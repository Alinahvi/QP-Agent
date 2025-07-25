public without sharing class VideoDetailController {
    @AuraEnabled
    public static String getDetails(String recordId){
        vtse__Stand_Deliver_Task__c tsk = [select   Id,
                                                    Name,
                                                    vtse__Stand_Deliver__c,
                                                    vtse__Stand_Deliver__r.Name,
                                                    vtse__Due_Date__c,
                                                    vtse__Stand_Deliver__r.vtse__Description__c,
                                                    vtse__Status__c,
                                                    vtse__Stand_Deliver__r.vtse__Minimum_Video_Length__c,
                                                    vtse__Stand_Deliver__r.vtse__Maximum_Video_Length__c,
                                                    vtse__Stand_Deliver__r.vtse__Concepts__c
                                            from vtse__Stand_Deliver_Task__c
                                            where Id = : recordId];

        List<vtse__Stand_Deliver_Media__c> medias =  [select  vtse__Media__c,
                                                        vtse__Media__r.Name 
                                                    from vtse__Stand_Deliver_Media__c	 
                                                    where vtse__Stand_Deliver__c = :tsk.vtse__Stand_Deliver__c	
                                                            and vtse__Media__c != null
                                                    order by CreatedDate DESC      
                                                    limit 1];

        

        VideoDetailWrapper wrp = new VideoDetailWrapper();
        wrp.tsk = tsk;
        if (medias.size() > 0){
            wrp.media = medias[0];
            wrp.siteDomain = getDomain();
            wrp.mediaName = medias[0].vtse__Media__r.Name;
            wrp.mediaLink = getDomain() + '/apex/scormanywhere__SCORM_Player?courseId=' + medias[0].vtse__Media__c + '&autoplay=0';
        }
        
        return JSON.serialize(wrp);
    }

    public class VideoDetailWrapper{
        vtse__Stand_Deliver_Task__c tsk {get; set;}
        vtse__Stand_Deliver_Media__c media {get; set;}
        String mediaName  {get; set;}
        String mediaLink {get; set;}
        String siteDomain {get; set;}
        public VideoDetailWrapper(){
            mediaName = '';
            mediaLink = '';
            siteDomain = '';
        }
    }
    
    public static String getDomain() {
        return Site.getSiteId() != null
            ? getSiteUrl()
                : System.Url.getSalesforceBaseUrl().toExternalForm().replace('.my.salesforce', 
                    '.lightning.force');
    
    }

    // private static String getSiteUrl() {
    //     String url = Site.getBaseCustomUrl();
    //     return url.endsWith('/s')
    //             ? url.removeEnd('/s')
    //             : Site.getPathPrefix() != ''
    //                     ? url + 'vforcesite'
    //                     : url + '/vforcesite';
    
    // }

    private static String getSiteUrl() { 
        Site site = [
            SELECT Id, UrlPathPrefix
            FROM Site
            WHERE MasterLabel = :Site.getMasterLabel()
                AND SiteType = 'ChatterNetwork' 
            LIMIT 1
        ];
        return [
            SELECT SecureUrl
            FROM SiteDetail
            WHERE DurableId = :site.Id 
            LIMIT 1
        ].SecureUrl; 
    }
        
    
    
}