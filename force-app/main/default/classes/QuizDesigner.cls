public with sharing class QuizDesigner {

    @AuraEnabled
    public static ResponseData getData(Id recordId){
        ResponseData rd = new ResponseData();
        
        try {
            String soqlString = 'SELECT ' + String.join(questionFields(), ', ') + 
                                    ', (SELECT ' + String.join(answerFields(), ', ') +
                                    ' FROM Quiz_Answer_Options__r' +
                                    ' ORDER BY Order__c ASC)' +
                                ' FROM Quiz_Question__c ' +
                                ' WHERE Asset__c = :recordId' +
                                ' ORDER BY Order__c ASC';
            List<Quiz_Question__c> questions = Database.query(soqlString);

            rd.put('questions', questions);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    private static List<String> questionFields(){
        return new List<String>(new Set<String>{
            'Id', 'Question_Text__c', 'Order__c', 'Type__c', 'Correct_Feedback__c', 'Incorrect_Feedback__c', 'Include_In_Scoring__c', 'Context__c'
        });
    }

    private static List<String> answerFields(){
        return new List<String>(new Set<String>{
            'Id', 'Answer_Text__c', 'Is_Correct__c', 'Order__c', 'Feedback__c', 'Matching_Left_Pair__c', 'Matching_Right_Pair__c', 'Statements__c',
            'Point_Value__c'
        });
    }

    @AuraEnabled
    public static ResponseData saveQuestionOrder(List<String> questionIds){
        ResponseData rd = new ResponseData();
        
        try {
            List<Quiz_Question__c> questions = new List<Quiz_Question__c>();

            for(Integer i = 0; i < questionIds.size(); i++){
                Quiz_Question__c question = new Quiz_Question__c(Id = questionIds[i], Order__c = i + 1);
                questions.add(question);
            }

            update as user questions;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData saveQuestion(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Quiz_Question__c question = (Quiz_Question__c)utilities.getSobjectByMap((Map<String, Object>)parsedRes.get('question'), 'Quiz_Question__c');
            List<Object> answerObjs = (List<Object>)parsedRes.get('answers');
            List<Quiz_Answer_Option__c> answers = new List<Quiz_Answer_Option__c>();
            List<Object> deletedAnswerIdObjs = (List<Object>)parsedRes.get('deletedAnswerIds');

            upsert question;

            for(Integer i = 0; i < answerObjs.size(); i++){
                Object obj = answerObjs[i];
                Quiz_Answer_Option__c answer = (Quiz_Answer_Option__c)utilities.getSobjectByMap((Map<String, Object>)obj, 'Quiz_Answer_Option__c');
                
                if(answer.Quiz_Question__c == null){
                    answer.Quiz_Question__c = question.Id;
                }

                answer.Order__c = i + 1;
                
                //If its boolean its already set on the front end
                if(question.Type__c != 'True/False'){
                    answer.Point_Value__c = i + 1;
                }

                answers.add(answer);
            }

            upsert answers;

            if(deletedAnswerIdObjs != null && !deletedAnswerIdObjs.isEmpty()){
                List<String> deletedAnswerIds = new List<String>();

                for(Object obj : deletedAnswerIdObjs){
                    deletedAnswerIds.add((String)obj);
                }

                delete [SELECT Id FROM Quiz_Answer_Option__c WHERE Id IN :deletedAnswerIds];
            }
            
            //requery to get data for front end
            String questionId = question.Id;
            String soqlString = 'SELECT ' + String.join(questionFields(), ', ') + 
                                    ', (SELECT ' + String.join(answerFields(), ', ') +
                                    ' FROM Quiz_Answer_Options__r' +
                                    ' ORDER BY Order__c ASC)' +
                                ' FROM Quiz_Question__c ' +
                                ' WHERE Id = :questionId' +
                                ' ORDER BY Order__c ASC';

            Quiz_Question__c dbQuestion = Database.query(soqlString);

            rd.put('question', dbQuestion);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData allowedEditor(Id recordId) {
        ResponseData rd = new ResponseData();
        try{
            rd.put('allowedEditor', false);
            for(Asset__c asset : [SELECT Id, Allowed_Editor__c FROM Asset__c where Id = :recordId WITH USER_MODE LIMIT 1]) {
                rd.put('allowedEditor', asset.Allowed_Editor__c);
            }
                    
        }catch(Exception e){
            rd.addError(e);
        }        
        return rd;
    }
}