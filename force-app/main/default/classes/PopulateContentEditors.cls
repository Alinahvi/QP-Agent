public class PopulateContentEditors implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Content_Editor_Ids__c,RecordType.Name, Owner.Id, Content_POC__c, Content_POC__r.User__c, Owner.isActive, Content_POC__r.Status__c,
                                         (Select Id from Allowed_Content_Editors__r) 
                                        from Asset__c 
                                        where RecordType.Name in ('Trailhead Module') And Content_Editor_Ids__c = '' and Owner.isActive = true]);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset__c> scope) {
    	List<Allowed_Content_Editor__c> editorList = new List<Allowed_Content_Editor__c>();
		Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
		Set<Id> learningIds = new Set<Id>();
        for(Asset__c cr : scope) {
            if(cr.Allowed_Content_Editors__r.isEmpty()) {
                if(cr.Content_POC__c != null && cr.Content_POC__r.Status__c == 'Active') {
                    editorList.add(new Allowed_Content_Editor__c (
                        Learner_Profile__c = cr.Content_POC__c,
                        Asset__c = cr.Id
                    ));					
                }
                if(cr.Owner.Id != cr.Content_POC__r.User__c && cr.Owner.isActive) {
					if(!contentByOwnerId.containsKey(cr.Owner.Id)) {
						contentByOwnerId.put(cr.Owner.Id, new List<Id>{cr.Id});
					} else {
						contentByOwnerId.get(cr.Owner.Id).add(cr.Id);
					}
				}
				learningIds.add(cr.Id);
            }	
        }
        
        for(Learner_Profile__c lp : [SELECT Id, User__c 
                                    FROM Learner_profile__c 
                                    WHERE User__c IN :contentByOwnerId.keySet() 
                                    WITH USER_MODE]) {
            List<Id> contentIds = contentByOwnerId.get(lp.User__c);
            if(contentIds != null && !contentIds.isEmpty()) {
                for(Id contentId : contentIds) {
                    editorList.add(new Allowed_Content_Editor__c (
                        Learner_Profile__c = lp.Id,
                        Asset__c = contentId
                    )); 
                }
            }
        }
        
        try {
            System.debug('editorList -------- '+editorList);
            insert editorList;
        }catch(Exception e) {
            System.debug('Error while updating Content Editor String ---- '+e.getStackTraceString() +' ------ '+e.getMessage());
        } 
		
        List<Asset__c> toUpdate = new List<Asset__c>();		
		for(Asset__c temp : [Select Id, Content_Editor_Ids__c, (Select Id, Learner_Profile__r.User__c from Allowed_Content_Editors__r) From Asset__c 
							Where Id in: learningIds]) {
			String str = '';
			for(Allowed_Content_Editor__c ac : temp.Allowed_Content_Editors__r) {
				str += ac.Learner_Profile__r.User__c + ',';
			}
			str = str.removeEnd(',');
			temp.Content_Editor_Ids__c = str;
			toUpdate.add(temp);
		}
		try {
            System.debug('temp -------- '+toUpdate);
            update toUpdate;
        }catch(Exception e) {
            System.debug('Error while updating Content Editor String ---- '+e.getStackTraceString() +' ------ '+e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    } 
}