/**
 * @description Simplified Service class for searching Subject Matter Experts (SMEs) by product
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentSMESearchServiceSimple {
    
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
        
        // Contact information fields
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String department { get; set; }
        
        // Enhanced ranking fields
        @AuraEnabled public Decimal relevanceScore { get; set; }
        @AuraEnabled public String scoringRationale { get; set; }
        @AuraEnabled public Boolean isFuzzyMatch { get; set; }
        
        public SMEInfo() {
            this.email = '';
            this.phone = '';
            this.title = '';
            this.department = '';
            this.relevanceScore = 0.0;
            this.scoringRationale = '';
            this.isFuzzyMatch = false;
        }
        
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
            this.email = '';
            this.phone = '';
            this.title = '';
            this.department = '';
            this.relevanceScore = 0.0;
            this.scoringRationale = '';
            this.isFuzzyMatch = false;
        }
    }
    
    /**
     * @description Search result wrapper
     */
    public class SMESearchResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<SMEInfo> records { get; set; }
        @AuraEnabled public Integer totalRecordCount { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
        
        public SMESearchResult() {
            this.success = false;
            this.message = '';
            this.records = new List<SMEInfo>();
            this.totalRecordCount = 0;
            this.errors = new List<String>();
        }
    }
    
    /**
     * @description Enhanced search with ranking and fuzzy matching (simplified version)
     */
    public static SMESearchResult searchSMEsEnhanced(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly, String ouName) {
        SMESearchResult result = new SMESearchResult();
        result.success = true;
        result.message = 'Enhanced SME search completed successfully';
        
        try {
            // Use default configuration (hardcoded for now)
            Boolean enableRanking = true;
            Boolean enableFuzzy = true;
            Integer returnTopN = 3;
            Boolean explainability = true;
            
            // Build enhanced search query
            String query = buildEnhancedSearchQuerySimple(searchTerm, searchType, academyMembersOnly);
            
            // Execute query
            List<SObject> records = Database.query(query);
            
            // Process records with ranking
            result.records = processSMERecordsWithRankingSimple(records, searchTerm, searchType, ouName);
            
            // Sort by relevance score if ranking is enabled
            if (enableRanking) {
                result.records.sort(new SMEInfoComparator());
            }
            
            // Limit results
            if (result.records.size() > returnTopN) {
                List<ANAgentSMESearchServiceSimple.SMEInfo> limitedRecords = new List<ANAgentSMESearchServiceSimple.SMEInfo>();
                for (Integer i = 0; i < returnTopN && i < result.records.size(); i++) {
                    limitedRecords.add(result.records[i]);
                }
                result.records = limitedRecords;
            }
            
            result.totalRecordCount = result.records.size();
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error in enhanced SME search: ' + e.getMessage();
            result.errors.add(e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Build enhanced search query (simplified version)
     */
    private static String buildEnhancedSearchQuerySimple(String searchTerm, String searchType, Boolean academyMembersOnly) {
        String query = 'SELECT Id, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, PRODUCT_L3__c, PRODUCT_L2__c, ' +
                      'ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                      'FROM AGENT_SME_ACADEMIES__c ';
        
        List<String> conditions = new List<String>();
        
        // Add search term conditions
        if (String.isNotBlank(searchTerm)) {
            String searchPattern = '%' + searchTerm + '%';
            conditions.add('(PRODUCT_L2__c LIKE :searchPattern OR PRODUCT_L3__c LIKE :searchPattern OR AE_NAME__c LIKE :searchPattern)');
        }
        
        // Add academy members only filter
        if (academyMembersOnly != null && academyMembersOnly) {
            conditions.add('ACADEMIES_MEMBER__c = true');
        }
        
        // Add WHERE clause if conditions exist
        if (!conditions.isEmpty()) {
            query += 'WHERE ' + String.join(conditions, ' AND ');
        }
        
        query += ' ORDER BY LastModifiedDate DESC LIMIT 50';
        
        return query;
    }
    
    /**
     * @description Process SME records with ranking (simplified version)
     */
    private static List<SMEInfo> processSMERecordsWithRankingSimple(List<SObject> records, String searchTerm, String searchType, String ouName) {
        List<SMEInfo> smeList = new List<SMEInfo>();
        
        for (SObject record : records) {
            SMEInfo sme = new SMEInfo(
                String.valueOf(record.get('Id')),
                String.valueOf(record.get('AE_NAME__c')),
                String.valueOf(record.get('AE_NAME__c')),
                (Double) record.get('AE_RANK__c'),
                String.valueOf(record.get('OU__c')),
                (Double) record.get('TOTAL_ACV__c'),
                String.valueOf(record.get('PRODUCT_L3__c')),
                String.valueOf(record.get('PRODUCT_L2__c')),
                (Boolean) record.get('ACADEMIES_MEMBER__c'),
                (Datetime) record.get('CreatedDate'),
                (Datetime) record.get('LastModifiedDate')
            );
            
            // Calculate relevance score
            calculateRelevanceScoreSimple(sme, searchTerm, searchType, ouName);
            
            smeList.add(sme);
        }
        
        return smeList;
    }
    
    /**
     * @description Calculate relevance score (simplified version with hardcoded weights)
     */
    private static void calculateRelevanceScoreSimple(SMEInfo sme, String searchTerm, String searchType, String ouName) {
        Decimal score = 0.0;
        List<String> rationale = new List<String>();
        
        // Same OU bonus: +3.0
        if (String.isNotBlank(ouName) && String.isNotBlank(sme.organizationalUnit)) {
            if (sme.organizationalUnit.equalsIgnoreCase(ouName)) {
                score += 3.0;
                rationale.add('Same-OU +3.0');
            }
        }
        
        // Excellence Academy bonus: +2.5
        if (sme.isAcademyMember == true) {
            score += 2.5;
            rationale.add('Excellence Academy +2.5');
        }
        
        // Product L2 match: +3.0
        if (String.isNotBlank(searchTerm) && String.isNotBlank(sme.productL2)) {
            if (sme.productL2.equalsIgnoreCase(searchTerm)) {
                score += 3.0;
                rationale.add('L2 match +3.0');
            } else if (sme.productL2.containsIgnoreCase(searchTerm)) {
                score += 2.0;
                rationale.add('L2 partial +2.0');
            }
        }
        
        // Product L3 match: +1.0
        if (String.isNotBlank(searchTerm) && String.isNotBlank(sme.productL3)) {
            if (sme.productL3.equalsIgnoreCase(searchTerm)) {
                score += 1.0;
                rationale.add('L3 match +1.0');
            } else if (sme.productL3.containsIgnoreCase(searchTerm)) {
                score += 0.5;
                rationale.add('L3 partial +0.5');
            }
        }
        
        // ACV signal (scaled): min((TOTAL_ACV__c / 1,000,000), 2.0)
        if (sme.totalACV != null && sme.totalACV > 0) {
            Decimal acvScore = Math.min(sme.totalACV / 1000000, 2.0);
            score += acvScore;
            rationale.add('ACV +' + acvScore);
        }
        
        // Recency bonus: +0.5 if LastModifiedDate >= LAST_N_DAYS:90
        if (sme.lastModifiedDate != null) {
            Date ninetyDaysAgo = Date.today().addDays(-90);
            if (sme.lastModifiedDate.date() >= ninetyDaysAgo) {
                score += 0.5;
                rationale.add('Recency +0.5');
            }
        }
        
        sme.relevanceScore = score;
        sme.scoringRationale = String.join(rationale, ', ');
    }
    
    /**
     * @description Comparator for sorting SMEInfo by relevance score
     */
    public class SMEInfoComparator implements Comparator<SMEInfo> {
        public Integer compare(SMEInfo sme1, SMEInfo sme2) {
            if (sme1.relevanceScore > sme2.relevanceScore) return -1;
            if (sme1.relevanceScore < sme2.relevanceScore) return 1;
            return 0;
        }
    }
    
    /**
     * @description Populate contact information from User and Learner_Profile__c
     */
    private static void populateContactInformation(List<SMEInfo> smeList) {
        // Get AE names for lookup
        Set<String> aeNames = new Set<String>();
        for (SMEInfo sme : smeList) {
            if (String.isNotBlank(sme.aeName)) {
                aeNames.add(sme.aeName);
            }
        }
        
        if (aeNames.isEmpty()) return;
        
        // Query User object for email addresses
        Map<String, String> nameToEmail = new Map<String, String>();
        try {
            List<User> users = [SELECT Name, Email FROM User WHERE Name IN :aeNames AND Email != null LIMIT 100];
            for (User u : users) {
                nameToEmail.put(u.Name, u.Email);
            }
        } catch (Exception e) {
            System.debug('Error querying User object: ' + e.getMessage());
        }
        
        // Query Learner_Profile__c for additional contact info
        Map<String, String> nameToLearnerEmail = new Map<String, String>();
        try {
            List<Learner_Profile__c> profiles = [SELECT Name, Primary_Email__c FROM Learner_Profile__c WHERE Name IN :aeNames AND Primary_Email__c != null LIMIT 100];
            for (Learner_Profile__c profile : profiles) {
                nameToLearnerEmail.put(profile.Name, profile.Primary_Email__c);
            }
        } catch (Exception e) {
            System.debug('Error querying Learner_Profile__c: ' + e.getMessage());
        }
        
        // Populate contact information
        for (SMEInfo sme : smeList) {
            if (String.isBlank(sme.email) && String.isNotBlank(sme.aeName)) {
                // Try User object first
                if (nameToEmail.containsKey(sme.aeName)) {
                    sme.email = nameToEmail.get(sme.aeName);
                }
                // Fallback to Learner_Profile__c
                else if (nameToLearnerEmail.containsKey(sme.aeName)) {
                    sme.email = nameToLearnerEmail.get(sme.aeName);
                }
            }
        }
    }
}
