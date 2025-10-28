/**
 * @description Program Search Service V5 - Clean implementation with enhanced validation
 * @author Sales Operations Team
 * @version 5.0
 * @date 2025-10-27
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts normalized Integer/Boolean values from handler (no string parsing)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent field mapping with Product_Catalog__c and Regional_Programs__c objects
 * - Better error messages for common failure scenarios
 * - No references to V4 code
 * 
 * Business Context: Searches Product_Catalog__c (Global programs) and Regional_Programs__c 
 * (Regional programs) with usage metrics from Enablement_Solutions__c for program discovery and planning.
 */
public with sharing class ANAgentProgramSearchServiceV5 {

    // Configuration constants
    private static final Integer DEFAULT_LIMIT = 50;
    private static final Integer MAX_LIMIT = 100;
    private static final Integer MIN_SEARCH_LENGTH = 2;
    
    // Usage thresholds for program analysis
    private static final Integer HIGH_USAGE_THRESHOLD = 10;
    private static final Integer RECENT_USAGE_THRESHOLD = 3;
    private static final Integer LOW_USAGE_THRESHOLD = 2;

    /* ---------- Error taxonomy helpers (JSON-first) ---------- */

    private static String ok(Object data) {
        Map<String, Object> res = new Map<String, Object>{
            'ok' => true,
            'data' => data,
            'error' => null
        };
        return JSON.serialize(res);
    }

    private static String err(String code, String message, String field, String expected, Object got,
                              List<String> samples, List<String> nextSteps) {
        Map<String, Object> res = new Map<String, Object>{
            'ok' => false,
            'data' => null,
            'error' => new Map<String, Object>{
                'code' => code,
                'message' => message,
                'details' => new Map<String, Object>{
                    'field' => field,
                    'expected' => expected,
                    'got' => got,
                    'samples' => (samples == null ? new List<String>() : samples),
                    'agent_next_steps' => (nextSteps == null ? new List<String>() : nextSteps)
                }
            }
        };
        return JSON.serialize(res);
    }

    /* ---------- Validation (agent-visible) ---------- */

    private static String validateRequest(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r, Integer limitValue, Boolean includeUsageMetrics, Boolean includeArchived) {
        // CRUD/FLS upfront for program objects
        if (!FRPermissionGuard.hasRead('Product_Catalog__c')) {
            return err('INSUFFICIENT_ACCESS', 'No read access to Product_Catalog__c (Global Programs catalog)',
                       'object', 'Read on Product_Catalog__c', null, null,
                       new List<String>{'Contact system administrator to grant read permissions on Product_Catalog__c object', 'This permission is required to search global enablement programs'});
        }
        if (!FRPermissionGuard.hasRead('Regional_Programs__c')) {
            return err('INSUFFICIENT_ACCESS', 'No read access to Regional_Programs__c (Regional Programs catalog)',
                       'object', 'Read on Regional_Programs__c', null, null,
                       new List<String>{'Contact system administrator to grant read permissions on Regional_Programs__c object', 'This permission is required to search regional enablement programs'});
        }
        if (!FRPermissionGuard.hasRead('Enablement_Solutions__c')) {
            return err('INSUFFICIENT_ACCESS', 'No read access to Enablement_Solutions__c (required for usage metrics)',
                       'object', 'Read on Enablement_Solutions__c', null, null,
                       new List<String>{'Contact system administrator to grant read permissions on Enablement_Solutions__c object', 'This permission is required for usage metrics enrichment (usageCount, totalLearners, recentUsage90Days)'});
        }
        if (!FRPermissionGuard.hasRead('Quarterly_Planning__c')) {
            return err('INSUFFICIENT_ACCESS', 'No read access to Quarterly_Planning__c (required for quarterly filtering)',
                       'object', 'Read on Quarterly_Planning__c', null, null,
                       new List<String>{'Contact system administrator to grant read permissions on Quarterly_Planning__c object', 'This permission is required when filtering by Fiscal Quarter and Fiscal Year'});
        }

        // Program type required
        if (String.isBlank(r.programType)) {
            return err('INVALID_INPUT', 'programType is required - specify which catalog to search',
                       'programType', 'GLOBAL|REGIONAL|BOTH', 'blank', 
                       new List<String>{'GLOBAL', 'REGIONAL', 'BOTH'},
                       new List<String>{'Use GLOBAL for standardized enterprise programs (172 active)', 'Use REGIONAL for localized programs (861 total)', 'Use BOTH for comprehensive search across both catalogs'});
        }

        // Program type validation
        Set<String> validProgramTypes = new Set<String>{'GLOBAL', 'REGIONAL', 'BOTH'};
        String normalizedType = r.programType.toUpperCase();
        if (!validProgramTypes.contains(normalizedType)) {
            return err('INVALID_INPUT', 'programType must be GLOBAL, REGIONAL, or BOTH',
                       'programType', 'GLOBAL|REGIONAL|BOTH', r.programType, 
                       new List<String>{'GLOBAL', 'REGIONAL', 'BOTH'},
                       new List<String>{'Use GLOBAL to search Product_Catalog__c (172 active standardized programs)', 'Use REGIONAL to search Regional_Programs__c (861 localized programs)', 'Use BOTH to search both catalogs simultaneously', 'Case-insensitive but check spelling'});
        }

        // Search term validation (only if provided)
        if (String.isNotBlank(r.searchTerm) && !FRSearchGuard.isValidSearchTerm(r.searchTerm, MIN_SEARCH_LENGTH)) {
            return err('INVALID_INPUT', 'searchTerm must be at least 2 characters long for meaningful search results',
                       'searchTerm', 'length >= 2', r.searchTerm, 
                       new List<String>{'AI', 'SE', 'AE', 'BDR', 'Slack', 'Tableau'},
                       new List<String>{'Provide longer search term and retry', 'Minimum 2 characters required to prevent overly broad results'});
        }

        // Enablement type validation
        if (String.isNotBlank(r.enablementType)) {
            Set<String> validEnablementTypes = new Set<String>{'PRODUCT', 'SKILLS', 'INDUSTRY', 'DO_MY_JOB', 'ALL'};
            String normalizedEnablement = r.enablementType.toUpperCase();
            if (!validEnablementTypes.contains(normalizedEnablement)) {
                return err('INVALID_INPUT', 'enablementType must be PRODUCT|SKILLS|INDUSTRY|DO_MY_JOB|ALL',
                           'enablementType', 'PRODUCT|SKILLS|INDUSTRY|DO_MY_JOB|ALL', r.enablementType, 
                           new List<String>{'PRODUCT', 'SKILLS', 'INDUSTRY', 'DO_MY_JOB', 'ALL'},
                           new List<String>{'Use PRODUCT for product training programs', 'Use SKILLS for soft skills and selling methodologies', 'Use INDUSTRY for industry-specific knowledge', 'Use DO_MY_JOB for role-specific job tasks', 'Use ALL for no filtering (default)', 'Case-insensitive'});
            }
        }

        // Target level validation
        if (String.isNotBlank(r.targetLevel)) {
            Set<String> validLevels = new Set<String>{'BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'ALL'};
            String normalizedLevel = r.targetLevel.toUpperCase();
            if (!validLevels.contains(normalizedLevel)) {
                return err('INVALID_INPUT', 'targetLevel must be BEGINNER|INTERMEDIATE|ADVANCED|EXPERT|ALL',
                           'targetLevel', 'BEGINNER|INTERMEDIATE|ADVANCED|EXPERT|ALL', r.targetLevel, 
                           new List<String>{'BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'ALL'},
                           new List<String>{'Use BEGINNER for foundational content (e.g., onboarding programs)', 'Use INTERMEDIATE for standard proficiency programs', 'Use ADVANCED for expert-level training', 'Use EXPERT for mastery-level programs', 'Note: Only applies to Global programs - Regional programs have no level field', 'Case-insensitive'});
            }
        }

        // Target role validation
        if (String.isNotBlank(r.targetRole)) {
            Set<String> validRoles = new Set<String>{'AE', 'SE', 'BDR', 'SDR', 'SALES_MANAGER', 'LEADER', 'CSM', 'SUCCESS_GUIDE', 'SERVICES', 'SPECIALIST_AE', 'PSE', 'ALL'};
            String normalizedRole = r.targetRole.toUpperCase();
            if (!validRoles.contains(normalizedRole)) {
                return err('INVALID_INPUT', 'targetRole must be a valid role code',
                           'targetRole', 'AE|SE|BDR|SDR|SALES_MANAGER|LEADER|CSM|SUCCESS_GUIDE|SERVICES|SPECIALIST_AE|PSE|ALL', r.targetRole, 
                           new List<String>{'AE', 'SE', 'BDR', 'SDR', 'SALES_MANAGER', 'LEADER', 'CSM', 'SUCCESS_GUIDE', 'SERVICES', 'SPECIALIST_AE', 'PSE'},
                           new List<String>{'Use AE for Account Executives', 'Use SE for Solution Engineers', 'Use BDR for Business Development Reps', 'Use SDR for Sales Development Reps', 'Use SALES_MANAGER for Sales Managers', 'Use LEADER for leadership roles', 'Note: Only applies to Global programs - Regional programs have limited role data', 'Case-insensitive'});
            }
        }

        // Fiscal quarter validation
        if (String.isNotBlank(r.fiscalQuarter)) {
            Set<String> validQuarters = new Set<String>{'Q1', 'Q2', 'Q3', 'Q4'};
            String normalizedQuarter = r.fiscalQuarter.toUpperCase();
            if (!validQuarters.contains(normalizedQuarter)) {
                return err('INVALID_INPUT', 'fiscalQuarter must be Q1, Q2, Q3, or Q4',
                           'fiscalQuarter', 'Q1|Q2|Q3|Q4', r.fiscalQuarter, 
                           new List<String>{'Q1', 'Q2', 'Q3', 'Q4'},
                           new List<String>{'Use Q1 for Feb-Apr period', 'Use Q2 for May-Jul period', 'Use Q3 for Aug-Oct period', 'Use Q4 for Nov-Jan period', 'Must be used WITH Fiscal Year parameter', 'Case-insensitive'});
            }
        }

        // Fiscal year validation
        if (String.isNotBlank(r.fiscalYear)) {
            String normalizedYear = r.fiscalYear.toUpperCase().trim();
            if (!normalizedYear.startsWith('FY ') && !normalizedYear.startsWith('FY')) {
                return err('INVALID_INPUT', 'fiscalYear must start with "FY" prefix',
                           'fiscalYear', 'FY YYYY (e.g., FY 2025)', r.fiscalYear, 
                           new List<String>{'FY 2024', 'FY 2025', 'FY 2026'},
                           new List<String>{'Use format "FY 2025" with FY prefix', 'Must be used WITH Fiscal Quarter parameter', 'Case-insensitive'});
            }
        }

        // Fiscal quarter/year must be used together
        if ((String.isNotBlank(r.fiscalQuarter) && String.isBlank(r.fiscalYear)) ||
            (String.isBlank(r.fiscalQuarter) && String.isNotBlank(r.fiscalYear))) {
            return err('INVALID_INPUT', 'Fiscal Quarter and Fiscal Year must be used together - cannot use one without the other',
                       'fiscalQuarter/fiscalYear', 'Both provided or both blank', 
                       'Quarter: ' + r.fiscalQuarter + ', Year: ' + r.fiscalYear, 
                       new List<String>{'fiscalQuarter=Q2, fiscalYear=FY 2025', 'fiscalQuarter=Q4, fiscalYear=FY 2024'},
                       new List<String>{'Provide both fiscalQuarter AND fiscalYear parameters', 'Or leave both blank to skip quarterly filtering', 'Example: fiscalQuarter=Q2, fiscalYear=FY 2025'});
        }

        // Global region validation
        if (String.isNotBlank(r.globalRegion)) {
            Set<String> validRegions = new Set<String>{'GLOBAL', 'AMER', 'EMEA', 'APAC', 'LATAM', 'JAPAN', 'ALL'};
            String normalizedRegion = r.globalRegion.toUpperCase();
            if (!validRegions.contains(normalizedRegion)) {
                return err('INVALID_INPUT', 'globalRegion must be a valid region code',
                           'globalRegion', 'GLOBAL|AMER|EMEA|APAC|LATAM|JAPAN|ALL', r.globalRegion, 
                           new List<String>{'GLOBAL', 'AMER', 'EMEA', 'APAC', 'LATAM', 'JAPAN'},
                           new List<String>{'Use GLOBAL for worldwide programs', 'Use AMER for Americas', 'Use EMEA for Europe/Middle East/Africa', 'Use APAC for Asia Pacific', 'Use ALL for no regional filter', 'Case-insensitive'});
            }
        }

        // Session type validation
        if (String.isNotBlank(r.sessionType)) {
            Set<String> validSessions = new Set<String>{'VIRTUAL', 'PHYSICAL', 'HYBRID', 'ALL'};
            String normalizedSession = r.sessionType.toUpperCase();
            if (!validSessions.contains(normalizedSession)) {
                return err('INVALID_INPUT', 'sessionType must be VIRTUAL|PHYSICAL|HYBRID|ALL',
                           'sessionType', 'VIRTUAL|PHYSICAL|HYBRID|ALL', r.sessionType, 
                           new List<String>{'VIRTUAL', 'PHYSICAL', 'HYBRID', 'ALL'},
                           new List<String>{'Use VIRTUAL for online/remote delivery', 'Use PHYSICAL for in-person/onsite delivery', 'Use HYBRID for combination delivery', 'Note: Only applies to Regional programs - Global programs do not have session type field', 'Case-insensitive'});
            }
        }

        // Sort by validation
        if (String.isNotBlank(r.sortBy)) {
            Set<String> validSort = new Set<String>{'USAGE_COUNT', 'TOTAL_LEARNERS', 'RECENT_USAGE', 'NAME', 'HOURS', 'DEFAULT'};
            String normalizedSort = r.sortBy.toUpperCase();
            if (!validSort.contains(normalizedSort)) {
                return err('INVALID_INPUT', 'sortBy must be USAGE_COUNT|TOTAL_LEARNERS|RECENT_USAGE|NAME|HOURS|DEFAULT',
                           'sortBy', 'USAGE_COUNT|TOTAL_LEARNERS|RECENT_USAGE|NAME|HOURS|DEFAULT', r.sortBy, 
                           new List<String>{'USAGE_COUNT', 'TOTAL_LEARNERS', 'RECENT_USAGE', 'NAME', 'HOURS', 'DEFAULT'},
                           new List<String>{'Use DEFAULT for recommended sorting (usage count, then total learners)', 'Use USAGE_COUNT to find frequently scheduled programs', 'Use TOTAL_LEARNERS to find high-reach programs', 'Use RECENT_USAGE to find actively used programs', 'Use HOURS to sort by time investment', 'Metrics-based sorting requires includeUsageMetrics=true', 'Case-insensitive'});
            }
        }

        // Sort order validation
        if (String.isNotBlank(r.sortOrder)) {
            Set<String> validOrder = new Set<String>{'ASC', 'DESC'};
            String normalizedOrder = r.sortOrder.toUpperCase();
            if (!validOrder.contains(normalizedOrder)) {
                return err('INVALID_INPUT', 'sortOrder must be ASC or DESC',
                           'sortOrder', 'ASC|DESC', r.sortOrder, 
                           new List<String>{'ASC', 'DESC'},
                           new List<String>{'Use DESC (default) to show top performers first (highest usage, most learners)', 'Use ASC to find underutilized programs or shortest duration programs', 'Case-insensitive'});
            }
        }

        // Limit validation
        if (limitValue != null && !FRSearchGuard.isInRange(limitValue, 1, MAX_LIMIT)) {
            return err('INVALID_INPUT', 'limit must be between 1 and 100',
                       'limit', '1–100', limitValue, 
                       new List<String>{'20', '50', '100'}, 
                       new List<String>{'Use 50 (default) for standard analysis', 'Use 100 for comprehensive results', 'Use 20 for quick overview', 'When searching BOTH catalogs, limit applies per catalog (max 200 total)'});
        }

        // Hours validation
        if (r.minHoursRequired != null && r.minHoursRequired < 0) {
            return err('INVALID_INPUT', 'minHoursRequired must be >= 0',
                       'minHoursRequired', '>= 0', r.minHoursRequired, 
                       new List<String>{'0.5', '1', '2', '4', '8'},
                       new List<String>{'Use 0.5 for 30-minute programs', 'Use 1 for 1-hour sessions', 'Use 4 for half-day programs', 'Use 8 for full-day programs'});
        }
        if (r.maxHoursRequired != null && r.maxHoursRequired < 0) {
            return err('INVALID_INPUT', 'maxHoursRequired must be >= 0',
                       'maxHoursRequired', '>= 0', r.maxHoursRequired, 
                       new List<String>{'1', '2', '4', '8', '16'},
                       new List<String>{'Use 2 for short programs', 'Use 8 for single-day programs', 'Use 16 for multi-day programs'});
        }
        if (r.minHoursRequired != null && r.maxHoursRequired != null && r.maxHoursRequired < r.minHoursRequired) {
            return err('INVALID_INPUT', 'maxHoursRequired must be >= minHoursRequired for valid time range',
                       'maxHoursRequired', '>= ' + r.minHoursRequired, r.maxHoursRequired, 
                       new List<String>{'minHours=1, maxHours=2', 'minHours=4, maxHours=8'},
                       new List<String>{'Ensure maxHoursRequired >= minHoursRequired', 'Example: minHours=1, maxHours=4 finds programs 1-4 hours long'});
        }

        return null;
    }

    /* ---------- Smart Search Preprocessing ---------- */

    private class SmartSearchContext {
        public String enhancedSearchTerm;
        public List<String> synonyms = new List<String>();
        public String countryKeyword;
        public String extractedRegion;
        public String extractedEnablementType;
        public String extractedLevel;
        public String extractedSortBy;
        public Decimal extractedMinHours;
        public Decimal extractedMaxHours;
    }

    private static SmartSearchContext preprocessSearchTerm(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r) {
        SmartSearchContext ctx = new SmartSearchContext();
        
        // Handle optional search term
        if (String.isBlank(r.searchTerm)) {
            ctx.enhancedSearchTerm = '';
            return ctx; // No preprocessing needed for empty search
        }
        
        String term = r.searchTerm.toLowerCase().trim();
        ctx.enhancedSearchTerm = r.searchTerm; // Default to original
        
        // 1. DURATION EXTRACTION
        if (term.contains('30 min') || term.contains('30 minute') || term.contains('thirty minute')) {
            ctx.extractedMinHours = 0.5;
            ctx.extractedMaxHours = 0.5;
        } else if (term.contains('1 hour') || term.contains('one hour') || term.contains('1-hour')) {
            ctx.extractedMinHours = 1;
            ctx.extractedMaxHours = 1;
        } else if (term.contains('under 2 hour') || term.contains('less than 2 hour') || term.contains('< 2 hour')) {
            ctx.extractedMaxHours = 2;
        } else if (term.contains('under 3 hour') || term.contains('less than 3 hour')) {
            ctx.extractedMaxHours = 3;
        } else if (term.contains('lunch') && term.contains('learn')) {
            ctx.extractedMinHours = 0.5;
            ctx.extractedMaxHours = 1.5;
        } else if (term.contains('quick') || term.contains('short')) {
            ctx.extractedMaxHours = 1;
        } else if (term.contains('half-day') || term.contains('half day')) {
            ctx.extractedMinHours = 3;
            ctx.extractedMaxHours = 5;
        } else if (term.contains('full-day') || term.contains('full day')) {
            ctx.extractedMinHours = 6;
            ctx.extractedMaxHours = 10;
        } else if (term.contains('multi-day') || term.contains('multi day') || term.contains('comprehensive') || term.contains('immersive')) {
            ctx.extractedMinHours = 8;
        } else if (term.contains('multi-week') || term.contains('multi week')) {
            ctx.extractedMinHours = 40;
        }
        
        // 2. LEVEL EXTRACTION
        if (term.contains('beginner') || term.contains('foundational') || term.contains('basic')) {
            ctx.extractedLevel = 'BEGINNER';
        } else if (term.contains('intermediate') || term.contains('mid-level')) {
            ctx.extractedLevel = 'INTERMEDIATE';
        } else if (term.contains('advanced') || term.contains('expert')) {
            ctx.extractedLevel = 'ADVANCED';
        }
        
        // 3. SYNONYM EXPANSION
        if (term.contains('soft skill') || term.contains('people skill')) {
            ctx.extractedEnablementType = 'SKILLS';
            ctx.synonyms.add('Skills');
        }
        
        // 4. COUNTRY MAPPING TO REGIONS
        if (term.contains('france') || term.contains('french')) {
            ctx.extractedRegion = 'EMEA';
            ctx.countryKeyword = 'France';
        } else if (term.contains('india') || term.contains('south asia')) {
            ctx.extractedRegion = 'APAC';
            ctx.countryKeyword = 'India';
        } else if (term.contains('australia') || term.contains('anz')) {
            ctx.extractedRegion = 'APAC';
            ctx.countryKeyword = 'ANZ';
        } else if (term.contains('uk') || term.contains('britain') || term.contains('uki')) {
            ctx.extractedRegion = 'EMEA';
            ctx.countryKeyword = 'UKI';
        } else if (term.contains('japan') || term.contains('japanese')) {
            ctx.extractedRegion = 'JAPAN';
            ctx.countryKeyword = 'Japan';
        }
        
        // 5. POPULARITY/USAGE DETECTION
        if (term.contains('most popular') || term.contains('frequently used') || term.contains('most used')) {
            ctx.extractedSortBy = 'USAGE_COUNT';
        } else if (term.contains('most people') || term.contains('trained the most') || term.contains('highest enrollment')) {
            ctx.extractedSortBy = 'TOTAL_LEARNERS';
        } else if (term.contains('recently used') || term.contains('currently') || term.contains('active')) {
            ctx.extractedSortBy = 'RECENT_USAGE';
        }
        
        return ctx;
    }

    private static String expandBusinessPriority(String businessPriority) {
        if (String.isBlank(businessPriority)) return null;
        
        String term = businessPriority.toLowerCase().trim();
        
        // Map user-friendly terms to database values
        if (term.contains('acv') && term.contains('growth')) return 'ACV/AOV';
        if (term.contains('big deal')) return 'Big Deal Motion';
        if (term.contains('ceo') && term.contains('business')) return 'CEO of your Business';
        if (term.contains('ai') && term.contains('data') && term.contains('crm')) return 'AI + Data + CRM';
        if (term.contains('hvs') || (term.contains('high') && term.contains('value'))) return 'High-Value Selling';
        if (term.contains('industry 360')) return 'Industry 360';
        if (term.contains('ou priority')) return 'OU Priority';
        if (term.contains('leader excellence')) return 'Leader';
        if (term.contains('technical product')) return 'Technical Product Knowledge';
        
        // Return original if no mapping
        return businessPriority;
    }

    /* ---------- Public entry (JSON-first, no silent fixes) ---------- */

    public static String search(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r, Integer limitValue, Boolean includeUsageMetrics, Boolean includeArchived) {
        try {
            // Validate request
            String v = validateRequest(r, limitValue, includeUsageMetrics, includeArchived);
            if (v != null) return v;

            // SMART SEARCH PREPROCESSING - Extract implicit parameters and expand synonyms
            SmartSearchContext ctx = preprocessSearchTerm(r);

            // Normalize parameters with defaults (enhanced with extracted values)
            String programType = r.programType.toUpperCase();
            String enablementType = String.isNotBlank(ctx.extractedEnablementType) ? ctx.extractedEnablementType.toUpperCase() : 
                                    (String.isNotBlank(r.enablementType) ? r.enablementType.toUpperCase() : 'ALL');
            String targetLevel = String.isNotBlank(ctx.extractedLevel) ? ctx.extractedLevel.toUpperCase() :
                                (String.isNotBlank(r.targetLevel) ? r.targetLevel.toUpperCase() : 'ALL');
            String targetRole = String.isNotBlank(r.targetRole) ? r.targetRole.toUpperCase() : 'ALL';
            String globalRegion = String.isNotBlank(ctx.extractedRegion) ? ctx.extractedRegion :
                                 (String.isNotBlank(r.globalRegion) ? r.globalRegion.toUpperCase() : 'ALL');
            String sessionType = String.isNotBlank(r.sessionType) ? r.sessionType.toUpperCase() : 'ALL';
            String sortBy = String.isNotBlank(ctx.extractedSortBy) ? ctx.extractedSortBy :
                           (String.isNotBlank(r.sortBy) ? r.sortBy.toUpperCase() : 'DEFAULT');
            String sortOrder = String.isNotBlank(r.sortOrder) ? r.sortOrder.toUpperCase() : 'DESC';
            Integer limitVal = (limitValue == null) ? DEFAULT_LIMIT : Math.min(Math.max(limitValue, 1), MAX_LIMIT);
            Boolean includeMetrics = (includeUsageMetrics == null) ? true : includeUsageMetrics;
            Boolean includeArchivedVal = (includeArchived == null) ? false : includeArchived;
            
            // Override with extracted duration constraints if present
            Decimal minHours = ctx.extractedMinHours != null ? ctx.extractedMinHours : r.minHoursRequired;
            Decimal maxHours = ctx.extractedMaxHours != null ? ctx.extractedMaxHours : r.maxHoursRequired;
            
            // Update request with extracted values
            if (minHours != null) r.minHoursRequired = minHours;
            if (maxHours != null) r.maxHoursRequired = maxHours;

            // Get quarterly plan filter if provided
            Set<String> quarterlyFilteredProgramIds = null;
            if (String.isNotBlank(r.fiscalQuarter) && String.isNotBlank(r.fiscalYear)) {
                quarterlyFilteredProgramIds = getProgramsInQuarterlyPlan(
                    r.fiscalQuarter.toUpperCase(), 
                    r.fiscalYear.toUpperCase(), 
                    globalRegion.equals('ALL') ? null : globalRegion,
                    programType
                );
                // If quarterly filter returns no programs, return empty result
                if (quarterlyFilteredProgramIds.isEmpty()) {
                    return buildEmptyResult(r, 'No programs found for ' + r.fiscalQuarter + ' ' + r.fiscalYear + 
                        (globalRegion.equals('ALL') ? '' : ' ' + globalRegion) + ' - no matching quarterly plans or programs');
                }
            }

            // Route to appropriate search method
            if (programType == 'GLOBAL') {
                return searchGlobalPrograms(r, enablementType, targetLevel, targetRole, globalRegion, 
                                           sortBy, sortOrder, limitVal, includeMetrics, includeArchivedVal,
                                           quarterlyFilteredProgramIds);
            } else if (programType == 'REGIONAL') {
                return searchRegionalPrograms(r, enablementType, sessionType, globalRegion,
                                             sortBy, sortOrder, limitVal, includeMetrics,
                                             quarterlyFilteredProgramIds);
            } else {
                // BOTH mode
                return searchBothPrograms(r, enablementType, targetLevel, targetRole, globalRegion, sessionType,
                                         sortBy, sortOrder, limitVal, includeMetrics, includeArchivedVal,
                                         quarterlyFilteredProgramIds);
            }

        } catch (QueryException qe) {
            return err('QUERY_ERROR', 'Database query failed while searching programs: ' + qe.getMessage(), 
                       'soql', 'valid SOQL query', qe.getMessage(), 
                       null,
                       new List<String>{'Reduce filter complexity and retry', 'Simplify search term to avoid special characters', 'Check that fiscal quarter/year values are valid', 'Contact support if error persists with error message: ' + qe.getMessage()});
        } catch (SecurityException se) {
            return err('SECURITY_ERROR', 'Access denied while querying program or related objects: ' + se.getMessage(), 
                       'security', 'CRUD/FLS permissions for Product_Catalog__c, Regional_Programs__c, Enablement_Solutions__c, Quarterly_Planning__c', se.getMessage(), 
                       null,
                       new List<String>{'Request read permissions on Product_Catalog__c, Regional_Programs__c, Enablement_Solutions__c, Quarterly_Planning__c', 'Contact system administrator for permission grants'});
        } catch (Exception e) {
            return err('UNEXPECTED_ERROR', 'Unexpected system error during program search: ' + e.getMessage(), 
                       'service', 'successful execution', e.getMessage(), 
                       null,
                       new List<String>{'Retry the search with simplified criteria', 'Reduce number of filters applied', 'Try searching one catalog at a time (GLOBAL or REGIONAL instead of BOTH)', 'If error persists, escalate with error message: ' + e.getMessage() + ' at line: ' + e.getLineNumber()});
        }
    }

    /* ---------- Quarterly Plan Filtering ---------- */

    private static Set<String> getProgramsInQuarterlyPlan(String quarter, String year, String region, String programType) {
        Set<String> programIds = new Set<String>();
        
        try {
            // Step 1: Find matching Quarterly Plans
            String qpQuery = 'SELECT Id FROM Quarterly_Planning__c WHERE Fiscal_Quarter__c = \'' + 
                             String.escapeSingleQuotes(quarter) + '\' AND Fiscal_Year__c = \'' + 
                             String.escapeSingleQuotes(year) + '\'';
            
            if (String.isNotBlank(region)) {
                qpQuery += ' AND Global_Region__c = \'' + String.escapeSingleQuotes(region) + '\'';
            }
            
            List<Quarterly_Planning__c> plans = Database.query(qpQuery);
            if (plans.isEmpty()) {
                return programIds; // Return empty set
            }
            
            Set<String> planIds = new Set<String>();
            for (Quarterly_Planning__c p : plans) {
                planIds.add(p.Id);
            }
            
            // Step 2: Find programs used in those plans
            if (programType == 'GLOBAL' || programType == 'BOTH') {
                for (Enablement_Solutions__c es : [
                    SELECT GE_Program_Menu_Item__c 
                    FROM Enablement_Solutions__c 
                    WHERE Quarterly_Plan__c IN :planIds 
                      AND GE_Program_Menu_Item__c != null
                ]) {
                    programIds.add(es.GE_Program_Menu_Item__c);
                }
            }
            
            if (programType == 'REGIONAL' || programType == 'BOTH') {
                for (Enablement_Solutions__c es : [
                    SELECT Regional_Program_Menu_Item__c 
                    FROM Enablement_Solutions__c 
                    WHERE Quarterly_Plan__c IN :planIds 
                      AND Regional_Program_Menu_Item__c != null
                ]) {
                    programIds.add(es.Regional_Program_Menu_Item__c);
                }
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Quarterly plan filtering error: ' + e.getMessage());
        }
        
        return programIds;
    }

    /* ---------- Global Programs Search ---------- */

    private static String searchGlobalPrograms(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r,
                                              String enablementType, String targetLevel, String targetRole,
                                              String globalRegion, String sortBy, String sortOrder,
                                              Integer limitVal, Boolean includeMetrics, Boolean includeArchived,
                                              Set<String> quarterlyFilteredIds) {
        List<ProgramInfo> results = new List<ProgramInfo>();
        
        try {
            // Get smart search context for enhanced search
            SmartSearchContext ctx = preprocessSearchTerm(r);
            String expandedBizPriority = expandBusinessPriority(r.businessPriority);
            
            // Build multi-field fuzzy search query (Note: Description__c is Long Text and cannot be in WHERE clause)
            String query = 'SELECT Id, Name, Course_Asset_Title__c, Description__c, ' +
                          'Program_Menu_Item_Health__c, Enablement_Type__c, Level__c, Role__c, ' +
                          'L1_Cloud_Product__c, L2_Product_Line__c, L3_Product_Family__c, ' +
                          'Excellence_Skill__c, Excellence_Competency__c, Excellence_Factor__c, ' +
                          'Total_Learner_Time_Investment__c, Delivery_Cadence__c, Regions__c, ' +
                          'Market_Segments__c, Asset_Link__c, Highspot_Link__c, CreatedDate ' +
                          'FROM Product_Catalog__c ';
            
            // Add search term filter if provided
            List<String> whereConditions = new List<String>();
            if (String.isNotBlank(r.searchTerm)) {
                whereConditions.add('(Course_Asset_Title__c LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\' OR Business_Priority__c LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\')');
            }
            
            // Add country keyword search if present
            if (String.isNotBlank(ctx.countryKeyword)) {
                whereConditions.add('Course_Asset_Title__c LIKE \'%' + String.escapeSingleQuotes(ctx.countryKeyword) + '%\'');
            }
            
            // Status filter
            if (!includeArchived) {
                whereConditions.add('Program_Menu_Item_Health__c = \'Active\'');
            }
            
            // Enablement type filter
            if (!enablementType.equals('ALL')) {
                String enablementValue = enablementType.replace('_', ' '); // DO_MY_JOB → Do My Job
                whereConditions.add('Enablement_Type__c INCLUDES (\'' + String.escapeSingleQuotes(enablementValue) + '\')');
            }
            
            // Level filter (include nulls to avoid missing programs)
            if (!targetLevel.equals('ALL')) {
                whereConditions.add('(Level__c = \'' + String.escapeSingleQuotes(targetLevel.capitalize()) + '\' OR Level__c = null)');
            }
            
            // Role filter (include nulls)
            if (!targetRole.equals('ALL')) {
                String roleValue = targetRole.replace('_', ' '); // SALES_MANAGER → Sales Manager
                whereConditions.add('(Role__c INCLUDES (\'' + String.escapeSingleQuotes(roleValue) + '\') OR Role__c = null)');
            }
            
            // Hours filter
            if (r.minHoursRequired != null) {
                whereConditions.add('Total_Learner_Time_Investment__c >= ' + r.minHoursRequired);
            }
            if (r.maxHoursRequired != null) {
                whereConditions.add('Total_Learner_Time_Investment__c <= ' + r.maxHoursRequired);
            }
            
            // Quarterly plan filter
            if (quarterlyFilteredIds != null) {
                if (quarterlyFilteredIds.isEmpty()) {
                    return buildEmptyResult(r, 'No global programs found in specified quarterly plan');
                }
                String idList = '\'' + String.join(new List<String>(quarterlyFilteredIds), '\',\'') + '\'';
                whereConditions.add('Id IN (' + idList + ')');
            }
            
            // Build WHERE clause
            if (!whereConditions.isEmpty()) {
                query += ' WHERE ' + String.join(whereConditions, ' AND ');
            }
            
            query += ' ORDER BY CreatedDate DESC LIMIT ' + (limitVal * 2); // Get extra for post-filtering

            // Execute query
            List<SObject> records = Database.query(query);
            
            // Apply security stripping
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
            records = decision.getRecords();
            
            // Convert to ProgramInfo and apply post-filters
            for (SObject record : records) {
                ProgramInfo info = new ProgramInfo(record, 'Global');
                
                // Post-filter: Description (cannot filter in SOQL due to Long Text field)
                // Only boost relevance if search term found in description, don't exclude
                Boolean descriptionMatch = false;
                if (String.isNotBlank(r.searchTerm) && String.isNotBlank(info.description) && 
                    info.description.toLowerCase().contains(r.searchTerm.toLowerCase())) {
                    descriptionMatch = true;
                }
                
                // Post-filter: Business priority (fuzzy matching with expanded term)
                if (String.isNotBlank(expandedBizPriority)) {
                    Boolean matchFound = false;
                    
                    // Check business priority field
                    if (String.isNotBlank(info.businessPriority) && 
                        info.businessPriority.toLowerCase().contains(expandedBizPriority.toLowerCase())) {
                        matchFound = true;
                    }
                    
                    // Check excellence factors field
                    if (!matchFound && String.isNotBlank(info.excellenceFactors) && 
                        info.excellenceFactors.toLowerCase().contains(expandedBizPriority.toLowerCase())) {
                        matchFound = true;
                    }
                    
                    // Check original business priority term
                    if (!matchFound && String.isNotBlank(info.businessPriority) && 
                        info.businessPriority.toLowerCase().contains(r.businessPriority.toLowerCase())) {
                        matchFound = true;
                    }
                    
                    if (!matchFound) {
                        continue; // Skip if doesn't match any field
                    }
                }
                
                results.add(info);
            }
            
            // Enrich with usage metrics if requested
            if (includeMetrics && !results.isEmpty()) {
                enrichWithGlobalMetrics(results);
            }
            
            // Sort results
            sortPrograms(results, sortBy, sortOrder, includeMetrics);
            
            // Apply final limit after sorting
            if (results.size() > limitVal) {
                List<ProgramInfo> limited = new List<ProgramInfo>();
                for (Integer i = 0; i < limitVal; i++) {
                    limited.add(results[i]);
                }
                results = limited;
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error searching global programs: ' + e.getMessage());
            throw e;
        }

        return buildResponse(results, r, 'GLOBAL', sortBy, sortOrder, includeMetrics);
    }

    /* ---------- Regional Programs Search ---------- */

    private static String searchRegionalPrograms(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r,
                                                String enablementType, String sessionType, String globalRegion,
                                                String sortBy, String sortOrder, Integer limitVal,
                                                Boolean includeMetrics, Set<String> quarterlyFilteredIds) {
        List<ProgramInfo> results = new List<ProgramInfo>();
        
        try {
            // Get smart search context for enhanced search
            SmartSearchContext ctx = preprocessSearchTerm(r);
            String expandedBizPriority = expandBusinessPriority(r.businessPriority);
            
            // Build multi-field fuzzy search query
            String query = 'SELECT Id, Name, Regional_Program_Name__c, Enablement_Type__c, ' +
                          'Business_Priority__c, Excellence_Competency__c, Excellence_Factor__c, ' +
                          'Hours__c, Session_Type__c, Fast_Start__c, CreatedDate ' +
                          'FROM Regional_Programs__c ';
            
            // Build WHERE conditions
            List<String> whereConditions = new List<String>{'IsDeleted = false'};
            
            // Add search term filter if provided
            if (String.isNotBlank(r.searchTerm)) {
                whereConditions.add('(Regional_Program_Name__c LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\' OR Business_Priority__c LIKE \'%' + String.escapeSingleQuotes(r.searchTerm) + '%\')');
            }
            
            // Add country keyword search if present
            if (String.isNotBlank(ctx.countryKeyword)) {
                whereConditions.add('Regional_Program_Name__c LIKE \'%' + String.escapeSingleQuotes(ctx.countryKeyword) + '%\'');
            }
            
            // Enablement type filter (Regional uses single-select picklist, not multi-select)
            if (!enablementType.equals('ALL')) {
                String enablementValue = enablementType.replace('_', ' ');
                whereConditions.add('(Enablement_Type__c = \'' + String.escapeSingleQuotes(enablementValue) + '\' OR Enablement_Type__c = null)');
            }
            
            // Session type filter (include nulls)
            if (!sessionType.equals('ALL')) {
                whereConditions.add('(Session_Type__c = \'' + String.escapeSingleQuotes(sessionType.capitalize()) + '\' OR Session_Type__c = null)');
            }
            
            // Hours filter
            if (r.minHoursRequired != null) {
                whereConditions.add('Hours__c >= ' + r.minHoursRequired);
            }
            if (r.maxHoursRequired != null) {
                whereConditions.add('Hours__c <= ' + r.maxHoursRequired);
            }
            
            // Quarterly plan filter
            if (quarterlyFilteredIds != null) {
                if (quarterlyFilteredIds.isEmpty()) {
                    return buildEmptyResult(r, 'No regional programs found in specified quarterly plan');
                }
                String idList = '\'' + String.join(new List<String>(quarterlyFilteredIds), '\',\'') + '\'';
                whereConditions.add('Id IN (' + idList + ')');
            }
            
            // Build WHERE clause
            if (!whereConditions.isEmpty()) {
                query += ' WHERE ' + String.join(whereConditions, ' AND ');
            }
            
            query += ' ORDER BY CreatedDate DESC LIMIT ' + (limitVal * 2);

            // Execute query
            List<SObject> records = Database.query(query);
            
            // Apply security stripping
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
            records = decision.getRecords();
            
            // Convert to ProgramInfo and apply post-filters
            for (SObject record : records) {
                ProgramInfo info = new ProgramInfo(record, 'Regional');
                
                // Post-filter: Business priority (fuzzy matching with expanded term)
                if (String.isNotBlank(expandedBizPriority)) {
                    Boolean matchFound = false;
                    
                    // Check business priority field
                    if (String.isNotBlank(info.businessPriority) && 
                        info.businessPriority.toLowerCase().contains(expandedBizPriority.toLowerCase())) {
                        matchFound = true;
                    }
                    
                    // Check excellence factors field
                    if (!matchFound && String.isNotBlank(info.excellenceFactors) && 
                        info.excellenceFactors.toLowerCase().contains(expandedBizPriority.toLowerCase())) {
                        matchFound = true;
                    }
                    
                    // Check original business priority term
                    if (!matchFound && String.isNotBlank(info.businessPriority) && 
                        info.businessPriority.toLowerCase().contains(r.businessPriority.toLowerCase())) {
                        matchFound = true;
                    }
                    
                    if (!matchFound) {
                        continue; // Skip if doesn't match any field
                    }
                }
                
                results.add(info);
            }
            
            // Enrich with usage metrics if requested
            if (includeMetrics && !results.isEmpty()) {
                enrichWithRegionalMetrics(results);
            }
            
            // Sort results
            sortPrograms(results, sortBy, sortOrder, includeMetrics);
            
            // Apply final limit
            if (results.size() > limitVal) {
                List<ProgramInfo> limited = new List<ProgramInfo>();
                for (Integer i = 0; i < limitVal; i++) {
                    limited.add(results[i]);
                }
                results = limited;
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error searching regional programs: ' + e.getMessage());
            throw e;
        }

        return buildResponse(results, r, 'REGIONAL', sortBy, sortOrder, includeMetrics);
    }

    /* ---------- Both Programs Search ---------- */

    private static String searchBothPrograms(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r,
                                            String enablementType, String targetLevel, String targetRole,
                                            String globalRegion, String sessionType, String sortBy, String sortOrder,
                                            Integer limitVal, Boolean includeMetrics, Boolean includeArchived,
                                            Set<String> quarterlyFilteredIds) {
        List<ProgramInfo> allResults = new List<ProgramInfo>();
        
        // Get global programs
        String globalJson = searchGlobalPrograms(r, enablementType, targetLevel, targetRole, globalRegion,
                                                sortBy, sortOrder, limitVal, includeMetrics, includeArchived,
                                                quarterlyFilteredIds);
        Map<String, Object> globalResponse = (Map<String, Object>)JSON.deserializeUntyped(globalJson);
        if ((Boolean)globalResponse.get('ok')) {
            Map<String, Object> globalData = (Map<String, Object>)globalResponse.get('data');
            List<Object> globalRecords = (List<Object>)globalData.get('records');
            // Note: Would need to deserialize back to ProgramInfo for sorting, but for simplicity return separate sections
        }
        
        // Get regional programs
        String regionalJson = searchRegionalPrograms(r, enablementType, sessionType, globalRegion,
                                                    sortBy, sortOrder, limitVal, includeMetrics,
                                                    quarterlyFilteredIds);
        Map<String, Object> regionalResponse = (Map<String, Object>)JSON.deserializeUntyped(regionalJson);
        
        // Build combined response
        Map<String, Object> combinedData = new Map<String, Object>{
            'analysisType' => 'PROGRAM_SEARCH_BOTH',
            'searchTerm' => r.searchTerm,
            'filters' => buildFiltersMap(r),
            'global' => (Boolean)globalResponse.get('ok') ? globalResponse.get('data') : null,
            'regional' => (Boolean)regionalResponse.get('ok') ? regionalResponse.get('data') : null
        };
        
        return ok(combinedData);
    }

    /* ---------- Usage Metrics Enrichment ---------- */

    private static void enrichWithGlobalMetrics(List<ProgramInfo> programs) {
        if (programs == null || programs.isEmpty()) return;
        
        Set<String> programIds = new Set<String>();
        for (ProgramInfo p : programs) {
            programIds.add(p.id);
        }
        
        try {
            // Get usage metrics in aggregate queries
            Map<String, ProgramMetrics> metricsMap = new Map<String, ProgramMetrics>();
            
            // Query 1: Total usage and learners
            List<AggregateResult> usageResults = [
                SELECT GE_Program_Menu_Item__c programId,
                       COUNT(Id) usageCount,
                       SUM(of_Learners__c) totalLearners,
                       MAX(Delivery_Date__c) lastScheduled
                FROM Enablement_Solutions__c
                WHERE GE_Program_Menu_Item__c IN :programIds
                  AND of_Learners__c != null
                GROUP BY GE_Program_Menu_Item__c
            ];
            
            for (AggregateResult ar : usageResults) {
                String pId = (String)ar.get('programId');
                ProgramMetrics m = new ProgramMetrics();
                m.usageCount = (Integer)ar.get('usageCount');
                m.totalLearners = ar.get('totalLearners') != null ? ((Decimal)ar.get('totalLearners')).intValue() : 0;
                m.lastScheduledDate = (Date)ar.get('lastScheduled');
                m.avgLearnersPerInstance = m.usageCount > 0 ? (m.totalLearners / m.usageCount) : 0;
                metricsMap.put(pId, m);
            }
            
            // Query 2: Recent usage (last 90 days)
            List<AggregateResult> recentResults = [
                SELECT GE_Program_Menu_Item__c programId,
                       COUNT(Id) recentCount
                FROM Enablement_Solutions__c
                WHERE GE_Program_Menu_Item__c IN :programIds
                  AND Delivery_Date__c >= LAST_N_DAYS:90
                GROUP BY GE_Program_Menu_Item__c
            ];
            
            for (AggregateResult ar : recentResults) {
                String pId = (String)ar.get('programId');
                if (metricsMap.containsKey(pId)) {
                    metricsMap.get(pId).recentUsage90Days = (Integer)ar.get('recentCount');
                } else {
                    ProgramMetrics m = new ProgramMetrics();
                    m.recentUsage90Days = (Integer)ar.get('recentCount');
                    metricsMap.put(pId, m);
                }
            }
            
            // Apply metrics to programs
            for (ProgramInfo p : programs) {
                if (metricsMap.containsKey(p.id)) {
                    p.metrics = metricsMap.get(p.id);
                } else {
                    p.metrics = new ProgramMetrics(); // Empty metrics
                }
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error enriching global program metrics: ' + e.getMessage());
        }
    }

    private static void enrichWithRegionalMetrics(List<ProgramInfo> programs) {
        if (programs == null || programs.isEmpty()) return;
        
        Set<String> programIds = new Set<String>();
        for (ProgramInfo p : programs) {
            programIds.add(p.id);
        }
        
        try {
            Map<String, ProgramMetrics> metricsMap = new Map<String, ProgramMetrics>();
            
            // Query 1: Total usage and learners
            List<AggregateResult> usageResults = [
                SELECT Regional_Program_Menu_Item__c programId,
                       COUNT(Id) usageCount,
                       SUM(of_Learners__c) totalLearners,
                       MAX(Delivery_Date__c) lastScheduled
                FROM Enablement_Solutions__c
                WHERE Regional_Program_Menu_Item__c IN :programIds
                  AND of_Learners__c != null
                GROUP BY Regional_Program_Menu_Item__c
            ];
            
            for (AggregateResult ar : usageResults) {
                String pId = (String)ar.get('programId');
                ProgramMetrics m = new ProgramMetrics();
                m.usageCount = (Integer)ar.get('usageCount');
                m.totalLearners = ar.get('totalLearners') != null ? ((Decimal)ar.get('totalLearners')).intValue() : 0;
                m.lastScheduledDate = (Date)ar.get('lastScheduled');
                m.avgLearnersPerInstance = m.usageCount > 0 ? (m.totalLearners / m.usageCount) : 0;
                metricsMap.put(pId, m);
            }
            
            // Query 2: Recent usage
            List<AggregateResult> recentResults = [
                SELECT Regional_Program_Menu_Item__c programId,
                       COUNT(Id) recentCount
                FROM Enablement_Solutions__c
                WHERE Regional_Program_Menu_Item__c IN :programIds
                  AND Delivery_Date__c >= LAST_N_DAYS:90
                GROUP BY Regional_Program_Menu_Item__c
            ];
            
            for (AggregateResult ar : recentResults) {
                String pId = (String)ar.get('programId');
                if (metricsMap.containsKey(pId)) {
                    metricsMap.get(pId).recentUsage90Days = (Integer)ar.get('recentCount');
                } else {
                    ProgramMetrics m = new ProgramMetrics();
                    m.recentUsage90Days = (Integer)ar.get('recentCount');
                    metricsMap.put(pId, m);
                }
            }
            
            // Apply metrics
            for (ProgramInfo p : programs) {
                if (metricsMap.containsKey(p.id)) {
                    p.metrics = metricsMap.get(p.id);
                } else {
                    p.metrics = new ProgramMetrics();
                }
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error enriching regional program metrics: ' + e.getMessage());
        }
    }

    /* ---------- Sorting ---------- */

    private static void sortPrograms(List<ProgramInfo> programs, String sortBy, String sortOrder, Boolean hasMetrics) {
        if (programs == null || programs.isEmpty()) return;
        
        Boolean ascending = sortOrder.equals('ASC');
        
        if (sortBy.equals('USAGE_COUNT') && hasMetrics) {
            programs.sort(new UsageCountComparator(ascending));
        } else if (sortBy.equals('TOTAL_LEARNERS') && hasMetrics) {
            programs.sort(new TotalLearnersComparator(ascending));
        } else if (sortBy.equals('RECENT_USAGE') && hasMetrics) {
            programs.sort(new RecentUsageComparator(ascending));
        } else if (sortBy.equals('HOURS')) {
            programs.sort(new HoursComparator(ascending));
        } else if (sortBy.equals('NAME')) {
            programs.sort(new NameComparator(ascending));
        } else {
            // DEFAULT: Usage count DESC, then total learners DESC
            if (hasMetrics) {
                programs.sort(new DefaultComparator());
            } else {
                programs.sort(new NameComparator(false)); // Fall back to name if no metrics
            }
        }
    }

    /* ---------- Response Builders ---------- */

    private static String buildResponse(List<ProgramInfo> programs, 
                                       ANAgentProgramSearchHandlerV5.ProgramSearchRequest r,
                                       String catalogType, String sortBy, String sortOrder, Boolean hasMetrics) {
        // Calculate summary metrics
        Integer totalPrograms = programs.size();
        Integer totalUsageCount = 0;
        Integer totalLearnersAllInstances = 0;
        Integer recentUsage90DaysCount = 0;
        Decimal totalHours = 0;
        Integer programsWithHours = 0;
        Integer globalCount = 0;
        Integer regionalCount = 0;
        Integer highUsageCount = 0;
        Integer lowUsageCount = 0;
        Integer recentlyUsedCount = 0;
        
        for (ProgramInfo p : programs) {
            if (p.programType == 'Global') globalCount++;
            if (p.programType == 'Regional') regionalCount++;
            
            if (p.hoursRequired != null && p.hoursRequired > 0) {
                totalHours += p.hoursRequired;
                programsWithHours++;
            }
            
            if (hasMetrics && p.metrics != null) {
                totalUsageCount += p.metrics.usageCount;
                totalLearnersAllInstances += p.metrics.totalLearners;
                recentUsage90DaysCount += p.metrics.recentUsage90Days;
                
                if (p.metrics.usageCount >= HIGH_USAGE_THRESHOLD) {
                    highUsageCount++;
                }
                if (p.metrics.usageCount > 0 && p.metrics.usageCount < LOW_USAGE_THRESHOLD) {
                    lowUsageCount++;
                }
                if (p.metrics.recentUsage90Days > 0) {
                    recentlyUsedCount++;
                }
            }
        }
        
        Decimal avgHours = programsWithHours > 0 ? (totalHours / programsWithHours) : 0;
        
        // Build summary
        Map<String, Object> summary = new Map<String, Object>{
            'totalPrograms' => totalPrograms,
            'catalogBreakdown' => new Map<String, Integer>{
                'global' => globalCount,
                'regional' => regionalCount
            },
            'avgHoursRequired' => Math.round(avgHours * 10) / 10.0
        };
        
        if (hasMetrics) {
            summary.put('totalUsageCount', totalUsageCount);
            summary.put('totalLearnersAllInstances', totalLearnersAllInstances);
            summary.put('recentUsage90DaysCount', recentUsage90DaysCount);
            summary.put('highUsagePrograms', highUsageCount);
            summary.put('lowUsagePrograms', lowUsageCount);
            summary.put('recentlyUsedPrograms', recentlyUsedCount);
        }
        
        // Build records
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (ProgramInfo p : programs) {
            Map<String, Object> record = new Map<String, Object>{
                'id' => p.id,
                'name' => p.name,
                'programTitle' => p.programTitle,
                'programType' => p.programType,
                'enablementType' => p.enablementType,
                'targetLevel' => p.targetLevel,
                'targetRoles' => p.targetRoles,
                'description' => truncateDescription(p.description),
                'hoursRequired' => p.hoursRequired,
                'deliveryCadence' => p.deliveryCadence,
                'sessionType' => p.sessionType,
                'regions' => p.regions,
                'businessPriority' => p.businessPriority,
                'status' => p.status,
                'products' => p.products,
                'productLine' => p.productLine,
                'skills' => p.skills,
                'competencies' => p.competencies,
                'excellenceFactors' => p.excellenceFactors,
                'marketSegments' => p.marketSegments,
                'fastStart' => p.fastStart,
                'links' => new Map<String, String>{
                    'assetLink' => p.assetLink,
                    'programLink' => p.highspotLink
                },
                'createdDate' => p.createdDate
            };
            
            if (hasMetrics && p.metrics != null) {
                record.put('metrics', new Map<String, Object>{
                    'usageCount' => p.metrics.usageCount,
                    'totalLearners' => p.metrics.totalLearners,
                    'recentUsage90Days' => p.metrics.recentUsage90Days,
                    'lastScheduledDate' => p.metrics.lastScheduledDate,
                    'avgLearnersPerInstance' => p.metrics.avgLearnersPerInstance
                });
            }
            
            records.add(record);
        }
        
        // Build response data
        Map<String, Object> data = new Map<String, Object>{
            'analysisType' => 'PROGRAM_SEARCH_' + catalogType,
            'searchTerm' => r.searchTerm,
            'catalogType' => catalogType,
            'filters' => buildFiltersMap(r),
            'sortBy' => sortBy,
            'sortOrder' => sortOrder,
            'includeUsageMetrics' => hasMetrics,
            'summary' => summary,
            'records' => records,
            'dataQualityNotes' => buildDataQualityNotes(catalogType)
        };
        
        return ok(data);
    }

    private static String buildEmptyResult(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r, String reason) {
        Map<String, Object> data = new Map<String, Object>{
            'analysisType' => 'PROGRAM_SEARCH_EMPTY',
            'searchTerm' => r.searchTerm,
            'reason' => reason,
            'summary' => new Map<String, Object>{
                'totalPrograms' => 0,
                'catalogBreakdown' => new Map<String, Integer>{'global' => 0, 'regional' => 0}
            },
            'records' => new List<Object>(),
            'suggestions' => new List<String>{
                'Try broader search terms',
                'Remove fiscal quarter/year filter if applied',
                'Use programType=BOTH to search both catalogs',
                'Check spelling of search term'
            }
        };
        return ok(data);
    }

    private static Map<String, String> buildFiltersMap(ANAgentProgramSearchHandlerV5.ProgramSearchRequest r) {
        Map<String, String> filters = new Map<String, String>();
        if (String.isNotBlank(r.enablementType) && !r.enablementType.toUpperCase().equals('ALL')) {
            filters.put('enablementType', r.enablementType);
        }
        if (String.isNotBlank(r.targetLevel) && !r.targetLevel.toUpperCase().equals('ALL')) {
            filters.put('targetLevel', r.targetLevel);
        }
        if (String.isNotBlank(r.targetRole) && !r.targetRole.toUpperCase().equals('ALL')) {
            filters.put('targetRole', r.targetRole);
        }
        if (String.isNotBlank(r.globalRegion) && !r.globalRegion.toUpperCase().equals('ALL')) {
            filters.put('globalRegion', r.globalRegion);
        }
        if (String.isNotBlank(r.sessionType) && !r.sessionType.toUpperCase().equals('ALL')) {
            filters.put('sessionType', r.sessionType);
        }
        if (String.isNotBlank(r.businessPriority)) filters.put('businessPriority', r.businessPriority);
        if (String.isNotBlank(r.fiscalQuarter)) filters.put('fiscalQuarter', r.fiscalQuarter);
        if (String.isNotBlank(r.fiscalYear)) filters.put('fiscalYear', r.fiscalYear);
        if (r.minHoursRequired != null) filters.put('minHours', String.valueOf(r.minHoursRequired));
        if (r.maxHoursRequired != null) filters.put('maxHours', String.valueOf(r.maxHoursRequired));
        return filters;
    }

    private static List<String> buildDataQualityNotes(String catalogType) {
        List<String> notes = new List<String>();
        
        if (catalogType == 'GLOBAL' || catalogType == 'BOTH') {
            notes.add('Global programs: Only 172 of 540 are Active (32%). Archived programs excluded unless includeArchived=true.');
            notes.add('Global programs: products field (L1_Cloud_Product__c) only 24% populated - use program title for product hints.');
            notes.add('Global programs: skills field (Excellence_Skill__c) only 50% populated - many programs have null skills.');
            notes.add('Global programs: level field 76% populated, role field 74% populated - nulls included in results.');
            notes.add('Global programs: description field 56% populated - not all programs have detailed descriptions.');
        }
        
        if (catalogType == 'REGIONAL' || catalogType == 'BOTH') {
            notes.add('Regional programs: No status field exists - all 861 non-deleted programs shown as potentially active.');
            notes.add('Regional programs: No description field - use programTitle (Regional_Program_Name__c) for content understanding.');
            notes.add('Regional programs: No level or role fields - cannot filter by target level or role.');
            notes.add('Regional programs: No product or skill fields - use keywords in program names.');
            notes.add('Regional programs: Business_Priority__c 100% populated - reliable for strategic filtering.');
            notes.add('Regional programs: Session_Type__c 90% populated - good for delivery format filtering.');
            notes.add('Regional programs: Filter by recentUsage90Days > 0 to find actively used programs (proxy for "active" status).');
        }
        
        return notes;
    }

    /* ---------- Helper Methods ---------- */

    private static String truncateDescription(String description) {
        if (String.isBlank(description)) return null;
        // Remove HTML tags for cleaner output
        String cleaned = description.stripHtmlTags();
        if (cleaned.length() <= 300) return cleaned;
        return cleaned.substring(0, 300) + '...';
    }

    /* ---------- Data Model ---------- */

    private class ProgramInfo {
        public String id, name, programTitle, programType, enablementType, targetLevel, targetRoles;
        public String description, deliveryCadence, sessionType, regions, businessPriority, status;
        public String products, productLine, skills, competencies, excellenceFactors, marketSegments, fastStart;
        public String assetLink, highspotLink;
        public Decimal hoursRequired;
        public Datetime createdDate;
        public ProgramMetrics metrics;
        
        public ProgramInfo(SObject record, String type) {
            this.programType = type;
            this.id = (String)record.get('Id');
            
            if (type == 'Global') {
                this.name = (String)record.get('Name');
                this.programTitle = (String)record.get('Course_Asset_Title__c');
                this.description = (String)record.get('Description__c');
                this.status = (String)record.get('Program_Menu_Item_Health__c');
                this.enablementType = (String)record.get('Enablement_Type__c');
                this.targetLevel = (String)record.get('Level__c');
                this.targetRoles = (String)record.get('Role__c');
                this.products = (String)record.get('L1_Cloud_Product__c');
                this.productLine = (String)record.get('L2_Product_Line__c');
                this.skills = (String)record.get('Excellence_Skill__c');
                this.competencies = (String)record.get('Excellence_Competency__c');
                this.excellenceFactors = (String)record.get('Excellence_Factor__c');
                this.hoursRequired = (Decimal)record.get('Total_Learner_Time_Investment__c');
                this.deliveryCadence = (String)record.get('Delivery_Cadence__c');
                this.regions = (String)record.get('Regions__c');
                this.marketSegments = (String)record.get('Market_Segments__c');
                this.assetLink = (String)record.get('Asset_Link__c');
                this.highspotLink = (String)record.get('Highspot_Link__c');
                this.sessionType = null; // Global doesn't have this
                this.fastStart = null;
                this.businessPriority = null; // Global has it but rarely populated
            } else {
                // Regional
                this.name = (String)record.get('Name');
                this.programTitle = (String)record.get('Regional_Program_Name__c');
                this.enablementType = (String)record.get('Enablement_Type__c');
                this.businessPriority = (String)record.get('Business_Priority__c');
                this.competencies = (String)record.get('Excellence_Competency__c');
                this.excellenceFactors = (String)record.get('Excellence_Factor__c');
                this.hoursRequired = (Decimal)record.get('Hours__c');
                this.sessionType = (String)record.get('Session_Type__c');
                this.fastStart = (String)record.get('Fast_Start__c');
                this.status = 'Active (inferred - no status field in Regional_Programs__c)';
                this.description = null; // Regional doesn't have description
                this.targetLevel = null;
                this.targetRoles = null;
                this.products = null;
                this.productLine = null;
                this.skills = null;
                this.deliveryCadence = null;
                this.regions = null;
                this.marketSegments = null;
                this.assetLink = null;
                this.highspotLink = null;
            }
            
            this.createdDate = (Datetime)record.get('CreatedDate');
            this.metrics = new ProgramMetrics(); // Initialize empty, enriched later
        }
    }

    private class ProgramMetrics {
        public Integer usageCount = 0;
        public Integer totalLearners = 0;
        public Integer recentUsage90Days = 0;
        public Date lastScheduledDate = null;
        public Integer avgLearnersPerInstance = 0;
    }

    /* ---------- Comparators ---------- */

    private class UsageCountComparator implements Comparator<ProgramInfo> {
        Boolean isAscending;
        public UsageCountComparator(Boolean ascending) { this.isAscending = ascending; }
        public Integer compare(ProgramInfo a, ProgramInfo b) {
            Integer countA = (a.metrics != null) ? a.metrics.usageCount : 0;
            Integer countB = (b.metrics != null) ? b.metrics.usageCount : 0;
            if (countA > countB) return isAscending ? 1 : -1;
            if (countA < countB) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class TotalLearnersComparator implements Comparator<ProgramInfo> {
        Boolean isAscending;
        public TotalLearnersComparator(Boolean ascending) { this.isAscending = ascending; }
        public Integer compare(ProgramInfo a, ProgramInfo b) {
            Integer learnersA = (a.metrics != null) ? a.metrics.totalLearners : 0;
            Integer learnersB = (b.metrics != null) ? b.metrics.totalLearners : 0;
            if (learnersA > learnersB) return isAscending ? 1 : -1;
            if (learnersA < learnersB) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class RecentUsageComparator implements Comparator<ProgramInfo> {
        Boolean isAscending;
        public RecentUsageComparator(Boolean ascending) { this.isAscending = ascending; }
        public Integer compare(ProgramInfo a, ProgramInfo b) {
            Integer recentA = (a.metrics != null) ? a.metrics.recentUsage90Days : 0;
            Integer recentB = (b.metrics != null) ? b.metrics.recentUsage90Days : 0;
            if (recentA > recentB) return isAscending ? 1 : -1;
            if (recentA < recentB) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class HoursComparator implements Comparator<ProgramInfo> {
        Boolean isAscending;
        public HoursComparator(Boolean ascending) { this.isAscending = ascending; }
        public Integer compare(ProgramInfo a, ProgramInfo b) {
            Decimal hoursA = (a.hoursRequired != null) ? a.hoursRequired : 0;
            Decimal hoursB = (b.hoursRequired != null) ? b.hoursRequired : 0;
            if (hoursA > hoursB) return isAscending ? 1 : -1;
            if (hoursA < hoursB) return isAscending ? -1 : 1;
            return 0;
        }
    }

    private class NameComparator implements Comparator<ProgramInfo> {
        Boolean isAscending;
        public NameComparator(Boolean ascending) { this.isAscending = ascending; }
        public Integer compare(ProgramInfo a, ProgramInfo b) {
            String nameA = (a.programTitle != null) ? a.programTitle : '';
            String nameB = (b.programTitle != null) ? b.programTitle : '';
            Integer comp = nameA.compareTo(nameB);
            return isAscending ? comp : -comp;
        }
    }

    private class DefaultComparator implements Comparator<ProgramInfo> {
        public Integer compare(ProgramInfo a, ProgramInfo b) {
            // Sort by usage count DESC, then total learners DESC
            Integer countA = (a.metrics != null) ? a.metrics.usageCount : 0;
            Integer countB = (b.metrics != null) ? b.metrics.usageCount : 0;
            if (countA > countB) return -1;
            if (countA < countB) return 1;
            
            Integer learnersA = (a.metrics != null) ? a.metrics.totalLearners : 0;
            Integer learnersB = (b.metrics != null) ? b.metrics.totalLearners : 0;
            if (learnersA > learnersB) return -1;
            if (learnersA < learnersB) return 1;
            
            return 0;
        }
    }
}

