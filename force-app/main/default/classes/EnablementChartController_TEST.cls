@IsTest
public with sharing class EnablementChartController_TEST {
    
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
    private static void testEpics() {
        Date tempDateStart = Date.today().addMonths(-3);
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), 
            tempDateStart.day() + 1, 0, 0, 0);
        Long startDate = instance.getTime(); 
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), 
            tempDateEnd.day() + 1, 0, 0, 0);
        Long endDate = instance2.getTime();

        System.debug('START: ' + startDate + ' Instance ' + instance);
        System.debug('End: ' + endDate + ' Instance ' + instance2);

        Integer slotSize = 14;

        Test.startTest();
        List<agf__ADM_Epic__c> epics = [SELECT Id, Name, agf__Health__c, agf__Project__c, agf__Start_Date__c, agf__End_Date__c 
            FROM agf__ADM_Epic__c WHERE (NOT agf__Health__c IN ('Completed', 'Cancelled', 'Canceled'))  ];
        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + 
            '~' + String.valueOf(slotSize) + '~' + showByUpperLevel;  
        
        System.debug('the programs 1: ' + epics);
        System.debug('the programs 1 Count: ' + epics.size());
        List<Object> epicList = EnablementChartController.getEpics(params);
        System.debug('the programs: ' + epicList);
        System.assert(epicList.size() == 0, 'Invalid number of epics'); //need a better test here

        Test.stopTest();
    }

    @isTest
    private static void testEpicsById() {
        Date tempDateStart = Date.today();
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), tempDateStart.day(), 0, 0, 0);
        Long startDate = instance.getTime() / 1000;
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), tempDateEnd.day(), 0, 0, 0);
        Long endDate = instance2.getTime() / 1000;

        Integer slotSize = 14;

        Test.startTest();
        List<agf__ADM_Epic__c> epics = [SELECT Id, Name, agf__Health__c, agf__Project__c 
            FROM agf__ADM_Epic__c WHERE (NOT agf__Health__c IN ('Completed', 'Cancelled', 'Canceled'))];
        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) 
        +  '~' + showByUpperLevel + '~' + String.valueOf(epics[0].Id);        

        List<Object> epicsList = EnablementChartController.getEpics(params);        
        System.assert(epicsList.size() == 1, 'Invalid number of epics by Id');

        Test.stopTest();
    }

    @isTest
    private static void testPrograms() {
        Date tempDateStart = Date.today();
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), tempDateStart.day(), 0, 0, 0);
        Long startDate = instance.getTime() / 1000;
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), tempDateEnd.day(), 0, 0, 0);
        Long endDate = instance2.getTime() / 1000;

        Integer slotSize = 14;

        Test.startTest();
        List<agf__PPM_Program__c> programs = [SELECT Id, Name, agf__Start_Date__c, agf__End_Date__c, agf__Program_Health__c FROM agf__PPM_Program__c];
        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) + '~' + showByUpperLevel;        
        System.assert(programs.size() == 4, 'Invalid number of programs');

        List<Object> programsList = EnablementChartController.getPrograms(params);

        Test.stopTest();
    }

    @isTest
    private static void testProgramsById() {
        Date tempDateStart = Date.today().addMonths(-2);
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), tempDateStart.day(), 0, 0, 0);
        Long startDate = instance.getTime() / 1000;
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), tempDateEnd.day(), 0, 0, 0);
        Long endDate = instance2.getTime() / 1000;

        Integer slotSize = 14;

        Test.startTest();
        List<agf__PPM_Program__c> programs = [SELECT Id, Name, agf__Start_Date__c, agf__End_Date__c, agf__Program_Health__c 
            FROM agf__PPM_Program__c WHERE agf__Program_Health__c = 'On Track'];
        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize)  
        + '~' + showByUpperLevel + '~' + String.valueOf(programs[0].Id);
           
        List<Object> programsList = EnablementChartController.getPrograms(params);        
        System.assert(programsList.size() == 1, 'Invalid number of programs by Id');

        Test.stopTest();
    }

    @isTest
    private static void testProject() {
        Date tempDateStart = Date.today();
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), tempDateStart.day(), 0, 0, 0);
        Long startDate = instance.getTime() / 1000;
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), tempDateEnd.day(), 0, 0, 0);
        Long endDate = instance2.getTime() / 1000;

        Integer slotSize = 28;

        Test.startTest();
        List<agf__PPM_Project__c> projects = [SELECT Id, Name, agf__Planned_Start_Date__c, agf__Planned_End_Date__c, agf__Project_Health__c FROM agf__PPM_Project__c];
        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) + '~' + showByUpperLevel;        
        System.assert(projects.size() == 4, 'Invalid number of projects');
        List<Object> projectsList = EnablementChartController.getProjects(params);        

        Test.stopTest();
    }

    @isTest
    private static void testProjectById() {
        Date tempDateStart = Date.today();
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), tempDateStart.day(), 0, 0, 0);
        Long startDate = instance.getTime() / 1000;
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), tempDateEnd.day(), 0, 0, 0);
        Long endDate = instance2.getTime() / 1000;

        Integer slotSize = 28;

        Test.startTest();
        List<agf__PPM_Project__c> projects = [SELECT Id, Name, agf__Planned_Start_Date__c, agf__Planned_End_Date__c, 
            agf__Project_Health__c FROM agf__PPM_Project__c WHERE (NOT agf__Project_Health__c IN ('Completed', 'Cancelled', 'Canceled'))];

        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) +  
            '~' + showByUpperLevel + '~' + String.valueOf(projects[0].Id);        
        List<Object> projectsList = EnablementChartController.getProjects(params);        

        System.assert(projectsList.size() == 1, 'Invalid number of projects by Id');

        Test.stopTest();
    }

    @isTest
    private static void testDataById() {
        Date tempDateStart = Date.today();
        Datetime instance = Datetime.newInstanceGmt(tempDateStart.year(), tempDateStart.month(), tempDateStart.day(), 0, 0, 0);
        Long startDate = instance.getTime() / 1000;
        Boolean showByUpperLevel = false;

        Date tempDateEnd = Date.today().addDays(90);
        Datetime instance2 = Datetime.newInstanceGmt(tempDateEnd.year(), tempDateEnd.month(), tempDateEnd.day(), 0, 0, 0);
        Long endDate = instance2.getTime() / 1000;

        Integer slotSize = 28;

        Test.startTest();
        // TEST PROJECTS
        List<agf__PPM_Project__c> projects = [SELECT Id, Name FROM agf__PPM_Project__c 
            WHERE (NOT agf__Project_Health__c IN ('Completed', 'Cancelled', 'Canceled')) LIMIT 1];

        String params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) +  
            '~' + showByUpperLevel + '~' + String.valueOf(projects[0].Id);        
        System.assert(projects.size() == 1, 'Invalid number of projects');

        List<Object> projectsList = EnablementChartController.getDataById(params);        
        System.assert(projectsList.size() == 1, 'Invalid number of projects by Id');

        /* // TEST PROGRAMS
        List<agf__PPM_Program__c> programs = [SELECT Id, Name FROM agf__PPM_Program__c LIMIT 1];
        params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) +  
            '~' + showByUpperLevel + '~' + String.valueOf(programs[0].Id);
        System.assert(programs.size() == 1, 'Invalid number of programs');

        List<Object> programList = EnablementChartController.getDataById(params);
        System.debug('number of programs: ' + programList.size());
        System.assert(programList.size() == 4, 'Invalid number of programs by Id');

        // TEST EPICS
        List<agf__ADM_Epic__c> epics = [SELECT Id, Name FROM agf__ADM_Epic__c LIMIT 1];
        params = String.valueOf(startDate) + '~' + String.valueOf(endDate) + '~' + String.valueOf(slotSize) +  
            '~' + showByUpperLevel + '~' + String.valueOf(epics[0].Id);
        System.assert(epics.size() == 1, 'Invalid number of epics');

        List<Object> epicList = EnablementChartController.getDataById(params);
        System.debug('number of epicList: ' + epicList.size());
        System.assert(epicList.size() == 4, 'Invalid number of Epics by Id');        */

        Test.stopTest();
    }

    @isTest
    private static void testObjectName() {
        List<agf__ADM_Epic__c> epics = [SELECT Id, Name FROM agf__ADM_Epic__c LIMIT 1];
        String objName = EnablementChartController.getObjectName(epics[0].Id);
        System.assert(objName.contains('Epic'), 'Invalid object Name');
    }

    @isTest
    private static void testObjectLabel() {
        List<agf__ADM_Epic__c> epics = [SELECT Id, Name FROM agf__ADM_Epic__c LIMIT 1];
        String objName = EnablementChartController.getObjectLabel(epics[0].Id, false);        
        System.assert(objName == 'Epic', 'Invalid object Label');
    }

    @isTest
    private static void testFiscalQuarter() {
        String fq = 'NEXT_FISCAL_QUARTER';
        List<Period> period = EnablementChartController.getFiscalQuarterData(fq);
        System.assert(period[0].StartDate > Date.today(), 'Invalid fiscal quarter');
    }

}