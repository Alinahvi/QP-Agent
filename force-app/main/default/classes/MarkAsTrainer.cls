public with sharing class MarkAsTrainer {
    List<Learner_Profile__c> newLps;
    Map<Id, Learner_Profile__c> oldLps;

    @AuraEnabled
    public static ResponseData markTrainer(String lpId){
        ResponseData rd = new ResponseData();
        
        try {
            Learner_Profile__c lp = [SELECT Id, Primary_Email__c, Is_Trainer__c FROM Learner_Profile__c WHERE Id =: lpId];
            ResponseData licenseCheckRD = Attendees.checkZoomUserForLicense(lp.Primary_Email__c, 'Meeting', 'Host');

            if(licenseCheckRD.isSuccess && String.isEmpty((String)licenseCheckRD.results.get('errMsg'))){
                lp.Is_Trainer__c = true;
            } else {
                lp.Is_Trainer__c = false;

                if((Boolean)licenseCheckRD.results.get('needsLicense')){
                    rd.put('errMsg', 'Unable to assign this user as a trainer since they are not licensed. All trainers must have a licensed Zoom account.');
                } else {
                    String errMsg = String.isNotEmpty(licenseCheckRD.errMsg) ? licenseCheckRD.errMsg : (String)licenseCheckRD.results.get('errMsg');

                    rd.put('errMsg', errMsg);
                }
            }
            
            System.debug('**************** licenseCheckRD ' + licenseCheckRD);

            update lp;
            rd.put('isTrainer', lp.Is_Trainer__c);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }
}