@isTest
public with sharing class EnablementEditableListviewControllerTEST {
    
    @TestSetup
    static void makeData() {
        List<String> healths = new List<String>{'Not Started', 'Blocked', 'Canceled', 'On Track', 'Completed'};
        List<agf__PPM_Project__c> projects = new List<agf__PPM_Project__c>();
        List<agf__ADM_Epic__c> epics = new List<agf__ADM_Epic__c>();

        List<agf__PPM_Program__c> programs = new List<agf__PPM_Program__c> {
            new agf__PPM_Program__c(
                Name = 'Program 1',
                agf__Start_Date__c = Date.today().addMonths(-1), 
                agf__End_Date__c = Date.today().addDays(35), 
                agf__Program_Health__c = 'Canceled'
                ),
            new agf__PPM_Program__c(
                Name = 'Program 2',
                agf__Start_Date__c = Date.today().addDays(20), 
                agf__End_Date__c = Date.today().addMonths(14), 
                agf__Program_Health__c = 'On Track'
                ),
            new agf__PPM_Program__c(
                Name = 'Program 3',
                agf__Start_Date__c = Date.today().addMonths(2), 
                agf__End_Date__c = Date.today().addDays(135), 
                agf__Program_Health__c = 'Blocked'
                ),
            new agf__PPM_Program__c(
                Name = 'Program 4',
                agf__Start_Date__c = Date.today(), 
                agf__End_Date__c = Date.today().addDays(10), 
                agf__Program_Health__c = 'Not Started'
                )
        };
        insert programs;

        for(agf__PPM_Program__c p : programs ) {
            projects.add(
                new agf__PPM_Project__c(
                    agf__Program__c = p.Id,
                    Name = 'Project - ' + String.valueOf(Math.random() * 1000), 
                    agf__Planned_Start_Date__c = p.agf__Start_Date__c.addDays(1), 
                    agf__Planned_End_Date__c = p.agf__End_Date__c.addDays(-3), 
                    agf__Project_Health__c = healths[Integer.valueOf(Math.random() * 3)]
                )
            );
        }
        insert projects;

        for(agf__PPM_Project__c p : projects ) {
            epics.add(
                new agf__ADM_Epic__c(
                    agf__Project__c = p.Id,
                    Name = 'Epic - ' + String.valueOf(Math.random() * 1000), 
                    agf__Start_Date__c = p.agf__Planned_Start_Date__c.addDays(-1), 
                    agf__End_Date__c = p.agf__Planned_End_Date__c.addDays(13), 
                    agf__Health__c = 'On Track'
                )
            );
        }
        epics[epics.size()-1].agf__Health__c = 'Blocked';
        insert epics;        
    }

    @isTest
    private static void testRelatedProjects() {
        Id recordId = [SELECT Id FROM agf__PPM_Program__c LIMIT 1].Id;
        String results = EnablementEditableListviewController.getListViewData(recordId);
        System.assert(results.length() > 0, 'Invalid Project related records');        
    }

    @isTest
    private static void testRelatedEpics() {
        Id recordId = [SELECT Id FROM agf__PPM_Project__c LIMIT 1].Id;
        String results = EnablementEditableListviewController.getListViewData(recordId);
        System.assert(results.length() > 0, 'Invalid Epic related records');        
    }

    @isTest
    static void testProjectSave(){
        String dataToSave = '[{"team":"AE Onboarding","startDateUTC":1611734400000,"startDate":"2021-01-27",' + 
            '"recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001ySirUAE/view",' + 
            '"priority":null,' + 
            '"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN",' + 
            '"name":"Develop AE Onboarding Journey Milestones - V1","managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1",' + 
            '"learningLength":null,"id":"a5E2E000001ySirUAE","health":"Not Started","geo":null,"epicRecordDetail":null,"endDateUTC":1648710000000,' + 
            '"endDate":"2022-03-31","completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding","startDateUTC":1616396400000,' + 
            '"startDate":"2021-03-22","recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001ySiDUAU/view",' + 
            '"priority":null,"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN",' + 
            '"name":"Develop Onboarding Highspot for all Milestones & C360 Course design","managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1",' + 
            '"learningLength":null,"id":"a5E2E000001ySiDUAU","health":"At Risk","geo":null,"epicRecordDetail":null,"endDateUTC":1636444800000,' + 
            '"endDate":"2021-11-09","completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding","startDateUTC":1625641200000,' + 
            '"startDate":"2021-07-07","recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001ySimUAE/view",' + 
            '"priority":null,"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN",' + 
            '"name":"Discover and Map AE Onboarding Data","managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1","learningLength":null,' + 
            '"id":"a5E2E000001ySimUAE","health":"On Hold","geo":null,"epicRecordDetail":null,"endDateUTC":1634626800000,"endDate":"2021-10-19",' + 
            '"completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding","startDateUTC":1627455600000,"startDate":"2021-07-28",' + 
            '"recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001ySekUAE/view","priority":null,' + 
            '"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":null,"ownerId":null,"name":"Journey Milestones (name may change)",' + 
            '"managerName":null,"managerId":null,"learningLength":null,"id":"a5E2E000001ySekUAE","health":"Canceled","geo":null,"epicRecordDetail":null,' + 
            '"endDateUTC":1635663600000,"endDate":"2021-10-31","completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding",' + 
            '"startDateUTC":1632898800000,"startDate":"2021-09-29","recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001ySi8UAE/view",' + 
            '"priority":null,"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN","name":"Maintain: AE Onboarding Curriculum",' + 
            '"managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1","learningLength":null,"id":"a5E2E000001ySi8UAE","health":"At Risk","geo":null,' + 
            '"epicRecordDetail":null,"endDateUTC":1643616000000,"endDate":"2022-01-31","completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding",' + 
            '"startDateUTC":"1625702400000","startDate":"2021-07-06","recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001ySi3UAE/view",' + 
            '"priority":null,"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN",' + 
            '"name":"Map AE Onboarding Curriculum","managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1","learningLength":null,' + 
            '"id":"a5E2E000001ySi3UAE","health":"On Track","geo":null,"epicRecordDetail":null,"endDateUTC":1634626800000,"endDate":"2021-10-19",' + 
            '"completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding","startDateUTC":1640073600000,"startDate":"2021-12-21",' + 
            '"recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001yShtUAE/view","priority":null,' + 
            '"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN",' + 
            '"name":"Refresh Onboarding Core Curriculum - Listen Phase V2","managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1",' + 
            '"learningLength":null,"id":"a5E2E000001yShtUAE","health":"On Hold","geo":null,"epicRecordDetail":null,"endDateUTC":1648710000000,' + 
            '"endDate":"2022-03-31","completed":0,"benefit":null,"audience":null},{"team":"AE Onboarding","startDateUTC":1623826800000,' + 
            '"startDate":"2021-06-16","recordDetail":"https://readiness--java2.my.salesforce.com/lightning/r/agf__PPM_Project__c/a5E2E000001yShyUAE/view",' + 
            '"priority":null,"parentName":"AE Onboarding","parentId":"a5C2E000000sP3bUAE","ownerName":"Sumita Raman","ownerId":"0052E00000FyMGkQAN",' + 
            '"name":"Refresh Onboarding Core Curriculum - Partner Phase V1","managerName":"Jason Oldfield","managerId":"0052E00000NGoSVQA1",' + 
            '"learningLength":null,"id":"a5E2E000001yShyUAE","health":"Completed","geo":null,"epicRecordDetail":null,"endDateUTC":1642579200000,' + 
            '"endDate":"2022-01-19","completed":1,"benefit":null,"audience":null}]';
            Integer results = EnablementEditableListviewController.saveUpdatedRecords(dataToSave);
            System.debug('testing: ' + results);
            System.assert(results > 0, 'Invalid attempt to save records');
    }

    @isTest
    static void testEpicSave(){
        List<agf__ADM_Epic__c> epic = [SELECT Id, Name, agf__Project__c, agf__Project__r.Name, agf__Health__c, Percent_Complete__c, 
            agf__Start_Date__c, agf__End_Date__c, agf__Team__c, agf__Priority__c, Target_Audience__c, OU_Benefit__c, 
            Target_Geo_Region__c, Length_of_Learning__c, agf__Team__r.Name,
            Epic_Health_Color__c, Epic_Progress_Bar__c
            FROM agf__ADM_Epic__c];

        Test.startTest();

        epic[0].agf__Start_Date__c = Date.today().addMonths(-1);
        epic[0].agf__End_Date__c = Date.today().addMonths(4);

        EnablementEditableListviewController.WrapperObject epicWrapper = 
            new EnablementEditableListviewController.WrapperObject( epic[0], 'Epic' );
        String wrapperString = '[' + JSON.serialize(epicWrapper) + ']';

        System.debug('JSON Wrapper string: ' + wrapperString);
        Integer results = EnablementEditableListviewController.saveUpdatedRecords(wrapperString);
        System.debug('testing: ' + results);
        System.assert(results > 0, 'Invalid attempt to save Epic records');

        Test.stopTest();
    }

    @isTest
    static void miscellaneousTest() {
        List<agf__PPM_Project__c> project = [SELECT Id, Name, agf__Program__c, agf__Program__r.Name, agf__Project_Health__c, Percent_Complete__c, 
         agf__Planned_Start_Date__c, agf__Planned_End_Date__c, agf__Delivery_Scrum_Team__r.Name, agf__Project_Manager__c, 
         agf__Project_Manager__r.Name, agf__Product_Owner_Project_Object__c, agf__Product_Owner_Project_Object__r.Name, 
         Project_Progress_Bar__c, Project_Health_Icon__c
         FROM agf__PPM_Project__c ];

        List<agf__ADM_Epic__c> epic = [SELECT Id, Name, agf__Project__c, agf__Project__r.Name, agf__Health__c, Percent_Complete__c, 
         agf__Start_Date__c, agf__End_Date__c, agf__Team__c, agf__Priority__c, Target_Audience__c, OU_Benefit__c, 
         Target_Geo_Region__c, Length_of_Learning__c, agf__Team__r.Name, Epic_Health_Color__c, Epic_Progress_Bar__c 
         FROM agf__ADM_Epic__c];

        Test.startTest();
        EnablementEditableListviewController.WrapperObject projectWrapper = 
            new EnablementEditableListviewController.WrapperObject( project[0], 'Project' );

        EnablementEditableListviewController.WrapperObject epicWrapper = 
            new EnablementEditableListviewController.WrapperObject( epic[0], 'Epic' );

        Test.stopTest();

        System.assert(projectWrapper != null, 'Invalid Project object wrapper construction');
        System.assert(epicWrapper != null, 'Invalid Epic object wrapper construction');
    }
}