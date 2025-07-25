public with sharing class MediaConstants {
	private static Organization org = [SELECT Id, InstanceName, IsSandbox FROM Organization LIMIT 1];

    public static FINAL String ORG_ID = org.Id;
    public static FINAL String INSTANCE_NAME = org.InstanceName;
    public static FINAL Boolean IS_SANDBOX = org.IsSandbox;
    public static FINAL String BASE_URL = 'https://' + INSTANCE_NAME + '.salesforce.com';

    public static FINAL String NAMESPACE = String.valueOf(constants.class).split('[.]').size() > 1 ? String.valueOf(constants.class).split('[.]')[0] : 'c';
    public static FINAL String NAMESPACE_API = NAMESPACE == 'c' ? '' : NAMESPACE + '__';
    public static final String STATUS_SUCCESS           = 'SUCCESS';
    public static final String STATUS_ERROR             = 'ERROR';
    public static final String STATUS_ACCESS_DENIED     = 'ACCESS_DENIED';
    public static final String AUDIENCE_ID_INTERNAL    = 'internal';
    public static final String GET_PLAYBACK_LINK_PARAM = 'GetPlaybackURL';
    public static final String OBJECT_API_NAME_MEDIA   = 'scormanywhere__Course__c';

    public String ns {get { return NAMESPACE; }}

    public MediaConstants() {

    }

    public MediaConstants(ApexPages.StandardController std) {

    }
}