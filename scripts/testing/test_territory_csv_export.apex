// Test script for Territory Analysis CSV Export
// This script demonstrates the CSV export functionality

// Create a test request
ANAgentAETerritoryAnalysisService.TerritoryAnalysisRequest request = new ANAgentAETerritoryAnalysisService.TerritoryAnalysisRequest();
request.analysisType = 'TERRITORY_KPIS';
request.operatingUnit = 'AMER ICE';
request.generateCSV = true;
request.maxResults = 10;

System.debug('=== TERRITORY ANALYSIS CSV EXPORT TEST ===');
System.debug('Request: ' + request);

// Execute the analysis
ANAgentAETerritoryAnalysisService.TerritoryAnalysisResponse response = 
    ANAgentAETerritoryAnalysisService.analyzeTerritory(request);

// Display results
System.debug('=== RESULTS ===');
System.debug('Success: ' + response.success);
System.debug('Message: ' + response.message);
System.debug('Total Records: ' + response.totalRecords);
System.debug('CSV Data Length: ' + (response.csvData != null ? response.csvData.length() : 0));

// Display sample CSV data
if (response.csvData != null && response.csvData.length() > 0) {
    List<String> lines = response.csvData.split('\n');
    System.debug('=== CSV SAMPLE ===');
    System.debug('Total Lines: ' + lines.size());
    
    if (lines.size() > 0) {
        System.debug('Header: ' + lines[0]);
    }
    
    if (lines.size() > 1) {
        System.debug('First Data Row: ' + lines[1]);
    }
    
    if (lines.size() > 2) {
        System.debug('Second Data Row: ' + lines[2]);
    }
}

System.debug('=== TEST COMPLETE ==='); 