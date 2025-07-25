//Id batchJobId = Database.executeBatch(new g4gUserBatchTransformation('execute'), 10);
global class g4gUserBatchTransformation implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String ljAction;
    integer totalcount=0;
    boolean isComplete=false;
    String myMessage='';
    User baseUser;
    
    global g4gUserBatchTransformation(String action){
        //query the landing table
        String q;
        ljAction=action;
        if (ljAction=='validate'){
         q = 'Select id,employeeEmail__c ,name__c,mymanagerid__c,employeenumber__c,mgmtlevel1__c,mgmtlevel2__c,mgmtlevel3__c,mgmtlevel4__c,mgmtlevel5__c,mgmtlevel6__c,mgmtlevel7__c,mgmtlevel8__c,mgmtlevel9__c,mgmtlevel10__c,mgmtlevel11__c,mgmtlevel12__c  from g4gdata__c where complete__c !=true order by name__c '; 
        }
        if (ljAction=='execute'){
            q = 'Select id,employeeEmail__c ,name__c,mymanagerid__c,employeenumber__c,mgmtlevel1__c,mgmtlevel2__c,mgmtlevel3__c,mgmtlevel4__c,mgmtlevel5__c,mgmtlevel6__c,mgmtlevel7__c,mgmtlevel8__c,mgmtlevel9__c,mgmtlevel10__c,mgmtlevel11__c,mgmtlevel12__c  from g4gdata__c where complete__c =true and message__c != \'Passed Update\'  order by name__c '; 
        }
        Query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Query : ----------------------------- '+Query);
        System.debug('Action : ----------------------------- '+ljAction);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        System.debug('Records to Process: '+scope.size());
        Map<String,User>Usermap= new map<String,User>();
   
        for (sObject objScope: scope) {
            totalcount++;
            g4gdata__c g4gObjScope = (g4gdata__c)objScope ;
            try {  
                Usermap.clear();
                String empNumber = '';
				if (!BlankResult(g4gObjScope.employeenumber__c)) {
                    Usermap.put('employeenumber',getUserData(g4gObjScope.employeenumber__c,g4gObjScope.employeeEmail__c )); 
                }
                if (!BlankResult(g4gObjScope.mymanagerid__c)) {  
                    Usermap.put('mymanagerid',getUserData(g4gObjScope.mymanagerid__c,''));
                }
                if (!BlankResult(g4gObjScope.mgmtlevel1__c)) {  
                    // Usermap.put('mgmtlevel1',getUserData(g4gObjScope.mgmtlevel1__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel1__c);
					Usermap.put('mgmtlevel1',getUserData(empNumber,''));
                }
                 if (!BlankResult(g4gObjScope.mgmtlevel2__c)) {  
                    // Usermap.put('mgmtlevel2',getUserData(g4gObjScope.mgmtlevel2__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel2__c);
					Usermap.put('mgmtlevel2',getUserData(empNumber,''));
					
                }
                 if (!BlankResult(g4gObjScope.mgmtlevel3__c)) {  
                    // Usermap.put('mgmtlevel3',getUserData(g4gObjScope.mgmtlevel3__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel3__c);
					Usermap.put('mgmtlevel3',getUserData(empNumber,''));
                }
                 if (!BlankResult(g4gObjScope.mgmtlevel4__c)) {  
                    // Usermap.put('mgmtlevel4',getUserData(g4gObjScope.mgmtlevel4__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel4__c);
					Usermap.put('mgmtlevel4',getUserData(empNumber,''));
                }
                
                 if (!BlankResult(g4gObjScope.mgmtlevel5__c)) {  
                    // Usermap.put('mgmtlevel5',getUserData(g4gObjScope.mgmtlevel5__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel5__c);
					Usermap.put('mgmtlevel5',getUserData(empNumber,''));
                }
                 if (!BlankResult(g4gObjScope.mgmtlevel6__c)) {  
                    // Usermap.put('mgmtlevel6',getUserData(g4gObjScope.mgmtlevel6__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel6__c);
					Usermap.put('mgmtlevel6',getUserData(empNumber,''));
                }
                
                 if (!BlankResult(g4gObjScope.mgmtlevel7__c)) {  
                    // Usermap.put('mgmtlevel7',getUserData(g4gObjScope.mgmtlevel7__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel7__c);
					Usermap.put('mgmtlevel7',getUserData(empNumber,''));
                }
                  if (!BlankResult(g4gObjScope.mgmtlevel8__c)) {  
                    // Usermap.put('mgmtlevel8',getUserData(g4gObjScope.mgmtlevel8__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel8__c);
					Usermap.put('mgmtlevel8',getUserData(empNumber,''));
                }
                  if (!BlankResult(g4gObjScope.mgmtlevel9__c)) {  
                    // Usermap.put('mgmtlevel9',getUserData(g4gObjScope.mgmtlevel9__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel9__c);
					Usermap.put('mgmtlevel9',getUserData(empNumber,''));
                }
                 if (!BlankResult(g4gObjScope.mgmtlevel10__c)) {  
                    // Usermap.put('mgmtlevel10',getUserData(g4gObjScope.mgmtlevel10__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel10__c);
					Usermap.put('mgmtlevel10',getUserData(empNumber,''));
                }
                
                if (!BlankResult(g4gObjScope.mgmtlevel11__c)) {  
                    // Usermap.put('mgmtlevel11',getUserData(g4gObjScope.mgmtlevel11__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel11__c);
					Usermap.put('mgmtlevel11',getUserData(empNumber,''));
                }
                if (!BlankResult(g4gObjScope.mgmtlevel12__c)) {  
                    // Usermap.put('mgmtlevel12',getUserData(g4gObjScope.mgmtlevel12__c.substringBetween('(', ')'),''));
					empNumber = getEmpNumber(g4gObjScope.mgmtlevel12__c);
					Usermap.put('mgmtlevel12',getUserData(empNumber,''));
                }
              
              User targetOrgUser  = new User();
              User targetOrgUserClear  = new User();
              //evaluate what we have in the Usermap
              User mycurrentUser = CheckUserData(Usermap,'employeenumber');
                if (mycurrentUser==null){
                    //error condition
                    Updateg4gData(g4gObjScope, 'Error employee not found', false);
                    continue;
                }
                else{
                    //set to the correct employee
                    targetOrgUser.id=mycurrentUser.id;
                    targetOrgUserClear.id=mycurrentUser.id;
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_01_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_02_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_03_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_04_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_05_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_06_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_07_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_08_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_09_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_10_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_11_Nm__c='';
                    targetOrgUserClear.Emp_Mgt_Chain_Lvl_12_Nm__c='';
                    g4gObjScope.ReadinessUserId__c=mycurrentUser.id;
                }
                
                mycurrentUser = CheckUserData(Usermap,'mymanagerid');
                if (mycurrentUser==null){
                    //error condition
                    Updateg4gData(g4gObjScope, 'Error Manager not found', false);
                    continue;
                } 
                else{
                     targetOrgUser.managerid=mycurrentUser.id;
                     targetOrgUser.Manager_Email__c=mycurrentUser.email;
                }
               
              integer mapSize = Usermap.size();
              integer hierarchySize = Usermap.size()-2;
              integer hierarchySizeinProcess = 1;
              system.debug('Usermap size = '+mapSize);
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel1');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel1 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_01_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel1_Email__c=mycurrentUser.email; 
                        hierarchySizeinProcess++;
                    }
                }
                 if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel2');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel2 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_02_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel2_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }
              if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel3');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel3 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_03_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel3_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }  
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel4');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel4 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_04_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel4_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }  
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel5');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel5 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_05_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel5_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }  
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel6');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel6 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_06_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel6_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }  
              if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel7');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel7 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_07_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel7_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }  
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel8');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel8 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_08_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel8_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                } 
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel9');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel9 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_09_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel9_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                } 
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel10');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel10 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_10_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel10_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }   
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel11');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel11 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_11_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel11_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }   
                if (hierarchySizeinProcess <= hierarchySize){
                    mycurrentUser = CheckUserData(Usermap,'mgmtlevel12');
                    if (mycurrentUser==null){
                        //error condition
                        Updateg4gData(g4gObjScope, 'Error mgmtlevel12 not found', false);
                        continue;
                    } 
                    else{
                        targetOrgUser.Emp_Mgt_Chain_Lvl_12_Nm__c=mycurrentUser.email;
                        g4gObjScope.mgmtlevel12_Email__c=mycurrentUser.email;
                        hierarchySizeinProcess++;
                    }
                }   
              Updateg4gData(g4gObjScope, 'Passed Validation', true);
                if (ljAction=='validate'){
                    //System.debug('targetOrgUser--------------------------------------- : '+targetOrgUser);  
                }
              if (ljAction=='execute'){
                    System.debug('targetOrgUser--------------------------------------- : '+targetOrgUser);
                        try {
                   update targetOrgUserClear;
                   update targetOrgUser;
                   Updateg4gData(g4gObjScope, 'Passed Update', true);

                        }
                         catch(exception e){
                         System.debug('g4g fatal Error : '+e.getMessage());
                         Updateg4gData(g4gObjScope, e.getMessage(), false);
                }
              }
                
              //printMap(Usermap);
                
             
               
               }
            catch(exception e){
                System.debug('g4g fatal Error : '+e.getMessage());
               
            }
        }

    
    
  
}//end execute
    
      public void Updateg4gData(g4gdata__c myg4gdata, String mymessage, boolean mystatus) {
         
               myg4gdata.message__c=mymessage;
               myg4gdata.complete__c=mystatus;
               //System.debug('g4g Data Message:-------- '+mymessage);
               update myg4gdata;
    }
    public User CheckUserData(map<String,User> myg4gUser, String userType) {
        User currentUser = new User(); 
        currentUser = myg4gUser.get(userType);
        if (currentUser==null){
            return null;
        }
        return currentUser;  
    }
    
public boolean BlankResult(String dataValue) {
        return String.isBlank(dataValue);
    }    
    
	public String getEmpNumber(String temp) {
		// String temp = 'Jeffrey Huang (he/him) (724803)';
		Integer startIndex = temp.lastIndexOf('(', temp.length()) + 1;
		Integer endIndex = temp.length()-1;
		String val = temp.substring(startIndex, endIndex);
		// System.debug('String value ---- '+val);
		return val;
	}
	
public User getUserData(String myEmployeeNumber,String myEmployeeEmail ) {
    //system.debug('myemployeeNumber : '+myEmployeeNumber);
    //system.debug('myEmployeeEmail : '+myEmployeeEmail);
    List<User> myUser = [SELECT id,name,email FROM User WHERE EmployeeNumber = :myEmployeeNumber  and isactive=true];
    if (myUser.size()>0){
           return myUser[0];
        }
    	//invalid email check for sandbox , not needed into production
        if(!String.isEmpty(myEmployeeEmail)) {
            String newEmail = myEmployeeEmail.replace('mulesoft','salesforce');
            myUser = [SELECT id,name,email FROM User WHERE email = :newEmail  and isactive=true];
            if (myUser.size()>0){
               return myUser[0];
            }
        }
    	
       return null;
        
    }
public User buildUserData(map<String,User> myg4gUser, g4gdata__c myg4gdata ) {
        
        
       return null;  
    }
public void printMap(map<String,User> myUsers ) {
        for (String key:myUsers.keySet())
            {
                System.debug('Map Key is '+ key);
                System.debug('User data Found '+myUsers.get(key));
                
            }
      
        
    }
global void finish(Database.BatchableContext BC){
    
    System.debug('Total records processed ..................' +totalcount);
    //Database.executeBatch(new ProvisionLJBatch2('updateSTables'), 10);
}                 

}