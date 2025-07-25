/**
 * @description Apex class to represent the deserialized JSON from the NLU service.
 * This acts as a data transfer object (DTO) that carries the structured query
 * information throughout the system.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingQueryRequest {

    @AuraEnabled public String USER_QUERY;
    @AuraEnabled public String AGENT_ACTION;
    @AuraEnabled public String INTENT_TYPE;

    @AuraEnabled public LearnerContext LEARNER_CONTEXT;
    @AuraEnabled public HierarchyContext HIERARCHY_CONTEXT;
    @AuraEnabled public Filters FILTERS;
    @AuraEnabled public ResponseCriteria RESPONSE_CRITERIA;
    @AuraEnabled public AmbiguityInfo AMBIGUITY_INFO;
    
    @AuraEnabled public String METADATA_REQUEST_TYPE;
    @AuraEnabled public String TARGET_OBJECT_API_NAME;
    @AuraEnabled public String TARGET_FIELD_API_NAME;
    @AuraEnabled public Boolean MAINTAIN_PREVIOUS_CONTEXT;

    // Inner class to hold learner-specific context
    public class LearnerContext {
        @AuraEnabled public String LEARNER_NAME;
    }

    // Inner class to hold hierarchy-specific context
    public class HierarchyContext {
        @AuraEnabled public String TYPE;        // "DIRECT_REPORTS" or "ORGANIZATION_MEMBERS"
        @AuraEnabled public String ANCHOR_NAME; // Manager's Name (text)
    }

    // Inner class to hold all possible filter criteria
    public class Filters {
        @AuraEnabled public String Training_Name;
        @AuraEnabled public String Training_Type_Hint;
        @AuraEnabled public String Completion_Status;
        @AuraEnabled public String Session_Name;
        @AuraEnabled public String Session_Start_Date;
        @AuraEnabled public String RELATIVE_DATE_TERM;
        @AuraEnabled public String Completion_Date_Relative_Term;
        @AuraEnabled public String Assignment_Status_Category;
        @AuraEnabled public String Session_Participant_Status;
        @AuraEnabled public String Event_Name_For_Session_Filter;
        @AuraEnabled public Integer queryOffset;
        @AuraEnabled public Integer queryLimit;
    }

    // Inner class to define the expected response format
    public class ResponseCriteria {
        @AuraEnabled public List<String> RETURN_FIELDS;
        @AuraEnabled public String FORMAT;
        @AuraEnabled public String AGGREGATION_FUNCTION;
        @AuraEnabled public Integer totalRecords { get; set; }
    }

    // Inner class to handle cases where the NLU is uncertain
    public class AmbiguityInfo {
        @AuraEnabled public String AMBIGUOUS_TERM;
        @AuraEnabled public Boolean SUGGEST_CLARIFICATION;
    }

    /**
     * @description A static method to safely parse a JSON string into an instance of this class.
     * @param jsonString The JSON string from the NLU service.
     * @return TrainingQueryRequest An instance of the class, or null if parsing fails.
     */
    public static TrainingQueryRequest parse(String jsonString) {
        try {
            if (String.isBlank(jsonString)) {
                System.debug(LoggingLevel.WARN, 'TrainingQueryRequest.parse: Input JSON string is blank.');
                return null;
            }
            return (TrainingQueryRequest)JSON.deserialize(jsonString, TrainingQueryRequest.class);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error deserializing TrainingQueryRequest: ' + e.getMessage());
            return null;
        }
    }
}