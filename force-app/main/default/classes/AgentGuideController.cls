public with sharing class AgentGuideController {
    
    @AuraEnabled(cacheable=true)
    public static List<OUData> getOUData() {
        try {
            List<AGENT_OU_PIPELINE_V2__c> records = [
                SELECT OU_NAME__c, WORK_LOCATION_COUNTRY__c 
                FROM AGENT_OU_PIPELINE_V2__c 
                WHERE OU_NAME__c != null 
                ORDER BY OU_NAME__c, WORK_LOCATION_COUNTRY__c
            ];
            
            // Get unique OUs
            Set<String> uniqueOUs = new Set<String>();
            for (AGENT_OU_PIPELINE_V2__c record : records) {
                if (record.OU_NAME__c != null) {
                    uniqueOUs.add(record.OU_NAME__c);
                }
            }
            
            List<OUData> ouDataList = new List<OUData>();
            for (String ou : uniqueOUs) {
                OUData ouData = new OUData();
                ouData.ouName = ou;
                ouData.countries = new List<String>();
                
                // Get countries for this OU (deduplicated)
                Set<String> uniqueCountries = new Set<String>();
                for (AGENT_OU_PIPELINE_V2__c record : records) {
                    if (record.OU_NAME__c == ou && record.WORK_LOCATION_COUNTRY__c != null) {
                        uniqueCountries.add(record.WORK_LOCATION_COUNTRY__c);
                    }
                }
                ouData.countries = new List<String>(uniqueCountries);
                ouData.countries.sort(); // Sort alphabetically
                
                ouDataList.add(ouData);
            }
            
            return ouDataList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching OU data: ' + e.getMessage());
        }
    }
    
    public class OUData {
        @AuraEnabled
        public String ouName { get; set; }
        
        @AuraEnabled
        public List<String> countries { get; set; }
    }
}
