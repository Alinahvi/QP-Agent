/**
 * @description SME Search Service V3 - FR-style implementation
 * @author AI Assistant
 * @version 3.0
 * Follows FR agent best practices: all logic in service, returns single String message
 */
public with sharing class ANAgentSMESearchServiceV3 {
    
    /**
     * @description Enhanced search with ranking and fuzzy matching
     * Returns a complete formatted message string for the agent
     */
    public static String searchSMEsEnhanced(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly, String ouName) {
        try {
            // Set defaults
            if (maxResults == null || maxResults <= 0) maxResults = 10;
            if (String.isBlank(searchType)) searchType = 'product';
            if (academyMembersOnly == null) academyMembersOnly = false;
            
            // Build and execute query
            String query = buildEnhancedSearchQuery(searchTerm, searchType, academyMembersOnly);
            System.debug('SME Search Query: ' + query);
            
            List<SObject> records = Database.query(query);
            
            // Apply security
            records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();
            
            // Process and rank results
            List<SMEInfo> smeList = processSMERecordsWithRanking(records, searchTerm, searchType, ouName);
            
            // Sort by ranking
            smeList.sort(new SMERankingComparator());
            
            // Apply limit after sorting
            Integer totalFound = smeList.size();
            if (smeList.size() > maxResults) {
                List<SMEInfo> limitedList = new List<SMEInfo>();
                for (Integer i = 0; i < maxResults; i++) {
                    limitedList.add(smeList[i]);
                }
                smeList = limitedList;
            }
            
            // Build complete message following FR-style format
            return buildCompleteMessage(smeList, searchTerm, searchType, ouName, academyMembersOnly, totalFound, maxResults);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'SME Search Service Error: ' + e.getStackTraceString());
            return buildErrorMessage(e.getMessage());
        }
    }
    
    /**
     * @description Build enhanced search query with proper escaping
     */
    private static String buildEnhancedSearchQuery(String searchTerm, String searchType, Boolean academyMembersOnly) {
        String query = 'SELECT Id, AE_NAME__c, AE_RANK__c, OU__c, TOTAL_ACV__c, PRODUCT_L3__c, PRODUCT_L2__c, ' +
                      'ACADEMIES_MEMBER__c, CreatedDate, LastModifiedDate ' +
                      'FROM AGENT_SME_ACADEMIES__c ';
        
        String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);
        String whereClause = '';
        
        if (searchType.toLowerCase() == 'product') {
            whereClause = 'WHERE (PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\' OR PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\')';
        } else if (searchType.toLowerCase() == 'name') {
            whereClause = 'WHERE AE_NAME__c LIKE \'%' + escapedSearchTerm + '%\'';
        } else {
            whereClause = 'WHERE (AE_NAME__c LIKE \'%' + escapedSearchTerm + '%\' OR PRODUCT_L3__c LIKE \'%' + escapedSearchTerm + '%\' OR PRODUCT_L2__c LIKE \'%' + escapedSearchTerm + '%\')';
        }
        
        if (academyMembersOnly) {
            whereClause += ' AND ACADEMIES_MEMBER__c = true';
        }
        
        query += whereClause + ' ORDER BY AE_RANK__c DESC NULLS LAST, TOTAL_ACV__c DESC NULLS LAST';
        
        return query;
    }
    
    /**
     * @description Process SME records with enhanced ranking
     */
    private static List<SMEInfo> processSMERecordsWithRanking(List<SObject> records, String searchTerm, String searchType, String ouName) {
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
            calculateRelevanceScore(sme, searchTerm, searchType, ouName);
            
            smeList.add(sme);
        }
        
        return smeList;
    }
    
    /**
     * @description Calculate relevance score for ranking
     */
    private static void calculateRelevanceScore(SMEInfo sme, String searchTerm, String searchType, String ouName) {
        Double score = 0.0;
        String rationale = '';
        
        // Base score from AE_RANK__c
        if (sme.aeRank != null) {
            score += sme.aeRank * 10;
            rationale += 'AE Rank: ' + sme.aeRank + ' (+' + (sme.aeRank * 10) + '), ';
        }
        
        // OU matching bonus
        if (String.isNotBlank(ouName) && String.isNotBlank(sme.organizationalUnit) && 
            sme.organizationalUnit.toLowerCase().contains(ouName.toLowerCase())) {
            score += 50;
            rationale += 'OU Match: ' + ouName + ' (+50), ';
        }
        
        // Academy member bonus
        if (sme.isAcademyMember == true) {
            score += 25;
            rationale += 'Academy Member (+25), ';
        }
        
        // Product relevance bonus
        if (searchType.toLowerCase() == 'product' || searchType.toLowerCase() == 'all') {
            if (String.isNotBlank(sme.productL3) && sme.productL3.toLowerCase().contains(searchTerm.toLowerCase())) {
                score += 30;
                rationale += 'L3 Product Match (+30), ';
            } else if (String.isNotBlank(sme.productL2) && sme.productL2.toLowerCase().contains(searchTerm.toLowerCase())) {
                score += 20;
                rationale += 'L2 Product Match (+20), ';
            }
        }
        
        // Name relevance bonus
        if (searchType.toLowerCase() == 'name' || searchType.toLowerCase() == 'all') {
            if (String.isNotBlank(sme.aeName) && sme.aeName.toLowerCase().contains(searchTerm.toLowerCase())) {
                score += 40;
                rationale += 'Name Match (+40), ';
            }
        }
        
        sme.relevanceScore = score;
        sme.scoringRationale = rationale.removeEnd(', ');
    }
    
    /**
     * @description Build complete message following FR-style format
     */
    private static String buildCompleteMessage(List<SMEInfo> smeList, String searchTerm, String searchType, String ouName, Boolean academyMembersOnly, Integer totalFound, Integer maxResults) {
        String message = '';
        
        // HEADER
        message += '# SME Search Results\n\n';
        
        // SUMMARY
        message += '## Summary\n';
        message += '- **Search Term**: ' + searchTerm + '\n';
        message += '- **Search Type**: ' + searchType + '\n';
        message += '- **Organizational Unit**: ' + (String.isNotBlank(ouName) ? ouName : 'All') + '\n';
        message += '- **Academy Members Only**: ' + (academyMembersOnly ? 'Yes' : 'No') + '\n';
        message += '- **Total Found**: ' + totalFound + ' SMEs\n';
        message += '- **Showing**: ' + smeList.size() + ' results\n\n';
        
        // INSIGHTS
        String topOU = '';
        Integer academyCount = 0;
        
        if (!smeList.isEmpty()) {
            message += '## Insights\n';
            
            // Top performing OU
            Map<String, Integer> ouCount = new Map<String, Integer>();
            for (SMEInfo sme : smeList) {
                if (String.isNotBlank(sme.organizationalUnit)) {
                    Integer currentCount = ouCount.containsKey(sme.organizationalUnit) ? ouCount.get(sme.organizationalUnit) : 0;
                    ouCount.put(sme.organizationalUnit, currentCount + 1);
                }
            }
            
            Integer maxCount = 0;
            for (String ou : ouCount.keySet()) {
                if (ouCount.get(ou) > maxCount) {
                    maxCount = ouCount.get(ou);
                    topOU = ou;
                }
            }
            
            if (String.isNotBlank(topOU)) {
                message += '- **Top OU**: ' + topOU + ' (' + maxCount + ' SMEs)\n';
            }
            
            // Academy members percentage
            for (SMEInfo sme : smeList) {
                if (sme.isAcademyMember == true) academyCount++;
            }
            if (academyCount > 0) {
                message += '- **Academy Members**: ' + academyCount + ' of ' + smeList.size() + ' (' + Math.round((Double)academyCount / smeList.size() * 100) + '%)\n';
            }
            
            message += '\n';
        }
        
        // DETAILS
        message += '## SME Details\n';
        if (smeList.isEmpty()) {
            message += 'No SMEs found matching the search criteria.\n\n';
        } else {
            for (Integer i = 0; i < smeList.size(); i++) {
                SMEInfo sme = smeList[i];
                message += '### ' + (i + 1) + '. ' + sme.aeName + '\n';
                message += '- **Organizational Unit**: ' + (String.isNotBlank(sme.organizationalUnit) ? sme.organizationalUnit : 'N/A') + '\n';
                message += '- **Product L3**: ' + (String.isNotBlank(sme.productL3) ? sme.productL3 : 'N/A') + '\n';
                message += '- **Product L2**: ' + (String.isNotBlank(sme.productL2) ? sme.productL2 : 'N/A') + '\n';
                message += '- **AE Rank**: ' + (sme.aeRank != null ? String.valueOf(sme.aeRank) : 'N/A') + '\n';
                message += '- **Total ACV**: ' + (sme.totalACV != null ? '$' + String.valueOf(sme.totalACV) : 'N/A') + '\n';
                message += '- **Academy Member**: ' + (sme.isAcademyMember == true ? 'Yes' : 'No') + '\n';
                message += '- **Relevance Score**: ' + sme.relevanceScore + '\n';
                message += '- **Scoring**: ' + sme.scoringRationale + '\n\n';
            }
        }
        
        // LIMITS & COUNTS
        message += '## Limits & Counts\n';
        message += '- **Query Limit**: ' + maxResults + ' results\n';
        message += '- **Total Matches**: ' + totalFound + ' (before limit)\n';
        message += '- **Results Shown**: ' + smeList.size() + '\n';
        if (totalFound > maxResults) {
            message += '- **Truncated**: Yes (showing top ' + maxResults + ' by relevance)\n';
        }
        message += '\n';
        
        // JSON (compact, 3-6 keys max)
        message += '## Data (JSON)\n';
        message += '```json\n';
        message += '{\n';
        message += '  "searchTerm": "' + searchTerm + '",\n';
        message += '  "totalFound": ' + totalFound + ',\n';
        message += '  "showing": ' + smeList.size() + ',\n';
        message += '  "academyMembers": ' + academyCount + ',\n';
        message += '  "topOU": "' + topOU + '",\n';
        message += '  "results": [\n';
        
        for (Integer i = 0; i < smeList.size(); i++) {
            SMEInfo sme = smeList[i];
            message += '    {\n';
            message += '      "name": "' + sme.aeName + '",\n';
            message += '      "ou": "' + (String.isNotBlank(sme.organizationalUnit) ? sme.organizationalUnit : '') + '",\n';
            message += '      "product": "' + (String.isNotBlank(sme.productL3) ? sme.productL3 : '') + '",\n';
            message += '      "rank": ' + (sme.aeRank != null ? sme.aeRank : 0) + ',\n';
            message += '      "academy": ' + (sme.isAcademyMember == true ? 'true' : 'false') + ',\n';
            message += '      "score": ' + sme.relevanceScore + '\n';
            message += '    }';
            if (i < smeList.size() - 1) message += ',';
            message += '\n';
        }
        
        message += '  ]\n';
        message += '}\n';
        message += '```\n';
        
        return message;
    }
    
    /**
     * @description Build error message
     */
    private static String buildErrorMessage(String errorMsg) {
        return '# SME Search Error\n\n**Error**: ' + errorMsg + '\n\nPlease check your search parameters and try again.';
    }
    
    /**
     * @description Internal SMEInfo class for processing
     */
    private class SMEInfo {
        public String id { get; set; }
        public String name { get; set; }
        public String aeName { get; set; }
        public Double aeRank { get; set; }
        public String organizationalUnit { get; set; }
        public Double totalACV { get; set; }
        public String productL3 { get; set; }
        public String productL2 { get; set; }
        public Boolean isAcademyMember { get; set; }
        public Datetime createdDate { get; set; }
        public Datetime lastModifiedDate { get; set; }
        public Decimal relevanceScore { get; set; }
        public String scoringRationale { get; set; }
        public Boolean isFuzzyMatch { get; set; }
        
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
            this.relevanceScore = 0.0;
            this.scoringRationale = '';
            this.isFuzzyMatch = false;
        }
    }
    
    /**
     * @description Comparator for SME ranking
     */
    private class SMERankingComparator implements Comparator<SMEInfo> {
        public Integer compare(SMEInfo sme1, SMEInfo sme2) {
            if (sme1.relevanceScore > sme2.relevanceScore) return -1;
            if (sme1.relevanceScore < sme2.relevanceScore) return 1;
            
            // If relevance scores are equal, use AE rank
            if (sme1.aeRank != null && sme2.aeRank != null) {
                if (sme1.aeRank > sme2.aeRank) return -1;
                if (sme1.aeRank < sme2.aeRank) return 1;
            }
            
            // If still equal, use ACV
            if (sme1.totalACV != null && sme2.totalACV != null) {
                if (sme1.totalACV > sme2.totalACV) return -1;
                if (sme1.totalACV < sme2.totalACV) return 1;
            }
            
            return 0;
        }
    }
}
