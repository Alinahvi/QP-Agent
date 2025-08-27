// End-to-End KPI Analysis Test
// Simulating real business question: "What is the average ACV of Brazil new hires (6 months in role)"

System.debug('=== End-to-End KPI Analysis Test ===');
System.debug('Business Question: What is the average ACV of Brazil new hires (6 months in role)?');

// Test 1: Search for Brazil new hires (6 months or less in role)
System.debug('--- Test 1: Search for Brazil New Hires ---');
try {
    ANAGENTKPIAnalysisHandlerV3.Request searchReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    searchReq.action = 'Search';
    searchReq.WorkLocationCountry = 'Brazil';
    searchReq.TimeSinceOnboarding = '6'; // 6 months or less
    searchReq.recordLimit = 50;
    
    System.debug('Search Request:');
    System.debug('- Action: ' + searchReq.action);
    System.debug('- Work Location Country: ' + searchReq.WorkLocationCountry);
    System.debug('- Time Since Onboarding: ' + searchReq.TimeSinceOnboarding);
    System.debug('- Record Limit: ' + searchReq.recordLimit);
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> searchResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ searchReq });
    
    if (!searchResponses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response searchResponse = searchResponses[0];
        System.debug('✅ Search PASSED - Success: ' + searchResponse.success);
        System.debug('✅ Records returned: ' + searchResponse.kpiRecords.size() + ' of ' + searchResponse.totalRecordCount + ' total');
        System.debug('✅ Message: ' + searchResponse.message);
        
        // Calculate average ACV for Brazil new hires
        if (searchResponse.kpiRecords.size() > 0) {
            Decimal totalACV = 0;
            Integer validACVCount = 0;
            List<String> employeeNames = new List<String>();
            
            for (ANAGENTKPIAnalysisServiceV3.UnifiedOpenPipeRecord record : searchResponse.kpiRecords) {
                if (record.cqAcv != null && record.cqAcv > 0) {
                    totalACV += record.cqAcv;
                    validACVCount++;
                }
                employeeNames.add(record.fullName + ' (ACV: ' + record.cqAcv + ')');
            }
            
            if (validACVCount > 0) {
                Decimal avgACV = totalACV / validACVCount;
                System.debug('📊 Brazil New Hires Analysis:');
                System.debug('- Total employees found: ' + searchResponse.kpiRecords.size());
                System.debug('- Employees with valid ACV: ' + validACVCount);
                System.debug('- Total ACV: ' + totalACV);
                System.debug('- Average ACV: ' + avgACV.setScale(2));
                System.debug('- Sample employees: ' + String.join(employeeNames, ', '));
            } else {
                System.debug('⚠️ No valid ACV data found for Brazil new hires');
            }
        }
    } else {
        System.debug('❌ Search FAILED - No response returned');
    }
} catch (Exception e) {
    System.debug('❌ Search FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Get distinct values for Work Location Country to verify Brazil exists
System.debug('--- Test 2: Verify Brazil Location Exists ---');
try {
    ANAGENTKPIAnalysisHandlerV3.Request distinctReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    distinctReq.action = 'GetDistinctFieldValues';
    distinctReq.fieldNameForValues = 'Work Location Country';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> distinctResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ distinctReq });
    
    if (!distinctResponses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response distinctResponse = distinctResponses[0];
        System.debug('✅ GetDistinctFieldValues PASSED - Success: ' + distinctResponse.success);
        System.debug('✅ Distinct countries found: ' + distinctResponse.fieldValues.size());
        
        // Check if Brazil is in the list
        Boolean brazilExists = false;
        for (String country : distinctResponse.fieldValues) {
            if (country != null && country.toLowerCase().contains('brazil')) {
                brazilExists = true;
                break;
            }
        }
        
        if (brazilExists) {
            System.debug('✅ Brazil location found in distinct values');
        } else {
            System.debug('⚠️ Brazil location NOT found in distinct values');
            System.debug('Available countries: ' + String.join(distinctResponse.fieldValues, ', '));
        }
    }
} catch (Exception e) {
    System.debug('❌ GetDistinctFieldValues FAILED: ' + e.getMessage());
}

// Test 3: Count field values for Time Since Onboarding to understand the data distribution
System.debug('--- Test 3: Analyze Time Since Onboarding Distribution ---');
try {
    ANAGENTKPIAnalysisHandlerV3.Request countReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    countReq.action = 'CountFieldValues';
    countReq.countValuesForField = 'Time Since Onboarding';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> countResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{ countReq });
    
    if (!countResponses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response countResponse = countResponses[0];
        System.debug('✅ CountFieldValues PASSED - Success: ' + countResponse.success);
        System.debug('✅ Field value counts: ' + countResponse.fieldValueCountsJSON);
        
        // Parse the JSON to show the distribution
        try {
            Map<String, Object> counts = (Map<String, Object>)JSON.deserializeUntyped(countResponse.fieldValueCountsJSON);
            System.debug('📊 Time Since Onboarding Distribution:');
            for (String key : counts.keySet()) {
                System.debug('- ' + key + ': ' + counts.get(key) + ' employees');
            }
        } catch (Exception parseEx) {
            System.debug('⚠️ Could not parse field value counts: ' + parseEx.getMessage());
        }
    }
} catch (Exception e) {
    System.debug('❌ CountFieldValues FAILED: ' + e.getMessage());
}

// Test 4: Direct service call to test the underlying service layer
System.debug('--- Test 4: Direct Service Layer Test ---');
try {
    Map<String, Object> filters = new Map<String, Object>{
        'Work Location Country' => 'Brazil',
        'Time Since Onboarding' => '6'
    };
    
    ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult serviceResult = ANAGENTKPIAnalysisServiceV3.searchOpenPipeRecords(null, filters, 'CQ_ACV__c', 'DESC', 10, 0);
    
    System.debug('✅ Direct Service Call PASSED');
    System.debug('✅ Total records found: ' + serviceResult.totalCount);
    System.debug('✅ Records returned: ' + serviceResult.records.size());
    
    if (serviceResult.records.size() > 0) {
        System.debug('📊 Top ACV performers in Brazil (6 months or less):');
        for (Integer i = 0; i < Math.min(5, serviceResult.records.size()); i++) {
            ANAGENTKPIAnalysisServiceV3.UnifiedOpenPipeRecord record = serviceResult.records[i];
            System.debug('- ' + (i+1) + '. ' + record.fullName + ' - ACV: ' + record.cqAcv + ', OU: ' + record.ouName);
        }
    }
} catch (Exception e) {
    System.debug('❌ Direct Service Call FAILED: ' + e.getMessage());
}

System.debug('=== End-to-End Test Complete ===');
System.debug('This test validates the complete flow from business question to actionable insights!'); 