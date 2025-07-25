public with sharing class learningItemDetailQuiz {

    @AuraEnabled
    public static ResponseData submitQuiz(String questionJSON, String feedback, String assignmentId){
        ResponseData rd = new ResponseData();

        try {
            List<quizQuestion> questions = (List<quizQuestion>) JSON.deserialize(questionJSON, List<quizQuestion>.class);
            List<String> questionIds = new List<String>();
            Decimal score = 0;
            Decimal totalCorrectQuestions = 0;
            Decimal totalPointValue = 0;
            Decimal scoredNeeded = 0;
            Boolean passed = false;

            for(quizQuestion question : questions){
                questionIds.add(question.quizQuestionId);
            }

            Assignment__c assignment = [SELECT Id, Asset__c, Asset__r.RecordType.DeveloperName, Asset__r.Passing_Score__c, Asset__r.Passing_Score_Numeric__c, Completed__c, Learner_Profile__c
                                        FROM Assignment__c 
                                        WHERE Id =: assignmentId
                                        WITH USER_MODE];

            Boolean isQuiz = assignment.Asset__r.RecordType.DeveloperName == 'Quiz';
            scoredNeeded = isQuiz ? assignment.Asset__r.Passing_Score__c : assignment.Asset__r.Passing_Score_Numeric__c;
            //validate answers against the database versions
            Map<Id, Quiz_Answer_Option__c> sourceAnswers = new Map<Id, Quiz_Answer_Option__c>([SELECT Id, Is_Correct__c, Matching_Left_Pair__c, Matching_Right_Pair__c
                                                                                               FROM Quiz_Answer_Option__c
                                                                                               WHERE Quiz_Question__c IN :questionIds
                                                                                               WITH USER_MODE]);

            Quiz_Attempt__c quizAttempt = new Quiz_Attempt__c(
                Learner_Profile__c = assignment.Learner_Profile__c,
                Asset__c = assignment.Asset__c,
                Assignment__c = assignment.Id,
                Assessor_Feedback__c = feedback,
                Max_Score__c = 0
            );

            for(AggregateResult ar : [SELECT MAX(Point_Value__c) maxScore
                                      FROM Quiz_Answer_Option__c 
                                      WHERE Quiz_Question__r.Asset__c = :assignment.Asset__c
                                      AND Quiz_Question__r.Include_In_Scoring__c = true
                                      GROUP BY Quiz_Question__c]){
                quizAttempt.Max_Score__c += (Decimal) ar.get('maxScore');
            }

            List<Quiz_Question_Response__c> questionResponses = new List<Quiz_Question_Response__c>();
            List<Quiz_Answer_Response__c> answerResponses = new List<Quiz_Answer_Response__c>();
            System.debug('************* questions ' + questions);
            for(quizQuestion question : questions){
                Decimal totalCorrectAnswers = 0;
                Decimal totalSelectedAnswers = 0;

                Quiz_Question_Response__c questionResponse = new Quiz_Question_Response__c(
                    Quiz_Question__c = question.quizQuestionId,
                    Passed__c = false,
                    Type__c = question.type,
                    Question_Text__c = question.questionText,
                    Context__c = question.context,
                    Order__c = question.order,
                    Number_of_Answers__c = question.totalCorrectAnswers,
                    Correct_Feedback__c = question.correctFeedback,
                    Incorrect_Feedback__c = question.incorrectFeedback
                );

                questionResponses.add(questionResponse);

                for(quizAnswer answer : question.answers){
                    Quiz_Answer_Response__c answerResponse = new Quiz_Answer_Response__c(
                        Quiz_Question_Response__r = questionResponse,
                        Quiz_Answer_Option__c = answer.answerOptionId,
                        Answer_Text__c = answer.answerText,
                        Selected__c = answer.isSelected,
                        Selected_Pair__c = answer.selectedPair,
                        Order__c = answer.order,
                        Feedback__c = answer.feedback,
                        Matching_Left_Pair__c = answer.leftPair,
                        Matching_Right_Pair__c = answer.rightPair,
                        Point_Value__c = answer.pointValue
                    );

                    if(isQuiz){
                        Quiz_Answer_Option__c answerOption = sourceAnswers.get(answer.answerOptionId);
                        answerResponse.Is_Correct__c = answerOption.Is_Correct__c;
                        
                        if(answer.isSelected){
                            totalSelectedAnswers++;
                        }
                        
                        if(question.type == 'Matching' && answer.selectedPair == answerOption.Matching_Right_Pair__c){
                            totalCorrectAnswers++;
                        } else if (answer.isSelected && answerOption.Is_Correct__c){
                            totalCorrectAnswers++;
                        }
                    } else if(question.includeInScoring){
                        if(answer.isSelected){
                            totalPointValue += answer.pointValue;
                        }
                    }

                    answerResponses.add(answerResponse);
                }

                if(isQuiz){
                    if(question.type == 'Multiple Choice' && totalSelectedAnswers != question.totalCorrectAnswers){
                        continue;
                    }

                    if(totalCorrectAnswers == question.totalCorrectAnswers){
                        questionResponse.Passed__c = true;
                        totalCorrectQuestions++;
                    }
                }
            }

            score = isQuiz ? ((totalCorrectQuestions / questions.size()) * 100).setScale(2) : totalPointValue;
            passed = score >= scoredNeeded;

            quizAttempt.Score__c = score;
            quizAttempt.Passed__c = passed;
            quizAttempt.Passing_Score__c = scoredNeeded;

            if(passed){
                quizAttempt.Completion_Date__c = Date.today();
            }

            insert quizAttempt;

            for(Quiz_Question_Response__c qr : questionResponses){
                qr.Quiz_Attempt__c = quizAttempt.Id;
            }

            insert questionResponses;

            for(Quiz_Answer_Response__c ar : answerResponses){
                ar.Quiz_Attempt__c = quizAttempt.Id;
                ar.Quiz_Question_Response__c = ar.Quiz_Question_Response__r.Id;
                ar.Quiz_Question_Response__r = null;
            }

            insert answerResponses;

            if(passed){
                assignment.Completed__c = true;
                update assignment;
            }

            //requery data to return to the client
            Map<String, Object> quizData = getQuizData(assignment.Asset__c, assignment.Id, assignment.Learner_Profile__c, false, false);
            rd.put('quizData', quizData);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData getQuizData(String assetId, String assignmentId){
        ResponseData rd = new ResponseData();
        
        try {
            System.debug('************* in here? ');
            Map<String, Object> quizData = getQuizData(assetId, assignmentId, null, true, false);
            
            rd.put('quizData', quizData);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static Map<String, Object> getQuizData(String assetId, String assignmentId, String lpId, Boolean isReattempt, Boolean isPreview){
        Map<String, Object> quizData = new Map<String, Object>{
            'isAssessor' => false
        };
        List<Quiz_Attempt__c> quizAttempts = new List<Quiz_Attempt__c>();

        if(!isReattempt && !isPreview){
            quizAttempts = [SELECT Id, Passed__c, Score__c, Completion_Date__c, Passing_Score__c, Assessor_Feedback__c, Max_Score__c
                            FROM Quiz_Attempt__c
                            WHERE Assignment__c =: assignmentId 
                            AND Learner_Profile__c =: lpId
                            ORDER BY CreatedDate DESC
                            LIMIT 1];
        }
        
        if(assignmentId != null){
            Assignment__c assignment = [SELECT Id, Assessor__c, Assessor__r.Name, Assessor__r.User__r.SmallPhotoUrl, Assessor_Type__c, Assessment_Data_Link__c, Learner_Profile__r.Name, Learner_Profile__r.User__r.SmallPhotoUrl
                                        FROM Assignment__c
                                        WHERE Id =: assignmentId
                                        WITH USER_MODE];

            quizData.put('assignment', assignment);
        
            if(assignment.Assessor_Type__c != 'Ai'){
                Learner_Profile__c currentUserLP = [SELECT Id FROM Learner_Profile__c WHERE User__c =: UserInfo.getUserId() AND Status__c = 'Active'];
                quizData.put('isAssessor', assignment.Assessor__c == currentUserLP.Id);
            } else {
                quizData.put('isAssessor', false);
            }
        }
        System.debug('************* quizAttempts ' + quizAttempts);
        //if we never took it get the data from the asset or its an reattempt/preview
        if(quizAttempts.isEmpty()){
            List<Quiz_Question__c> questions = [SELECT Id, Context__c, Question_Text__c, Type__c, Asset__c, Order__c, Number_Of_Answers__c, Correct_Feedback__c, Incorrect_Feedback__c, Include_In_Scoring__c,
                                                    (
                                                        SELECT Id, Answer_Text__c, Feedback__c, Is_Correct__c, Matching_Left_Pair__c,
                                                                Matching_Right_Pair__c, Order__c, Statements__c, Point_Value__c
                                                        FROM Quiz_Answer_Options__r
                                                        ORDER BY Order__c ASC
                                                    )
                                                FROM Quiz_Question__c
                                                WHERE Asset__c =: assetId
                                                WITH USER_MODE
                                                ORDER BY Order__c ASC];

            List<quizQuestion> formattedQuestions = new List<quizQuestion>();
            System.debug('************* questions ' + questions);
            for(Quiz_Question__c q : questions){
                formattedQuestions.add(new quizQuestion(q));
            }

            System.debug('************* formattedQuestions ' + formattedQuestions);
            quizData.put('questions', formattedQuestions);
        } else { // else display the data from the attempted quiz
            Quiz_Attempt__c quizAttempt = quizAttempts.get(0);
            List<Quiz_Question_Response__c> questionResponses = [SELECT Id, Context__c, Quiz_Question__c, Question_Text__c, Type__c, Order__c, Number_Of_Answers__c, Passed__c, Correct_Feedback__c, Incorrect_Feedback__c,
                                                                        Include_In_Scoring__c,
                                                                    (
                                                                        SELECT Id, Answer_Text__c, Feedback__c, Is_Correct__c, Matching_Left_Pair__c,
                                                                                Matching_Right_Pair__c, Selected_Pair__c, Selected__c, Order__c, Quiz_Answer_Option__c,
                                                                                Statements__c, Point_Value__c
                                                                        FROM Quiz_Answer_Responses__r
                                                                        ORDER BY Order__c ASC
                                                                    )
                                                                FROM Quiz_Question_Response__c
                                                                WHERE Quiz_Attempt__c =: quizAttempt.Id
                                                                WITH USER_MODE
                                                                ORDER BY Order__c ASC];

            List<quizQuestion> formattedQuestions = new List<quizQuestion>();

            for(Quiz_Question_Response__c qr : questionResponses){
                formattedQuestions.add(new quizQuestion(qr));
            }

            quizData.put('quizAttempt', quizAttempt);
            quizData.put('questions', formattedQuestions);
        }

        return quizData;
    }

    @AuraEnabled
    public static ResponseData redirectToOpportunity(String userId){
        ResponseData rd = new ResponseData();        
        try {
            List<Learner_Profile__c> lp = [SELECT Id FROM Learner_Profile__c WHERE User__c =: userId AND Status__c = 'Active' LIMIT 1];
            if(lp.isEmpty()) {
                rd.addError('No Learner Profile record found.');
                return rd;
            }
            List<Opportunity> opp = [SELECT Id, Learner_Profile__c, Name 
                                    FROM Opportunity 
                                    WHERE Learner_Profile__c =: lp[0].Id
                                    WITH USER_MODE
                                    LIMIT 1];
            if(opp.isEmpty()) {
                Opportunity oppRecord = new Opportunity(
                    Name = 'Sales Coach Opportunity - ' + UserInfo.getName(),
                    StageName = 'Readiness',
                    CloseDate = Date.today().addDays(15),
                    Learner_Profile__c = lp[0].Id                    
                );
                insert oppRecord;

                String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();
                sfUrl += '/lightning/app/standard__LightningSales/r/Opportunity/'+oppRecord.Id+'/view';
                rd.put('url', sfUrl);
            } else {
                String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();
                sfUrl += '/lightning/app/standard__LightningSales/r/Opportunity/'+opp[0].Id+'/view';
                // sfUrl += '/'+opp[0].Id;
                rd.put('url', sfUrl);
            }           
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class quizQuestion {
        @AuraEnabled public String id; //Quiz Question or Quiz Attempt Question
        @AuraEnabled public String quizQuestionId;
        @AuraEnabled public String questionText;
        @AuraEnabled public String context;
        @AuraEnabled public String type;
        @AuraEnabled public String correctFeedback;
        @AuraEnabled public String incorrectFeedback;
        @AuraEnabled public Boolean includeInScoring;
        @AuraEnabled public List<quizAnswer> answers;
        @AuraEnabled public Decimal order;
        @AuraEnabled public Decimal totalCorrectAnswers;
        @AuraEnabled public Boolean passed;

        
        public quizQuestion(Quiz_Question__c question){
            this.id = question.Id;
            this.quizQuestionId = question.Id;
            this.questionText = question.Question_Text__c;
            this.type = question.Type__c;
            this.order = question.Order__c;
            this.passed = false;
            this.totalCorrectAnswers = this.type == 'Scale' ? 1 : question.Number_Of_Answers__c;
            this.answers = new List<quizAnswer>();
            this.correctFeedback = question.Correct_Feedback__c;
            this.incorrectFeedback = question.Incorrect_Feedback__c;
            this.includeInScoring = question.Include_In_Scoring__c;
            this.context = question.Context__c;

            //Text questions don't have an answer to work with since the learner types in the answer
            if(this.type == 'Text'){
                this.answers.add(new quizAnswer(new Quiz_Answer_Option__c()));
            }

            for(Quiz_Answer_Option__c answer : question.Quiz_Answer_Options__r){
                this.answers.add(new quizAnswer(answer));
            }
        }

        public quizQuestion(Quiz_Question_Response__c question){
            this.id = question.Id;
            this.quizQuestionId = question.Quiz_Question__c;
            this.questionText = question.Question_Text__c;
            this.type = question.Type__c;
            this.order = question.Order__c; 
            this.passed = question.Passed__c;
            this.totalCorrectAnswers = this.type == 'Scale' ? 1 : question.Number_Of_Answers__c;
            this.answers = new List<quizAnswer>();
            this.correctFeedback = question.Correct_Feedback__c;
            this.incorrectFeedback = question.Incorrect_Feedback__c;
            this.includeInScoring = question.Include_In_Scoring__c;
            this.context = question.Context__c;

            for(Quiz_Answer_Response__c answer : question.Quiz_Answer_Responses__r){
                this.answers.add(new quizAnswer(answer));
            }
        }
    }

    public class quizAnswer {
        @AuraEnabled public String id; //Answer Option or Answer Response
        @AuraEnabled public String answerOptionId;
        @AuraEnabled public String answerText;
        @AuraEnabled public String feedback;
        @AuraEnabled public String leftPair;
        @AuraEnabled public String rightPair;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public String selectedPair;
        @AuraEnabled public Decimal order;
        @AuraEnabled public Decimal pointValue;
        @AuraEnabled public List<String> statements;

        public quizAnswer(Quiz_Answer_Option__c answer){
            if(answer.Id == null){
                this.id = UUID.randomUUID().toString();
            } else {
                this.id = answer.Id;
            }

            this.answerOptionId = answer.Id;
            this.answerText = answer.Answer_Text__c;
            this.feedback = answer.Feedback__c;
            this.leftPair = answer.Matching_Left_Pair__c;
            this.rightPair = answer.Matching_Right_Pair__c;
            this.isSelected = false;
            this.selectedPair = '';
            this.order = answer.Order__c;
            this.pointValue = answer.Point_Value__c;

            if(answer.Statements__c != null){
                this.statements = answer.Statements__c.split('\\|');
            }
        }

        public quizAnswer(Quiz_Answer_Response__c answer){
            this.id = answer.Id;
            this.answerOptionId = answer.Quiz_Answer_Option__c;
            this.answerText = answer.Answer_Text__c;
            this.feedback = answer.Feedback__c;
            this.leftPair = answer.Matching_Left_Pair__c;
            this.rightPair = answer.Matching_Right_Pair__c;
            this.isSelected = answer.Selected__c;
            this.selectedPair = answer.Selected_Pair__c;
            this.pointValue = answer.Point_Value__c;
            this.order = answer.Order__c;

            if(answer.Statements__c != null){
                this.statements = answer.Statements__c.split('\\|');
            }
        }
    }
}