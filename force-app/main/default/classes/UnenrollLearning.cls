public with sharing class UnenrollLearning {

    @AuraEnabled
    public static ResponseData blockSelfEnrollment(String unenrollJSONStr) {
        Map<String, Object> unenrollData = (Map<String, Object>) JSON.deserializeUntyped(unenrollJSONStr);
        List<Learner_Profile__c> lp = [SELECT Id FROM Learner_Profile__c WHERE User__c =: UserInfo.getUserId()];
        if(lp.isEmpty()) {
            ResponseData rd = new ResponseData();
            rd.addError('No Learner Profile found. Please contact support for help');
            return rd;
        }
        ResponseData rd = unenrollUserLearning(unenrollJSONStr);
        if(rd.isSuccess) {
           try {
                // RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'ACT_Unenroll_Learning_Case_Type'];
                // Case unEnrollCase = new Case();
                // unEnrollCase.RecordTypeId = rt.Id;
                // unEnrollCase.Unenroll_Reason__c = (String)unenrollData.get('unenrollReason');
                // unEnrollCase.Unenroll_Comment__c = (String)unenrollData.get('unenrollComment');
                // unEnrollCase.Status = 'Closed';
                // unEnrollCase.Learner_Profile__c	 = lp[0].Id;

                // if(objType == 'Assigned_Curriculum__c') {
                //     unEnrollCase.Curriculum__c = (String)unenrollData.get('learningId');          
                // } else if(objType == 'Assigned_Course__c') {
                //     unEnrollCase.Course__c = (String)unenrollData.get('learningId');
                // } else {
                //     unEnrollCase.Asset__c =  (String)unenrollData.get('learningId');
                // }

                // insert as user unEnrollCase;
            } catch(Exception e) {
                rd.addError(e);
            }
        }
        return rd;
    }
    
    @AuraEnabled
    public static ResponseData unenrollUserLearning(String unenrollJSONStr) {
        ResponseData rd = new ResponseData();
        Map<String, Object> unenrollData = (Map<String, Object>) JSON.deserializeUntyped(unenrollJSONStr);
        List<Learner_Profile__c> lp = [SELECT Id FROM Learner_Profile__c WHERE User__c =: UserInfo.getUserId()];
        if(!lp.isEmpty()) {
            String objId = (String)unenrollData.get('Id');

            if(String.isEmpty(objId)) {
                rd.addError('Learning Id is NULL'); 
                return rd; 
            }

            String objType = ((Id)objId).getSObjectType() + '';
            if(objType == 'Assigned_Curriculum__c') {
                rd = unenrollAssignedCurriulum(objId, lp[0].Id);
            } else if(objType == 'Assigned_Course__c') {
                rd = unenrollAssignedCourse(objId, lp[0].Id);
            } else { 
                rd = unenrollSoloAssigment(objId, lp[0].Id);
            }

            createLearningHistory(unenrollData);

        } else {
            rd.addError('No Learner Profile found. Please contact support for help');           
        }
        return rd;
    }

    public static void createLearningHistory(Map<String, Object> unenrollData) {        
        List<Learning_History__c> lhs = generateLearningHistories(new List<String>{(String)unenrollData.get('Id')}, (String)unenrollData.get('unenrollReason'), (String)unenrollData.get('unenrollComment'));
        insert lhs;
    }

    public static List<Learning_History__c> generateLearningHistories(List<String> assignedIds, String unenrollReason, String unenrollComment) {
        List<Learning_History__c> lhs = new List<Learning_History__c>();
        String objType = Id.valueOf(assignedIds.get(0)).getSObjectType() + '';
        Set<String> fields = new Set<String>{'Id', 'CreatedDate', 'Assigned_Learning__r.OU_Leader__c', 'Assigned_Learning__r.Content_Distribution_Organization__c', 
                                                'Assigned_Learning__r.Start_Date__c', 'Assigned_On__c', 'Self_Assigned__c'};

        String soqlString = 'SELECT ' + String.join(new List<String>(fields), ',') +
                            ' FROM ' + objType +
                            ' WHERE Id IN :assignedIds' +
                            ' WITH USER_MODE';

        List<sObject> assignedDatas = Database.query(soqlString);

        for(sObject assignedData : assignedDatas) {
            Assigned_Learning__c assignedLearning = (Assigned_Learning__c) assignedData.getSObject('Assigned_Learning__r');
            Date enrolledOn = assignedData.get('Assigned_On__c') != null ? (Date)assignedData.get('Assigned_On__c') : ((DateTime)assignedData.get('CreatedDate')).dateGMT();

            Learning_History__c lh = new Learning_History__c(
                Due_Date__c = assignedLearning?.Start_Date__c,
                Assigned_Learning__c = assignedLearning?.Id,
                Leader__c = assignedLearning?.OU_Leader__c,
                Assigning_Org__c = assignedLearning?.Content_Distribution_Organization__c,
                Assigned_On__c = enrolledOn,
                Self_Assigned__c = (Boolean)assignedData.get('Self_Assigned__c'),
                Unenrollment_Comment__c = unenrollComment,
                Unenrollment_Reason__c = unenrollReason,
                Unenrollment_Date__c = Date.today()
            );
    
            lh.put(objType, (String)assignedData.get('Id'));

            lhs.add(lh);
        }

        return lhs;
    }

    @AuraEnabled
    public static ResponseData checkBlockUnenrollment(String learningId, String type) {
        Map<String, Object> learningDetail = new Map<String, Object>();
        Learner_Profile__c lp = [SELECT Id FROM Learner_Profile__c WHERE User__c =: UserInfo.getUserId()];
        if(lp == null) {
            ResponseData rd = new ResponseData();
            rd.addError('No learner profile Id found');
            return rd;
        }
        String lpId = lp.Id;
        String query = 'Select Id, Self_Assigned__c, Assigned_Curriculum__r.Curriculum__r.Name, Assigned_Curriculum__r.Curriculum__r.Block_Unenrollment__c, ';
        query += 'Assigned_Course__r.Course__r.Name, Assigned_Course__r.Course__r.Block_Unenrollment__c, ';
        query += 'Asset__r.Name, Asset__r.Block_Unenrollment__c from Assignment__c where ';
        query += 'Learner_Profile__c =: lpId and ';
        if(type == 'Assigned_Curriculum__c') {
            query += 'Assigned_Curriculum__c =: learningId LIMIT 1';
        } else if(type == 'Assigned_Course__c') {
            query += 'Assigned_Course__c =: learningId LIMIT 1';
        } else {
            query += 'Id =: learningId LIMIT 1';
        }
        
        System.debug('Query str ------------ lpId ' + lpId);
        System.debug('Query str ------------ learningId '+learningId);
        System.debug('Query str ------------ '+query);
        try{
            List<Object> objList = Database.query(query); 
            if(objList.isEmpty()) {
                ResponseData rd = new ResponseData();
                rd.addError('Please contact support for further assistance.');
                return rd;
            }
            ResponseData rd;
            Assignment__c ac = (Assignment__c)objList[0];
            Boolean hasAssignedCurr = ac.Assigned_Curriculum__c != null ? true : false;
            Boolean hasAssignedCr = ac.Assigned_Course__c != null ? true : false;

            if(hasAssignedCurr) {
                if(ac.Self_Assigned__c || !ac.Assigned_Curriculum__r.Curriculum__r.Block_Unenrollment__c) {
                    rd = unenrollAssignedCurriulum(ac.Assigned_Curriculum__r.Id, lp.Id);
                    if(rd.isSuccess) {
                        rd.put('unenrolled', true);
                    }
                } else {
                    rd = new ResponseData();
                    rd.put('Id', ac.Assigned_Curriculum__r.Id);
                    rd.put('learningName', ac.Assigned_Curriculum__r.Curriculum__r.Name);
                    rd.put('learningId', ac.Assigned_Curriculum__r.Curriculum__r.Id);
                    rd.put('isBlockUnenrollment', ac.Assigned_Curriculum__r.Curriculum__r.Block_Unenrollment__c);
                    rd.put('hasParent', type == 'Assignment__c' ? true : false);
                }
            } else if(hasAssignedCr) {
                if(ac.Self_Assigned__c || !ac.Assigned_Course__r.Course__r.Block_Unenrollment__c) {
                    rd = unenrollAssignedCourse(ac.Assigned_Course__r.Id, lp.Id);
                    if(rd.isSuccess) {
                        rd.put('unenrolled', true);
                    }
                } else {
                    rd = new ResponseData();
                    rd.put('Id', ac.Assigned_Course__r.Id);
                    rd.put('learningName', ac.Assigned_Course__r.Course__r.Name);
                    rd.put('learningId', ac.Assigned_Course__r.Course__r.Id);
                    rd.put('isBlockUnenrollment', ac.Assigned_Course__r.Course__r.Block_Unenrollment__c);
                    rd.put('hasParent', type == 'Assignment__c' ? true : false);
                }
            } else {
                if(ac.Self_Assigned__c || !ac.Asset__r.Block_Unenrollment__c) {
                    rd = unenrollSoloAssigment(ac.Id, lp.Id);
                    if(rd.isSuccess) {
                        rd.put('unenrolled', true);
                    }
                } else {
                    rd = new ResponseData();
                    rd.put('Id', ac.Id);
                    rd.put('learningName', ac.Asset__r.Name);
                    rd.put('learningId', ac.Asset__r.Id);
                    rd.put('isBlockUnenrollment', ac.Asset__r.Block_Unenrollment__c);
                    rd.put('hasParent', false);
                }
            }

            if(rd.results.get('unenrolled') != null && (Boolean)rd.results.get('unenrolled')) {
                createLearningHistory(new Map<String, Object>{
                    'Id' => learningId
                });
            }

            return rd;          
        } catch(Exception e) {
            ResponseData rd = new ResponseData();
            rd.addError(e);
            return rd;
        }        
    }

    public static ResponseData unenrollAssignedCurriulum(String currId, String lpId) {
        ResponseData rd = new ResponseData();
        try {
            List<Assigned_Curriculum__c> crList = [SELECT Id, Inactive__c,
                                                  (SELECT Id, Inactive__c FROM Assigned_Courses__r WHERE Completed__c = false), 
                                                  (SELECT Id, Inactive__c FROM Assignments__r WHERE Completed__c = false) 
                                                  FROM Assigned_Curriculum__c 
                                                  WHERE Id =: currId 
                                                  AND Completed__c = false
                                                  AND Learner_Profile__c =: lpId
                                                  WITH USER_MODE];
            if(!crList.isEmpty()) {
                if(!crList[0].Assignments__r.isEmpty()) {
                    unenrollAssigments(crList[0].Assignments__r, lpId);
                }
                if(!crList[0].Assigned_Courses__r.isEmpty()) {
                    for(Assigned_Course__c ac : crList[0].Assigned_Courses__r) {
                        ac.Inactive__c = true;
                    }

                    update (crList[0].Assigned_Courses__r);
                }

                crList[0].Inactive__c = true;
                update crList;
            }
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd; 
    }

    public static ResponseData unenrollAssignedCourse(String crId, String lpId) {
        ResponseData rd = new ResponseData();
        try {
            List<Assigned_Course__c> crList = [SELECT Id, Inactive__c,
                                              (SELECT Id, Inactive__c FROM Assignments__r WHERE Completed__c = false) 
                                              FROM Assigned_Course__c 
                                              WHERE Id =: crId 
                                              AND Learner_Profile__c =: lpId
                                              AND Completed__c = false
                                              WITH USER_MODE];
            if(!crList.isEmpty()) {
                if(!crList[0].Assignments__r.isEmpty()) {
                    unenrollAssigments(crList[0].Assignments__r, lpId);
                }

                crList[0].Inactive__c = true;
                update crList;
            }
            
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    public static ResponseData unenrollAssigments(List<Assignment__c> aList, String lpId) {
        ResponseData rd = new ResponseData();
        try { 
            List<Assignment__c> dataList = [SELECT Id, Inactive__c,
                                            (
                                                SELECT Id 
                                                FROM Assigned_Sessions__r 
                                                WHERE Status__c != 'Attended'
                                            )
                                            FROM Assignment__c
                                            WHERE Id IN: aList
                                            AND Learner_Profile__c =: lpId
                                            WITH USER_MODE];
            if(!dataList.isEmpty()) {
                for(Assignment__c ac : dataList) {
                    ac.Inactive__c = true;
                }

                update dataList;
            }
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    public static ResponseData unenrollSoloAssigment(String asgId, String lpId) {
        ResponseData rd = new ResponseData();
        try {
            List<Assignment__c> crList = [SELECT Id, Inactive__c
                                            FROM Assignment__c
                                            WHERE Id =: asgId
                                            AND Learner_Profile__c =: lpId
                                            AND Completed__c = false
                                            WITH USER_MODE];

            crList[0].Inactive__c = true;

            update crList;
        } catch(Exception e) {
            rd.addError(e);
        }
        return rd;
    }

}