public with sharing class SiteLink {
    public String siteUrlWithPrefix{get;set;}

    public SiteLink() {
        if(String.isEmpty(siteUrlWithPrefix)){
            List<Site> site = [SELECT Id FROM Site WHERE Name = 'Astro_s_Course_Tracker1'];
    
            if(!site.isEmpty()){
                String siteId = site.get(0).Id;
                List<SiteDetail> siteDetail = [SELECT SecureUrl FROM SiteDetail WHERE DurableId =: siteId];
    
                if(!siteDetail.isEmpty()){
                    siteUrlWithPrefix = siteDetail.get(0).SecureUrl;
                }
            }
        }

    }
}