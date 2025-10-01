/**
 * KPI Response Formatter
 * Formats KPI analysis responses into human-readable messages
 * 
 * @version 1.0
 * @author AI Assistant
 */
public with sharing class ANAgentKPIResponseFormatter {

    /**
     * Format KPI analysis response into human-readable message
     * @param response KPI analysis response
     * @param request Original request
     * @param outlierResults Outlier analysis results
     * @return Formatted message
     */
    public static String formatResponse(ANAgentKPIAnalysisService.KPIAnalysisResponse response,
                                       ANAgentKPIAnalysisService.KPIAnalysisRequest request,
                                       Map<String, ANAgentKPIOutlierService.OutlierResult> outlierResults) {
        Boolean enableOutliers = false;
        if (request != null) {
            try {
                enableOutliers = request.enableOutliers;
            } catch (Exception e) {
                enableOutliers = false;
            }
        }
        String formattedMessage = '';
        
        // 1. KPI Health Summary
        formattedMessage += '# KPI Health Summary\n\n';
        formattedMessage += '**OU:** ' + (response.ouName != null ? response.ouName : 'N/A') + '\n';
        formattedMessage += '**Country:** ' + (response.country != null ? response.country : 'N/A') + '\n';
        formattedMessage += '**Timeframe:** ' + response.timeFrame + '\n';
        formattedMessage += '**Analysis Type:** ' + response.analysisType + '\n';
        formattedMessage += '**Total AEs:** ' + response.totalAEs + '\n';
        formattedMessage += '**Total Records:** ' + response.totalRecordCount + '\n\n';

        formattedMessage += '## Key Metrics\n';
        if (response.totalMeetings != null) formattedMessage += '*   **Total Meetings:** ' + response.totalMeetings + '\n';
        if (response.totalCallConnects != null) formattedMessage += '*   **Total Call Connects:** ' + response.totalCallConnects + '\n';
        if (response.totalACV != null) formattedMessage += '*   **Total ACV:** ' + formatCurrency(response.totalACV) + '\n';
        if (response.totalPG != null) formattedMessage += '*   **Total PG:** ' + formatCurrency(response.totalPG) + '\n';
        if (response.avgCoverage != null) formattedMessage += '*   **Avg. Coverage:** ' + response.avgCoverage.setScale(2) + '\n';
        formattedMessage += '\n';

        // 2. Outlier Tiles (if enabled and results exist)
        if (enableOutliers && outlierResults != null && !outlierResults.isEmpty()) {
            formattedMessage += '## Outlier Analysis\n';
            for (String metric : outlierResults.keySet()) {
                ANAgentKPIOutlierService.OutlierResult result = outlierResults.get(metric);
                formattedMessage += '### ' + formatMetricName(metric) + ' Outliers (' + result.method + ')\n';
                
                if (!result.highOutliers.isEmpty()) {
                    formattedMessage += '*   **High Outliers:**\n';
                    for (Integer i = 0; i < Math.min(result.highOutliers.size(), 5); i++) { // Top 5
                        ANAgentKPIOutlierService.OutlierData ae = result.highOutliers[i];
                        formattedMessage += '    *   ' + (ae.aeName != null ? ae.aeName : 'Unknown') + 
                                          ' (' + (ae.aeEmail != null ? ae.aeEmail : 'N/A') + '): ' + 
                                          ae.value.setScale(2) + ' (+' + ae.deltaFromMedian.setScale(2) + ' vs median)\n';
                    }
                }
                if (!result.lowOutliers.isEmpty()) {
                    formattedMessage += '*   **Low Outliers:**\n';
                    for (Integer i = 0; i < Math.min(result.lowOutliers.size(), 5); i++) { // Top 5
                        ANAgentKPIOutlierService.OutlierData ae = result.lowOutliers[i];
                        formattedMessage += '    *   ' + (ae.aeName != null ? ae.aeName : 'Unknown') + 
                                          ' (' + (ae.aeEmail != null ? ae.aeEmail : 'N/A') + '): ' + 
                                          ae.value.setScale(2) + ' (' + ae.deltaFromMedian.setScale(2) + ' vs median)\n';
                    }
                }
                if (result.highOutliers.isEmpty() && result.lowOutliers.isEmpty()) {
                    formattedMessage += '*   No significant outliers detected for ' + formatMetricName(metric) + '.\n';
                }
                formattedMessage += '\n';
            }
        }

        // 3. Benchmarks (simplified for now)
        formattedMessage += '## Benchmarks\n';
        formattedMessage += '*   **AE Score & Coverage Percentiles:** (Detailed percentiles require raw data for calculation)\n';
        formattedMessage += '    *   Median AE Score: N/A\n';
        formattedMessage += '    *   Median Coverage: N/A\n';
        formattedMessage += '\n';

        // 4. Explainability
        formattedMessage += '## How This Was Computed\n';
        formattedMessage += '*   **Data Source:** `AGENT_OU_PIPELINE_V3__c`\n';
        formattedMessage += '*   **Timeframe Logic:** `CURRENT` = This Fiscal Quarter; `PREVIOUS` = Last Fiscal Quarter.\n';
        if (enableOutliers) {
            formattedMessage += '*   **Outlier Detection:** Used ' + (outlierResults.isEmpty() ? 'N/A' : outlierResults.values()[0].method) + ' method.\n';
        }
        formattedMessage += '*   **Fuzzy Matching:** ' + (request.fuzzySearchEnabled ? 'Enabled' : 'Disabled') + ' for OU and Country names.\n';
        formattedMessage += '\n';

        // 5. Warnings
        if (response.warnings != null && !response.warnings.isEmpty()) {
            formattedMessage += '## Warnings\n';
            for (String warning : response.warnings) {
                formattedMessage += '*   ' + warning + '\n';
            }
            formattedMessage += '\n';
        }

        // 6. TSV Download Link (stub)
        if (response.totalRecordCount > (request.maxResults != null ? request.maxResults : 100)) {
            String tsvLink = 'https://example.com/download/kpi_analysis_' + Datetime.now().format('yyyyMMddHHmmss') + '.tsv';
            formattedMessage += 'For a full dataset, [download the TSV here](' + tsvLink + ').\n';
        }
        
        return formattedMessage;
    }

    /**
     * Format currency amount
     * @param amount Amount to format
     * @return Formatted currency string
     */
    private static String formatCurrency(Decimal amount) {
        if (amount == null) return 'N/A';
        return '$' + amount.setScale(0).format();
    }

    /**
     * Format metric name for display
     * @param metric Metric field name
     * @return Formatted metric name
     */
    private static String formatMetricName(String metric) {
        if (metric == null) return 'N/A';
        return metric.replace('CQ_CUSTOMER_MEETING__c', 'Customer Meetings')
                     .replace('CQ_CALL_CONNECT__c', 'Call Connects')
                     .replace('CQ_ACV__c', 'ACV')
                     .replace('CQ_PG__c', 'PG')
                     .replace('Coverage__c', 'Coverage')
                     .replace('AE_Score__c', 'AE Score');
    }
}