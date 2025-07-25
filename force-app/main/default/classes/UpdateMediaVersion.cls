public with sharing class UpdateMediaVersion {
    public UpdateMediaVersion() {

    }

    @AuraEnabled(cacheable=true)
    public static ResultData wiredMediaVersionUploadStr(String recordId) {
        ResultData result = new ResultData();
        List<Asset__c> asset = [SELECT Id, Media__c, Name FROM Asset__c WHERE Id =: recordId WITH USER_MODE];
        if(!asset.isEmpty() && String.isNotBlank(asset[0].Media__c)) {
            String versionUploadString = '{"relatedLearningObjects":{},"parentCourseGeoRegions":[],"parentCourseId":"'+asset[0].Media__c+'"}';
            Map<String, String> data = new Map<String, String>();
            data.put('mediaVersionStr', versionUploadString);
            data.put('mediaId', asset[0].Media__c);
            data.put('assetId', asset[0].Id);
            result.setData(data);
            result.setResultStatusAndMessage(MediaConstants.STATUS_SUCCESS, 'Media added to version upgrade : '+asset[0].Media__c+' for Learning Asset : '+asset[0].Id, null);            
        } else {
            result.setResultStatusAndMessage(MediaConstants.STATUS_ERROR, 'No Media attached to this learning Asset : '+asset[0].Name, null);
            System.debug(' Error --------- '+ result);
        }
        return result;
    }

    @AuraEnabled
    public static ResultData updateMediaVersion(String newMedia, String recordId) {
        ResultData result = new ResultData();
        List<Asset__c> asset = [SELECT Id, Name, Media__c, Url__c 
                                                        FROM Asset__c 
                                                        WHERE Id =: recordId
														WITH USER_MODE];
        if(!asset.isEmpty()) {
            String communityId='';
            for (ConnectApi.Community community : ConnectApi.Communities.getCommunities(ConnectApi.CommunityStatus.Live).communities) {
                if(community.Name == 'Astro\'s Course Tracker') {
                    communityId = community.id;
                    break;                    
                }
            }
            asset[0].Url__c = scormanywhere.ApiService.getLink(
                MediaConstants.GET_PLAYBACK_LINK_PARAM,
                JSON.serialize(new GetLinkWrapper(newMedia, communityId)) //'internal'))
            );
            asset[0].Media__c = newMedia;
            
            try{
                update as user asset;
                result.setResultStatusAndMessage(MediaConstants.STATUS_SUCCESS, 'Asset has been updated with the latest media version.', null);
            } catch(Exception e) {
                result.setResultStatusAndMessage(MediaConstants.STATUS_ERROR, 'Error in media version update', null);                
            }
        } else {
            result.setResultStatusAndMessage(MediaConstants.STATUS_ERROR, 'No Media attached to this learning Asset : '+asset[0].Name, null);
        }
        return result;
    }

    public class GetLinkWrapper {
        public String courseId;
        public String audience;

        public GetLinkWrapper(String mediaId, String audienceId) {
            this.courseId = mediaId;
            this.audience = audienceId;
        }
    }
    
}