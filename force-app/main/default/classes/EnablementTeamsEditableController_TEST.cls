@isTest
public with sharing class EnablementTeamsEditableController_TEST {
    @TestSetup
    static void makeData() {
        List<String> healths = new List<String>{'Not Started', 'Blocked', 'Canceled', 'On Track', 'Completed'};
        List<agf__PPM_Project__c> projects = new List<agf__PPM_Project__c>();
        List<agf__ADM_Epic__c> epics = new List<agf__ADM_Epic__c>();

        // make team
        List<agf__ADM_Scrum_Team__c> teams = new List<agf__ADM_Scrum_Team__c>();
        Id scrumRecType = Schema.SObjectType.agf__ADM_Scrum_Team__c.getRecordTypeInfosByName().get('Scrum Team').getRecordTypeId();
        teams.add(
            new agf__ADM_Scrum_Team__c(
                agf__Start_Date__c = Date.today().addDays(-30),
                RecordTypeId = scrumRecType, 
                agf__Cloud__c = 'Core', //department
                agf__Active__c = true,
                Name = 'Testing scrum Team'
            )
        );
        insert teams;

        // make Programs
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

        // make Projects
        for(agf__PPM_Program__c p : programs ) {
            projects.add(
                new agf__PPM_Project__c(
                    agf__Program__c = p.Id,
                    Name = 'Project - ' + String.valueOf(Math.random() * 1000), 
                    agf__Planned_Start_Date__c = p.agf__Start_Date__c.addDays(1), 
                    agf__Planned_End_Date__c = p.agf__End_Date__c.addDays(-3), 
                    agf__Project_Health__c = healths[Integer.valueOf(Math.random() * 3)],
                    agf__Delivery_Scrum_Team__c = teams[0].Id
                )
            );
        }
        insert projects;

        // make Epics
        for(agf__PPM_Project__c p : projects ) {
            epics.add(
                new agf__ADM_Epic__c(
                    agf__Project__c = p.Id,
                    Name = 'Epic - ' + String.valueOf(Math.random() * 1000), 
                    agf__Start_Date__c = p.agf__Planned_Start_Date__c.addDays(-1), 
                    agf__End_Date__c = p.agf__Planned_End_Date__c.addDays(13), 
                    agf__Health__c = 'On Track',
                    agf__Team__c = teams[0].Id
                )
            );
        }
        epics[epics.size()-1].agf__Health__c = 'Blocked';
        insert epics;

        // make work
        List<agf__ADM_Work__c> work = new List<agf__ADM_Work__c>();
        Integer counter = 0;
        List<String> statuses = new List<String>{'New', 'Acknowledged', 'In Progress', 'Investigating', 
            'Ready for Review', 'Fixed', 'QA In Progress', 'Closed', 'Deferred', 'Completed'};
        
        for (agf__ADM_Epic__c e : epics) {
            work.add( 
                new agf__ADM_Work__c(
                    agf__Epic__c = e.Id, 
                    agf__Subject__c = 'This Subject ' + String.valueOf(++counter), 
                    agf__Status__c = statuses[Integer.valueOf((Math.random() * 9))], 
                    //agf__Product_Tag__c,               
                    agf__Assignee__c = UserInfo.getUserId(), 
                    Start_Date__c = Date.today().addDays(10), 
                    Due_Date__c =Date.today().addDays(30), 
                    agf__Details__c = 'This is the description ' + String.valueOf(counter), 
                    agf__Story_Points__c = 3, 
                    Hours__c = 2.5, 
                    agf__Priority_Rank__c = Integer.valueOf((Math.random() * 50)), 
                    agf__QA_Engineer__c = UserInfo.getUserId(), 
                    Project__c = e.agf__Project__c,
                    agf__Scrum_Team__c = teams[0].Id
                )
            );
        }

        insert work;

    }


    @isTest
    static void listDataProjectTest() {
        Test.startTest();
        Id teamId = [SELECT Id, Name FROM agf__ADM_Scrum_Team__c][0].Id;
        String data = EnablementTeamsEditableController.getData(teamId, 'Project');        
        List<EnablementTeamsEditableController.WorkObjectWrapper> teamObject = 
            (List<EnablementTeamsEditableController.WorkObjectWrapper>)JSON.deserialize(data, 
                List<EnablementTeamsEditableController.WorkObjectWrapper>.class);
        Test.stopTest();
        System.debug('team project object size: ' + teamObject);
        System.assert(teamObject.size() == 4, 'cannot retrieve team data for projects');
    }

    @isTest
    static void listDataEpicTest() {
        Test.startTest();
        Id teamId = [SELECT Id, Name FROM agf__ADM_Scrum_Team__c][0].Id;
        String data = EnablementTeamsEditableController.getData(teamId, 'Epic');        
        List<EnablementTeamsEditableController.WorkObjectWrapper> teamObject = 
            (List<EnablementTeamsEditableController.WorkObjectWrapper>)JSON.deserialize(data, 
                List<EnablementTeamsEditableController.WorkObjectWrapper>.class);
        Test.stopTest();
        System.debug('team epic object size: ' + teamObject);
        System.assert(teamObject.size() == 4, 'cannot retrieve team data for epic');
    }

    @isTest
    static void listDataWorkTest() {
        Test.startTest();
        Id teamId = [SELECT Id, Name FROM agf__ADM_Scrum_Team__c][0].Id;
        String data = EnablementTeamsEditableController.getData(teamId, 'Work');        
        List<EnablementTeamsEditableController.WorkObjectWrapper> teamObject = 
            (List<EnablementTeamsEditableController.WorkObjectWrapper>)JSON.deserialize(data, 
                List<EnablementTeamsEditableController.WorkObjectWrapper>.class);
        Test.stopTest();
        System.debug('team work object size: ' + teamObject);
        System.assert(teamObject.size() == 4, 'cannot retrieve team data for work');
    }

    @isTest
    static void listSaveDataTest() {

        Test.startTest();        
        agf__ADM_Work__c w = [SELECT Id, Name FROM agf__ADM_Work__c LIMIT 1];

        String updatedWork = '[{"id":"","status":"In Progress","subject":"Send invites to Program retros - updated",' +
            '"startDate":"2021-12-28","dueDate":"2022-03-11","details":"New Description","hours":"2.5","storyPoints":"5"}]';
        
        updatedWork = updatedWork.replace('""', '"' + w.Id + '"');
        Integer saved = EnablementTeamsEditableController.saveChanges(updatedWork, 'Work');

        Test.stopTest();        
        System.assert(saved == 1, 'Cannot update records');
    }


    @isTest
    static void saveProjectData() {

        Test.startTest();        
        agf__PPM_Project__c w = [SELECT Id, Name FROM agf__PPM_Project__c LIMIT 1];

        string updatedProject = '[{"id":"","health":"Blocked","startDate":"2022-03-01","endDate":"2022-05-01"}]';
        
        updatedProject = updatedProject.replace('""', '"' + w.Id + '"');
        Integer saved = EnablementTeamsEditableController.saveChanges(updatedProject, 'Project');

        Test.stopTest();        
        System.assert(saved == 1, 'Cannot update records');
    }

    @isTest
    static void saveEpicData() {

        Test.startTest();        
        agf__ADM_Epic__c w = [SELECT Id, Name FROM agf__ADM_Epic__c LIMIT 1];

        string updatedEpic = '[{"id":"","health":"On Track","startDate":"2022-02-21","endDate":"2022-05-25","priority":"4","audience":"RVP","benefit":"GCR","geo":"LATAM","learningLength":"20"}]';
        
        updatedEpic = updatedEpic.replace('""', '"' + w.Id + '"');
        Integer saved = EnablementTeamsEditableController.saveChanges(updatedEpic, 'Epic');

        Test.stopTest();        
        System.assert(saved == 1, 'Cannot update records');
    }

}