@isTest
private class ProgressTriggerTestClass {
    static testMethod void testEpicTrigger() {
        agf__PPM_Project__c Project = new agf__PPM_Project__c(Name='testProject', Percent_Complete__c=0);
        insert Project;
        agf__ADM_Epic__c Epic = new agf__ADM_Epic__c(Name='testEpic', agf__Project__c=Project.Id, Percent_Complete__c=0, agf__Health__c='On Track');
        insert Epic;
        agf__ADM_Work__c WorkItem1 = new agf__ADM_Work__c(agf__Status__c='In Progress', agf__Epic__c=Epic.Id, Project__c=Project.Id);
        agf__ADM_Work__c WorkItem2 = new agf__ADM_Work__c(agf__Status__c='In Progress', agf__Epic__c=Epic.Id, Project__c=Project.Id);
        
        insert WorkItem1;
        insert WorkItem2;
        
        System.assertEquals(0, Epic.Percent_Complete__c);
        
		WorkItem2.agf__Status__c = 'Closed';
        update WorkItem2;
        
        Epic = [SELECT Percent_Complete__c FROM agf__ADM_Epic__c WHERE Id =:Epic.Id];
        
        System.assertEquals(50, Epic.Percent_Complete__c);
        
        Epic.agf__Health__c = 'Completed';
        update Epic;
        
        Project = [SELECT Percent_Complete__c FROM agf__PPM_Project__c WHERE Id =:Project.Id];
        
        System.assertEquals(100, Project.Percent_Complete__c);
        
        delete WorkItem1;
        
        Epic = [SELECT Percent_Complete__c FROM agf__ADM_Epic__c WHERE Id =:Epic.Id];
        
        System.assertEquals(100, Epic.Percent_Complete__c);
        
        agf__ADM_Epic__c Epic1 = new agf__ADM_Epic__c(Name='testEpic2', agf__Project__c=Project.Id, Percent_Complete__c=0, agf__Health__c='On Track');
        insert Epic1;
        
        Project = [SELECT Percent_Complete__c FROM agf__PPM_Project__c WHERE Id =:Project.Id];
        
        System.assertEquals(50, Project.Percent_Complete__c);
        
        delete Epic1;
        
        Project = [SELECT Percent_Complete__c FROM agf__PPM_Project__c WHERE Id =:Project.Id];
        
        System.assertEquals(100, Project.Percent_Complete__c);
    }
}