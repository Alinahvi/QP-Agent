public with sharing class SurveyQuestionScoreHelper {
    public static Map<Id, Id> latestVersionBySurveyId = new Map<Id, Id>();
    // public static String sessionSurveyId = '';
    
    public static void updateLearningCsatScore(List<SurveyQuestionScore> newList) {
        Set<Id> invitationIds = new Set<Id>();
        for(Survey srv : [SELECT Id, Name, developername, LatestVersionId
                            FROM Survey 
                            WHERE DeveloperName =: Label.ACT_Course_Survey_Name 
                            OR DeveloperName =: Label.ACT2_Session_Survey_Name
                            WITH USER_MODE]) {
            latestVersionBySurveyId.put(srv.Id, srv.LatestVersionId);
            // if(srv.developername == Label.ACT2_Session_Survey_Name) {
            //     sessionSurveyId = srv.Id;
            // }
        }
        
        if(latestVersionBySurveyId.isEmpty() || latestVersionBySurveyId.size() < 2) {
            return;
        }

        for(SurveyQuestionScore response : newList) {
            if(response.SurveyInvitationId != null && latestVersionBySurveyId.containsKey(response.SurveyId)) {
                invitationIds.add(response.SurveyInvitationId); 
            }                       	
        }
        if(!invitationIds.isEmpty()) {
            try {
                calculateSurveyScore(invitationIds);
            }catch(Exception e) {
                System.debug('Error calculateSurveyScore ----- '+e.getMessage()); 
                insert (new Integration_Error__c(
                    Error_Message__c = 'Error while updating - survey',
                    Http_Response_Body__c = 'ERROR :: '+e.getMessage() + ' -- '+e.getStackTraceString() ,
                    Type__c = 'CSAT'
                ));                
            }
        }            
    }

    private static void calculateSurveyScore(Set<Id> invitationIds) {
        if(invitationIds.isEmpty()) {
            return;
        }
        Map<Id, Course__c> coursesTobeUpdated = new Map<Id, Course__c>();
        Map<Id, Session__c> sessionToUpdate = new Map<Id, Session__c>();        
        Map<Id, Course__c> relatedCoursesByInvId = findRelatedCourses(invitationIds);
        updateCourseCsatField(relatedCoursesByInvId);
        Map<Id, Session__c> relatedSessionsByInvId = findRelatedSessions(invitationIds);
        updateSessionCsatFields(relatedSessionsByInvId);                
    }

    private static Map<Id, Course__c> findRelatedCourses(Set<Id> invitationIds) {
        Map<Id, Course__c> relatedCourses = new Map<Id, Course__c>();
        for(Course__c course : [SELECT Id, Name, Survey__c, Survey_Invitation__c,
                                    Survey_Response_Count__c, Survey_URL__c,
                                    CSAT__c 
                                FROM Course__c 
                                WHERE Survey_Invitation__c IN :invitationIds
                                AND Survey__c != null
                                WITH USER_MODE]) {
            relatedCourses.put(course.Survey_Invitation__c, course);            
        } 
        return relatedCourses;
    }

    private static Map<Id, Session__c> findRelatedSessions(Set<Id> invitationIds) {
        Map<Id, Session__c> relatedSession = new Map<Id, Session__c>();
        for(Session__c session : [SELECT Id, Name, Survey__c, Survey_Invitation__c,
                                    Survey_Response_Count__c, Survey_URL__c,
                                    CSAT__c, Facilitator_CSAT__c, Effectiveness_CSAT__c, Session_CSAT__c
                                FROM Session__c 
                                WHERE Survey_Invitation__c IN :invitationIds
                                AND Survey__c != null
                                WITH USER_MODE]) {
            relatedSession.put(session.Survey_Invitation__c, session);            
        }        
        return relatedSession;
    }

    private static void updateCourseCsatField(Map<Id, Course__c> relatedCoursesByInvId) {
        if(relatedCoursesByInvId.isEmpty()) {
            return;
        }
        Map<Id, List<SurveyQuestionScore>> scoreByInvId = new Map<Id, List<SurveyQuestionScore>>();
        List<Course__c> courseToUpdate = new List<Course__c>();
        for(SurveyQuestionScore score : [SELECT SurveyInvitationId, Score, SurveyId, ResponseCount, SurveyVersionId
                                        FROM SurveyQuestionScore
                                        WHERE SurveyInvitationId IN :relatedCoursesByInvId.keySet()
                                        AND ScoreType='Overall'
                                        AND Question.QuestionType = 'Rating'
                                        WITH USER_MODE]) {
            if(!scoreByInvId.containsKey(score.SurveyInvitationId)) {
                scoreByInvId.put(score.SurveyInvitationId, new List<SurveyQuestionScore>());
            }
            scoreByInvId.get(score.SurveyInvitationId).add(score);
        }
        for(String key : scoreByInvId.keySet()) {
            List<SurveyQuestionScore> dataList = scoreByInvId.get(key);
            Double newCSATWeight = 0;
            Integer newResponseCount = 0;
            for(SurveyQuestionScore qs : dataList) {
                Double CSATWeight = qs.Score * qs.ResponseCount;
                newCSATWeight += CSATWeight;
                newResponseCount += qs.ResponseCount;
            }
            Course__c course = relatedCoursesByInvId.get(key);
            Decimal score = newCSATWeight / newResponseCount;
            Decimal csatScore = score.setScale(2, System.RoundingMode.HALF_UP);
            courseToUpdate.add(new Course__c(
                    Id = course.Id,
                    CSAT__c = csatScore,
                    Survey_Response_Count__c = newResponseCount
                )
            );                       		           
        }

        if(!courseToUpdate.isEmpty()) {
            try {
                update courseToUpdate;
            } catch(Exception e) {
                System.debug('Error coursesTobeUpdated ----- '+e.getMessage()); 
                insert (new Integration_Error__c(
                    Error_Message__c = 'Error while updating course csat field',
                    Http_Response_Body__c = 'ERROR :: '+e.getMessage() + ' -- '+e.getStackTraceString() ,
                    Type__c = 'CSAT'
                ));                                             
            }                      
        }
    }

    private static void updateSessionCsatFields(Map<Id, Session__c> relatedSessionsByInvId) {
        if(relatedSessionsByInvId.isEmpty()) {
            return;
        }
        Map<Id, List<SurveyQuestionScore>> scoreByInvId = new Map<Id, List<SurveyQuestionScore>>();
        List<Session__c> sessionToUpdate = new List<Session__c>();
        for(SurveyQuestionScore score : [SELECT SurveyInvitationId, Score, SurveyId, ResponseCount, SurveyVersionId, 
                                        Question.DeveloperName
                                        FROM SurveyQuestionScore
                                        WHERE SurveyInvitationId IN :relatedSessionsByInvId.keySet()
                                        AND ScoreType = 'Overall'
                                        AND Question.QuestionType = 'Rating'
                                        WITH USER_MODE]) {
            if(!scoreByInvId.containsKey(score.SurveyInvitationId)) {
                scoreByInvId.put(score.SurveyInvitationId, new List<SurveyQuestionScore>());
            }
            scoreByInvId.get(score.SurveyInvitationId).add(score);
        }
        
        for(String invId : scoreByInvId.keySet()) {
            List<SurveyQuestionScore> dataList = scoreByInvId.get(invId);
            Session__c session = relatedSessionsByInvId.get(invId);
            Double sessionCsat;
            Double facilitatorCsat;
            Double effectivenessCsat;
            Integer newResponseCount = 0;
            for(SurveyQuestionScore qs : dataList) {
                if(qs.Question.DeveloperName == Label.ACT_Session_CSAT_DevName_Question) {
                    sessionCsat = qs.score.setScale(2, System.RoundingMode.HALF_UP);
                    newResponseCount = qs.ResponseCount;
                } else if(qs.Question.DeveloperName == Label.ACT_Session_Facilitator_DevName_Question) {
                    facilitatorCsat = qs.score.setScale(2, System.RoundingMode.HALF_UP);
                } else if(qs.Question.DeveloperName == Label.ACT_Session_Effectiveness_DevName_Question) {
                    effectivenessCsat = qs.score.setScale(2, System.RoundingMode.HALF_UP);
                }                
            }
            sessionToUpdate.add(new Session__c(
                    Id = session.Id,
                    CSAT__c = sessionCsat,
                    Session_CSAT__c = sessionCsat,
                    Survey_Response_Count__c = newResponseCount,
                    Effectiveness_CSAT__c = effectivenessCsat,
                    Facilitator_CSAT__c = facilitatorCsat
                )
            ); 
        }
        
        if(!sessionToUpdate.isEmpty()) {
            try {
                update sessionToUpdate;
            } catch(Exception e) {
                System.debug('Error sessionToUpdate ----- '+e.getMessage()); 
                insert (new Integration_Error__c(
                    Error_Message__c = 'Error while updating session csat fields',
                    Http_Response_Body__c = 'ERROR :: '+e.getMessage() + ' -- '+e.getStackTraceString() ,
                    Type__c = 'CSAT'
                ));               
            }
        }
    }

    public static void updateCaseCsatScore(List<SurveyQuestionScore> newList) {
        Set<Id> invitationIds = new Set<Id>();
        Map<Id, Survey> sfSurvey = new Map<Id, Survey>([SELECT Id, Name, developername FROM Survey 
                                                        WHERE DeveloperName =: Label.ACT2_Support_Survey
                                                        WITH USER_MODE]);
        
        if(sfSurvey.isEmpty()) {
            return;
        }
        for(SurveyQuestionScore response : newList) {
            if(response.SurveyInvitationId != null && 
                (sfSurvey.containsKey(response.SurveyId))) { 
                invitationIds.add(response.SurveyInvitationId);                 
            }            	
        }
        
        List<Case> caseToUpdate = new List<Case>();
        Map<Id, Case> relatedCaseByInvId = new Map<Id, Case>();
        for(Case actCase : [SELECT Id, Survey_Invitation__c, CSAT__c 
                            FROM Case 
                            WHERE Survey_Invitation__c IN :invitationIds
                            AND Survey__c != null
                            WITH USER_MODE]) {
            relatedCaseByInvId.put(actCase.Survey_Invitation__c, actCase);            
        }

        for(SurveyQuestionScore qScore : [SELECT SurveyInvitationId,
                                                Score, 
                                                ResponseCount
                                            FROM SurveyQuestionScore
                                            WHERE SurveyInvitationId IN :relatedCaseByInvId.keySet()
                                            AND ScoreType='Overall'
                                            AND Question.QuestionType = 'Rating'
                                            WITH USER_MODE]) {
            Case actCase = relatedCaseByInvId.get(qScore.SurveyInvitationId);
            if(actCase != null) {
                actCase.CSAT__c = qScore.Score;
                caseToUpdate.add(actCase);
            }
        }
        
        if(!caseToUpdate.isEmpty()) {
            try {
                update caseToUpdate;
            } catch(DMLException e) {
                System.debug('Error sessionToUpdate ----- '+e.getMessage());                
            }
        }
    }
}