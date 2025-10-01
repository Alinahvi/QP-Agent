/**
 * MINIMAL VERSION - Test if the large field mapping is causing heap issues
 */
public with sharing class ABAgentRenewalsAnalysisServiceMinimal {

    // Minimal field mapping
    private static final Map<String, String> GROUP_FIELD_MAP = new Map<String, String>{
        'AE' => 'full_name__c'
    };

    /**
     * Main method to analyze Renewals data using aggregate queries
     */
    public static String analyzeRenewals(String ouName, String workLocationCountry, String groupBy,
                                      String filterCriteria, String restrictInValuesCsv,
                                      Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {

        try {
            // Validate groupBy parameter
            if (String.isBlank(groupBy) || !GROUP_FIELD_MAP.containsKey(groupBy)) {
                return buildErrorMessage('Invalid groupBy parameter: ' + groupBy);
            }

            // Use aggregate queries to prevent memory issues
            return buildAnalysisFromAggregateQuery(ouName, workLocationCountry, groupBy, filterCriteria,
                                                 restrictInValuesCsv, perAENormalize, limitN, aggregationType, analysisType);

        } catch (Exception e) {
            return buildErrorMessage('Renewals analysis failed: ' + e.getMessage());
        }
    }

    /**
     * Builds analysis using aggregate queries to prevent memory issues
     */
    private static String buildAnalysisFromAggregateQuery(String ouName, String workLocationCountry, String groupBy,
                                                        String filterCriteria, String restrictInValuesCsv,
                                                        Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType) {
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        String message = '';

        // Header
        message += '# Renewals Analysis (Minimal Version)\n\n';

        // Summary
        message += '## Summary\n';
        if (String.isNotBlank(ouName)) {
            message += '- **OU**: ' + ouName + '\n';
        }
        if (String.isNotBlank(workLocationCountry)) {
            message += '- **Work Location Country**: ' + workLocationCountry + '\n';
        }
        message += '- **Grouped By**: ' + groupBy + '\n';
        message += '- **Analysis Type**: ' + analysisType + '\n';
        message += '- **Filter**: ' + (String.isNotBlank(filterCriteria) ? filterCriteria : 'None') + '\n';
        message += '- **Per-AE Normalized**: ' + (perAENormalize ? 'Yes' : 'No') + '\n';
        if (limitN != null && limitN > 0) {
            message += '- **Limit Applied**: ' + limitN + '\n';
        }
        message += '\n';

        try {
            // Build aggregate query
            String aggregateQuery = buildAggregateQuery(ouName, workLocationCountry, groupBy, filterCriteria, limitN);
            System.debug('Aggregate Query: ' + aggregateQuery);
            
            List<AggregateResult> results = Database.query(aggregateQuery);
            
            message += '## Insights\n';
            message += '- **Records Found**: ' + results.size() + ' groups\n';
            message += '\n';

            // Process results
            message += buildAEAnalysisFromAggregate(results, limitN, aggregationType);

            // Data (JSON)
            message += '## Data (JSON)\n';
            message += '```json\n';
            message += buildJSONFromAggregate(results, groupBy, limitN);
            message += '\n```\n';

        } catch (Exception e) {
            message += '## Error\n';
            message += 'Failed to execute aggregate query: ' + e.getMessage() + '\n';
            System.debug('Aggregate query error: ' + e.getStackTraceString());
        }

        return message;
    }

    /**
     * Builds aggregate query for memory-efficient analysis
     */
    private static String buildAggregateQuery(String ouName, String workLocationCountry, String groupBy,
                                            String filterCriteria, Integer limitN) {
        
        String groupField = GROUP_FIELD_MAP.get(groupBy);
        
        // Build aggregate query
        String query = 'SELECT ' + groupField + ', COUNT(Id) recordCount, SUM(renewal_opty_amt__c) totalAmount, ';
        query += 'AVG(renewal_opty_amt__c) avgAmount, MAX(renewal_opty_amt__c) maxAmount, MIN(renewal_opty_amt__c) minAmount ';
        query += 'FROM Agent_Renewals__c';

        // Build WHERE clause
        List<String> whereClauses = new List<String>();

        // Add work location country filter if provided
        if (String.isNotBlank(workLocationCountry)) {
            whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
        }

        // Add null checks for grouping field
        if (String.isNotBlank(groupField)) {
            whereClauses.add(groupField + ' != null');
        }

        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + String.join(whereClauses, ' AND ');
        }

        // Add GROUP BY
        query += ' GROUP BY ' + groupField;

        // Add ORDER BY
        query += ' ORDER BY SUM(renewal_opty_amt__c) DESC';

        // Add LIMIT
        Integer effectiveLimit = limitN != null ? limitN : 10;
        query += ' LIMIT ' + effectiveLimit;

        return query;
    }

    /**
     * Builds AE analysis from aggregate results
     */
    private static String buildAEAnalysisFromAggregate(List<AggregateResult> results, Integer limitN, String aggregationType) {
        String insights = '\n**AE Analysis**:\n';

        for (AggregateResult result : results) {
            String aeName = (String)result.get('full_name__c');
            Integer count = (Integer)result.get('recordCount');
            Decimal totalAmount = (Decimal)result.get('totalAmount');
            Decimal avgAmount = (Decimal)result.get('avgAmount');
            Decimal maxAmount = (Decimal)result.get('maxAmount');
            Decimal minAmount = (Decimal)result.get('minAmount');

            if (String.isNotBlank(aeName)) {
                insights += '- **' + aeName + '**: ' + count + ' renewal opportunities';
                
                switch on aggregationType {
                    when 'SUM' {
                        insights += ', $' + (totalAmount != null ? String.valueOf(totalAmount.setScale(2)) : '0.00') + ' total amount';
                    }
                    when 'AVG' {
                        insights += ', $' + (avgAmount != null ? String.valueOf(avgAmount.setScale(2)) : '0.00') + ' average amount';
                    }
                    when 'MAX' {
                        insights += ', $' + (maxAmount != null ? String.valueOf(maxAmount.setScale(2)) : '0.00') + ' max amount';
                    }
                    when 'MIN' {
                        insights += ', $' + (minAmount != null ? String.valueOf(minAmount.setScale(2)) : '0.00') + ' min amount';
                    }
                    when 'COUNT' {
                        insights += ', ' + count + ' opportunities';
                    }
                    when else {
                        insights += ', $' + (totalAmount != null ? String.valueOf(totalAmount.setScale(2)) : '0.00') + ' total amount';
                    }
                }
                insights += '\n';
            }
        }

        return insights;
    }

    /**
     * Builds JSON from aggregate results
     */
    private static String buildJSONFromAggregate(List<AggregateResult> results, String groupBy, Integer limitN) {
        String jsonResult = '{\n';
        jsonResult += '  "groups": [\n';
        
        for (Integer i = 0; i < results.size(); i++) {
            AggregateResult result = results[i];
            String groupValue = (String)result.get('full_name__c');
            Integer count = (Integer)result.get('recordCount');
            Decimal totalAmount = (Decimal)result.get('totalAmount');
            Decimal avgAmount = (Decimal)result.get('avgAmount');
            Decimal maxAmount = (Decimal)result.get('maxAmount');
            Decimal minAmount = (Decimal)result.get('minAmount');

            if (String.isNotBlank(groupValue)) {
                if (i > 0) jsonResult += ',\n';
                jsonResult += '    {\n';
                jsonResult += '      "name": "' + String.escapeSingleQuotes(groupValue) + '",\n';
                jsonResult += '      "count": ' + count + ',\n';
                jsonResult += '      "totalAmount": ' + (totalAmount != null ? totalAmount.setScale(2) : 0) + ',\n';
                jsonResult += '      "avgAmount": ' + (avgAmount != null ? avgAmount.setScale(2) : 0) + ',\n';
                jsonResult += '      "maxAmount": ' + (maxAmount != null ? maxAmount.setScale(2) : 0) + ',\n';
                jsonResult += '      "minAmount": ' + (minAmount != null ? minAmount.setScale(2) : 0) + '\n';
                jsonResult += '    }';
            }
        }
        
        jsonResult += '\n  ]\n';
        jsonResult += '}';
        
        return jsonResult;
    }

    /**
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# Renewals Analysis\n\n## Error\n' + errorMessage;
    }
}
