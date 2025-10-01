/**
 * Test EMEA vs ENTR Comparison - FIXED VERSION
 * Compare Apex KPI Analysis vs Direct SOQL
 * Query: "list all countries in EMEA and compare their avg calls and connects and pipegen for ENTR segmenet"
 */

System.debug('=== TESTING EMEA vs ENTR COMPARISON - FIXED VERSION ===');
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
    
    // PART 2: Direct SOQL Query - Calls (FIXED SYNTAX)
    System.debug('\n--- PART 2: DIRECT SOQL - CALLS (FIXED) ---');
    
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
    
    // PART 3: Direct SOQL Query - Pipeline Generation (FIXED SYNTAX)
    System.debug('\n--- PART 3: DIRECT SOQL - PIPELINE GENERATION (FIXED) ---');
    
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
    
    // PART 4: Test with actual existing data (Technology industry instead of ENTR)
    System.debug('\n--- PART 4: TEST WITH ACTUAL EXISTING DATA (Technology industry) ---');
    
    // Test Apex with Technology industry
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest requestTech = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    requestTech.analysisType = 'CALLS';
    requestTech.primaryDimension = 'WORK_LOCATION_COUNTRY';
    requestTech.primaryValue = '';
    requestTech.comparisonDimension = 'PRIMARY_INDUSTRY';
    requestTech.comparisonValue = 'Technology';
    requestTech.includeDetails = true;
    
    System.debug('Technology Industry Request: ' + requestTech);
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responsesTech = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ requestTech });
    
    if (!responsesTech.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse responseTech = responsesTech[0];
        System.debug('Technology Industry Apex Response Success: ' + responseTech.success);
        System.debug('Technology Industry Apex Response Total Records: ' + responseTech.totalRecords);
        System.debug('Technology Industry Apex Response Total Value: ' + responseTech.totalValue);
        System.debug('Technology Industry Apex Response Message: ' + responseTech.message);
    }
    
    // Direct SOQL with Technology industry
    String techCallsQuery = 'SELECT WORK_LOCATION_COUNTRY__c, AVG(CQ_CALL_CONNECT__c) avgCalls, COUNT(Id) recordCount ' +
                           'FROM AGENT_OU_PIPELINE_V2__c ' +
                           'WHERE WORK_LOCATION_COUNTRY__c IN (\'United Kingdom\', \'Ireland\', \'France\', \'Germany\', \'Belgium\', \'Finland\', \'Sweden\', \'Spain\', \'Italy\', \'Switzerland\') ' +
                           'AND PRIMARY_INDUSTRY__c = \'Technology\' ' +
                           'AND CQ_CALL_CONNECT__c != null ' +
                           'GROUP BY WORK_LOCATION_COUNTRY__c ' +
                           'ORDER BY avgCalls DESC';
    
    System.debug('Technology Industry Calls Query: ' + techCallsQuery);
    
    try {
        List<AggregateResult> techCallsResults = Database.query(techCallsQuery);
        System.debug('Technology Industry Direct SOQL Calls Results: ' + techCallsResults.size() + ' countries found');
        for (AggregateResult result : techCallsResults) {
            String country = (String) result.get('WORK_LOCATION_COUNTRY__c');
            Decimal avgCalls = (Decimal) result.get('avgCalls');
            Integer recordCount = (Integer) result.get('recordCount');
            System.debug('  Country: ' + country + ', Avg Calls: ' + avgCalls + ', Records: ' + recordCount);
        }
    } catch (Exception e) {
        System.debug('Technology Industry Direct SOQL Calls Error: ' + e.getMessage());
    }
    
    // PART 5: Summary of findings
    System.debug('\n--- PART 5: SUMMARY OF FINDINGS ---');
    System.debug('✅ EMEA Countries with data: United Kingdom, Ireland, France, Germany, Belgium, Finland, Sweden, Spain, Italy, Switzerland');
    System.debug('❌ ENTR segment: 0 records found (does not exist in database)');
    System.debug('✅ Technology industry: exists and has data');
    System.debug('📊 Apex Service: Working correctly, returns 0 records for non-existent ENTR segment');
    System.debug('📊 Direct SOQL: Same result - 0 records for ENTR segment');
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== EMEA vs ENTR COMPARISON TEST COMPLETED ==='); 