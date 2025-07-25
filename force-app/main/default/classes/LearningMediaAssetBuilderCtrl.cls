public with sharing class LearningMediaAssetBuilderCtrl {

    @AuraEnabled(cacheable=true)
    public static List<PicklistOptionWrapper> getAudiences(){
        List<PicklistOptionWrapper> result = new List<PicklistOptionWrapper>{
            new PicklistOptionWrapper(Label.Internal_Users, MediaConstants.AUDIENCE_ID_INTERNAL)
        };

        if (test.isRunningTest() == false) {
            for (ConnectApi.Community community : ConnectApi.Communities.getCommunities(ConnectApi.CommunityStatus.Live).communities) {
                result.add(new PicklistOptionWrapper(community.name, community.id));
            }
        } else {
            result.add(new PicklistOptionWrapper('Test Community', 'a0'));
        }

        return result;
    }

    @AuraEnabled
    public static ResultData addLinkToLearningMediaAsset(String recordId, String mediaId, String audienceId) {
        ResultData result = new ResultData();

        if (String.isBlank(recordId) || String.isBlank(mediaId) || String.isBlank(audienceId)) return result;

        try {
            Id recId = Id.valueOf(recordId);
            SObjectType sObjType = recId.getSobjectType();
            if(sObjType == Asset__c.getSObjectType()) {
                Asset__c asset = [SELECT Url__c, Media__c FROM Asset__c WHERE Id = :recordId WITH USER_MODE];
                String communityId='';
                for (ConnectApi.Community community : ConnectApi.Communities.getCommunities(ConnectApi.CommunityStatus.Live).communities) {
                    if(community.Name == 'Astro\'s Course Tracker') {
                        communityId = community.id;
                        break;                        
                    }
                }
                asset.Url__c = scormanywhere.ApiService.getLink(
                    MediaConstants.GET_PLAYBACK_LINK_PARAM,
                    JSON.serialize(new GetLinkWrapper(mediaId, communityId))
                );
                asset.Media__c = mediaId;
                update as user asset;
            }
            /* Remove references to ACT 1
            else {
                slj__Learning_Offering__c learningOffering = [SELECT slj__Url__c, Scorm_Media__c FROM slj__Learning_Offering__c WHERE Id = :recordId];

                learningOffering.slj__Url__c = scormanywhere.ApiService.getLink(
                    Constants.GET_PLAYBACK_LINK_PARAM,
                    JSON.serialize(new GetLinkWrapper(mediaId, audienceId))
                );
                learningOffering.Scorm_Media__c = mediaId;
                update as user learningOffering;
            }     
            */       
            
        } catch (Exception e) {
            result.setResultStatusAndMessage(MediaConstants.STATUS_ERROR, e.getMessage(), e);
        }

        return result;
    }

    /* @AuraEnabled
    public static ResultData mediaVersionUploadStr(String recordId) {
        ResultData result = new ResultData();
        List<slj__Learning_Offering__c> learningAsset = [SELECT Id, Scorm_Media__c, Name FROM slj__Learning_Offering__c WHERE Id =: recordId];

        if(!learningAsset.isEmpty() && String.isNotBlank(learningAsset[0].Scorm_Media__c)) {
            String versionUploadString = '{"relatedLearningObjects":{},"parentCourseGeoRegions":[],"parentCourseId":"'+learningAsset[0].Scorm_Media__c+'"}';
            Map<String, String> data = new Map<String, String>();
            data.put('mediaVersionStr', versionUploadString);
            result.setData(data);
            // result.setResultStatusAndMessage(Constants.STATUS_SUCCESS, 'Media added to version upgrade : '+learningAsset[0].Scorm_Media__c+' for Learning Asset : '+learningAsset[0].Id, null);
            result.setResultStatusAndMessage(Constants.STATUS_SUCCESS, versionUploadString, null);
        } else {
            result.setResultStatusAndMessage(Constants.STATUS_ERROR, 'No Media attached to this learning Asset : '+learningAsset[0].Name, null);
        }
        return result;
    } */

    public class GetLinkWrapper {
        public String courseId;
        public String audience;

        public GetLinkWrapper(String mediaId, String audienceId) {
            this.courseId = mediaId;
            this.audience = audienceId;
        }
    }
}