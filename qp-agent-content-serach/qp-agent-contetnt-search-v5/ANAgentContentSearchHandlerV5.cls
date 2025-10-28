/**
 * @description Content Search Handler V5 - Clean implementation with flexible input handling
 * @author AI Assistant
 * @version 5.0
 * @date 2025-10-27
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts both string and proper types for all Boolean/Integer fields (no type mismatch errors!)
 * - No deprecated "Input" suffix fields (cleaner API)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent with object field names
 * - No schema.json enforcement (auto-discovery mode)
 * 
 * Business Context: Unified search across ACT Learning Content (courses, assets, curricula) and 
 * Consensus Demo Videos for content discovery, lifecycle management, and training needs analysis.
 */
public with sharing class ANAgentContentSearchHandlerV5 {
    
    /**
     * @description Request wrapper for content search with enhanced filtering
     * ALL Boolean/Integer fields accept BOTH string and proper types
     */
    public class ContentSearchRequest {
        @InvocableVariable(
            label='Search Term' 
            description='Product name, topic, or content keyword to search. Examples: "Tableau", "Einstein", "Sales Cloud", "MuleSoft Anypoint", "Admin Certification". Business Context: Searches across Course names, Asset titles, Curriculum names, Consensus video titles, and descriptions. Use specific product names ("Data Cloud") for focused results or broader terms ("integration") for discovery. Minimum 2 characters required.' 
            required=true
        )
        public String searchTerm;
        
        @InvocableVariable(
            label='Content Type' 
            description='Filter ACT content by type (does NOT affect Consensus videos). Valid values: "COURSE" (full learning courses with CSAT and completion tracking), "ASSET" (short-form content like PDFs, quick guides), "CURRICULUM" (learning paths/journeys), "ALL" (searches all ACT types - default). Business Context: Helps narrow large result sets. Consensus videos are always included regardless of this filter. Case-insensitive.' 
            required=false
        )
        public String contentType;
        
        @InvocableVariable(
            label='Search Mode' 
            description='Controls which content sources to search. Valid values: "AUTO" (default - intelligent routing), "ACT" (ONLY ACT Learning Content), "CONSENSUS" (ONLY Consensus Demo Videos), "BOTH" (search both sources). Business Context: AUTO mode provides best UX for natural language queries. Case-insensitive.' 
            required=false
        )
        public String searchMode;
        
        @InvocableVariable(
            label='User Utterance' 
            description='Complete user utterance for intelligent routing (used in AUTO mode). Examples: "Find me Tableau courses", "Show demo videos for Einstein". Business Context: AUTO mode analyzes this text to route to appropriate source. If blank, uses searchTerm for routing.' 
            required=false
        )
        public String userUtterance;
        
        @InvocableVariable(
            label='Created Since' 
            description='Find content created/published SINCE this date (YYYY-MM-DD). Examples: "2024-08-01", "2024-01-01", "2025-10-01". Filters by CreatedDate field. Optional - leave blank to search all content regardless of age.' 
            required=false
        )
        public String createdSince;
        
        @InvocableVariable(
            label='Created Before' 
            description='Find content created BEFORE this date (YYYY-MM-DD). Examples: "2024-12-31", "2024-06-30". Filters by CreatedDate field. Format must be YYYY-MM-DD. If both dates provided, createdBefore must be >= createdSince.' 
            required=false
        )
        public String createdBefore;
        
        @InvocableVariable(
            label='Sort By' 
            description='Primary sort field for ACT content. Valid values: "ENROLLMENT" (most popular), "CSAT" (highest quality), "COMPLETION" (most engaging), "CREATED_DATE" (newest), "DEFAULT" (Enrollment then CSAT - recommended). Consensus always sorts by CreatedDate DESC. Case-insensitive.' 
            required=false
        )
        public String sortBy;
        
        @InvocableVariable(
            label='Sort Order' 
            description='Sort direction. Valid values: "DESC" (highest to lowest, default), "ASC" (lowest to highest). Use ASC to find underperforming content. Case-insensitive.' 
            required=false
        )
        public String sortOrder;
        
        @InvocableVariable(
            label='Limit' 
            description='📊 MAX RESULTS - Range: 1-500. Default: 100. ✅ FLEXIBLE: Accepts 100 (number) OR "100" (string). Examples: 20, "20", 100, "100", 500. System auto-converts both formats. Controls pagination per source (ACT and Consensus each return up to this limit).' 
            required=false
        )
        public String limitStr;
        
        @InvocableVariable(
            label='Include Inactive' 
            description='📂 INCLUDE ARCHIVED - ✅ FLEXIBLE: Accepts true (boolean) OR "true"/"yes"/"1" (string) for include, false/"false"/"no"/"0" for exclude. Default: false (Active only). System auto-converts. When true: shows Draft/Archived ACT content + archived Consensus videos. When false: only Active ACT + Published non-archived Consensus.' 
            required=false
        )
        public String includeInactiveStr;
    }
    
    /**
     * @description Response wrapper - EXACTLY ONE output following V5 best practices
     */
    public class ContentSearchResponse {
        @InvocableVariable(
            label='Content Search Result'
            description='Returns {ok|error, data:{summary, records}} in JSON format with complete search results. For ACT content: includes enrollment count, completion rate, CSAT score. For Consensus: includes published videos with preview links. Summary section shows: totalEnrollment, avgCompletionRate, avgCSAT, totalContent. Records section shows: id, name, type, link, createdDate, status, and metrics.'
            required=true
        )
        public String result;
        
        public ContentSearchResponse() {
            this.result = '';
        }
    }
    
    /**
     * @description Main invocable method - flexible input handling with auto-conversion
     * Accepts BOTH string and proper types for all Boolean/Integer fields
     */
    @InvocableMethod(
        label='SearchContentV5'
        description='🎯 CONTENT DISCOVERY V5 - Unified search across ACT Learning Content (45,000+ courses) + Consensus Demo Videos (2,000+ demos). ✅ FLEXIBLE INPUT: limit accepts 100/"100", includeInactive accepts true/"true"/"yes". Examples: {"searchTerm":"Agentforce","limit":"100","includeInactive":"false"} OR {"searchTerm":"Agentforce","limit":100,"includeInactive":false}. Both work! AUTO mode routes intelligently. Returns JSON with summary + detailed records with metrics.'
    )
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        List<ContentSearchResponse> out = new List<ContentSearchResponse>();
        
        if (requests == null || requests.isEmpty()) {
            ContentSearchResponse err = new ContentSearchResponse();
            err.result = FRResult.invalidInput('requests', 'List<ContentSearchRequest>', 'null');
            out.add(err);
            return out;
        }

        for (ContentSearchRequest req : requests) {
            ContentSearchResponse res = new ContentSearchResponse();
            
            // FLEXIBLE INPUT HANDLING: Convert string inputs to proper types
            Integer limitValue = null;
            Boolean includeInactiveValue = null;
            
            // Convert limit (string → integer)
            if (String.isNotBlank(req.limitStr)) {
                try {
                    limitValue = Integer.valueOf(req.limitStr.trim());
                } catch (Exception e) {
                    res.result = buildConversionError('limit', 'Integer', req.limitStr, 
                        new List<String>{'100', '"100"', '20', '"500"'},
                        new List<String>{
                            'Use a number between 1 and 500',
                            'Examples: limit=100 OR limit="100"',
                            'Default is 100 if not specified'
                        });
                    out.add(res);
                    continue;
                }
            }
            
            // Convert includeInactive (string → boolean)
            if (String.isNotBlank(req.includeInactiveStr)) {
                Object conversionResult = convertToBoolean(req.includeInactiveStr, 'includeInactive');
                if (conversionResult instanceof String) {
                    // Error occurred
                    res.result = (String) conversionResult;
                    out.add(res);
                    continue;
                }
                includeInactiveValue = (Boolean) conversionResult;
            }
            
            // Call service with converted values
            res.result = ANAgentContentSearchServiceV5.search(req, limitValue, includeInactiveValue);
            out.add(res);
        }
        
        return out;
    }
    
    /**
     * @description Converts string to Boolean with flexible format support
     * Accepts: true, "true", "TRUE", "yes", "1", false, "false", "no", "0"
     */
    private static Object convertToBoolean(String input, String fieldName) {
        if (String.isBlank(input)) {
            return null;
        }
        
        String normalized = input.toLowerCase().trim();
        
        // TRUE values
        if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
            return true;
        }
        
        // FALSE values
        if (normalized == 'false' || normalized == 'no' || normalized == '0') {
            return false;
        }
        
        // Invalid format
        return buildConversionError(fieldName, 'Boolean', input,
            new List<String>{'true', '"true"', '"yes"', '"1"', 'false', '"false"', '"no"', '"0"'},
            new List<String>{
                'Use true/false (boolean) OR "true"/"false" (string)',
                'Accepted values: true, "true", "yes", "1" for true',
                'Accepted values: false, "false", "no", "0" for false',
                'Example: ' + fieldName + '=true OR ' + fieldName + '="true"'
            });
    }
    
    /**
     * @description Builds standardized conversion error response
     */
    private static String buildConversionError(String field, String expectedType, String receivedValue,
                                               List<String> correctExamples, List<String> nextSteps) {
        Map<String, Object> error = new Map<String, Object>{
            'ok' => false,
            'data' => null,
            'error' => new Map<String, Object>{
                'code' => 'INVALID_INPUT',
                'message' => 'Cannot convert ' + field + ' to ' + expectedType + ': received "' + receivedValue + '"',
                'details' => new Map<String, Object>{
                    'field' => field,
                    'expected_type' => expectedType,
                    'received_value' => receivedValue,
                    'correct_examples' => correctExamples,
                    'agent_next_steps' => nextSteps
                }
            }
        };
        return JSON.serialize(error);
    }
}

