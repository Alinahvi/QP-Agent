public with sharing class ANAgentFilterParser {

    public class ParsedFilter {
        public Boolean isValid;
        public String soqlWhere;
        public String errorMessage;
        public String display;

        public ParsedFilter(Boolean ok, String whereClause, String err, String disp) {
            this.isValid = ok;
            this.soqlWhere = whereClause;
            this.errorMessage = err;
            this.display = disp;
        }
    }

    // Entry point
    public static ParsedFilter parse(String input) {
        String disp = input;
        if (String.isBlank(input)) {
            return new ParsedFilter(false, null, 'Empty or invalid filter', disp);
        }

        // 1) Normalize whitespace and keep original for display
        String src = input.trim();

        // 2) Normalize common aliases in values (done pre-tokenization for simplicity)
        // NOTE: keep these on ONE line each to avoid broken string literals
        src = src.replaceAll('(?i)USA', 'US')
                 .replaceAll('(?i)U\\.S\\.', 'US')
                 .replaceAll('(?i)United\\s+States', 'US');

        src = src.replaceAll('(?i)Brasil', 'Brazil')
                 .replaceAll('(?i)U\\.K\\.', 'UKI')
                 .replaceAll('(?i)\\bUK\\b', 'UKI');

        // 3) Tokenize a simple grammar supporting:
        //    <cond> ::= <expr> ( (AND|OR) <expr> )*
        //    <expr> ::= <field> <op> <value> | <field> IN (val[, val]*)
        //    <field> ::= alphaNum/_ (friendly keys) 
        //    <op> ::= = | != | > | >= | < | <=
        //    <value> ::= number | 'string' | "string"
        // We do a light-weight parse by splitting on AND/OR at top level, then parse each expression.
        List<String> parts = splitTopLevel(src, new List<String>{' AND ', ' and ', ' And ', ' OR ', ' or ', ' Or '});
        if (parts.isEmpty()) {
            return new ParsedFilter(false, null, 'Could not parse filter', disp);
        }

        List<String> outExprs = new List<String>();
        Integer idx = 0;
        while (idx < parts.size()) {
            String token = parts[idx];
            String delim = null;
            if (idx + 1 < parts.size()) {
                delim = parts[idx + 1]; // ' AND ' / ' OR '
            }

            // Parse a single expression token
            String soqlExpr = parseExpression(token);
            if (soqlExpr == null) {
                return new ParsedFilter(false, null, 'Invalid expression: ' + token.trim(), disp);
            }
            outExprs.add(soqlExpr);

            // Append the logical delimiter (normalized) if present
            if (delim != null) {
                String d = delim.trim().toUpperCase();
                if (d.equals('AND') || d.equals('OR')) {
                    outExprs.add(d);
                } else {
                    return new ParsedFilter(false, null, 'Invalid logical operator: ' + delim, disp);
                }
            }

            idx += (delim == null ? 1 : 2);
        }

        // 4) Join into final where
        String finalWhere = String.join(outExprs, ' ');
        return new ParsedFilter(true, finalWhere, null, disp);
    }

    // --- Helpers ---

    // Split the string into [expr, delim, expr, delim, expr...] while preserving quoted strings
    private static List<String> splitTopLevel(String s, List<String> delims) {
        List<String> out = new List<String>();
        String current = '';
        Boolean inSingle = false;
        Boolean inDouble = false;

        Integer i = 0;
        while (i < s.length()) {
            String ch = s.substring(i, i + 1);

            if (ch == '\'' && !inDouble) {
                inSingle = !inSingle;
                current += ch;
                i++;
                continue;
            }
            if (ch == '"' && !inSingle) {
                inDouble = !inDouble;
                current += ch;
                i++;
                continue;
            }

            // Only consider delimiters when not inside quotes
            if (!inSingle && !inDouble) {
                // Try each delimiter
                Boolean matched = false;
                for (String d : delims) {
                    Integer len = d.length();
                    if (i + len <= s.length()) {
                        String slice = s.substring(i, i + len);
                        if (slice == d) {
                            // Flush current token
                            if (current.length() > 0) {
                                out.add(current.trim());
                                current = '';
                            } else {
                                out.add('');
                            }
                            // Add the delimiter token
                            out.add(d);
                            i += len;
                            matched = true;
                            break;
                        }
                    }
                }
                if (matched) continue;
            }

            current += ch;
            i++;
        }

        if (current.length() > 0) {
            out.add(current.trim());
        }

        // If no delimiter found, out will be a single chunk (the whole string)
        return out;
    }

    // Parse one expression like:
    //   field IN ('A','B')
    //   field >= 10
    //   field = 'US'
    private static String parseExpression(String exprRaw) {
        String expr = exprRaw.trim();
        if (String.isBlank(expr)) return null;

        // Handle IN clause first (case-insensitive)
        // Pattern: <field> IN ( ... )
        // We'll detect the IN keyword when not inside quotes.
        Integer posIn = indexOfToken(expr, 'IN');
        if (posIn > 0) {
            String left = expr.substring(0, posIn).trim();
            String right = expr.substring(posIn + 2).trim(); // after 'IN'
            if (!right.startsWith('(') || !right.endsWith(')')) return null;

            String fieldKey = left;
            String apiField = mapField(fieldKey);
            if (apiField == null) return null;

            String innerContent = right.substring(1, right.length() - 1).trim();
            if (String.isBlank(innerContent)) return null;

            List<String> vals = splitCsvRespectingQuotes(innerContent);
            if (vals.isEmpty()) return null;

            List<String> normVals = new List<String>();
            for (String vRaw : vals) {
                String v = vRaw.trim();
                v = stripQuotesIfAny(v);
                v = escapeSOQLLiteral(v);
                normVals.add('\'' + v + '\'');
            }

            return apiField + ' IN (' + String.join(normVals, ',') + ')';
        }

        // Otherwise, parse binary operator
        // Supported ops, longest first
        List<String> ops = new List<String>{'>=', '<=', '!=', '=', '>', '<'};
        for (String op : ops) {
            Integer p = indexOfOp(expr, op);
            if (p > 0) {
                String left = expr.substring(0, p).trim();
                String right = expr.substring(p + op.length()).trim();

                String api = mapField(left);
                if (api == null) return null;

                // Decide if right is string or number
                if (isQuoted(right)) {
                    String vq = stripQuotesIfAny(right);
                    vq = escapeSOQLLiteral(vq);
                    return api + ' ' + op + ' \'' + vq + '\'';
                } else if (isNumeric(right)) {
                    return api + ' ' + op + ' ' + right;
                } else {
                    // Bare identifier - treat as string
                    String v = escapeSOQLLiteral(right);
                    return api + ' ' + op + ' \'' + v + '\'';
                }
            }
        }

        return null; // no operator matched
    }

    // Map friendly field → API field (extend as needed)
    private static String mapField(String keyRaw) {
        if (String.isBlank(keyRaw)) return null;
        String k = keyRaw.trim().toLowerCase();

        // common synonyms
        if (k == 'country' || k == 'work_location_country' || k == 'work_location_country__c') return 'WORK_LOCATION_COUNTRY__c';
        if (k == 'ou' || k == 'operating_unit' || k == 'ou_name' || k == 'ou_name__c') return 'OU_NAME__c';
        if (k == 'industry' || k == 'primary_industry' || k == 'primary_industry__c') return 'PRIMARY_INDUSTRY__c';
        if (k == 'tenure' || k == 'tenure_months' || k == 'time_since_onboarding' || k == 'time_since_onboarding__c') return 'TIME_SINCE_ONBOARDING__c';
        if (k == 'acv' || k == 'cq_acv__c' || k == 'pq_acv__c') return 'CQ_ACV__c'; // CURRENT by default; PREVIOUS selection is handled by Spec
        if (k == 'pg' || k == 'pipeline' || k == 'cq_pg__c' || k == 'pq_pg__c') return 'CQ_PG__c';
        if (k == 'calls' || k == 'cq_call_connect__c' || k == 'pq_call_connect__c') return 'CQ_CALL_CONNECT__c';
        if (k == 'meetings' || k == 'cq_customer_meeting__c' || k == 'pq_customer_meeting__c') return 'CQ_CUSTOMER_MEETING__c';
        if (k == 'email' || k == 'emp_email_addr' || k == 'emp_email_addr__c') return 'EMP_EMAIL_ADDR__c';
        if (k == 'manager' || k == 'emp_mgr_nm' || k == 'emp_mgr_nm__c') return 'EMP_MGR_NM__c';
        if (k == 'name' || k == 'full_name' || k == 'full_name__c') return 'FULL_NAME__c';

        // Unknown field
        return null;
    }

    // Find operator outside quotes
    private static Integer indexOfOp(String s, String op) {
        Boolean inS = false, inD = false;
        for (Integer i = 0; i <= s.length() - op.length(); i++) {
            String ch = s.substring(i, i + 1);
            if (ch == '\'' && !inD) inS = !inS;
            else if (ch == '"' && !inS) inD = !inD;
            if (!inS && !inD) {
                if (s.substring(i, i + op.length()) == op) return i;
            }
        }
        return -1;
    }

    // Find token (e.g., IN) outside quotes, tokenized by whitespace
    private static Integer indexOfToken(String s, String token) {
        Boolean inS = false, inD = false;
        String t = token.toUpperCase();
        Integer i = 0;
        while (i < s.length()) {
            String ch = s.substring(i, i + 1);
            if (ch == '\'' && !inD) { inS = !inS; i++; continue; }
            if (ch == '"' && !inS)  { inD = !inD; i++; continue; }

            if (!inS && !inD) {
                // match whole word
                if (isLetter(s.charAt(i))) {
                    Integer j = i + 1;
                    while (j < s.length() && isLetter(s.charAt(j))) j++;
                    String word = s.substring(i, j).toUpperCase();
                    if (word == t) return i;
                    i = j;
                    continue;
                }
            }
            i++;
        }
        return -1;
    }

    // Helper to check if character is a letter (Apex doesn't have Character.isLetter)
    private static Boolean isLetter(Integer charCode) {
        return (charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122);
    }

    private static Boolean isQuoted(String s) {
        String t = s.trim();
        return (t.startsWith('\'') && t.endsWith('\'')) || (t.startsWith('"') && t.endsWith('"'));
    }

    private static String stripQuotesIfAny(String s) {
        String t = s.trim();
        if ((t.startsWith('\'') && t.endsWith('\'')) || (t.startsWith('"') && t.endsWith('"'))) {
            return t.substring(1, t.length() - 1);
        }
        return t;
    }

    private static Boolean isNumeric(String s) {
        String t = s.trim();
        if (t.length() == 0) return false;
        // Accept integers and decimals
        return Pattern.matches('[-+]?\\d+(\\.\\d+)?', t);
    }

    private static List<String> splitCsvRespectingQuotes(String s) {
        List<String> out = new List<String>();
        String cur = '';
        Boolean inS = false, inD = false;
        for (Integer i = 0; i < s.length(); i++) {
            String ch = s.substring(i, i + 1);
            if (ch == '\'' && !inD) {
                inS = !inS; cur += ch; continue;
            }
            if (ch == '"' && !inS) {
                inD = !inD; cur += ch; continue;
            }
            if (ch == ',' && !inS && !inD) {
                out.add(cur.trim());
                cur = '';
                continue;
            }
            cur += ch;
        }
        if (cur.length() > 0) out.add(cur.trim());
        return out;
    }

    private static String escapeSOQLLiteral(String v) {
        // Escape single quotes by doubling them
        return v.replace('\'', '\\\'').replace('\\\'', '\\\\\'').replaceAll('\\\\\\\\\\\'', '\\\\\'').replaceAll('\\\\\\\'', '\\\\\'').replaceAll('\\\'', '\\\'');
        // NOTE: Apex SOQL literal escaping is finicky; safest is to use String.escapeSingleQuotes at the call site,
        // but since we need *quoted* literals, we ensure we never introduce unbalanced quotes here.
    }
} 