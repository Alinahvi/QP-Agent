public with sharing class EmailLogo {
    public static String logoUrl {get; set;}
    public static String sfdcLogoUrl {get; set;}

    public emailLogo() {
        try{
            String domain = URL.getOrgDomainURL().getHost();

            if(String.isEmpty(logoUrl)){
                Document logo = [SELECT Id FROM Document WHERE DeveloperName = 'ACT_Logo' WITH USER_MODE];
                logoUrl = 'https://' + domain + '/servlet/servlet.ImageServer?id=' + logo.Id + '&oid=' + constants.ORG_ID;
            }

            if(String.isEmpty(sfdcLogoUrl)){
                Document sfdcLogo = [SELECT Id FROM Document WHERE DeveloperName = 'ACT_Logo' WITH USER_MODE ];
                sfdcLogoUrl = 'https://' + domain + '/servlet/servlet.ImageServer?id=' + sfdcLogo.Id + '&oid=' + constants.ORG_ID;
            }
        } catch (Exception e){ 

        }
    }
}