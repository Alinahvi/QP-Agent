// TrainingSearchResult.cls
// Purpose: Data Transfer Object (DTO) to represent a single training search result.
// This class is used as an Apex-Defined type in Flow.
global class TrainingSearchResult {
    @AuraEnabled global Id recordId;
    @AuraEnabled global String name;
    @AuraEnabled global String description;
    @AuraEnabled global String objectType; // e.g., "Curriculum", "Course", "Event"
    @AuraEnabled global String matchReason; // Why this result was matched
    @AuraEnabled global String taggedDetails; // Concatenated string of Products, Industries, Roles, etc.
    @AuraEnabled global String metrics; // Concatenated string of CSAT, Time Estimate, etc.

    // Public no-argument constructor is required for Apex-Defined types in Flow
    public TrainingSearchResult() {
        // Initialize any default values if necessary, though often not needed for DTOs
    }
}