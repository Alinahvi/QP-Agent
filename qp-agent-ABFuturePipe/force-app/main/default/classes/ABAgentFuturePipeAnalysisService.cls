/**
 * UNIFIED FUTURE PIPELINE ANALYSIS SERVICE
 *
 * This service consolidates Renewals, Cross-sell, and Upsell analysis into a single unified service.
 * It uses aggregate queries to prevent heap size issues and provides consistent analysis across all pipeline types.
 *
 * Key Features:
 * - Unified analysis for RENEWALS, CROSS_SELL, and UPSELL
 * - Aggregate-only queries (no raw record loading)
 * - Governor-safe limits and validation
 * - Minimal memory footprint
 * - Type-aware field mapping and DTO handling
 *
 * @version 1.0 - Unified Analysis Service
 */
public with sharing class ABAgentFuturePipeAnalysisService {

    // Analysis type enum for type safety
    public enum AnalysisType { RENEWALS, CROSS_SELL, UPSELL }
    
    // Enhanced analysis types for advanced capabilities
    public enum EnhancedAnalysisType { 
        RENEWALS, CROSS_SELL, UPSELL,
        CROSS_REGION_COMPARISON,
        INDUSTRY_BENCHMARKING,
        PERFORMANCE_RANKING,
        MARKET_PENETRATION_ANALYSIS,
        TREND_ANALYSIS
    }

    // Object mapping by analysis type
    private static final Map<String, String> OBJECT_MAP = new Map<String, String>{
        'RENEWALS' => 'Agent_Renewals__c',
        'CROSS_SELL' => 'Agent_Cross_Sell__c',
        'UPSELL' => 'Agent_Upsell__c'
    };

    // Field mapping by analysis type and grouping option
    private static final Map<String, Map<String, String>> GROUP_FIELD_MAP = new Map<String, Map<String, String>>{
        'RENEWALS' => new Map<String, String>{
            'AE' => 'full_name__c',
            'OU' => 'ou_name__c',
            'COUNTRY' => 'work_location_country__c',
            'PRODUCT' => 'renewal_prod_nm__c',
            'INDUSTRY' => 'primary_industry__c',
            'MACRO_SEGMENT' => 'macrosgment__c',
            'MANAGER' => 'emp_mgr_nm__c',
            'ACCOUNT' => 'renewal_acct_nm__c',
            'LEARNER_PROFILE' => 'learner_profile_id__c'
        },
        'CROSS_SELL' => new Map<String, String>{
            'PRODUCT' => 'cross_sell_next_best_product__c',
            'INDUSTRY' => 'primary_industry__c',
            'MACRO_SEGMENT' => 'macrosgment__c',
            'AE' => 'full_name__c',
            'COUNTRY' => 'work_location_country__c',
            'MANAGER' => 'emp_mgr_nm__c',
            'ACCOUNT' => 'cross_sell_acct_nm__c',
            'LEARNER_PROFILE' => 'learner_profile_id__c'
        },
        'UPSELL' => new Map<String, String>{
            'PRODUCT' => 'upsell_sub_category__c',
            'INDUSTRY' => 'primary_industry__c',
            'MACRO_SEGMENT' => 'macrosgment__c',
            'AE' => 'full_name__c',
            'COUNTRY' => 'work_location_country__c',
            'MANAGER' => 'emp_mgr_nm__c',
            'ACCOUNT' => 'upsell_acct_nm__c',
            'LEARNER_PROFILE' => 'learner_profile_id__c'
        }
    };

    // Amount field mapping by analysis type
    private static final Map<String, String> AMOUNT_FIELD_MAP = new Map<String, String>{
        'RENEWALS' => 'renewal_opty_amt__c',
        'CROSS_SELL' => null, // No amount field
        'UPSELL' => null      // No amount field
    };

    // Account field mapping by analysis type
    private static final Map<String, String> ACCOUNT_FIELD_MAP = new Map<String, String>{
        'RENEWALS' => 'renewal_acct_nm__c',
        'CROSS_SELL' => 'cross_sell_acct_nm__c',
        'UPSELL' => 'upsell_acct_nm__c'
    };

    // Product field mapping by analysis type
    private static final Map<String, String> PRODUCT_FIELD_MAP = new Map<String, String>{
        'RENEWALS' => 'renewal_prod_nm__c',
        'CROSS_SELL' => 'cross_sell_next_best_product__c',
        'UPSELL' => 'upsell_sub_category__c'
    };

    // Enhanced field mapping constants for filtering with aliases and common variations
    public static final Map<String, String> FILTER_FIELD_MAP = new Map<String, String>{
        // OU and Location
        'ou_name' => 'ou_name__c',
        'ou' => 'ou_name__c',
        'operating_unit' => 'ou_name__c',
        'org_unit' => 'ou_name__c',

        'work_location_country' => 'work_location_country__c',
        'work_location' => 'work_location_country__c',
        'country' => 'work_location_country__c',
        'location' => 'work_location_country__c',
        'work_country' => 'work_location_country__c',

        // Industry and Segment
        'primary_industry' => 'primary_industry__c',
        'industry' => 'primary_industry__c',
        'sector' => 'primary_industry__c',

        'macro_segment' => 'macrosgment__c',
        'macrosgment' => 'macrosgment__c',
        'segment' => 'macrosgment__c',
        'macro' => 'macrosgment__c',
        'business_segment' => 'macrosgment__c',

        // Renewals Fields
        'renewal_prod_nm' => 'renewal_prod_nm__c',
        'renewal_product' => 'renewal_prod_nm__c',
        'renewal_acct_nm' => 'renewal_acct_nm__c',
        'renewal_account' => 'renewal_acct_nm__c',
        'renewal_opty_amt' => 'renewal_opty_amt__c',
        'renewal_amount' => 'renewal_opty_amt__c',

        // Cross-Sell Fields
        'cross_sell_next_best_product' => 'cross_sell_next_best_product__c',
        'cross_sell_product' => 'cross_sell_next_best_product__c',
        'cross_sell_acct_nm' => 'cross_sell_acct_nm__c',
        'cross_sell_account' => 'cross_sell_acct_nm__c',
        'cross_sell_acct_id' => 'cross_sell_acct_id__c',
        'cross_sell_rn' => 'cross_sell_rn__c',

        // Upsell Fields
        'upsell_sub_category' => 'upsell_sub_category__c',
        'upsell_product' => 'upsell_sub_category__c',
        'upsell_acct_nm' => 'upsell_acct_nm__c',
        'upsell_account' => 'upsell_acct_nm__c',
        'upsell_acct_id' => 'upsell_acct_id__c',
        'upsell_rn' => 'upsell_rn__c',

        // Common Employee Fields
        'emp_id' => 'emp_id__c',
        'emp' => 'emp_id__c',
        'employee_id' => 'emp_id__c',
        'employee' => 'emp_id__c',
        'ae_id' => 'emp_id__c',

        'full_name' => 'full_name__c',
        'name' => 'full_name__c',
        'ae_name' => 'full_name__c',
        'sales_rep' => 'full_name__c',

        'emp_email_addr' => 'emp_email_addr__c',
        'emp_email' => 'emp_email_addr__c',
        'email' => 'emp_email_addr__c',
        'ae_email' => 'emp_email_addr__c',

        'emp_mgr_nm' => 'emp_mgr_nm__c',
        'emp_mgr' => 'emp_mgr_nm__c',
        'manager' => 'emp_mgr_nm__c',
        'mgr' => 'emp_mgr_nm__c',
        'mgr_name' => 'emp_mgr_nm__c',
        'sales_manager' => 'emp_mgr_nm__c',

        // Additional Fields
        'learner_profile_id' => 'learner_profile_id__c',
        'learner_id' => 'learner_profile_id__c',
        'profile_id' => 'learner_profile_id__c',

        'ramp_status' => 'ramp_status__c',
        'ramp' => 'ramp_status__c',
        'onboarding_status' => 'ramp_status__c',

        // Ramp status variants seen in agent inputs
        'renewal_ae_ramp_status' => 'ramp_status__c',
        'ae_ramp_status' => 'ramp_status__c',

        'time_since_onboarding' => 'time_since_onboarding__c',
        'onboarding_time' => 'time_since_onboarding__c',
        'months_onboarded' => 'time_since_onboarding__c',
        'tenure' => 'time_since_onboarding__c',

        // Common aliases
        'product' => 'product', // Will be resolved based on analysis type
        'account' => 'account', // Will be resolved based on analysis type
        'amount' => 'amount'    // Will be resolved based on analysis type
    };

    // Keyword-to-predicate expansion for natural-language filters
    // Example: "slow rampers" -> ramp_status__c = 'Slow Ramper'
    private static final Map<String, String> KEYWORD_PREDICATE_MAP = new Map<String, String>{
        'slow ramper' => 'ramp_status__c = \'Slow Ramper\'',
        'slow rampers' => 'ramp_status__c = \'Slow Ramper\'',
        'slow_ramper' => 'ramp_status__c = \'Slow Ramper\'',
        'slow_rampers' => 'ramp_status__c = \'Slow Ramper\''
    };

    /**
     * DTO for a single row of aggregated pipeline data
     */
    public class PipelineRowDTO {
        public String key;
        public Integer count;
        public Decimal amount;        // Only for Renewals
        public Decimal avgAmount;     // Only for Renewals
        public Decimal maxAmount;     // Only for Renewals
        public Decimal minAmount;     // Only for Renewals
        public Integer uniqueAccounts; // Only for Cross-sell/Upsell
        public Integer uniqueProducts; // Only for Cross-sell/Upsell
    }

    /**
     * DTO for query parameters
     */
    public class PipelineQueryRequest {
        public String analysisType;
        public String ouName;
        public String workLocationCountry;
        public String groupBy;
        public String filterCriteria;
        public String restrictInValuesCsv;
        public Boolean perAENormalize;
        public Integer limitN;
        public String aggregationType;
        public String analysisTypeDetail;
        public Date startDate;
        public Date endDate;

        public PipelineQueryRequest(String analysisType, String ouName, String workLocationCountry, String groupBy,
                                    String filterCriteria, String restrictInValuesCsv, Boolean perAENormalize,
                                    Integer limitN, String aggregationType, String analysisTypeDetail,
                                    Date startDate, Date endDate) {
            this.analysisType = analysisType;
            this.ouName = ouName;
            this.workLocationCountry = workLocationCountry;
            this.groupBy = groupBy;
            this.filterCriteria = filterCriteria;
            this.restrictInValuesCsv = restrictInValuesCsv;
            this.perAENormalize = perAENormalize;
            this.limitN = limitN;
            this.aggregationType = aggregationType;
            this.analysisTypeDetail = analysisTypeDetail;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }

    /**
     * Main method to analyze pipeline data based on specified parameters
     * Returns a single composed message string for the agent
     */
    public static String analyzePipeline(String analysisType, String ouName, String workLocationCountry, String groupBy,
                                        String filterCriteria, String restrictInValuesCsv, Boolean perAENormalize,
                                        Integer limitN, String aggregationType, String analysisTypeDetail,
                                        Date startDate, Date endDate) {

        PipelineQueryRequest req = new PipelineQueryRequest(analysisType, ouName, workLocationCountry, groupBy,
                                                            filterCriteria, restrictInValuesCsv, perAENormalize,
                                                            limitN, aggregationType, analysisTypeDetail,
                                                            startDate, endDate);

        // Auto-apply keyword when filterCriteria is blank but analysisTypeDetail indicates slow rampers
        if (String.isBlank(req.filterCriteria)
            && req.analysisType == 'RENEWALS'
            && String.isNotBlank(req.analysisTypeDetail)
            && req.analysisTypeDetail.toLowerCase().contains('slow ramp')) {
            req.filterCriteria = 'slow rampers';
        }

        // Enhanced data validation before analysis
        DataAvailabilityResult dataValidation = validateDataAvailability(ouName, workLocationCountry, analysisType);
        if (!dataValidation.hasData) {
            // Build enhanced error message with smart suggestions
            Map<String, Object> errorContext = new Map<String, Object>{
                'ouName' => ouName,
                'country' => workLocationCountry,
                'analysisType' => analysisType,
                'groupBy' => groupBy,
                'suggestions' => dataValidation.suggestions,
                'recommendedAlternative' => dataValidation.recommendedAlternative
            };
            return buildEnhancedErrorMessage('NO_DATA', errorContext);
        }
        
        // Enforce governor limits and validate inputs
        String validationError = enforceGovernorSafety(req);
        if (validationError != null) {
            Map<String, Object> errorContext = new Map<String, Object>{
                'errorMessage' => validationError,
                'analysisType' => analysisType,
                'ouName' => ouName
            };
            return buildEnhancedErrorMessage('INVALID_PARAMETERS', errorContext);
        }

        List<PipelineRowDTO> results = queryTopPipeline(req);

        // Process results and build analysis
        return buildAnalysisMessage(results, req);
    }

    /**
     * Executes an aggregate query to get top pipeline data
     */
    public static List<PipelineRowDTO> queryTopPipeline(PipelineQueryRequest req) {
        String groupField = GROUP_FIELD_MAP.get(req.analysisType).get(req.groupBy);
        String objectName = OBJECT_MAP.get(req.analysisType);
        String amountField = AMOUNT_FIELD_MAP.get(req.analysisType);
        String accountField = ACCOUNT_FIELD_MAP.get(req.analysisType);
        String productField = PRODUCT_FIELD_MAP.get(req.analysisType);

        // Build aggregate query
        String query = 'SELECT ' + groupField + ', COUNT(Id) recordCount';

        // Add amount aggregation for Renewals
        if (String.isNotBlank(amountField)) {
            query += ', SUM(' + amountField + ') totalAmount';
            query += ', AVG(' + amountField + ') avgAmount';
            query += ', MAX(' + amountField + ') maxAmount';
            query += ', MIN(' + amountField + ') minAmount';
        }

        // Add unique counts for Cross-sell and Upsell
        if (req.analysisType != 'RENEWALS') {
            if (req.groupBy != 'ACCOUNT') {
                query += ', COUNT_DISTINCT(' + accountField + ') uniqueAccounts';
            }
            if (req.groupBy != 'PRODUCT') {
                query += ', COUNT_DISTINCT(' + productField + ') uniqueProducts';
            }
        }

        query += ' FROM ' + objectName;

        // Build WHERE clause with proper filtering
        List<String> whereClauses = new List<String>();

        // Always include IsDeleted = false
        whereClauses.add('IsDeleted = false');

        // Add OU filter if provided
        if (String.isNotBlank(req.ouName)) {
            whereClauses.add('ou_name__c = \'' + String.escapeSingleQuotes(req.ouName) + '\'');
        }

        // Add country filter if provided
        if (String.isNotBlank(req.workLocationCountry)) {
            whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(req.workLocationCountry) + '\'');
        }

        // Add custom filter criteria if provided
        if (String.isNotBlank(req.filterCriteria)) {
            String parsedFilter = parseFilterCriteria(req.filterCriteria, req.analysisType);
            if (String.isNotBlank(parsedFilter)) {
                whereClauses.add(parsedFilter);
            }
        }

        // For Renewals with SUM aggregation, filter out null amounts to get meaningful results
        if (req.analysisType == 'RENEWALS' && req.aggregationType == 'SUM' && String.isNotBlank(amountField)) {
            whereClauses.add(amountField + ' != null');
        }

        // Add date filtering for Renewals (if dates provided)
        if (req.analysisType == 'RENEWALS' && req.startDate != null && req.endDate != null) {
            whereClauses.add('CloseDate >= ' + req.startDate.format() + ' AND CloseDate <= ' + req.endDate.format());
        }

        // Ensure the grouping field is not null
        if (String.isNotBlank(groupField)) {
            whereClauses.add(groupField + ' != null');
        }

        if (!whereClauses.isEmpty()) {
            query += ' WHERE ' + String.join(whereClauses, ' AND ');
        }

        // Add GROUP BY and ORDER BY
        query += ' GROUP BY ' + groupField;

        // Order by aggregation type
        if (req.aggregationType == 'SUM' && String.isNotBlank(amountField)) {
            query += ' ORDER BY SUM(' + amountField + ') DESC';
        } else if (req.aggregationType == 'AVG' && String.isNotBlank(amountField)) {
            query += ' ORDER BY AVG(' + amountField + ') DESC';
        } else if (req.aggregationType == 'MAX' && String.isNotBlank(amountField)) {
            query += ' ORDER BY MAX(' + amountField + ') DESC';
        } else if (req.aggregationType == 'MIN' && String.isNotBlank(amountField)) {
            query += ' ORDER BY MIN(' + amountField + ') DESC';
        } else {
            query += ' ORDER BY COUNT(Id) DESC';
        }

        query += ' LIMIT ' + req.limitN;

        AgentLog.info('queryTopPipeline', 'Executing aggregate query', new Map<String, Object>{
            'query' => query,
            'analysisType' => req.analysisType,
            'groupBy' => req.groupBy,
            'limitN' => req.limitN
        });

        // Execute query and convert to DTOs
        List<AggregateResult> results = Database.query(query);
        List<PipelineRowDTO> dtos = new List<PipelineRowDTO>();

        for (AggregateResult result : results) {
            PipelineRowDTO dto = new PipelineRowDTO();
            dto.key = (String)result.get(groupField);
            dto.count = (Integer)result.get('recordCount');

            // Set amount fields for Renewals
            if (String.isNotBlank(amountField)) {
                dto.amount = (Decimal)result.get('totalAmount');
                dto.avgAmount = (Decimal)result.get('avgAmount');
                dto.maxAmount = (Decimal)result.get('maxAmount');
                dto.minAmount = (Decimal)result.get('minAmount');
            }

            // Set unique counts for Cross-sell and Upsell
            if (req.analysisType != 'RENEWALS') {
                if (req.groupBy != 'ACCOUNT') {
                    dto.uniqueAccounts = (Integer)result.get('uniqueAccounts');
                } else {
                    dto.uniqueAccounts = 1; // When grouping by account, each group has 1 unique account
                }

                if (req.groupBy != 'PRODUCT') {
                    dto.uniqueProducts = (Integer)result.get('uniqueProducts');
                } else {
                    dto.uniqueProducts = 1; // When grouping by product, each group has 1 unique product
                }
            }

            dtos.add(dto);
        }

        AgentLog.info('queryTopPipeline', 'Query completed', new Map<String, Object>{
            'resultCount' => dtos.size(),
            'analysisType' => req.analysisType,
            'groupBy' => req.groupBy
        });
        return dtos;
    }

    /**
     * Enforces governor limits and validates inputs
     */
    private static String enforceGovernorSafety(PipelineQueryRequest req) {
        // Validate analysis type
        if (!OBJECT_MAP.containsKey(req.analysisType)) {
            AgentLog.error('enforceGovernorSafety', 'Invalid analysis type', new Map<String, Object>{
                'analysisType' => req.analysisType,
                'validOptions' => OBJECT_MAP.keySet()
            });
            return 'Invalid analysis type: ' + req.analysisType + '. Valid values are: ' + String.join(new List<String>(OBJECT_MAP.keySet()), ', ') + '.';
        }

        // Validate groupBy
        Map<String, String> groupFields = GROUP_FIELD_MAP.get(req.analysisType);
        if (!groupFields.containsKey(req.groupBy)) {
            AgentLog.error('enforceGovernorSafety', 'Invalid groupBy field', new Map<String, Object>{
                'groupBy' => req.groupBy,
                'analysisType' => req.analysisType,
                'validOptions' => groupFields.keySet()
            });
            return 'Invalid group by: ' + req.groupBy + '. Valid values for ' + req.analysisType + ' are: ' + String.join(new List<String>(groupFields.keySet()), ', ') + '.';
        }

        // Validate limitN
        if (req.limitN == null || req.limitN <= 0) {
            req.limitN = 20; // Default limit
        } else if (req.limitN > 200) {
            AgentLog.error('enforceGovernorSafety', 'limitN too large', new Map<String, Object>{
                'limitN' => req.limitN,
                'maxAllowed' => 200
            });
            return 'The requested limit (' + req.limitN + ') is too large. Please request a limit up to 200.';
        }

        // Validate that at least one filter is provided
        if (String.isBlank(req.ouName) && String.isBlank(req.workLocationCountry)) {
            AgentLog.error('enforceGovernorSafety', 'No filters provided', new Map<String, Object>{
                'ouName' => req.ouName,
                'workLocationCountry' => req.workLocationCountry,
                'analysisType' => req.analysisType
            });
            return 'Either OU Name or Work Location Country is required for ' + req.analysisType + ' Analysis queries. Please provide at least one of these filters.';
        }

        return null; // No error
    }

    /**
     * Builds the complete analysis message with enhanced features
     */
    private static String buildAnalysisMessage(List<PipelineRowDTO> results, PipelineQueryRequest req) {
        String message = '';

        // 🎯 Executive Summary with Emojis
        message += '# ' + getAnalysisEmoji(req.analysisType) + ' ' + req.analysisType + ' Analysis\n\n';
        
        // Executive Summary
        message += buildExecutiveSummary(results, req);

        // 📊 Summary with Rich Formatting
        message += '## 📊 Analysis Summary\n';
        if (String.isNotBlank(req.ouName)) {
            message += '- **🏢 OU**: ' + req.ouName + '\n';
        }
        if (String.isNotBlank(req.workLocationCountry)) {
            message += '- **🌍 Work Location Country**: ' + req.workLocationCountry + '\n';
        }
        message += '- **📈 Grouped By**: ' + req.groupBy + '\n';
        message += '- **🔍 Analysis Type**: ' + req.analysisTypeDetail + '\n';
        message += '- **🔧 Filter**: ' + (String.isNotBlank(req.filterCriteria) ? req.filterCriteria : 'None') + '\n';
        message += '- **👥 Per-AE Normalized**: ' + (req.perAENormalize ? 'Yes' : 'No') + '\n';

        // Time range info
        if (req.analysisType == 'RENEWALS' && req.startDate != null && req.endDate != null) {
            message += '- **📅 Time Range**: ' + req.startDate.format() + ' to ' + req.endDate.format() + '\n';
        } else {
            message += '- **📅 Time Range**: All available data (no date filtering applied)\n';
        }

        if (req.limitN != null && req.limitN > 0) {
            message += '- **🔢 Limit Applied**: ' + req.limitN + '\n';
        }
        message += '\n';

        // 📈 Results with Rich Formatting
        message += '## 📈 Results\n';
        message += '- **📋 Records Found**: ' + results.size() + ' groups\n\n';

        if (results.isEmpty()) {
            message += '❌ No ' + req.analysisType.toLowerCase() + ' data found matching the specified criteria.\n';
            message += '\n**🔧 Troubleshooting Tips:**\n';
            message += '- ✅ Verify the OU name exists in the system\n';
            message += '- ✅ Check if the country filter is correct\n';
            message += '- ✅ Consider using a broader search criteria\n';
        } else {
            message += '**📊 ' + req.groupBy + ' Analysis**:\n';
            for (PipelineRowDTO dto : results) {
                if (String.isNotBlank(dto.key)) {
                    message += '- **' + getKeyEmoji(req.groupBy) + ' ' + dto.key + '**: ' + dto.count + ' ' + req.analysisType.toLowerCase() + ' opportunities';

                    // Add amount information for Renewals
                    if (req.analysisType == 'RENEWALS' && dto.amount != null) {
                        message += ', 💰 $' + dto.amount.setScale(2) + ' total amount';
                        if (dto.avgAmount != null) {
                            message += ' (avg: $' + dto.avgAmount.setScale(2) + ')';
                        }
                    }

                    // Add unique counts for Cross-sell and Upsell
                    if (req.analysisType != 'RENEWALS') {
                        if (dto.uniqueAccounts != null) {
                            message += ', 🏢 ' + dto.uniqueAccounts + ' unique accounts';
                        }
                        if (dto.uniqueProducts != null) {
                            message += ', 📦 ' + dto.uniqueProducts + ' unique products';
                        }
                    }

                    message += '\n';
                }
            }
        }

        // 🎯 Product-Market Fit Analysis
        message += '\n' + buildPMFAnalysis(results, req);

        // 💡 Actionable Insights
        message += '\n' + buildActionableInsights(results, req);

        return message;
    }

    /**
     * Builds error message
     */
    private static String buildErrorMessage(String errorMessage) {
        return '# Future Pipeline Analysis\n\n## Error\n' + errorMessage;
    }

    /**
     * Parses filter criteria from user-friendly format to SOQL
     */
    public static String parseFilterCriteria(String filterCriteria, String analysisType) {
        if (String.isBlank(filterCriteria)) return '';

        String parsedFilter = filterCriteria;

        // Expand known natural-language keywords to concrete predicates
        for (String keyword : KEYWORD_PREDICATE_MAP.keySet()) {
            parsedFilter = replaceWordCI(parsedFilter, keyword, KEYWORD_PREDICATE_MAP.get(keyword));
        }

        // Handle cases where agent sends API field names instead of user-friendly keys
        Map<String, String> apiFieldToUserKey = new Map<String, String>{
            'ou_name__C' => 'ou_name',
            'ou_name__c' => 'ou_name',
            'work_location_country__C' => 'work_location_country',
            'work_location_country__c' => 'work_location_country',
            'primary_industry__C' => 'primary_industry',
            'primary_industry__c' => 'primary_industry',
            'macrosgment__C' => 'macro_segment',
            'macrosgment__c' => 'macro_segment',
            'emp_id__C' => 'emp_id',
            'emp_id__c' => 'emp_id',
            'full_name__C' => 'full_name',
            'full_name__c' => 'full_name',
            'emp_email_addr__C' => 'emp_email_addr',
            'emp_email_addr__c' => 'emp_email_addr',
            'emp_mgr_nm__C' => 'emp_mgr_nm',
            'emp_mgr_nm__c' => 'emp_mgr_nm',
            'learner_profile_id__C' => 'learner_profile_id',
            'learner_profile_id__c' => 'learner_profile_id',
            'ramp_status__C' => 'ramp_status',
            'ramp_status__c' => 'ramp_status',
            'time_since_onboarding__C' => 'time_since_onboarding',
            'time_since_onboarding__c' => 'time_since_onboarding'
        };

        // Add analysis-type specific field mappings
        if (analysisType == 'RENEWALS') {
            apiFieldToUserKey.putAll(new Map<String, String>{
                'renewal_prod_nm__C' => 'renewal_prod_nm',
                'renewal_prod_nm__c' => 'renewal_prod_nm',
                'renewal_acct_nm__C' => 'renewal_acct_nm',
                'renewal_acct_nm__c' => 'renewal_acct_nm',
                'renewal_opty_amt__C' => 'renewal_opty_amt',
                'renewal_opty_amt__c' => 'renewal_opty_amt'
            });
        } else if (analysisType == 'CROSS_SELL') {
            apiFieldToUserKey.putAll(new Map<String, String>{
                'cross_sell_next_best_product__C' => 'cross_sell_next_best_product',
                'cross_sell_next_best_product__c' => 'cross_sell_next_best_product',
                'cross_sell_acct_nm__C' => 'cross_sell_acct_nm',
                'cross_sell_acct_nm__c' => 'cross_sell_acct_nm',
                'cross_sell_acct_id__C' => 'cross_sell_acct_id',
                'cross_sell_acct_id__c' => 'cross_sell_acct_id',
                'cross_sell_rn__C' => 'cross_sell_rn',
                'cross_sell_rn__c' => 'cross_sell_rn'
            });
        } else if (analysisType == 'UPSELL') {
            apiFieldToUserKey.putAll(new Map<String, String>{
                'upsell_sub_category__C' => 'upsell_sub_category',
                'upsell_sub_category__c' => 'upsell_sub_category',
                'upsell_acct_nm__C' => 'upsell_acct_nm',
                'upsell_acct_nm__c' => 'upsell_acct_nm',
                'upsell_acct_id__C' => 'upsell_acct_id',
                'upsell_acct_id__c' => 'upsell_acct_id',
                'upsell_rn__C' => 'upsell_rn',
                'upsell_rn__c' => 'upsell_rn'
            });
        }

        // First, convert API field names to user-friendly keys
        for (String apiField : apiFieldToUserKey.keySet()) {
            String userKey = apiFieldToUserKey.get(apiField);
            parsedFilter = replaceWordCI(parsedFilter, apiField, userKey);
        }

        // Convert base field names to API field names (longest first to prevent partial matches)
        List<String> fieldKeys = sortedKeysByLengthDesc(FILTER_FIELD_MAP);
        for (String key : fieldKeys) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            parsedFilter = replaceWordCI(parsedFilter, key, fieldName);
        }

        return parsedFilter;
    }

    /**
     * @description Case-insensitive, word-boundary replacement for field mapping
     */
    private static String replaceWordCI(String src, String token, String repl) {
        if (String.isBlank(src) || String.isBlank(token)) return src;

        // Build regex pattern: (?i)(?<![A-Za-z0-9_])TOKEN(?![A-Za-z0-9_])
        String escapedToken = token.replaceAll('([\\\\\\.\\[\\]\\{\\}\\(\\)\\*\\+\\?\\|\\^\\$])', '\\\\$1');
        String pattern = '(?i)(?<![A-Za-z0-9_])' + escapedToken + '(?![A-Za-z0-9_])';
        return src.replaceAll(pattern, repl);
    }

    /**
     * @description Returns map keys sorted by length in descending order to prevent partial matches
     */
    private static List<String> sortedKeysByLengthDesc(Map<String, Object> inputMap) {
        List<String> keys = new List<String>(inputMap.keySet());
        keys.sort(new KeyLengthComparator());
        return keys;
    }

    /**
     * @description Provides field suggestions and validation for better agent accuracy
     */
    public static String getFieldSuggestions(String query, String analysisType) {
        if (String.isBlank(query)) {
            return 'Please provide a query to get field suggestions.';
        }

        String suggestions = '## Field Mapping Suggestions for ' + analysisType + '\n\n';
        suggestions += '**Query**: ' + query + '\n\n';

        // Check for common field patterns in the query
        String lowerQuery = query.toLowerCase();

        // Product-related suggestions
        if (lowerQuery.contains('product')) {
            suggestions += '**Product Fields**:\n';
            if (analysisType == 'RENEWALS') {
                suggestions += '- Use: `product` or `renewal_prod_nm`\n';
            } else if (analysisType == 'CROSS_SELL') {
                suggestions += '- Use: `product` or `cross_sell_next_best_product`\n';
            } else if (analysisType == 'UPSELL') {
                suggestions += '- Use: `product` or `upsell_sub_category`\n';
            }
            suggestions += '- Common aliases: product, product_name\n\n';
        }

        // Account-related suggestions
        if (lowerQuery.contains('account') || lowerQuery.contains('customer')) {
            suggestions += '**Account Fields**:\n';
            if (analysisType == 'RENEWALS') {
                suggestions += '- Use: `account` or `renewal_acct_nm`\n';
            } else if (analysisType == 'CROSS_SELL') {
                suggestions += '- Use: `account` or `cross_sell_acct_nm`\n';
            } else if (analysisType == 'UPSELL') {
                suggestions += '- Use: `account` or `upsell_acct_nm`\n';
            }
            suggestions += '- Common aliases: account, account_name, customer\n\n';
        }

        // Location-related suggestions
        if (lowerQuery.contains('country') || lowerQuery.contains('location')) {
            suggestions += '**Location Fields**:\n';
            suggestions += '- Use: `country` or `work_location_country`\n';
            suggestions += '- Example values: "Mexico", "Canada", "France"\n';
            suggestions += '- Common aliases: country, location, work_country\n\n';
        }

        // Industry-related suggestions
        if (lowerQuery.contains('industry') || lowerQuery.contains('sector')) {
            suggestions += '**Industry Fields**:\n';
            suggestions += '- Use: `industry` or `primary_industry`\n';
            suggestions += '- Example values: "Retail & CG", "Healthcare & Life Sciences"\n';
            suggestions += '- Common aliases: industry, sector, business_industry\n\n';
        }

        suggestions += '**Available Field Aliases**:\n';
        for (String field : FILTER_FIELD_MAP.keySet()) {
            suggestions += '- ' + field + ' → ' + FILTER_FIELD_MAP.get(field) + '\n';
        }

        return suggestions;
    }

    /**
     * @description Validates filter criteria and provides suggestions for common errors
     */
    public static String validateFilterCriteria(String filterCriteria, String analysisType) {
        if (String.isBlank(filterCriteria)) {
            return 'Filter criteria is empty. Please provide a filter.';
        }

        String validation = '## Filter Validation Results for ' + analysisType + '\n\n';
        validation += '**Input**: ' + filterCriteria + '\n\n';

        // Check for proper quoting
        if (filterCriteria.contains('=') && !filterCriteria.contains('\'')) {
            validation += '⚠️ **WARNING**: Values should be quoted\n';
            validation += '   - Wrong: `product=Tableau Cloud Analytics`\n';
            validation += '   - Correct: `product=\'Tableau Cloud Analytics\'`\n\n';
        }

        validation += '**Field Mapping**:\n';
        for (String key : FILTER_FIELD_MAP.keySet()) {
            String fieldName = FILTER_FIELD_MAP.get(key);
            validation += '- ' + key + ' → ' + fieldName + '\n';
        }

        return validation;
    }

    /**
     * @description Comparator for sorting keys by length in descending order
     */
    private class KeyLengthComparator implements Comparator<String> {
        public Integer compare(String a, String b) {
            if (a.length() > b.length()) return -1;
            if (a.length() < b.length()) return 1;
            return 0;
        }
    }

    // ===== ENHANCED FEATURES =====

    /**
     * @description Gets appropriate emoji for analysis type
     */
    private static String getAnalysisEmoji(String analysisType) {
        switch on analysisType {
            when 'RENEWALS' {
                return '🔄';
            }
            when 'CROSS_SELL' {
                return '🎯';
            }
            when 'UPSELL' {
                return '📈';
            }
            when else {
                return '📊';
            }
        }
    }

    /**
     * @description Gets appropriate emoji for grouping type
     */
    private static String getKeyEmoji(String groupBy) {
        switch on groupBy {
            when 'PRODUCT' {
                return '📦';
            }
            when 'AE' {
                return '👤';
            }
            when 'ACCOUNT' {
                return '🏢';
            }
            when 'INDUSTRY' {
                return '🏭';
            }
            when 'COUNTRY' {
                return '🌍';
            }
            when 'MANAGER' {
                return '👔';
            }
            when 'MACRO_SEGMENT' {
                return '🎯';
            }
            when else {
                return '📋';
            }
        }
    }

    /**
     * @description Builds executive summary with key insights
     */
    private static String buildExecutiveSummary(List<PipelineRowDTO> results, PipelineQueryRequest req) {
        String summary = '## 🎯 Executive Summary\n';
        
        if (results.isEmpty()) {
            summary += '❌ **No Data Found**: No ' + req.analysisType.toLowerCase() + ' opportunities match the specified criteria.\n';
            summary += '💡 **Recommendation**: Consider broadening search parameters or verifying data availability.\n\n';
            return summary;
        }

        // Calculate key metrics
        Integer totalRecords = 0;
        Decimal totalAmount = 0;
        Decimal maxAmount = 0;
        String topPerformer = '';
        
        for (PipelineRowDTO dto : results) {
            totalRecords += dto.count;
            if (dto.amount != null) {
                totalAmount += dto.amount;
                if (dto.amount > maxAmount) {
                    maxAmount = dto.amount;
                    topPerformer = dto.key;
                }
            }
        }

        // Build summary based on analysis type
        summary += '✅ **Data Found**: ' + totalRecords + ' ' + req.analysisType.toLowerCase() + ' opportunities across ' + results.size() + ' ' + req.groupBy.toLowerCase() + ' groups.\n';
        
        if (req.analysisType == 'RENEWALS' && totalAmount > 0) {
            summary += '💰 **Total Value**: $' + totalAmount.setScale(2) + ' in renewal opportunities.\n';
            if (String.isNotBlank(topPerformer)) {
                summary += '🏆 **Top Performer**: ' + topPerformer + ' with $' + maxAmount.setScale(2) + ' in renewals.\n';
            }
        } else if (req.analysisType != 'RENEWALS') {
            summary += '🎯 **Opportunity Count**: ' + totalRecords + ' ' + req.analysisType.toLowerCase().replace('_', '-') + ' opportunities.\n';
        }

        // Add context-specific insights
        if (req.analysisType == 'RENEWALS') {
            summary += '🔄 **Focus Area**: Contract renewals and retention opportunities.\n';
        } else if (req.analysisType == 'CROSS_SELL') {
            summary += '🎯 **Focus Area**: New product expansion within existing customers.\n';
        } else if (req.analysisType == 'UPSELL') {
            summary += '📈 **Focus Area**: Upselling existing products to increase value.\n';
        }

        summary += '\n';
        return summary;
    }

    /**
     * @description Builds Product-Market Fit analysis
     */
    private static String buildPMFAnalysis(List<PipelineRowDTO> results, PipelineQueryRequest req) {
        String pmf = '## 🎯 Product-Market Fit Analysis\n';
        
        if (results.isEmpty()) {
            pmf += '❌ **No PMF Data Available**: Insufficient data for product-market fit analysis.\n\n';
            return pmf;
        }

        // Calculate PMF metrics
        Decimal totalOpportunities = 0;
        Decimal totalValue = 0;
        Integer topPerformerCount = 0;
        String topPerformer = '';
        Decimal topPerformerValue = 0;

        for (PipelineRowDTO dto : results) {
            totalOpportunities += dto.count;
            if (dto.amount != null) {
                totalValue += dto.amount;
                if (dto.amount > topPerformerValue) {
                    topPerformerValue = dto.amount;
                    topPerformer = dto.key;
                    topPerformerCount = dto.count;
                }
            }
        }

        // Calculate efficiency metrics
        Decimal avgOpportunitiesPerGroup = totalOpportunities / results.size();
        Decimal concentrationRatio = 0;
        if (totalOpportunities > 0 && topPerformerCount > 0) {
            concentrationRatio = (topPerformerCount / totalOpportunities) * 100;
        }

        // PMF Assessment
        pmf += '📊 **Market Distribution**: ' + results.size() + ' ' + req.groupBy.toLowerCase() + ' groups with ' + totalOpportunities + ' total opportunities.\n';
        pmf += '📈 **Average per Group**: ' + avgOpportunitiesPerGroup.setScale(1) + ' opportunities per ' + req.groupBy.toLowerCase() + '.\n';
        
        if (concentrationRatio > 0) {
            pmf += '🎯 **Market Concentration**: ' + concentrationRatio.setScale(1) + '% of opportunities in top performer.\n';
        }

        // PMF Efficiency Rating
        String efficiencyRating = '';
        String efficiencyEmoji = '';
        if (avgOpportunitiesPerGroup >= 10) {
            efficiencyRating = 'High';
            efficiencyEmoji = '🟢';
        } else if (avgOpportunitiesPerGroup >= 5) {
            efficiencyRating = 'Medium';
            efficiencyEmoji = '🟡';
        } else {
            efficiencyRating = 'Low';
            efficiencyEmoji = '🔴';
        }

        pmf += efficiencyEmoji + ' **PMF Efficiency**: ' + efficiencyRating + ' (' + avgOpportunitiesPerGroup.setScale(1) + ' opportunities per group)\n';
        
        if (String.isNotBlank(topPerformer)) {
            pmf += '🏆 **Market Leader**: ' + topPerformer + ' (' + topPerformerCount + ' opportunities';
            if (topPerformerValue > 0) {
                pmf += ', $' + topPerformerValue.setScale(2) + ' value';
            }
            pmf += ')\n';
        }

        pmf += '\n';
        return pmf;
    }

    /**
     * @description Builds actionable insights and recommendations
     */
    private static String buildActionableInsights(List<PipelineRowDTO> results, PipelineQueryRequest req) {
        String insights = '## 💡 Actionable Insights & Recommendations\n';
        
        if (results.isEmpty()) {
            insights += '🔍 **Data Collection Priority**:\n';
            insights += '- ✅ Verify data sources and refresh pipeline data\n';
            insights += '- ✅ Check filter criteria and expand search parameters\n';
            insights += '- ✅ Review data availability for ' + req.analysisType.toLowerCase() + ' opportunities\n\n';
            return insights;
        }

        // Calculate insights based on results
        Integer totalRecords = 0;
        Decimal totalValue = 0;
        Decimal maxValue = 0;
        String topPerformer = '';
        Integer topPerformerCount = 0;

        for (PipelineRowDTO dto : results) {
            totalRecords += dto.count;
            if (dto.amount != null) {
                totalValue += dto.amount;
                if (dto.amount > maxValue) {
                    maxValue = dto.amount;
                    topPerformer = dto.key;
                    topPerformerCount = dto.count;
                }
            }
        }

        // Strategic Insights
        insights += '🎯 **Strategic Focus Areas**:\n';
        
        if (req.analysisType == 'RENEWALS') {
            insights += '- 🔄 **Renewal Management**: Focus on high-value renewals to maximize retention\n';
            if (totalValue > 0) {
                insights += '- 💰 **Revenue Protection**: $' + totalValue.setScale(2) + ' in renewal value at risk\n';
            }
            insights += '- 📅 **Timing Optimization**: Monitor renewal dates and engagement cycles\n';
        } else if (req.analysisType == 'CROSS_SELL') {
            insights += '- 🎯 **Product Expansion**: Leverage existing customer relationships for new product sales\n';
            insights += '- 🤝 **Relationship Building**: Strengthen customer partnerships for cross-sell success\n';
            insights += '- 📊 **Product Mix**: Diversify product offerings based on customer needs\n';
        } else if (req.analysisType == 'UPSELL') {
            insights += '- 📈 **Value Expansion**: Increase deal sizes within existing customer base\n';
            insights += '- 🎯 **Feature Adoption**: Promote advanced features and capabilities\n';
            insights += '- 💎 **Premium Positioning**: Position higher-value solutions for growth\n';
        }

        // Performance Insights
        insights += '\n🏆 **Performance Optimization**:\n';
        if (String.isNotBlank(topPerformer)) {
            insights += '- ✅ **Best Practice**: Replicate strategies from ' + topPerformer + ' (top performer)\n';
            insights += '- 📚 **Knowledge Sharing**: Document and share successful approaches\n';
            insights += '- 🎯 **Scaling Opportunity**: Apply top performer tactics to other groups\n';
        }

        // Action Items
        insights += '\n📋 **Immediate Action Items**:\n';
        insights += '- 📊 **Data Review**: Analyze performance patterns in top-performing groups\n';
        insights += '- 🎯 **Target Setting**: Set specific goals based on current performance levels\n';
        insights += '- 📈 **Tracking**: Implement regular monitoring of ' + req.analysisType.toLowerCase() + ' metrics\n';
        
        if (req.analysisType == 'RENEWALS') {
            insights += '- 🔔 **Early Warning**: Set up alerts for at-risk renewals\n';
        } else {
            insights += '- 🤝 **Relationship Management**: Strengthen customer engagement strategies\n';
        }

        insights += '\n';
        return insights;
    }
    
    // ============================================================================
    // ENHANCED DATA VALIDATION AND ERROR HANDLING
    // ============================================================================
    
    /**
     * Validates data availability before analysis and provides smart suggestions
     */
    public static DataAvailabilityResult validateDataAvailability(String ouName, String workLocationCountry, String analysisType) {
        DataAvailabilityResult result = new DataAvailabilityResult();
        result.hasData = false;
        result.suggestions = new List<String>();
        result.dataCoverage = new Map<String, Integer>();
        result.recommendedAlternative = null;
        
        try {
            // Check data availability for the specified parameters
            String objectName = OBJECT_MAP.get(analysisType);
            if (String.isBlank(objectName)) {
                result.errorMessage = 'Invalid analysis type: ' + analysisType;
                return result;
            }
            
            // Build base query to check data availability
            String countQuery = 'SELECT COUNT(Id) recordCount FROM ' + objectName + ' WHERE IsDeleted = false';
            List<String> whereClauses = new List<String>();
            
            if (String.isNotBlank(ouName)) {
                whereClauses.add('ou_name__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
            }
            
            if (String.isNotBlank(workLocationCountry)) {
                whereClauses.add('work_location_country__c = \'' + String.escapeSingleQuotes(workLocationCountry) + '\'');
            }
            
            if (!whereClauses.isEmpty()) {
                countQuery += ' AND ' + String.join(whereClauses, ' AND ');
            }
            
            List<AggregateResult> countResults = Database.query(countQuery);
            Integer recordCount = (Integer) countResults[0].get('recordCount');
            
            if (recordCount > 0) {
                result.hasData = true;
                result.recordCount = recordCount;
                
                // Get data coverage by OU and Country
                result.dataCoverage = getDataCoverage(analysisType);
                
                // Provide suggestions for better analysis
                result.suggestions.add('✅ Data available: ' + recordCount + ' records found');
                result.suggestions.add('💡 Consider grouping by INDUSTRY or PRODUCT for deeper insights');
                result.suggestions.add('📊 Try limiting results to top 10 for focused analysis');
            } else {
                // No data found - provide smart suggestions
                result.errorMessage = 'No data found for ' + analysisType + ' in ' + ouName;
                if (String.isNotBlank(workLocationCountry)) {
                    result.errorMessage += ' (' + workLocationCountry + ')';
                }
                
                // Get data coverage to suggest alternatives
                result.dataCoverage = getDataCoverage(analysisType);
                result.suggestions = generateSmartSuggestions(ouName, workLocationCountry, analysisType, result.dataCoverage);
                result.recommendedAlternative = getRecommendedAlternative(ouName, workLocationCountry, analysisType, result.dataCoverage);
            }
            
        } catch (Exception e) {
            result.errorMessage = 'Error validating data availability: ' + e.getMessage();
            result.suggestions.add('🔧 Please check your parameters and try again');
        }
        
        return result;
    }
    
    /**
     * Gets data coverage across different OUs and countries
     */
    private static Map<String, Integer> getDataCoverage(String analysisType) {
        Map<String, Integer> coverage = new Map<String, Integer>();
        String objectName = OBJECT_MAP.get(analysisType);
        
        try {
            String coverageQuery = 'SELECT ou_name__c, work_location_country__c, COUNT(Id) recordCount ' +
                                 'FROM ' + objectName + ' WHERE IsDeleted = false ' +
                                 'GROUP BY ou_name__c, work_location_country__c ' +
                                 'ORDER BY COUNT(Id) DESC LIMIT 20';
            
            List<AggregateResult> coverageResults = Database.query(coverageQuery);
            
            for (AggregateResult result : coverageResults) {
                String ou = (String) result.get('ou_name__c');
                String country = (String) result.get('work_location_country__c');
                Integer count = (Integer) result.get('recordCount');
                
                String key = ou + ' - ' + country;
                coverage.put(key, count);
            }
            
        } catch (Exception e) {
            System.debug('Error getting data coverage: ' + e.getMessage());
        }
        
        return coverage;
    }
    
    /**
     * Generates smart suggestions when no data is found
     */
    private static List<String> generateSmartSuggestions(String ouName, String workLocationCountry, String analysisType, Map<String, Integer> dataCoverage) {
        List<String> suggestions = new List<String>();
        
        suggestions.add('❌ No data found for the specified criteria');
        
        // Find regions with data
        List<String> regionsWithData = new List<String>();
        for (String key : dataCoverage.keySet()) {
            if (dataCoverage.get(key) > 0) {
                regionsWithData.add(key + ' (' + dataCoverage.get(key) + ' records)');
            }
        }
        
        if (!regionsWithData.isEmpty()) {
            suggestions.add('💡 Try these regions that have data:');
            for (Integer i = 0; i < Math.min(3, regionsWithData.size()); i++) {
                suggestions.add('   • ' + regionsWithData[i]);
            }
        }
        
        // Suggest alternative analysis types
        List<String> alternativeTypes = new List<String>{'RENEWALS', 'CROSS_SELL', 'UPSELL'};
        alternativeTypes.remove(alternativeTypes.indexOf(analysisType));
        
        if (!alternativeTypes.isEmpty()) {
            suggestions.add('🔄 Try alternative analysis types: ' + String.join(alternativeTypes, ', '));
        }
        
        // General suggestions
        suggestions.add('📊 Consider using broader search criteria (remove country filter)');
        suggestions.add('🔍 Check if the OU name is correct (AMER ACC, UKI, EMEA, LATAM, APAC)');
        
        return suggestions;
    }
    
    /**
     * Gets recommended alternative parameters
     */
    private static String getRecommendedAlternative(String ouName, String workLocationCountry, String analysisType, Map<String, Integer> dataCoverage) {
        // Find the region with the most data
        String bestRegion = null;
        Integer maxCount = 0;
        
        for (String key : dataCoverage.keySet()) {
            Integer count = dataCoverage.get(key);
            if (count > maxCount) {
                maxCount = count;
                bestRegion = key;
            }
        }
        
        if (bestRegion != null) {
            return 'Try ' + bestRegion + ' for ' + analysisType + ' analysis (' + maxCount + ' records available)';
        }
        
        return 'Consider using AMER ACC or UKI for ' + analysisType + ' analysis';
    }
    
    /**
     * Enhanced error handling with contextual messages
     */
    private static String buildEnhancedErrorMessage(String errorType, Map<String, Object> context) {
        switch on errorType {
            when 'NO_DATA' {
                return buildNoDataMessage(context);
            }
            when 'INVALID_PARAMETERS' {
                return buildParameterErrorMessage(context);
            }
            when 'GOVERNOR_LIMITS' {
                return buildGovernorLimitMessage(context);
            }
            when 'SECURITY_ACCESS' {
                return buildSecurityErrorMessage(context);
            }
            when else {
                return buildGenericErrorMessage(context);
            }
        }
    }
    
    private static String buildNoDataMessage(Map<String, Object> context) {
        String message = '# ❌ No Data Found\n\n';
        message += '## 🔍 Analysis Summary\n';
        message += '- **🏢 OU**: ' + context.get('ouName') + '\n';
        message += '- **🌍 Country**: ' + context.get('country') + '\n';
        message += '- **📊 Analysis Type**: ' + context.get('analysisType') + '\n';
        message += '- **📈 Group By**: ' + context.get('groupBy') + '\n\n';
        
        message += '## 💡 Smart Suggestions\n';
        List<String> suggestions = (List<String>) context.get('suggestions');
        if (suggestions != null) {
            for (String suggestion : suggestions) {
                message += '- ' + suggestion + '\n';
            }
        }
        
        message += '\n## 🔧 Troubleshooting Tips\n';
        message += '- ✅ Verify the OU name exists in the system\n';
        message += '- ✅ Check if the country filter is correct\n';
        message += '- ✅ Consider using a broader search criteria\n';
        message += '- ✅ Try alternative analysis types\n\n';
        
        return message;
    }
    
    private static String buildParameterErrorMessage(Map<String, Object> context) {
        String message = '# ❌ Invalid Parameters\n\n';
        message += '## 🔍 Parameter Issues\n';
        
        List<String> invalidParams = (List<String>) context.get('invalidParams');
        if (invalidParams != null) {
            for (String param : invalidParams) {
                message += '- ❌ ' + param + '\n';
            }
        }
        
        message += '\n## 💡 Valid Options\n';
        message += '- **Analysis Types**: RENEWALS, CROSS_SELL, UPSELL\n';
        message += '- **Group By**: PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY, MANAGER, ACCOUNT, LEARNER_PROFILE\n';
        message += '- **OUs**: AMER ACC, AMER ICE, UKI, EMEA, LATAM, APAC\n';
        
        return message;
    }
    
    private static String buildGovernorLimitMessage(Map<String, Object> context) {
        String message = '# ⚠️ Governor Limits Exceeded\n\n';
        message += '## 🔍 Limit Issues\n';
        message += '- **Query Limit**: ' + context.get('queryLimit') + '\n';
        message += '- **Rows Limit**: ' + context.get('rowsLimit') + '\n';
        message += '- **CPU Time**: ' + context.get('cpuTime') + '\n\n';
        
        message += '## 💡 Optimization Suggestions\n';
        message += '- 📊 Reduce the limit parameter (try 5-10 instead of 50)\n';
        message += '- 🎯 Use more specific filters to reduce data volume\n';
        message += '- 📅 Consider date range filtering\n';
        message += '- 🔄 Try grouping by different fields\n\n';
        
        return message;
    }
    
    private static String buildSecurityErrorMessage(Map<String, Object> context) {
        String message = '# 🔒 Security Access Denied\n\n';
        message += '## 🔍 Access Issues\n';
        message += '- **Object**: ' + context.get('objectName') + '\n';
        message += '- **Required Permission**: READ access\n\n';
        
        message += '## 💡 Resolution Steps\n';
        message += '- 🔧 Contact your system administrator\n';
        message += '- 📋 Request READ access to the object\n';
        message += '- 🔄 Try again after permissions are granted\n\n';
        
        return message;
    }
    
    private static String buildGenericErrorMessage(Map<String, Object> context) {
        String message = '# ❌ Analysis Error\n\n';
        message += '## 🔍 Error Details\n';
        message += '- **Error**: ' + context.get('errorMessage') + '\n';
        message += '- **Analysis Type**: ' + context.get('analysisType') + '\n';
        message += '- **OU**: ' + context.get('ouName') + '\n\n';
        
        message += '## 💡 Troubleshooting\n';
        message += '- 🔧 Check your parameters and try again\n';
        message += '- 📞 Contact support if the issue persists\n';
        message += '- 🔄 Try a different analysis type or OU\n\n';
        
        return message;
    }
    
    // ============================================================================
    // DATA STRUCTURES FOR ENHANCED FUNCTIONALITY
    // ============================================================================
    
    /**
     * Data availability result structure
     */
    public class DataAvailabilityResult {
        public Boolean hasData;
        public Integer recordCount;
        public List<String> suggestions;
        public Map<String, Integer> dataCoverage;
        public String recommendedAlternative;
        public String errorMessage;
        
        public DataAvailabilityResult() {
            this.hasData = false;
            this.recordCount = 0;
            this.suggestions = new List<String>();
            this.dataCoverage = new Map<String, Integer>();
            this.recommendedAlternative = null;
            this.errorMessage = null;
        }
    }
    
    // ============================================================================
    // PHASE 2: MARKET INTELLIGENCE ENHANCEMENTS
    // ============================================================================
    
    /**
     * Comparative analysis across regions for benchmarking
     */
    public static String analyzeComparativePerformance(
        String analysisType,
        String primaryOu,
        String comparisonOu,
        String groupBy,
        Integer limitN
    ) {
        try {
            // Validate inputs
            if (String.isBlank(analysisType) || String.isBlank(primaryOu) || String.isBlank(comparisonOu)) {
                return buildErrorMessage('Primary OU, Comparison OU, and Analysis Type are required for comparative analysis');
            }
            
            // Get data for primary OU
            List<PipelineRowDTO> primaryResults = queryTopPipeline(new PipelineQueryRequest(
                analysisType, primaryOu, null, groupBy, null, null, false, limitN, 'SUM', null, null, null
            ));
            
            // Get data for comparison OU
            List<PipelineRowDTO> comparisonResults = queryTopPipeline(new PipelineQueryRequest(
                analysisType, comparisonOu, null, groupBy, null, null, false, limitN, 'SUM', null, null, null
            ));
            
            // Build comparative analysis message
            return buildComparativeAnalysisMessage(primaryResults, comparisonResults, primaryOu, comparisonOu, analysisType, groupBy);
            
        } catch (Exception e) {
            return buildErrorMessage('Comparative analysis failed: ' + e.getMessage());
        }
    }
    
    /**
     * Industry benchmarking analysis
     */
    public static String analyzeIndustryBenchmarking(
        String analysisType,
        String ouName,
        String industry,
        Integer limitN
    ) {
        try {
            // Get industry-specific data
            List<PipelineRowDTO> industryResults = queryTopPipeline(new PipelineQueryRequest(
                analysisType, ouName, null, 'INDUSTRY', null, null, false, limitN, 'SUM', null, null, null
            ));
            
            // Get overall OU performance for comparison
            List<PipelineRowDTO> overallResults = queryTopPipeline(new PipelineQueryRequest(
                analysisType, ouName, null, 'PRODUCT', null, null, false, limitN, 'SUM', null, null, null
            ));
            
            // Build benchmarking analysis
            return buildIndustryBenchmarkingMessage(industryResults, overallResults, industry, ouName, analysisType);
            
        } catch (Exception e) {
            return buildErrorMessage('Industry benchmarking failed: ' + e.getMessage());
        }
    }
    
    /**
     * Performance ranking analysis
     */
    public static String analyzePerformanceRanking(
        String analysisType,
        String ouName,
        String groupBy,
        Integer limitN
    ) {
        try {
            // Get performance data
            List<PipelineRowDTO> results = queryTopPipeline(new PipelineQueryRequest(
                analysisType, ouName, null, groupBy, null, null, false, limitN, 'SUM', null, null, null
            ));
            
            // Build performance ranking message
            return buildPerformanceRankingMessage(results, ouName, analysisType, groupBy);
            
        } catch (Exception e) {
            return buildErrorMessage('Performance ranking failed: ' + e.getMessage());
        }
    }
    
    /**
     * Market penetration analysis
     */
    public static String analyzeMarketPenetration(
        String analysisType,
        String ouName,
        String groupBy,
        Integer limitN
    ) {
        try {
            // Get market data
            List<PipelineRowDTO> results = queryTopPipeline(new PipelineQueryRequest(
                analysisType, ouName, null, groupBy, null, null, false, limitN, 'SUM', null, null, null
            ));
            
            // Calculate penetration scores
            Map<String, Decimal> penetrationScores = calculatePenetrationScores(results, analysisType);
            
            // Build market penetration message
            return buildMarketPenetrationMessage(results, penetrationScores, ouName, analysisType, groupBy);
            
        } catch (Exception e) {
            return buildErrorMessage('Market penetration analysis failed: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // HELPER METHODS FOR MARKET INTELLIGENCE
    // ============================================================================
    
    private static String buildComparativeAnalysisMessage(
        List<PipelineRowDTO> primaryResults,
        List<PipelineRowDTO> comparisonResults,
        String primaryOu,
        String comparisonOu,
        String analysisType,
        String groupBy
    ) {
        String message = '# 🔍 Comparative Analysis: ' + primaryOu + ' vs ' + comparisonOu + '\n\n';
        message += '## 🎯 Executive Summary\n';
        message += '📊 **Analysis Type**: ' + analysisType + '\n';
        message += '🏢 **Primary OU**: ' + primaryOu + '\n';
        message += '🏢 **Comparison OU**: ' + comparisonOu + '\n';
        message += '📈 **Grouped By**: ' + groupBy + '\n\n';
        
        // Performance comparison
        Decimal primaryTotal = calculateTotalValue(primaryResults);
        Decimal comparisonTotal = calculateTotalValue(comparisonResults);
        
        message += '## 📊 Performance Comparison\n';
        message += '- **' + primaryOu + ' Total**: $' + primaryTotal.setScale(2) + '\n';
        message += '- **' + comparisonOu + ' Total**: $' + comparisonTotal.setScale(2) + '\n';
        
        if (primaryTotal > comparisonTotal) {
            Decimal advantage = ((primaryTotal - comparisonTotal) / comparisonTotal * 100).setScale(1);
            message += '- **🏆 Advantage**: ' + primaryOu + ' leads by ' + advantage + '%\n';
        } else {
            Decimal advantage = ((comparisonTotal - primaryTotal) / primaryTotal * 100).setScale(1);
            message += '- **🏆 Advantage**: ' + comparisonOu + ' leads by ' + advantage + '%\n';
        }
        
        message += '\n## 📈 Top Performers by Region\n';
        
        // Top performers from primary OU
        message += '### 🥇 ' + primaryOu + ' Top Performers\n';
        for (Integer i = 0; i < Math.min(5, primaryResults.size()); i++) {
            PipelineRowDTO result = primaryResults[i];
            message += '- **' + result.key + '**: $' + result.amount.setScale(2) + ' (' + result.count + ' opportunities)\n';
        }
        
        // Top performers from comparison OU
        message += '\n### 🥈 ' + comparisonOu + ' Top Performers\n';
        for (Integer i = 0; i < Math.min(5, comparisonResults.size()); i++) {
            PipelineRowDTO result = comparisonResults[i];
            message += '- **' + result.key + '**: $' + result.amount.setScale(2) + ' (' + result.count + ' opportunities)\n';
        }
        
        message += '\n## 💡 Strategic Insights\n';
        message += '- 📊 **Best Practices**: Identify successful strategies from leading regions\n';
        message += '- 🎯 **Opportunity Areas**: Focus on underperforming segments\n';
        message += '- 🔄 **Knowledge Transfer**: Share successful approaches across regions\n';
        message += '- 📈 **Growth Potential**: Leverage top performer tactics for improvement\n\n';
        
        return message;
    }
    
    private static String buildIndustryBenchmarkingMessage(
        List<PipelineRowDTO> industryResults,
        List<PipelineRowDTO> overallResults,
        String industry,
        String ouName,
        String analysisType
    ) {
        String message = '# 🏭 Industry Benchmarking Analysis\n\n';
        message += '## 🎯 Executive Summary\n';
        message += '📊 **Analysis Type**: ' + analysisType + '\n';
        message += '🏢 **OU**: ' + ouName + '\n';
        message += '🏭 **Industry Focus**: ' + industry + '\n\n';
        
        // Find industry performance
        Decimal industryPerformance = 0;
        Integer industryCount = 0;
        for (PipelineRowDTO result : industryResults) {
            if (result.key.toLowerCase().contains(industry.toLowerCase())) {
                industryPerformance = result.amount;
                industryCount = result.count;
                break;
            }
        }
        
        // Calculate overall average
        Decimal overallTotal = calculateTotalValue(overallResults);
        Integer totalCount = calculateTotalCount(overallResults);
        Decimal overallAverage = totalCount > 0 ? overallTotal / totalCount : 0;
        
        message += '## 📊 Industry Performance\n';
        message += '- **Industry Performance**: $' + industryPerformance.setScale(2) + ' (' + industryCount + ' opportunities)\n';
        message += '- **Overall Average**: $' + overallAverage.setScale(2) + ' per opportunity\n';
        
        if (industryPerformance > overallAverage * industryCount) {
            message += '- **🏆 Status**: Above average performance\n';
        } else {
            message += '- **⚠️ Status**: Below average performance\n';
        }
        
        message += '\n## 📈 Industry Rankings\n';
        for (Integer i = 0; i < Math.min(10, industryResults.size()); i++) {
            PipelineRowDTO result = industryResults[i];
            String status = i < 3 ? '🥇' : i < 6 ? '🥈' : '🥉';
            message += '- ' + status + ' **' + result.key + '**: $' + result.amount.setScale(2) + ' (' + result.count + ' opportunities)\n';
        }
        
        message += '\n## 💡 Strategic Recommendations\n';
        message += '- 📊 **Benchmarking**: Compare performance against top-performing industries\n';
        message += '- 🎯 **Focus Areas**: Identify specific growth opportunities\n';
        message += '- 📚 **Best Practices**: Learn from leading industry performers\n';
        message += '- 🔄 **Market Strategy**: Adapt successful approaches to your industry\n\n';
        
        return message;
    }
    
    private static String buildPerformanceRankingMessage(
        List<PipelineRowDTO> results,
        String ouName,
        String analysisType,
        String groupBy
    ) {
        String message = '# 🏆 Performance Ranking Analysis\n\n';
        message += '## 🎯 Executive Summary\n';
        message += '📊 **Analysis Type**: ' + analysisType + '\n';
        message += '🏢 **OU**: ' + ouName + '\n';
        message += '📈 **Grouped By**: ' + groupBy + '\n\n';
        
        message += '## 🏆 Performance Rankings\n';
        
        // Top performers
        message += '### 🥇 Top Performers\n';
        for (Integer i = 0; i < Math.min(5, results.size()); i++) {
            PipelineRowDTO result = results[i];
            String medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '🏅';
            message += '- ' + medal + ' **' + result.key + '**: $' + result.amount.setScale(2) + ' (' + result.count + ' opportunities)\n';
        }
        
        // Performance distribution
        Decimal totalValue = calculateTotalValue(results);
        message += '\n## 📊 Performance Distribution\n';
        message += '- **Total Value**: $' + totalValue.setScale(2) + '\n';
        message += '- **Top 3 Share**: ' + calculateTop3Share(results, totalValue) + '% of total value\n';
        if (!results.isEmpty()) {
            message += '- **Performance Spread**: $' + results[0].amount.setScale(2) + ' (top) to $' + results[results.size()-1].amount.setScale(2) + ' (bottom)\n';
        }
        
        message += '\n## 💡 Performance Insights\n';
        message += '- 🎯 **Concentration**: Top performers drive significant value\n';
        message += '- 📈 **Opportunity**: Focus on improving middle-tier performers\n';
        message += '- 🏆 **Best Practices**: Document and replicate top performer strategies\n';
        message += '- 🔄 **Knowledge Sharing**: Transfer successful approaches across teams\n\n';
        
        return message;
    }
    
    private static String buildMarketPenetrationMessage(
        List<PipelineRowDTO> results,
        Map<String, Decimal> penetrationScores,
        String ouName,
        String analysisType,
        String groupBy
    ) {
        String message = '# 📊 Market Penetration Analysis\n\n';
        message += '## 🎯 Executive Summary\n';
        message += '📊 **Analysis Type**: ' + analysisType + '\n';
        message += '🏢 **OU**: ' + ouName + '\n';
        message += '📈 **Grouped By**: ' + groupBy + '\n\n';
        
        message += '## 📊 Market Penetration Scores\n';
        
        // Sort by penetration score using a simpler approach
        List<String> sortedKeys = new List<String>();
        for (String key : penetrationScores.keySet()) {
            sortedKeys.add(key);
        }
        
        // Simple bubble sort by score (descending)
        for (Integer i = 0; i < sortedKeys.size() - 1; i++) {
            for (Integer j = 0; j < sortedKeys.size() - i - 1; j++) {
                if (penetrationScores.get(sortedKeys[j]) < penetrationScores.get(sortedKeys[j + 1])) {
                    String temp = sortedKeys[j];
                    sortedKeys[j] = sortedKeys[j + 1];
                    sortedKeys[j + 1] = temp;
                }
            }
        }
        
        for (Integer i = 0; i < Math.min(10, sortedKeys.size()); i++) {
            String key = sortedKeys[i];
            Decimal score = penetrationScores.get(key);
            String status = score > 80 ? '🟢 High' : score > 50 ? '🟡 Medium' : '🔴 Low';
            message += '- **' + key + '**: ' + score.setScale(1) + '% ' + status + '\n';
        }
        
        message += '\n## 💡 Market Insights\n';
        message += '- 🎯 **High Penetration**: Leverage success in well-penetrated markets\n';
        message += '- 📈 **Growth Opportunities**: Focus on medium-penetration markets\n';
        message += '- 🔍 **Market Research**: Investigate low-penetration markets for barriers\n';
        message += '- 🔄 **Strategy Adaptation**: Adjust approach based on penetration levels\n\n';
        
        return message;
    }
    
    private static Decimal calculateTotalValue(List<PipelineRowDTO> results) {
        Decimal total = 0;
        for (PipelineRowDTO result : results) {
            total += result.amount;
        }
        return total;
    }
    
    private static Integer calculateTotalCount(List<PipelineRowDTO> results) {
        Integer total = 0;
        for (PipelineRowDTO result : results) {
            total += result.count;
        }
        return total;
    }
    
    private static Decimal calculateTop3Share(List<PipelineRowDTO> results, Decimal totalValue) {
        if (totalValue == 0) return 0;
        Decimal top3Value = 0;
        for (Integer i = 0; i < Math.min(3, results.size()); i++) {
            top3Value += results[i].amount;
        }
        return (top3Value / totalValue * 100).setScale(1);
    }
    
    private static Map<String, Decimal> calculatePenetrationScores(List<PipelineRowDTO> results, String analysisType) {
        Map<String, Decimal> scores = new Map<String, Decimal>();
        Decimal totalValue = calculateTotalValue(results);
        
        for (PipelineRowDTO result : results) {
            if (totalValue > 0) {
                Decimal score = (result.amount / totalValue * 100);
                scores.put(result.key, score);
            }
        }
        
        return scores;
    }
}