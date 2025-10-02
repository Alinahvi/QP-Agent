/**
 * @description Enhanced Open Pipe Analysis Service with context-aware resolution and rich formatting
 * @author Salesforce
 * @date 2024
 * 
 * FIELD CONTEXT & BUSINESS LOGIC:
 * 
 * CORE FIELDS:
 * - FULL_NAME__C: AE name | EMP_ID__C: 5-6 digit internal ID | EMP_MGR_NM__C: Direct manager
 * - OPEN_PIPE_OPTY_NM__C: AE/BDR created opportunity name | OPEN_PIPE_OPTY_STG_NM__C: Pipeline progress (Stage 1-7)
 * - OPEN_PIPE_AE_SCORE__C: AE's internal confidence score | OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C: Snapped value
 * 
 * PRODUCT FIELDS (3-tier hierarchy):
 * - OPEN_PIPE_PROD_NM__C: SKU level | OPEN_PIPE_APM_L2__C: Product family (DEFAULT)
 * 
 * CUSTOMER CONTEXT:
 * - PRIMARY_INDUSTRY__C: Customer industry (auto-populated) | MACROSGMENT__C: Customer segment
 * - WORK_LOCATION_COUNTRY__C: Customer country | OU_NAME__C: Operating Unit
 * 
 * DATA QUALITY NOTES:
 * - Account name missing | Close date missing | Opportunity owner ≠ Account owner | AE vertical ≠ Customer vertical
 * 
 * OUTLIER DETECTION FOR STAGNATION:
 * - Identifies opportunities stuck in stages for unusually long periods using statistical methods (IQR, Z-score)
 * - Helps identify forgotten deals or data quality issues - Critical for pipeline integrity
 */
public with sharing class ANAgentOpenPipeAnalysisV3ServiceEnhanced {
    
    // Enhanced error messages with emojis and troubleshooting tips
    private static final Map<String, String> ERROR_MESSAGES = new Map<String, String>{
        'NO_DATA' => '🔍 No data found for the specified criteria. Try expanding your search parameters.',
        'INVALID_PARAMS' => '⚠️ Invalid parameters provided. Please check your input and try again.',
        'GOVERNOR_LIMIT' => '🚨 Governor limit exceeded. Please refine your search criteria.',
        'SYSTEM_ERROR' => '❌ System error occurred. Please try again or contact support.'
    };
    
    // Field Priority Mappings for Different Analysis Types
    private static final Map<String, List<String>> TERRITORY_ANALYSIS_FIELDS = new Map<String, List<String>>{
        'primary' => new List<String>{'OPEN_PIPE_APM_L2__C', 'PRIMARY_INDUSTRY__C', 'MACROSGMENT__C', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C'},
        'secondary' => new List<String>{'OPEN_PIPE_PROD_NM__C', 'OPEN_PIPE_REVISED_SUB_SECTOR__C', 'WORK_LOCATION_COUNTRY__C'},
        'fallback' => new List<String>{'OPEN_PIPE_OPTY_STG_NM__C', 'FULL_NAME__C', 'OPEN_PIPE_AE_SCORE__C'}
    };
    
    private static final Map<String, List<String>> AE_ANALYSIS_FIELDS = new Map<String, List<String>>{
        'primary' => new List<String>{'FULL_NAME__C', 'OPEN_PIPE_AE_SCORE__C', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C'},
        'secondary' => new List<String>{'OPEN_PIPE_OPTY_STG_NM__C', 'OPEN_PIPE_APM_L2__C', 'PRIMARY_INDUSTRY__C'},
        'fallback' => new List<String>{'OPEN_PIPE_OPTY_NM__C', 'MACROSGMENT__C', 'WORK_LOCATION_COUNTRY__C'}
    };
    
    private static final Map<String, List<String>> PRODUCT_ANALYSIS_FIELDS = new Map<String, List<String>>{
        'primary' => new List<String>{'OPEN_PIPE_APM_L2__C', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C'},
        'secondary' => new List<String>{'OPEN_PIPE_PROD_NM__C', 'PRIMARY_INDUSTRY__C'},
        'fallback' => new List<String>{'FULL_NAME__C', 'MACROSGMENT__C', 'OPEN_PIPE_OPTY_STG_NM__C'}
    };
    
    // Outlier Detection for Stagnation Analysis
    private static final Map<String, Integer> STAGNATION_THRESHOLDS = new Map<String, Integer>{
        'Stage 1 - Identifying Opportunity' => 30,  // 30 days in Stage 1
        'Stage 2 - Determining Problem, Impact, Ideal' => 60,  // 60 days in Stage 2
        'Stage 3 - Validating Benefits & Value' => 45,  // 45 days in Stage 3
        'Stage 4 - Confirming Value With Power' => 30,  // 30 days in Stage 4
        'Stage 5 - Negotiating $$ & Mutual Plan' => 21,  // 21 days in Stage 5
        'Stage 6 - Finalizing Closure' => 14,  // 14 days in Stage 6
        'Stage 7 - Pending' => 90   // 90 days in Stage 7 (Pending)
    };
    
    // Statistical outlier detection parameters
    private static final Decimal OUTLIER_Z_SCORE_THRESHOLD = 2.5; // Z-score > 2.5 = outlier
    private static final Decimal OUTLIER_IQR_MULTIPLIER = 1.5;    // IQR * 1.5 = outlier boundary
    
    private static final Map<String, List<String>> STAGE_ANALYSIS_FIELDS = new Map<String, List<String>>{
        'primary' => new List<String>{'OPEN_PIPE_OPTY_STG_NM__C', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C'},
        'secondary' => new List<String>{'FULL_NAME__C', 'OPEN_PIPE_AE_SCORE__C', 'OPEN_PIPE_APM_L2__C'},
        'fallback' => new List<String>{'PRIMARY_INDUSTRY__C', 'MACROSGMENT__C', 'WORK_LOCATION_COUNTRY__C'}
    };
    
    // Data Quality Thresholds
    private static final Decimal MIN_DATA_QUALITY_THRESHOLD = 0.7; // 70% of records should have data
    private static final Integer MIN_RECORDS_FOR_ANALYSIS = 5;
    
    /**
     * @description Main method to analyze open pipe data with enhanced formatting
     * @param params Map containing analysis parameters
     * @return String Enhanced analysis message with emojis and structured sections
     */
    public static String analyzeOpenPipe(Map<String, Object> params) {
        try {
            // Extract original parameters for querying
            String originalOu = (String) params.get('ou');
            String originalProduct = (String) params.get('product');
            String originalCountry = (String) params.get('country');
            String originalSegment = (String) params.get('segment');
            String originalStage = (String) params.get('stage');
            String analysisType = (String) params.get('analysisType');
            
            // Normalize parameters for display
            String ou = ANAgentNamingNormalizer.normalizeOUName(originalOu);
            String product = ANAgentNamingNormalizer.normalizeProductName(originalProduct);
            String country = ANAgentNamingNormalizer.normalizeCountry(originalCountry);
            String segment = ANAgentNamingNormalizer.normalizeMacroSegment(originalSegment);
            String stage = ANAgentNamingNormalizer.normalizeStage(originalStage);
            
            // Validate parameters
            if (String.isBlank(originalOu) && String.isBlank(originalProduct) && String.isBlank(originalCountry) && String.isBlank(originalSegment)) {
                return buildEnhancedErrorMessage('INVALID_PARAMS', new Map<String, Object>{
                    'suggestion' => 'Please provide at least one search parameter (OU, Product, Country, or Segment)',
                    'examples' => new List<String>{'Amer-ACC', 'Tableau', 'United States', 'Enterprise'}
                });
            }
            
            // Query data using original values, with wildcard for product LIKE query
            String productForQuery = String.isNotBlank(originalProduct) ? '%' + originalProduct + '%' : originalProduct;
            String stageForQuery = String.isNotBlank(originalStage) ? ANAgentNamingNormalizer.normalizeStage(originalStage) : originalStage;
            List<Agent_Open_Pipe__c> openPipeData = queryOpenPipeData(originalOu, productForQuery, originalCountry, originalSegment, stageForQuery, analysisType);
            
            if (openPipeData.isEmpty()) {
                return buildEnhancedErrorMessage('NO_DATA', new Map<String, Object>{
                    'suggestion' => 'Try using broader search criteria or different parameter combinations',
                    'alternatives' => generateSmartSuggestions(ou, product, country, segment)
                });
            }
            
            // Assess data quality and provide warnings
            Map<String, Decimal> dataQuality = assessDataQuality(openPipeData);
            String dataQualityReport = buildDataQualityReport(dataQuality, analysisType);
            
            // Detect stagnation outliers for data integrity
            Map<String, Object> outlierAnalysis = detectStagnationOutliers(openPipeData);
            String outlierReport = buildOutlierReport(outlierAnalysis);
            
            // Get smart field selection based on analysis type and data quality
            Map<String, List<String>> smartFields = getSmartFieldSelection(analysisType, openPipeData);
            
            // Build enhanced analysis message with data quality context
            return buildAnalysisMessage(openPipeData, ou, product, country, segment, stage, analysisType, dataQualityReport, outlierReport, smartFields);
            
        } catch (Exception e) {
            System.debug('Error in analyzeOpenPipe: ' + e.getMessage());
            return buildEnhancedErrorMessage('SYSTEM_ERROR', new Map<String, Object>{
                'error' => e.getMessage(),
                'suggestion' => 'Please try again or contact support if the issue persists'
            });
        }
    }
    
    /**
     * @description Query open pipe data with normalized parameters
     */
    private static List<Agent_Open_Pipe__c> queryOpenPipeData(String ou, String product, String country, String segment, String stage, String analysisType) {
        String query = 'SELECT Id, Name, OU_NAME__C, OPEN_PIPE_PROD_NM__C, WORK_LOCATION_COUNTRY__C, ' +
                      'MACROSGMENT__C, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C, OPEN_PIPE_OPTY_STG_NM__C, ' +
                      'FULL_NAME__C, OPEN_PIPE_OPTY_NM__C, OPEN_PIPE_AE_SCORE__C, PRIMARY_INDUSTRY__C, ' +
                      'OPEN_PIPE_APM_L2__C, OPEN_PIPE_REVISED_SUB_SECTOR__C, OPEN_PIPE_OPTY_DAYS_IN_STAGE__C, ' +
                      'EMP_ID__C, EMP_MGR_NM__C, OPEN_PIPE_OPP_MANAGER_NT__C ' +
                      'FROM Agent_Open_Pipe__c WHERE ';
        
        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(ou)) {
            conditions.add('OU_NAME__C = :ou');
        }
        if (String.isNotBlank(product)) {
            conditions.add('OPEN_PIPE_PROD_NM__C LIKE :product');
        }
        if (String.isNotBlank(country)) {
            conditions.add('WORK_LOCATION_COUNTRY__C = :country');
        }
        if (String.isNotBlank(segment)) {
            conditions.add('MACROSGMENT__C = :segment');
        }
        if (String.isNotBlank(stage)) {
            conditions.add('OPEN_PIPE_OPTY_STG_NM__C = :stage');
        }
        
        query += String.join(conditions, ' AND ');
        // Use higher limit for complex territory analysis
        if (String.isNotBlank(analysisType) && analysisType.toLowerCase().contains('territory')) {
            query += ' LIMIT 10000'; // Higher limit for complex territory analysis
        } else {
            query += ' LIMIT 1000';  // Standard limit for simple queries
        }
        
        return Database.query(query);
    }
    
    /**
     * @description Build enhanced analysis message with rich formatting
     */
    private static String buildAnalysisMessage(List<Agent_Open_Pipe__c> data, String ou, String product, 
                                             String country, String segment, String stage, String analysisType, 
                                             String dataQualityReport, String outlierReport, Map<String, List<String>> smartFields) {
        String message = '# 🔍 Open Pipe Analysis\n\n';
        
        // Executive Summary
        message += buildExecutiveSummary(data, ou, product, country, segment);
        
        // Analysis Summary
        message += buildAnalysisSummary(data, analysisType);
        
        // Data Quality Report
        message += dataQualityReport + '\n';
        
        // Outlier Detection Report
        message += outlierReport + '\n';
        
        // Results
        message += buildResultsSection(data);
        
        // Actionable Insights
        message += buildActionableInsights(data, ou, product, country, segment);
        
        return message;
    }
    
    /**
     * @description Build executive summary section
     */
    private static String buildExecutiveSummary(List<Agent_Open_Pipe__c> data, String ou, String product, 
                                              String country, String segment) {
        String summary = '## 📊 Executive Summary\n\n';
        
        Decimal totalACV = 0;
        Integer totalDeals = data.size();
        Set<String> uniqueStages = new Set<String>();
        Set<String> uniqueAEs = new Set<String>();
        
        for (Agent_Open_Pipe__c record : data) {
            if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null) {
                totalACV += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C;
            }
            if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM__C)) {
                uniqueStages.add(record.OPEN_PIPE_OPTY_STG_NM__C);
            }
            if (String.isNotBlank(record.FULL_NAME__C)) {
                uniqueAEs.add(record.FULL_NAME__C);
            }
        }
        
        summary += '**Total Pipeline Value:** $' + totalACV.format() + '\n';
        summary += '**Total Deals:** ' + totalDeals + '\n';
        summary += '**Active Stages:** ' + uniqueStages.size() + '\n';
        summary += '**Account Executives:** ' + uniqueAEs.size() + '\n\n';
        
        // Filter context
        if (String.isNotBlank(ou) || String.isNotBlank(product) || String.isNotBlank(country) || String.isNotBlank(segment)) {
            summary += '**Analysis Scope:**\n';
            if (String.isNotBlank(ou)) summary += '- OU: ' + ou + '\n';
            if (String.isNotBlank(product)) summary += '- Product: ' + product + '\n';
            if (String.isNotBlank(country)) summary += '- Country: ' + country + '\n';
            if (String.isNotBlank(segment)) summary += '- Segment: ' + segment + '\n';
            summary += '\n';
        }
        
        return summary;
    }
    
    /**
     * @description Build analysis summary section
     */
    private static String buildAnalysisSummary(List<Agent_Open_Pipe__c> data, String analysisType) {
        String summary = '## 📈 Analysis Summary\n\n';
        
        if (String.isBlank(analysisType) || analysisType == 'GENERAL') {
            summary += 'This analysis provides a comprehensive view of your open pipeline data, ' +
                      'highlighting key metrics, trends, and opportunities for improvement.\n\n';
        } else {
            summary += 'This ' + analysisType.toLowerCase() + ' analysis focuses on specific aspects ' +
                      'of your pipeline to provide targeted insights.\n\n';
        }
        
        // Key metrics
        Decimal totalACV = 0;
        Decimal avgACV = 0;
        Integer totalDeals = data.size();
        
        for (Agent_Open_Pipe__c record : data) {
            if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null) {
                totalACV += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C;
            }
        }
        
        if (totalDeals > 0) {
            avgACV = totalACV / totalDeals;
        }
        
        summary += '**Key Metrics:**\n';
        summary += '- Average Deal Size: $' + avgACV.format() + '\n';
        summary += '- Pipeline Health: ' + (totalDeals > 10 ? 'Strong' : 'Needs Attention') + '\n';
        summary += '- Data Quality: ' + (totalACV > 0 ? 'Good' : 'Review Required') + '\n\n';
        
        return summary;
    }
    
    /**
     * @description Build results section
     */
    private static String buildResultsSection(List<Agent_Open_Pipe__c> data) {
        String results = '## 📋 Results\n\n';
        
        // Stage distribution
        Map<String, Integer> stageCount = new Map<String, Integer>();
        Map<String, Decimal> stageACV = new Map<String, Decimal>();
        
        for (Agent_Open_Pipe__c record : data) {
            String stage = String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM__C) ? record.OPEN_PIPE_OPTY_STG_NM__C : 'Unknown';
            Decimal acv = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null ? record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C : 0;
            
            if (stageCount.containsKey(stage)) {
                stageCount.put(stage, stageCount.get(stage) + 1);
            } else {
                stageCount.put(stage, 1);
            }
            if (stageACV.containsKey(stage)) {
                stageACV.put(stage, stageACV.get(stage) + acv);
            } else {
                stageACV.put(stage, acv);
            }
        }
        
        results += '### 🎯 Stage Distribution\n\n';
        for (String stage : stageCount.keySet()) {
            Integer count = stageCount.get(stage);
            Decimal acv = stageACV.get(stage);
            results += '- **' + stage + ':** ' + count + ' deals ($' + acv.format() + ')\n';
        }
        results += '\n';
        
        // Top AEs
        Map<String, Integer> aeCount = new Map<String, Integer>();
        Map<String, Decimal> aeACV = new Map<String, Decimal>();
        
        for (Agent_Open_Pipe__c record : data) {
            String ae = String.isNotBlank(record.FULL_NAME__C) ? record.FULL_NAME__C : 'Unknown';
            Decimal acv = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null ? record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C : 0;
            
            if (aeCount.containsKey(ae)) {
                aeCount.put(ae, aeCount.get(ae) + 1);
            } else {
                aeCount.put(ae, 1);
            }
            if (aeACV.containsKey(ae)) {
                aeACV.put(ae, aeACV.get(ae) + acv);
            } else {
                aeACV.put(ae, acv);
            }
        }
        
        results += '### 👥 Top Account Executives\n\n';
        List<String> sortedAEs = new List<String>(aeCount.keySet());
        sortedAEs.sort(new AEComparator(aeACV));
        
        Integer displayCount = Math.min(5, sortedAEs.size());
        for (Integer i = 0; i < displayCount; i++) {
            String ae = sortedAEs[i];
            Integer count = aeCount.get(ae);
            Decimal acv = aeACV.get(ae);
            results += (i + 1) + '. **' + ae + ':** ' + count + ' deals ($' + acv.format() + ')\n';
        }
        results += '\n';
        
        return results;
    }
    
    /**
     * @description Build actionable insights section
     */
    private static String buildActionableInsights(List<Agent_Open_Pipe__c> data, String ou, String product, 
                                                String country, String segment) {
        String insights = '## 💡 Actionable Insights\n\n';
        
        // Pipeline health insights
        Decimal totalACV = 0;
        Integer totalDeals = data.size();
        Integer dealsWithACV = 0;
        
        for (Agent_Open_Pipe__c record : data) {
            if (record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C != null && record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C > 0) {
                totalACV += record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C;
                dealsWithACV++;
            }
        }
        
        insights += '### 🎯 Pipeline Health\n';
        if (dealsWithACV < totalDeals * 0.8) {
            insights += '- ⚠️ **Data Quality Issue:** ' + (totalDeals - dealsWithACV) + ' deals missing ACV values\n';
        }
        if (totalACV < 1000000) {
            insights += '- 📈 **Growth Opportunity:** Consider expanding pipeline to reach higher ACV targets\n';
        }
        insights += '\n';
        
        // Stage-specific insights
        Map<String, Integer> stageCount = new Map<String, Integer>();
        for (Agent_Open_Pipe__c record : data) {
            String stage = String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM__C) ? record.OPEN_PIPE_OPTY_STG_NM__C : 'Unknown';
            if (stageCount.containsKey(stage)) {
                stageCount.put(stage, stageCount.get(stage) + 1);
            } else {
                stageCount.put(stage, 1);
            }
        }
        
        insights += '### 🚀 Stage Optimization\n';
        for (String stage : stageCount.keySet()) {
            Integer count = stageCount.get(stage);
            if (count > totalDeals * 0.3) {
                insights += '- **' + stage + ':** High concentration (' + count + ' deals) - consider stage-specific strategies\n';
            }
        }
        insights += '\n';
        
        // Next steps
        insights += '### 📋 Recommended Next Steps\n';
        insights += '1. Review deals with missing ACV values\n';
        insights += '2. Focus on stage progression for high-concentration stages\n';
        insights += '3. Analyze AE performance patterns\n';
        insights += '4. Consider territory adjustments based on data distribution\n\n';
        
        return insights;
    }
    
    /**
     * @description Build enhanced error message with troubleshooting tips
     */
    private static String buildEnhancedErrorMessage(String errorType, Map<String, Object> context) {
        String message = '## ❌ ' + ERROR_MESSAGES.get(errorType) + '\n\n';
        
        if (context.containsKey('suggestion')) {
            message += '**💡 Suggestion:** ' + context.get('suggestion') + '\n\n';
        }
        
        if (context.containsKey('alternatives')) {
            List<String> alternatives = (List<String>) context.get('alternatives');
            if (alternatives != null && !alternatives.isEmpty()) {
                message += '**🔄 Try these alternatives:**\n';
                for (String alt : alternatives) {
                    message += '- ' + alt + '\n';
                }
                message += '\n';
            }
        }
        
        if (context.containsKey('error')) {
            message += '**🔧 Technical Details:** ' + context.get('error') + '\n\n';
        }
        
        message += '**📞 Need Help?** Contact your system administrator for assistance.\n';
        
        return message;
    }
    
    /**
     * @description Generate smart suggestions for alternative search parameters
     */
    private static List<String> generateSmartSuggestions(String ou, String product, String country, String segment) {
        List<String> suggestions = new List<String>();
        
        if (String.isBlank(ou)) {
            suggestions.add('Try searching by OU: Amer-ACC, EMEA, APAC');
        }
        if (String.isBlank(product)) {
            suggestions.add('Try searching by Product: Tableau, Sales Cloud, Service Cloud');
        }
        if (String.isBlank(country)) {
            suggestions.add('Try searching by Country: United States, United Kingdom, Germany');
        }
        if (String.isBlank(segment)) {
            suggestions.add('Try searching by Segment: Enterprise, Mid-Market, SMB');
        }
        
        return suggestions;
    }
    
    /**
     * @description Custom comparator for sorting AEs by ACV
     */
    public class AEComparator implements Comparator<String> {
        private Map<String, Decimal> acvMap;
        
        public AEComparator(Map<String, Decimal> acvMap) {
            this.acvMap = acvMap;
        }
        
        public Integer compare(String ae1, String ae2) {
            Decimal acv1 = acvMap.get(ae1);
            Decimal acv2 = acvMap.get(ae2);
            
            if (acv1 == null && acv2 == null) return 0;
            if (acv1 == null) return 1;
            if (acv2 == null) return -1;
            
            if (acv2 > acv1) return 1;
            if (acv2 < acv1) return -1;
            return 0; // Descending order
        }
    }
    
    /**
     * Provides field suggestions for Open Pipe Analysis
     */
    public static String getFieldSuggestions(String filterCriteria) {
        String suggestions = '# Field Suggestions for Open Pipe Analysis\n\n';
        suggestions += '## Available Fields\n';
        
        Map<String, String> fieldMap = new Map<String, String>{
            'stage' => 'open_pipe_opty_stg_nm__c',
            'product' => 'open_pipe_prod_nm__c',
            'amount' => 'open_pipe_original_openpipe_alloc_amt__c',
            'days_in_stage' => 'open_pipe_opty_days_in_stage__c',
            'ae_score' => 'open_pipe_ae_score__c',
            'industry' => 'primary_industry__c',
            'segment' => 'macrosgment__c',
            'country' => 'work_location_country__c',
            'ou' => 'ou_name__c',
            'ae' => 'full_name__c',
            'manager' => 'emp_mgr_nm__c',
            'apm' => 'open_pipe_apm_l2__c',
            'sub_sector' => 'open_pipe_revised_sub_sector__c',
            'manager_notes' => 'open_pipe_opp_manager_nt__c',
            'opportunity_name' => 'open_pipe_opty_nm__c'
        };
        
        for (String alias : fieldMap.keySet()) {
            String fieldName = fieldMap.get(alias);
            suggestions += '- **' + alias + '** → ' + fieldName + '\n';
        }
        
        suggestions += '\n## Example Filters\n';
        suggestions += '- `stage=\'05 - Negotiating $$ & Mutual Plan\'`\n';
        suggestions += '- `amount > 200000`\n';
        suggestions += '- `days_in_stage > 20`\n';
        suggestions += '- `ae_score > 3`\n';
        suggestions += '- `product=\'Data Cloud\'`\n';
        
        return suggestions;
    }
    
    /**
     * Validates filter criteria and provides suggestions for common errors
     */
    public static String validateFilterCriteria(String filterCriteria) {
        if (String.isBlank(filterCriteria)) {
            return 'Filter criteria cannot be empty.';
        }
        
        String validation = '# Filter Criteria Validation\n\n';
        validation += '## Input\n';
        validation += filterCriteria + '\n\n';
        
        // Check for common field name errors
        List<String> fieldSuggestions = new List<String>();
        if (filterCriteria.toLowerCase().contains('oppty')) {
            fieldSuggestions.add('⚠️ **Field Name Issue**: `oppty` should be `opty` (remove extra \'p\')');
            fieldSuggestions.add('   Correct: `open_pipe_opty_stg_nm__c` instead of `open_pipe_oppty_stg_nm`');
        }
        
        if (filterCriteria.toLowerCase().contains('stg_nm') && !filterCriteria.contains('__c')) {
            fieldSuggestions.add('⚠️ **Field Name Issue**: Missing `__c` suffix');
            fieldSuggestions.add('   Correct: `open_pipe_opty_stg_nm__c` instead of `open_pipe_opty_stg_nm`');
        }
        
        if (filterCriteria.toLowerCase().contains('prod_nm') && !filterCriteria.contains('__c')) {
            fieldSuggestions.add('⚠️ **Field Name Issue**: Missing `__c` suffix');
            fieldSuggestions.add('   Correct: `open_pipe_prod_nm__c` instead of `open_pipe_prod_nm`');
        }
        
        // Check for common syntax errors
        if (filterCriteria.contains('&&')) {
            validation += '⚠️ **Warning**: Use `AND` instead of `&&` for logical AND operations\n';
        }
        
        if (filterCriteria.contains('||')) {
            validation += '⚠️ **Warning**: Use `OR` instead of `||` for logical OR operations\n';
        }
        
        // Add field name suggestions
        if (!fieldSuggestions.isEmpty()) {
            validation += '\n## Field Name Issues Detected\n';
            for (String suggestion : fieldSuggestions) {
                validation += suggestion + '\n';
            }
        }
        
        if (filterCriteria.contains('==')) {
            validation += '⚠️ **Warning**: Use `=` instead of `==` for equality comparisons\n';
        }
        
        validation += '\n## Available Fields\n';
        Map<String, String> fieldMap = new Map<String, String>{
            'stage' => 'open_pipe_opty_stg_nm__c',
            'product' => 'open_pipe_prod_nm__c',
            'amount' => 'open_pipe_original_openpipe_alloc_amt__c',
            'days_in_stage' => 'open_pipe_opty_days_in_stage__c',
            'ae_score' => 'open_pipe_ae_score__c',
            'industry' => 'primary_industry__c',
            'segment' => 'macrosgment__c',
            'country' => 'work_location_country__c',
            'ou' => 'ou_name__c',
            'ae' => 'full_name__c',
            'manager' => 'emp_mgr_nm__c',
            'apm' => 'open_pipe_apm_l2__c',
            'sub_sector' => 'open_pipe_revised_sub_sector__c',
            'manager_notes' => 'open_pipe_opp_manager_nt__c',
            'opportunity_name' => 'open_pipe_opty_nm__c'
        };
        
        for (String alias : fieldMap.keySet()) {
            String fieldName = fieldMap.get(alias);
            validation += '- ' + alias + ' → ' + fieldName + '\n';
        }
        
        return validation;
    }
    
    /**
     * @description Smart field selection based on analysis type and data availability
     */
    private static Map<String, List<String>> getSmartFieldSelection(String analysisType, List<Agent_Open_Pipe__c> availableData) {
        Map<String, List<String>> fieldMap = new Map<String, List<String>>();
        
        // Get base field mapping based on analysis type
        if (analysisType != null && analysisType.toLowerCase().contains('territory')) {
            fieldMap = TERRITORY_ANALYSIS_FIELDS;
        } else if (analysisType != null && analysisType.toLowerCase().contains('ae')) {
            fieldMap = AE_ANALYSIS_FIELDS;
        } else if (analysisType != null && analysisType.toLowerCase().contains('product')) {
            fieldMap = PRODUCT_ANALYSIS_FIELDS;
        } else if (analysisType != null && analysisType.toLowerCase().contains('stage')) {
            fieldMap = STAGE_ANALYSIS_FIELDS;
        } else {
            // Default to territory analysis
            fieldMap = TERRITORY_ANALYSIS_FIELDS;
        }
        
        // Assess data quality and adjust field selection
        Map<String, Decimal> fieldQuality = assessDataQuality(availableData);
        Map<String, List<String>> smartSelection = new Map<String, List<String>>();
        
        // Select fields based on data quality
        for (String priority : fieldMap.keySet()) {
            List<String> selectedFields = new List<String>();
            for (String field : fieldMap.get(priority)) {
                if (fieldQuality.containsKey(field) && fieldQuality.get(field) >= MIN_DATA_QUALITY_THRESHOLD) {
                    selectedFields.add(field);
                }
            }
            if (!selectedFields.isEmpty()) {
                smartSelection.put(priority, selectedFields);
            }
        }
        
        return smartSelection;
    }
    
    /**
     * @description Assess data quality for each field
     * @param data List of records to analyze
     * @return Map of field names to data quality percentage
     */
    private static Map<String, Decimal> assessDataQuality(List<Agent_Open_Pipe__c> data) {
        Map<String, Decimal> qualityMap = new Map<String, Decimal>();
        
        if (data.isEmpty()) {
            return qualityMap;
        }
        
        Integer totalRecords = data.size();
        Map<String, Integer> fieldCounts = new Map<String, Integer>();
        
        // Initialize field counts
        List<String> allFields = new List<String>{
            'FULL_NAME__C', 'OPEN_PIPE_AE_SCORE__C', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C',
            'OPEN_PIPE_OPTY_STG_NM__C', 'OPEN_PIPE_APM_L2__C', 'PRIMARY_INDUSTRY__C',
            'MACROSGMENT__C', 'WORK_LOCATION_COUNTRY__C', 'OPEN_PIPE_PROD_NM__C',
            'OPEN_PIPE_REVISED_SUB_SECTOR__C', 'OPEN_PIPE_OPTY_NM__C'
        };
        
        for (String field : allFields) {
            fieldCounts.put(field, 0);
        }
        
        // Count non-null values for each field
        for (Agent_Open_Pipe__c record : data) {
            for (String field : allFields) {
                Object value = getFieldValue(record, field);
                if (value != null && String.valueOf(value).trim() != '') {
                    fieldCounts.put(field, fieldCounts.get(field) + 1);
                }
            }
        }
        
        // Calculate quality percentages
        for (String field : allFields) {
            Decimal quality = (Decimal.valueOf(fieldCounts.get(field)) / totalRecords) * 100;
            qualityMap.put(field, quality);
        }
        
        return qualityMap;
    }
    
    /**
     * @description Detect stagnation outliers using statistical methods
     */
    private static Map<String, Object> detectStagnationOutliers(List<Agent_Open_Pipe__c> data) {
        Map<String, Object> outlierResults = new Map<String, Object>();
        
        if (data.isEmpty()) {
            return outlierResults;
        }
        
        // Extract days in stage values
        List<Decimal> daysInStage = new List<Decimal>();
        Map<String, List<Decimal>> stageDaysMap = new Map<String, List<Decimal>>();
        
        for (Agent_Open_Pipe__c record : data) {
            if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C != null) {
                Decimal days = record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C;
                daysInStage.add(days);
                
                String stage = record.OPEN_PIPE_OPTY_STG_NM__C;
                if (String.isNotBlank(stage)) {
                    if (!stageDaysMap.containsKey(stage)) {
                        stageDaysMap.put(stage, new List<Decimal>());
                    }
                    stageDaysMap.get(stage).add(days);
                }
            }
        }
        
        if (daysInStage.isEmpty()) {
            outlierResults.put('error', 'No days in stage data available');
            return outlierResults;
        }
        
        // Calculate overall statistics
        Map<String, Object> overallStats = calculateStagnationStatistics(daysInStage);
        outlierResults.put('overall', overallStats);
        
        // Calculate stage-specific outliers
        Map<String, Object> stageOutliers = new Map<String, Object>();
        for (String stage : stageDaysMap.keySet()) {
            List<Decimal> stageDays = stageDaysMap.get(stage);
            if (stageDays.size() > 1) { // Need at least 2 values for statistical analysis
                Map<String, Object> stageStats = calculateStagnationStatistics(stageDays);
                stageStats.put('threshold', STAGNATION_THRESHOLDS.get(stage));
                stageOutliers.put(stage, stageStats);
            }
        }
        outlierResults.put('by_stage', stageOutliers);
        
        // Identify specific outlier records
        List<Map<String, Object>> outlierRecords = identifyOutlierRecords(data, overallStats);
        outlierResults.put('outlier_records', outlierRecords);
        
        return outlierResults;
    }
    
    /**
     * @description Calculate statistical measures for stagnation analysis
     */
    private static Map<String, Object> calculateStagnationStatistics(List<Decimal> daysList) {
        Map<String, Object> stats = new Map<String, Object>();
        
        if (daysList.isEmpty()) {
            return stats;
        }
        
        // Sort the list for percentile calculations
        List<Decimal> sortedDays = new List<Decimal>(daysList);
        sortedDays.sort();
        
        Integer n = sortedDays.size();
        
        // Basic statistics
        Decimal sum = 0;
        for (Decimal day : sortedDays) {
            sum += day;
        }
        
        Decimal mean = sum / n;
        Decimal median = (Math.mod(n, 2) == 0) ? 
            (sortedDays[n/2 - 1] + sortedDays[n/2]) / 2 : 
            sortedDays[n/2];
        
        // Calculate standard deviation
        Decimal variance = 0;
        for (Decimal day : sortedDays) {
            variance += (day - mean) * (day - mean);
        }
        Decimal stdDev = Math.sqrt(variance / n);
        
        // Calculate quartiles
        Decimal q1 = calculatePercentile(sortedDays, 25);
        Decimal q3 = calculatePercentile(sortedDays, 75);
        Decimal iqr = q3 - q1;
        
        // Outlier boundaries using IQR method
        Decimal lowerBound = q1 - (OUTLIER_IQR_MULTIPLIER * iqr);
        Decimal upperBound = q3 + (OUTLIER_IQR_MULTIPLIER * iqr);
        
        // Count outliers
        Integer outlierCount = 0;
        for (Decimal day : sortedDays) {
            if (day < lowerBound || day > upperBound) {
                outlierCount++;
            }
        }
        
        stats.put('count', n);
        stats.put('mean', mean);
        stats.put('median', median);
        stats.put('std_dev', stdDev);
        stats.put('q1', q1);
        stats.put('q3', q3);
        stats.put('iqr', iqr);
        stats.put('min', sortedDays[0]);
        stats.put('max', sortedDays[n-1]);
        stats.put('lower_bound', lowerBound);
        stats.put('upper_bound', upperBound);
        stats.put('outlier_count', outlierCount);
        stats.put('outlier_percentage', (Decimal.valueOf(outlierCount) / n) * 100);
        
        return stats;
    }
    
    /**
     * @description Calculate percentile for a sorted list
     */
    private static Decimal calculatePercentile(List<Decimal> sortedList, Decimal percentile) {
        if (sortedList.isEmpty()) return 0;
        
        Integer n = sortedList.size();
        Decimal index = (percentile / 100) * (n - 1);
        Integer lowerIndex = Math.floor(index).intValue();
        Integer upperIndex = Math.ceil(index).intValue();
        
        if (lowerIndex == upperIndex) {
            return sortedList[lowerIndex];
        }
        
        Decimal weight = index - lowerIndex;
        return sortedList[lowerIndex] * (1 - weight) + sortedList[upperIndex] * weight;
    }
    
    /**
     * @description Identify specific records that are outliers
     */
    private static List<Map<String, Object>> identifyOutlierRecords(List<Agent_Open_Pipe__c> data, Map<String, Object> overallStats) {
        List<Map<String, Object>> outliers = new List<Map<String, Object>>();
        
        Decimal upperBound = (Decimal) overallStats.get('upper_bound');
        Decimal lowerBound = (Decimal) overallStats.get('lower_bound');
        
        for (Agent_Open_Pipe__c record : data) {
            if (record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C != null) {
                Decimal days = record.OPEN_PIPE_OPTY_DAYS_IN_STAGE__C;
                
                if (days > upperBound || days < lowerBound) {
                    Map<String, Object> outlier = new Map<String, Object>{
                        'record_id' => record.Id,
                        'opportunity_name' => record.OPEN_PIPE_OPTY_NM__C,
                        'ae_name' => record.FULL_NAME__C,
                        'stage' => record.OPEN_PIPE_OPTY_STG_NM__C,
                        'days_in_stage' => days,
                        'amount' => record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C,
                        'outlier_type' => days > upperBound ? 'HIGH_STAGNATION' : 'LOW_STAGNATION',
                        'severity' => days > upperBound ? 'CRITICAL' : 'WARNING'
                    };
                    outliers.add(outlier);
                }
            }
        }
        
        return outliers;
    }
    
    /**
     * @description Get field value using reflection
     */
    private static Object getFieldValue(Agent_Open_Pipe__c record, String fieldName) {
        try {
            return record.get(fieldName);
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * @description Build data quality warnings and suggestions
     * @param qualityMap Map of field quality percentages
     * @param analysisType Type of analysis being performed
     * @return String Data quality report
     */
    private static String buildDataQualityReport(Map<String, Decimal> qualityMap, String analysisType) {
        String report = '## 📊 Data Quality Assessment\n\n';
        
        List<String> criticalFields = new List<String>();
        List<String> warningFields = new List<String>();
        List<String> goodFields = new List<String>();
        
        // Categorize fields by quality
        for (String field : qualityMap.keySet()) {
            Decimal quality = qualityMap.get(field);
            if (quality < 50) {
                criticalFields.add(field + ' (' + quality.setScale(1) + '% data)');
            } else if (quality < 70) {
                warningFields.add(field + ' (' + quality.setScale(1) + '% data)');
            } else {
                goodFields.add(field + ' (' + quality.setScale(1) + '% data)');
            }
        }
        
        // Report critical issues
        if (!criticalFields.isEmpty()) {
            report += '🚨 **Critical Data Quality Issues:**\n';
            for (String field : criticalFields) {
                report += '- ' + field + '\n';
            }
            report += '\n';
        }
        
        // Report warnings
        if (!warningFields.isEmpty()) {
            report += '⚠️ **Data Quality Warnings:**\n';
            for (String field : warningFields) {
                report += '- ' + field + '\n';
            }
            report += '\n';
        }
        
        // Report good quality
        if (!goodFields.isEmpty()) {
            report += '✅ **Good Data Quality:**\n';
            for (String field : goodFields) {
                report += '- ' + field + '\n';
            }
            report += '\n';
        }
        
        // Add recommendations
        report += '### 💡 Recommendations:\n';
        if (!criticalFields.isEmpty()) {
            report += '1. **Immediate Action Required:** Address critical data quality issues\n';
        }
        if (!warningFields.isEmpty()) {
            report += '2. **Data Improvement:** Focus on fields with warning status\n';
        }
        if (criticalFields.isEmpty() && warningFields.isEmpty()) {
            report += '1. **Excellent Data Quality:** All fields have good data coverage\n';
        }
        report += '3. **Analysis Reliability:** Results based on available data quality\n';
        
        return report;
    }
    
    /**
     * @description Build outlier detection report for stagnation analysis
     */
    private static String buildOutlierReport(Map<String, Object> outlierAnalysis) {
        String report = '## 🚨 Stagnation Outlier Detection\n\n';
        
        if (outlierAnalysis.containsKey('error')) {
            report += '⚠️ **No stagnation data available for analysis**\n\n';
            return report;
        }
        
        // Overall statistics
        Map<String, Object> overallStats = (Map<String, Object>) outlierAnalysis.get('overall');
        if (overallStats != null) {
            Integer outlierCount = (Integer) overallStats.get('outlier_count');
            Decimal outlierPercentage = (Decimal) overallStats.get('outlier_percentage');
            Decimal mean = (Decimal) overallStats.get('mean');
            Decimal median = (Decimal) overallStats.get('median');
            Decimal upperBound = (Decimal) overallStats.get('upper_bound');
            
            report += '### 📊 Overall Stagnation Statistics\n';
            report += '- **Total Records Analyzed:** ' + overallStats.get('count') + '\n';
            report += '- **Average Days in Stage:** ' + mean.setScale(1) + ' days\n';
            report += '- **Median Days in Stage:** ' + median.setScale(1) + ' days\n';
            report += '- **Outlier Threshold:** ' + upperBound.setScale(1) + ' days\n';
            report += '- **Outliers Detected:** ' + outlierCount + ' (' + outlierPercentage.setScale(1) + '%)\n\n';
            
            if (outlierCount > 0) {
                if (outlierPercentage > 10) {
                    report += '🚨 **HIGH RISK:** ' + outlierPercentage.setScale(1) + '% of opportunities show unusual stagnation patterns\n\n';
                } else if (outlierPercentage > 5) {
                    report += '⚠️ **MEDIUM RISK:** ' + outlierPercentage.setScale(1) + '% of opportunities show stagnation concerns\n\n';
                } else {
                    report += '✅ **LOW RISK:** ' + outlierPercentage.setScale(1) + '% of opportunities show stagnation patterns\n\n';
                }
            }
        }
        
        // Stage-specific analysis
        Map<String, Object> stageOutliers = (Map<String, Object>) outlierAnalysis.get('by_stage');
        if (stageOutliers != null && !stageOutliers.isEmpty()) {
            report += '### 🎯 Stage-Specific Analysis\n';
            
            for (String stage : stageOutliers.keySet()) {
                Map<String, Object> stageStats = (Map<String, Object>) stageOutliers.get(stage);
                Integer stageOutlierCount = (Integer) stageStats.get('outlier_count');
                Decimal stageOutlierPercentage = (Decimal) stageStats.get('outlier_percentage');
                Decimal stageMean = (Decimal) stageStats.get('mean');
                Integer threshold = (Integer) stageStats.get('threshold');
                
                String stageDisplay = stage.replace('Stage ', 'S').replace(' - ', ' - ');
                report += '**' + stageDisplay + ':**\n';
                report += '- Records: ' + stageStats.get('count') + ' | Avg: ' + stageMean.setScale(1) + ' days | Threshold: ' + threshold + ' days\n';
                report += '- Outliers: ' + stageOutlierCount + ' (' + stageOutlierPercentage.setScale(1) + '%)\n';
                
                if (stageOutlierCount > 0) {
                    if (stageOutlierPercentage > 15) {
                        report += '  🚨 **CRITICAL:** High stagnation risk in this stage\n';
                    } else if (stageOutlierPercentage > 8) {
                        report += '  ⚠️ **WARNING:** Moderate stagnation risk in this stage\n';
                    } else {
                        report += '  ✅ **ACCEPTABLE:** Low stagnation risk in this stage\n';
                    }
                }
                report += '\n';
            }
        }
        
        // Specific outlier records
        List<Map<String, Object>> outlierRecords = (List<Map<String, Object>>) outlierAnalysis.get('outlier_records');
        if (outlierRecords != null && !outlierRecords.isEmpty()) {
            report += '### 🔍 Critical Outlier Records\n';
            report += '**Top 10 Most Critical Stagnation Cases:**\n\n';
            
            // Sort by days in stage (descending) and take top 10
            List<Map<String, Object>> sortedOutliers = new List<Map<String, Object>>(outlierRecords);
            sortedOutliers.sort(new OutlierComparator());
            
            Integer count = 0;
            for (Map<String, Object> outlier : sortedOutliers) {
                if (count >= 10) break;
                
                String severity = (String) outlier.get('severity');
                String emoji = severity == 'CRITICAL' ? '🚨' : '⚠️';
                String opportunityName = (String) outlier.get('opportunity_name');
                String aeName = (String) outlier.get('ae_name');
                Decimal days = (Decimal) outlier.get('days_in_stage');
                Decimal amount = (Decimal) outlier.get('amount');
                String stage = (String) outlier.get('stage');
                
                report += emoji + ' **' + opportunityName + '**\n';
                report += '   - AE: ' + aeName + ' | Stage: ' + stage + '\n';
                report += '   - Days in Stage: ' + days.setScale(0) + ' | Amount: $' + (amount != null ? String.valueOf(amount.setScale(0)) : 'N/A') + '\n\n';
                
                count++;
            }
            
            if (outlierRecords.size() > 10) {
                report += '*... and ' + (outlierRecords.size() - 10) + ' more outlier records*\n\n';
            }
        }
        
        // Recommendations
        report += '### 💡 Stagnation Management Recommendations\n';
        if (outlierAnalysis.containsKey('outlier_records') && !((List<Map<String, Object>>) outlierAnalysis.get('outlier_records')).isEmpty()) {
            report += '1. **Immediate Review:** Focus on critical outlier records identified above\n';
            report += '2. **Stage Progression:** Implement stage progression coaching for stagnant deals\n';
            report += '3. **Data Cleanup:** Verify if outlier records represent forgotten or abandoned deals\n';
            report += '4. **Process Improvement:** Review stage transition criteria and timelines\n';
            report += '5. **AE Coaching:** Provide targeted coaching for AEs with high stagnation rates\n';
        } else {
            report += '✅ **No significant stagnation outliers detected** - Pipeline shows healthy progression patterns\n';
        }
        
        return report;
    }
    
    /**
     * @description Comparator for sorting outliers by days in stage
     */
    public class OutlierComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            Decimal daysA = (Decimal) a.get('days_in_stage');
            Decimal daysB = (Decimal) b.get('days_in_stage');
            
            if (daysA == null && daysB == null) return 0;
            if (daysA == null) return 1;
            if (daysB == null) return -1;
            
            return (daysB > daysA) ? 1 : ((daysB < daysA) ? -1 : 0); // Descending order
        }
    }
    
    /**
     * @description Get product level based on user request and data availability
     */
    private static String getProductLevelField(String userRequest, List<Agent_Open_Pipe__c> availableData) {
        // Check user request for specific level
        if (userRequest != null) {
            if (userRequest.toLowerCase().contains('l3') || userRequest.toLowerCase().contains('sku')) {
                return 'OPEN_PIPE_PROD_NM__C';
            }
        }
        
        // Default to L2, but check data availability
        Map<String, Decimal> qualityMap = assessDataQuality(availableData);
        
        // Check L2 availability first (default)
        if (qualityMap.containsKey('OPEN_PIPE_APM_L2__C') && qualityMap.get('OPEN_PIPE_APM_L2__C') >= MIN_DATA_QUALITY_THRESHOLD * 100) {
            return 'OPEN_PIPE_APM_L2__C';
        }
        
        // Fallback to SKU level if L2 is not available
        if (qualityMap.containsKey('OPEN_PIPE_PROD_NM__C') && qualityMap.get('OPEN_PIPE_PROD_NM__C') >= MIN_DATA_QUALITY_THRESHOLD * 100) {
            return 'OPEN_PIPE_PROD_NM__C';
        }
        
        // Default to L2 even if data quality is poor
        return 'OPEN_PIPE_APM_L2__C';
    }
}
