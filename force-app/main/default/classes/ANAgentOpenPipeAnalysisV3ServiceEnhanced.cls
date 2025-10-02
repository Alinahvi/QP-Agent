/**
 * @description Enhanced Open Pipe Analysis Service with context-aware resolution and rich formatting
 * @author Salesforce
 * @date 2024
 */
public with sharing class ANAgentOpenPipeAnalysisV3ServiceEnhanced {
    
    // Enhanced error messages with emojis and troubleshooting tips
    private static final Map<String, String> ERROR_MESSAGES = new Map<String, String>{
        'NO_DATA' => '🔍 No data found for the specified criteria. Try expanding your search parameters.',
        'INVALID_PARAMS' => '⚠️ Invalid parameters provided. Please check your input and try again.',
        'GOVERNOR_LIMIT' => '🚨 Governor limit exceeded. Please refine your search criteria.',
        'SYSTEM_ERROR' => '❌ System error occurred. Please try again or contact support.'
    };
    
    /**
     * @description Main method to analyze open pipe data with enhanced formatting
     * @param params Map containing analysis parameters
     * @return String Enhanced analysis message with emojis and structured sections
     */
    public static String analyzeOpenPipe(Map<String, Object> params) {
        try {
            // Extract and normalize parameters
            String ou = ANAgentNamingNormalizer.normalizeOUName((String) params.get('ou'));
            String product = ANAgentNamingNormalizer.normalizeProductName((String) params.get('product'));
            String country = ANAgentNamingNormalizer.normalizeCountry((String) params.get('country'));
            String segment = ANAgentNamingNormalizer.normalizeMacroSegment((String) params.get('segment'));
            String analysisType = (String) params.get('analysisType');
            
            // Validate parameters
            if (String.isBlank(ou) && String.isBlank(product) && String.isBlank(country) && String.isBlank(segment)) {
                return buildEnhancedErrorMessage('INVALID_PARAMS', new Map<String, Object>{
                    'suggestion' => 'Please provide at least one search parameter (OU, Product, Country, or Segment)',
                    'examples' => new List<String>{'Amer-ACC', 'Tableau', 'United States', 'Enterprise'}
                });
            }
            
            // Query data
            List<Agent_Open_Pipe__c> openPipeData = queryOpenPipeData(ou, product, country, segment);
            
            if (openPipeData.isEmpty()) {
                return buildEnhancedErrorMessage('NO_DATA', new Map<String, Object>{
                    'suggestion' => 'Try using broader search criteria or different parameter combinations',
                    'alternatives' => generateSmartSuggestions(ou, product, country, segment)
                });
            }
            
            // Build enhanced analysis message
            return buildAnalysisMessage(openPipeData, ou, product, country, segment, analysisType);
            
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
    private static List<Agent_Open_Pipe__c> queryOpenPipeData(String ou, String product, String country, String segment) {
        String query = 'SELECT Id, Name, OU_NAME__C, OPEN_PIPE_PROD_NM__C, WORK_LOCATION_COUNTRY__C, ' +
                      'MACROSGMENT__C, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C, OPEN_PIPE_OPTY_STG_NM__C, ' +
                      'FULL_NAME__C, OPEN_PIPE_OPTY_NM__C, OPEN_PIPE_AE_SCORE__C, PRIMARY_INDUSTRY__C ' +
                      'FROM Agent_Open_Pipe__c WHERE ';
        
        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(ou)) {
            conditions.add('OU_NAME__C = :ou');
        }
        if (String.isNotBlank(product)) {
            conditions.add('OPEN_PIPE_PROD_NM__C = :product');
        }
        if (String.isNotBlank(country)) {
            conditions.add('WORK_LOCATION_COUNTRY__C = :country');
        }
        if (String.isNotBlank(segment)) {
            conditions.add('MACROSGMENT__C = :segment');
        }
        
        query += String.join(conditions, ' AND ');
        query += ' LIMIT 1000';
        
        return Database.query(query);
    }
    
    /**
     * @description Build enhanced analysis message with rich formatting
     */
    private static String buildAnalysisMessage(List<Agent_Open_Pipe__c> data, String ou, String product, 
                                             String country, String segment, String analysisType) {
        String message = '# 🔍 Open Pipe Analysis\n\n';
        
        // Executive Summary
        message += buildExecutiveSummary(data, ou, product, country, segment);
        
        // Analysis Summary
        message += buildAnalysisSummary(data, analysisType);
        
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
}
