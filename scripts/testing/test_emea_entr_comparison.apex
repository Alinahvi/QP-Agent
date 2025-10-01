/**
 * Test EMEA vs ENTR Comparison
 * Compare Apex KPI Analysis vs Direct SOQL
 * Query: "list all countries in EMEA and compare their avg calls and connects and pipegen for ENTR segmenet"
 */

System.debug('=== TESTING EMEA vs ENTR COMPARISON ===');
System.debug('Query: "list all countries in EMEA and compare their avg calls and connects and pipegen for ENTR segmenet"');

try {
    // PART 1: Test via Apex KPI Analysis Service
    System.debug('\n--- PART 1: APEX KPI ANALYSIS SERVICE ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'CALLS'; // For calls and connects
    request.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request.primaryValue = ''; // Empty to get all countries
    request.comparisonDimension = 'PRIMARY_INDUSTRY';
    request.comparisonValue = 'ENTR'; // Looking for ENTR segment
    request.includeDetails = true;
    
    System.debug('Request: ' + request);
    System.debug('Analysis Type: ' + request.analysisType);
    System.debug('Primary Dimension: ' + request.primaryDimension);
    System.debug('Comparison Dimension: ' + request.comparisonDimension);
    System.debug('Comparison Value: ' + request.comparisonValue);
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request });
    
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Apex Response Success: ' + response.success);
        System.debug('Apex Response Total Records: ' + response.totalRecords);
        System.debug('Apex Response Total Value: ' + response.totalValue);
        System.debug('Apex Response Message: ' + response.message);
        System.debug('Apex Response Insights: ' + response.insights);
        
        if (response.detailedResults != null) {
            System.debug('Apex Detailed Results: ' + response.detailedResults);
        }
    }
    
    // PART 2: Direct SOQL Query - Calls
    System.debug('\n--- PART 2: DIRECT SOQL - CALLS ---');
    
    String callsQuery = 'SELECT WORK_LOCATION_COUNTRY__c, AVG(CQ_CALL_CONNECT__c) avgCalls, COUNT(Id) recordCount ' +
                       'FROM AGENT_OU_PIPELINE_V2__c ' +
                       'WHERE WORK_LOCATION_COUNTRY__c IN (\'United Kingdom\', \'Ireland\', \'France\', \'Germany\', \'Belgium\', \'Finland\', \'Sweden\', \'Spain\', \'Italy\', \'Switzerland\') ' +
                       'AND PRIMARY_INDUSTRY__c = \'ENTR\' ' +
                       'AND CQ_CALL_CONNECT__c != null ' +
                       'GROUP BY WORK_LOCATION_COUNTRY__c ' +
                       'ORDER BY avgCalls DESC';
    
    System.debug('Calls Query: ' + callsQuery);
    
    try {
        List<AggregateResult> callsResults = Database.query(callsQuery);
        System.debug('Direct SOQL Calls Results: ' + callsResults.size() + ' countries found');
        for (AggregateResult result : callsResults) {
            String country = (String) result.get('WORK_LOCATION_COUNTRY__c');
            Decimal avgCalls = (Decimal) result.get('avgCalls');
            Integer recordCount = (Integer) result.get('recordCount');
            System.debug('  Country: ' + country + ', Avg Calls: ' + avgCalls + ', Records: ' + recordCount);
        }
    } catch (Exception e) {
        System.debug('Direct SOQL Calls Error: ' + e.getMessage());
    }
    
    // PART 3: Direct SOQL Query - Pipeline Generation
    System.debug('\n--- PART 3: DIRECT SOQL - PIPELINE GENERATION ---');
    
    String pipelineQuery = 'SELECT WORK_LOCATION_COUNTRY__c, AVG(CQ_PG__c) avgPipeline, COUNT(Id) recordCount ' +
                          'FROM AGENT_OU_PIPELINE_V2__c ' +
                          'WHERE WORK_LOCATION_COUNTRY__c IN (\'United Kingdom\', \'Ireland\', \'France\', \'Germany\', \'Belgium\', \'Finland\', \'Sweden\', \'Spain\', \'Italy\', \'Switzerland\') ' +
                          'AND PRIMARY_INDUSTRY__c = \'ENTR\' ' +
                          'AND CQ_PG__c != null ' +
                          'GROUP BY WORK_LOCATION_COUNTRY__c ' +
                          'ORDER BY avgPipeline DESC';
    
    System.debug('Pipeline Query: ' + pipelineQuery);
    
    try {
        List<AggregateResult> pipelineResults = Database.query(pipelineQuery);
        System.debug('Direct SOQL Pipeline Results: ' + pipelineResults.size() + ' countries found');
        for (AggregateResult result : pipelineResults) {
            String country = (String) result.get('WORK_LOCATION_COUNTRY__c');
            Decimal avgPipeline = (Decimal) result.get('avgPipeline');
            Integer recordCount = (Integer) result.get('recordCount');
            System.debug('  Country: ' + country + ', Avg Pipeline: ' + avgPipeline + ', Records: ' + recordCount);
        }
    } catch (Exception e) {
        System.debug('Direct SOQL Pipeline Error: ' + e.getMessage());
    }
    
    // PART 4: Check what EMEA countries and ENTR segment data actually exists
    System.debug('\n--- PART 4: CHECK ACTUAL DATA AVAILABILITY ---');
    
    // Check EMEA countries
    List<AGENT_OU_PIPELINE_V2__c> emeaCountries = [
        SELECT WORK_LOCATION_COUNTRY__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c IN ('United Kingdom', 'Ireland', 'France', 'Germany', 'Belgium', 'Finland', 'Sweden', 'Spain', 'Italy', 'Switzerland')
        LIMIT 100
    ];
    
    Map<String, Integer> emeaCountryCounts = new Map<String, Integer>();
    for (AGENT_OU_PIPELINE_V2__c record : emeaCountries) {
        String country = record.WORK_LOCATION_COUNTRY__c;
        emeaCountryCounts.put(country, emeaCountryCounts.containsKey(country) ? emeaCountryCounts.get(country) + 1 : 1);
    }
    
    System.debug('EMEA Countries with data:');
    for (String country : emeaCountryCounts.keySet()) {
        System.debug('  ' + country + ': ' + emeaCountryCounts.get(country) + ' records');
    }
    
    // Check ENTR segment
    List<AGENT_OU_PIPELINE_V2__c> entrRecords = [
        SELECT Id
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE PRIMARY_INDUSTRY__c = 'ENTR'
        LIMIT 100
    ];
    
    System.debug('ENTR segment records: ' + entrRecords.size());
    
    // Check what PRIMARY_INDUSTRY values actually exist
    List<AGENT_OU_PIPELINE_V2__c> industrySamples = [
        SELECT PRIMARY_INDUSTRY__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE PRIMARY_INDUSTRY__c != null
        LIMIT 20
    ];
    
    System.debug('Sample PRIMARY_INDUSTRY values:');
    for (AGENT_OU_PIPELINE_V2__c record : industrySamples) {
        System.debug('  ' + record.PRIMARY_INDUSTRY__c);
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== EMEA vs ENTR COMPARISON TEST COMPLETED ==='); 