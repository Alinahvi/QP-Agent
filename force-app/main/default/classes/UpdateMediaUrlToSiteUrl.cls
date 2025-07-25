public class UpdateMediaUrlToSiteUrl implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name, Media__c, Url__c 
                                             FROM Asset__c 
                                             where RecordTypeId = '012Hu000000RJifIAG'
                                             and Media__c != null and Url__c = '007' 
                                             order by Id desc]);        	
        
    }
    
    public void execute(Database.BatchableContext BC, List<Asset__c> scope) {
        List<Asset__c> assetToUpdate = new List<Asset__c>();
        String communityId = '';
        List<Network> nt = [Select Id, Name From Network where Name = 'Astro\'s Course Tracker'];
        if(!nt.isEmpty()) {
            communityId = nt[0].Id;
        }
        if(!String.isEmpty(communityId)) {
            for(Asset__c asset : scope) {
                asset.Url__c = scormanywhere.ApiService.getLink(
                    MediaConstants.GET_PLAYBACK_LINK_PARAM,
                    JSON.serialize(new GetLinkWrapper(asset.Media__c, communityId)) 
                );
                assetToUpdate.add(asset);
            }
			if(!assetToUpdate.isEmpty()) {
                update assetToUpdate;
            }            
        }
        
    }

    public void finish(Database.BatchableContext BC) {
        // Database.executeBatch(new UpdateMediaUrlToSiteUrl(), 50);
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