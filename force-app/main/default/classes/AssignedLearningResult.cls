// This class defines the data structure for a single assigned learning item.
// By making it a top-level global class, it becomes a reusable Apex-Defined type for Flows.
global class AssignedLearningResult {

    @AuraEnabled @InvocableVariable(label='Assigned Learning ID' required=true)
    global String assignedLearningId;
    
    @AuraEnabled @InvocableVariable(label='Learning Name' required=true)
    global String learningName;
    
    @AuraEnabled @InvocableVariable(label='Learning Type' required=true)
    global String learningType; // e.g., "Curriculum", "Course", or "Event"
    
    @AuraEnabled @InvocableVariable(label='Is Self Assigned')
    global Boolean isSelfAssigned;

    @AuraEnabled @InvocableVariable(label='Required By')
    global String requiredBy; // The name of the Content Distribution Organization
    
    // A public no-argument constructor is required for Apex-Defined types used in Flow.
    public AssignedLearningResult() {}
}