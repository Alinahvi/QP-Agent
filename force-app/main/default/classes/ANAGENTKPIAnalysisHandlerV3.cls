/**
 * @description ANAgent KPI Analysis Handler V3
 * Handles KPI analysis requests for AGENT_OU_PIPELINE_V2__c object
 * Supports meetings analysis by ramp status and other KPIs
 * @version 3.0
 * @author AI Assistant
 */
public with sharing class ANAGENTKPIAnalysisHandlerV3 {
    
    public class Request {
        @InvocableVariable(label='Action' description='Action to perform (Search, CountFieldValues, GetDistinctFieldValues)')
        public String action;
        
        @InvocableVariable(label='OU Name' description='Operating Unit name filter')
        public String OuName;
        
        @InvocableVariable(label='Work Location Country' description='Country filter')
        public String WorkLocationCountry;
        
        @InvocableVariable(label='Primary Industry' description='Industry filter')
        public String PrimaryIndustry;
        
        @InvocableVariable(label='Ramp Status' description='Ramp status filter')
        public String RampStatus;
        
        @InvocableVariable(label='Record Limit' description='Maximum number of records to return')
        public Integer recordLimit;
        
        @InvocableVariable(label='Metric Key' description='KPI metric to analyze (MEETINGS, CALLS, ACV, PG)')
        public String metricKey;
        
        @InvocableVariable(label='Time Frame' description='Time frame for analysis (CURRENT, PREVIOUS)')
        public String timeFrame;
        
        @InvocableVariable(label='Group By' description='Field to group by (AE, COUNTRY, OU, INDUSTRY, RAMP_STATUS)')
        public String groupBy;
        
        @InvocableVariable(label='Filter Criteria' description='Additional filter criteria')
        public String filterCriteria;
        
        @InvocableVariable(label='Per AE Normalize' description='Whether to normalize per AE')
        public Boolean perAENormalize;
        
        @InvocableVariable(label='Aggregation Type' description='Type of aggregation (AVG, SUM, MAX, MIN)')
        public String aggregationType;
        
        public Request() {
            this.action = 'Search';
            this.recordLimit = 50;
            this.metricKey = 'MEETINGS';
            this.timeFrame = 'CURRENT';
            this.groupBy = 'AE';
            this.perAENormalize = false;
            this.aggregationType = 'AVG';
        }
    }
    
    public class Response {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message or error details')
        public String message;
        
        @InvocableVariable(label='Total Record Count' description='Total number of records found')
        public Integer totalRecordCount;
        
        @InvocableVariable(label='KPI Records' description='KPI analysis results')
        public List<KPIRecord> kpiRecords;
        
        @InvocableVariable(label='Analysis Summary' description='Summary of the analysis')
        public String analysisSummary;
        
        @InvocableVariable(label='Execution Time (ms)' description='Execution time in milliseconds')
        public Long executionTimeMs;
        
        public Response() {
            this.success = false;
            this.message = '';
            this.totalRecordCount = 0;
            this.kpiRecords = new List<KPIRecord>();
            this.analysisSummary = '';
            this.executionTimeMs = 0;
        }
    }
    
    public class KPIRecord {
        @InvocableVariable(label='AE Name' description='Account Executive name')
        public String aeName;
        
        @InvocableVariable(label='Country' description='Work location country')
        public String country;
        
        @InvocableVariable(label='OU Name' description='Operating Unit name')
        public String ouName;
        
        @InvocableVariable(label='Industry' description='Primary industry')
        public String industry;
        
        @InvocableVariable(label='Ramp Status' description='Ramp status')
        public String rampStatus;
        
        @InvocableVariable(label='Meetings' description='Number of meetings')
        public Decimal meetings;
        
        @InvocableVariable(label='Calls' description='Number of calls')
        public Decimal calls;
        
        @InvocableVariable(label='ACV' description='Annual Contract Value')
        public Decimal acv;
        
        @InvocableVariable(label='Pipeline Generated' description='Pipeline generated amount')
        public Decimal pipelineGenerated;
        
        @InvocableVariable(label='Coverage' description='Coverage percentage')
        public Decimal coverage;
        
        @InvocableVariable(label='AI Mentions' description='Number of AI mentions')
        public Decimal aiMentions;
        
        // Roster data fields from Learner_Profile__c
        @InvocableVariable(label='Email' description='Primary email from Learner Profile')
        public String email;
        
        @InvocableVariable(label='Manager Name' description='Manager name from Learner Profile')
        public String managerName;
        
        @InvocableVariable(label='Manager Email' description='Manager email from Learner Profile')
        public String managerEmail;
        
        @InvocableVariable(label='Job Family' description='Job family from Learner Profile')
        public String jobFamily;
        
        @InvocableVariable(label='Division' description='Division from Learner Profile')
        public String division;
        
        @InvocableVariable(label='Is FLM' description='Is First Line Manager from Learner Profile')
        public Boolean isFLM;
        
        @InvocableVariable(label='Is FTE' description='Is Full Time Employee from Learner Profile')
        public Boolean isFTE;
        
        public KPIRecord() {
            this.meetings = 0;
            this.calls = 0;
            this.acv = 0;
            this.pipelineGenerated = 0;
            this.coverage = 0;
            this.aiMentions = 0;
            this.email = '';
            this.managerName = '';
            this.managerEmail = '';
            this.jobFamily = '';
            this.division = '';
            this.isFLM = false;
            this.isFTE = false;
        }
    }
    
    @InvocableMethod(
        label='Analyze KPIs V3'
        description='Analyzes KPIs from AGENT_OU_PIPELINE_V2__c with support for ramp status analysis'
        category='ANAgent'
    )
    public static List<Response> analyzeKPIs(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request request : requests) {
            Response response = new Response();
            Long startTime = System.currentTimeMillis();
            
            try {
                // Validate request
                if (String.isBlank(request.action)) {
                    response.success = false;
                    response.message = 'Action is required';
                    responses.add(response);
                    continue;
                }
                
                // Route to appropriate handler
                switch on request.action {
                    when 'Search' {
                        response = handleSearch(request);
                    }
                    when 'CountFieldValues' {
                        response = handleCountFieldValues(request);
                    }
                    when 'GetDistinctFieldValues' {
                        response = handleGetDistinctFieldValues(request);
                    }
                    when else {
                        response.success = false;
                        response.message = 'Unknown action: ' + request.action;
                    }
                }
                
                Long endTime = System.currentTimeMillis();
                response.executionTimeMs = endTime - startTime;
                
            } catch (Exception e) {
                Long endTime = System.currentTimeMillis();
                response.executionTimeMs = endTime - startTime;
                response.success = false;
                response.message = 'Error in KPI Analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'KPI Analysis Error: ' + e.getStackTraceString());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    private static Response handleSearch(Request request) {
        Response response = new Response();
        
        try {
            // Build SOQL query
            String soql = buildSearchQuery(request);
            System.debug('SOQL Query: ' + soql);
            
            // Execute query
            List<AGENT_OU_PIPELINE_V2__c> records = Database.query(soql);
            
            // Convert to KPI records
            List<KPIRecord> kpiRecords = new List<KPIRecord>();
            for (AGENT_OU_PIPELINE_V2__c record : records) {
                KPIRecord kpiRecord = new KPIRecord();
                kpiRecord.aeName = record.FULL_NAME__c;
                kpiRecord.country = record.WORK_LOCATION_COUNTRY__c;
                kpiRecord.ouName = record.OU_NAME__c;
                kpiRecord.industry = record.PRIMARY_INDUSTRY__c;
                kpiRecord.rampStatus = record.RAMP_STATUS__c;
                
                // Map KPI fields based on time frame
                if (request.timeFrame == 'CURRENT') {
                    kpiRecord.meetings = record.CQ_CUSTOMER_MEETING__c != null ? record.CQ_CUSTOMER_MEETING__c : 0;
                    kpiRecord.calls = record.CQ_CALL_CONNECT__c != null ? record.CQ_CALL_CONNECT__c : 0;
                    kpiRecord.acv = record.CQ_ACV__c != null ? record.CQ_ACV__c : 0;
                    kpiRecord.pipelineGenerated = record.CQ_PG__c != null ? record.CQ_PG__c : 0;
                    // Coverage and AI mentions not available in V2 object
                } else if (request.timeFrame == 'PREVIOUS') {
                    kpiRecord.meetings = record.PQ_CUSTOMER_MEETING__c != null ? record.PQ_CUSTOMER_MEETING__c : 0;
                    kpiRecord.calls = record.PQ_CALL_CONNECT__c != null ? record.PQ_CALL_CONNECT__c : 0;
                    kpiRecord.acv = record.PQ_ACV__c != null ? record.PQ_ACV__c : 0;
                    kpiRecord.pipelineGenerated = record.PQ_PG__c != null ? record.PQ_PG__c : 0;
                }
                
                kpiRecords.add(kpiRecord);
            }
            
            // Populate roster data from Learner_Profile__c using existing pattern
            populateRosterData(kpiRecords);
            
            response.success = true;
            response.message = 'Successfully retrieved ' + kpiRecords.size() + ' records';
            response.totalRecordCount = kpiRecords.size();
            response.kpiRecords = kpiRecords;
            response.analysisSummary = generateAnalysisSummary(kpiRecords, request);
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Search failed: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Search Error: ' + e.getStackTraceString());
        }
        
        return response;
    }
    
    private static Response handleCountFieldValues(Request request) {
        Response response = new Response();
        
        try {
            // Validate request parameters
            if (String.isBlank(request.groupBy)) {
                response.success = false;
                response.message = 'GroupBy field is required for CountFieldValues action';
                return response;
            }
            
            // Validate groupBy value
            Set<String> validGroupByValues = new Set<String>{'RAMP_STATUS', 'COUNTRY', 'OU', 'INDUSTRY'};
            if (!validGroupByValues.contains(request.groupBy)) {
                response.success = false;
                response.message = 'Invalid groupBy value. Must be one of: RAMP_STATUS, COUNTRY, OU, INDUSTRY';
                return response;
            }
            
            // Build aggregation query
            String soql = buildCountQuery(request);
            System.debug('Count SOQL Query: ' + soql);
            
            // Validate SOQL syntax before execution
            if (String.isBlank(soql) || !soql.contains('GROUP BY')) {
                response.success = false;
                response.message = 'Invalid SOQL query generated. Missing GROUP BY clause.';
                return response;
            }
            
            // Execute aggregation query
            List<AggregateResult> results = Database.query(soql);
            
            // Convert to KPI records for display
            List<KPIRecord> kpiRecords = new List<KPIRecord>();
            for (AggregateResult result : results) {
                KPIRecord kpiRecord = new KPIRecord();
                
                // Map based on groupBy field
                if (request.groupBy == 'RAMP_STATUS') {
                    kpiRecord.rampStatus = (String) result.get('RAMP_STATUS__c');
                    kpiRecord.meetings = (Decimal) result.get('recordCount');
                } else if (request.groupBy == 'COUNTRY') {
                    kpiRecord.country = (String) result.get('WORK_LOCATION_COUNTRY__c');
                    kpiRecord.meetings = (Decimal) result.get('recordCount');
                } else if (request.groupBy == 'OU') {
                    kpiRecord.ouName = (String) result.get('OU_NAME__c');
                    kpiRecord.meetings = (Decimal) result.get('recordCount');
                } else if (request.groupBy == 'INDUSTRY') {
                    kpiRecord.industry = (String) result.get('PRIMARY_INDUSTRY__c');
                    kpiRecord.meetings = (Decimal) result.get('recordCount');
                }
                
                kpiRecords.add(kpiRecord);
            }
            
            response.success = true;
            response.message = 'Successfully counted ' + kpiRecords.size() + ' groups';
            response.totalRecordCount = kpiRecords.size();
            response.kpiRecords = kpiRecords;
            response.analysisSummary = generateCountSummary(kpiRecords, request);
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Count failed: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Count Error: ' + e.getStackTraceString());
        }
        
        return response;
    }
    
    private static Response handleGetDistinctFieldValues(Request request) {
        Response response = new Response();
        
        try {
            // Build distinct values query
            String soql = buildDistinctQuery(request);
            System.debug('Distinct SOQL Query: ' + soql);
            
            // Execute query
            List<AggregateResult> results = Database.query(soql);
            
            // Convert to KPI records for display
            List<KPIRecord> kpiRecords = new List<KPIRecord>();
            for (AggregateResult result : results) {
                KPIRecord kpiRecord = new KPIRecord();
                
                // Map based on requested field
                if (request.groupBy == 'RAMP_STATUS') {
                    kpiRecord.rampStatus = (String) result.get('RAMP_STATUS__c');
                } else if (request.groupBy == 'COUNTRY') {
                    kpiRecord.country = (String) result.get('WORK_LOCATION_COUNTRY__c');
                } else if (request.groupBy == 'OU') {
                    kpiRecord.ouName = (String) result.get('OU_NAME__c');
                } else if (request.groupBy == 'INDUSTRY') {
                    kpiRecord.industry = (String) result.get('PRIMARY_INDUSTRY__c');
                }
                
                kpiRecords.add(kpiRecord);
            }
            
            response.success = true;
            response.message = 'Successfully retrieved ' + kpiRecords.size() + ' distinct values';
            response.totalRecordCount = kpiRecords.size();
            response.kpiRecords = kpiRecords;
            response.analysisSummary = generateDistinctSummary(kpiRecords, request);
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Get distinct values failed: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Distinct Error: ' + e.getStackTraceString());
        }
        
        return response;
    }
    
    private static String buildSearchQuery(Request request) {
        String soql = 'SELECT Id, FULL_NAME__c, WORK_LOCATION_COUNTRY__c, OU_NAME__c, PRIMARY_INDUSTRY__c, RAMP_STATUS__c, ';
        
        // Add KPI fields based on time frame
        if (request.timeFrame == 'CURRENT') {
            soql += 'CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, CQ_ACV__c, CQ_PG__c ';
        } else if (request.timeFrame == 'PREVIOUS') {
            soql += 'PQ_CUSTOMER_MEETING__c, PQ_CALL_CONNECT__c, PQ_ACV__c, PQ_PG__c ';
        }
        
        soql += 'FROM AGENT_OU_PIPELINE_V2__c WHERE Id != null ';
        
        // Add filters
        if (String.isNotBlank(request.OuName)) {
            soql += 'AND OU_NAME__c = \'' + String.escapeSingleQuotes(request.OuName) + '\' ';
        }
        if (String.isNotBlank(request.WorkLocationCountry)) {
            soql += 'AND WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(request.WorkLocationCountry) + '\' ';
        }
        if (String.isNotBlank(request.PrimaryIndustry)) {
            soql += 'AND PRIMARY_INDUSTRY__c = \'' + String.escapeSingleQuotes(request.PrimaryIndustry) + '\' ';
        }
        if (String.isNotBlank(request.RampStatus)) {
            soql += 'AND RAMP_STATUS__c = \'' + String.escapeSingleQuotes(request.RampStatus) + '\' ';
        }
        
        // Add custom filter criteria
        if (String.isNotBlank(request.filterCriteria)) {
            soql += 'AND (' + request.filterCriteria + ') ';
        }
        
        // Add limit
        if (request.recordLimit != null && request.recordLimit > 0) {
            soql += 'LIMIT ' + request.recordLimit;
        }
        
        return soql;
    }
    
    private static String buildCountQuery(Request request) {
        String soql = 'SELECT ';
        String groupByField = '';
        
        // Add group by field and determine the field name
        if (request.groupBy == 'RAMP_STATUS') {
            soql += 'RAMP_STATUS__c, ';
            groupByField = 'RAMP_STATUS__c';
        } else if (request.groupBy == 'COUNTRY') {
            soql += 'WORK_LOCATION_COUNTRY__c, ';
            groupByField = 'WORK_LOCATION_COUNTRY__c';
        } else if (request.groupBy == 'OU') {
            soql += 'OU_NAME__c, ';
            groupByField = 'OU_NAME__c';
        } else if (request.groupBy == 'INDUSTRY') {
            soql += 'PRIMARY_INDUSTRY__c, ';
            groupByField = 'PRIMARY_INDUSTRY__c';
        } else {
            // This should not happen due to validation, but provide a safe fallback
            throw new IllegalArgumentException('Invalid groupBy value: ' + request.groupBy);
        }
        
        soql += 'COUNT(Id) recordCount FROM AGENT_OU_PIPELINE_V2__c WHERE Id != null ';
        
        // Add filters
        if (String.isNotBlank(request.OuName)) {
            soql += 'AND OU_NAME__c = \'' + String.escapeSingleQuotes(request.OuName) + '\' ';
        }
        if (String.isNotBlank(request.WorkLocationCountry)) {
            soql += 'AND WORK_LOCATION_COUNTRY__c = \'' + String.escapeSingleQuotes(request.WorkLocationCountry) + '\' ';
        }
        if (String.isNotBlank(request.PrimaryIndustry)) {
            soql += 'AND PRIMARY_INDUSTRY__c = \'' + String.escapeSingleQuotes(request.PrimaryIndustry) + '\' ';
        }
        if (String.isNotBlank(request.RampStatus)) {
            soql += 'AND RAMP_STATUS__c = \'' + String.escapeSingleQuotes(request.RampStatus) + '\' ';
        }
        
        // Add custom filter criteria
        if (String.isNotBlank(request.filterCriteria)) {
            soql += 'AND (' + request.filterCriteria + ') ';
        }
        
        // Add proper GROUP BY clause
        soql += 'GROUP BY ' + groupByField + ' ORDER BY COUNT(Id) DESC';
        
        return soql;
    }
    
    private static String buildDistinctQuery(Request request) {
        String soql = 'SELECT ';
        
        // Add distinct field
        if (request.groupBy == 'RAMP_STATUS') {
            soql += 'RAMP_STATUS__c FROM AGENT_OU_PIPELINE_V2__c WHERE RAMP_STATUS__c != null ';
        } else if (request.groupBy == 'COUNTRY') {
            soql += 'WORK_LOCATION_COUNTRY__c FROM AGENT_OU_PIPELINE_V2__c WHERE WORK_LOCATION_COUNTRY__c != null ';
        } else if (request.groupBy == 'OU') {
            soql += 'OU_NAME__c FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c != null ';
        } else if (request.groupBy == 'INDUSTRY') {
            soql += 'PRIMARY_INDUSTRY__c FROM AGENT_OU_PIPELINE_V2__c WHERE PRIMARY_INDUSTRY__c != null ';
        }
        
        soql += 'GROUP BY ';
        
        // Add group by field
        if (request.groupBy == 'RAMP_STATUS') {
            soql += 'RAMP_STATUS__c ORDER BY RAMP_STATUS__c';
        } else if (request.groupBy == 'COUNTRY') {
            soql += 'WORK_LOCATION_COUNTRY__c ORDER BY WORK_LOCATION_COUNTRY__c';
        } else if (request.groupBy == 'OU') {
            soql += 'OU_NAME__c ORDER BY OU_NAME__c';
        } else if (request.groupBy == 'INDUSTRY') {
            soql += 'PRIMARY_INDUSTRY__c ORDER BY PRIMARY_INDUSTRY__c';
        }
        
        return soql;
    }
    
    private static String generateAnalysisSummary(List<KPIRecord> records, Request request) {
        if (records.isEmpty()) {
            return 'No records found matching the criteria.';
        }
        
        String summary = 'Analysis Summary:\n';
        summary += '- Total Records: ' + records.size() + '\n';
        summary += '- Metric: ' + request.metricKey + '\n';
        summary += '- Time Frame: ' + request.timeFrame + '\n';
        summary += '- Group By: ' + request.groupBy + '\n';
        
        // Calculate totals
        Decimal totalMeetings = 0;
        Decimal totalCalls = 0;
        Decimal totalACV = 0;
        Decimal totalPG = 0;
        
        for (KPIRecord record : records) {
            totalMeetings += record.meetings != null ? record.meetings : 0;
            totalCalls += record.calls != null ? record.calls : 0;
            totalACV += record.acv != null ? record.acv : 0;
            totalPG += record.pipelineGenerated != null ? record.pipelineGenerated : 0;
        }
        
        summary += '- Total Meetings: ' + totalMeetings + '\n';
        summary += '- Total Calls: ' + totalCalls + '\n';
        summary += '- Total ACV: ' + totalACV + '\n';
        summary += '- Total Pipeline Generated: ' + totalPG + '\n';
        
        return summary;
    }
    
    private static String generateCountSummary(List<KPIRecord> records, Request request) {
        if (records.isEmpty()) {
            return 'No groups found matching the criteria.';
        }
        
        String summary = 'Count Summary:\n';
        summary += '- Total Groups: ' + records.size() + '\n';
        summary += '- Grouped By: ' + request.groupBy + '\n';
        
        return summary;
    }
    
    private static String generateDistinctSummary(List<KPIRecord> records, Request request) {
        if (records.isEmpty()) {
            return 'No distinct values found matching the criteria.';
        }
        
        String summary = 'Distinct Values Summary:\n';
        summary += '- Total Distinct Values: ' + records.size() + '\n';
        summary += '- Field: ' + request.groupBy + '\n';
        
        return summary;
    }
    
    /**
     * @description Populate roster data from Learner_Profile__c using existing pattern
     * @param kpiRecords List of KPI records to populate
     */
    private static void populateRosterData(List<KPIRecord> kpiRecords) {
        if (kpiRecords == null || kpiRecords.isEmpty()) {
            return;
        }
        
        try {
            // Collect all AE names for lookup
            Set<String> aeNames = new Set<String>();
            for (KPIRecord kpi : kpiRecords) {
                if (String.isNotBlank(kpi.aeName)) {
                    aeNames.add(kpi.aeName);
                }
            }
            
            if (aeNames.isEmpty()) {
                return;
            }
            
            // Look up Learner_Profile__c records by Name field
            Map<String, Learner_Profile__c> profileMap = new Map<String, Learner_Profile__c>();
            List<Learner_Profile__c> profiles = [
                SELECT Id, Name, Primary_Email__c, Manager__c, Manager_Email__c,
                       Work_Location_Country__c, OU_Name__c, Job_Family__c, 
                       Division__c, Is_FLM__c, FTE__c
                FROM Learner_Profile__c
                WHERE Name IN :aeNames
                AND Status__c = 'Active'
            ];
            
            for (Learner_Profile__c profile : profiles) {
                profileMap.put(profile.Name, profile);
            }
            
            // Populate roster data for each KPI record
            for (KPIRecord kpi : kpiRecords) {
                if (String.isNotBlank(kpi.aeName) && profileMap.containsKey(kpi.aeName)) {
                    Learner_Profile__c profile = profileMap.get(kpi.aeName);
                    // Populate roster fields from profile
                    kpi.email = profile.Primary_Email__c;
                    kpi.managerName = profile.Manager__c;
                    kpi.managerEmail = profile.Manager_Email__c;
                    kpi.jobFamily = profile.Job_Family__c;
                    kpi.division = profile.Division__c;
                    kpi.isFLM = profile.Is_FLM__c;
                    kpi.isFTE = profile.FTE__c;
                }
            }
            
        } catch (Exception e) {
            System.debug('Error populating roster data: ' + e.getMessage());
        }
    }
}