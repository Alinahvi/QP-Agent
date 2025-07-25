public class UserTreeGridClass {
    @AuraEnabled
    //Select manager_level__c,Id, Name,(Select Id,Name From ManagedUsers) From User  where  Emp_Mgt_Chain_Lvl_04_Nm__c = 'ddresser@salesforce.com' and people_manager__c=true and has_direct_reports__c=true order by manager_level__c limit 2
      public static list<learningprogram__c> getLearningTreeByFilter(String myprogram, String mytype){
         String fullQuery;
          
         List<learningprogram__c > learning = new List<learningprogram__c >();
          
          if (mytype.equals('All')){
              mytype='%';
          }
          if (myprogram.equals('All')){
              myprogram='%';
          }
           fullQuery = 'select id,name , timeframe__c ,learning_event__c,(select learningtypeformula__c ,nameformula__c,ACT_Course__c ,ACT_Curriculum__c , id,name__c,description__c,LearningReqFormula__c,required__c from LearningCores__r  where  learningtypeformula__c like \'' + mytype + '\' order by sort_order__c asc) from learningprogram__c where isActive__c = true and name like \'' + myprogram + '\' order by sort_order__c asc ' ;
           system.debug('fullQuery====================='+fullQuery);
           learning = database.Query(fullQuery);
        
         system.debug('learning====================='+learning);

         if (learning.size() == 0){
             
                return null;
              
             }
        return learning;
    }
    @AuraEnabled
    //Select manager_level__c,Id, Name,(Select Id,Name From ManagedUsers) From User  where  Emp_Mgt_Chain_Lvl_04_Nm__c = 'ddresser@salesforce.com' and people_manager__c=true and has_direct_reports__c=true order by manager_level__c limit 2
      public static list<learningprogram__c> getLearningTree(){
         String fullQuery;
         List<learningprogram__c > learning = new List<learningprogram__c >();
           //system.debug('Uname====================='+uname);
           fullQuery = 'select id,name , timeframe__c ,learning_event__c, (select learningtypeformula__c ,nameformula__c,ACT_Course__c ,ACT_Curriculum__c , id,name__c,description__c,LearningReqFormula__c,required__c from LearningCores__r order by sort_order__c asc) from learningprogram__c where isActive__c = true order by sort_order__c asc ' ;
           system.debug('fullQuery====================='+fullQuery);
           learning = database.Query(fullQuery);
        
         system.debug('learning====================='+learning);

         if (learning.size() == 0){
             
                return null;
              
             }
        return learning;
    }
     @AuraEnabled
    //Select manager_level__c,Id, Name,(Select Id,Name From ManagedUsers) From User  where  Emp_Mgt_Chain_Lvl_04_Nm__c = 'ddresser@salesforce.com' and people_manager__c=true and has_direct_reports__c=true order by manager_level__c limit 2
      public static list<learningprogram__c> getLearningProgram(){
         String fullQuery;
         List<learningprogram__c > learning = new List<learningprogram__c >();
           //system.debug('Uname====================='+uname);
           fullQuery = 'select id,name , timeframe__c ,learning_event__c from learningprogram__c where isActive__c = true order by sort_order__c asc ' ;
           system.debug('fullQuery====================='+fullQuery);
           learning = database.Query(fullQuery);
        
         system.debug('learning====================='+learning);

         if (learning.size() == 0){
             
                return null;
              
             }
        return learning;
    }

    @AuraEnabled
    public static list<user> getUserTree(String uname , boolean directReports){
        
        String fullQuery;
         List<User> oUser = new List<User>();
         system.debug('Uname====================='+uname);
         
         String chainquery = getUserQueryString( uname );
         if (directReports){
             fullQuery = 'Select Job_Family__c ,uniqueid__c,username, manager_level__c,Id, Name,(Select Job_Family__c , id,username,Name From ManagedUsers) FROM User Where  username = \'' + uname + '\' order by manager_level__c ' ;
           system.debug('fullQuery====================='+fullQuery);
           oUser = database.Query(fullQuery);
         }
         else
         {
           fullQuery = 'Select Job_Family__c ,uniqueid__c, username, manager_level__c,Id, Name,(Select  Job_Family__c ,id,username,Name From ManagedUsers) FROM User Where  ' +chainquery+' and people_manager__c=true and has_direct_reports__c=true order by manager_level__c ' ;
           system.debug('fullQuery====================='+fullQuery);
           oUser = database.Query(fullQuery); 
         }
         system.debug('User====================='+oUser);

         if (oUser.size() == 0){
             //try again for Managers whose direct reports are not managers
             fullQuery = 'Select Job_Family__c ,uniqueid__c, username, manager_level__c,Id, Name,(Select Job_Family__c , id,username,Name From ManagedUsers) FROM User Where  username = \'' + uname + '\' order by manager_level__c ' ;
             system.debug('fullQuery Direct reports====================='+fullQuery);
             oUser = database.Query(fullQuery);
              if (oUser.size() == 0){
                return null;
              }
             }
        return oUser;
    }
     @AuraEnabled
     public static String getUserQueryString(String uname ){
        
         String qstring = '';
        
         List<User> oUser  = [select manager_level__c,email FROM User Where username =: uname];
         
         if (String.isBlank(oUser[0].manager_level__c)){
             qstring = qstring +' username = \'' + uname + '\'';
             return qstring;
         }
         
         if (oUser[0].manager_level__c.contains('1')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_01_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
         else if (oUser[0].manager_level__c.contains('2')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_02_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('3')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_03_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('4')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_04_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('5')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_05_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
       else  if (oUser[0].manager_level__c.contains('6')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_06_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('7')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_07_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
       else  if (oUser[0].manager_level__c.contains('8')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_08_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('9')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_09_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
          else if (oUser[0].manager_level__c.contains('10')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_10_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
             System.debug(' Qstring -----------------------------------------------: '+qstring);
        
         //count = database.countQuery(qstring);

        return qstring;
    }
    @AuraEnabled
     public static integer getHierarchyCount(String uname ){
         //mystr = 'SELECT payout__Account_Desc__c FROM payout__ImportStaging__c where payout__BD_Id__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\' AND payout__Processed_Flag__c <> \'' + String.escapeSingleQuotes('Y') + '\'');
         
         //Emp_Mgt_Chain_Lvl_04_Nm__c 
         String qstring = 'select count() from user where ';
         integer  count=0;
       
         List<User> oUser  = [select manager_level__c,id,Name,email,em_Business_Line_L1__c,em_Industry__c,em_Operating_Unit__c,em_Product_Line_L2__c,em_Role__c,em_Segment__c,em_Sub_Vertical__c
                 FROM User Where username =: uname];
         
         if (oUser[0].manager_level__c.contains('2')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_02_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('3')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_03_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('4')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_04_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('5')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_05_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
       else  if (oUser[0].manager_level__c.contains('6')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_06_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('7')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_07_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
       else  if (oUser[0].manager_level__c.contains('8')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_08_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        else if (oUser[0].manager_level__c.contains('9')){
             qstring = qstring +' Emp_Mgt_Chain_Lvl_09_Nm__c = \'' + String.escapeSingleQuotes(oUser[0].email.replace('.invalid','')) + '\'';
         }
        System.debug(' Qstring -----------------------------------------------: '+qstring);
        count = database.countQuery(qstring+' and Isactive=true ');

        return count;
    }
       @AuraEnabled
     public static List < String > getselectOptions(sObject objObject, string fld) {
  system.debug('objObject --->' + objObject);
  system.debug('fld --->' + fld);
  List < String > allOpts = new list < String > ();
  // Get the object type of the SObject.
  Schema.sObjectType objType = objObject.getSObjectType();
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
 
  // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
  // Get the list of picklist values for this field.
  list < Schema.PicklistEntry > values =
   fieldMap.get(fld).getDescribe().getPickListValues();
 
  // Add these values to the selectoption list.
  for (Schema.PicklistEntry a: values) {
   allOpts.add(a.getValue());
  }
  system.debug('allOpts ---->' + allOpts);
  allOpts.sort();
  return allOpts;
 }
   @AuraEnabled 
   public static String runHierarchyUpdate(String uname){
        try {
        //system.debug('Bulk User Size-->' + usr.size());
        //update usr;
        list<user> myBaseUser = getUser( uname );
        String myquery = getUserQueryString( uname );
        system.debug('getUserQueryString MyQuery -->' +myquery);
        list<user> myUserHierarchy = database.Query(myquery);
            list<user> myUserUpdates = new list<user>();
            system.debug('runHierarchyUpdate  size -->     ' + myUserHierarchy.size());
            for(User u : myUserHierarchy){
                u.em_Business_Line_L1__c = myBaseUser[0].em_Business_Line_L1__c;
                u.em_Role__c = myBaseUser[0].em_Role__c;
                u.em_Product_Line_L2__c = myBaseUser[0].em_Product_Line_L2__c;
                u.em_Segment__c = myBaseUser[0].em_Segment__c;
                u.em_Industry__c = myBaseUser[0].em_Industry__c;
                u.em_Sub_Vertical__c = myBaseUser[0].em_Sub_Vertical__c;
                u.em_Operating_Unit__c = myBaseUser[0].em_Operating_Unit__c;
                myUserUpdates.add(u);
            }
          update myUserUpdates;
          return 'Success';
        } catch(Exception e) {
             System.debug('runHierarchyUpdate The following exception has occurred: ' + e.getMessage());
            return null;
           }
    }
   @AuraEnabled 
   public static String updateBulkUser(List<User> usr){
        try {
        system.debug('Bulk User Size-->' + usr.size());
        update usr;
        return 'Success';
        } catch(Exception e) {
            System.debug('updateUser The following exception has occurred: ' + e.getMessage());
            throw e;
           }
    }
    @AuraEnabled 
    public static user updateUser(User usr){
        try {
        system.debug('user-->' + usr);
        update usr;
        return usr;
        } catch(Exception e) {
             System.debug('updateUser The following exception has occurred: ' + e.getMessage());
            return null;
           }
    }
    @AuraEnabled
     public static list<user> getUser(String uname ){
         system.debug('Uname====================='+uname);
         List<User> oUser  = [select ManagerId,manager_level__c,id,Name,email,em_Business_Line_L1__c,em_Industry__c,em_Operating_Unit__c,em_Product_Line_L2__c,em_Role__c,em_Segment__c,em_Sub_Vertical__c
                 FROM User Where username =: uname];
          system.debug('User====================='+oUser);
         if (oUser.size() == 0){
             return null;
             }
        return oUser;
    }
   @AuraEnabled
     public static String getMyObjectType(String myOid){
         //String recordId = 'a1G2E00000IHuRLUA1';
         try {
         Id myId = Id.valueOf(myOid);
         String objectDef = myId.getSObjectType().getDescribe().getName();
         return objectDef;
          } catch(Exception e) {
             System.debug('Getdescribe for Id: ' + myOid+ ' ' +e.getMessage());
            return null;
           }
    }
}