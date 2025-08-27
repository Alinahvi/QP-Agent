/**
 * Debug script to investigate KPI breakdown issues
 * Specifically looking at customer meetings by country
 */

System.debug('=== DEBUGGING KPI BREAKDOWN ISSUE ===');

// First, let's see what's actually in the data for customer meetings by country
System.debug('\n--- DIRECT SOQL QUERY FOR CUSTOMER MEETINGS BY COUNTRY ---');
try {
    String query = 'SELECT WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c, PQ_CUSTOMER_MEETING__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE IsDeleted = false ' +
                   'AND WORK_LOCATION_COUNTRY__c != null ' +
                   'AND (CQ_CUSTOMER_MEETING__c > 0 OR PQ_CUSTOMER_MEETING__c > 0) ' +
                   'ORDER BY WORK_LOCATION_COUNTRY__c';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Total records found: ' + records.size());
    
    // Group by country and calculate totals
    Map<String, Decimal> countryMeetings = new Map<String, Decimal>();
    Map<String, Integer> countryCounts = new Map<String, Integer>();
    
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        String country = record.WORK_LOCATION_COUNTRY__c;
        Decimal currentMeetings = record.CQ_CUSTOMER_MEETING__c != null ? record.CQ_CUSTOMER_MEETING__c : 0;
        Decimal previousMeetings = record.PQ_CUSTOMER_MEETING__c != null ? record.PQ_CUSTOMER_MEETING__c : 0;
        Decimal totalMeetings = currentMeetings + previousMeetings;
        
        if (totalMeetings > 0) {
            if (countryMeetings.containsKey(country)) {
                countryMeetings.put(country, countryMeetings.get(country) + totalMeetings);
                countryCounts.put(country, countryCounts.get(country) + 1);
            } else {
                countryMeetings.put(country, totalMeetings);
                countryCounts.put(country, 1);
            }
        }
    }
    
    System.debug('\n--- COUNTRY BREAKDOWN (TOTAL MEETINGS) ---');
    for (String country : countryMeetings.keySet()) {
        Decimal total = countryMeetings.get(country);
        Integer count = countryCounts.get(country);
        Decimal average = count > 0 ? total / count : 0;
        System.debug(country + ': Total=' + total + ', Count=' + count + ', Average=' + average.setScale(2));
    }
    
    // Now let's test the actual KPI Analysis service
    System.debug('\n--- TESTING KPI ANALYSIS SERVICE FOR MEETINGS ---');
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request.primaryValue = null; // No specific country filter
    request.timeFrame = 'CURRENT';
    request.maxResults = 1000;
    request.includeDetails = true;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response = 
        ANAgentKPIAnalysisService.analyzeKPIs(request);
    
    System.debug('Service Response Success: ' + response.success);
    System.debug('Service Response Message: ' + response.message);
    System.debug('Service Response Total Records: ' + response.totalRecords);
    System.debug('Service Response Total Value: ' + response.totalValue);
    System.debug('Service Response Average Value: ' + response.averageValue);
    
    if (response.breakdownByDimension != null) {
        System.debug('\n--- SERVICE BREAKDOWN BY DIMENSION ---');
        for (String dimension : response.breakdownByDimension.keySet()) {
            Decimal value = response.breakdownByDimension.get(dimension);
            System.debug(dimension + ': ' + value);
        }
    }
    
    // Let's also test the handler
    System.debug('\n--- TESTING KPI ANALYSIS HANDLER ---');
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest handlerRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    handlerRequest.analysisType = 'MEETINGS';
    handlerRequest.primaryDimension = 'WORK_LOCATION_COUNTRY';
    handlerRequest.primaryValue = null;
    handlerRequest.timeFrame = 'CURRENT';
    handlerRequest.maxResults = 1000;
    handlerRequest.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> handlerResponses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ handlerRequest });
    
    if (!handlerResponses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse handlerResponse = handlerResponses[0];
        System.debug('Handler Response Success: ' + handlerResponse.success);
        System.debug('Handler Response Message: ' + handlerResponse.message);
        System.debug('Handler Response Total Records: ' + handlerResponse.totalRecords);
        System.debug('Handler Response Total Value: ' + handlerResponse.totalValue);
        System.debug('Handler Response Average Value: ' + handlerResponse.averageValue);
        System.debug('Handler Response Breakdown Summary: ' + handlerResponse.breakdownSummary);
    }
    
} catch (Exception e) {
    System.debug('Error in debug script: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== DEBUGGING COMPLETED ==='); 