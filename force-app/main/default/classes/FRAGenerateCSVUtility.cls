public with sharing class FRAGenerateCSVUtility {

    private static final Set<String> VALID_STATUSES = new Set<String>{'Attended', 'Absent', 'Exempt', 'Registered', 'Unregistered', 'Waitlisted'};
    private static final Set<String> VALID_REGISTRATION_TYPES = new Set<String>{'Virtual', 'Physical'};

    /**
     * Invocable method to generate a downloadable CSV file with emails of Audience Members.
     * Applies the same status and registration type to all members in the specified audience.
     * @param csvAudienceRequest List containing Audience ID, Status, Registration Type, and desired filename.
     * @return List containing ContentDocument ID, download URL, and summary.
     */
    @InvocableMethod(label='GA-FRA Generate CSV from Audience' description='Generates CSV for Audience Members with provided Status and Registration Type.')
    public static List<CSVResponse> generateAudienceCSV(List<CSVAudienceRequest> csvAudienceRequest) {
        List<CSVResponse> responses = new List<CSVResponse>();
        if (csvAudienceRequest == null || csvAudienceRequest.isEmpty()) return responses;

        CSVAudienceRequest request = csvAudienceRequest[0];

        if (!VALID_STATUSES.contains(request.status)) {
            throw new AuraHandledException('Invalid Status: ' + request.status);
        }
        if (!VALID_REGISTRATION_TYPES.contains(request.registrationType)) {
            throw new AuraHandledException('Invalid Registration Type: ' + request.registrationType);
        }

        // Query Audience Member emails
        List<Audience_Member__c> audienceMembers = [
            SELECT Learner_Profile__r.Primary_Email__c
            FROM Audience_Member__c
            WHERE Audience__c = :request.audienceId
        ];

        // Prepare CSV
        List<String> csvLines = new List<String>{'Email,Status,Registration Type'};

        for (Audience_Member__c member : audienceMembers) {
            if (member.Learner_Profile__r != null && String.isNotBlank(member.Learner_Profile__r.Primary_Email__c)) {
                csvLines.add(member.Learner_Profile__r.Primary_Email__c + ',' + request.status + ',' + request.registrationType);
            }
        }

        Blob csvBody = Blob.valueOf(String.join(csvLines, '\n'));

        // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = request.fileName,
            PathOnClient = request.fileName + '.csv',
            VersionData = csvBody
        );
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String downloadUrl = baseUrl + '/sfc/servlet.shepherd/version/download/' + cv.Id;

        CSVResponse response = new CSVResponse();
        response.contentDocumentId = cv.ContentDocumentId;
        response.downloadUrl = downloadUrl;
        response.summary = 'CSV generated successfully for ' + audienceMembers.size() + ' Audience Members.';
        responses.add(response);

        return responses;
    }

    /**
     * Request wrapper class for Audience CSV generation.
     */
    public class CSVAudienceRequest {
        @InvocableVariable(label='Audience ID' description='ID of the Audience to fetch members from.' required=true)
        public Id audienceId;

        @InvocableVariable(label='Status' description='Attendance status (Attended, Absent, Exempt, Registered, Unregistered, Waitlisted).' required=true)
        public String status;

        @InvocableVariable(label='Registration Type' description='Registration type (Virtual or Physical).' required=true)
        public String registrationType;

        @InvocableVariable(label='File Name' description='Desired filename for the CSV file (without .csv extension).' required=true)
        public String fileName;
    }

    /**
     * Inner class representing the CSV response structure.
     */
    public class CSVResponse {
        @InvocableVariable(label='Content Document ID' description='The ID of the generated ContentDocument.')
        public Id contentDocumentId;

        @InvocableVariable(label='Download URL' description='Download URL for the generated CSV file.')
        public String downloadUrl;

        @InvocableVariable(label='Summary' description='Text summary confirming CSV generation.')
        public String summary;
    }
}