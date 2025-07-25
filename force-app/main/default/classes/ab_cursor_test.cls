public with sharing class ab_cursor_test {
    private static ResponseData rd;
    // private static Boolean isManager;
    private static Learner_Profile__c lp;

 
    @AuraEnabled
    public static ResponseData initData(String assignmentId){
        rd = new ResponseData();
        
        try {
            List<Learner_Profile__c> lps = [SELECT Id, People_Manager__c, User__r.ManagerId  
                                                 FROM Learner_Profile__c
                                                 WHERE User__c =: UserInfo.getUserId()
                                                 AND Status__c = 'Active'
                                                 WITH USER_MODE];

            List<Assessment_Response__c> responses = [SELECT Id, OwnerId, Assignment__r.Assessor__c, Assignment__r.Assessor__r.Name, Manager_Submitted__c, Assessment__c,Assessment__r.Role__c, Assessment__r.Name, Assessment__r.Description__c, Is_Manager__c, Assessment_Taker__c, Assessment_Taker__r.Name,
                                                             Assessment_Taker__r.Title__c, Assessment_Taker__r.User__r.SmallPhotoUrl, Manager__c, Manager_Response__c, 
                                                             Manager_Response__r.Status__c, Manager_Response__r.Assessment_Taker__r.Name, Due_Date__c, Status__c, Review_Skill_One__c, Review_Skill_One__r.Name, Review_Skill_Two__c, Review_Skill_Two__r.Name,
                                                             Job_Code__c, Asset__r.Description__c, Asset__r.Learner_Instructions__c, Asset__r.Assessor_Instructions__c, Asset__r.Assessment__r.Name, Asset__r.Objective__c,
                                                        (
                                                            SELECT Id, Name, Question__c, Question__r.Skill__c, Assessment_Response__c, Assessment_Response__r.Status__c, Assessee__c, Assessee__r.User__r.SmallPhotoUrl,
                                                                   Assessee__r.Name, Assessee__r.Title__c, Assessment_Taker__c, Assessment_Taker__r.Name, Scale_Answer__c, Manager_Scale_Answer__c
                                                            FROM Assessment_Question_Responses__r
                                                            ORDER BY Question__r.Order__c ASC
                                                        )
                                                      FROM Assessment_Response__c
                                                      WHERE Assignment__c =: assignmentId
                                                      WITH USER_MODE];
            
            if(lps.isEmpty()){
                rd.addError('No Learner Profile found');

                return rd;
            } else if(responses.isEmpty()){
                rd.addError('No asssessment response found.');
                return rd;
            }

            

            String userId = UserInfo.getUserId();
            Assessment_Response__c response = responses.get(0);
            lp = lps.get(0);
            Boolean isMyResponse = lp.Id == response.Assessment_Taker__c;
            Learner_Profile__c managerLP = new Learner_Profile__c();

            if(isMyResponse){
                managerLP = [SELECT Id
                             FROM Learner_Profile__c
                             WHERE User__c =: lp.User__r.ManagerId
                             AND Status__c = 'Active'
                             WITH USER_MODE];
            }
            
            // if(response.Manager__c == lp.Id && !managerFinished){
            //     rd.addError('You do not have permission to view this assessment until you finished your assessment of ' + response.Assessment_Taker__r.Name);
            //     return rd;
            // } else 
            
            Boolean isManager = lp.Id == response.Assignment__r.Assessor__c;

            if(response.Assessment_Taker__c != lp.Id && !isManager) {
                rd.addError('You do not have permission to view or take this assessment.');
                return rd;
            }

            getAssessmentData(response);

            rd.put('isMyResponse', lp.Id == response.Assessment_Taker__c);
            rd.put('response', response);
            rd.put('lpId', lp.Id);
            rd.put('managerLP', managerLP);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    private static void getAssessmentData(Assessment_Response__c response){
        Boolean isTeamView = response.Is_Manager__c;
        List<Question__c> questions = [SELECT Id, Excellence_Factor__c, Competency__r.Name, Competency__r.Excellence_Factor__c, Skill__c, Skill__r.Name,
                                              Skill__r.Skill_Definition__c, Order__c
                                       FROM Question__c
                                       WHERE Assessment__c =: response.Assessment__c
                                       WITH USER_MODE
                                       ORDER BY Order__c ASC];
        
        Map<String, Assessment_Question_Response__c> questionResponseByQuestionId = new Map<String, Assessment_Question_Response__c>();//Question|Assesee
        Map<String, Assessment_Question_Response__c> otherQuestionResponseByQuestionResponseId = new Map<String, Assessment_Question_Response__c>();//Question|AssessmentTaker
        // List<Assessment_Response__c> otherResponses = getOtherPeoplesResponses(response, isTeamView);
        List<String> skillIds = new List<String>();
        List<String> jobCodes = new List<String>{response.Job_Code__c};
        System.debug('*************** response.Assessment_Question_Responses__r ' + response.Assessment_Question_Responses__r.size());
        //map my responses
        for(Assessment_Question_Response__c questionResponse : response.Assessment_Question_Responses__r){
            System.debug('************** questionResponse?' + questionResponse);
            questionResponseByQuestionId.put(questionResponse.Question__c, questionResponse);
            skillIds.add(questionResponse.Question__r.Skill__c);
        }

        //map other peoples responses could be manager or other employees
        // for(Assessment_Response__c res : otherResponses){
        //     for(Assessment_Question_Response__c questionResponse : res.Assessment_Question_Responses__r){
        //         String key = questionResponse.Question__c + '|' + res.Id;
        //         otherQuestionResponseByQuestionResponseId.put(key, questionResponse);
        //         skillIds.add(questionResponse.Question__r.Skill__c);
        //     }

        //     jobCodes.add(res.Job_Code__c);
        // }

        Map<String, Integer> benchmarkBySkillJobCode = getBenchmarks(skillIds, jobCodes);

        // if(response.Status__c == 'Submitted' || response.Status__c == 'Completed'){
        //     questionResByQuestionResponseAssesseeId.putAll(getOtherPeoplesResponses(response, isManager));
        // }
        
        //we're going to group everything by references
        List<Map<String, Object>> orderedExcellenceFactions = new List<Map<String, Object>>();
        List<Map<String, Object>> skills = new List<Map<String, Object>>();
        Map<String, Map<String, Object>> excellenceFactorByName = new Map<String, Map<String, Object>>();
        Map<String, Map<String, Object>> competencyById = new Map<String, Map<String, Object>>();
        Map<String, Map<String, Object>> questionBySkill = new Map<String, Map<String, Object>>();
        Map<String, Map<String, Object>> questionBySkillAndJobCode = new Map<String, Map<String, Object>>();
            System.debug('*************** questions ' + questions);
        for(Question__c question : questions){
            skills.add(new Map<String, Object>{
                'label' => question.Skill__r.Name,
                'value' => question.Skill__c
            });
            //create Excellence Factor if its new
            if(!excellenceFactorByName.containsKey(question.Excellence_Factor__c)){
                Map<String, Object> newEF = new Map<String, Object>{
                    'name' => question.Excellence_Factor__c,
                    'competencies' => new List<Map<String, Object>>()
                };

                orderedExcellenceFactions.add(newEF);
                excellenceFactorByName.put(question.Excellence_Factor__c, newEF);
            }

            //create Competency if its new and add it to the EF
            if(!competencyById.containsKey(question.Competency__c)){
                Map<String, Object> ef = excellenceFactorByName.get(question.Competency__r.Excellence_Factor__c);
                //check comps EF
                List<Object> compList = (List<Object>)ef.get('competencies');

                Map<String, Object> comp = new Map<String, Object>{
                    'Id' => question.Competency__c,
                    'name' => question.Competency__r.Name,
                    'questions' => new List<Map<String, Object>>()
                };

                compList.add(comp);
                competencyById.put(question.Competency__c, comp);
            }

            //Add Skill Questions to Competencies
            Map<String, Object> comp = (Map<String, Object>)competencyById.get(question.Competency__c);
            List<Object> compQuestions = (List<Object>)comp.get('questions');
            Map<String, Object> questionMap = question.getPopulatedFieldsAsMap().clone();

            Assessment_Question_Response__c questionResponse = questionResponseByQuestionId.get(question.Id);
            
            //if we don't have an answer make a stub for it
            if(questionResponse == null){
                questionResponse = new Assessment_Question_Response__c(
                    OwnerId = response.OwnerId,
                    Assessment_Response__c = response.Id,
                    Question__c = question.Id
                );
            }

            Map<String, Object> questionResponseMap = questionResponse.getPopulatedFieldsAsMap().clone();
            
            String benchmarkKey = question.Skill__c + '|' + response.Job_Code__c;
            questionResponseMap.put('benchmarkAnswer', benchmarkBySkillJobCode.get(benchmarkKey));

            questionMap.put('questionResponse', questionResponseMap);
            compQuestions.add(questionMap);
            questionBySkill.put(question.Skill__c, questionMap);
        }

        addSkillStatements(questionBySkill, response.Assessment__r.Role__c);
        
        rd.put('excellenceFactors', orderedExcellenceFactions);
        rd.put('skills', skills);
    }

    private static void addSkillStatements(Map<String, Map<String, Object>> questionBySkill, String role){
        for(Skill_Statement__c skillStatement : [SELECT Id, Skill__c, Skill__r.Name, Statement__c, Proficiency_Level__c,
                                                        Proficiency_Level_Text__c
                                                 FROM Skill_Statement__c
                                                 WHERE Role__c =: role
                                                 AND Skill__c =: questionBySkill.keySet()
                                                 WITH USER_MODE]){
            Map<String, Object> question = questionBySkill.get(skillStatement.Skill__c);
                                                    
            if(!question.containsKey('skillStatements')){
                List<Map<String, Object>> statements = new List<Map<String, Object>>();

                //prefill the list with the possible statement ranges
                for(Integer i = 0; i < 4; i++){
                    statements.add(new Map<String, Object>{
                        'profLevel' => '',
                        'statements' => new List<String>()
                    });
                }

                question.put('skillStatements', statements);
            }

            

            List<Map<String, Object>> skillStatements = (List<Map<String, Object>>)question.get('skillStatements');
            //Proficiency_Level__c starts from 1 so we need to decrement by one
            Map<String, Object> skillStatementMap = skillStatements.get(Integer.valueOf(skillStatement.Proficiency_Level__c - 1));
            skillStatementMap.put('profLevel', skillStatement.Proficiency_Level_Text__c);
            ((List<String>)skillStatementMap.get('statements')).add(skillStatement.Statement__c);
        }
    }

    

    private static Map<String, Integer> getBenchmarks(List<String> skills, List<String> jobCodes){
        Map<String, Integer> benchmarkBySkillJobCode = new Map<String, Integer>();

        for(Benchmark__c benchmark : [SELECT Id, Skill__c, Job_Code__c, Proficiency_Target__c
                                      FROM Benchmark__c
                                      WHERE Job_Code__c =: jobCodes
                                      AND Skill__c =: skills
                                      WITH USER_MODE]){
            benchmarkBySkillJobCode.put(benchmark.Skill__c + '|' + benchmark.Job_Code__c, Integer.valueOf(benchmark.Proficiency_Target__c));
        }
        System.debug('************* ' + benchmarkBySkillJobCode);
        return benchmarkBySkillJobCode;
    }

    private static List<Assessment_Response__c> getOtherPeoplesResponses(Assessment_Response__c myResponse, Boolean isTeamView){
        Set<String> responseFields = new Set<String>{'Id', 'Name', 'Assessment_Taker__c', 'Assessment_Taker__r.Name', 'Status__c',
                                                     'Assessment_Taker__r.User__r.SmallPhotoUrl', 'Assessment_Taker__r.Title__c', 'Review_Skill_One__c', 'Review_Skill_Two__c',
                                                     'Review_Skill_One__r.Name', 'Review_Skill_Two__r.Name', 'Job_Code__c'};
        Set<String> questionResponseFields = new Set<String>{'Id', 'Name', 'Question__c', 'Question__r.Skill__c', 'Assessment_Response__c', 'Assessment_Response__r.Status__c', 'Assessee__c', 
                                                             'Assessee__r.User__r.SmallPhotoUrl', 'Assessee__r.Name', 'Assessee__r.Title__c', 'Assessment_Taker__c', 'Assessment_Taker__r.Name', 'Scale_Answer__c'};

        
        String whereClause = '';
        String childWhereClause = '';
        String responseId = '';
        String assesseeId = '';

        if(isTeamView){ //its a manager response so find all other employee responses
            responseId = myResponse.Id;
            whereClause = ' WHERE Manager_Response__c = :responseId'; 
        } else {//its an employee or mangager looking at an employee response so find manager responses
            assesseeId = myResponse.Assessment_Taker__c;
            responseId = myResponse.Manager_Response__c;
            whereClause = ' WHERE Id = :responseId';
            childWhereClause = ' WHERE Assessee__c = :assesseeId';
        }

        String soqlString = 'SELECT ' + String.join(new List<String>(responseFields), ', ') + 
                            ' ,(' +
                                  ' SELECT ' + String.join(new List<String>(questionResponseFields), ', ') +
                                  ' FROM Assessment_Question_Responses__r' +
                                    childWhereClause +
                                  ' ORDER BY Question__r.Order__c ASC' +
                            ' )' +
                            ' FROM Assessment_Response__c' +
                            whereClause + 
                            ' ORDER BY Assessment_Taker__r.Name ASC';

        return Database.query(soqlString, AccessLevel.USER_MODE);
    }

    @AuraEnabled
    public static ResponseData save(String responseId, Boolean isDraft, Boolean isMyResponse, List<Assessment_Question_Response__c> questionResponses){
        ResponseData rd = new ResponseData();
        
        try {
            System.debug('*********** questionResponses ' + questionResponses);
            System.debug('*********** questionResponses ' + isDraft);
            System.debug('*********** isMyResponse ' + isMyResponse);
            upsert as user questionResponses;

            Assessment_Response__c response = new Assessment_Response__c(
                Id = responseId
            );

            if(isMyResponse){
                response.Status__c = 'In Progress';
            }

            if(!isDraft){
                if(isMyResponse){
                    response.Submission_Date__c = Date.today();
                    response.Status__c = 'Submitted';
                } else {
                    response.Manager_Submitted__c = true; 
                }
            }

            update as user response;

            rd.put('questionResponses', questionResponses);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }
}