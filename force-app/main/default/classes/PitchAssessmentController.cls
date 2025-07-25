public with sharing class PitchAssessmentController {

     @AuraEnabled(cacheable=true)
    public static List<Rubric_Criterion__c> getRubricCriteria(Id rubricId) {
        // FIX: This check now handles both null and empty string values,
        // which prevents the error on initial page load.
        if (String.isBlank(String.valueOf(rubricId))) {
            return new List<Rubric_Criterion__c>();
        }
        
        return [
            SELECT Id, Criterion_Text__c, Points__c 
            FROM Rubric_Criterion__c 
            WHERE Assessment_Rubric__c = :rubricId 
            ORDER BY Sort_Order__c ASC
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Assessment_Rubric__c> getRubrics() {
        try {
            return [
                SELECT Id, Name 
                FROM Assessment_Rubric__c 
                WHERE Is_Active__c = true 
                ORDER BY Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Could not query Assessment Rubrics. Ensure the object and fields exist. Error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String assessPitch(String transcript, Id rubricId) {
        if (String.isBlank(transcript) || rubricId == null) {
            throw new AuraHandledException('Transcript and Rubric ID are required.');
        }

        try {
            Assessment_Rubric__c rubric = [
                SELECT Prompt_Template_API_Name__c 
                FROM Assessment_Rubric__c 
                WHERE Id = :rubricId
            ];

            ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            promptInput.isPreview = false;

            ConnectApi.WrappedValue transcriptValue = new ConnectApi.WrappedValue();
            transcriptValue.value = transcript;
            
            promptInput.inputParams = new Map<String, ConnectApi.WrappedValue>{
                'Input:pitchTranscript' => transcriptValue
            };
            
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                rubric.Prompt_Template_API_Name__c,
                promptInput
            );
            
            String feedback = output.generations[0].text;
            
            Decimal score = parseScore(feedback);

            Pitch_Assessment__c newAssessment = new Pitch_Assessment__c(
                Employee__c = UserInfo.getUserId(),
                Assessment_Rubric__c = rubricId,
                Transcript__c = transcript,
                AI_Feedback__c = feedback,
                AI_Score__c = score,
                Final_Score__c = score,
                Status__c = 'Awaiting Manager Review'
            );
            insert newAssessment;
            
            return feedback;

        } catch (Exception e) {
            System.debug('Error in assessPitch: ' + e.getMessage() + ' at stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('An error occurred with the AI service. Details: ' + e.getMessage());
        }
    }
    
    /**
     * @description A helper method to parse the score from the AI's response text.
     */
    private static Decimal parseScore(String feedback) {
        if (feedback == null) return null;
        try {
            // --- FIX IS HERE ---
            // The (?i) flag is added to the start of the pattern to make it case-insensitive.
            Pattern scorePattern = Pattern.compile('(?i)Overall Score:\\s*(\\d+)');
            Matcher scoreMatcher = scorePattern.matcher(feedback);

            if (scoreMatcher.find()) {
                // The score is in the first "capturing group" of the pattern.
                return Decimal.valueOf(scoreMatcher.group(1));
            }
        } catch (Exception e) {
            System.debug('Could not parse score from feedback: ' + e.getMessage());
        }
        // Return null if the pattern is not found.
        return null;
    }
}