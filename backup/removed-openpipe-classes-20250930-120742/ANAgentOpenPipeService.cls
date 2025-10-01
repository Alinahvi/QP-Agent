public with sharing class ANAgentOpenPipeService {
    
    public class OpenPipeInfo {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String employeeId { get; set; }
        @AuraEnabled public String employeeEmail { get; set; }
        @AuraEnabled public String positionWorkerEmail { get; set; }
        @AuraEnabled public String roleLevel4 { get; set; }
        @AuraEnabled public String roleLevel5 { get; set; }
        @AuraEnabled public String roleLevel6 { get; set; }
        @AuraEnabled public String macroSegment { get; set; }
        @AuraEnabled public String formattedVertical { get; set; }
        @AuraEnabled public String employeeLocationCountry { get; set; }
        @AuraEnabled public Boolean isAE { get; set; }
        @AuraEnabled public String simpleSegment { get; set; }
        @AuraEnabled public String employeeLocationRegion { get; set; }
        @AuraEnabled public String employeePccRegion { get; set; }
        @AuraEnabled public Double tenureAtSalesforceMonths { get; set; }
        @AuraEnabled public Double tenureInRoleMonths { get; set; }
        @AuraEnabled public String productL2 { get; set; }
        @AuraEnabled public Double value { get; set; }
        @AuraEnabled public String forecastType { get; set; }
        @AuraEnabled public Double rank { get; set; }
        @AuraEnabled public Datetime createdDate { get; set; }
        @AuraEnabled public Datetime lastModifiedDate { get; set; }
        
        public OpenPipeInfo() {}
        
        public OpenPipeInfo(String id, String name, String employeeId, String employeeEmail, 
                           String positionWorkerEmail, String roleLevel4, String roleLevel5, 
                           String roleLevel6, String macroSegment, String formattedVertical,
                           String employeeLocationCountry, Boolean isAE, String simpleSegment,
                           String employeeLocationRegion, String employeePccRegion,
                           Double tenureAtSalesforceMonths, Double tenureInRoleMonths,
                           String productL2, Double value, String forecastType, Double rank,
                           Datetime createdDate, Datetime lastModifiedDate) {
            this.id = id;
            this.name = name;
            this.employeeId = employeeId;
            this.employeeEmail = employeeEmail;
            this.positionWorkerEmail = positionWorkerEmail;
            this.roleLevel4 = roleLevel4;
            this.roleLevel5 = roleLevel5;
            this.roleLevel6 = roleLevel6;
            this.macroSegment = macroSegment;
            this.formattedVertical = formattedVertical;
            this.employeeLocationCountry = employeeLocationCountry;
            this.isAE = isAE;
            this.simpleSegment = simpleSegment;
            this.employeeLocationRegion = employeeLocationRegion;
            this.employeePccRegion = employeePccRegion;
            this.tenureAtSalesforceMonths = tenureAtSalesforceMonths;
            this.tenureInRoleMonths = tenureInRoleMonths;
            this.productL2 = productL2;
            this.value = value;
            this.forecastType = forecastType;
            this.rank = rank;
            this.createdDate = createdDate;
            this.lastModifiedDate = lastModifiedDate;
        }
    }
    
    public class OpenPipeSearchResult {
        public List<OpenPipeInfo> records;
        public Integer totalCount;
        public Map<String, Double> productSummary;
        public Map<String, Double> regionSummary;
        public Map<String, Double> verticalSummary;
        public Map<String, Double> segmentSummary;
        public Map<String, Double> countrySummary;
        public List<OpenPipeInfo> topPerformers;
        
        public OpenPipeSearchResult() {
            this.records = new List<OpenPipeInfo>();
            this.totalCount = 0;
            this.productSummary = new Map<String, Double>();
            this.regionSummary = new Map<String, Double>();
            this.verticalSummary = new Map<String, Double>();
            this.segmentSummary = new Map<String, Double>();
            this.countrySummary = new Map<String, Double>();
            this.topPerformers = new List<OpenPipeInfo>();
        }
    }
    
    public static OpenPipeSearchResult searchOpenPipe(String searchTerm, String searchType, 
                                                     String forecastType, Integer maxResults) {
        OpenPipeSearchResult result = new OpenPipeSearchResult();
        
        try {
            // Validate forecast type if provided
            String validatedForecastType = forecastType;
            if (String.isNotBlank(forecastType)) {
                List<String> availableForecastTypes = getAvailableForecastTypes();
                if (!availableForecastTypes.contains(forecastType)) {
                    // Invalid forecast type - log warning and search all forecast types instead
                    System.debug('WARNING: Invalid forecast type "' + forecastType + '" provided. Available types: ' + availableForecastTypes + '. Searching all forecast types instead.');
                    validatedForecastType = null; // Remove invalid forecast type to search all
                }
            }
            
            String query = buildSearchQuery(searchTerm, searchType, validatedForecastType, maxResults);
            
            if (String.isBlank(query)) {
                return result;
            }
            
            List<SObject> records = Database.query(query);
            result.records = processOpenPipeRecords(records);
            result.totalCount = result.records.size();
            
            if (!result.records.isEmpty()) {
                result.productSummary = getProductSummary(result.records);
                result.regionSummary = getRegionSummary(result.records);
                result.verticalSummary = getVerticalSummary(result.records);
                result.segmentSummary = getSegmentSummary(result.records);
                result.countrySummary = getCountrySummary(result.records);
                result.topPerformers = getTopPerformers(result.records, 10);
            }
            
        } catch (Exception e) {
            System.debug('Error in searchOpenPipe: ' + e.getMessage());
        }
        
        return result;
    }
    
    private static String buildSearchQuery(String searchTerm, String searchType, 
                                          String forecastType, Integer maxResults) {
        String baseQuery = 'SELECT Id, Name, EMPLOYEE_ID__c, EMPLOYEE_EMAIL__c, POSITION_WORKER_EMAIL__c, ' +
                          'ROLE_LEVEL_4__c, ROLE_LEVEL_5__c, ROLE_LEVEL_6__c, MACRO_SEGMENT__c, ' +
                          'FORMATTED_VERTICAL__c, EMPLOYEE_LOCATION_COUNTRY__c, IS_AE__c, ' +
                          'SIMPLE_SEGMENT__c, EMPLOYEE_LOCATION_REGION__c, EMPLOYEE_PCC_REGION__c, ' +
                          'TENURE_AT_SALESFORCE_MONTHS__c, TENURE_IN_ROLE_MONTHS__c, PRODUCT_L2__c, ' +
                          'VALUE__c, FORECAST_TYPE__c, RANK__c, CreatedDate, LastModifiedDate ' +
                          'FROM prime_ae_amer_plan__c ' +
                          'WHERE IsDeleted = false ';
        
        String searchCondition = '';
        String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);
        
        // Validate search type for combined terms
        if (String.isNotBlank(searchTerm) && searchTerm.contains(' ') && searchType?.toLowerCase() != 'all') {
            System.debug('WARNING: Combined search term "' + searchTerm + '" detected but searchType is "' + searchType + '". This may cause governor limit errors. Consider using searchType "All".');
        }
        
        // Special handling for the problematic case: "AMER ENTR" with "Segment" search type
        if (searchTerm == 'AMER ENTR' && searchType?.toLowerCase() == 'segment') {
            System.debug('CRITICAL: Detected problematic search - "AMER ENTR" with "Segment" search type. This will cause governor limit errors. Forcing searchType to "All".');
            searchType = 'All';
        }
        
        // Add forecast type filter if specified
        if (String.isNotBlank(forecastType)) {
            searchCondition += 'AND FORECAST_TYPE__c = \'' + String.escapeSingleQuotes(forecastType) + '\' ';
        }
        
        switch on searchType?.toLowerCase() {
            when 'product' {
                searchCondition += 'AND PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\'';
            }
            when 'region' {
                searchCondition += 'AND (EMPLOYEE_LOCATION_REGION__c LIKE \'%' + escapedSearchTerm + '%\' OR EMPLOYEE_PCC_REGION__c LIKE \'%' + escapedSearchTerm + '%\')';
            }
            when 'vertical' {
                searchCondition += 'AND FORMATTED_VERTICAL__c LIKE \'%' + escapedSearchTerm + '%\'';
            }
            when 'segment' {
                searchCondition += 'AND (MACRO_SEGMENT__c LIKE \'%' + escapedSearchTerm + '%\' OR SIMPLE_SEGMENT__c LIKE \'%' + escapedSearchTerm + '%\')';
            }
            when 'country' {
                searchCondition += 'AND EMPLOYEE_LOCATION_COUNTRY__c LIKE \'%' + escapedSearchTerm + '%\'';
            }
            when 'ae' {
                searchCondition += 'AND (Name LIKE \'%' + escapedSearchTerm + '%\' OR EMPLOYEE_EMAIL__c LIKE \'%' + escapedSearchTerm + '%\' OR POSITION_WORKER_EMAIL__c LIKE \'%' + escapedSearchTerm + '%\')';
            }
            when 'all' {
                // Check if search term contains multiple criteria (e.g., "AMER ENTR")
                List<String> searchTerms = escapedSearchTerm.split(' ');
                if (searchTerms.size() > 1) {
                    // Handle combined search with multiple terms
                    String combinedCondition = '';
                    for (String term : searchTerms) {
                        if (String.isNotBlank(term)) {
                            if (String.isNotBlank(combinedCondition)) {
                                combinedCondition += ' AND ';
                            }
                            combinedCondition += '(PRODUCT_L2__c LIKE \'%' + term + '%\' ' +
                                                'OR EMPLOYEE_LOCATION_REGION__c LIKE \'%' + term + '%\' ' +
                                                'OR EMPLOYEE_PCC_REGION__c LIKE \'%' + term + '%\' ' +
                                                'OR FORMATTED_VERTICAL__c LIKE \'%' + term + '%\' ' +
                                                'OR MACRO_SEGMENT__c LIKE \'%' + term + '%\' ' +
                                                'OR SIMPLE_SEGMENT__c LIKE \'%' + term + '%\' ' +
                                                'OR EMPLOYEE_LOCATION_COUNTRY__c LIKE \'%' + term + '%\' ' +
                                                'OR Name LIKE \'%' + term + '%\' ' +
                                                'OR EMPLOYEE_EMAIL__c LIKE \'%' + term + '%\')';
                        }
                    }
                    searchCondition += 'AND (' + combinedCondition + ')';
                } else {
                    // Single term search (original logic)
                    searchCondition += 'AND (PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR EMPLOYEE_LOCATION_REGION__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR EMPLOYEE_PCC_REGION__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR FORMATTED_VERTICAL__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR MACRO_SEGMENT__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR SIMPLE_SEGMENT__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR EMPLOYEE_LOCATION_COUNTRY__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR Name LIKE \'%' + escapedSearchTerm + '%\' ' +
                                      'OR EMPLOYEE_EMAIL__c LIKE \'%' + escapedSearchTerm + '%\')';
                }
            }
            when else {
                return ''; // Invalid search type
            }
        }
        
        String orderBy = 'ORDER BY VALUE__c DESC, RANK__c ASC';
        String limitClause = 'LIMIT ' + maxResults;
        
        return baseQuery + searchCondition + ' ' + orderBy + ' ' + limitClause;
    }
    
    private static List<OpenPipeInfo> processOpenPipeRecords(List<SObject> records) {
        List<OpenPipeInfo> openPipeList = new List<OpenPipeInfo>();
        
        for (SObject record : records) {
            OpenPipeInfo openPipe = new OpenPipeInfo(
                (String)record.get('Id'),
                (String)record.get('Name'),
                String.valueOf(record.get('EMPLOYEE_ID__c')),
                (String)record.get('EMPLOYEE_EMAIL__c'),
                (String)record.get('POSITION_WORKER_EMAIL__c'),
                (String)record.get('ROLE_LEVEL_4__c'),
                (String)record.get('ROLE_LEVEL_5__c'),
                (String)record.get('ROLE_LEVEL_6__c'),
                (String)record.get('MACRO_SEGMENT__c'),
                (String)record.get('FORMATTED_VERTICAL__c'),
                (String)record.get('EMPLOYEE_LOCATION_COUNTRY__c'),
                (Boolean)record.get('IS_AE__c'),
                (String)record.get('SIMPLE_SEGMENT__c'),
                (String)record.get('EMPLOYEE_LOCATION_REGION__c'),
                (String)record.get('EMPLOYEE_PCC_REGION__c'),
                                           (Double)record.get('TENURE_AT_SALESFORCE_MONTHS__c'),
                           (Double)record.get('TENURE_IN_ROLE_MONTHS__c'),
                                           (String)record.get('PRODUCT_L2__c'),
                           (Double)record.get('VALUE__c'),
                           (String)record.get('FORECAST_TYPE__c'),
                           (Double)record.get('RANK__c'),
                (Datetime)record.get('CreatedDate'),
                (Datetime)record.get('LastModifiedDate')
            );
            openPipeList.add(openPipe);
        }
        
        return openPipeList;
    }
    
    private static Map<String, Double> getProductSummary(List<OpenPipeInfo> records) {
        Map<String, Double> productSummary = new Map<String, Double>();
        
        for (OpenPipeInfo record : records) {
            if (String.isNotBlank(record.productL2)) {
                Double currentValue = productSummary.containsKey(record.productL2) ? productSummary.get(record.productL2) : 0;
                productSummary.put(record.productL2, currentValue + (record.value != null ? record.value : 0));
            }
        }
        
        return productSummary;
    }
    
    private static Map<String, Double> getRegionSummary(List<OpenPipeInfo> records) {
        Map<String, Double> regionSummary = new Map<String, Double>();
        
        for (OpenPipeInfo record : records) {
            String region = record.employeeLocationRegion != null ? record.employeeLocationRegion : 'Unknown';
            Double currentValue = regionSummary.containsKey(region) ? regionSummary.get(region) : 0;
            regionSummary.put(region, currentValue + (record.value != null ? record.value : 0));
        }
        
        return regionSummary;
    }
    
    private static Map<String, Double> getVerticalSummary(List<OpenPipeInfo> records) {
        Map<String, Double> verticalSummary = new Map<String, Double>();
        
        for (OpenPipeInfo record : records) {
            String vertical = record.formattedVertical != null ? record.formattedVertical : 'N/A';
            Double currentValue = verticalSummary.containsKey(vertical) ? verticalSummary.get(vertical) : 0;
            verticalSummary.put(vertical, currentValue + (record.value != null ? record.value : 0));
        }
        
        return verticalSummary;
    }
    
    private static Map<String, Double> getSegmentSummary(List<OpenPipeInfo> records) {
        Map<String, Double> segmentSummary = new Map<String, Double>();
        
        for (OpenPipeInfo record : records) {
            String segment = record.macroSegment != null ? record.macroSegment : 'Unknown';
            Double currentValue = segmentSummary.containsKey(segment) ? segmentSummary.get(segment) : 0;
            segmentSummary.put(segment, currentValue + (record.value != null ? record.value : 0));
        }
        
        return segmentSummary;
    }
    
    private static Map<String, Double> getCountrySummary(List<OpenPipeInfo> records) {
        Map<String, Double> countrySummary = new Map<String, Double>();
        
        for (OpenPipeInfo record : records) {
            String country = record.employeeLocationCountry != null ? record.employeeLocationCountry : 'Unknown';
            Double currentValue = countrySummary.containsKey(country) ? countrySummary.get(country) : 0;
            countrySummary.put(country, currentValue + (record.value != null ? record.value : 0));
        }
        
        return countrySummary;
    }
    
    private static List<OpenPipeInfo> getTopPerformers(List<OpenPipeInfo> records, Integer limitCount) {
        List<OpenPipeInfo> sortedList = new List<OpenPipeInfo>(records);
        sortedList.sort(new ValueComparator());
        
        List<OpenPipeInfo> topPerformers = new List<OpenPipeInfo>();
        for (Integer i = 0; i < Math.min(limitCount, sortedList.size()); i++) {
            topPerformers.add(sortedList[i]);
        }
        
        return topPerformers;
    }
    
    public static List<String> getAvailableForecastTypes() {
        List<String> forecastTypes = new List<String>();
        
        try {
            List<AggregateResult> results = [
                SELECT FORECAST_TYPE__c 
                FROM prime_ae_amer_plan__c 
                WHERE FORECAST_TYPE__c != null 
                GROUP BY FORECAST_TYPE__c 
                ORDER BY FORECAST_TYPE__c
                LIMIT 50
            ];
            
            for (AggregateResult result : results) {
                forecastTypes.add((String)result.get('FORECAST_TYPE__c'));
            }
        } catch (Exception e) {
            System.debug('Error getting forecast types: ' + e.getMessage());
        }
        
        return forecastTypes;
    }
    
    public static List<String> getAvailableProducts() {
        List<String> products = new List<String>();
        
        try {
            List<AggregateResult> results = [
                SELECT PRODUCT_L2__c 
                FROM prime_ae_amer_plan__c 
                WHERE PRODUCT_L2__c != null 
                GROUP BY PRODUCT_L2__c 
                ORDER BY PRODUCT_L2__c
                LIMIT 50
            ];
            
            for (AggregateResult result : results) {
                products.add((String)result.get('PRODUCT_L2__c'));
            }
        } catch (Exception e) {
            System.debug('Error getting products: ' + e.getMessage());
        }
        
        return products;
    }
    
    public static List<String> getAvailableRegions() {
        List<String> regions = new List<String>();
        
        try {
            List<AggregateResult> results = [
                SELECT EMPLOYEE_LOCATION_REGION__c 
                FROM prime_ae_amer_plan__c 
                WHERE EMPLOYEE_LOCATION_REGION__c != null 
                GROUP BY EMPLOYEE_LOCATION_REGION__c 
                ORDER BY EMPLOYEE_LOCATION_REGION__c
                LIMIT 50
            ];
            
            for (AggregateResult result : results) {
                regions.add((String)result.get('EMPLOYEE_LOCATION_REGION__c'));
            }
        } catch (Exception e) {
            System.debug('Error getting regions: ' + e.getMessage());
        }
        
        return regions;
    }
    
    private class ValueComparator implements Comparator<OpenPipeInfo> {
        public Integer compare(OpenPipeInfo a, OpenPipeInfo b) {
            if (a.value == null && b.value == null) return 0;
            if (a.value == null) return 1;
            if (b.value == null) return -1;
            
            if (a.value < b.value) return 1;
            if (a.value > b.value) return -1;
            return 0;
        }
    }
} 