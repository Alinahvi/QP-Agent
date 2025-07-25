public with sharing class assessment {
    // /***** Edit Assessment *****/
    // @AuraEnabled
    // public static String getEditAssessmentData(Id assessmentId) {
    //     responseData rd = new responseData();

    //     try {
    //         Assessment__c a = assessmentSelector(assessmentId);

    //         rd.put('canCreateQuestions', hasQuestionManagerPermSet());
    //         rd.put('assessment', a);
    //         rd.put('statusOptions', getAssessmentStatusOptions(a.Status__c));
    //         rd.put('questions', a.Type__c == 'Competency' ? getBarsQuestions(assessmentId) : getAssessmentQuestions(assessmentId));
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String getRoles() {
    //     responseData rd = new responseData();

    //     try {
    //         rd.put('roleOptions', getRoleOptions());
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String updateAssessment(String assessmentDetails) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(updateAssessmentAccessMap);

    //         Map<String, Object> assessmentData = (Map<String, Object>)JSON.deserializeUntyped(assessmentDetails);

    //         update new Assessment__c(
    //             Id = (Id)assessmentData.get('id'),
    //             Name = (String)assessmentData.get('name'), 
    //             Status__c = (String)assessmentData.get('status')
    //         );
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String createQuestion(String questionDetails, Id assessmentId) {
    //     responseData rd = new responseData();

    //     try {
    //         checkAccess(createQuestionAccessMap);

    //         Map<String, Object> questionData = (Map<String, Object>)JSON.deserializeUntyped(questionDetails);
    //         String questionType = (String)questionData.get('type');
            
    //         if (questionType == 'Bars') {
    //             BARS_Question__c q = buildBarsQuestionForUpsert(questionData);
    //             q.Assessment__c = assessmentId;
    //             insert q;

    //             //update the orders of the other questions
    //             updateBarsQuestionOrders(q.Assessment__c, q.Id, (Integer)q.Order__c);

    //             rd.put('newQuestionId', q.Id);
    //         } else {
    //             Question__c q = buildQuestionForUpsert(questionData);
    //             q.Assessment__c = assessmentId;
    //             insert q;

    //             //update orders of other questions in assessment
    //             updateOtherQuestionOrders(q.Assessment__c, q.Id, (Integer)q.Order__c);

    //             rd.put('newQuestionId', q.Id);
    //         }
            
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String updateQuestion(String questionDetails) {
    //     responseData rd = new responseData();

    //     try {
    //         checkAccess(updateQuestionAccessMap);

    //         Map<String, Object> questionData = (Map<String, Object>)JSON.deserializeUntyped(questionDetails);

    //         Question__c q = buildQuestionForUpsert(questionData);
    //         q.Id = (Id)questionData.get('id');
    //         update q;
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String updateQuestionOrder(Id assessmentId, Id questionId, Integer order) {
    //     responseData rd = new responseData();

    //     try {
    //         checkAccess(updateQuestionOrderAccessMap);

    //         //update question that was dragged to new position
    //         update new Question__c(Id = questionId, Order__c = order);

    //         //update orders of other questions in assessment
    //         updateOtherQuestionOrders(assessmentId, questionId, order);
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String updateBarsQuestionOrders(Id assessmentId, Id questionId, Integer order) {
    //     responseData rd = new responseData();
    //     try {
    //         update new BARS_Question__c(Id = questionId, Order__c = order);

    //         updateOtherBarsQuestionOrder(assessmentId, questionId, order);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String cloneQuestion(Id questionId) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(cloneQuestionAccessMap);

    //         Question__c existingQuestion = questionSelector(questionId);

    //         //create deep copy clone w/o preserving anything
    //         Question__c clonedQuestion = existingQuestion.clone(false, true, false, false);
    //         clonedQuestion.Template_Question__c = null;
    //         clonedQuestion.Order__c = existingQuestion.Order__c + 1;
    //         insert clonedQuestion;

    //         //update orders of other questions in assessment
    //         updateOtherQuestionOrders(existingQuestion.Assessment__c, clonedQuestion.Id, (Integer)clonedQuestion.Order__c);

    //         rd.put('clonedQuestionId', clonedQuestion.Id);
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String addQuestionToBank(String questionDetails) {
    //     responseData rd = new responseData();

    //     try {
    //         checkAccess(addQuestionToBankAccessMap);

    //         Map<String, Object> questionData = (Map<String, Object>)JSON.deserializeUntyped(questionDetails);

    //         Id existingQuestionId = (Id)questionData.get('existingQuestionId');
    //         String name = (String)questionData.get('name');

    //         Question__c existingQuestion = questionSelector(existingQuestionId);

    //         //create deep copy clone w/o preserving anything
    //         Question__c bankQuestion = existingQuestion.clone(false, true, false, false);
    //         bankQuestion.Name = name;
    //         bankQuestion.Is_Question_Bank__c = true;
    //         bankQuestion.Assessment__c = null;
    //         insert bankQuestion;

    //         //update template on existing question
    //         existingQuestion.Template_Question__c = bankQuestion.Id;
    //         update existingQuestion;

    //         //create question roles
    //         List<Question_Role__c> newRoles = new List<Question_Role__c>();
    //         for(Object r : (List<Object>)questionData.get('roles')) {
    //             Id roleId = (Id)r;
    //             newRoles.add(new Question_Role__c(Question__c = bankQuestion.Id, Role__c = roleId));
    //         }
    //         insert newRoles;

    //         rd.put('bankQuestionId', bankQuestion.Id);
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String deleteQuestion(Id questionId, Integer order) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(deleteQuestionAccessMap);

    //         delete [SELECT Id FROM Question__c WHERE Id = :questionId];

    //         //update orders of questions after deleted
    //         List<Question__c> qsAfterDeleted = [SELECT Id, Order__c FROM Question__c WHERE Order__c > :order];
    //         for(Question__c q : qsAfterDeleted) {
    //             q.Order__c -= 1;
    //         }
    //         update qsAfterDeleted;
    //     } Catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String getRecentBankQuestions() {
    //     responseData rd = new responseData();

    //     try{
    //         Map<String, Object> filters = new Map<String, Object>{
    //             'orderBy' => 'CreatedDate',
    //             'orderDirection' => 'DESC',
    //             'limit' => '10'
    //         };

    //         rd.put('recentQuestions', getBankQuestions(filters));
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String searchQuestionBank(String filters) {
    //     responseData rd = new responseData();

    //     try{
    //         Map<String, Object> filterMap = (Map<String, Object>)JSON.deserializeUntyped(String.escapeSingleQuotes(filters));

    //         rd.put('questions', getBankQuestions(filterMap));
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String addQuestionFromBank(Id questionId, Id assessmentId, Integer order) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(addQuestionFromBankAccessMap);

    //         Question__c bankQuestion = questionSelector(questionId);

    //         Question__c assessmentQuestion = bankQuestion.clone(false, true, false, false);
    //         assessmentQuestion.Name = null;
    //         assessmentQuestion.Is_Question_Bank__c = false;
    //         assessmentQuestion.Assessment__c = assessmentId;
    //         assessmentQuestion.Template_Question__c = questionId;
    //         assessmentQuestion.Order__c = order;
    //         insert assessmentQuestion;

    //         //update orders of other questions in assessment
    //         updateOtherQuestionOrders(assessmentId, assessmentQuestion.Id, order);

    //         rd.put('newQuestion', new Question(assessmentQuestion));
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }
    //     return rd.getJsonString();
    // }


    // /***** Take Assessment *****/
    // @AuraEnabled
    // public static String getTakeAssessmentData(Id assessmentInviteId) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(getTakeAssessmentDataAccessMap);

    //         //get invite details
    //         Assessment_Invitation__c ai = [SELECT Assessment__c, Assessment__r.Name, Assessment__r.Type__c, 
    //                                               Assessment__r.Description__c, Assessment_Taker__c, Assessor__c, Type__c, Due_Date__c,
    //                                            (SELECT Id, Status__c FROM Assessment_Response__r)
    //                                        FROM Assessment_Invitation__c
    //                                        WHERE Id = :assessmentInviteId
    //                                        WITH SECURITY_ENFORCED];

    //         slj__Learner_Profile__c lp = [SELECT Title__c, Id
    //                                       FROM slj__Learner_Profile__c
    //                                       WHERE slj__User__c = :UserInfo.getUserId()
    //                                       WITH SECURITY_ENFORCED];

    //         if(ai.Assessor__c == UserInfo.getUserId() || ai.Assessment_Taker__c == UserInfo.getUserId()) {
    //             //correct user taking assessment
    //             rd.put('responseId', !ai.Assessment_Response__r.isEmpty() ? ai.Assessment_Response__r.get(0).Id : null);
    //             rd.put('responseStatus', !ai.Assessment_Response__r.isEmpty() ? ai.Assessment_Response__r.get(0).Status__c : null);
    //             rd.put('questionResponses', !ai.Assessment_Response__r.isEmpty() ? getBarsAssessmentQuestionResponses(ai.Assessment__c, ai.Assessment_Response__r.get(0).Id) : null);
    //             rd.put('assessmentType', getFormattedAssessmentType(ai.Type__c));
    //             rd.put('assessmentName', ai.Assessment__r.Name);
    //             rd.put('questions', ai.Assessment__r.Type__c == 'Competency' ? (Object)getBarsQuestions(ai.Assessment__c) : (Object)getAssessmentQuestions(ai.Assessment__c));
    //             rd.put('assessee', new Assessee(ai.Assessment_Taker__c));
    //             rd.put('assessmentQuestionType', ai.Assessment__r.Type__c);
    //             rd.put('assessmentDescription', ai.Assessment__r.Description__c);
    //             rd.put('dueDate', ai.Due_Date__c);
    //             rd.put('isManager', ai.Type__c == 'Manager');
    //             rd.put('learnerTitle', lp.Title__c);
    //             rd.put('barsQuestions', getBarsData(ai.Assessment__c, !ai.Assessment_Response__r.isEmpty() ? ai.Assessment_Response__r.get(0).Id : null));
    //         } else{
    //             //incorrect user taking assessment
    //             rd.put('accessErrorMsg', 'You do not have permission to view or take this assessment.');
    //         }
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // @AuraEnabled
    // public static String saveAssessmentResponses(Id assessmentInviteId, String questionsJson) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(saveAssessmentResponsesAccessMap);

    //         //get invite details
    //         Assessment_Invitation__c ai = [SELECT Assessment__c, Assessment__r.Name, Assessment_Taker__c, Type__c
    //                                        FROM Assessment_Invitation__c
    //                                        WHERE Id = :assessmentInviteId];

    //         //create assessment response record
    //         Assessment_Response__c ar = new Assessment_Response__c(
    //             Assessment__c = ai.Assessment__c,
    //             Assessment_Invitation__c = ai.Id,
    //             OwnerId = ai.Assessment_Taker__c,
    //             Status__c = 'Submitted'
    //         );
            
    //         insert ar;

    //         //create question response records
    //         List<Assessment_Question_Response__c> responses = new List<Assessment_Question_Response__c>();
    //         for(Object q : (List<Object>)JSON.deserializeUntyped(questionsJson)) {
    //             Map<String, Object> questionMap = (Map<String, Object>)q;

    //             Assessment_Question_Response__c aqr = new Assessment_Question_Response__c(
    //                 Question__c = (Id)questionMap.get('id'),
    //                 User__c = UserInfo.getUserId(),
    //                 Assessment_Response__c = ar.Id,
    //                 OwnerId = ai.Assessment_Taker__c
    //             );

    //             if((String)questionMap.get('type') == 'Scale') {
    //                 aqr.Scale_Answer__c = Integer.valueOf(questionMap.get('response'));
    //             } else{
    //                 aqr.Paragraph_Answer__c = (String)questionMap.get('response');
    //             }
    //             responses.add(aqr);
    //         }
    //         insert responses;

    //         rd.put('redirect', System.URL.getOrgDomainUrl().toExternalForm() + '/lightning/n/' + constants.NAMESPACE_API + 'Dashboard_Home');
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // /***** Learner Review Assessment *****/
    // @AuraEnabled
    // public static String getLearnerReviewAssessmentData(Id assessmentInviteId) {
    //     responseData rd = new responseData();

    //     try {
    //         //get current user learner profile to determine if they are a manager
    //         slj__Learner_Profile__c currentUserLearnerProfile = [SELECT slj__User__r.ManagerId, Title__c, Id
    //                                                              FROM slj__Learner_Profile__c 
    //                                                              WHERE slj__User__c = :UserInfo.getUserId()
    //                                                              WITH SECURITY_ENFORCED
    //                                                              LIMIT 1];

    //         rd.put('isManager',false);            

    //         rd.put('UserInfo',UserInfo.getUserId());
    //         rd.put('assessmentInviteId',assessmentInviteId);
    //         rd.put('learnerTitle', currentUserLearnerProfile.Title__c);

    //         List<Assessment_Response__c> listOfLearnerAssessmentResponses = [SELECT Id, Assessment__c, Is_My_Direct_Reports_Assessment__c, Is_My_Managers_Assessment__c, Is_My_Self_Assessment__c, 
    //                                                                             Assessment_Review__c, Assessment__r.Name, Assessment__r.Type__c, Assessment_Invitation__c,  Assessment_Invitation__r.Assessee__c, Assessment__r.Due_Date__c, 
    //                                                                             Assessment__r.Description__c, Assessment_Invitation__r.Assessor__c, Assessment_Invitation__r.Assessment_Taker__r.name, Assessment_Invitation__r.Type__c, Status__c,
    //                                                                             Assessment_Review__r.Review_Skill_One__r.Skill__c, Assessment_Review__r.Review_Skill_Two__r.Skill__c, Assessment_Invitation__r.Due_Date__c, Assessment_Invitation__r.Status__c, Assessment_Invitation__r.Manager_Invitation__r.Status__c,
    //                                                                                 ( 
    //                                                                                     SELECT Id, BARS_Question__r.id, BARS_Question__r.Name, BARS_Question__r.Competency__c, 
    //                                                                                     BARS_Question__r.Skill__c, BARS_Question__r.Assessment__c, BARS_Question__r.Order__c, 
    //                                                                                     BARS_Question__r.Statements__c, BARS_Question__r.Excellence_Factor__c, 
    //                                                                                     BARS_Question__r.Skill_Description__c, BARS_Question__r.Required__c, BARS_Question__r.Description__c,
    //                                                                                     BARS_Question__r.Role__c, BARS_Question__r.Manager_Title__c, Question__r.Id, Question__r.Type__c,
    //                                                                                     Question__r.Is_Question_Bank__c, Question__r.Label__c, Question__r.Order__c, Question__r.Required__c,
    //                                                                                     Question__r.Type_Options_JSON__c, Question__r.Template_Question__c, Question__r.Competency__r.Name,
    //                                                                                     Question__r.Skill__r.Name, Scale_Answer__c, Paragraph_Answer__c, BARS_Answer__c
    //                                                                                     FROM Assessment_Question_Responses__r 
    //                                                                                 )
    //                                                                             FROM Assessment_Response__c 
    //                                                                             WHERE Assessment_Invitation__c = :assessmentInviteId
    //                                                                             AND Status__c = 'Submitted'
    //                                                                             AND Assessment_Invitation__r.Assessor__c = :UserInfo.getUserId() 
    //                                                                             LIMIT 1
    //                                                                             //DEV NOTE: UNCOMMENT BELOW LEFT COMMENTED BECAUSE OF TEST DATA IN ORG
    //                                                                             //ALSO WITH SECURITY_ENFORCED IS THROWING ERROR WITH OUR TEST USER UNCOMMENT WHEN FIXED
    //                                                                             //AND Assessment_Invitation__r.Due_Date__c <= :Date.today()
    //                                                                             //WITH SECURITY_ENFORCED
    //                                                                         ];

    //         Id managerId;
    //         rd.put('showAreasOfInterest', false);
    //         if (listOfLearnerAssessmentResponses.isEmpty()) {
    //             rd.put('isAssessmentSubmitted', false);  
    //             return rd.getJsonString();
    //         }

    //         //can use `Assessment_Invitation__r.Type__c = 'Employee'` to figure out Employee self  
    //         rd.put('isAssessmentSubmitted', true);  
    //         Assessment_Response__c selfAssesmentResponse = listOfLearnerAssessmentResponses[0];
    //         Boolean isManager = selfAssesmentResponse.Assessment_Invitation__r.Type__c == 'Manager';
    //         Id assessmentId = selfAssesmentResponse.Assessment__c;
    //         Id asseeId = selfAssesmentResponse.Assessment_Invitation__r.Assessee__c;
    //         Id assessorId;
    //         if (isManager) {
    //             managerId = selfAssesmentResponse.Assessment_Invitation__r.Assessee__c;
    //             assessorId = selfAssesmentResponse.Assessment_Invitation__r.Assessee__c;
    //         } else {
    //             assessorId = Id.valueOf(currentUserLearnerProfile.slj__User__r.ManagerId);
    //             managerId = Id.valueOf(currentUserLearnerProfile.slj__User__r.ManagerId);
    //         }

    //         rd.put('managerId',managerId);
    //         rd.put('assessmentType', getFormattedAssessmentType(selfAssesmentResponse.Assessment_Invitation__r.Type__c));
    //         rd.put('assessmentName', selfAssesmentResponse.Assessment__r.Name);
    //         rd.put('assessmentDescription', selfAssesmentResponse.Assessment__r.Description__c);
    //         rd.put('assessmentDueDate', selfAssesmentResponse.Assessment_Invitation__r.Due_Date__c);
    //         rd.put('assesseeName', selfAssesmentResponse.Assessment_Invitation__r.Assessment_Taker__r.name);
    //         rd.put('isManager', isManager);
            
    //         System.debug('********************* isManager ' + isManager);
    //         System.debug('********************* self ' + selfAssesmentResponse.Assessment_Invitation__r.Status__c);
    //         System.debug('********************* manager ' + selfAssesmentResponse.Assessment_Invitation__r.Manager_Invitation__r.Status__c);

    //         if(!isManager && 
    //            selfAssesmentResponse.Assessment_Invitation__r.Status__c == 'Submitted' &&
    //            selfAssesmentResponse.Assessment_Invitation__r.Manager_Invitation__r.Status__c == 'Submitted'){
    //             rd.put('showAreasOfInterest', true);
    //         }

    //         List<Map<String, Object>> ListOfMapOfLearnerQuestionsAndAnswers = new List<Map<String, Object>>();
    //         List<Map<String,Object>> listOfAreasOfInterest = new List<Map<String,Object>>(); 
    //         Map<String,Object> learnerAreasOfIntrestMap = new Map<String, Object>();
            
    //         //build skill map for front end 
    //         if(selfAssesmentResponse.Assessment_Review__r.Review_Skill_One__r.Skill__c != null) {
    //             learnerAreasOfIntrestMap.put('id', selfAssesmentResponse.Assessment_Invitation__r.Assessee__c );
    //             learnerAreasOfIntrestMap.put('name', selfAssesmentResponse.Assessment_Invitation__r.Assessment_Taker__r.name );
    //             learnerAreasOfIntrestMap.put('skillOne',selfAssesmentResponse.Assessment_Review__r.Review_Skill_One__r.Skill__c);
    //             learnerAreasOfIntrestMap.put('skillTwo',selfAssesmentResponse.Assessment_Review__r.Review_Skill_Two__r.Skill__c);
    //         }           

    //         if(!learnerAreasOfIntrestMap.isEmpty() || learnerAreasOfIntrestMap == null) {
    //             listOfAreasOfInterest.add(learnerAreasOfIntrestMap);
    //         }

    //         //make a map of all manager questions and awnsers
    //         List<Assessment_Response__c> listOfManagerAssessmentResponse = [SELECT Id, Assessment__c, Is_My_Direct_Reports_Assessment__c, Is_My_Managers_Assessment__c, Is_My_Self_Assessment__c, 
    //                                                                         Assessment_Review__c, Assessment__r.Name, Assessment__r.Type__c, Assessment_Invitation__c,  Assessment_Invitation__r.Assessee__c, Assessment__r.Due_Date__c, 
    //                                                                         Assessment__r.Description__c, Assessment_Invitation__r.Assessor__c, Assessment_Invitation__r.Assessment_Taker__r.name, Assessment_Invitation__r.Type__c, Status__c,
    //                                                                         Assessment_Review__r.Review_Skill_One__r.Skill__c, Assessment_Review__r.Review_Skill_One__r.Competency__c, Assessment_Review__r.Review_Skill_Two__r.Skill__c, 
    //                                                                         Assessment_Review__r.Review_Skill_Two__r.Competency__c, Assessment_Invitation__r.Due_Date__c,
    //                                                                             ( 
    //                                                                                 SELECT Id, BARS_Question__r.id, BARS_Question__r.Name, BARS_Question__r.Competency__c, 
    //                                                                                 BARS_Question__r.Skill__c, BARS_Question__r.Assessment__c, BARS_Question__r.Order__c, 
    //                                                                                 BARS_Question__r.Statements__c, BARS_Question__r.Excellence_Factor__c, 
    //                                                                                 BARS_Question__r.Skill_Description__c, BARS_Question__r.Required__c, BARS_Question__r.Description__c,
    //                                                                                 BARS_Question__r.Role__c, BARS_Question__r.Manager_Title__c, Question__r.Id, Question__r.Type__c,
    //                                                                                 Question__r.Is_Question_Bank__c, Question__r.Label__c, Question__r.Order__c, Question__r.Required__c,
    //                                                                                 Question__r.Type_Options_JSON__c, Question__r.Template_Question__c, Question__r.Competency__r.Name,
    //                                                                                 Question__r.Skill__r.Name, Scale_Answer__c, Paragraph_Answer__c, BARS_Answer__c
    //                                                                                 FROM Assessment_Question_Responses__r 
    //                                                                             )
    //                                                                         FROM Assessment_Response__c 
    //                                                                         WHERE Status__c = 'Submitted'
    //                                                                         AND Assessment__c = :selfAssesmentResponse.Assessment__c
    //                                                                         AND Assessment_Invitation__r.Due_Date__c = :selfAssesmentResponse.Assessment_Invitation__r.Due_Date__c
    //                                                                         AND (Assessment_Invitation__r.Assessee__c = :asseeId
    //                                                                             AND Assessment_Invitation__r.Assessor__c = :assessorId)
    //                                                                         LIMIT 1
    //                                                                         //DEV NOTE: UNCOMMENT BELOW LEFT COMMENTED BECAUSE OF TEST DATA IN ORG
    //                                                                         //ALSO WITH SECURITY_ENFORCED IS THROWING ERROR WITH OUR TEST USER UNCOMMENT WHEN FIXED
    //                                                                         //AND Assessment_Invitation__r.Due_Date__c <= :Date.today()
    //                                                                         //WITH SECURITY_ENFORCED
    //                                                                         ];

    //         //handle this case
    //         if (listOfManagerAssessmentResponse.isEmpty()) {
    //             //rd.put('listOfFormattedLearnerAssessmentResponses', listOfFormattedLearnerAssessmentResponses);
    //             //return rd.getJsonString();
    //         }

    //         Map<String, Object> mapOfManagersAnswersByQuestionId = new Map<String, Object>();
    //         List<Map<String, Object>> areasOfInterest = new List<Map<String, Object>>();

    //         if (!listOfManagerAssessmentResponse.isEmpty()) {
    //             Assessment_Response__c managerAssesmentResponse = listOfManagerAssessmentResponse[0];
               
    //             for (Assessment_Question_Response__c managerQuestionResponse : managerAssesmentResponse.Assessment_Question_Responses__r) {
    //                 Integer managerAnswerIndex = (Integer)managerQuestionResponse.BARS_Answer__c;
    //                 List<Object> listOfQuestionAnswers = (List<Object>)JSON.deserializeUntyped(managerQuestionResponse.BARS_Question__r.Statements__c.replace('&quot;', '"'));
    //                 Map<String, Object> managerAnswerAtIndex = (Map<String, Object>)listOfQuestionAnswers[managerAnswerIndex];
    //                 String uniqueKey = string.valueOf(managerQuestionResponse.BARS_Question__r.id) + string.valueOf(managerAnswerAtIndex.get('label'));
    //                 mapOfManagersAnswersByQuestionId.put(uniqueKey, managerAnswerAtIndex.get('value'));
    //             }
    //             if (isManager) {
    //                 if (managerAssesmentResponse.Assessment_Review__r.Review_Skill_One__c != null) {
    //                     areasOfInterest.add(new Map<String, Object>{
    //                         'competency' => managerAssesmentResponse.Assessment_Review__r.Review_Skill_One__r.Competency__c,
    //                         'skill' => managerAssesmentResponse.Assessment_Review__r.Review_Skill_One__r.Skill__c
    //                     });
    //                 }

    //                 if (managerAssesmentResponse.Assessment_Review__r.Review_Skill_Two__c != null) {
    //                     areasOfInterest.add(new Map<String, Object>{
    //                         'competency' => managerAssesmentResponse.Assessment_Review__r.Review_Skill_Two__r.Competency__c,
    //                         'skill' => managerAssesmentResponse.Assessment_Review__r.Review_Skill_Two__r.Skill__c
    //                     });
    //                 }
    //                 rd.put('learnerAreasOfInterest', areasOfInterest);
    //             }
    //         }
           
    //         List<Map<String, Object>> listOfFormattedLearnerAssessmentResponses = new List<Map<String, Object>>();
    //         Set<Map<String, Object>> listOfCompetencySkills = new Set<Map<String, Object>>();
    //         Map<String, Object> mapOfCompetencyToSkill = new Map<String, Object>();
    //         Map<String, List<String>> excellenceToCompMap = new Map<String, List<String>>();
    //         Map<String, Integer> compIndex = new Map<String, Integer>();
    //         for (Assessment_Question_Response__c selfQuestionResponse : selfAssesmentResponse.Assessment_Question_Responses__r) {

    //             Integer learnerAnswerIndex = (Integer)selfQuestionResponse.BARS_Answer__c;
    //             List<Object> listOfQuestionAnswers = (List<Object>)JSON.deserializeUntyped(selfQuestionResponse.BARS_Question__r.Statements__c.replace('&quot;', '"'));
    //             if (!excellenceToCompMap.containsKey(selfQuestionResponse.BARS_Question__r.Excellence_Factor__c)) {
    //                 excellenceToCompMap.put(selfQuestionResponse.BARS_Question__r.Excellence_Factor__c, new List<String>());
    //             }

    //             List<Map<String, Object>> listOfStatements = new List<Map<String, Object>>();
    //             for (Integer i = 0; i < listOfQuestionAnswers.size(); i++) {
    //                 Map<String, Object> questionAnswerMap = (Map<String, Object>)listOfQuestionAnswers[i];
    //                 questionAnswerMap.put('id', selfQuestionResponse.BARS_Question__r.id + 'index_' + string.valueOf(i));
    //                 questionAnswerMap.put('isManagerAnswer', false);
    //                 questionAnswerMap.put('isLearnerAnswer', false);

    //                 String uniqueKey = string.valueOf(selfQuestionResponse.BARS_Question__r.id) + string.valueOf(questionAnswerMap.get('label'));
    //                 if(!mapOfManagersAnswersByQuestionId.isEmpty() && (mapOfManagersAnswersByQuestionId.get(uniqueKey) == questionAnswerMap.get('value'))) {
    //                     if (isManager) {
    //                         questionAnswerMap.put('isLearnerAnswer', true);
    //                     }
    //                     else {
    //                         questionAnswerMap.put('isManagerAnswer', true);
    //                     }
    //                 }


    //                 if(learnerAnswerIndex == i) {
    //                     if (isManager) {
    //                         questionAnswerMap.put('isManagerAnswer', true);   
    //                     }
    //                     else {
    //                         questionAnswerMap.put('isLearnerAnswer', true);           
    //                     }
    //                 }

    //                 if((Boolean)questionAnswerMap.get('isLearnerAnswer') && (Boolean)questionAnswerMap.get('isManagerAnswer')) {
    //                     questionAnswerMap.put('sameAnswer', true); 
    //                 } else {
    //                     questionAnswerMap.put('sameAnswer', false); 
    //                 }
                    
    //                 listOfQuestionAnswers[i] = (Object)questionAnswerMap;
    //                 listOfStatements.add(questionAnswerMap);
    //             }

    //             Map<String, Object> newCompetencylMap = new Map<String, Object>{
    //                 'label' => selfQuestionResponse.BARS_Question__r.Competency__c,
    //                 'value' => selfQuestionResponse.BARS_Question__r.Competency__c
    //             };
    //             listOfCompetencySkills.add(newCompetencylMap);

    //             Map<String, Object> newSkillMap = new Map<String, Object>{
    //                 'label' => selfQuestionResponse.BARS_Question__r.Skill__c,
    //                 'value' => selfQuestionResponse.BARS_Question__r.Id
    //             };
    //             if(mapOfCompetencyToSkill.containsKey(selfQuestionResponse.BARS_Question__r.Competency__c)) {
    //                 List<Object> listOfSkillsToAddTo = (List<Object>)mapOfCompetencyToSkill.get(selfQuestionResponse.BARS_Question__r.Competency__c);
    //                 listOfSkillsToAddTo.add((Object)newSkillMap);
    //                 mapOfCompetencyToSkill.put(selfQuestionResponse.BARS_Question__r.Competency__c, (Object)listOfSkillsToAddTo);
    //             } else {
    //                 List<Object> listOfSkills = new List<Object>{(Object)newSkillMap};
    //                 mapOfCompetencyToSkill.put(selfQuestionResponse.BARS_Question__r.Competency__c, (Object)listOfSkills);
                    
    //             }

                   
    //             Map<String, Object> skillsMapToAdd = new Map<String, Object> {
    //                 'id' => selfAssesmentResponse.Assessment_Invitation__r.Assessee__c,
    //                 'key' => String.valueOf(Math.random()),
    //                 'name' => selfQuestionResponse.BARS_Question__r.Skill__c,
    //                 'description' => selfQuestionResponse.BARS_Question__r.Skill_Description__c,
    //                 'statements' => (Object)listOfStatements,
    //                 'isOpen' => true,
    //                 'index' => selfQuestionResponse.BARS_Question__r.Order__c,
    //                 'hasManagerAnswer' => isManager ? !listOfLearnerAssessmentResponses.isEmpty() : !listOfManagerAssessmentResponse.isEmpty(),
    //                 'hasLearnerAnswer' => !isManager ? true : !listOfManagerAssessmentResponse.isEmpty()
    //             };

    //             List<Map<String, Object>> listOfSkillsMaps = new List<Map<String, Object>> {skillsMapToAdd};

    //             Map<String, Object> competenciesMapToAdd = new Map<String, Object> {
    //                 'name' => selfQuestionResponse.BARS_Question__r.Competency__c,
    //                 'id' => String.valueOf(Math.random()),
    //                 'skills' => (Object)listOfSkillsMaps
    //             };
               
    //             Boolean doesCompetencyExist = false;
    //             for (Map<String, Object> learnerAssessmentResponse : listOfFormattedLearnerAssessmentResponses) {
    //                 if (learnerAssessmentResponse.containsKey('excellenceFactor') && (learnerAssessmentResponse.get('excellenceFactor') == selfQuestionResponse.BARS_Question__r.Excellence_Factor__c)) {
    //                     List<Object> listOfCompetenciesToModify = (List<Object>)learnerAssessmentResponse.get('competencies');
    //                     if (compIndex.containsKey(selfQuestionResponse.BARS_Question__r.Competency__c)) {
    //                         Integer competencyIndex = compIndex.get(selfQuestionResponse.BARS_Question__r.Competency__c);
    //                         Map<String, Object> competencyMapToModify = (Map<String, Object>)listOfCompetenciesToModify[competencyIndex];
    //                         List<Object> skillListToModify = (List<Object>)competencyMapToModify.get('skills');
    //                         skillListToModify.add(skillsMapToAdd);
    //                     } else{
    //                         listOfCompetenciesToModify.add(competenciesMapToAdd);
    //                     }
    //                     doesCompetencyExist = true;
    //                 }
    //             }
                
                
    //             if (!doesCompetencyExist) {
    //                 List<Map<String, Object>> listOfCompetencies = new List<Map<String, Object>>{competenciesMapToAdd};
    //                 Map<String, Object> learnerQuestionAnswerData = new Map<String, Object>{
    //                     'excellenceFactor' => selfQuestionResponse.BARS_Question__r.Excellence_Factor__c,
    //                     'competencies' => (Object)listOfCompetencies
    //                 };
    //                 listOfFormattedLearnerAssessmentResponses.add(learnerQuestionAnswerData);  
    //             }

    //             if (!compIndex.containsKey(selfQuestionResponse.BARS_Question__r.Competency__c)) {
    //                 excellenceToCompMap.get(selfQuestionResponse.BARS_Question__r.Excellence_Factor__c).add(selfQuestionResponse.BARS_Question__r.Competency__c);
    //                 compIndex.put(selfQuestionResponse.BARS_Question__r.Competency__c, excellenceToCompMap.get(selfQuestionResponse.BARS_Question__r.Excellence_Factor__c).size() - 1);
    //             }
                
                 
    //         }

    //         rd.put('mapOfCompetencyToSkill', mapOfCompetencyToSkill);
    //         rd.put('listOfAreasOfInterest', listOfAreasOfInterest);
    //         rd.put('listOfCompetencySkills', null);
    //         rd.put('questions', getBarsQuestions(assessmentId));

    //         if (!mapOfCompetencyToSkill.isEmpty()) {
    //             rd.put('listOfCompetencySkills', listOfCompetencySkills);
    //         }
            
    //         rd.put('listOfFormattedLearnerAssessmentResponses', listOfFormattedLearnerAssessmentResponses);

    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }
    //     return rd.getJsonString();
    // }

    // /***** View Assessment *****/
    // @AuraEnabled
    // public static String getViewAssessmentData(Id assessmentResponseId) {
    //     responseData rd = new responseData();

    //     try{
    //         checkAccess(getViewAssessmentDataAccessMap);

    //         //get response details
    //         Assessment_Response__c ar = [SELECT Assessment__c, Assessment__r.Name, Assessment__r.Type__c, Assessment_Invitation__r.Assessee__c, 
    //                                             Assessment_Invitation__r.Assessor__c, Assessment_Invitation__r.Type__c
    //                                      FROM Assessment_Response__c 
    //                                      WHERE Id = :assessmentResponseId];

    //         //get list view id and obj api name for nav based on type of assessment being viewed
    //         String listViewDevName = ar.Assessment_Invitation__r.Type__c == 'Employee' ? 'My_Self_Assessments' : (ar.Assessment_Invitation__r.Assessor__c == UserInfo.getUserId() ? 'My_Direct_Reports_Assessments' : 'My_Managers_Assessments');
    //         String sObjType = constants.NAMESPACE_API + 'Assessment_Response__c';
    //         rd.put('objectApiName', sObjType);
    //         rd.put('filterName', listViewDevName);

    //         if(ar.Assessment_Invitation__r.Assessor__c != UserInfo.getUserId() && ar.Assessment_Invitation__r.Assessee__c != UserInfo.getUserId()) {
    //             //not allowed to view assessment responses that are not for you or by you
    //             rd.put('accessErrorMsg', 'You do not have permission to view or take this assessment.');
    //         } else{
    //             //current user allowed to view
    //             List<QuestionResponse> questionResponses = ar.Assessment__r.Type__c == 'Competency' ? getBarsAssessmentQuestionResponses(ar.Assessment__c, assessmentResponseId) : getAssessmentQuestionResponses(ar.Assessment__c, assessmentResponseId);

    //             rd.put('assessmentType', getFormattedAssessmentType(ar.Assessment_Invitation__r.Type__c));
    //             rd.put('assessmentName', ar.Assessment__r.Name);
    //             rd.put('questions', questionResponses);
    //             rd.put('assessee', new Assessee(ar.Assessment_Invitation__r.Assessee__c));
    //         }
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }


    // /***** Private Helpers *****/
    // private static Assessment__c assessmentSelector(Id assessmentId) {
    //     checkAccess(assessmentSelectorAccessMap);

    //     return [SELECT Id, Name, Status__c, Type__c
    //             FROM Assessment__c
    //             WHERE Id = :assessmentId];
    // }

    // private static Boolean hasQuestionManagerPermSet() {
    //     checkAccess(hasQuestionManagerPermSetAccessMap);

    //     String nsPrefix = constants.NAMESPACE_API.removeEnd('__');

    //     return [SELECT COUNT()
    //             FROM PermissionSetAssignment 
    //             WHERE PermissionSet.Name = 'ACT_Assessment_Question_Management'
    //               AND PermissionSet.NamespacePrefix = :nsPrefix 
    //               AND AssigneeId = :UserInfo.getUserId()] > 0;
    // }

    // public static List<Question> getBarsQuestions(Id assessmentId) {
    //     checkAccess(getBarsQuestionAccessMap);

    //     List<Question> questions = new List<Question>();
    //     for(BARS_Question__c q : [SELECT Id, Name, Competency__c, Skill__c, Assessment__c,
    //                                      Order__c, Statements__c, Excellence_Factor__c, Skill_Description__c, 
    //                                      Required__c, Description__c, Role__c, Manager_Title__c
    //                               FROM BARS_Question__c
    //                               WHERE Assessment__c = :assessmentId
    //                               ORDER BY Order__c ASC
    //                               NULLS LAST]) {

    //         questions.add(new Question(q));
    //     }

    //     return questions;
    // }

    // public static List<Map<String, Object>> getBarsData(Id assessmentId, Id assessmentResponseId) {
    //     checkAccess(getBarsQuestionAccessMap);

    //     List<String> excellenceFactorList = new List<String>();
    //     Map<String, List<String>> excellenceFactorToCompetenciesMap = new Map<String, List<String>>();
    //     Map<String, List<Object>> excellenceFactorMap = new Map<String, List<Object>>();
    //     Map<String, List<Object>> competencySkillMap = new Map<String, List<Object>>();
    //     List<Map<String, Object>> barsQuestions = new List<Map<String, Object>>();

    //     List<BARS_Question__c> questions = [SELECT Id, Name, Competency__c, Skill__c, Assessment__c, Description__c,
    //                                                Order__c, Statements__c, Excellence_Factor__c, Skill_Description__c, Role__c,
    //                                                (
    //                                                     SELECT BARS_Answer__c
    //                                                     FROM Assessment_Question_Responses__r
    //                                                     WHERE Assessment_Response__c = :assessmentResponseId
    //                                                )
    //                                         FROM BARS_Question__c
    //                                         WHERE Assessment__c = :assessmentId
    //                                         ORDER BY Order__c ASC];

    //     for (BARS_Question__c question : questions) {
    //         String excellenceFactor = question.Excellence_Factor__c;
    //         String competency = question.Competency__c;
    //         String skill = question.Skill__c;
    //         Map<String, Object> skillMap = new Map<String, Object>();

    //         //Add new excellence factor to map and list
    //         if (!excellenceFactorToCompetenciesMap.containsKey(excellenceFactor)) {
    //             excellenceFactorToCompetenciesMap.put(excellenceFactor, new List<String>());
    //             excellenceFactorList.add(excellenceFactor);
    //         }

    //         if (!competencySkillMap.containsKey(question.Competency__c)) {
    //             competencySkillMap.put(competency, new List<Object>());
    //             excellenceFactorToCompetenciesMap.get(excellenceFactor).add(competency);
    //         }

    //         skillMap.put('id', question.Id);
    //         skillMap.put('key', String.valueOf(Math.random()));
    //         skillMap.put('name', skill);
    //         skillMap.put('description', question.Skill_Description__c);
    //         skillMap.put('statements', JSON.deserializeUntyped(question.Statements__c.replace('&quot;', '"')));
    //         skillMap.put('index', question.Order__c);
    //         skillMap.put('response', !question.Assessment_Question_Responses__r.isEmpty() ? question.Assessment_Question_Responses__r.get(0).BARS_Answer__c : null);
    //         skillMap.put('isOpen', true);
    //         competencySkillMap.get(competency).add(skillMap);
    //     }

    //     //Build BARS question structure for frontend
    //     for (String ef : excellenceFactorList) {
    //         List<Map<String, Object>> competencyList = new List<Map<String, Object>>();

    //         for (String competency : excellenceFactorToCompetenciesMap.get(ef)) {
    //             competencyList.add(new Map<String, Object>{
    //                 'name' => competency,
    //                 'skills' => competencySkillMap.get(competency)
    //             });
    //         }
    //         barsQuestions.add(new Map<String, Object>{
    //             'excellenceFactor' => ef,
    //             'competencies' => competencyList
    //         });
    //     }

    //     return barsQuestions;
    // }

    // private static List<QuestionResponse> getBarsAssessmentQuestionResponses(Id assessmentId ,Id assessmentResponseId) {
    //     checkAccess(getBarsAssessmentQuestionResponsesAccessMap); 

    //     List<QuestionResponse> questionResponses = new List<QuestionResponse>();
    //     for(BARS_Question__c q : [SELECT Id, Name, Competency__c, Skill__c, Assessment__c,
    //                                 Order__c, Statements__c, Excellence_Factor__c, Skill_Description__c, 
    //                                 Required__c, Description__c, Role__c,
    //                                 (
    //                                     SELECT BARS_Answer__c, Paragraph_Answer__c, Scale_Answer__c
    //                                     FROM Assessment_Question_Responses__r
    //                                     WHERE Assessment_Response__c = :assessmentResponseId
    //                                 )
    //                           FROM BARS_Question__c
    //                           WHERE Assessment__c = :assessmentId
    //                           ORDER BY Order__c
    //                           NULLS LAST]) {

    //         questionResponses.add(new QuestionResponse(q));
    //     }
    //     return questionResponses;
    // }

    // public static List<Question> getAssessmentQuestions(Id assessmentId) {
    //     checkAccess(getAssessmentQuestionsAccessMap);

    //     List<Question> questions = new List<Question>();
    //     for(Question__c q : [SELECT Id, Name, CreatedDate, CreatedBy.Name, Is_Question_Bank__c, 
    //                                 Competency__c, Competency__r.Name,
    //                                 Skill__c, Skill__r.Name,
    //                                 Label__c, Type_Options_JSON__c, Order__c, 
    //                                 Required__c, Template_Question__c, Type__c
    //                           FROM Question__c
    //                           WHERE Assessment__c = :assessmentId
    //                           ORDER BY Order__c
    //                           NULLS LAST]) {

    //         questions.add(new Question(q));
    //     }

    //     return questions;
    // }

    // private static List<Map<String, String>> getAssessmentStatusOptions(String currentAssessmentStatus) {
    //     //get picklist options for assessment status
    //     List<Map<String, String>> statusOptions = new List<Map<String, String>>();
    //     for(Schema.PicklistEntry pe : Assessment__c.Status__c.getDescribe().getPickListValues()) {
    //         if(pe.isActive()) {
    //             String value = pe.getValue();
    //             if(value == 'Draft' && currentAssessmentStatus != 'Draft') {
    //                 //once out of draft status, cant go back
    //                 continue;
    //             }

    //             String label = pe.getLabel();

    //             statusOptions.add(new Map<String, String>{
    //                 'label' => label,
    //                 'value' => value
    //             });
    //         }
    //     }
    //     return statusOptions;
    // }

    // private static List<Map<String, String>> getRoleOptions() {
    //     checkAccess(getRoleOptionsAccessMap);

    //     List<Map<String, String>> roleOptions = new List<Map<String, String>>();
    //     for(Role__c role : [SELECT Id, Name FROM Role__c]) {
    //         roleOptions.add(new Map<String, String>{'label' => role.Name, 'value' => role.Id});
    //     }
    //     return roleOptions;
    // }

    // private static Question__c buildQuestionForUpsert(Map<String, Object> questionData) {
    //     checkAccess(buildQuestionForUpsertAccessMap);
    //     Map<String, Object> typeOptions = (Map<String, Object>)questionData.get('typeOptions');
    //     Map<String, Object> compOrSkill = (Map<String, Object>)questionData.get('competencyOrSkill');

    //     Id compOrSkillId = (Id)compOrSkill.get('id');

    //     Question__c q = new Question__c(
    //         Label__c = (String)questionData.get('text'),
    //         Order__c = (Integer)questionData.get('order'),
    //         Required__c = (Boolean)questionData.get('required'),
    //         Type__c = (String)questionData.get('type'),
    //         Type_Options_JSON__c = JSON.serialize(typeOptions)
    //     );

    //     if(compOrSkillId.getSObjectType().getDescribe().getName() == constants.NAMESPACE_API + 'Competency__c') {
    //         q.Competency__c = compOrSkillId;
    //         q.Skill__c = null;
    //     } else{
    //         q.Skill__c = compOrSkillId;
    //         q.Competency__c = null;
    //     }

    //     return q;
    // }

    // private static BARS_Question__c buildBarsQuestionForUpsert(Map<String, Object> questionData) {
    //     checkAccess(buildBarsQuestionForUpsertAccessMap);
    //     String questionType = (String)questionData.get('type');
    //     List<Object> statements = (List<Object>)questionData.get('typeOptions');
        
    //     BARS_Question__c q = new BARS_Question__c(
    //         Order__c = (Integer)questionData.get('order'),
    //         Required__c = (Boolean)questionData.get('required'),
    //         Active__c = true,
    //         Skill__c = (String)questionData.get('skill'),
    //         Competency__c = (String)questionData.get('competency'),
    //         Excellence_Factor__c = (String)questionData.get('excellenceFactor'),
    //         Role__c = (String)questionData.get('role'),
    //         Statements__c = JSON.serialize(statements),
    //         Manager_Description__c = (String)questionData.get('mangerDescription'),
    //         Manager_Title__c = (String)questionData.get('managerTitle'),
    //         Label__c = (String)questionData.get('title'),
    //         Description__c = (String)questionData.get('description')
    //     );
    //     return q;
    // }

    // private static void updateOtherQuestionOrders(Id assessmentId, Id questionId, Integer order) {
    //     checkAccess(updateOtherQuestionOrdersAccessMap);

    //     //update order of other questions that are part of same assessment
    //     List<Question__c> otherQuestions = [SELECT Id, Order__c
    //                                         FROM Question__c
    //                                         WHERE Id != :questionId
    //                                           AND Assessment__c = :assessmentId
    //                                         ORDER BY Order__c ASC];

    //     for(Integer i = 0; i < otherQuestions.size(); i++) {
    //         otherQuestions[i].Order__c = (i < order ? i : i + 1);
    //     }

    //     update otherQuestions;
    // }

    // private static void updateOtherBarsQuestionOrder(Id assessmentId, Id questionId, Integer order) {
    //     checkAccess(updateOtherBarsQuestionOrderAccessMap);
        
    //     List<BARS_Question__c> otherQuestions = [SELECT Id, Order__c
    //                                              FROM BARS_Question__c
    //                                              WHERE Id != :questionId
    //                                                AND Assessment__c = :assessmentId
    //                                              ORDER BY Order__c ASC];
    //     for (Integer i = 0; i < otherQuestions.size(); i++) {
    //         otherQuestions[i].Order__c = (i < order ? i : i + 1);
    //     }
        
    //     update otherQuestions;
    // }

    // private static Question__c questionSelector(Id questionId) {
    //     checkAccess(questionSelectorAccessMap);

    //     return [SELECT Id, CreatedBy.Name, CreatedDate, Assessment__c, Competency__c,
    //                    Is_Question_Bank__c, Label__c, Order__c, Required__c, 
    //                    Skill__c, Template_Question__c, Type__c, Type_Options_JSON__c,
    //                    Competency__r.Name, Skill__r.Name
    //             FROM Question__c 
    //             WHERE Id = :questionId];
    // }

    // private static List<BankQuestion> getBankQuestions(Map<String, Object> filters) {
    //     checkAccess(getBankQuestionsAccessMap);

    //     //populated if filtering by role; need to retrieve question roles to determine matching questions
    //     Set<Id> filteredQuestionIds = new Set<Id>();

    //     //populated if filtering by competency or skill
    //     Id compOrSkillId;

    //     //base query string for questions and their roles
    //     String queryString = 'SELECT Id, Name, CreatedDate, CreatedBy.Name,' +
    //                          'Competency__c, Competency__r.Name,' +
    //                          'Skill__c, Skill__r.Name, Is_Question_Bank__c,' +
    //                          'Label__c, Type_Options_JSON__c, Order__c, ' +
    //                          'Required__c, Template_Question__c, Type__c,' +
    //                          '(' +
    //                             'SELECT Role__c, Role__r.Name ' +
    //                             ' FROM Question_Roles__r' +
    //                             ' ORDER BY Role__r.Name ASC' +
    //                          ')' +
    //                          ' FROM Question__c' + 
    //                          ' WHERE Is_Question_Bank__c = true';

    //     if(filters.containsKey('name')) {
    //         String nameSearchTerm = (String)filters.get('name');

    //         if(String.isNotEmpty(nameSearchTerm)) {
    //             //add name search
    //             queryString += ' AND Name LIKE \'%' + String.escapeSingleQuotes(nameSearchTerm) + '%\'';
    //         }
    //     }

    //     if(filters.containsKey('competencyOrSkill')) {
    //         //add competency or skill search
    //         Map<String, Object> compOrSkillMap = (Map<String, Object>)filters.get('competencyOrSkill');

    //         if(compOrSkillMap.containsKey('id')) {
    //             compOrSkillId = (Id)compOrSkillMap.get('id');
    //         }

    //         if(String.isNotEmpty(compOrSkillId)) {
    //             String compOrSkillObjName = compOrSkillId.getSObjectType().getDescribe().getName();
    //             queryString += ' AND ' + compOrSkillObjName + ' = :compOrSkillId';
    //         }

    //     }

    //     if(filters.containsKey('roles')) {
    //         List<Object> roles = (List<Object>)filters.get('roles');

    //         if(!roles.isEmpty()) {
    //             filteredQuestionIds = getQuestionsForRoles(roles);
    //             queryString += ' AND Id = :filteredQuestionIds';
    //         }
    //     }

    //     if(filters.containsKey('orderBy')) {
    //         //add order by clause
    //         queryString += ' ORDER BY ' + filters.get('orderBy');

    //         if(filters.containsKey('orderDirection')) {
    //             queryString += ' ' + String.escapeSingleQuotes((String)filters.get('orderDirection'));                
    //         }
    //     }

    //     if(filters.containsKey('limit')) {
    //         queryString += ' LIMIT ' + String.escapeSingleQuotes((String)filters.get('limit'));
    //     }

    //     //get questions that match filter criteria
    //     List<Question__c> bankQuestions = Database.query(queryString);

    //     //get questions that bank questions are used as templates for
    //     //to determine assessments thatbank questions are used in
    //     Map<String, Set<String>> relatedAssessmentNamesByQuestionId = new Map<String, Set<String>>();
    //     for(Question__c q : [SELECT Template_Question__c, Assessment__r.Name
    //                          FROM Question__c 
    //                          WHERE Assessment__c != null 
    //                          AND Template_Question__c = :bankQuestions
    //                          ORDER BY Assessment__r.LastModifiedDate DESC]) {

    //         Set<String> relatedAssessmentNames = new Set<String>();
    //         if(relatedAssessmentNamesByQuestionId.containsKey(q.Template_Question__c)) {
    //             relatedAssessmentNames = relatedAssessmentNamesByQuestionId.get(q.Template_Question__c);
    //         }

    //         relatedAssessmentNames.add(q.Assessment__r.Name);

    //         relatedAssessmentNamesByQuestionId.put(q.Template_Question__c, relatedAssessmentNames);
    //     }

    //     List<BankQuestion> formattedBankQuestions = new List<BankQuestion>();
    //     for(Question__c q : bankQuestions) {
    //         formattedBankQuestions.add(new BankQuestion(q, relatedAssessmentNamesByQuestionId.get(q.Id)));
    //     }

    //     return formattedBankQuestions;
    // }

    // private static Set<Id> getQuestionsForRoles(List<Object> roles) {
    //     checkAccess(getQuestionsForRolesAccessMap);

    //     Set<Id> roleIds = new Set<Id>();
    //     for(Object r : roles) {
    //         Map<String, Object> roleData = (Map<String, Object>)r;
    //         roleIds.add((Id)roleData.get('value'));
    //     }

    //     Set<Id> questionIds = new Set<Id>();

    //     for(Question_Role__c qr : [SELECT Question__c 
    //                                FROM Question_Role__c
    //                                WHERE Role__c = :roleIds
    //                                  AND Question__r.Is_Question_Bank__c = true]) {
    //         questionIds.add(qr.Question__c);
    //     }

    //     return questionIds;
    // }

    // private static List<QuestionResponse> getAssessmentQuestionResponses(Id assessmentId, Id assessmentResponseId) {
    //     checkAccess(getAssessmentQuestionResponsesAccessMap);

    //     List<QuestionResponse> questionResponses = new List<QuestionResponse>();
    //     for(Question__c q : [SELECT Id, Name, CreatedDate, CreatedBy.Name, Is_Question_Bank__c, 
    //                                 Competency__c, Competency__r.Name,
    //                                 Skill__c, Skill__r.Name,
    //                                 Label__c, Type_Options_JSON__c, Order__c, 
    //                                 Required__c, Template_Question__c, Type__c,
    //                                 (
    //                                     SELECT Scale_Answer__c, Paragraph_Answer__c
    //                                     FROM Assessment_Question_Responses__r
    //                                     WHERE Assessment_Response__c = :assessmentResponseId
    //                                 )
    //                           FROM Question__c
    //                           WHERE Assessment__c = :assessmentId
    //                           ORDER BY Order__c
    //                           NULLS LAST]) {

    //         questionResponses.add(new QuestionResponse(q));
    //     }

    //     return questionResponses;
    // }

    // private static String getFormattedAssessmentType(String assessmentType) {
    //     return assessmentType == 'Employee' ? 'Self' : 'Manager';
    // }


    // /***** Question Wrappers *****/

    // //base question
    // private virtual class Question {
    //     @AuraEnabled public String id;
    //     @AuraEnabled public String templateId;
    //     @AuraEnabled public Boolean savedToQuestionBank;
    //     @AuraEnabled public String type;
    //     @AuraEnabled public Integer order;
    //     @AuraEnabled public Boolean required;
    //     @AuraEnabled public String text;
    //     @AuraEnabled public Map<String, String> competencyOrSkill;
    //     @AuraEnabled public Map<String, Object> typeOptions;
    //     @AuraEnabled public List<Object> statements;
    //     @auraEnabled public String skill;
    //     @auraEnabled public String competency;
    //     @auraEnabled public String excellenceFactor;
    //     @auraEnabled public String role;

    //     public Question(){}

    //     public Question(Question__c q) {
    //         this.id = q.Id;
    //         this.templateId = q.Template_Question__c;
    //         this.savedToQuestionBank = q.Template_Question__c != null;
    //         this.type = q.Type__c;
    //         this.order = (Integer)q.Order__c;
    //         this.required = q.Required__c;
    //         this.text = q.Label__c;

    //         this.competencyOrSkill = getCompetencyOrSkill(q);
    //         this.typeOptions = getTypeOptions(q);
    //     }

    //     public Question(BARS_Question__c q) {
    //         this.id = q.id;
    //         this.templateId = q.id;
    //         this.savedToQuestionBank = false;
    //         this.type = 'Bars';
    //         this.order = (Integer)q.Order__c;
    //         this.required = q.Required__c;
    //         this.text = q.Description__c;
    //         this.skill = q.Skill__c;
    //         this.competency = q.Competency__c;
    //         this.excellenceFactor = q.Excellence_Factor__c;
    //         this.role = q.Role__c;
    //         this.statements = (List<Object>)JSON.deserializeUntyped(q.Statements__c.replace('&quot;', '"'));
    //         this.typeOptions = new Map<String, Object>{'statements' => (List<Object>)JSON.deserializeUntyped(q.Statements__c.replace('&quot;', '"'))};
    //     }

    //     private Map<String, String> getCompetencyOrSkill(Question__c q) {
    //         /*
    //         EXAMPLE:
    //         {
    //             "id": "a0b0R000007cbWIQAY",
    //             "label": "Communication"
    //         }
    //         */
    //         Map<String, String> compOrSkillData = new Map<String, String>();

    //         String compOrSkillId = q.Competency__c != null ? q.Competency__c : q.Skill__c;
    //         String compOrSkillLabel = q.Competency__c != null ? q.Competency__r.Name : q.Skill__r.Name;

    //         compOrSkillData.put('id', compOrSkillId);
    //         compOrSkillData.put('label', compOrSkillLabel);

    //         return compOrSkillData;
    //     }

    //     private Map<String, Object> getTypeOptions(Question__c q) {
    //         /*
    //         EXAMPLE:
    //         {
    //             "scaleMin": "1",
    //             "scaleMax": "4",
    //             "hideNumericValues": false,
    //             "scaleOptions": [
    //                 {
    //                     "numericValue": "1",
    //                     "label": "Emerging Skill"
    //                 },
    //                 {
    //                     "numericValue": "2",
    //                     "label": "Developing Skill"
    //                 },
    //                 {
    //                     "numericValue": "3",
    //                     "label": "Mastering Skill"
    //                 },
    //                 {
    //                     "numericValue": "4",
    //                     "label": "Exceeding Skill"
    //                 }
    //             ]
    //         }
    //         */

    //         Map<String, Object> typeOptions = new Map<String, Object>();

    //         if(q.Type__c == 'Scale') {
    //             typeOptions = (Map<String, Object>)JSON.deserializeUntyped(q.Type_Options_JSON__c);
    //         }

    //         return typeOptions;
    //     }
    // }

    // //bank question
    // private class BankQuestion extends Question {
    //     @AuraEnabled public String name;
    //     @AuraEnabled public String createdBy;
    //     @AuraEnabled public DateTime createdDate;
    //     @AuraEnabled public List<String> usedIn;
    //     @AuraEnabled public List<String> roles;

    //     public BankQuestion(Question__c q, Set<String> usedIn) {
    //         super(q);

    //         this.name = q.Name;
    //         this.createdBy = q.CreatedBy.Name;
    //         this.createdDate = q.CreatedDate;
    //         this.usedIn = new List<String>(usedIn);
    //         this.setRoles(q);
    //     }

    //     private void setRoles(Question__c q) {
    //         List<String> associatedRoles = new List<String>();

    //         for(Question_Role__c qr : q.Question_Roles__r) {
    //             associatedRoles.add(qr.Role__r.Name);
    //         }

    //         this.roles = associatedRoles;
    //     }
    // }

    // //add response to base question
    // private class QuestionResponse extends Question {
    //     @AuraEnabled public String response;

    //     public QuestionResponse(Question__c q) {
    //         super(q);

    //         setQuestionResponse(q.Assessment_Question_Responses__r);
    //     }

    //     public QuestionResponse(BARS_Question__c q) {
    //         super(q);

    //         setQuestionResponse(q.Assessment_Question_Responses__r);
    //     }

    //     private void setQuestionResponse(List<Assessment_Question_Response__c> aqrs) {
    //         if(!aqrs.isEmpty()) {
    //             Assessment_Question_Response__c response = aqrs.get(0);
    //             if (response.BARS_Answer__c != null) {
    //                 this.response = String.valueOf(response.BARS_Answer__c);
    //                 return;
    //             }
    //             this.response = String.isEmpty(response.Paragraph_Answer__c) ? String.valueOf(response.Scale_Answer__c) : response.Paragraph_Answer__c;
    //         }
    //     }
    // }


    // /***** Assessee Wrapper *****/
    // private with sharing class Assessee {
    //     @AuraEnabled public String name;
    //     @AuraEnabled public String role;
    //     @AuraEnabled public String avatarUrl;

    //     private Assessee(Id userId) {
    //         this.setAssesseeNameAndRole(userId);
    //         this.setAssesseeAvatarUrl(userId);
    //     }

    //     private void setAssesseeNameAndRole(Id userId) {
    //         slj__Learner_Profile__c lp = [SELECT Name,
    //                                             (
    //                                                 SELECT slj__Role__r.Name 
    //                                                 FROM slj__Learner_Roles__r 
    //                                                 WHERE slj__Current_Role__c = true
    //                                             )
    //                                      FROM slj__Learner_Profile__c 
    //                                      WHERE slj__User__c = :userId];
    //         this.name = lp.Name;

    //         //check for role
    //         if(!lp.slj__Learner_Roles__r.isEmpty()) {
    //             slj__Learner_Role__c lr = lp.slj__Learner_Roles__r.get(0);
    //             if(lr.slj__Role__r != null) {
    //                 this.role = lr.slj__Role__r.Name;
    //             }
    //         }
    //     }

    //     private void setAssesseeAvatarUrl(Id userId) {
    //         this.avatarUrl = [SELECT FullPhotoUrl FROM User WHERE Id = :userId].FullPhotoUrl;
    //     }
    // }


    // /***** Access Checks *****/
    // private static void checkAccess(Map<String, Map<String, List<String>>> accessMap) {
    //     dmlManager.checkAccess(accessMap);
    // }

    // private static FINAL Map<String, Map<String, List<String>>> updateAssessmentAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Update' => new List<String>{
    //             'Name', 'Status__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> createQuestionAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Assessment__c', 'Label__c', 'Order__c', 'Required__c',
    //             'Type__c', 'Type_Options_JSON__c', 'Competency__c', 'Skill__c'
    //         },
    //         'Update' => new List<String>{
    //             'Assessment__c', 'Label__c', 'Order__c', 'Required__c',
    //             'Type__c', 'Type_Options_JSON__c', 'Competency__c', 'Skill__c'
    //         }
    //     },
    //     'BARS_Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Assessment__c', 'Label__c', 'Order__c', 'Required__c', 'Statements__c', 'Manager_Title__c', 'Description__c',
    //             'Competency__c', 'Skill__c', 'Active__c', 'Excellence_Factor__c', 'Role__c', 'Manager_Description__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> updateQuestionAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Update' => new List<String>{
    //             'Assessment__c', 'Label__c', 'Order__c', 'Required__c',
    //             'Type__c', 'Type_Options_JSON__c', 'Competency__c', 'Skill__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> updateQuestionOrderAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Update' => new List<String>{
    //             'Order__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> cloneQuestionAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Template_Question__c', 'Order__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> addQuestionToBankAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Name', 'Is_Question_Bank__c', 'Assessment__c'
    //         },
    //         'Update' => new List<String>{
    //             'Name', 'Is_Question_Bank__c', 'Assessment__c'
    //         }
    //     },
    //     'Question_Role__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Question__c', 'Role__c'
    //         },
    //         'Update' => new List<String>{
    //             'Question__c', 'Role__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> deleteQuestionAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Delete' => new List<String>(),
    //         'Update' => new List<String>{
    //             'Order__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> addQuestionFromBankAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Name', 'Is_Question_Bank__c', 'Assessment__c', 'Template_Question__c', 'Order__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getTakeAssessmentDataAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Assessment_Invitation__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Assessment__c', 'Assessment_Taker__c', 'Assessor__c', 'Type__c', 'Due_Date__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name', 'Type__c'
    //         }
    //     },
    //     'Assessment_Response__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> saveAssessmentResponsesAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Assessment_Invitation__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Assessment__c', 'Assessment_Taker__c', 'Type__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name'
    //         }
    //     },
    //     'Assessment_Response__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Assessment__c', 'Assessment_Invitation__c', 'Status__c'
    //         },
    //         'Read' => new List<String>{
    //             'Id'
    //         }
    //     },
    //     'Assessment_Question_Response__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Question__c', 'User__c', 'Assessment_Response__c', 'Scale_Answer__c', 'Paragraph_Answer__c'
    //         },
    //         'Read' => new List<String>{
    //             'Question__c', 'User__c', 'Assessment_Response__c', 'Scale_Answer__c', 'Paragraph_Answer__c'
    //         }
    //     },
    //     'User' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getViewAssessmentDataAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Assessment_Response__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Assessment__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Assessment_Invitation__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Assessment_Taker__c', 'Assessor__c', 'Type__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> assessmentSelectorAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name', 'Status__c', 'Type__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> hasQuestionManagerPermSetAccessMap = new Map<String, Map<String, List<String>>>{
    //     'PermissionSetAssignment' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'AssigneeId'
    //         }
    //     },
    //     'PermissionSet' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name', 'NamespacePrefix'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getAssessmentQuestionsAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name', 'CreatedDate', 'Is_Question_Bank__c',
    //             'Competency__c', 'Skill__c', 'Label__c', 'Type_Options_JSON__c',
    //             'Order__c', 'Required__c', 'Template_Question__c', 'Type__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getRoleOptionsAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Role__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> updateOtherQuestionOrdersAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Order__c', 'Assessment__c'
    //         },
    //         'Update' => new List<String>{
    //             'Order__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> questionSelectorAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'CreatedDate', 'Assessment__c', 'Competency__c',
    //             'Is_Question_Bank__c', 'Label__c', 'Order__c', 'Required__c',
    //             'Skill__c', 'Template_Question__c', 'Type__c', 'Type_Options_JSON__c', 'Competency__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getBankQuestionsAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'CreatedDate', 'Assessment__c', 'Competency__c',
    //             'Is_Question_Bank__c', 'Label__c', 'Order__c', 'Required__c',
    //             'Skill__c', 'Template_Question__c', 'Type__c', 'Type_Options_JSON__c', 'Competency__c'
    //         }
    //     },
    //     'Competency__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Skill__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Role__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Question_Role__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Role__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name', 'LastModifiedDate'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getQuestionsForRolesAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question_Role__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Question__c', 'Role__c'
    //         }
    //     },
    //     'Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Is_Question_Bank__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getAssessmentQuestionResponsesAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name', 'CreatedDate', 'Is_Question_Bank__c', 'Competency__c','Skill__c',
    //             'Label__c', 'Type_Options_JSON__c', 'Order__c', 'Required__c', 'Template_Question__c', 'Type__c'
    //         }
    //     },
    //     'Competency__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Skill__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Assessment_Question_Response__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Scale_Answer__c', 'Paragraph_Answer__c', 'Assessment_Response__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getBarsAssessmentQuestionResponsesAccessMap = new Map<String, Map<String, List<String>>>{
    //     'BARS_Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name', 'Competency__c', 'Skill__c', 'Assessment__c', 'Order__c', 'Statements__c', 
    //             'Excellence_Factor__c', 'Skill_Description__c', 'Required__c', 'Description__c', 'Role__c'
    //         }
    //     },
    //     'Assessment_Question_Response__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'BARS_Answer__c', 'Assessment_Response__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> getBarsQuestionAccessMap = new Map<String, Map<String, List<String>>>{
    //     'BARS_Question__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Name', 'Competency__c', 'Description__c', 'Excellence_Factor__c', 'Label__c', 'Statements__c', 'Role__c', 
    //             'Skill__c', 'Assessment__c', 'Order__c', 'Skill_Description__c'
    //         }
    //     }
    // };


    // private static FINAL Map<String, Map<String, List<String>>> buildBarsQuestionForUpsertAccessMap = new Map<String, Map<String, List<String>>>{
    //     'BARS_Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Order__c', 'Required__c', 'Active__c', 'Skill__c', 'Competency__c', 'Excellence_Factor__c', 'Role__c', 'Statements__c',
    //             'Manager_Description__c', 'Manager_Title__c', 'Label__c', 'Description__c'
    //         },
    //         'Update' => new List<String>{
    //             'Order__c', 'Required__c', 'Active__c', 'Skill__c', 'Competency__c', 'Excellence_Factor__c', 'Role__c', 'Statements__c',
    //             'Manager_Description__c', 'Manager_Title__c', 'Label__c', 'Description__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> buildQuestionForUpsertAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Question__c' => new Map<String, List<String>>{
    //         'Create' => new List<String>{
    //             'Label__c', 'Order__c', 'Required__c', 'Type__c', 'Type_Options_JSON_c', 'Competency__c', 'Skill__c'
    //         },
    //         'Update' => new List<String>{
    //             'Label__c', 'Order__c', 'Required__c', 'Type__c', 'Type_Options_JSON_c', 'Competency__c', 'Skill__c'
    //         }
    //     }
    // };

    // private static FINAL Map<String, Map<String, List<String>>> updateOtherBarsQuestionOrderAccessMap = new Map<String, Map<String, List<String>>>{
    //     'BARS_Question__c' => new Map<String, List<String>>{
    //         'Update' => new List<String>{
    //             'Order__c', 'Assessment__c'
    //         }
    //     }
    // };
}