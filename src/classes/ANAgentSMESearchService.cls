/**
 * @description Service class for searching Subject Matter Experts (SMEs) by product
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentSMESearchService {
    
    /**
     * @description Data transfer object for SME information
     */
    public class SMEInfo {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String aeName { get; set; }
        @AuraEnabled public Double aeRank { get; set; }
        @AuraEnabled public String organizationalUnit { get; set; }
        @AuraEnabled public Double totalACV { get; set; }
        @AuraEnabled public String productL3 { get; set; }
        @AuraEnabled public String productL2 { get; set; }
        @AuraEnabled public Boolean isAcademyMember { get; set; }
        @AuraEnabled public Datetime createdDate { get; set; }
        @AuraEnabled public Datetime lastModifiedDate { get; set; }
        
        public SMEInfo() {}
        
        public SMEInfo(String id, String name, String aeName, Double aeRank, String ou, 
                      Double totalACV, String productL3, String productL2, Boolean isAcademyMember,
                      Datetime createdDate, Datetime lastModifiedDate) {
            this.id = id;
            this.name = name;
            this.aeName = aeName;
            this.aeRank = aeRank;
            this.organizationalUnit = ou;
            this.totalACV = totalACV;
            this.productL3 = productL3;
            this.productL2 = productL2;
            this.isAcademyMember = isAcademyMember;
            this.createdDate = createdDate;
            this.lastModifiedDate = lastModifiedDate;
        }
    }
    
    /**
     * @description Search result wrapper
     */
    public class SMESearchResult {
        public Boolean success { get; set; }
        public List<SMEInfo> records { get; set; }
        public Integer totalCount { get; set; }
        public List<String> errors { get; set; }
        public Map<String, List<SMEInfo>> smesByProduct { get; set; }
        public Map<String, Integer> productCounts { get; set; }
        
        public SMESearchResult() {
            this.success = false;
            this.records = new List<SMEInfo>();
            this.totalCount = 0;
            this.errors = new List<String>();
            this.smesByProduct = new Map<String, List<SMEInfo>>();
            this.productCounts = new Map<String, Integer>();
        }
    }
    
    /**
     * @description Main search method for SMEs
     * @param searchTerm The search term (product name, AE name, or organizational unit)
     * @param searchType The type of search (Product, AE, OU, or All)
     * @param maxResults Maximum number of results to return
     * @param academyMembersOnly Optional filter for Academy members only
     * @return SMESearchResult
     */
    public static SMESearchResult searchSMEs(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly) {
        SMESearchResult result = new SMESearchResult();
        
        try {
            // Validate inputs
            if (String.isBlank(searchTerm)) {
                result.errors.add('Search term is required.');
                return result;
            }
            
            if (maxResults == null || maxResults <= 0) {
                maxResults = 50; // Default limit
            }
            
            // Build dynamic SOQL query based on search type
            String query = buildSearchQuery(searchTerm, searchType, maxResults, academyMembersOnly);
            
            if (String.isBlank(query)) {
                result.errors.add('Invalid search type. Valid types: Product, AE, OU, All');
                return result;
            }
            
            // Execute query
            List<SObject> records = Database.query(query);
            
            // Process results
            result.records = processSMERecords(records);
            result.totalCount = result.records.size();
            result.success = true;
            
            // Group by product for better organization
            result.smesByProduct = groupSMEsByProduct(result.records);
            result.productCounts = getProductCounts(result.records);
            
        } catch (Exception e) {
            result.success = false;
            result.errors.add('Search failed: ' + e.getMessage());
            System.debug('ANAgentSMESearchService error: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Build dynamic SOQL query based on search parameters
     * @param searchTerm The search term
     * @param searchType The type of search
     * @param maxResults Maximum results limit
     * @param academyMembersOnly Optional filter for Academy members only
     * @return String SOQL query
     */
    private static String buildSearchQuery(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly) {
        String baseQuery = 'SELECT Id, Name, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, ' +
                          'PRODUCT_L3__c, PRODUCT_L2__c, ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                          'FROM AGENT_SME_ACADEMIES__c ' +
                          'WHERE IsDeleted = false ';
        
        String searchCondition = '';
        String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);
        
        switch on searchType?.toLowerCase() {
            when 'product' {
                searchCondition = 'AND (PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\' OR PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\')';
            }
            when 'ae' {
                searchCondition = 'AND (Name LIKE \'%' + escapedSearchTerm + '%\' OR AE_NAME__c LIKE \'%' + escapedSearchTerm + '%\')';
            }
            when 'ou' {
                searchCondition = 'AND OU__c LIKE \'%' + escapedSearchTerm + '%\'';
            }
            when 'all' {
                searchCondition = 'AND (PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\' OR PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                 'OR Name LIKE \'%' + escapedSearchTerm + '%\' OR AE_NAME__c LIKE \'%' + escapedSearchTerm + '%\' ' +
                                 'OR OU__c LIKE \'%' + escapedSearchTerm + '%\')';
            }
            when else {
                return ''; // Invalid search type
            }
        }
        
        // Add Academy filtering if requested
        String academyFilter = '';
        if (academyMembersOnly != null && academyMembersOnly) {
            academyFilter = ' AND ACADEMIES_MEMBER__c = true';
        }
        
        String orderBy = 'ORDER BY AE_RANK__c ASC, TOTAL_ACV__c DESC';
        String limitClause = 'LIMIT ' + maxResults;
        
        return baseQuery + searchCondition + academyFilter + ' ' + orderBy + ' ' + limitClause;
    }
    
    /**
     * @description Process SObject records into SMEInfo objects
     * @param records List of SObject records
     * @return List<SMEInfo>
     */
    private static List<SMEInfo> processSMERecords(List<SObject> records) {
        List<SMEInfo> smeList = new List<SMEInfo>();
        
        for (SObject record : records) {
            SMEInfo sme = new SMEInfo(
                (String)record.get('Id'),
                (String)record.get('Name'),
                (String)record.get('AE_NAME__c'),
                (Double)record.get('AE_RANK__c'),
                (String)record.get('OU__c'),
                (Double)record.get('TOTAL_ACV__c'),
                (String)record.get('PRODUCT_L3__c'),
                (String)record.get('PRODUCT_L2__c'),
                (Boolean)record.get('ACADEMIES_MEMBER__c'),
                (Datetime)record.get('CreatedDate'),
                (Datetime)record.get('LastModifiedDate')
            );
            smeList.add(sme);
        }
        
        return smeList;
    }
    
    /**
     * @description Group SMEs by product for better organization
     * @param smeList List of SME records
     * @return Map<String, List<SMEInfo>>
     */
    private static Map<String, List<SMEInfo>> groupSMEsByProduct(List<SMEInfo> smeList) {
        Map<String, List<SMEInfo>> groupedSMEs = new Map<String, List<SMEInfo>>();
        
        for (SMEInfo sme : smeList) {
            String productKey = sme.productL3 != null ? sme.productL3 : sme.productL2;
            if (String.isNotBlank(productKey)) {
                if (!groupedSMEs.containsKey(productKey)) {
                    groupedSMEs.put(productKey, new List<SMEInfo>());
                }
                groupedSMEs.get(productKey).add(sme);
            }
        }
        
        return groupedSMEs;
    }
    
    /**
     * @description Get count of SMEs per product
     * @param smeList List of SME records
     * @return Map<String, Integer>
     */
    private static Map<String, Integer> getProductCounts(List<SMEInfo> smeList) {
        Map<String, Integer> productCounts = new Map<String, Integer>();
        
        for (SMEInfo sme : smeList) {
            String productKey = sme.productL3 != null ? sme.productL3 : sme.productL2;
            if (String.isNotBlank(productKey)) {
                Integer currentCount = productCounts.containsKey(productKey) ? productCounts.get(productKey) : 0;
                productCounts.put(productKey, currentCount + 1);
            }
        }
        
        return productCounts;
    }
    
    /**
     * @description Get top SMEs by ACV for a specific product
     * @param productName The product name to search for
     * @param limitCount Number of top SMEs to return
     * @return List<SMEInfo>
     */
    public static List<SMEInfo> getTopSMEsByProduct(String productName, Integer limitCount) {
        if (String.isBlank(productName) || limitCount == null || limitCount <= 0) {
            return new List<SMEInfo>();
        }
        
        try {
            String query = 'SELECT Id, Name, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, ' +
                          'PRODUCT_L3__c, PRODUCT_L2__c, ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                          'FROM AGENT_SME_ACADEMIES__c ' +
                          'WHERE IsDeleted = false ' +
                          'AND (PRODUCT_L3__c = :productName OR PRODUCT_L2__c = :productName) ' +
                          'ORDER BY TOTAL_ACV__c DESC, AE_RANK__c ASC ' +
                          'LIMIT :limitCount';
            
            List<SObject> records = Database.query(query);
            return processSMERecords(records);
            
        } catch (Exception e) {
            System.debug('Error getting top SMEs by product: ' + e.getMessage());
            return new List<SMEInfo>();
        }
    }
    
    /**
     * @description Get all available products
     * @return List<String>
     */
    public static List<String> getAllProducts() {
        try {
            List<String> products = new List<String>();
            
            // Get unique PRODUCT_L3 values
            List<AggregateResult> l3Results = [
                SELECT PRODUCT_L3__c 
                FROM AGENT_SME_ACADEMIES__c 
                WHERE IsDeleted = false AND PRODUCT_L3__c != null 
                GROUP BY PRODUCT_L3__c 
                ORDER BY PRODUCT_L3__c
            ];
            
            for (AggregateResult ar : l3Results) {
                products.add((String)ar.get('PRODUCT_L3__c'));
            }
            
            // Get unique PRODUCT_L2 values
            List<AggregateResult> l2Results = [
                SELECT PRODUCT_L2__c 
                FROM AGENT_SME_ACADEMIES__c 
                WHERE IsDeleted = false AND PRODUCT_L2__c != null 
                GROUP BY PRODUCT_L2__c 
                ORDER BY PRODUCT_L2__c
            ];
            
            for (AggregateResult ar : l2Results) {
                String l2Product = (String)ar.get('PRODUCT_L2__c');
                if (!products.contains(l2Product)) {
                    products.add(l2Product);
                }
            }
            
            return products;
            
        } catch (Exception e) {
            System.debug('Error getting all products: ' + e.getMessage());
            return new List<String>();
        }
    }
    
    /**
     * @description Get top SMEs by ACV for a specific product with Academy filtering
     * @param productName The product name to search for
     * @param limitCount Number of top SMEs to return
     * @param academyMembersOnly Whether to filter for Academy members only
     * @return List<SMEInfo>
     */
    public static List<SMEInfo> getTopSMEsByProductWithAcademy(String productName, Integer limitCount, Boolean academyMembersOnly) {
        if (String.isBlank(productName) || limitCount == null || limitCount <= 0) {
            return new List<SMEInfo>();
        }
        
        try {
            String query = 'SELECT Id, Name, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, ' +
                          'PRODUCT_L3__c, PRODUCT_L2__c, ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                          'FROM AGENT_SME_ACADEMIES__c ' +
                          'WHERE IsDeleted = false ' +
                          'AND (PRODUCT_L3__c = :productName OR PRODUCT_L2__c = :productName) ';
            
            if (academyMembersOnly != null && academyMembersOnly) {
                query += 'AND ACADEMIES_MEMBER__c = true ';
            }
            
            query += 'ORDER BY TOTAL_ACV__c DESC, AE_RANK__c ASC LIMIT :limitCount';
            
            List<SObject> records = Database.query(query);
            return processSMERecords(records);
            
        } catch (Exception e) {
            System.debug('Error getting top SMEs by product with Academy filter: ' + e.getMessage());
            return new List<SMEInfo>();
        }
    }
    
    /**
     * @description Get top SMEs by ACV for a specific product and OU with Academy filtering
     * @param productName The product name to search for
     * @param ouName The organizational unit name
     * @param limitCount Number of top SMEs to return
     * @param academyMembersOnly Whether to filter for Academy members only
     * @return List<SMEInfo>
     */
    public static List<SMEInfo> getTopSMEsByProductAndOU(String productName, String ouName, Integer limitCount, Boolean academyMembersOnly) {
        if (String.isBlank(productName) || String.isBlank(ouName) || limitCount == null || limitCount <= 0) {
            return new List<SMEInfo>();
        }
        
        try {
            String query = 'SELECT Id, Name, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, ' +
                          'PRODUCT_L3__c, PRODUCT_L2__c, ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                          'FROM AGENT_SME_ACADEMIES__c ' +
                          'WHERE IsDeleted = false ' +
                          'AND (PRODUCT_L3__c = :productName OR PRODUCT_L2__c = :productName) ' +
                          'AND OU__c = :ouName ';
            
            if (academyMembersOnly != null && academyMembersOnly) {
                query += 'AND ACADEMIES_MEMBER__c = true ';
            }
            
            query += 'ORDER BY TOTAL_ACV__c DESC, AE_RANK__c ASC LIMIT :limitCount';
            
            List<SObject> records = Database.query(query);
            return processSMERecords(records);
            
        } catch (Exception e) {
            System.debug('Error getting top SMEs by product and OU: ' + e.getMessage());
            return new List<SMEInfo>();
        }
    }
} 