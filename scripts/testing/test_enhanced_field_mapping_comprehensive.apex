// Comprehensive test script for enhanced field mapping functionality
// This tests all the improvements: new aliases, smart detection, validation methods

System.debug('=== COMPREHENSIVE TEST: Enhanced Field Mapping ===\n');

// Test Case 1: Test New Business Context Aliases
System.debug('=== Test Case 1: Test New Business Context Aliases ===');

// Test geographic/demographic aliases
List<String> geographicAliases = new List<String>{
    'location=\'US\'',
    'region=\'US\'',
    'geo=\'US\'',
    'territory=\'US\''
};

for (String alias : geographicAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('work_location_country__c')) {
            System.debug('  ✅ SUCCESS: Geographic alias working');
        } else {
            System.debug('  ❌ FAILED: Geographic alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test operating unit aliases
List<String> ouAliases = new List<String>{
    'operating_unit=\'AMER\'',
    'unit=\'AMER\'',
    'division=\'AMER\'',
    'segment=\'AMER\'',
    'business_unit=\'AMER\''
};

for (String alias : ouAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('ou_name__c')) {
            System.debug('  ✅ SUCCESS: OU alias working');
        } else {
            System.debug('  ❌ FAILED: OU alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test industry aliases
List<String> industryAliases = new List<String>{
    'sector=\'Tech\'',
    'vertical=\'Tech\'',
    'business_type=\'Tech\'',
    'market=\'Tech\''
};

for (String alias : industryAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('primary_industry__c')) {
            System.debug('  ✅ SUCCESS: Industry alias working');
        } else {
            System.debug('  ❌ FAILED: Industry alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test employee/AE aliases
List<String> employeeAliases = new List<String>{
    'employee=\'John Doe\'',
    'rep=\'John Doe\'',
    'salesperson=\'John Doe\'',
    'seller=\'John Doe\'',
    'name=\'John Doe\'',
    'person=\'John Doe\''
};

for (String alias : employeeAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('full_name__c')) {
            System.debug('  ✅ SUCCESS: Employee alias working');
        } else {
            System.debug('  ❌ FAILED: Employee alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test manager aliases
List<String> managerAliases = new List<String>{
    'supervisor=\'Jane Manager\'',
    'boss=\'Jane Manager\'',
    'lead=\'Jane Manager\'',
    'director=\'Jane Manager\''
};

for (String alias : managerAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('emp_mgr_nm__c')) {
            System.debug('  ✅ SUCCESS: Manager alias working');
        } else {
            System.debug('  ❌ FAILED: Manager alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test contact aliases
List<String> contactAliases = new List<String>{
    'contact=\'test@example.com\'',
    'address=\'test@example.com\'',
    'communication=\'test@example.com\''
};

for (String alias : contactAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('emp_email_addr__c')) {
            System.debug('  ✅ SUCCESS: Contact alias working');
        } else {
            System.debug('  ❌ FAILED: Contact alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test learning aliases
List<String> learningAliases = new List<String>{
    'learning=\'profile123\'',
    'enablement=\'profile123\'',
    'training=\'profile123\'',
    'profile=\'profile123\'',
    'education=\'profile123\''
};

for (String alias : learningAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('learner_profile_id__c')) {
            System.debug('  ✅ SUCCESS: Learning alias working');
        } else {
            System.debug('  ❌ FAILED: Learning alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test growth factor aliases
List<String> growthFactorAliases = new List<String>{
    'growth_area=\'Deal Size\'',
    'improvement_area=\'Deal Size\'',
    'development_focus=\'Deal Size\''
};

for (String alias : growthFactorAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('definition__c')) {
            System.debug('  ✅ SUCCESS: Growth Factor alias working');
        } else {
            System.debug('  ❌ FAILED: Growth Factor alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test description aliases
List<String> descriptionAliases = new List<String>{
    'explanation=\'test\'',
    'details=\'test\'',
    'meaning=\'test\'',
    'desc=\'test\''
};

for (String alias : descriptionAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('description__c')) {
            System.debug('  ✅ SUCCESS: Description alias working');
        } else {
            System.debug('  ❌ FAILED: Description alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test ramp status aliases
List<String> rampStatusAliases = new List<String>{
    'onboarding_status=\'Fast Ramper\'',
    'performance_status=\'Fast Ramper\'',
    'ramp_level=\'Fast Ramper\'',
    'ramp_category=\'Fast Ramper\''
};

for (String alias : rampStatusAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('ramp_status__c')) {
            System.debug('  ✅ SUCCESS: Ramp Status alias working');
        } else {
            System.debug('  ❌ FAILED: Ramp Status alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test tenure aliases
List<String> tenureAliases = new List<String>{
    'experience=\'6\'',
    'months_at_company=\'6\'',
    'time_in_role=\'6\'',
    'seniority=\'6\'',
    'years_of_service=\'6\''
};

for (String alias : tenureAliases) {
    System.debug('Testing: ' + alias);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(alias);
        System.debug('  Result: ' + result);
        if (result.contains('time_since_onboarding__c')) {
            System.debug('  ✅ SUCCESS: Tenure alias working');
        } else {
            System.debug('  ❌ FAILED: Tenure alias not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test Case 2: Test Enhanced API Field Variations
System.debug('\n=== Test Case 2: Test Enhanced API Field Variations ===');

// Test new API field variations
List<String> newApiVariations = new List<String>{
    'RAMPSTATUS__C=\'Fast Ramper\'',
    'OUNAME__C=\'AMER\'',
    'WORKLOCATIONCOUNTRY__C=\'US\'',
    'PRIMARYINDUSTRY__C=\'Tech\'',
    'FULLNAME__C=\'John Doe\'',
    'EMPMGRNM__C=\'Jane Manager\'',
    'EMPEMAILADDR__C=\'test@example.com\'',
    'LEARNERPROFILEID__C=\'profile123\'',
    'DEF__C=\'Deal Size\'',
    'DESC__C=\'test\'',
    'TIMESINCEONBOARDING__C=\'6\'',
    'TENURE__C=\'6\'',
    'ONBOARDING__C=\'6\''
};

for (String variation : newApiVariations) {
    System.debug('Testing: ' + variation);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(variation);
        System.debug('  Result: ' + result);
        if (result.contains('__c')) {
            System.debug('  ✅ SUCCESS: API variation working');
        } else {
            System.debug('  ❌ FAILED: API variation not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test Case 3: Test Smart Field Detection
System.debug('\n=== Test Case 3: Test Smart Field Detection ===');

// Test creative field names that should be detected by smart logic
List<String> creativeFieldNames = new List<String>{
    'nation=\'US\'',
    'business_unit=\'AMER\'',
    'market=\'Tech\'',
    'person=\'John Doe\'',
    'director=\'Jane Manager\'',
    'communication=\'test@example.com\'',
    'education=\'profile123\'',
    'focus=\'Deal Size\'',
    'meaning=\'test\'',
    'category=\'Fast Ramper\'',
    'service=\'6\''
};

for (String creativeField : creativeFieldNames) {
    System.debug('Testing: ' + creativeField);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(creativeField);
        System.debug('  Result: ' + result);
        if (result.contains('__c')) {
            System.debug('  ✅ SUCCESS: Smart detection working');
        } else {
            System.debug('  ❌ FAILED: Smart detection not working');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test Case 4: Test Complex Business Scenarios
System.debug('\n=== Test Case 4: Test Complex Business Scenarios ===');

List<String> complexScenarios = new List<String>{
    'location=\'US\' AND operating_unit=\'AMER\' AND sector=\'Tech\'',
    'employee=\'John Doe\' AND supervisor=\'Jane Manager\' AND experience=\'6\'',
    'nation=\'US\' AND business_unit=\'AMER\' AND market=\'Tech\' AND person=\'John Doe\'',
    'geo=\'US\' AND division=\'AMER\' AND vertical=\'Tech\' AND rep=\'John Doe\' AND boss=\'Jane Manager\'',
    'territory=\'US\' AND segment=\'AMER\' AND business_type=\'Tech\' AND salesperson=\'John Doe\' AND lead=\'Jane Manager\''
};

for (String scenario : complexScenarios) {
    System.debug('Testing: ' + scenario);
    try {
        String result = ANAGENTKPIAnalysisServiceV5.parseFilterCriteria(scenario);
        System.debug('  Result: ' + result);
        
        // Count how many fields were successfully mapped
        Integer mappedFields = 0;
        if (result.contains('work_location_country__c')) mappedFields++;
        if (result.contains('ou_name__c')) mappedFields++;
        if (result.contains('primary_industry__c')) mappedFields++;
        if (result.contains('full_name__c')) mappedFields++;
        if (result.contains('emp_mgr_nm__c')) mappedFields++;
        if (result.contains('time_since_onboarding__c')) mappedFields++;
        
        System.debug('  Mapped Fields: ' + mappedFields + '/6');
        if (mappedFields >= 4) {
            System.debug('  ✅ SUCCESS: Complex scenario working well');
        } else if (mappedFields >= 2) {
            System.debug('  ⚠️ PARTIAL: Some fields mapped');
        } else {
            System.debug('  ❌ FAILED: Most fields not mapped');
        }
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

// Test Case 5: Test Field Mapping Info and Validation
System.debug('\n=== Test Case 5: Test Field Mapping Info and Validation ===');

try {
    // Test getFieldMappingInfo method
    Map<String, Object> mappingInfo = ANAGENTKPIAnalysisServiceV5.getFieldMappingInfo();
    System.debug('✅ getFieldMappingInfo working');
    System.debug('User-friendly aliases: ' + ((Map<String, String>)mappingInfo.get('userFriendlyAliases')).size());
    System.debug('API field variations: ' + ((Map<String, String>)mappingInfo.get('apiFieldVariations')).size());
    System.debug('Final SOQL fields: ' + ((Set<String>)mappingInfo.get('finalSOQLFields')).size());
    System.debug('Business context patterns: ' + ((Map<String, List<String>>)mappingInfo.get('businessContextPatterns')).size());
    
    // Test validateFieldMapping method
    String testFilter = 'location=\'US\' AND operating_unit=\'AMER\'';
    Map<String, Object> validation = ANAGENTKPIAnalysisServiceV5.validateFieldMapping(testFilter);
    System.debug('✅ validateFieldMapping working');
    System.debug('Original: ' + validation.get('originalFilter'));
    System.debug('Mapped: ' + validation.get('mappedFilter'));
    System.debug('Successfully mapped: ' + validation.get('successfullyMapped'));
    System.debug('Unmapped fields: ' + validation.get('unmappedFields'));
    System.debug('Mapping issues: ' + validation.get('mappingIssues'));
    
} catch (Exception e) {
    System.debug('❌ Field mapping info/validation failed: ' + e.getMessage());
}

// Test Case 6: Test End-to-End Service Integration
System.debug('\n=== Test Case 6: Test End-to-End Service Integration ===');

List<String> endToEndTests = new List<String>{
    'location=\'US\' AND experience=\'6\'',
    'operating_unit=\'AMER\' AND sector=\'Tech\'',
    'nation=\'US\' AND business_unit=\'AMER\' AND market=\'Tech\'',
    'geo=\'US\' AND division=\'AMER\' AND vertical=\'Tech\' AND person=\'John Doe\''
};

for (String testFilter : endToEndTests) {
    System.debug('Testing end-to-end: ' + testFilter);
    
    try {
        // Create a request
        ANAGENTKPIAnalysisHandlerV5.Request req = new ANAGENTKPIAnalysisHandlerV5.Request();
        req.metricKey = 'CALLS';
        req.timeframe = 'CURRENT';
        req.groupBy = 'COUNTRY';
        req.filterCriteria = testFilter;
        req.perAENormalize = false;
        req.limitN = 5;
        
        // Call the handler
        List<ANAGENTKPIAnalysisHandlerV5.Request> requests = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req};
        List<ANAGENTKPIAnalysisHandlerV5.Response> responses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests);
        
        if (responses != null && !responses.isEmpty()) {
            String message = responses[0].message;
            if (message.contains('Invalid') || message.contains('error')) {
                System.debug('  ❌ FAILED: ' + message.substring(0, Math.min(100, message.length())));
            } else {
                System.debug('  ✅ SUCCESS: End-to-end working');
                if (message.contains('Total Records Found: 0')) {
                    System.debug('    Note: No records found (might be expected)');
                } else {
                    System.debug('    Note: Records found - analysis successful');
                }
            }
        } else {
            System.debug('  ❌ FAILED: No response');
        }
        
    } catch (Exception e) {
        System.debug('  ❌ FAILED: Exception - ' + e.getMessage());
    }
}

System.debug('\n=== ENHANCED FIELD MAPPING TEST COMPLETE ===');
System.debug('This test verified all the new field mapping enhancements:');
System.debug('✅ New business context aliases');
System.debug('✅ Enhanced API field variations');
System.debug('✅ Smart field detection');
System.debug('✅ Complex business scenarios');
System.debug('✅ Field mapping info and validation methods');
System.debug('✅ End-to-end service integration');
System.debug('If all tests passed, the enhanced field mapping is working perfectly!'); 