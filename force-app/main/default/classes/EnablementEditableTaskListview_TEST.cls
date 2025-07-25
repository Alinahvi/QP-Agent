@isTest
public with sharing class EnablementEditableTaskListview_TEST {
    @TestSetup
    static void makeData(){
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

        // make work
        List<agf__ADM_Work__c> work = new List<agf__ADM_Work__c>();
        Integer Counter = 0;
        List<String> statuses = new List<String>{'New', 'Acknowledged', 'In Progress', 'Investigating', 
            'Ready for Review', 'Fixed', 'QA In Progress', 'Closed', 'Deferred', 'Completed'};
        
        for (agf__ADM_Epic__c e : epics) {
            work.add( 
                new agf__ADM_Work__c(
                    agf__Epic__c = e.Id, 
                    agf__Subject__c = 'This Subject ' + String.valueOf(++Counter), 
                    agf__Status__c = statuses[Integer.valueOf((Math.random() * 9))],                               
                    agf__Assignee__c = UserInfo.getUserId(), 
                    Start_Date__c = Date.today().addDays(10), 
                    Due_Date__c =Date.today().addDays(30), 
                    agf__Details__c = 'This is the description ' + String.valueOf(Counter), 
                    agf__Story_Points__c = 3, 
                    Hours__c = 2.5, 
                    agf__Priority_Rank__c = Integer.valueOf((Math.random() * 50)), 
                    agf__QA_Engineer__c = UserInfo.getUserId(), 
                    Project__c = e.agf__Project__c
                )
            );
        }

        insert work;

        List<agf__ADM_Task__c> tasks = new List<agf__ADM_Task__c>();        
        for (agf__ADM_Work__c w : work) {
            tasks.add(
                new agf__ADM_Task__c(
                    agf__Assigned_To__c = UserInfo.getUserId(), 
                    agf__Work__c = w.Id, 
                    agf__Subject__c = 'Subject for ' + String.valueOf(w.Id), 
                    agf__Status__c = 'Not Started', 
                    agf__Starting_Hours__c = 7.0,
                    agf__Hours_Remaining__c = 7.0, 
                    agf__Actual_Hours__c = 0, 
                    agf__Comments__c = 'Comments for ' + String.valueOf(w.Id)
                )
            );
        }

        insert tasks;

    }
    
    @isTest
    static void listSaveDataTest() {

        Test.startTest();        
        agf__ADM_Task__c t = [SELECT Id, Name FROM agf__ADM_Task__c LIMIT 1];

        String updatedTask = '[{"subject":"Channel Build out -- updated","id":"","status":"Waiting on someone else","dueBy":"2050-05-01","actualHours":"12","comments":"This is the comments for this task."}]';
        
        updatedTask = updatedTask.replace('""', '"' + t.Id + '"');
        Boolean saved = EnablementEditableTaskListview.saveUpdates(updatedTask);

        Test.stopTest();        
        System.assert(saved == true, 'Cannot update records');
    }

    @isTest
    static void getTaskDataTest() {
        Test.startTest();
        String tasks = EnablementEditableTaskListview.getTaskData();
        List<EnablementEditableListWork.WorkObjectWrapper> taskObject = 
            (List<EnablementEditableListWork.WorkObjectWrapper>)JSON.deserialize(tasks, 
                List<EnablementEditableListWork.WorkObjectWrapper>.class);
        Test.stopTest();
        System.assert(taskObject.size() > 0, 'Error retrieving tasks data');
    }

}