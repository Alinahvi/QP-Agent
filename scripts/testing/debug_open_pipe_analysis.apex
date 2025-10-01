// Debug script for Open Pipe Analysis
System.debug('🔍 DEBUGGING OPEN PIPE ANALYSIS');

// Check if the object exists
try {
    Schema.SObjectType objType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
    if (objType != null) {
        System.debug('✅ AGENT_OU_PIPELINE_V2__c object exists');
        
        // Check field accessibility
        Schema.DescribeSObjectResult objDesc = objType.getDescribe();
        System.debug('Object Label: ' + objDesc.getLabel());
        System.debug('Object Name: ' + objDesc.getName());
        System.debug('Is Accessible: ' + objDesc.isAccessible());
        System.debug('Is Createable: ' + objDesc.isCreateable());
        System.debug('Is Updateable: ' + objDesc.isUpdateable());
        
        // Check specific fields
        List<String> fieldsToCheck = new List<String>{
            'OPEN_PIPE_PROD_NM_1__c',
            'OPEN_PIPE_APM_L2_1__c',
            'OPEN_PIPE_OPTY_NM_1__c',
            'OPEN_PIPE_OPTY_STG_NM_1__c',
            'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c',
            'OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c'
        };
        
        for (String fieldName : fieldsToCheck) {
            try {
                Schema.SObjectField field = objDesc.fields.getMap().get(fieldName);
                if (field != null) {
                    Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                    System.debug('✅ Field ' + fieldName + ' exists - Type: ' + fieldDesc.getType() + ', Accessible: ' + fieldDesc.isAccessible());
                } else {
                    System.debug('❌ Field ' + fieldName + ' does not exist');
                }
            } catch (Exception e) {
                System.debug('❌ Error checking field ' + fieldName + ': ' + e.getMessage());
            }
        }
        
    } else {
        System.debug('❌ AGENT_OU_PIPELINE_V2__c object does not exist');
    }
} catch (Exception e) {
    System.debug('❌ Error checking object: ' + e.getMessage());
}

// Check if there are any records
try {
    Integer recordCount = Database.countQuery('SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c');
    System.debug('📊 Total records in AGENT_OU_PIPELINE_V2__c: ' + recordCount);
    
    if (recordCount > 0) {
        // Check a sample record
        List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
            SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c
            FROM AGENT_OU_PIPELINE_V2__c 
            LIMIT 3
        ];
        
        System.debug('📋 Sample records:');
        for (AGENT_OU_PIPELINE_V2__c record : sampleRecords) {
            System.debug('Record ID: ' + record.Id + ', OU: ' + record.OU_NAME__c + ', Industry: ' + record.PRIMARY_INDUSTRY__c);
        }
    }
} catch (Exception e) {
    System.debug('❌ Error checking records: ' + e.getMessage());
}

// Test the service directly
try {
    System.debug('🧪 Testing Open Pipe Analysis Service...');
    
    ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCT_BY_STAGE';
    request.operatingUnit = 'AMER ICE';
    
    ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response = 
        ANAgentOpenPipeAnalysisService.analyzeOpenPipe(request);
    
    System.debug('Service Response:');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Analysis Type: ' + response.analysisType);
    System.debug('Total Records: ' + response.totalRecords);
    System.debug('Summary: ' + response.summary);
    
} catch (Exception e) {
    System.debug('❌ Error testing service: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🔍 DEBUG COMPLETE'); 