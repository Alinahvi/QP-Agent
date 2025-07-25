public with sharing class constantsNP {
    private static Organization org = [SELECT InstanceName , IsSandbox FROM Organization LIMIT 1];
    //private static Credentials__mdt credentials = [SELECT Trailhead_Api_Key__c, Client_Id_Prod__c, Client_Secret_Prod__c FROM Credentials__mdt LIMIT 1];
    public static FINAL String INSTANCE_NAME = org.InstanceName;
    public static FINAL Boolean IS_SANDBOX = org.IsSandbox;
    public static FINAL String BASE_URL = 'https://' + INSTANCE_NAME + '.salesforce.com';

    public static FINAL String NAMESPACE = String.valueOf(constantsNP.class).split('[.]').size() > 1 ? String.valueOf(constantsNP.class).split('[.]')[0] : 'c';
    public static FINAL String NAMESPACE_API = NAMESPACE == 'c' ? '' : NAMESPACE + '__';
    public static FINAL String SCHEDULER_NAME = 'Lighthouse Nightly Jobs';
    public static FINAL String TRAILHEAD_API_KEY = 'bf14e43fd5a9f8cf277f8c01f7469175';
    public static FINAL String BASE_TRAILHEAD_API = 'https://api.trailhead.salesforce.com';
    public static FINAL String TRAILHEAD_API_USER_SEARCH = BASE_TRAILHEAD_API + '/v1/search/users';
    public static FINAL String TRAILHEAD_API_USER_SEARCH_BY_ID = BASE_TRAILHEAD_API + '/v1/users/{0}';
    public static FINAL String TRAILHEAD_API_CURSOR = BASE_TRAILHEAD_API + '/v1/cursor/users';
    public static FINAL String TRAILHEAD_API_MODULES = BASE_TRAILHEAD_API + '/v1/modules';
    public static FINAL String TRAILHEAD_API_ASSIGNMENTS = BASE_TRAILHEAD_API + '/v1/assignments';
    public static FINAL String TRAILHEAD_API_MIXES_SEARCH = BASE_TRAILHEAD_API + '/v1/search/trailmixes';
    public static FINAL String CLIENT_ID = '3MVG9zlTNB8o8BA3vOrMgljZYh1GiKa.R19UfFyuzKXXSAdF3mfJrxmzjYTtOBhurIVd8iU08r68xAJhf3G3D';
    public static FINAL String CLIENT_SECRET = '8414810432560000824';

    public String ns {get { return NAMESPACE; }}

    public constantsNP() {

    }

    public constantsNP(ApexPages.StandardController std) {

    }
}