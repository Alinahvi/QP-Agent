public with sharing class EnablementChartController {

    @AuraEnabled
    public static List<Object> getPrograms( String params ) {
        List<String> paramList = params.split('~'); //String startTime, String endTime, Integer slotSize, Id recordId
        List<Object> programs = new List<Object>();

        try {            
            Date startDate = DateTime.newInstance(Long.valueOf(paramList[0])).date();
            Date endDate = DateTime.newInstance(Long.valueOf(paramList[1])).date();
            Integer slotSize = Integer.valueOf(paramList[2]);              
            
            String query = 'SELECT Id, Name, agf__Start_Date__c, agf__End_Date__c, agf__Program_Health__c FROM agf__PPM_Program__c ';
            if (paramList.size() == 5 ) {
                Id recordId = Id.valueOf(paramList[4]); 
                query += ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\' ';
            } else {
                query += ' WHERE agf__Start_Date__c != NULL AND agf__Start_Date__c <= :endDate AND agf__End_Date__c >= :startDate ';
            }
            query += 'AND (NOT agf__Program_Health__c IN (\'Completed\', \'Cancelled\', \'Canceled\')) WITH SECURITY_ENFORCED '; 
            
            List<agf__PPM_Program__c> programQuery = Database.query(query);            
            for(agf__PPM_Program__c p : programQuery) {

                Date theStart = p.agf__Start_Date__c < startDate ? startDate : p.agf__Start_Date__c;
                Date theEnd = p.agf__End_Date__c > endDate ? endDate : p.agf__End_Date__c;

                Decimal left = Decimal.valueOf( startDate.daysBetween(theStart) ) / slotSize;
                left = left.round(System.RoundingMode.FLOOR);

                Decimal right = Decimal.valueOf(startDate.daysBetween(theEnd) ) / slotSize;
                right = right.round(System.RoundingMode.FLOOR);
            
                programs.add(                        
                    new Map<String, Object>{
                        'Id' => p.Id,
                        'StartDate' => p.agf__Start_Date__c,
                        'EndDate' => p.agf__End_Date__c,
                        'Status' => p.agf__Program_Health__c,
                        'projectName' => p.Name,
                        'color' => EnablementChartController.getColor(p.agf__Program_Health__c, p.agf__Start_Date__c),
                        'left' => left,
                        'right' => right,
                        'team' => null,
                        'completed' => null
                    }                    
                );
            }

        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        return programs;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getProjects(String params) {
        List<Object> projects = new List<Object>();
        List<String> paramList = params.split('~'); //String startTime, String endTime, Integer slotSize, Id recordId
        
        try {            
            Date startDate = DateTime.newInstance(Long.valueOf(paramList[0])).date();
            Date endDate = DateTime.newInstance(Long.valueOf(paramList[1])).date();
            Integer slotSize = Integer.valueOf(paramList[2]);
            Boolean showByUpperLevel = Boolean.valueOf(paramList[3]);
            Id recordId;
            
            String query = 'SELECT Id, Name, agf__Planned_Start_Date__c, agf__Planned_End_Date__c, agf__Project_Health__c, ' + 
                'Percent_Complete__c, agf__Delivery_Scrum_Team__r.Name FROM agf__PPM_Project__c ';            
            if (paramList.size() == 5 && showByUpperLevel ) {
                recordId = Id.valueOf(paramList[4]); 
                query += ' WHERE agf__Planned_Start_Date__c != NULL AND agf__Program__c =: recordId ';                
            } else if (paramList.size() == 5 ) {
                recordId = Id.valueOf(paramList[4]); 
                query += ' WHERE agf__Planned_Start_Date__c != NULL AND Id =: recordId ';
            } else {
                query += ' WHERE agf__Planned_Start_Date__c != NULL AND agf__Planned_Start_Date__c <= :endDate AND agf__Planned_End_Date__c >= :startDate ';
            }
            query += ' AND (NOT agf__Project_Health__c IN (\'Completed\', \'Cancelled\', \'Canceled\')) WITH SECURITY_ENFORCED ORDER BY Name';

            for(agf__PPM_Project__c p : Database.query(query)) {

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
                        'Id' => p.Id,
                        'StartDate' => p.agf__Planned_Start_Date__c,
                        'EndDate' => p.agf__Planned_End_Date__c,
                        'Status' => p.agf__Project_Health__c,
                        'projectName' => p.Name,
                        'color' => EnablementChartController.getColor(p.agf__Project_Health__c, p.agf__Planned_Start_Date__c),
                        'left' => left,
                        'right' => right, 
                        'team' => p.agf__Delivery_Scrum_Team__r.Name,
                        'completed' => completed
                    }                    
                );
            }

        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        return projects;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getEpics(String params) {
        List<Object> epics = new List<Object>();
        List<String> paramList = params.split('~'); //String startTime, String endTime, Integer slotSize, Id recordId
        
        try {                      
            Date startDate = DateTime.newInstance(Long.valueOf(paramList[0])).date();
            Date endDate = DateTime.newInstance(Long.valueOf(paramList[1])).date();
            Integer slotSize = Integer.valueOf(paramList[2]);
            Boolean showByUpperLevel = Boolean.valueOf(paramList[3]);
            Id recordId;
            
            String query = 'SELECT Id, Name, agf__Start_Date__c, agf__End_Date__c, agf__Health__c, agf__Team__r.Name, ' +
                ' Percent_Complete__c FROM agf__ADM_Epic__c ';
            if (paramList.size() == 5 && showByUpperLevel ) {
                recordId = Id.valueOf(paramList[4]); 
                query += ' WHERE agf__Start_Date__c != NULL AND agf__Project__c =: recordId ';                
            } else if (paramList.size() == 5 ) {
                recordId = Id.valueOf(paramList[4]); 
                query += ' WHERE agf__Start_Date__c != NULL AND Id =: recordId ';
            } else {
                query += ' WHERE agf__Start_Date__c != NULL AND agf__Start_Date__c <= ' + 
                endDate + ' AND agf__End_Date__c >= ' + startDate + ' ';
            }
            query += ' AND (NOT agf__Health__c IN (\'Completed\', \'Cancelled\', \'Canceled\')) WITH SECURITY_ENFORCED ORDER BY Name';
                        
            for(agf__ADM_Epic__c p : Database.query(query)) {                
                Date theStart = p.agf__Start_Date__c < startDate ? startDate : p.agf__Start_Date__c;
                Date theEnd = p.agf__End_Date__c > endDate ? endDate : p.agf__End_Date__c;

                Decimal left = Decimal.valueOf( startDate.daysBetween(theStart) ) / slotSize;
                left = left.round(System.RoundingMode.FLOOR);

                Decimal right = Decimal.valueOf(startDate.daysBetween(theEnd) ) / slotSize;
                right = right.round(System.RoundingMode.FLOOR);
            
                String completed = '0';
                if (p.Percent_Complete__c != null) {
                    completed = String.valueOf(p.Percent_Complete__c.setScale(0));
                }

                epics.add(                        
                    new Map<String, Object>{
                        'Id' => p.Id,
                        'StartDate' => p.agf__Start_Date__c,
                        'EndDate' => p.agf__End_Date__c,
                        'Status' => p.agf__Health__c,
                        'projectName' => p.Name,
                        'color' => EnablementChartController.getColor(p.agf__Health__c, p.agf__Start_Date__c),
                        'left' => left,
                        'right' => right,
                        'team' => p.agf__Team__r.Name,
                        'completed' => completed
                    }                    
                );
            }
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        return epics;
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

    // used when the object name is not known
    @AuraEnabled(cacheable=true)
    public static List<Object> getDataById(String params) {
        List<Object> returnValue = new List<Object>();
        List<String> paramList = params.split('~'); //String startTime, String endTime, Integer slotSize, Boolean showByUpperLevel, Id recordId
        Boolean showByUpperLevel = Boolean.valueOf(paramList[3]);

        switch on getObjectName( Id.valueOf(paramList[4]) ) {
            when 'agf__PPM_Program__c' {                
                returnValue = showByUpperLevel ? getProjects(params) : getPrograms(params);
            }
            when 'agf__PPM_Project__c' {                
                returnValue = showByUpperLevel ? getEpics(params) : getProjects(params);
            }
            when 'agf__ADM_Epic__c' {                             
                paramList[3] = 'false';                
                returnValue = getEpics(String.join(paramList,'~'));                
            }            
        }

        return returnValue;
    }

    @AuraEnabled(cacheable=true)
    public static String getObjectName(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    @AuraEnabled(cacheable=true)
    public static String getObjectLabel(Id recordId, Boolean showByUpperLevel) {
        String returnValue;

        switch on recordId.getSObjectType().getDescribe().getLabel() {
            when 'Program' {
                returnValue = 'Program';
                if (showByUpperLevel) {
                    Id id = [SELECT Id FROM agf__PPM_Project__c LIMIT 1].Id;
                    returnValue = id.getSObjectType().getDescribe().getLabel();
                }                
            }
            when 'Project' {                
                returnValue = 'Project';
                if (showByUpperLevel) {
                    Id id = [SELECT Id FROM agf__ADM_Epic__c LIMIT 1].Id;
                    returnValue = id.getSObjectType().getDescribe().getLabel();
                }  
            }
            when 'Epic' {                                                             
                returnValue = 'Epic';                
            }            
        }

        return returnValue;  
    }

    @AuraEnabled(cacheable=true)
    public static List<Period> getFiscalQuarterData(String quarter) {
        //quarter expected values: THIS_FISCAL_QUARTER, LAST_FISCAL_QUARTER, NEXT_FISCAL_QUARTER        
        try {
            String query = 'SELECT Id, StartDate, EndDate FROM Period WHERE Type = \'Quarter\' AND StartDate = ' + quarter +
                ' WITH SECURITY_ENFORCED';            
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}