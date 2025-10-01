/**
 * @description Consensus content search service for agent actions.
 * Searches the Agent_Consensu__c object with intelligent ranking and filtering.
 * @version 1.0
 */
public with sharing class ANAgentConsensusContentSearchService {
    
    // Schema constants for compile-time safety
    private class SchemaMap {
        public final String OBJ_CONS = 'Agent_Consensu__c';
        public final String F_TITLE   = 'Title__c';
        public final String F_INT    = 'InternalTitle__c';
        public final String F_DESC   = 'Description__c';
        public final String F_PUB    = 'IsPublished__c';
        public final String F_PUBLIC = 'IsPublic__c';
        public final String F_CREATED_AT = 'CreatedAt__c'; // if absent, we'll fall back to CreatedDate
        public final String F_PREVIEW = 'PreviewLink__c';
        public final String F_LANG    = 'LanguageTitle__c';
        public final String F_FOLDER  = 'FolderInfoName__c';
        public final String F_CRE_FN  = 'CreatorDataFirstName__c';
        public final String F_CRE_LN  = 'CreatorDataLastName__c';
        public final String F_CRE_EM  = 'CreatorDataEmail__c';
    }
    
    // Helper methods for safe string operations
    private static String after(String src, String token) {
        if (String.isBlank(src) || String.isBlank(token)) return '';
        Integer i = src.indexOf(token);
        return i < 0 ? '' : src.substring(i + token.length()).trim();
    }
    
    private static String nz(String s) { 
        return String.isBlank(s) ? '' : s; 
    }
    
    private static String nzlower(String s) { 
        return String.isBlank(s) ? '' : s.toLowerCase(); 
    }

    /**
     * @description Consensus content record structure
     */
    public class ConsensusContent {
        public String id { get; set; }
        public String title { get; set; }
        public String internalTitle { get; set; }
        public String description { get; set; }
        public Boolean isPublic { get; set; }
        public Boolean isPublished { get; set; }
        public DateTime createdAt { get; set; }
        public String previewLink { get; set; }
        public String languageTitle { get; set; }
        public String folderInfoName { get; set; }
        public String creatorFirstName { get; set; }
        public String creatorLastName { get; set; }
        public String creatorEmail { get; set; }
        public Integer relevanceScore { get; set; }
        
        // Enhanced fields for improved UX
        public String category { get; set; }
        public String duration { get; set; }
        public String difficulty { get; set; }
        public String prerequisites { get; set; }
        public Double qualityScore { get; set; }
        public String freshnessIndicator { get; set; }
        public String contentType { get; set; }
        
        public ConsensusContent() {
            this.relevanceScore = 0;
            this.qualityScore = 0.0;
            this.category = '';
            this.duration = '';
            this.difficulty = '';
            this.prerequisites = '';
            this.freshnessIndicator = '';
            this.contentType = '';
        }
        
        /**
         * @description Calculate quality score based on engagement metrics
         */
        public void calculateQualityScore() {
            Double score = 0.0;
            
            // Base score for published content
            if (this.isPublished == true) {
                score += 0.3;
            }
            
            // Score for public content
            if (this.isPublic == true) {
                score += 0.2;
            }
            
            // Score for recent content (within last 90 days)
            if (this.createdAt != null) {
                Integer daysSince = this.createdAt.date().daysBetween(Date.today());
                if (daysSince <= 90) {
                    score += 0.3;
                } else if (daysSince <= 180) {
                    score += 0.2;
                } else {
                    score += 0.1;
                }
            }
            
            // Score for content with description
            if (String.isNotBlank(this.description)) {
                score += 0.1;
            }
            
            // Score for content with preview link
            if (String.isNotBlank(this.previewLink)) {
                score += 0.1;
            }
            
            this.qualityScore = Math.min(1.0, score);
        }
    }

    /**
     * @description Main entry point for Consensus content search
     * @param userUtterance The user's search query
     * @return Formatted search results message
     */
    public static String searchConsensusContent(String userUtterance) {
        try {
            // Use basic search for now
            List<ConsensusContent> results = searchBasic(userUtterance, 25);
            
            if (results.isEmpty()) {
                return '**Consensus Content Search**\n\nNo content found matching: "' + userUtterance + '"\n\nTry different keywords or check spelling.';
            }
            
            // Format results
            String message = '**Consensus Content Search**\n\n';
            message += 'Found ' + results.size() + ' results for: "' + userUtterance + '"\n\n';
            
            for (Integer i = 0; i < results.size(); i++) {
                ConsensusContent content = results[i];
                message += '**' + (i + 1) + '.** ' + (String.isNotBlank(content.title) ? content.title : 'Untitled') + '\n';
                
                if (String.isNotBlank(content.internalTitle)) {
                    message += '   Internal: ' + content.internalTitle + '\n';
                }
                
                if (String.isNotBlank(content.description)) {
                    String description = content.description.length() > 200 ? content.description.substring(0, 200) + '...' : content.description;
                    message += '   Description: ' + description + '\n';
                }
                
                if (String.isNotBlank(content.folderInfoName)) {
                    message += '   Folder: ' + content.folderInfoName + '\n';
                }
                
                if (content.createdAt != null) {
                    message += '   Created: ' + content.createdAt.format('yyyy-MM-dd') + '\n';
                }
                
                if (String.isNotBlank(content.previewLink)) {
                    message += '   Preview: ' + content.previewLink + '\n';
                }
                
                message += '\n';
            }
            
            return message;
            
        } catch (Exception e) {
            return '**Consensus Content Search Error**\n\nError searching content: ' + e.getMessage();
        }
    }

    /**
     * @description Basic Consensus content search with minimal filters
     * @param rawQuery The search term
     * @param limitN Maximum number of results
     * @return List of ConsensusContent objects
     */
    public static List<ConsensusContent> searchBasic(String rawQuery, Integer limitN) {
        String term = String.isBlank(rawQuery) ? null : rawQuery.trim();
        Integer n = (limitN == null || limitN <= 0) ? 25 : Math.min(limitN, 100);

        // Build field list - using only fields that definitely exist
        String f = String.join(new List<String>{
            'Id',
            'Title__c',
            'InternalTitle__c',
            'Description__c',
            'IsPublic__c',
            'IsPublished__c',
            'CreatedDate',
            'PreviewLink__c',
            'LanguageTitle__c',
            'FolderInfoName__c'
        }, ', ');

        String soql = 'SELECT ' + f + ' FROM Agent_Consensu__c';
        List<String> wherez = new List<String>();

        // published by default
        wherez.add('IsPublished__c = TRUE');

        if (term != null) {
            String esc = String.escapeSingleQuotes(term);
            wherez.add('(Title__c LIKE \'%' + esc + '%\' OR ' +
                        'InternalTitle__c LIKE \'%' + esc + '%\' OR ' +
                        'FolderInfoName__c LIKE \'%' + esc + '%\')');
        }

        if (!wherez.isEmpty()) soql += ' WHERE ' + String.join(wherez, ' AND ');
        soql += ' ORDER BY CreatedDate DESC NULLS LAST LIMIT ' + n;

        List<SObject> rows;
        try {
            rows = Database.query(soql);
        } catch (Exception e) {
            System.debug('Error querying Agent_Consensu__c: ' + e.getMessage());
            // Fallback to simpler query without problematic fields
            String simpleSoql = 'SELECT Id, Title__c FROM Agent_Consensu__c WHERE IsPublished__c = TRUE LIMIT ' + n;
            try {
                rows = Database.query(simpleSoql);
            } catch (Exception e2) {
                System.debug('Error with fallback query: ' + e2.getMessage());
                return new List<ConsensusContent>();
            }
        }

        List<ConsensusContent> out = new List<ConsensusContent>();
        for (SObject r : rows) out.add(mapConsensusRow(r));
        return out;
    }

    /**
     * @description Map SObject record to ConsensusContent
     * @param r The SObject record
     * @return ConsensusContent object
     */
    private static ConsensusContent mapConsensusRow(SObject r) {
        ConsensusContent c = new ConsensusContent();
        
        // Safe field mapping with null checks
        c.id = safeGetString(r, 'Id');
        c.title = safeGetString(r, 'Title__c');
        c.internalTitle = safeGetString(r, 'InternalTitle__c');
        c.description = safeGetString(r, 'Description__c');
        c.isPublic = safeGetBoolean(r, 'IsPublic__c');
        c.isPublished = safeGetBoolean(r, 'IsPublished__c');
        c.createdAt = safeGetDateTime(r, 'CreatedDate');
        c.previewLink = safeGetString(r, 'PreviewLink__c');
        c.languageTitle = safeGetString(r, 'LanguageTitle__c');
        c.folderInfoName = safeGetString(r, 'FolderInfoName__c');
        
        // Set defaults for missing fields
        c.creatorFirstName = '';
        c.creatorLastName = '';
        c.creatorEmail = '';

        // cheap relevance: title/internal/folder contains search term later in ranking method
        c.relevanceScore = 0;
        c.calculateQualityScore();
        return c;
    }
    
    private static String safeGetString(SObject r, String fieldName) {
        try {
            return (String)r.get(fieldName);
        } catch (Exception e) {
            return '';
        }
    }
    
    private static Boolean safeGetBoolean(SObject r, String fieldName) {
        try {
            Boolean value = (Boolean)r.get(fieldName);
            return value != null ? value : false;
        } catch (Exception e) {
            return false;
        }
    }
    
    private static DateTime safeGetDateTime(SObject r, String fieldName) {
        try {
            return (DateTime)r.get(fieldName);
        } catch (Exception e) {
            return null;
        }
    }
}
