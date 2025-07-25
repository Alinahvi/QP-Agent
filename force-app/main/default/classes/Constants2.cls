public with sharing class Constants2 { 
    private static Organization org = [SELECT Id, InstanceName, IsSandbox, TimeZoneSidKey FROM Organization LIMIT 1];
    private static Credentials__mdt credentials = [SELECT Zoom_Dev_Admin_Client_Id__c, Zoom_Dev_Admin_Client_Secret__c, Zoom_Prod_Admin_Client_Id__c, 
                                                          Zoom_Prod_Admin_Client_Secret__c,
                                                          Zoom_Dev_Account_Id__c, Zoom_Prod_Account_Id__c, Zoom_Dev_Validation_Token__c, Zoom_Prod_Validation_Token__c,
                                                          Heroku_Api_Key__c, Heroku_Api_Uat_Key__c, Heroku_Api_Prod_Key__c, Bitly_Api_Token__c, Bitly_Group_Guid__c
                                                    FROM Credentials__mdt LIMIT 1];
    // private static Auth_Setting__c authSetting = Auth_Setting__c.getOrgDefaults();

    public static FINAL String ORG_ID = org.Id;
    public static FINAL String INSTANCE_NAME = org.InstanceName;
    public static FINAL String ORG_TIMEZONE = org.TimeZoneSidKey;
    public static FINAL Boolean IS_SANDBOX = org.IsSandbox;
    public static final String STATUS_SUCCESS           = 'SUCCESS';
    public static final String STATUS_ERROR             = 'ERROR';
    public static final String STATUS_ACCESS_DENIED     = 'ACCESS_DENIED';
    public static final String AUDIENCE_ID_INTERNAL    = 'internal';
    public static final String GET_PLAYBACK_LINK_PARAM = 'GetPlaybackURL';
    public static final String OBJECT_API_NAME_MEDIA   = 'scormanywhere__Course__c';

    //SF OAUTH
    public static FINAL String CLIENT_ID = '3MVG9zlTNB8o8BA3vOrMgljZYh1GiKa.R19UfFyuzKXXSAdF3mfJrxmzjYTtOBhurIVd8iU08r68xAJhf3G3D';
    public static FINAL String CLIENT_SECRET = '8414810432560000824';
    // public static FINAL String PUBLIC_SITE_REDIRECT_URL = 'https://actprodpack-developer-edition.na153.force.com';

    //Trailhead
    public static FINAL String TRAILHEAD_API_KEY = 'bf14e43fd5a9f8cf277f8c01f7469175';
    public static FINAL String BASE_TRAILHEAD_API = 'https://api.trailhead.salesforce.com';
    public static FINAL String TRAILHEAD_API_USER_SEARCH = BASE_TRAILHEAD_API + '/v1/search/users';
    public static FINAL String TRAILHEAD_API_USER_SEARCH_BY_ID = BASE_TRAILHEAD_API + '/v1/users/{0}';
    public static FINAL String TRAILHEAD_API_CURSOR = BASE_TRAILHEAD_API + '/v1/cursor/users';
    public static FINAL String TRAILHEAD_API_MODULES = BASE_TRAILHEAD_API + '/v1/modules';
    public static FINAL String TRAILHEAD_API_ASSIGNMENTS = BASE_TRAILHEAD_API + '/v1/assignments';
    public static FINAL String TRAILHEAD_API_MIXES_SEARCH = BASE_TRAILHEAD_API + '/v1/search/trailmixes';

    //GCAL
    public static FINAL String GCAL_NAMED_CREDENTIAL = 'callout:Google_Event';
    public static FINAl Integer GCAL_EVENT_ATTENDEE_LIMIT = 100; 
    //public static FINAL String GCAL_CALENDAR_ID = '/94c15b9535f5412cadc7bb3330d9b8ae3f21dacf2a3e511402bc99a50532b729@group.calendar.google.com';
    public static FINAL String GCAL_CALENDAR_ID = IS_SANDBOX ? '/stanley.chui@appdev.it.salesforce.com' : '/astroscoursetracker@salesforce.com';
    public static FINAL String GCAL_EVENTS_ENDPOINT = GCAL_NAMED_CREDENTIAL + GCAL_CALENDAR_ID + '/events';
    public static FINAL String GCAL_JOB_NAME = 'Google Calendar Response Jobs';

    // ZOOM
    public static FINAL String ZOOM_ADMIN_CLIENT_ID = IS_SANDBOX ? credentials.Zoom_Dev_Admin_Client_Id__c : credentials.Zoom_Prod_Admin_Client_Id__c;
    public static FINAL String ZOOM_ADMIN_CLIENT_SECRET = IS_SANDBOX ? credentials.Zoom_Dev_Admin_Client_Secret__c : credentials.Zoom_Prod_Admin_Client_Secret__c;
    public static FINAL String ZOOM_VALIDATION_TOKEN = IS_SANDBOX ? credentials.Zoom_Dev_Validation_Token__c : credentials.Zoom_Prod_Validation_Token__c;
    public static FINAL String ZOOM_ACCOUNT_ID = IS_SANDBOX ? credentials.Zoom_Dev_Account_Id__c : credentials.Zoom_Prod_Account_Id__c;
    public static FINAL String PUBLIC_SITE_REDIRECT_URL = 'https://actprodpack-developer-edition.na153.force.com';
    public static FINAL String ZOOM_BASE_URL = 'https://api.zoom.us/v2';
    public static FINAL String ZOOM_ATTENDANCE_BATCH_NAME = 'ACT Zoom Attendance Tracker';

    // HEROKU
    public static FINAL String HEROKU_ENDPOINT = Utilities.getHerokuEndpoint(); // IS_SANDBOX ? 'https://act-slack-app-1ef373b96ec0.herokuapp.com/dev/depositeSlackNotifications' : 'https://act-slack-app-1ef373b96ec0.herokuapp.com/dev/depositeSlackNotifications';
    public static FINAL String HEROKU_API_KEY = Utilities.getHerokuApiKey(credentials); // credentials.Heroku_Api_Key__c;

    // BITLY
    public static FINAL String BITLY_API_TOKEN = credentials.Bitly_Api_Token__c;
    public static FINAL String BITLY_GROUP_GUID = credentials.Bitly_Group_Guid__c;
    public static FINAL String BITLY_BASE_URL = 'https://api-ssl.bitly.com/v4';
    public static FINAL String BITLY_QR_CODE_URL = BITLY_BASE_URL + '/qr-codes';

    public static FINAL String NAMESPACE = String.valueOf(Constants2.class).split('[.]').size() > 1 ? String.valueOf(Constants2.class).split('[.]')[0] : 'c';
    public static FINAL String NAMESPACE_API = NAMESPACE == 'c' ? '' : NAMESPACE + '__';
    // public static FINAL String ASSIGNMENT_JOB_NAME = 'Lighthouse Nightly Jobs';
    // public static FINAL String PATH_AND_STAGE_EMAIL_JOB_NAME = 'Path and Stage Email Jobs';
    // public static FINAL String ENABLEMENT_EMAIL_JOB_NAME = 'Enablement Email Jobs';
    // public static FINAL String ASSIGNMENT_CANCELLATION_JOB_NAME = 'Assignment Cancel Jobs';
    
    // public static FINAL String TRAILHEAD_API_KEY = credentials.Trailhead_Api_Key__c;
    // public static FINAL String BASE_TRAILHEAD_API = 'https://api.trailhead.salesforce.com';
    // public static FINAL String TRAILHEAD_API_USER_SEARCH = BASE_TRAILHEAD_API + '/v1/search/users';
    // public static FINAL String TRAILHEAD_API_USER_SEARCH_BY_ID = BASE_TRAILHEAD_API + '/v1/users/{0}';
    // public static FINAL String TRAILHEAD_API_CURSOR = BASE_TRAILHEAD_API + '/v1/cursor/users';
    // public static FINAL String TRAILHEAD_API_MODULES = BASE_TRAILHEAD_API + '/v1/modules';
    // public static FINAL String TRAILHEAD_API_ASSIGNMENTS = BASE_TRAILHEAD_API + '/v1/assignments';
    // public static FINAL String TRAILHEAD_API_MIXES_SEARCH = BASE_TRAILHEAD_API + '/v1/search/trailmixes';
    // public static FINAL String CLIENT_ID = credentials.Client_Id_Prod__c;
    // public static FINAL String CLIENT_SECRET = credentials.Client_Secret_Prod__c;
    // public static FINAL List<String> CAPACITY_FILLING_STATUSES = new List<String>{'Invited', 'Registered', 'Attended', 'Absent'};

    // public static FINAL String ZOOM_ADMIN_CLIENT_ID = IS_SANDBOX ? credentials.Zoom_Dev_Admin_Client_Id__c : credentials.Zoom_Prod_Admin_Client_Id__c;
    // public static FINAL String ZOOM_ADMIN_CLIENT_SECRET = IS_SANDBOX ? credentials.Zoom_Dev_Admin_Client_Secret__c : credentials.Zoom_Prod_Admin_Client_Secret__c;
    // public static FINAL String ZOOM_BASE_URL = 'https://api.zoom.us/v2';
    // public static FINAL String ZOOM_ATTENDANCE_BATCH_NAME = 'Zoom Attendance Tracker';

    // //Slack
    // public static FINAL Slack.App SLACKAPP = !IS_SANDBOX && (NAMESPACE != 'c') ? Slack.App.ACT.get() : Slack.App.ACT_Dev.get();

    // //GCAL
    // public static FINAl Integer GCAL_EVENT_ATTENDEE_LIMIT = 100; 
    // public static FINAL String GCAL_CLIENT_ID = IS_SANDBOX ? credentials.GCal_Dev_Client_Id__c : credentials.GCal_Client_Id__c;
    // public static FINAL String GCAL_CLIENT_SECRET = IS_SANDBOX ? credentials.GCal_Dev_Client_Secret__c : credentials.GCal_Client_Secret__c;
    // public static FINAL String GCAL_CALENDAR_ID = IS_SANDBOX ? 'stanley.chui@appdev.it.salesforce.com' : 'astroscoursetracker@salesforce.com';
    // public static FINAL String GCAL_CALENDAR_ENDPOINT = 'https://www.googleapis.com/calendar/v3/calendars/' + GCAL_CALENDAR_ID;
    // public static FINAL String GCAL_EVENTS_ENDPOINT = GCAL_CALENDAR_ENDPOINT + '/events';

    // public static FINAL Blob KEY = String.isNotEmpty(authSetting.Link_Encryption_Key__c) ? EncodingUtil.base64Decode(authSetting.Link_Encryption_Key__c) : Blob.valueOf('');
    // public static FINAL String SLACK_MULESOFT_CLIENT_ID = credentials.Slack_Mulesoft_Client_Id__c;
    // public static FINAL String SLACK_MULESOFT_CLIENT_SECRET = credentials.Slack_Mulesoft_Client_Secret__c;

    public String ns {get { return NAMESPACE; }}

    public Constants2() {

    }

    public Constants2(ApexPages.StandardController std) {

    }
}