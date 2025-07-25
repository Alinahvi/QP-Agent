public with sharing class UploadSessionAttendeesByCsv {

    @AuraEnabled
    public static ResponseData processEmails(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {

            SessionAttendeesPayload payload = (SessionAttendeesPayload) JSON.deserialize(jsonString, SessionAttendeesPayload.class);

            Map<String, String> registrationTypesByEmail = new Map<String, String>();
            Map<String, String> statusByEmail = new Map<String, String>();
            Set<String> emails = new Set<String>();
            Session__c session;
            String sessionType = '';

            for (CsvData csvData : payload.csvData) {
                registrationTypesByEmail.put(csvData.email, csvData.registrationType);
                statusByEmail.put(csvData.email, csvData.status);
                emails.add(csvData.email);
            }

            if(payload.sessionId != null){
                session = [SELECT Name, Asset__c, Asset__r.Event_Type__c, Session_Type__c FROM Session__c WHERE Id = :payload.sessionId WITH USER_MODE LIMIT 1];
                sessionType = session.Session_Type__c;
            }

            List<Learner_Profile__c> lps = [SELECT Id, Name, Primary_Email__c 
                                                FROM Learner_Profile__c 
                                                WHERE Primary_Email__c =: registrationTypesByEmail.keySet() 
                                                AND Primary_Email__c != null 
                                                AND Status__c = 'Active'
                                                WITH USER_MODE];

            List<Map<String, Object>> lpsToProcess = new List<Map<String, Object>>();
            
            for(Learner_Profile__c lp : lps){
                emails.remove(lp.Primary_Email__c);
                Map<String, Object> lpToProcess = lp.getPopulatedFieldsAsMap().clone();
                String csvRegType = registrationTypesByEmail.get(lp.Primary_Email__c);
                lpToProcess.put('Registration_Type__c', String.isNotEmpty(csvRegType) ? csvRegType : sessionType);
                lpToProcess.put('Status__c', statusByEmail.get(lp.Primary_Email__c));

                lpsToProcess.add(lpToProcess);
            }

            List<Map<String, Object>> notFound = new List<Map<String, Object>>();

            for(String email : emails){
                notFound.add(new Map<String, Object>{
                    'id' => UUID.randomUUID().toString(),
                    'name' => email,
                    'sessionName' => session?.name,
                    'reason' => 'No Learner Profile found'
                });
            }
            
            rd.put('notFound', notFound);
            rd.put('lpsToProcess', lpsToProcess);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd;
        //return processEmailsViaAssignments(payload);
        /* Depreacted for now as we're switching this to onl be assignments - 11/22/2023
        if (payload.eventType == 'Course') {
            return processEmailsViaAssignments(payload);
        } else {
            return processEmailsViaLearnerProfile(payload);
        }*/
    }

    // @AuraEnabled
    // public static ResponseData processEmailsViaAssignments(SessionAttendeesPayload payload){
    //     ResponseData rd = new ResponseData();
        
    //     try {
    //         Map<String, String> registrationTypesByEmail = new Map<String, String>();
    //         Map<String, String> statusByEmail = new Map<String, String>();

    //         for (CsvData csvData : payload.csvData) {
    //             registrationTypesByEmail.put(csvData.email, csvData.registrationType);
    //             statusByEmail.put(csvData.email, csvData.status);
    //         }

    //         Set<String> newEmails = new Set<String>(registrationTypesByEmail.keySet());

    //         List<Map<String, Object>> newLPs = new List<Map<String, Object>>();
    //         List<Map<String, Object>> existingLPs = new List<Map<String, Object>>();
    //         List<Map<String, Object>> invalidLps = new List<Map<String, Object>>();

    //         // String lastProcessedId = String.isNotEmpty(payload.lastProcessedId) ? payload.lastProcessedId : '';
    //         Map<String, Assignment__c> assignmentByLp = new Map<String, Assignment__c>();
    //         List<Id> assignmentIds = new List<Id>();
    //         Map<String, Assigned_Session__c> aSessionByLp = new Map<String, Assigned_Session__c>();
    //         Map<String, Recommended_Learning__c> recLearningByLp = new Map<String, Recommended_Learning__c>();

    //         List<Learner_Profile__c> lps = [SELECT Id, Name, Primary_Email__c 
    //                                         FROM Learner_Profile__c 
    //                                         WHERE Primary_Email__c =: newEmails 
    //                                         AND Primary_Email__c != null 
    //                                         AND Status__c = 'Active'
    //                                         WITH USER_MODE];
    //         Session__c session = [SELECT Asset__c, Asset__r.Event_Type__c, Session_Type__c FROM Session__c WHERE Id = :payload.sessionId WITH USER_MODE LIMIT 1];
    //         String sessionType = session.Session_Type__c;




    //         for (Assignment__c assignment : [SELECT Id, Completed__c, Learner_Profile__c, Learner_Profile__r.Name, Learner_Profile__r.Primary_Email__c
    //                                          FROM Assignment__c
    //                                          WHERE Asset__c =: payload.assetId 
    //                                          AND Learner_Profile__r.Primary_Email__c =: newEmails
    //                                          WITH USER_MODE]) {
    //             assignmentByLp.put(assignment.Learner_Profile__c, assignment);
    //             assignmentIds.add(assignment.Id);
    //         }

    //         for (Assigned_Session__c aSession : [SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, 
    //                                              Learner_Profile__r.Primary_Email__c, Assignment__c, Assignment__r.Completed__c, Status__c, Registration_Type__c
    //                                              FROM Assigned_Session__c
    //                                             //  WHERE Assignment__c IN: assignmentIds
    //                                              WHERE Session__c =: payload.sessionId
    //                                              WITH USER_MODE]) {
    //             aSessionByLp.put(aSession.Learner_Profile__c, aSession);                
    //         }

    //         for (Recommended_Learning__c rec : [SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, 
    //                                             Learner_Profile__r.Primary_Email__c, Status__c
    //                                             FROM Recommended_Learning__c
    //                                             WHERE Learner_Profile__r.Primary_Email__c IN: newEmails
    //                                             AND Asset__c =: session.Asset__c
    //                                             AND Status__c = 'Active'
    //                                             WITH USER_MODE]) {
    //             recLearningByLp.put(rec.Learner_Profile__c, rec);
    //         }

    //         for(Learner_Profile__c lp : lps){
    //             Assignment__c assignment = assignmentByLp.get(lp.Id);
    //             Assigned_Session__c aSession = aSessionByLp.get(lp.Id);
    //             Recommended_Learning__c recLearning = recLearningByLp.get(lp.Id);
    //             String currentRegistrationType = registrationTypesByEmail.get(lp.Primary_Email__c);
    //             String csvRegType = registrationTypesByEmail.get(lp.Primary_Email__c);

    //             if(assignment == null && recLearning == null){
    //                 invalidLps.add(new Map<String, Object>{
    //                     'Primary_Email__c' => lp.Primary_Email__c,
    //                     'Error' => 'A Learner must have a recommended learning or be assigned the event before they can join'
    //                 });
    //             } else if (session.Asset__r.Event_Type__c == 'Course' && assignment != null && assignment.Completed__c) {
    //                 existingLPs.add(new Map<String, Object>{
    //                     'Id' => lp.Id,
    //                     'Primary_Email__c' => lp.Primary_Email__c,
    //                     'Name' => lp.Name,
    //                     'Registration_Type__c' => String.isNotEmpty(csvRegType) ? csvRegType : sessionType,
    //                     'Status__c' => statusByEmail.get(lp.Primary_Email__c),
    //                     'noChange' => true,
    //                     'modified' => 'No Change. Assignment has already been completed.'
    //                 });
    //             } else if (aSession != null) {
    //                 String modifiedMessage = 'Status Modified';
    //                 String status = statusByEmail.get(lp.Primary_Email__c);
    //                 Boolean noChange = false;

    //                 if(aSession.Assignment__r.Completed__c){
    //                     modifiedMessage = 'No Change. Assignment has already been completed.';
    //                     noChange = true;
    //                 } else if (status != aSession.Status__c) {
    //                     modifiedMessage = 'Status Modified';
    //                     noChange = false;
    //                 } else {
    //                     modifiedMessage = 'No Change';
    //                     noChange = true;
    //                 }

    //                 existingLPs.add(new Map<String, Object>{
    //                     'Id' => lp.Id,
    //                     'Primary_Email__c' => lp.Primary_Email__c,
    //                     'Name' => lp.Name,
    //                     'Registration_Type__c' => String.isNotEmpty(csvRegType) ? csvRegType : sessionType,
    //                     'Status__c' => status,
    //                     'modified' => modifiedMessage,
    //                     'noChange' => noChange
    //                 });
    //             } else if (!validRegistrationType(sessionType, currentRegistrationType)) {
    //                 invalidLps.add(new Map<String, Object>{
    //                     'Primary_Email__c' => lp.Primary_Email__c,
    //                     'Error' => 'INVALID TYPE: ' + currentRegistrationType
    //                 });
    //             } else {
    //                 newLps.add(new Map<String, Object>{
    //                     'Id' => lp.Id,
    //                     'Primary_Email__c' => lp.Primary_Email__c,
    //                     'Name' => lp.Name,
    //                     'Registration_Type__c' => String.isNotEmpty(csvRegType) ? csvRegType : sessionType,
    //                     'Status__c' => statusByEmail.get(lp.Primary_Email__c)
    //                 });
    //             } 

    //             newEmails.remove(lp.Primary_Email__c);
    //         }

    //         // Learners Not Found
    //         for (String email : newEmails) {
    //             invalidLps.add(new Map<String, Object>{'Primary_Email__c' => email, 'Error' => 'Learner Not Found'});
    //         }

    //         rd.put('newLPs', newLPs);
    //         rd.put('existingLPs', existingLPs);
    //         rd.put('invalidLps', invalidLps);
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    
    //     return rd;
    // }

    @AuraEnabled
    public static ResponseData processEmailsViaLearnerProfile(SessionAttendeesPayload payload){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, String> registrationTypesByEmail = new Map<String, String>();

            for (CsvData csvData : payload.csvData) {
                registrationTypesByEmail.put(csvData.email, csvData.registrationType);
            }

            Set<String> newEmails = new Set<String>(registrationTypesByEmail.keySet());

            List<Map<String, Object>> newLPs = new List<Map<String, Object>>();
            List<Map<String, Object>> existingLPs = new List<Map<String, Object>>();
            List<Map<String, Object>> invalidLps = new List<Map<String, Object>>();

            String sessionType = [SELECT Session_Type__c FROM Session__c WHERE Id = :payload.sessionId WITH USER_MODE LIMIT 1].Session_Type__c;


            // String lastProcessedId = String.isNotEmpty(payload.lastProcessedId) ? payload.lastProcessedId : '';

            List<Learner_Profile__c> lps = [SELECT Id, Name, User__c, User__r.Name, Primary_Email__c,
                                                ( 
                                                    SELECT Id
                                                    FROM Assigned_Sessions__r
                                                    WHERE Session__c =: payload.sessionId
                                                )
                                            FROM Learner_Profile__c
                                            WHERE Primary_Email__c =: newEmails
                                            AND Status__c = 'Active'
                                            WITH USER_MODE
                                            ORDER BY Name ASC];

            for (Learner_Profile__c lp : lps) {
                String currentRegistrationType = registrationTypesByEmail.get(lp.Primary_Email__c);

                if (!validRegistrationType(sessionType, currentRegistrationType)) {
                    invalidLps.add(new Map<String, Object>{
                        'Primary_Email__c' => lp.Primary_Email__c, 
                        'Error' => getRegistrationTypeErrorMessage(sessionType, currentRegistrationType)
                    });

                    newEmails.remove(lp.Primary_Email__c);

                    continue;
                }

                Map<String, Object> lpMap = new Map<String, Object>(lp.getPopulatedFieldsAsMap());
                lpMap.put('Registration_Type__c', String.isEmpty(currentRegistrationType) ? sessionType : currentRegistrationType);

                if (lp.Assigned_Sessions__r.isEmpty()) {
                    newLPs.add(lpMap);
                } else {
                    existingLPs.add(lpMap);
                }

                newEmails.remove(lp.Primary_Email__c);
            }

            // Learners Not Found
            for (String email : newEmails) {
                invalidLps.add(new Map<String, Object>{'Primary_Email__c' => email, 'Error' => 'Learner Not Found'});
            }
        
            rd.put('newLPs', newLPs);
            rd.put('existingLPs', existingLPs);
            rd.put('invalidLps', invalidLps);
            // rd.put('lastProcessedId', lastProcessedId);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    private static Boolean validRegistrationType(String sessionType, String registrationType) {
        Boolean valid = false;

        switch on sessionType {
            when 'Virtual' {
                valid = String.isEmpty(registrationType) || registrationType == 'Virtual';
            }
            when 'Physical' {
                valid = String.isEmpty(registrationType) || registrationType == 'Physical';
            }
            when 'Hybrid' {
                valid = registrationType == 'Physical' || registrationType == 'Virtual';
            }
            when else {
                valid = false;
            }
        }

        return valid;
    }

    private static String getRegistrationTypeErrorMessage(String sessionType, String registrationType) {
        String errorMessage = '';

        switch on sessionType {
            when 'Virtual' {
                if (registrationType == 'Physical') {
                    errorMessage = 'Physical Sessions Must Be Registered Physically';
                } else {
                    errorMessage = 'Invalid Registration Type: ' + registrationType;
                }
            }
            when 'Physical' {
                if (registrationType == 'Virtual') {
                    errorMessage = 'Virtual Sessions Must Be Registered Virtually';
                } else {
                    errorMessage = 'Invalid Registration Type: ' + registrationType;
                }
            }
            when 'Hybrid' {
                if (String.isEmpty(registrationType)) {
                    errorMessage = 'No Registration Type Specified for Hybrid Session';
                } else {
                    errorMessage = 'Invalid Registration Type: ' + registrationType;
                }
            }
            when else {
                errorMessage = 'Unknown Session Type: ' + sessionType;
            }
        }

        return errorMessage;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getEnablementPrograms(){
        return RecommendedLearners.getEnablementPrograms();
    }

    public class SessionAttendeesPayload {
        public List<CsvData> csvData { get; set; }
        public String sessionId { get; set; }
        public String assetId { get; set; }
        public Integer pageSize { get; set; }
        public String eventType { get; set; }
        // String lastProcessedId;
    }

    public class CsvData {
        public String email { get; set; }
        public String registrationType { get; set; }
        public String status { get; set; }
    }
}