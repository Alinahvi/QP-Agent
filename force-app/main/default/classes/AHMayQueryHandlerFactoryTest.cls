@isTest
private class AHMayQueryHandlerFactoryTest {

    @isTest
    static void testGetStandardHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'Division__c' => 'Sales'};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayStandardQueryHandler, 'Should return Standard handler.');
    }

    @isTest
    static void testGetDirectReportsHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'DIRECT_REPORTS' => 'John Doe'};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayDirectReportsQueryHandler, 'Should return Direct Reports handler.');
    }

    @isTest
    static void testGetHierarchicalHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'HIERARCHICAL_QUERY' => 'Jane Smith'};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayHierarchicalQueryHandler, 'Should return Hierarchical handler.');
    }
    
    @isTest
    static void testGetHierarchicalHandlerFromPhrase() {
        Map<String, Object> queryData = new Map<String, Object>{
            'ORIGINAL_QUERY' => 'show me everyone who rolls up to Jane Smith',
            'DIRECT_REPORTS' => 'Jane Smith'
        };
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayHierarchicalQueryHandler, 'Should return Hierarchical handler based on phrase detection.');
    }

    @isTest
    static void testGetEmployeeDetailsHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'EMPLOYEE_DETAILS' => 'Bob Johnson'};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayEmployeeDetailsQueryHandler, 'Should return Employee Details handler.');
    }

    @isTest
    static void testGetMetadataHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'METADATA_REQUEST' => 'FIELD_VALUES'};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayMetadataQueryHandler, 'Should return Metadata handler.');
    }

    @isTest
    static void testGetAggregationHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'AGGREGATION' => true};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayAggregationHandler, 'Should return Aggregation handler.');
        
        queryData = new Map<String, Object>{'GROUP_BY_FIELD' => 'Division__c'};
        handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayAggregationHandler, 'Should return Aggregation handler for GROUP_BY_FIELD.');
    }
    
    @isTest
    static void testGetOrConditionHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'Division__c_OR' => new List<String>{'Sales', 'Marketing'}};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayOrConditionQueryHandler, 'Should return Or Condition handler.');
    }

    @isTest
    static void testGetCompoundQueryHandler() {
        Map<String, Object> queryData = new Map<String, Object>{
            'DIRECT_REPORTS' => 'John Doe',
            'AGGREGATION' => true
        };
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayCompoundQueryHandler, 'Should return Compound Query handler.');
    }

    @isTest
    static void testGetUnsupportedHandler() {
        Map<String, Object> queryData = new Map<String, Object>{'UNSUPPORTED_QUERY' => 'some unsupported text'};
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
        System.assert(handler instanceof AHMayUnsupportedQueryHandler, 'Should return Unsupported handler.');
    }
    
    @isTest
    static void testEmptyQueryData() {
        AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(new Map<String, Object>());
        System.assert(handler instanceof AHMayStandardQueryHandler, 'Should default to Standard handler for empty data.');
    }
}