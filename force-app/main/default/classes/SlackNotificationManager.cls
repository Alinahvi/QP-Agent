public with sharing class SlackNotificationManager {
    private static String ASSIGNED = System.Label.Assigned;
    private static String REMINDER = System.Label.Reminder;
    private static String OVERDUE = System.Label.Overdue;
    private static String ESCALATION = System.Label.Escalation;
    private static String SURVEY = System.Label.Survey;
    private static String ASSIGNED_EVENT = System.Label.Assigned_event;
    private static String RECOMMENDATION = System.Label.Recommendation;

    @AuraEnabled
    public static String getNotificationMetaData(Id recordId) {
        ResponseData rd = new ResponseData();
        try {
			List<Map<String, Object>> objList = new List<Map<String, Object>>();			
			Boolean isEvent = false;
            String isEventType = '';
            SObjectType sObjType = recordId.getSobjectType();
            if(sObjType == Asset__c.getSObjectType()) {
                Asset__c asset = [SELECT Id, RecordType.developerName, Event_Type__c FROM Asset__c WHERE Id = :recordId];
                if(asset != null && asset.RecordType.developerName == 'Event') {
                    isEvent = true;
                    isEventType = asset.Event_Type__c;
                } 
            }
            Boolean isSession = sObjType == Session__c.getSObjectType() ? true : false;
            if(isSession) {
                Session__c session = [SELECT Id, Asset__r.Event_Type__c FROM Session__c WHERE Id = :recordId];
                if(session != null && session.Asset__r != null) {
                    isEventType = session.Asset__r.Event_Type__c == 'Course' ? 'Course' : '';
                }
            }
            Boolean isCurrciculum = sObjType == Curriculum__c.getSObjectType() ? true : false;
            Boolean isCourse = sObjType == Course__c.getSObjectType() ? true : false;
            Boolean isAsset = sObjType == Asset__c.getSObjectType() ? true : false;
            Map<String, String> mapObj;
            if(isAsset && isEvent) {
                objList.add(new Map<String, String>{'name' => 'Assigned Event', 'description' => ASSIGNED_EVENT});
                if(isEventType != 'Course') {
                    objList.add(new Map<String, String>{'name' => 'Recommendation', 'description' => RECOMMENDATION});
                }                
            } else if(isSession) {
                objList.add(new Map<String, String>{'name' => 'Survey', 'description' => SURVEY});
                if(isEventType != 'Course') {
                    objList.add(new Map<String, String>{'name' => 'Recommendation', 'description' => RECOMMENDATION});
                }                
            } else if(isCourse) { // isCurrciculum) {
                objList.add(new Map<String, String>{'name' => 'Assigned', 'description' => ASSIGNED});
                objList.add(new Map<String, String>{'name' => 'Reminder', 'description' => REMINDER});
                objList.add(new Map<String, String>{'name' => 'Overdue', 'description' => OVERDUE});
                objList.add(new Map<String, String>{'name' => 'Escalation', 'description' => ESCALATION});
                objList.add(new Map<String, String>{'name' => 'Recommendation', 'description' => RECOMMENDATION});
                objList.add(new Map<String, String>{'name' => 'Survey', 'description' => SURVEY});                                
            } else { //single asset and curriculum
                objList.add(new Map<String, String>{'name' => 'Assigned', 'description' => ASSIGNED});
                objList.add(new Map<String, String>{'name' => 'Reminder', 'description' => REMINDER});
                objList.add(new Map<String, String>{'name' => 'Overdue', 'description' => OVERDUE});
                objList.add(new Map<String, String>{'name' => 'Escalation', 'description' => ESCALATION});
                objList.add(new Map<String, String>{'name' => 'Recommendation', 'description' => RECOMMENDATION});                   
            }
            
			rd.put('notificationData', objList);
		} catch(Exception e) {
			rd.addError(e);
		}
		return rd.getJsonString();
    }

    @AuraEnabled
	public static String getNotificationPreference(Id recordId) { 
		responseData rd = new responseData();
		try {
			if(recordId == null) {
				rd.addError('Parm is empty :');
                return rd.getJsonString();
			}			
			SObjectType sObjType = recordId.getSobjectType();
            String queryStr = 'SELECT Id,';
			if(sObjType == Asset__c.getSObjectType()) {
                queryStr = queryStr + 'Event_Type__c,Send_Assigned_Notification__c,Send_Reminder_Notification__c,Send_Overdue_Notification__c,Send_Escalation_Notification__c,Send_Survey_Notification__c,Send_Recommendation_Notification__c';
                queryStr = queryStr + ',RecordTypeId';
            } else if(sObjType == Session__c.getSObjectType()) {
                queryStr = queryStr + 'Asset__r.Event_Type__c,Send_Survey_Notification__c,Send_Recommendation_Notification__c';
            } else {
                queryStr = queryStr + 'Send_Assigned_Notification__c,Send_Reminder_Notification__c,Send_Overdue_Notification__c,Send_Escalation_Notification__c,Send_Survey_Notification__c, Send_Recommendation_Notification__c';
            }
            queryStr = queryStr + ' FROM ' + sObjType + ' WHERE Id =: recordId';
			List<Object> dataList = Database.query(queryStr);
						
			if(dataList.isEmpty()) {
				rd.addError('No record to fetch.');
				return rd.getJsonString();
			}
			            
			rd.put('preference', getOptInNoit(''+sObjType, dataList));
			rd.put('objectType', ''+sObjType);
		} catch (Exception e) {
            rd.addError(e);
		}
		return rd.getJsonString();
	}

    private static List<String> getOptInNoit(String objType, List<Object> dataList) {
        List<String> optInList = new List<String>();
        switch on (objType) {
            when 'Course__c'{
                Course__c course = (Course__c)dataList[0];
                if(course.Send_Assigned_Notification__c) { optInList.add('Assigned'); }
                if(course.Send_Reminder_Notification__c) { optInList.add('Reminder'); }
                if(course.Send_Overdue_Notification__c) {optInList.add('Overdue'); }
                if(course.Send_Escalation_Notification__c) { optInList.add('Escalation'); }
                if(course.Send_Recommendation_Notification__c) { optInList.add('Recommendation'); }
                if(course.Send_Survey_Notification__c) { optInList.add('Survey'); }
            }
            when 'Curriculum__c' {
                Curriculum__c curr = (Curriculum__c)dataList[0];
                if(curr.Send_Assigned_Notification__c) { optInList.add('Assigned'); }
                if(curr.Send_Reminder_Notification__c) { optInList.add('Reminder'); }
                if(curr.Send_Overdue_Notification__c) { optInList.add('Overdue'); }
                if(curr.Send_Escalation_Notification__c) { optInList.add('Escalation'); }
                if(curr.Send_Recommendation_Notification__c) { optInList.add('Recommendation'); }             
            }
            when 'Asset__c' {
                Id eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
                Asset__c asset = (Asset__c)dataList[0];
                if(asset.RecordTypeId == eventRecordTypeId) {
                    if(asset.Send_Assigned_Notification__c) { optInList.add('Assigned Event'); }
                    if(asset.Event_Type__c != 'Course') {
                        if(asset.Send_Recommendation_Notification__c) { optInList.add('Recommendation'); }
                    }
                    
                } else {
                    if(asset.Send_Assigned_Notification__c) { optInList.add('Assigned'); }
                    if(asset.Send_Reminder_Notification__c) { optInList.add('Reminder'); }
                    if(asset.Send_Overdue_Notification__c) { optInList.add('Overdue'); }
                    if(asset.Send_Escalation_Notification__c) { optInList.add('Escalation'); }
                    if(asset.Send_Recommendation_Notification__c) { optInList.add('Recommendation'); }
                    // if(asset.Send_Survey_Notification__c) { optInList.add('Survey'); }
                }
            }
            when else {
                Session__c session = (Session__c)dataList[0];
                if(session.Send_Survey_Notification__c) { optInList.add('Survey'); }
                if(session.Asset__r != null && session.Asset__r.Event_Type__c != 'Course') {
                    if(session.Send_Recommendation_Notification__c) { optInList.add('Recommendation'); }
                }                
            }
        }
        return optInList;
    }

    @AuraEnabled
	public static String saveNotificationPreference(Id recordId, String optOut, String selectedNoti) {
		responseData rd = new responseData();
		try {
			Map<String, Object> selectedNotiMap = (Map<String, Object>)JSON.deserializeUntyped(selectedNoti);
            if(recordId == null) {
				rd.addError('Parameter recordId is required.');
				return rd.getJsonString();
			}

            SObjectType sObjType = recordId.getSobjectType();
            String queryStr = 'SELECT Id,';
			if(sObjType == Asset__c.getSObjectType()) {
                queryStr = queryStr + 'Event_Type__c,Send_Assigned_Notification__c,Send_Reminder_Notification__c,Send_Overdue_Notification__c,Send_Escalation_Notification__c,Send_Survey_Notification__c,Send_Recommendation_Notification__c';
                queryStr = queryStr + ',RecordTypeId';
            } else if(sObjType == Session__c.getSObjectType()) {
                queryStr = queryStr + 'Asset__r.Event_Type__c,Send_Survey_Notification__c,Send_Recommendation_Notification__c';
            } else {
                queryStr = queryStr + 'Send_Assigned_Notification__c,Send_Reminder_Notification__c,Send_Overdue_Notification__c,Send_Escalation_Notification__c,Send_Survey_Notification__c,Send_Recommendation_Notification__c';
            }
            queryStr = queryStr + ' FROM ' + sObjType + ' WHERE Id =: recordId';
			String type = ''+sObjType;
            switch on (type) {
                when 'Course__c' {
                    List<Course__c> dataList = Database.query(queryStr);
                    dataList[0].Send_Assigned_Notification__c = (Boolean)selectedNotiMap.get('Assigned');
                    dataList[0].Send_Reminder_Notification__c = (Boolean)selectedNotiMap.get('Reminder');
                    dataList[0].Send_Overdue_Notification__c = (Boolean)selectedNotiMap.get('Overdue');
                    dataList[0].Send_Escalation_Notification__c = (Boolean)selectedNotiMap.get('Escalation');
                    dataList[0].Send_Recommendation_Notification__c = (Boolean)selectedNotiMap.get('Recommendation');
                    dataList[0].Send_Survey_Notification__c = (Boolean)selectedNotiMap.get('Survey');
                    update as user dataList;
                } 
                when 'Curriculum__c' {
                    List<Curriculum__c> dataList = Database.query(queryStr);
                    dataList[0].Send_Assigned_Notification__c = (Boolean)selectedNotiMap.get('Assigned');
                    dataList[0].Send_Reminder_Notification__c = (Boolean)selectedNotiMap.get('Reminder');
                    dataList[0].Send_Overdue_Notification__c = (Boolean)selectedNotiMap.get('Overdue');
                    dataList[0].Send_Escalation_Notification__c = (Boolean)selectedNotiMap.get('Escalation');
                    dataList[0].Send_Recommendation_Notification__c = (Boolean)selectedNotiMap.get('Recommendation');
                    update as user dataList;
                }
                when 'Session__c' {
                    List<Session__c> dataList = Database.query(queryStr);
                    dataList[0].Send_Survey_Notification__c = (Boolean)selectedNotiMap.get('Survey');
                    if(dataList[0].Asset__r != null && dataList[0].Asset__r.Event_Type__c != 'Course') {
                        dataList[0].Send_Recommendation_Notification__c = (Boolean)selectedNotiMap.get('Recommendation');
                    }
                    // update as user dataList;
                    update as user (new Session__c(
                        Id = dataList[0].Id,
                        Send_Survey_Notification__c = dataList[0].Send_Survey_Notification__c,
                        Send_Recommendation_Notification__c = dataList[0].Send_Recommendation_Notification__c
                    ));
                }
                when else {
                    List<Asset__c> dataList = Database.query(queryStr);
                    Id eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
                    if(dataList[0].RecordTypeId == eventRecordTypeId) {
                        dataList[0].Send_Assigned_Notification__c = (Boolean)selectedNotiMap.get('Assigned Event');
                        if(dataList[0].Event_Type__c != 'Course') {
                            dataList[0].Send_Recommendation_Notification__c = (Boolean)selectedNotiMap.get('Recommendation');
                        }                        
                    } else {
                        dataList[0].Send_Assigned_Notification__c = (Boolean)selectedNotiMap.get('Assigned');
                        dataList[0].Send_Reminder_Notification__c = (Boolean)selectedNotiMap.get('Reminder');
                        dataList[0].Send_Overdue_Notification__c = (Boolean)selectedNotiMap.get('Overdue');
                        dataList[0].Send_Escalation_Notification__c = (Boolean)selectedNotiMap.get('Escalation');
                        dataList[0].Send_Recommendation_Notification__c = (Boolean)selectedNotiMap.get('Recommendation');
                        // dataList[0].Send_Survey_Notification__c = (Boolean)selectedNotiMap.get('Survey');
                    }
                    update as user dataList;
                }
            }
            rd.put('recordUpdated', true);
		} catch(Exception e) {
			rd.addError(e);
		}
		return rd.getJsonString();
	}     
}