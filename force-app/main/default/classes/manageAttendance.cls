public with sharing class manageAttendance {
   
    // Attendance tracker emailtemplate
    public String emailLink;
    public String rId {get; set;}
  
    @AuraEnabled
    public static ResponseData checkAttendance(String code,String eventId,String learnerId) {
        ResponseData rd = new ResponseData();
        try {
            List<Session__c > ea = [SELECT  Id, Attendance_Code_2__c  
                                                FROM Session__c 
                                                WHERE Id = :eventId 
                                                AND Attendance_Code_2__c =: code
                                                WITH USER_MODE];
            System.debug('Activity '+ea);
            if(!ea.isEmpty()) {
                updateAttendance(eventId, learnerId, rd);                              
            } else {
                rd.put('isSuccess', false);
                rd.put('errMsg', 'Invalid event code. Please try again or contact the event facilitator.');                
            }            
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd;
    }
    
    @AuraEnabled(cacheable = true)
    public static String getActivity(String recordId) {
        ResponseData rd = new ResponseData();
        List<Session__c> eactlist =  [SELECT Name, Attendance_Code_2__c, Bitly_QR_Code_Id__c FROM Session__c WHERE Id = :recordId WITH USER_MODE];
        if(!eactlist.isEmpty()) {
            rd.put('attendanceCode', eactlist[0].Attendance_Code_2__c); 
            rd.put('qrCodeId', eactlist[0].Bitly_QR_Code_Id__c);
        } else {
            rd.addError('No Event record fetched.');
        }
        return rd.getJSONString();
    }

    public static void updateAttendance(String eventId, String learnerId, ResponseData rd) {    
        try {
            if (String.isEmpty(eventId)) {
                rd.put('isSuccess', false);
                rd.put('errMsg', 'Null event id');
                return;
            }

            List<assigned_session__c > assigned_session = [SELECT  Id, status__c, Asset__r.Mandatory_Session_Count__c
                                                FROM assigned_session__c 
                                                WHERE Session__c =: eventId 
                                                AND Learner_Profile__r.User__c =: learnerId
                                                WITH USER_MODE];
            List<assigned_session__c > no_assigned_session = [SELECT  Id, status__c, Asset__r.Mandatory_Session_Count__c
                                    FROM assigned_session__c 
                                    WHERE Session__c =: eventId
                                    WITH USER_MODE];

            if (!assigned_session.isEmpty()) {
                    if(assigned_session[0].Status__c == 'Attended') {
                        rd.put('message', 'Success! Thanks for attending the event.');
                        rd.put('isSuccess', true);
                    } else {
                        assigned_session[0].Status__c = 'Attended';
                        update assigned_session;
                        rd.put('message', 'Success! Thanks for attending the event.');
                        rd.put('isSuccess', true);
                    }             
            } else {
                Id assetId;
                Integer requiredSessionCount;
                if (no_assigned_session.isEmpty()) {
                    // assetId = [SELECT Asset__c FROM Session__c WHERE Id =: eventId WITH USER_MODE LIMIT 1]?.Asset__c;
                    Session__c session = [SELECT Asset__r.Mandatory_Session_Count__c 
                                            FROM Session__c 
                                            WHERE Id =: eventId 
                                            WITH USER_MODE 
                                            LIMIT 1];
                    assetId = session.Asset__r.Id;
                    requiredSessionCount = Integer.valueOf(session.Asset__r.Mandatory_Session_Count__c);
                } else {
                    assetId = no_assigned_session[0].Asset__r.Id;
                    requiredSessionCount =  Integer.valueOf(no_assigned_session[0].Asset__r.Mandatory_Session_Count__c);
                }

                // create new assignment because user has attended an event and has that event's attendance code
               // Id recordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Session').getRecordTypeId();                
                Learner_Profile__c lp = [SELECT Id, User__c FROM Learner_Profile__c WHERE User__c =: learnerId AND Status__c = 'Active'];
                if(lp != null) {
                    Assignment__c assigment = getUserAssignment(assetId, requiredSessionCount, lp);
                    // if(requiredSessionCount > 1) {
                    //     assigment.Completed_Session_Count__c += 1;
                    //     if(assigment.Completed_Session_Count__c == requiredSessionCount) {
                    //         assigment.Completed__c = true;
                    //         assigment.Completion_Date__c = System.today();
                    //     } 
                    //     assigment.Mandatory_Session_Count__c = requiredSessionCount;
                    // } else {
                    //     assigment.Completed__c = true;
                    //     assigment.Completion_Date__c = System.today();
                    // }
                    
                    upsert assigment;
                    assigned_session__c newAssign_Session = new assigned_session__c(
                        Status__c = 'Attended',
                        Session__c = eventId,
                        Learner_Profile__c = lp.Id,
                        //OwnerId = learnerId,
                        Assignment__c = assigment.id,
                        Registration_Date_Time__c = DateTime.now(),
                        Asset__c = assetId,
                        Self_Registered__c = true
                    );
                    insert newAssign_Session;
                    rd.put('message', 'Success! Thanks for attending the event.');
                    rd.put('isSuccess', true);
                } else {
                    rd.put('isSuccess', false);
                    rd.put('errMsg', 'Invalid Learner Profile.' + learnerId);
                }                
            }
        } catch (Exception e) {
            rd.addError(e);
        }   
    }

    public static Assignment__c getUserAssignment(Id assetId, Integer requiredSessionCount, Learner_Profile__c lpId) {
        List<Assignment__c> assignment = [SELECT Id, Completed_Session_Count__c, Mandatory_Session_Count__c, Learner_Profile__c, Asset__c, 
                                            Self_Assigned__c, Completed__c, Completion_Date__c
                                            FROM Assignment__c
                                            WHERE Asset__c =: assetId
                                            AND Learner_Profile__c =: lpId.Id
                                            WITH USER_MODE 
                                            LIMIT 1];
        if(!assignment.isEmpty()) {
            return assignment[0];
        } else {
            Assignment__c newAssignment = new Assignment__c(
                Learner_Profile__c = lpId.Id,
                OwnerId = lpId.User__c,
                Asset__c = assetId,
                Self_Assigned__c = true,
                Completed_Session_Count__c = 0,
                Completion_Date__c = null,
                Completed__c = false,
                Mandatory_Session_Count__c = requiredSessionCount
            );
            return newAssignment;
        }
    }

    // public String getEmailLink() {
    //     String emailLink = '';
    //     if(String.isNotEmpty(rId)) {
    //         Session__c fea = [SELECT Id, Name, Attendance_Code__c 
    //                           FROM Session__c 
    //                           WHERE Id =: rId
    //                           WITH USER_MODE];
            
    //         emailLink = getSiteURL(fea.Id, fea.Attendance_Code__c, false);
    //     }
    //     return emailLink;      
    // }

    @AuraEnabled(cacheable = true)
    public static String getSiteURL(String eventId, String attendanceCode, boolean forQRCode) {
        String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();
        String emailLink;
        if(sfUrl.contains('readiness--act2dev')){
            emailLink = 'https://readiness--act2dev.sandbox.my.site.com/act' + '/event-detail?id='+eventId;
        } else if(sfUrl.contains('readiness--act2qa')) {
            emailLink = 'https://readiness--act2qa.sandbox.my.site.com/act' + '/event-detail?id='+eventId;
        } else if(sfUrl.contains('readiness--act2uat')) {
            emailLink = 'https://readiness--act2uat.sandbox.my.site.com/act' + '/event-detail?id='+eventId;
        } else if(sfUrl.contains('readiness.my')) {
            emailLink = 'https://readiness.my.site.com/act' + '/event-detail?id='+eventId;
        } else if(sfUrl.contains('readiness--chrisdev1')) { // Remove this
            emailLink = 'https://readiness--chrisdev1.sandbox.my.site.com/act' + '/event-detail?id='+eventId;
        } else {
            emailLink = 'https://readiness--act2dev.sandbox.my.site.com/act' + '/event-detail?id='+eventId;
        }

        if(forQRCode) {
            emailLink = emailLink+'&attendanceCode='+attendanceCode;
            return EncodingUtil.urlEncode(emailLink, 'UTF-8');
        } else {
            return emailLink;
        }        
    }

    @AuraEnabled(cacheable=true)
    public static String getQrCodeSvg(String qrCodeId) {
        ResponseData rd = new ResponseData();
        Map<String,String> headerMap = new Map<String,String>();

        try {
            headerMap.put('Authorization', 'Bearer ' + Constants.BITLY_API_TOKEN);
            headerMap.put('Accept', 'application/json');

            HttpResponse res =  Utilities.makeCallout(Constants.BITLY_QR_CODE_URL + '/' + qrCodeId + '/image', 'GET', headerMap);
            
            if (res.getStatusCode() != 200) {
                rd.addError('Error retrieving the QR code SVG: ' + res.getStatus());
            } else {
                rd.put('qrCode', res.getBody());
            }
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJSONString();
    }
}