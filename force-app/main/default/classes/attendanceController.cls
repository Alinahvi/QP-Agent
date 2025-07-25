public with sharing class attendanceController {
    /* Remove ACT 1 references
    @AuraEnabled(cacheable = false)
    public static string checkAttendance(String code, String eventId, String learnerId) {
        Map<String, Object> result = new Map<String, Object>();
        try {            
            System.debug('Event '+eventId+' Code '+code);
            List<slj__Enablement_Activity__c > ea = [SELECT  Id, slj__Attendance_Code__c  
                                                FROM slj__Enablement_Activity__c 
                                                WHERE Id = :eventId 
                                                AND slj__Attendance_Code__c =: code
                                                WITH USER_MODE];
            System.debug('Activity '+ea);
            if(!ea.isEmpty()) {
                String message = updateAttendance(eventId, learnerId, result); 
                return message;                              
            } else {
                result.put('isSuccess', false);
                result.put('message', 'Invalid event code. Please try again or contact the event facilitator.');
                return JSON.serialize(result);
            }
        } catch(Exception e ) {
            result.put('isSuccess', false);
            result.put('message', 'Error: '+e.getmessage()+' : attendanceController.checkAttendance');
            return JSON.serialize(result);
        }        
    }

    @AuraEnabled(cacheable = false)
    public static slj__Enablement_Activity__c getActivity(String recordId, String learnerId) {
        List<slj__Enablement_Activity__c> eactlist =  [SELECT Name, slj__Attendance_code__c, slj__Regions__c, slj__Description__c,
                                                        (SELECT Id, slj__Event_Status__c 
                                                        FROM slj__Assignments__r 
                                                        WHERE slj__Event_Status__c = 'Attended'
                                                        AND slj__Learner_Profile__r.slj__User__c =: learnerId) 
                                                       FROM slj__Enablement_Activity__c 
                                                       WHERE Id = :recordId
                                                       WITH USER_MODE];
        return eactlist[0];
    }

    
    public static String updateAttendance(String eventId, String learnerId, Map<String, Object> result) {    
        try {
            List<slj__Assignment__c > assignment = [SELECT  Id, slj__Event_Status__c 
                                                FROM slj__Assignment__c 
                                                WHERE slj__Enablement_Activity__c =: eventId 
                                                AND slj__Learner_Profile__r.slj__User__c =: learnerId
                                                WITH USER_MODE];
            if (!assignment.isEmpty()) {
                    if(assignment[0].slj__Event_Status__c != 'Attended') {
                        assignment[0].slj__Event_Status__c = 'Attended';
                        update as user assignment;                        
                    } 
                    result.put('isSuccess', true);
                    result.put('message', 'Success! Thanks for attending the event.');           
            } else {
                // create new assignment because user has attended different event and has that event's attendance code
                Id recordTypeId = Schema.SObjectType.slj__Assignment__c.getRecordTypeInfosByDeveloperName().get('Enablement_Activity').getRecordTypeId();                
                slj__Learner_Profile__c lp = [SELECT Id, slj__User__c FROM slj__Learner_Profile__c WHERE slj__User__c =: learnerId WITH USER_MODE];
                if(lp != null) {
                    slj__Assignment__c newAssignment = new slj__Assignment__c(
                        slj__Event_Status__c = 'Attended',
                        slj__Status__c = 'Completed',
                        slj__Enablement_Activity__c = eventId,
                        slj__Learner_Profile__c = lp.Id,
                        OwnerId = learnerId,
                        recordTypeId = recordTypeId
                    );
                    insert as user newAssignment;
                    
                    result.put('isSuccess', true);
                    result.put('message', 'Success! Thanks for attending the event.');
                } else {
                    result.put('isSuccess', false);
                    result.put('message', 'Invalid event code. Please try again or contact the event facilitator.');
                }                
            }   
        } catch (Exception e) {
            result.put('isSuccess', false);
            result.put('message', 'Error: '+e.getmessage()+' : attendanceController.updateAttendance');            
        }
        return JSON.serialize(result); 
    }   
    */
}