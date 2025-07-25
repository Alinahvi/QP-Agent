@IsTest
public with sharing class EnablementProjectDashboardControllerTEST {
    
    @TestSetup
    static void makeData() {
        Integer idx = 0;
        List<String> healths = new List<String>{'Not Started', 'Blocked', 'Canceled', 'On Track', 'Completed'};
        List<agf__PPM_Project__c> projects = new List<agf__PPM_Project__c>();
        List<agf__ADM_Epic__c> epics = new List<agf__ADM_Epic__c>();

        List<agf__ADM_Scrum_Team__c> teams = new List<agf__ADM_Scrum_Team__c>{
            new agf__ADM_Scrum_Team__c(
                Name = 'Governance',
                GE_Org__c = 'GE Learning & Technology Operations', 
                GE_Business_Unit__c = 'Global Enablement Operations and Tech'
            ),
            new agf__ADM_Scrum_Team__c(
                Name = 'Enablement Operations',
                GE_Org__c = 'GE Learning & Technology Operations', 
                GE_Business_Unit__c = 'Global Enablement Operations and Tech'
            ),
            new agf__ADM_Scrum_Team__c(
                Name = 'Learning Apps',
                GE_Org__c = 'GE Learning & Technology Operations', 
                GE_Business_Unit__c = 'Global Enablement Operations and Tech'
            ),
            new agf__ADM_Scrum_Team__c(
                Name = 'Enablement Analytics',
                GE_Org__c = 'GE Learning & Technology Operations', 
                GE_Business_Unit__c = 'Global Enablement Operations and Tech'
            ),
            new agf__ADM_Scrum_Team__c(
                Name = 'Enablement Tech Support & Ops',
                GE_Org__c = 'GE Learning & Technology Operations', 
                GE_Business_Unit__c = 'Global Enablement Operations and Tech'
            )
        };
        insert teams;

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
                    agf__Planned_Start_Date__c = p.agf__Start_Date__c.addDays(-10), 
                    agf__Planned_End_Date__c = p.agf__End_Date__c.addDays(15), 
                    agf__Project_Health__c = healths[Integer.valueOf(Math.random() * 3)],
                    agf__Delivery_Scrum_Team__c = teams[idx++].Id
                )
            );
        }
        insert projects;
        idx = 0;

        for(agf__PPM_Project__c p : projects ) {
            epics.add(
                new agf__ADM_Epic__c(
                    agf__Project__c = p.Id,
                    Name = 'Epic - ' + String.valueOf(Math.random() * 1000), 
                    agf__Start_Date__c = p.agf__Planned_Start_Date__c.addDays(-1), 
                    agf__End_Date__c = p.agf__Planned_End_Date__c.addDays(13), 
                    agf__Health__c = 'On Track',
                    agf__Team__c = teams[idx++].Id
                )
            );
        }
        epics[epics.size()-1].agf__Health__c = 'Blocked';
        insert epics;   

    }

    @isTest
    static void getCurrentQuarter() {
        Date today = Date.today();
        List<Period> periods = EnablementProjectDashboardController.currentFiscalQuarter();
        System.assert(today >= periods[0].StartDate && today <= periods[0].EndDate, 'Invalid current fiscal quarter.');
    }


    @isTest
    private static void getPicklistValues() {
        Date starts = Date.today().addDays(-3);
        Date ends = Date.today().addDays(5);
        String jsonResult = EnablementProjectDashboardController.getDependentPicklistValues(starts, ends);
        
        List<EnablementProjectDashboardController.DependentFilterData> dfilters = 
            (List<EnablementProjectDashboardController.DependentFilterData>)JSON.deserialize(jsonResult, List<EnablementProjectDashboardController.DependentFilterData>.class);
        Map<String,List<Map<String,List<String>>>> geOrgs = dfilters[0].geOrg;        
        System.assert(geOrgs.get('GE Learning & Technology Operations') != null, 'Invalid picklist values');
    }

    @isTest
    private static void getFilterData() {
        Date starts = Date.today().addDays(-3);
        Date ends = Date.today().addDays(5);
        String jsonResult = EnablementProjectDashboardController.getFilterData(starts, ends);
        System.debug('options: ' + jsonResult);        

        System.assert(jsonResult.contains('Enablement Tech Support & Ops'), 'Invalid data for method getFilterData');
    }


    @IsTest
    static void getProjectsByPrograms() {
        //getProjects(Date startDate, Date endDate, String filters, Boolean isByProgram)
        String filters = ' AND agf__Delivery_Scrum_Team__r.GE_Org__c IN (\'GE Strategy\', \'GE Content & Curriculum\') AND agf__Delivery_Scrum_Team__r.Name IN (\'M&A Enablement\', \'Executive Programs\', \'WAVE\') AND agf__Project_Health__c IN (\'Blocked\', \'Not Started\', \'On Hold\', \'On Track\', \'Watch\')';
        Boolean byProgram = true;

        Date starts = Date.today().addDays(-3);
        Date ends = Date.today().addDays(5);
        List<Object> jsonResult = EnablementProjectDashboardController.getProjects(starts, ends, null, byProgram);
        
        System.assert(jsonResult.size() == 2, 'invalid number of programs'); // update assertions in final version
    }

    @IsTest
    static void getProjectsNotByPrograms() {
        //getProjects(Date startDate, Date endDate, String filters, Boolean isByProgram)
        String filters = ' AND agf__Delivery_Scrum_Team__r.GE_Org__c IN (\'GE Strategy\', \'GE Content & Curriculum\', \'Global Field Excellence & Enablement\') AND agf__Delivery_Scrum_Team__r.Name IN (\'M&A Enablement\', \'Product\', \'GFE Team\') AND agf__Project_Health__c IN (\'Blocked\', \'Not Started\', \'On Hold\', \'On Track\', \'Watch\')';
        Boolean byProgram = false;

        Date starts = Date.today().addDays(-3);
        Date ends = Date.today().addDays(5);
        List<Object> jsonResult = EnablementProjectDashboardController.getProjects(starts, ends, null, byProgram);
        
        System.assert(jsonResult.size() == 2, 'invalid number of epics');

    }
}