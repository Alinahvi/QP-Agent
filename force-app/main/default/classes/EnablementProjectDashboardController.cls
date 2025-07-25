public with sharing class EnablementProjectDashboardController {
    
    @AuraEnabled(cacheable=true)
    public static List<Period> currentFiscalQuarter(){
        //quarter expected values: THIS_FISCAL_QUARTER, LAST_FISCAL_QUARTER, NEXT_FISCAL_QUARTER
        string period = 'THIS_FISCAL_QUARTER';
        try {
            String query = 'SELECT Id, StartDate, EndDate FROM Period WHERE Type = \'Quarter\' AND StartDate = ' + period +
                ' WITH SECURITY_ENFORCED';            
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible class FilterData {
        public List<ListOptions> geOrg;
        public List<ListOptions> geBusiness;        
        public List<ListOptions> program;
        public List<ListOptions> project;
        public List<ListOptions> team;
    }

    class ListOptions {        
        public String value;
        public String label;
        public Boolean selected = true;

        public ListOptions(String label, String value) {            
            this.value = value;
            this.label = label;
        }
    }

    @TestVisible class DependentFilterData {
        public Map<String,List<Map<String,List<String>>>> geOrg;
        public Map<String,List<Map<String,List<String>>>> program;
        public DependentFilterData(Map<String,List<Map<String,List<String>>>> g, Map<String,List<Map<String,List<String>>>> p) {
            this.geOrg = g;
            this.program = p;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getDependentPicklistValues(Date start, Date endDate) {

        Map<String,List<Map<String,List<String>>>> programs = fetchDependentProgramProject(start, endDate);
        Map<String,List<Map<String,List<String>>>> geOrg = fetchDependentPicklistValues();

        List<DependentFilterData> filters = new List<DependentFilterData> { 
            new DependentFilterData(geOrg, programs)
        };

        return JSON.serialize(filters);
    }

    private static Map<String,List<Map<String,List<String>>>> fetchDependentPicklistValues(){
        Map<String,List<Map<String,List<String>>>> mapOfDependentPicklist = new  Map<String,List<Map<String,List<String>>>>();        
        

        String query = 'SELECT Name, GE_Org__c, GE_Business_Unit__c FROM agf__ADM_Scrum_Team__c WHERE GE_Org__c != null AND GE_Business_Unit__c != null' 
            + ' GROUP BY GE_Org__c, GE_Business_Unit__c, Name';
        
        for(AggregateResult ag : Database.query(query)) {

            Map<String,List<String>> mapOfBusinessAndTeam = new Map<String,List<String>>();

            if(mapOfBusinessAndTeam.containsKey(String.valueOf(ag.get('GE_Business_Unit__c')))){
                mapOfBusinessAndTeam.get(String.valueOf(ag.get('GE_Business_Unit__c'))).add(String.valueOf(ag.get('Name')));
            }else{
                mapOfBusinessAndTeam.put(String.valueOf(ag.get('GE_Business_Unit__c')),new List<String>{String.valueOf(ag.get('Name'))});
            }

            if(MapOfDependentPicklist.containsKey(String.valueOf(ag.get('GE_Org__c')))){
                MapOfDependentPicklist.get(String.valueOf(ag.get('GE_Org__c'))).add(mapOfBusinessAndTeam);
            }else{
                MapOfDependentPicklist.put(String.valueOf(ag.get('GE_Org__c')),new List<Map<String,List<String>>>{mapOfBusinessAndTeam});
            }
        }

        return MapOfDependentPicklist;
    }

    private static Map<String,List<Map<String,List<String>>>> fetchDependentProgramProject(Date start, Date endDate) {
        Map<String,List<Map<String,List<String>>>> mapOfDependentPicklist = new  Map<String,List<Map<String,List<String>>>>();

        List<agf__PPM_Program__c> program = [SELECT Id, Name, 
            (SELECT agf__Delivery_Scrum_Team__r.Id, agf__Delivery_Scrum_Team__r.Name, ID, NAME 
                 FROM agf__Projects__r 
                 WHERE agf__Delivery_Scrum_Team__c != null AND
                     agf__Planned_Start_Date__c != NULL AND agf__Planned_End_Date__c != NULL AND agf__Planned_Start_Date__c <= :endDate AND agf__Planned_End_Date__c >= :start
                 ORDER BY agf__Delivery_Scrum_Team__r.Name, Name) 
        FROM agf__PPM_Program__c 
             WHERE agf__Start_Date__c != NULL AND agf__End_Date__c != NULL AND agf__Start_Date__c <= :endDate AND agf__End_Date__c >= :start];
        
        
        for (agf__PPM_Program__c p : program) {
            Map<String,List<String>> mapOfProgramAndProject = new Map<String,List<String>>();
            
            System.debug('The Program Name is: '+p.Name);
            for (agf__PPM_Project__c pr : p.agf__Projects__r) {
                
                if( mapOfProgramAndProject.containsKey(p.Name)) {
                    mapOfProgramAndProject.get(p.Name).add(String.valueOf(pr.Name));
                } else {
                    mapOfProgramAndProject.put(String.valueOf(p.Name), new List<String>{String.valueOf(pr.Name)});
                }
                
                if (mapOfDependentPicklist.containsKey(String.valueOf(pr.agf__Delivery_Scrum_Team__r.Name))){
                    mapOfDependentPicklist.get(String.valueOf(pr.agf__Delivery_Scrum_Team__r.Name)).add(mapOfProgramAndProject);
                } else {
                    mapOfDependentPicklist.put(String.valueOf(pr.agf__Delivery_Scrum_Team__r.Name),new List<Map<String,List<String>>>{mapOfProgramAndProject});
                }
            }

        }

        return mapOfDependentPicklist;

    }

    @AuraEnabled(cacheable=true)
    public static String getFilterData(Date start, Date endDate) {
        FilterData fd = new FilterData();        
        Map<String, ListOptions> geOrg = new Map<String, ListOptions>();
        Map<String, ListOptions> geBusiness = new Map<String, ListOptions>();
        List<ListOptions> team = new List<ListOptions>();
        team.add(new ListOptions('All', 'All'));
        
        geOrg.put('All', new ListOptions('All', 'All'));
        geBusiness.put('All', new ListOptions('All', 'All'));
        for(agf__ADM_Scrum_Team__c c : teamData()) {
            team.add(new ListOptions( c.Name, c.Name ));
            if (c.GE_Org__c != null) {
                geOrg.put(c.GE_Org__c, new ListOptions(c.GE_Org__c, c.GE_Org__c));
            }
            if (c.GE_Business_Unit__c != null) {
                geBusiness.put(c.GE_Business_Unit__c, new ListOptions(c.GE_Business_Unit__c, c.GE_Business_Unit__c));
            }
        }

        fd.geOrg = geOrg.values();
        fd.geBusiness = geBusiness.values();
        fd.program =  programData(start, endDate); 
        fd.project = projectData(start, endDate);
        fd.team = team;
        
        return JSON.serialize(fd);
    }

    private static List<ListOptions> programData(Date start, Date endDate) {        
        List<ListOptions> program = new List<ListOptions>();
        program.add(new ListOptions('All', 'All'));

        try {
            String query = 'SELECT Id, Name, Prioritization__c FROM agf__PPM_Program__c' +
            ' WHERE agf__Start_Date__c != NULL AND agf__End_Date__c != NULL AND agf__Start_Date__c <= :endDate AND agf__End_Date__c >= :start ' +
                'WITH SECURITY_ENFORCED ORDER BY Name ';
            for(agf__PPM_Program__c p : Database.query(query)) {
                program.add(new ListOptions( p.Name, p.Name ));
            }
            return program;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<ListOptions> projectData(Date start, Date endDate) { // for the period to collect date
        List<ListOptions> projectOptions = new List<ListOptions>();
        projectOptions.add(new ListOptions('All', 'All'));

        try {
            String query = 'SELECT Id, Name FROM agf__PPM_Project__c ' +
                ' WHERE agf__Planned_Start_Date__c != NULL AND agf__Planned_End_Date__c != NULL AND agf__Planned_Start_Date__c <= :endDate AND agf__Planned_End_Date__c >= :start ' +                
                ' WITH SECURITY_ENFORCED  ORDER BY Name';
            for(agf__PPM_Project__c p : Database.query(query)) {
                projectOptions.add(new ListOptions( p.Name, p.Name ));
            }
            return projectOptions;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<agf__ADM_Scrum_Team__c> teamData() {                
        try {
            String query = 'SELECT Id, Name, GE_Business_Unit__c, GE_Org__c ' +
                'FROM agf__ADM_Scrum_Team__c WHERE agf__Active__c = true WITH SECURITY_ENFORCED ORDER BY Name';
            return Database.query(query);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class HealthCount {
        public String healthName;
        public Integer healthCount;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getProjects(Date startDate, Date endDate, String filters, Boolean isByProgram) {        
        return (isByProgram == NULL || isByProgram == true
            ? getProjectsByProgram(startDate, endDate, filters)
            : getProjectsByEpic(startDate, endDate, filters));
    }

    private static List<Object> getProjectsByProgram(Date startDate, Date endDate, String filters) {
        List<Object> projects = new List<Object>();        
        String healthFilter = ' AND agf__Project_Health__c IN (\'Blocked\', \'Not Started\', \'On Hold\', \'On Track\', \'Watch\')';
        String security = ' WITH SECURITY_ENFORCED ';
        String orderBy = ' ORDER BY agf__Program__r.Name, agf__Delivery_Scrum_Team__r.Name, Name';
        String filtersApply = filters == null ? healthFilter + security + orderBy : filters;
        Map<String, Integer> healthCounter = new Map<String, Integer>();        

        try {                        
            Integer slotSize = 14;
            String query = 'SELECT Id, Name, agf__Planned_Start_Date__c, agf__Planned_End_Date__c, agf__Project_Health__c, ' 
                + ' Percent_Complete__c, agf__Delivery_Scrum_Team__r.Name, '
                + ' agf__Program__r.Id, agf__Program__r.Name, agf__Program__r.Prioritization__c '                
                + ' FROM agf__PPM_Project__c ' 
                + ' WHERE agf__Planned_Start_Date__c != NULL AND agf__Planned_End_Date__c != NULL AND agf__Planned_Start_Date__c <= :endDate AND agf__Planned_End_Date__c >= :startDate '
                + filtersApply;

            System.debug('HEALTH COUNTER: ' + healthFilter);
            System.debug('the query is: ' + query);
            System.debug('Start Date: ' + startDate);
            System.debug('end date: ' + endDate);

            for (agf__PPM_Project__c p : Database.query(query)) {

                Date theStart = p.agf__Planned_Start_Date__c < startDate ? startDate : p.agf__Planned_Start_Date__c;
                Date theEnd = p.agf__Planned_End_Date__c > endDate ? endDate : p.agf__Planned_End_Date__c;
                
                Decimal left = Decimal.valueOf( startDate.daysBetween(theStart) ) / slotSize;
                left = left.round(System.RoundingMode.FLOOR);
                
                Decimal right = Decimal.valueOf(startDate.daysBetween(theEnd) ) / slotSize;
                right = right.round(System.RoundingMode.FLOOR);
                
                String completed = '0';
                if (p.Percent_Complete__c != null) {
                    completed = String.valueOf(p.Percent_Complete__c.setScale(0));
                 } 

                projects.add(                        
                    new Map<String, Object>{
                        'id' => p.Id,
                        'startDate' => p.agf__Planned_Start_Date__c,
                        'endDate' => p.agf__Planned_End_Date__c,
                        'status' => p.agf__Project_Health__c,
                        'projectName' => p.Name,
                        'color' => getColor(p.agf__Project_Health__c, p.agf__Planned_Start_Date__c),
                        'left' => left,
                        'right' => right, 
                        'teamName' => p.agf__Delivery_Scrum_Team__r.Name,
                        'completed' => completed,
                        'programId' => p.agf__Program__r.Id, 
                        'programName' => p.agf__Program__r.Name, 
                        'programPriority' => p.agf__Program__r.Prioritization__c                        
                    }                    
                );
            }
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        return projects;
    }

    private static List<Object> getProjectsByEpic(Date startDate, Date endDate, String filters) {
        List<Object> projects = new List<Object>();
        String healthFilter = ' AND (NOT agf__Health__c IN (\'Completed\', \'Cancelled\', \'Canceled\')) ';
        String security = ' WITH SECURITY_ENFORCED ';
        String orderBy = ' ORDER BY agf__Project__r.Name, agf__Team__r.Name, Name';
        String filtersApply = filters == null ? healthFilter + security + orderBy : filters;
        Map<String, Integer> healthCounter = new Map<String, Integer>();
        
        try {                        
            Integer slotSize = 14;           
            String query = 'SELECT Id, Name, agf__Start_Date__c, agf__End_Date__c, agf__Health__c,'
                + ' agf__Team__r.Id, agf__Team__r.Name, agf__Project__r.agf__Planned_Start_Date__c,agf__Project__r.agf__Planned_End_Date__c,'
                + ' agf__Project__r.Id, agf__Project__r.Name, agf__Project__r.agf__Program__r.Id, agf__Project__r.agf__Program__r.Name'
                + ' FROM agf__ADM_Epic__c'
                + ' WHERE agf__Start_Date__c != NULL AND agf__End_Date__c != NULL '
                + ' AND agf__Start_Date__c <= :endDate AND agf__End_Date__c >= :startDate'
                + filtersApply;

            for (agf__ADM_Epic__c e : Database.query(query)) {

                Date theStart = e.agf__Start_Date__c < startDate ? startDate : e.agf__Start_Date__c;
                Date theEnd = e.agf__End_Date__c > endDate ? endDate : e.agf__End_Date__c;
                
                Decimal left = Decimal.valueOf( startDate.daysBetween(theStart) ) / slotSize;
                left = left.round(System.RoundingMode.FLOOR);
                
                Decimal right = Decimal.valueOf(startDate.daysBetween(theEnd) ) / slotSize;
                right = right.round(System.RoundingMode.FLOOR);
                
                projects.add(                        
                    new Map<String, Object>{
                        'id' => e.Id,
                        'startDate' => e.agf__Start_Date__c,
                        'endDate' => e.agf__End_Date__c,
                        'projectStartDate' => e.agf__Project__r.agf__Planned_Start_Date__c,
                        'projectEndDate' => e.agf__Project__r.agf__Planned_End_Date__c,
                        'status' => e.agf__Health__c,
                        'epicName' => e.Name,
                        'color' => getColor(e.agf__Health__c, e.agf__Start_Date__c),
                        'left' => left,
                        'right' => right, 
                        'teamName' => e.agf__Team__r.Name,                        
                        'programId' => e.agf__Project__r.agf__Program__r.Id, 
                        'programName' => e.agf__Project__r.agf__Program__r.Name,
                        'projectName' => e.agf__Project__r.Name
                    }                    
                );
            }
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        
        return projects;
    }

    private static String getColor(String colorCode, Date startDate) {
        String selectedColor;
        
        switch on colorCode {
            when 'At Risk', 'Watch' {
                selectedColor = '#FFC72C';
            }
            when 'Blocked' {
                selectedColor = '#FF0000';
            }
            when 'Canceled', 'Cancelled' {
                selectedColor = '#00A1E0';
            }   
            when 'On Hold' {
                selectedColor = '#7C868D';
            }
            when 'On Track' {
                selectedColor = '#97D700';
            }
            when 'Completed' {
                selectedColor = '#00A1E0';
            }
            when 'Not Started' {
                selectedColor = '#000000';
            }                        
            when else {
                selectedColor = '#000000';  // my default
            }
        }

        return selectedColor;
    }
    
}