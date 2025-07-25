public with sharing class GAFRA2CSVGeneratorHandler {

    // Valid statuses and registration types for CSV generation
    private static final Set<String> VALID_STATUSES = new Set<String>{
        'Attended', 'Absent', 'Exempt', 'Registered', 'Unregistered', 'Waitlisted'
    };
    private static final Set<String> VALID_REGISTRATION_TYPES = new Set<String>{
        'Virtual', 'Physical'
    };

    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Generate' required=true)
        public String actionType;
        @InvocableVariable(label='Audience ID' description='ID of the Audience to fetch members from.' required=true)
        public String audienceId;
        @InvocableVariable(label='Status' description='Attendance status (Attended, Absent, Exempt, Registered, Unregistered, Waitlisted).' required=true)
        public String status;
        @InvocableVariable(label='Registration Type' description='Registration type (Virtual or Physical).' required=true)
        public String registrationType;
        @InvocableVariable(label='File Name' description='Desired filename for the CSV file (without .csv extension).' required=true)
        public String fileName;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='Content Document ID' description='The ID of the generated ContentDocument.')
        public String contentDocumentId = '';
        @InvocableVariable(label='Download URL' description='Download URL for the generated CSV file.')
        public String downloadUrl = '';
    }

    @InvocableMethod(label='GA-FRA2 Generate CSV from Audience' description='Generates CSV for Audience Members with provided Status and Registration Type.')
    public static List<Response> generateCSV(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                if (req.actionType == 'Generate') {
                    handleGenerate(req, res);
                } else {
                    res.message = 'Error: Invalid action type. Must be Generate.';
                }
            } catch (Exception e) {
                res.message = 'Error: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        
        return responses;
    }

    private static void handleGenerate(Request req, Response res) {
        if (!VALID_STATUSES.contains(req.status)) {
            res.message = 'Error: Invalid Status: ' + req.status;
            return;
        }
        if (!VALID_REGISTRATION_TYPES.contains(req.registrationType)) {
            res.message = 'Error: Invalid Registration Type: ' + req.registrationType;
            return;
        }

        // Query Audience Member emails
        List<Audience_Member__c> audienceMembers = [
            SELECT Learner_Profile__r.Primary_Email__c
            FROM Audience_Member__c
            WHERE Audience__c = :req.audienceId
        ];

        // Prepare CSV
        List<String> csvLines = new List<String>{'Email,Status,Registration Type'};

        for (Audience_Member__c member : audienceMembers) {
            if (member.Learner_Profile__r != null && String.isNotBlank(member.Learner_Profile__r.Primary_Email__c)) {
                csvLines.add(member.Learner_Profile__r.Primary_Email__c + ',' + req.status + ',' + req.registrationType);
            }
        }

        Blob csvBody = Blob.valueOf(String.join(csvLines, '\n'));

        // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = req.fileName,
            PathOnClient = req.fileName + '.csv',
            VersionData = csvBody
        );
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String downloadUrl = baseUrl + '/sfc/servlet.shepherd/version/download/' + cv.Id;

        res.success = true;
        res.message = 'CSV generated successfully for ' + audienceMembers.size() + ' Audience Members.';
        res.contentDocumentId = cv.ContentDocumentId;
        res.downloadUrl = downloadUrl;
    }
}