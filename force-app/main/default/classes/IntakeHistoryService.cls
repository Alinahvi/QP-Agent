public with sharing class IntakeHistoryService {
    public static void CreateIntakeHistory (ID IntakeID) {
        ENB_Intake__c Intake = [SELECT ID, Date_of_Most_Recent_New_Status__c, Initial_Intake_Request__c, Owner.Name, Decision_Reason__c, Intake_Status__c, Intake_Stage__c, LastModifiedBy.FirstName, LastModifiedBy.LastName, Intake_Channel__c FROM ENB_Intake__c WHERE Id = :IntakeID];
        //System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  ' + Intake.Intake_Channel__c + Intake.Owner.Name);
        
        Intake_Decision_History__c History = new Intake_Decision_History__c (
        	Intake__c = Intake.Id,
            Initial_Intake_Request__c = Intake.Initial_Intake_Request__c,
            Intake_Status__c = Intake.Intake_Status__c,
            Intake_Stage__c = Intake.Intake_Stage__c,
            Change_Made_By__c = (Intake.LastModifiedBy.FirstName + ' ' + Intake.LastModifiedBy.LastName),
            New_Intake_Channel__c = (STRING)Intake.Intake_Channel__c,
            Decision_Reason__c = Intake.Decision_Reason__c
        );
        Intake.Decision_Reason__c = '';
        if(Intake.Intake_Status__c == 'New'){
            Intake.Date_of_Most_Recent_New_Status__c = date.today();
        }
    	try{
        	Upsert History;
            Upsert Intake;
        }catch(DmlException de){
            System.debug(de);
        }
    }

    public static void CreateIntakeHistoryWithDayCount (ID IntakeID) {
        ENB_Intake__c Intake = [SELECT ID, Date_of_Most_Recent_New_Status__c, Initial_Intake_Request__c, Owner.Name, Decision_Reason__c, Intake_Status__c, Intake_Stage__c, LastModifiedBy.FirstName, CreatedDate, LastModifiedBy.LastName, Intake_Channel__c FROM ENB_Intake__c WHERE Id = :IntakeID];
        //System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  ' + Intake.Intake_Channel__c + Intake.Owner.Name);
        if(Intake.Date_of_Most_Recent_New_Status__c == null){
            //Intake.Date_of_Most_Recent_New_Status__c = date.today();
            Intake.Date_of_Most_Recent_New_Status__c = Intake.CreatedDate.date();

        }
        Intake_Decision_History__c History = new Intake_Decision_History__c (
        	Intake__c = Intake.Id,
            Initial_Intake_Request__c = Intake.Initial_Intake_Request__c,
            Intake_Status__c = Intake.Intake_Status__c,
            Intake_Stage__c = Intake.Intake_Stage__c,
            Change_Made_By__c = (Intake.LastModifiedBy.FirstName + ' ' + Intake.LastModifiedBy.LastName),
            New_Intake_Channel__c = (STRING)Intake.Intake_Channel__c,
            Decision_Reason__c = Intake.Decision_Reason__c,
            Time_to_Decision_Days__c = Intake.Date_of_Most_Recent_New_Status__c.daysBetween(date.today())
        );
        Intake.Decision_Reason__c = '';
    	try{
        	Upsert History;
            Upsert Intake;
        }catch(DmlException de){
            System.debug(de);
        }
    }
}