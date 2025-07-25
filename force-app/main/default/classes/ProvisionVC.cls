public virtual class ProvisionVC {
    //Author Doug Glassman 9-6-2020 LevelJump ProvisionLJ
    //Author Doug Glassman 11-4-2022 Migrate to Appinium Video Coaching

    boolean Assign_PermissionSets=false;
    boolean isComplete=false;
    AutoProvisionLJ__c theAplj = new AutoProvisionLJ__c();
    String myMessage='';
    User baseUser;

    static String idPlayer_User='';
    static String idViewTrac_Lightning_UI_User ='';
    static String idVideo_Coaching_User='';
  
    public static final String[] PERMISSION_SETS = new String[] {
      'Player_User',
      'ViewTrac_Lightning_UI_User',
      'Video_Coaching_User'
      
    };
  


    public ProvisionVC() { }

    public ProvisionVC(User myUser) {
        //Just in time flow
       // Assign_LJ_License=assignLJlicense(myUser);
       // Assign_PermissionSets=assignPermSets(myUser);
       // Assign_Lurniture_Object=assignLJRoomObject(myUser);
    }
    public ProvisionVC(List<AutoProvisionLJ__c> listAutoProvisionLJ) {
        for (AutoProvisionLJ__c apEntry : listAutoProvisionLJ)  {
            try {
                baseUser = getUserData(apEntry.emailAddress__c);

                if (baseUser!=null){
                   // System.debug('baseUser : -----'+baseUser.Profile.Name);
                   
                    Assign_PermissionSets=assignPermSets(baseUser);
                   
                    theAplj = getAutoProvisionObject(Assign_PermissionSets,apEntry.emailAddress__c,true,'Valid Email');
                    theAplj.UserId__c=baseUser.id;
                    upsertAutoProvisionObject(theAplj);
                }
                else
                {
                 theAplj = getAutoProvisionObject(Assign_PermissionSets,apEntry.emailAddress__c,isComplete,'Error: User Not Found');
                 upsertAutoProvisionObject(theAplj);
                }

            }catch(exception e){
                System.debug('Error : '+e.getMessage());
                theAplj = getAutoProvisionObject(Assign_PermissionSets,apEntry.emailAddress__c,isComplete,'Error: '+e.getMessage());
                upsertAutoProvisionObject(theAplj);
            }
        }
    }


    public static boolean doesPermSetExist(String myUser,String permId) {
        List<PermissionSetAssignment> myPerms = [select Id from PermissionSetAssignment  where AssigneeId =:myUser and PermissionSetId =:permId];
        if (myPerms.size()>0){
           // System.debug('Permset found .. user'+ myUser+' permid '+permId);
            return true;
        }
        else
        {
           // System.debug('Permset not found .. user'+myUser+' permid '+permId);
            return false;
        }
    }

    private static void upsertPermSets(String myUser,String myProfileName)
    {
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        idPlayer_User  = getPermissionSetId('Player_User');
        idViewTrac_Lightning_UI_User =  getPermissionSetId('ViewTrac_Lightning_UI_User');
        idVideo_Coaching_User = getPermissionSetId('Stand_Deliver_User');

        PermissionSetAssignment psa;

            if(!doesPermSetExist(myUser, idPlayer_User)){
                psa = new PermissionSetAssignment (PermissionSetId = idPlayer_User, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if(!doesPermSetExist(myUser, idViewTrac_Lightning_UI_User)){
                psa = new PermissionSetAssignment (PermissionSetId = idViewTrac_Lightning_UI_User, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if(!doesPermSetExist(myUser, idVideo_Coaching_User)){
                psa = new PermissionSetAssignment (PermissionSetId = idVideo_Coaching_User, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            System.debug('Perms to assign: '+permissionSetList.size());
            if (permissionSetList.size()>0){
                
                upsert permissionSetList;
            }

    
        return ;
    }

    public boolean assignPermSets(User myUser) {
        upsertPermSets(myUser.Id,myUser.Profile.Name);
        return true;
    }

    public User getUserData(String myUserEmail) {

        List<User> myUser = [SELECT name,email, Id, Profile.Name, ProfileId FROM User WHERE email = :myUserEmail and isactive=true];
        if (myUser.size()>0){
           return myUser[0];
        }
        List<User> myUser2 = [SELECT name,email, Id, Profile.Name, ProfileId FROM User WHERE username = :myUserEmail and isactive=true];
        if (myUser2.size()>0){
           return myUser2[0];
        }

       return null;

    }
     public static String getPermissionSetId(String PermissionName) {

        List<PermissionSet> myPermissionSet = [SELECT Id FROM PermissionSet WHERE name=:PermissionName];
        //System.debug('PermissionSet to assign: '+myPermissionSet + ' Name '+PermissionName);
         if (myPermissionSet.size()>0){
            
           return myPermissionSet[0].id;
        }
       return null;

    }
    public AutoProvisionLJ__c getProvisionData(String myUserEmail) {
        AutoProvisionLJ__c myAP = [SELECT  Id FROM AutoProvisionLJ__c WHERE emailAddress__c = :myUserEmail];
        return myAP ;
    }

    public static void upsertAutoProvisionObject(AutoProvisionLJ__c myAplj) {
        upsert myAplj myAplj.emailAddress__c;
        return;
    }

  public  static AutoProvisionLJ__c getAutoProvisionObject(boolean myAssign_PermissionSets,String myEmailAddress,boolean myisComplete,String myMessage) 
  {
        AutoProvisionLJ__c  Aplj = new AutoProvisionLJ__c();
      
        Aplj.Assign_PermissionSets__c=myAssign_PermissionSets;
        Aplj.emailAddress__c=myEmailAddress;
        Aplj.Complete__c=myisComplete;
        Aplj.message__c=mymessage;

        return Aplj;
    }
    public  boolean checkPermSets(User user)
    {
        idPlayer_User  = getPermissionSetId('Player_User');
        idViewTrac_Lightning_UI_User =  getPermissionSetId('ViewTrac_Lightning_UI_User');
        idVideo_Coaching_User = getPermissionSetId('Stand_Deliver_User');
        
        if (doesPermSetExist(user.id, idPlayer_User)
            && doesPermSetExist(user.id, idViewTrac_Lightning_UI_User)
            && doesPermSetExist(user.id, idVideo_Coaching_User)) {
                return true;
            }else
                return false;
    }
    
}