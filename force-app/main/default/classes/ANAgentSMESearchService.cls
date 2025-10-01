/**
 * @description Service class for SME Search functionality
 * @author Salesforce
 * @date 2024
 */
public with sharing class ANAgentSMESearchService {
    
    /**
     * @description Enhanced search request structure
     */
    public class EnhancedSearchRequest {
        public String searchTerm;
        public String searchType;
        public Integer maxResults;
        public Boolean academyMembersOnly;
        public String ouName;
        public String workLocationCountry;
        public String productLevel;
        public Boolean requireSameOU;
        public Boolean includeStale;
    }
    
    /**
     * @description SME search result structure
     */
    public class SMESearchResult {
        public Boolean success;
        public String message;
        public List<SMEInfo> records;
        public Integer totalCount;
        public List<String> errors;
        public Map<String, Integer> productCounts;
    }
    
    /**
     * @description SME information structure
     */
    public class SMEInfo {
        public String id;
        public String name;
        public String aeName;
        public String aeRank;
        public String ou;
        public Decimal totalAcv;
        public String productL2;
        public String productL3;
        public Boolean academyMember;
        public String email;
        public String workLocationCountry;
        public Date createdDate;
        public DateTime lastModifiedDate;
        public Decimal relevanceScore;
        public String rankingExplanation;
    }
    
    /**
     * @description Enhanced search method with all parameters
     */
    public static SMESearchResult searchSMEsEnhanced(EnhancedSearchRequest request) {
        SMESearchResult result = new SMESearchResult();
        result.success = false;
        result.records = new List<SMEInfo>();
        result.totalCount = 0;
        result.errors = new List<String>();
        result.productCounts = new Map<String, Integer>();

        try {
            // Validate inputs
            if (String.isBlank(request.searchTerm)) {
                result.errors.add('Search term cannot be blank.');
                return result;
            }

            // Set defaults
            String searchType = String.isNotBlank(request.searchType) ? request.searchType : 'ALL';
            Integer maxResults = request.maxResults != null && request.maxResults > 0 ? Math.min(request.maxResults, 100) : 25;
            Boolean academyMembersOnly = request.academyMembersOnly != null ? request.academyMembersOnly : false;
            String ouName = request.ouName;
            String workLocationCountry = request.workLocationCountry;
            String productLevel = String.isNotBlank(request.productLevel) ? request.productLevel : 'ANY';
            Boolean requireSameOU = request.requireSameOU != null ? request.requireSameOU : true;
            Boolean includeStale = request.includeStale != null ? request.includeStale : false;

            // Build enhanced query with all parameters
            String query = buildEnhancedQueryWithAllParams(request.searchTerm, searchType, maxResults,
                academyMembersOnly, ouName, workLocationCountry, productLevel, requireSameOU, includeStale);

            // Execute query
            List<AGENT_SME_ACADEMIES__c> smeRecords = Database.query(query);

            if (smeRecords.isEmpty()) {
                result.success = true;
                result.message = 'No SMEs found matching "' + request.searchTerm + '"';
                return result;
            }

            // Convert to SMEInfo objects
            List<SMEInfo> smeInfoList = convertToSMEInfo(smeRecords);

            // Apply max results limit
            if (smeInfoList.size() > maxResults) {
                List<SMEInfo> limitedList = new List<SMEInfo>();
                for (Integer i = 0; i < maxResults && i < smeInfoList.size(); i++) {
                    limitedList.add(smeInfoList[i]);
                }
                smeInfoList = limitedList;
            }

            // Build product counts
            result.productCounts = buildProductCounts(smeInfoList);

            result.success = true;
            result.records = smeInfoList;
            result.totalCount = smeInfoList.size();
            result.message = 'Found ' + smeInfoList.size() + ' SME(s) for "' + request.searchTerm + '"';

        } catch (Exception e) {
            result.success = false;
            result.errors.add('Enhanced search failed: ' + e.getMessage());
            System.debug('Enhanced SME search error: ' + e.getMessage());
        }

        return result;
    }
    
    /**
     * @description Build enhanced query with all parameters
     */
    private static String buildEnhancedQueryWithAllParams(String searchTerm, String searchType, Integer maxResults,
        Boolean academyMembersOnly, String ouName, String workLocationCountry, String productLevel,
        Boolean requireSameOU, Boolean includeStale) {

        String baseQuery = 'SELECT Id, Name, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, ' +
                            'PRODUCT_L3__c, PRODUCT_L2__c, ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                            'FROM AGENT_SME_ACADEMIES__c ' +
                            'WHERE IsDeleted = false ';

        List<String> conditions = new List<String>();
        String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);

        // Search term conditions
        if (String.isNotBlank(searchTerm)) {
            if (searchType == 'PRODUCT') {
                conditions.add('(PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\' OR ' +
                              'PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\')');
            } else if (searchType == 'AE') {
                conditions.add('(Name LIKE \'%' + escapedSearchTerm + '%\' OR ' +
                              'AE_NAME__c LIKE \'%' + escapedSearchTerm + '%\')');
            } else if (searchType == 'OU') {
                conditions.add('OU__c LIKE \'%' + escapedSearchTerm + '%\'');
            } else if (searchType == 'ALL') {
                conditions.add('(PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\' OR ' +
                              'PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\' OR ' +
                              'Name LIKE \'%' + escapedSearchTerm + '%\' OR ' +
                              'AE_NAME__c LIKE \'%' + escapedSearchTerm + '%\' OR ' +
                              'OU__c LIKE \'%' + escapedSearchTerm + '%\')');
            }
        }

        // OU filter
        if (String.isNotBlank(ouName)) {
            conditions.add('OU__c = \'' + String.escapeSingleQuotes(ouName) + '\'');
        }

        // Country filter
        if (String.isNotBlank(workLocationCountry)) {
            conditions.add('WORK_LOCATION_COUNTRY__c LIKE \'%' + String.escapeSingleQuotes(workLocationCountry) + '%\'');
        }

        // Academy filter
        if (academyMembersOnly) {
            conditions.add('ACADEMIES_MEMBER__c = true');
        }

        // Product level filter
        if (productLevel == 'L2') {
            conditions.add('PRODUCT_L2__c != null');
        } else if (productLevel == 'L3') {
            conditions.add('PRODUCT_L3__c != null');
        }

        // Stale filter
        if (!includeStale) {
            Datetime staleDate = Datetime.now().addDays(-180);
            conditions.add('LastModifiedDate >= ' + staleDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        }

        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }

        baseQuery += ' ORDER BY LastModifiedDate DESC LIMIT ' + maxResults;

        return baseQuery;
    }
    
    /**
     * @description Convert SME records to SMEInfo objects
     */
    private static List<SMEInfo> convertToSMEInfo(List<AGENT_SME_ACADEMIES__c> smeRecords) {
        List<SMEInfo> smeInfoList = new List<SMEInfo>();
        
        for (AGENT_SME_ACADEMIES__c sme : smeRecords) {
            SMEInfo info = new SMEInfo();
            info.id = sme.Id;
            info.name = sme.Name;
            info.aeName = sme.AE_NAME__c;
            info.aeRank = String.valueOf(sme.AE_RANK__c);
            info.ou = sme.OU__c;
            info.totalAcv = sme.TOTAL_ACV__c != null ? sme.TOTAL_ACV__c : 0;
            info.productL2 = sme.PRODUCT_L2__c;
            info.productL3 = sme.PRODUCT_L3__c;
            info.academyMember = sme.ACADEMIES_MEMBER__c;
            info.email = ''; // Will be enriched from Learner_Profile__c later
            info.workLocationCountry = ''; // Will be enriched from Learner_Profile__c later
            info.createdDate = sme.CreatedDate.date();
            info.lastModifiedDate = sme.LastModifiedDate;
            info.relevanceScore = 1.0; // Default score
            info.rankingExplanation = 'Basic ranking applied';
            
            smeInfoList.add(info);
        }
        
        return smeInfoList;
    }
    
    /**
     * @description Build product counts from SME info list
     */
    private static Map<String, Integer> buildProductCounts(List<SMEInfo> smeInfoList) {
        Map<String, Integer> productCounts = new Map<String, Integer>();
        
        for (SMEInfo sme : smeInfoList) {
            if (String.isNotBlank(sme.productL2)) {
                Integer count = productCounts.get(sme.productL2);
                productCounts.put(sme.productL2, count != null ? count + 1 : 1);
            }
            if (String.isNotBlank(sme.productL3)) {
                Integer count = productCounts.get(sme.productL3);
                productCounts.put(sme.productL3, count != null ? count + 1 : 1);
            }
        }
        
        return productCounts;
    }
    
    /**
     * @description Original search method for backward compatibility
     */
    public static SMESearchResult searchSMEs(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly) {
        EnhancedSearchRequest request = new EnhancedSearchRequest();
        request.searchTerm = searchTerm;
        request.searchType = searchType;
        request.maxResults = maxResults;
        request.academyMembersOnly = academyMembersOnly;
        request.ouName = null;
        request.workLocationCountry = null;
        request.productLevel = 'ANY';
        request.requireSameOU = true;
        request.includeStale = false;
        
        return searchSMEsEnhanced(request);
    }
}
