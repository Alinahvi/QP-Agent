public virtual class ProvisionLJ {
    //Author Doug Glassman 9-6-2020
    boolean Assign_LJ_License=false;
    boolean Assign_Lurniture_Object=false;
    boolean Assign_PermissionSets=false;
    boolean isComplete=false;
    AutoProvisionLJ__c theAplj = new AutoProvisionLJ__c();
    String myMessage='';
    User baseUser;
    static String idActLearner='';
    static String idActDesigner ='';
    static String idlurnitureManager='';
    static String idlurnitureUser='';

    public static final String PACKAGE_LICENSE_ID = '0502E000000kFCxQAM';
    public static final String[] PERMISSION_SETS = new String[] {
      'ACT_Learners_Permission_for_Stand_and_Deliver',
      'ACT_Designers_Permission_for_Stand_and_Deliver',
      'Permission_Set_for_Manager',
      'Lurniture_App_User'
    };
    public static final String[] PROFILE_NAMES = new String[]{
      'Basecamp User',
      'Enablement Design User',
      'System Administrator',
      'System Administrator (APEX & Activate)'
    };
    public final Set<Id> USER_IDS = new Set<Id>();

    public ProvisionLJ() { }

    public ProvisionLJ(User myUser) {
        //Just in time flow
        Assign_LJ_License=assignLJlicense(myUser);
        Assign_PermissionSets=assignPermSets(myUser);
        Assign_Lurniture_Object=assignLJRoomObject(myUser);
    }
    public ProvisionLJ(List<AutoProvisionLJ__c> listAutoProvisionLJ) {
        for (AutoProvisionLJ__c apEntry : listAutoProvisionLJ)  {
            try {
                baseUser = getUserData(apEntry.emailAddress__c);

                if (baseUser!=null){
                    //System.debug('baseUser : '+baseUser.Profile.Name);
                    Assign_LJ_License=assignLJlicense(baseUser);
                    Assign_PermissionSets=assignPermSets(baseUser);
                    Assign_Lurniture_Object=assignLJRoomObject(baseUser);
                    theAplj = getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,apEntry.emailAddress__c,true,'Valid Email');
                    theAplj.UserId__c=baseUser.id;
                    upsertAutoProvisionObject(theAplj);
                }
                else
                {
                 theAplj = getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,apEntry.emailAddress__c,isComplete,'Error: User Not Found');
                 upsertAutoProvisionObject(theAplj);
                }

            }catch(exception e){
                System.debug('Error : '+e.getMessage());
                theAplj = getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,apEntry.emailAddress__c,isComplete,'Error: '+e.getMessage());
                upsertAutoProvisionObject(theAplj);
            }
        }
    }
       public boolean assignLJRoomObject(User myUser) {

        List<LRN__Lurniture_User__c> myLurnitureUser = [select Id from LRN__Lurniture_User__c where LRN__User__c=:myUser.id];
        if (myLurnitureUser.size()>0){
            return true;
        }
         LRN__Lurniture_User__c lurnUser = new LRN__Lurniture_User__c();


        if (myUser.Profile.Name=='Basecamp User'){
            lurnUser.LRN__Active__c=TRUE;
            lurnUser.LRN__Can_Assign_Video__c=FALSE;
            lurnUser.LRN__Can_Publish_Video__c=FALSE;
            lurnUser.LRN__Can_Create_Tags__c=FALSE;
            lurnUser.LRN__Can_Create_Rooms__c=FALSE;
            lurnUser.LRN__Disable_Public_Playlist_Creation__c=TRUE;
            lurnUser.LRN__User__c =myUser.Id;
            insert lurnUser;
            return true;
        }
        if (myUser.Profile.Name=='Enablement Design User'){
            lurnUser.LRN__Active__c=TRUE;
            lurnUser.LRN__Disable_Public_Playlist_Creation__c=TRUE;
            lurnUser.LRN__Can_Create_Rooms__c=TRUE;
            lurnUser.LRN__Can_Assign_Video__c=FALSE;
            lurnUser.LRN__Can_Publish_Video__c=FALSE;
            lurnUser.LRN__Can_Create_Tags__c=FALSE;
            lurnUser.LRN__User__c =myUser.Id;
            insert lurnUser;
            return true;
        }
        if (myUser.Profile.Name.containsIgnoreCase('System Administrator')){
            lurnUser.LRN__Active__c=TRUE;
            lurnUser.LRN__Disable_Public_Playlist_Creation__c=TRUE;
            lurnUser.LRN__Can_Create_Rooms__c=TRUE;
            lurnUser.LRN__User__c =myUser.Id;
            insert lurnUser;
            return true;
        }
        return false;
    }


    private static void InsertLicense(String myUser)
    {
        try{
            UserPackageLicense lrnUserLicense = new UserPackageLicense();
            lrnUserLicense.PackageLicenseId = '0502E000000kFCxQAM';
            lrnUserLicense.UserId = myUser;
            Insert lrnUserLicense;
        }catch(exception e){
            System.debug('License Error ============================: '+e.getMessage());
           // upsert Aplj myAplj.emailAddress__c; will give mixed dml error
        }
    }

   public boolean doesLicenseExist(User myUser) {
        List<UserPackageLicense> mylicenses = [select Id from UserPackageLicense where PackageLicenseId = '0502E000000kFCxQAM' and UserId=:myUser.id];
        if (mylicenses.size()>0){
            return true;
        }
       else
       {
        return false;
       }
    }

    public boolean assignLJlicense(User myUser) {
        if (doesLicenseExist(myUser))
        {
            return true;
        }
        else{
            InsertLicense(String.valueof(myUser.id));
        }

        return true;
    }

     public static boolean doesPermSetExist(String myUser,String permId) {
        List<PermissionSetAssignment> myPerms = [select Id from PermissionSetAssignment  where AssigneeId =:myUser and PermissionSetId =:permId];
        if (myPerms.size()>0){
            return true;
        }
       else
       {
        return false;
       }
    }


    private static void upsertPermSets(String myUser,String myProfileName)
    {
        //ACT_Learners_Permission_for_Stand_and_Deliver
        //ACT_Designers_Permission_for_Stand_and_Deliver
        //Permission_Set_for_Manager =Lurniture App Manager
        //Lurniture_App_User =Lurniture App User
        //
        //Profile - Base Camp User, Enablement Design User  System*
        //

        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        idActLearner  = getPermissionSetId('ACT_Learners_Permission_for_Stand_and_Deliver');
        idActDesigner =  getPermissionSetId('ACT_Designers_Permission_for_Stand_and_Deliver');
        idlurnitureManager = getPermissionSetId('Permission_Set_for_Manager');
        idlurnitureUser = getPermissionSetId('Lurniture_App_User');
        PermissionSetAssignment psa;

        if (myProfileName=='Basecamp User') {

            if(!doesPermSetExist(myUser,idActLearner)){
                psa = new PermissionSetAssignment (PermissionSetId = idActLearner, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if(!doesPermSetExist(myUser,idlurnitureUser)){
                psa = new PermissionSetAssignment (PermissionSetId = idlurnitureUser, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if (permissionSetList.size()>0){
                upsert permissionSetList;
            }



        } else if (myProfileName=='Enablement Design User') {


            if(!doesPermSetExist(myUser,idActDesigner)){
                psa = new PermissionSetAssignment (PermissionSetId = idActDesigner, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if(!doesPermSetExist(myUser,idlurnitureUser)){
                psa = new PermissionSetAssignment (PermissionSetId = idlurnitureUser, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if (permissionSetList.size()>0){
                upsert permissionSetList;
            }

        } else if ((myProfileName=='System Administrator') || myProfileName=='System Administrator (APEX & Activate)'){

            if(!doesPermSetExist(myUser,idActDesigner)){
                psa = new PermissionSetAssignment (PermissionSetId = idActDesigner, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if(!doesPermSetExist(myUser,idlurnitureUser)){
                psa = new PermissionSetAssignment (PermissionSetId = idlurnitureUser, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
             if(!doesPermSetExist(myUser,idlurnitureManager)){
                psa = new PermissionSetAssignment (PermissionSetId = idlurnitureManager, AssigneeId = myUser);
                permissionSetList.add(psa);
            }
            if (permissionSetList.size()>0){
                upsert permissionSetList;
            }


        } else {
        return ;
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
        if (myPermissionSet.size()>0){
           return myPermissionSet[0].id;
        }
       return null;

    }
    public AutoProvisionLJ__c getProvisionData(String myUserEmail) {
        AutoProvisionLJ__c myAP = [SELECT  Id FROM AutoProvisionLJ__c WHERE emailAddress__c = :myUserEmail];
        return myAP ;
    }

    public  void upsertAutoProvisionObject(AutoProvisionLJ__c myAplj) {
        upsert myAplj myAplj.emailAddress__c;
        return;
    }

  public  AutoProvisionLJ__c getAutoProvisionObject(boolean myAssign_LJ_License,boolean myAssign_Lurniture_Object,boolean myAssign_PermissionSets,String myEmailAddress,boolean myisComplete,String myMessage) {
        AutoProvisionLJ__c  Aplj = new AutoProvisionLJ__c();
        Aplj.Assign_LJ_License__c=myAssign_LJ_License;
        Aplj.Assign_Lurniture_Object__c=myAssign_Lurniture_Object;
        Aplj.Assign_PermissionSets__c=myAssign_PermissionSets;
        Aplj.emailAddress__c=myEmailAddress;
        Aplj.Complete__c=myisComplete;
        Aplj.message__c=mymessage;

        return Aplj;
    }
  public  boolean checkPermSets(User user)
  {
    idActLearner  = getPermissionSetId('ACT_Learners_Permission_for_Stand_and_Deliver');
    idActDesigner =  getPermissionSetId('ACT_Designers_Permission_for_Stand_and_Deliver');
    idlurnitureManager = getPermissionSetId('Permission_Set_for_Manager');
    idlurnitureUser = getPermissionSetId('Lurniture_App_User');


    if (user.Profile.Name == 'Basecamp User') {

      if (doesPermSetExist(user.id, idlurnitureUser)
        && doesPermSetExist(user.id, idActLearner)) {
        return true;
      }
    } else if (user.Profile.Name == 'Enablement Design User') {
      if (doesPermSetExist(user.id, idlurnitureUser) &&
          doesPermSetExist(user.id, idActDesigner)) {
        return true;
      }
    } else if (user.Profile.Name == 'System Administrator' || user.Profile.Name=='System Administrator (APEX & Activate)') {

      if (doesPermSetExist(user.id, idlurnitureUser) &&
          doesPermSetExist(user.id, idActDesigner) &&
          doesPermSetExist(user.id, idlurnitureManager)) {
        return true;
      }
    }

    return false;
  }

}