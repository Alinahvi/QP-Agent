/**
 * TEMPLATE SERVICE (Business Logic)
 *
 * 1) Template Type: Handler/Service template. This is the Service layer.
 * 2) Business Logic Location: HERE. This class performs permission checks, DML, queries,
 *    duplicate checks, search logic (including optional fuzzy fallback), and result messaging.
 * 3) Important Code:
 *    - IMPORTANT: fuzzyRankAndSort(...) and the tokenized fallback in searchAudiences(...).
 *    - IMPORTANT: consistent messages for limits (default/custom), no-criteria, and zero results.
 * 4) Hardcoded Values:
 *    - HARDCODED: DEFAULT_RECORD_LIMIT = 50 (safe default when callers omit a limit).
 *    - HARDCODED: FUZZY_CANDIDATE_LIMIT and TOKEN_MATCH_LIMIT protect CPU.
 *    - HARDCODED: STOP_WORDS = {'audience','test'} reduce noise in fuzzy search.
 * 5) Plain Language: Think of this as the "engine" that does the real work for audiences.
 *
 * Key fields returned: Id, Name, Created/LastModified, and CreatedBy/LastModifiedBy names.
 *
 * @version 2.9
 */
public with sharing class FRAGENTAudienceService  {

    // Maximum records to consider when performing fuzzy matching
    private static final Integer FUZZY_CANDIDATE_LIMIT = 200;

    // Hard ceiling for token comparisons during fuzzy ranking to avoid CPU limits
    private static final Integer TOKEN_MATCH_LIMIT = 10000;
    // Minimum acceptable fuzzy score threshold
    private static final Decimal FUZZY_MATCH_THRESHOLD = 0.4;

    // Default record limit when none specified
    private static final Integer DEFAULT_RECORD_LIMIT = 50;

    @TestVisible private static String testCountQueryOverride;

    // HARDCODED: Ensures exact matches rank above all other fuzzy results
    private static final Integer EXACT_MATCH_SCORE = 2147483647;

    // HARDCODED: Regex to split search terms and names on whitespace, hyphens, slashes, or underscores.
    private static final String TOKEN_SPLIT_REGEX = '[\\s\\-\\/_]+';
    // HARDCODED: Stop words ignored during fuzzy matching (reduce noise)
    // This helps prevent broad terms (e.g., "test" or "audience") from introducing
    // unrelated records into fallback searches.
    private static final Set<String> STOP_WORDS = new Set<String>{ 'audience', 'test' };

    /**
     * Tokenize a search term using the shared fuzzy utility and local STOP_WORDS.
     */
    private static Set<String> tokenize(String input) {
        if (String.isBlank(input)) {
            return new Set<String>();
        }
        Set<String> toks = AgentCore_Fuzzy.tokenize(input, STOP_WORDS);
        return toks;
    }

    /**
     * Break a string into lowercase tokens while removing punctuation and common stop words.
     */
    private static List<Audience__c> fuzzyRankAndSort(List<Audience__c> candidates, String searchTerm) {
        if (candidates == null || candidates.isEmpty() || String.isBlank(searchTerm)) {
            return candidates;
        }

        List<String> names = new List<String>();
        for (Audience__c aud : candidates) {
            names.add(aud == null ? null : aud.Name);
        }

        List<AgentCore_Fuzzy.CandidateScore> scores = AgentCore_Fuzzy.scoreTokens(
            names,
            searchTerm,
            STOP_WORDS,
            TOKEN_MATCH_LIMIT,
            FUZZY_MATCH_THRESHOLD
        );

        List<Audience__c> sorted = new List<Audience__c>();
        for (AgentCore_Fuzzy.CandidateScore score : scores) {
            if (score.index != null && score.index >= 0 && score.index < candidates.size()) {
                sorted.add(candidates[score.index]);
            }
        }
        return sorted;
    }

    // Lightweight representation of an Audience Member with only the required fields.
    public class AudienceMemberSummary {
        @AuraEnabled public Id audienceMemberId;
        @AuraEnabled public Id learnerProfileId;
        @AuraEnabled public String learnerName;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastModifiedDate;

        public AudienceMemberSummary(Audience_Member__c am) {
            this.audienceMemberId = am.Id;
            this.learnerProfileId = am.Learner_Profile__c;
            this.learnerName = am.Learner_Profile__r != null ? am.Learner_Profile__r.Name : null;
            this.createdDate = am.CreatedDate;
            this.lastModifiedDate = am.LastModifiedDate;
        }
    }

    // Combined DTO containing an Audience record, its member count, and optional members list.
    public class AudienceDetails {
        @AuraEnabled public Audience__c audience;
        @AuraEnabled public Id audienceId;
        @AuraEnabled public Integer memberCount;
        @AuraEnabled public List<AudienceMemberSummary> members;

        public AudienceDetails(Audience__c audience, Integer memberCount, List<AudienceMemberSummary> members) {
            this.audienceId = audience == null ? null : audience.Id;
            this.audience = audience == null
                ? null
                : audience.clone(false, true, true, true);
            this.memberCount = memberCount;
            this.members = members;
        }
    }

    // Result DTO for retrieval operations exposing total count and audience details.
    public class AudienceResult extends AgentCore_Result { 
        @AuraEnabled public Integer totalCount; 
        @AuraEnabled public List<AudienceDetails> audienceDetails; 
        @AuraEnabled public Boolean permissionDenied; 
        @AuraEnabled public String code; 

        public AudienceResult(Boolean success, List<SObject> records,
                Integer totalCount,
                List<AudienceDetails> audienceDetails,
                List<String> errors) {
            this(success, records, totalCount, audienceDetails, errors, null);
        }

        public AudienceResult(Boolean success, List<SObject> records,
                Integer totalCount,
                List<AudienceDetails> audienceDetails,
                List<String> errors,
                String message) {
            super(success, records, errors, message); 
            this.totalCount = totalCount; 
            this.audienceDetails = audienceDetails == null 
                ? new List<AudienceDetails>() 
                : audienceDetails; 
            this.permissionDenied = false; 
            this.code = null; 
        } 
    } 

    /**
     * @description Unified retrieval for Audience records by Id or search criteria.
     */
    public static AudienceResult retrieveAudiences(
            Id audienceId,
            String audienceName,
            String dateFieldToSearch,
            String dateLiteral,
            Date startDate,
            Date endDate,
            Id createdByUserId,
            Integer recordLimit) {

        String processedAudienceName = audienceName;
        String finalDateLiteral = dateLiteral;
        Date finalStartDate = startDate;
        Date finalEndDate = endDate;

        if (String.isNotBlank(processedAudienceName)) {
            // Preserve characters like hyphens or slashes so direct searches can match them.
            processedAudienceName = processedAudienceName.normalizeSpace();
        }

        try {
            AgentCore_Permissions.requireAction(AgentCore_ActionKeys.Audience.readKey());
        } catch (AgentCore_Permissions.PermissionException pe) {
            String msg = pe.getMessage();
            AudienceResult ar = new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
            ar.permissionDenied = true;
            ar.code = 'PERMISSION_DENIED';
            return ar;
        } catch (Exception e) {
            String msg = e.getMessage();
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }

        boolean noCriteria = audienceId == null && String.isBlank(processedAudienceName) && String.isBlank(finalDateLiteral)
            && finalStartDate == null && finalEndDate == null && createdByUserId == null;
        Integer limitSize = (recordLimit == null || recordLimit <= 0) ? DEFAULT_RECORD_LIMIT : recordLimit;

        AudienceResult result;
        if (audienceId != null) {
            result = getAudienceById(audienceId);
        } else {
            result = searchAudiences(noCriteria ? null : processedAudienceName, dateFieldToSearch, finalDateLiteral,
                finalStartDate, finalEndDate, createdByUserId, limitSize);

            if (result.success && result.totalCount == 0 && String.isNotBlank(processedAudienceName)) {
                Pattern datePattern = Pattern.compile('(\\b\\d{1,2}/\\d{1,2}/(\\d{2}|\\d{4})\\b)');
                Matcher dateMatcher = datePattern.matcher(processedAudienceName);
                if (dateMatcher.find()) {
                    String dateStr = dateMatcher.group(1);
                    try {
                        String[] dateParts = dateStr.split('/');
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        if (year < 100) {
                            year += 2000;
                        }
                        Date parsedDate = Date.newInstance(year, month, day);
                        finalStartDate = parsedDate;
                        finalEndDate = parsedDate;
                        processedAudienceName = processedAudienceName.replace(dateStr, '').trim();
                        processedAudienceName = processedAudienceName.normalizeSpace();
                        finalDateLiteral = null;
                        result = searchAudiences(processedAudienceName, dateFieldToSearch, finalDateLiteral,
                            finalStartDate, finalEndDate, createdByUserId, limitSize);
                    } catch (Exception e) {
                        System.debug('Could not parse date from search term: ' + dateStr + '. Error: ' + e.getMessage());
                    }
                }
            }
        }

        if (!result.success) {
            result.message = String.join(result.errors, '; ');
            return result;
        }

        if (result.totalCount > limitSize) {
            if (recordLimit == null || recordLimit <= 0) {
                result.message = 'default limit of ' + DEFAULT_RECORD_LIMIT + ' reached';
            } else {
                result.message = 'custom limit of ' + limitSize + ' reached';
            }
        } else if (result.totalCount == 0) {
            result.message = 'No audience records found matching the criteria.';
        } else if (audienceId != null) {
            result.message = 'Audience retrieved successfully.';
        } else if (noCriteria) {
            result.message = 'No criteria specified. Here are the last ' + limitSize +
                ' modified records. Ask for clarification to refine your request.';
        } else {
            result.message = 'Retrieve successful. Found ' + result.totalCount + ' total audience(s).';
        }
        return result;
    }

    /**
     * @description Retrieves an Audience record by ID.
     */
    private static AudienceResult getAudienceById(Id audienceId) {
        if (audienceId == null) {
            String msg = 'Audience ID cannot be null.';
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }

        try {
            AgentCore_Permissions.checkCrudRead(Audience__c.SObjectType);
            AgentCore_Permissions.checkFlsReadable(
                Audience__c.SObjectType,
                new Set<String>{ 'Name', 'CreatedById', 'LastModifiedById' }
            );
        } catch (Exception e) {
            String msg = e.getMessage();
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }

        System.AccessLevel mode = (Test.isRunningTest() && AgentCore_Permissions.TEST_BYPASS)
            ? AccessLevel.SYSTEM_MODE : AccessLevel.USER_MODE;
        Boolean bypass = (mode == AccessLevel.SYSTEM_MODE);
        String getSoql = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id = :audienceId LIMIT 1';
        Map<String, Object> getBinds = new Map<String, Object>{ 'audienceId' => audienceId };
        String securedGetSoql = bypass ? getSoql : AgentCore_SafeQuery.secureForAccessLevel(getSoql, mode);
        List<Audience__c> audiences = (List<Audience__c>)Database.queryWithBinds(securedGetSoql, getBinds, mode);

        if (audiences.isEmpty()) {
            String msg = 'Audience not found with ID: ' + audienceId;
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }

        Audience__c aud = audiences[0];

        Integer memberCount = 0;
        List<AudienceMemberSummary> members = new List<AudienceMemberSummary>();
        try {
            String memSoql = 'SELECT Id, Audience__c, Learner_Profile__c, Learner_Profile__r.Name, Learner_Profile__r.Division__c, Learner_Profile__r.AE_Type__c, Learner_Profile__r.Role_Level_4__c, CreatedDate, LastModifiedDate FROM Audience_Member__c WHERE Audience__c = :audienceId';
            Map<String, Object> mBinds = new Map<String, Object>{ 'audienceId' => audienceId };
            String securedMemSoql = bypass ? memSoql : AgentCore_SafeQuery.secureForAccessLevel(memSoql, mode);
            List<Audience_Member__c> mems = (List<Audience_Member__c>)Database.queryWithBinds(securedMemSoql, mBinds, mode);
            for (Audience_Member__c am : mems) {
                memberCount++;
                members.add(new AudienceMemberSummary(am));
            }
        } catch (Exception ignoreMemberQuery) {
            // If the relationship or object is unavailable for the running user, proceed without members
        }

        AudienceDetails details = new AudienceDetails(aud, memberCount, members);
        List<AudienceDetails> detailList = new List<AudienceDetails>{details};
        List<SObject> auds = new List<SObject>{aud};

        return new AudienceResult(true, auds, 1, detailList,
            new List<String>(), 'Audience retrieved successfully.');
    }

    /**
     * @description Creates multiple Audience records.
     */
    public static AgentCore_Result createAudiences(List<Audience__c> audiences) {
        try {
            AgentCore_Permissions.requireAction(AgentCore_ActionKeys.Audience.createKey());
            AgentCore_Permissions.checkCrudCreate(Audience__c.SObjectType);
            AgentCore_Permissions.checkFlsUpdateable(Audience__c.SObjectType, new Set<String>{ 'Name', 'RecordTypeId' });
        } catch (Exception e) {
            String msg = e.getMessage();
            return new AgentCore_Result(false, null, new List<String>{msg}, msg);
        }

        if (audiences == null || audiences.isEmpty()) {
            String msg = 'No audience records to create.';
            return new AgentCore_Result(false, new List<SObject>(), new List<String>{msg}, msg);
        }

        List<Audience__c> validAudiences = new List<Audience__c>();
        List<String> errorMessages = new List<String>();

        for (Audience__c aud : audiences) {
            if (String.isBlank(aud.Name)) {
                errorMessages.add('Error creating audience: Name is required');
            } else {
                validAudiences.add(aud);
            }
        }

        if (!validAudiences.isEmpty()) {
            Set<String> namesToCheck = new Set<String>();
            for (Audience__c a : validAudiences) if (String.isNotBlank(a.Name)) namesToCheck.add(a.Name.trim());
            List<SObject> duplicates = AgentCore_Dedupe.findByNames('Audience__c', namesToCheck);
            if (!duplicates.isEmpty()) {
                String msg = 'Unable to complete this action because a duplicate name is found, please rename or modify the existing name.';
                errorMessages.add(msg);
                return new AgentCore_Result(false, duplicates, errorMessages, msg);
            }
        }

        // Always assign the "Manual" record type when creating audiences.
        // The developer name for this record type is 'Cohort'.
        Id manualRtId;
        try {
            manualRtId = Schema.SObjectType.Audience__c
                .getRecordTypeInfosByDeveloperName()
                .get('Cohort')
                .getRecordTypeId();
        } catch (Exception e) {
            manualRtId = null;
        }

        if (manualRtId == null) {
            try {
                // SOQL fallback for environments where describe metadata is incomplete
                manualRtId = [
                    SELECT Id FROM RecordType
                    WHERE SObjectType = 'Audience__c' AND DeveloperName = 'Cohort'
                    LIMIT 1
                ].Id;
            } catch (Exception ignoreRt) {
                // leave null if not present; creation will proceed without RecordType assignment
            }
        }

        if (manualRtId != null) {
            for (Audience__c aud : validAudiences) {
                aud.RecordTypeId = manualRtId;
            }
        }

        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.insert(validAudiences, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error creating audience: ' + err.getMessage());
                }
            }
        }

        List<Audience__c> createdAudiences = successIds.isEmpty() ? new List<Audience__c>() :
            [SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name,
                LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :successIds WITH SECURITY_ENFORCED];

        Boolean success = errorMessages.isEmpty();
        String msg = success ? 'Audience created successfully.' : String.join(errorMessages, '; ');
        return new AgentCore_Result(success, createdAudiences, errorMessages, msg);
    }

    /**
     * @description Updates multiple Audience records.
     */
    public static AgentCore_Result updateAudiences(List<Audience__c> audiences) {
        try {
            AgentCore_Permissions.requireAction(AgentCore_ActionKeys.Audience.updateKey());
            AgentCore_Permissions.checkCrudUpdate(Audience__c.SObjectType);
            AgentCore_Permissions.checkFlsUpdateable(Audience__c.SObjectType, new Set<String>{ 'Name' });
        } catch (Exception e) {
            String msg = e.getMessage();
            return new AgentCore_Result(false, null, new List<String>{msg}, msg);
        }

        if (audiences == null || audiences.isEmpty()) {
            String msg = 'No audience records to update.';
            return new AgentCore_Result(false, new List<SObject>(), new List<String>{msg}, msg);
        }

        List<Audience__c> validAudiences = new List<Audience__c>();
        List<String> errorMessages = new List<String>();
        for (Audience__c aud : audiences) {
            if (aud.Id == null || String.isBlank(aud.Name)) {
                errorMessages.add('Error updating audience: Id and Name are required');
            } else {
                validAudiences.add(aud);
            }
        }

        // Verify that each provided Id exists before attempting the update
        Set<Id> idsToCheck = new Set<Id>();
        for (Audience__c aud : validAudiences) idsToCheck.add(aud.Id);
        Map<Id, Audience__c> existing = new Map<Id, Audience__c>([
            SELECT Id FROM Audience__c WHERE Id IN :idsToCheck WITH SECURITY_ENFORCED
        ]);

        List<Audience__c> toUpdate = new List<Audience__c>();
        Set<Id> toUpdateIds = new Set<Id>();
        for (Audience__c aud : validAudiences) {
            if (existing.containsKey(aud.Id)) {
                toUpdate.add(aud);
                toUpdateIds.add(aud.Id);
            } else {
                errorMessages.add('Audience not found: ' + aud.Id);
            }
        }

        // Prevent duplicate names on update:
        // 1) Block when two or more records in the same request share the same target Name
        if (!toUpdate.isEmpty()) {
            Map<String, Set<Id>> nameToIds = new Map<String, Set<Id>>();
            for (Audience__c aud : toUpdate) {
                String nm = aud.Name == null ? '' : aud.Name.trim();
                if (!nameToIds.containsKey(nm)) {
                    nameToIds.put(nm, new Set<Id>());
                }
                nameToIds.get(nm).add(aud.Id);
            }
            for (String nm : nameToIds.keySet()) {
                if (String.isNotBlank(nm) && nameToIds.get(nm).size() > 1) {
                    String msg = 'Unable to complete this action because a duplicate name is found, please rename or modify the existing name.';
                    errorMessages.add(msg);
                    return new AgentCore_Result(false, new List<SObject>(), errorMessages, msg);
                }
            }

            // 2) Block when any other Audience__c already uses one of the target Names
            Set<String> namesToCheck = new Set<String>();
            for (Audience__c a : toUpdate) if (String.isNotBlank(a.Name)) namesToCheck.add(a.Name.trim());
            List<SObject> duplicates = AgentCore_Dedupe.findByNames('Audience__c', namesToCheck);
            if (!duplicates.isEmpty()) {
                // Filter out the same records being updated; we only care about conflicts with OTHER records
                List<SObject> conflicting = new List<SObject>();
                for (SObject d : duplicates) {
                    Id dupId = (Id)d.get('Id');
                    if (!toUpdateIds.contains(dupId)) {
                        conflicting.add(d);
                    }
                }
                if (!conflicting.isEmpty()) {
                    String msg = 'Unable to complete this action because a duplicate name is found, please rename or modify the existing name.';
                    errorMessages.add(msg);
                    return new AgentCore_Result(false, conflicting, errorMessages, msg);
                }
            }
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] srs = Database.update(toUpdate, false);
            for (Database.SaveResult sr : srs) {
                if (sr.isSuccess()) {
                    // Add to list of successful updates
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        errorMessages.add('Error updating audience ' + sr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }

        List<Audience__c> updatedAudiences = toUpdateIds.isEmpty() ? new List<Audience__c>() :
            [SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name,
                LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :toUpdateIds WITH SECURITY_ENFORCED];

        Boolean success = errorMessages.isEmpty();
        String msg = success ? 'Audience updated successfully.' : String.join(errorMessages, '; ');
        return new AgentCore_Result(success, updatedAudiences, errorMessages, msg);
    }
    
    /**
     * @description Deletes multiple Audience records by their IDs.
     */
    public static AgentCore_Result deleteAudiences(List<Id> ids) {
        try {
            AgentCore_Permissions.requireAction(AgentCore_ActionKeys.Audience.deleteKey());
            AgentCore_Permissions.checkCrudDelete(Audience__c.SObjectType);
        } catch (Exception e) {
            String msg = e.getMessage();
            return new AgentCore_Result(false, null, new List<String>{msg}, msg);
        }

        if (ids == null || ids.isEmpty()) {
            String msg = 'Audience ID is required for Delete action.';
            return new AgentCore_Result(false, null, new List<String>{msg}, msg);
        }

        List<Audience__c> toDelete = [SELECT Id FROM Audience__c WHERE Id IN :ids WITH SECURITY_ENFORCED];
        if (toDelete.isEmpty()) {
            String msg = 'No matching audiences found to delete.';
            return new AgentCore_Result(true, null, new List<String>{msg}, msg);
        }
        
        Database.DeleteResult[] drs = Database.delete(toDelete, false);

        List<String> errorMessages = new List<String>();
        for(Database.DeleteResult dr : drs){
            if(!dr.isSuccess()){
                for(Database.Error err : dr.getErrors()){
                    errorMessages.add('Error deleting audience ' + dr.getId() + ': ' + err.getMessage());
                }
            }
        }

        Boolean success = errorMessages.isEmpty();
        String msg = success ? 'Audience deleted successfully.' : String.join(errorMessages, '; ');
        return new AgentCore_Result(success, null, errorMessages, msg);
    }

    /**
     * @description Searches for audiences by name, creator, or date, with priority given to date searches.
     * @param audienceName Exact or partial Audience name to match.
     * @param dateFieldToSearch The specific date field to search (CreatedDate or LastModifiedDate).
     * @param dateLiteral A date literal string for date filtering.
     * @param startDate The start date for date range filtering.
     * @param endDate The end date for date range filtering.
     * @param createdByUserId Filter results to audiences created by this user.
     * @param recordLimit The maximum number of records to return.
     * @return An AudienceResult DTO containing the records page and the total count.
     */
    private static AudienceResult searchAudiences(
        String audienceName,
        String dateFieldToSearch,
        String dateLiteral,
        Date startDate,
        Date endDate,
        Id createdByUserId,
        Integer recordLimit
    ) {
        // CRUD/FLS checks for Audience__c reads 
        try { 
            AgentCore_Permissions.checkCrudRead(Audience__c.SObjectType); 
            AgentCore_Permissions.checkFlsReadable(Audience__c.SObjectType, new Set<String>{ 'Name', 'CreatedDate', 'LastModifiedDate', 'CreatedById', 'LastModifiedById' }); 
        } catch (AgentCore_Permissions.PermissionException pe) { 
            String msg = pe.getMessage(); 
            AudienceResult ar = new AudienceResult(false, null, 0, new List<AudienceDetails>(), new List<String>{ msg }, msg); 
            ar.permissionDenied = true; 
            ar.code = 'PERMISSION_DENIED'; 
            return ar; 
        } catch (Exception e) { 
            String msg = e.getMessage(); 
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(), new List<String>{ msg }, msg); 
        } 
        // Default the date field if not specified
        String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
        Set<String> validDateFields = new Set<String>{'CreatedDate', 'LastModifiedDate'};

        if (!validDateFields.contains(targetDateField)) {
            String msg = 'Invalid date field specified: ' + targetDateField;
            return new AudienceResult(false, null, 0,
                new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }

        List<String> whereClauses = new List<String>();
        Map<Id, List<Audience_Member__c>> memberCache = null;
        Map<String, Object> bindVars = new Map<String, Object>();
        String searchClause;
        if (createdByUserId != null) {
            whereClauses.add('CreatedById = :createdByUserId');
            bindVars.put('createdByUserId', createdByUserId);
        }

        try {
            if (String.isNotBlank(dateLiteral)) {
                String dateClause = AgentCore_Dates.parseDateFilter(targetDateField, dateLiteral);
                whereClauses.add('(' + dateClause + ')');
            } else if (startDate != null || endDate != null) {
                Date queryEndDate = endDate;
                if (startDate != null && endDate != null && startDate == endDate) {
                    queryEndDate = endDate.addDays(1);
                }

                String rangeClause = AgentCore_SafeQuery.buildDateRangeClause(targetDateField, startDate != null ? 'startDate' : null, queryEndDate != null ? 'endDate' : null);
                if (startDate != null) bindVars.put('startDate', startDate);
                if (queryEndDate != null) bindVars.put('endDate', queryEndDate);

                whereClauses.add('(' + rangeClause + ')');
            } else if (String.isNotBlank(audienceName)) {
                // Only perform a name search if the term contains non-punctuation characters
                String alnumCheck = audienceName.replaceAll('[^a-zA-Z0-9]', '');
                if (!String.isBlank(alnumCheck)) {
                    String escapedName = AgentCore_Text.escapeLike(audienceName);
                    // Use the default SOQL escape behavior. The escapeLike utility
                    // method prefixes any wildcard characters with a backslash,
                    // so we don't need an explicit ESCAPE clause.
                    searchClause = 'Name LIKE :queryTerm';
                    whereClauses.add(searchClause);
                    bindVars.put('queryTerm', '%' + escapedName + '%');
                }
            }
        } catch (Exception e) {
            String msg = 'Search failed due to invalid input: ' + e.getMessage();
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }

        String finalWhereClause = whereClauses.isEmpty() ? '' : 'WHERE ' + String.join(whereClauses, ' AND ');

        // Prefer exact name match when a specific name is provided (helps names containing dates/special characters)
        if (String.isNotBlank(audienceName) && !(Test.isRunningTest() && AgentCore_Permissions.TEST_BYPASS)) { 
            try {
                String orderByExact = AgentCore_SafeQuery.orderByFrom(new Map<String, String>(), new Set<String>{ 'LastModifiedDate', 'CreatedDate', 'Name', 'Id' }, 'LastModifiedDate DESC, Id ASC'); 
                AgentCore_SafeQuery.SoqlSpec exactSpec = AgentCore_SafeQuery.builder(); 
                exactSpec.type = Audience__c.SObjectType; 
                exactSpec.selectFields.add(Audience__c.Id); 
                exactSpec.selectFields.add(Audience__c.Name); 
                exactSpec.selectFields.add(Audience__c.CreatedDate); 
                exactSpec.selectFields.add(Audience__c.LastModifiedDate); 
                exactSpec.selectFields.add(Audience__c.CreatedById); 
                exactSpec.selectFields.add(Audience__c.LastModifiedById); 
                exactSpec.whereClauses.add('Name = :exactName'); 
                exactSpec.orderBy = orderByExact; 
                exactSpec.limitSize = recordLimit; 
                String exactSoql = AgentCore_SafeQuery.soql(exactSpec); 
                Boolean bypass = (Test.isRunningTest() && AgentCore_Permissions.TEST_BYPASS); 
                System.AccessLevel mode = AccessLevel.USER_MODE; 
                String securedExactSoql = bypass ? exactSoql : AgentCore_SafeQuery.secureForAccessLevel(exactSoql, mode); 
                List<Audience__c> exactMatches = Database.queryWithBinds(securedExactSoql, new Map<String, Object>{ 'exactName' => audienceName }, mode); 

                if (!exactMatches.isEmpty()) {
                    Set<Id> aIds = new Set<Id>();
                    for (Audience__c a : exactMatches) aIds.add(a.Id);
                    Map<Id, List<Audience_Member__c>> mems = new Map<Id, List<Audience_Member__c>>();
                    try {
                        for (Audience_Member__c am : [SELECT Id, Audience__c, Learner_Profile__c, Learner_Profile__r.Name, CreatedDate, LastModifiedDate FROM Audience_Member__c WHERE Audience__c IN :aIds]) {
                            if (!mems.containsKey(am.Audience__c)) mems.put(am.Audience__c, new List<Audience_Member__c>());
                            mems.get(am.Audience__c).add(am);
                        }
                    } catch (Exception ignore) {}
                    // Hydrate CreatedBy/LastModifiedBy names
                    if (!aIds.isEmpty()) {
                        String enrichExact = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :aIds';
                        Map<String, Object> eb2 = new Map<String, Object>{ 'aIds' => aIds };
                        String securedEnrichExact = bypass ? enrichExact : AgentCore_SafeQuery.secureForAccessLevel(enrichExact, mode);
                        List<Audience__c> enrichedExact = (List<Audience__c>)Database.queryWithBinds(securedEnrichExact, eb2, mode);
                        Map<Id, Audience__c> mapEx = new Map<Id, Audience__c>(enrichedExact);
                        for (Integer i = 0; i < exactMatches.size(); i++) {
                            Audience__c a = exactMatches[i];
                            if (mapEx.containsKey(a.Id)) exactMatches[i] = mapEx.get(a.Id);
                        }
                    }

                    List<AudienceDetails> details = new List<AudienceDetails>(); 
                    for (Audience__c aud : exactMatches) {
                        List<AudienceMemberSummary> members = new List<AudienceMemberSummary>();
                        if (mems.containsKey(aud.Id)) {
                            for (Audience_Member__c am : mems.get(aud.Id)) members.add(new AudienceMemberSummary(am));
                        }
                        details.add(new AudienceDetails(aud, members.size(), members));
                    }
                    return new AudienceResult(true, exactMatches, exactMatches.size(), details, new List<String>(), null);
                }
            } catch (Exception e) {
                String msg = 'Search query failed: ' + e.getMessage();
                return new AudienceResult(false, null, 0, new List<AudienceDetails>(), new List<String>{ msg }, msg);
            }
        }
        String fallbackWhereClause = '';
        if (String.isNotBlank(searchClause)) {
            List<String> fallbackClauses = new List<String>();
            for (String clause : whereClauses) {
                if (clause != searchClause) {
                    fallbackClauses.add(clause);
                }
            }
            fallbackWhereClause = fallbackClauses.isEmpty() ? '' : 'WHERE ' + String.join(fallbackClauses, ' AND ');
        }

        String countQuery = 'SELECT COUNT(Id) cnt FROM Audience__c ' + finalWhereClause;
        if (Test.isRunningTest() && testCountQueryOverride != null) {
            countQuery = testCountQueryOverride;
        }
        List<Audience__c> audiences = new List<Audience__c>();
        Integer totalCount = 0;
        String executedQuery = countQuery;
        System.AccessLevel mode = (Test.isRunningTest() && AgentCore_Permissions.TEST_BYPASS)
            ? AccessLevel.SYSTEM_MODE : AccessLevel.USER_MODE;
        Boolean bypass = (mode == AccessLevel.SYSTEM_MODE);
        try {
            String securedCountQuery = bypass ? countQuery : AgentCore_SafeQuery.secureForAccessLevel(countQuery, mode);
            List<AggregateResult> countResults = Database.queryWithBinds(securedCountQuery, bindVars, mode);
            Integer rowCounter = 0;
            for (AggregateResult ar : countResults) {
                rowCounter++;
                if (rowCounter > 1) {
                    String msg = 'Search query failed: multiple count rows returned';
                    return new AudienceResult(false, null, 0, new List<AudienceDetails>(), new List<String>{msg}, msg);
                }
                Object val = ar.get('cnt') != null ? ar.get('cnt') : ar.get('expr0');
                if (val != null) {
                    totalCount = (Integer)val;
                }
            }
            if (totalCount > 0) {
                String orderBy = AgentCore_SafeQuery.orderByFrom(new Map<String, String>(), new Set<String>{ 'LastModifiedDate', 'CreatedDate', 'Name', 'Id' }, 'LastModifiedDate DESC, Id ASC');
                AgentCore_SafeQuery.SoqlSpec spec = AgentCore_SafeQuery.builder();
                spec.type = Audience__c.SObjectType;
                spec.selectFields.add(Audience__c.Id);
                spec.selectFields.add(Audience__c.Name);
                spec.selectFields.add(Audience__c.CreatedDate);
                spec.selectFields.add(Audience__c.LastModifiedDate);
                spec.selectFields.add(Audience__c.CreatedById);
                spec.selectFields.add(Audience__c.LastModifiedById);
                spec.orderBy = orderBy;
                spec.limitSize = recordLimit;
                // We'll manage WITH SECURITY_ENFORCED via secureForAccessLevel(...)
                spec.withSecurity = false;
                for (String c : whereClauses) spec.whereClauses.add(c);
                String mainSoql = AgentCore_SafeQuery.soql(spec);
                executedQuery = mainSoql;
                String securedMainSoql = bypass ? mainSoql : AgentCore_SafeQuery.secureForAccessLevel(mainSoql, mode);
                List<Audience__c> top = (List<Audience__c>)Database.queryWithBinds(securedMainSoql, bindVars, mode);
                // Fetch members separately
                Set<Id> aIds = new Set<Id>();
                for (Audience__c a : top) aIds.add(a.Id);
                if (!aIds.isEmpty()) {
                    Map<Id, List<Audience_Member__c>> membersByAud = new Map<Id, List<Audience_Member__c>>();
                    Boolean memberFetchFailed = false;
                    try {
                        String mSoql = 'SELECT Id, Audience__c, Learner_Profile__c, Learner_Profile__r.Name, CreatedDate, LastModifiedDate FROM Audience_Member__c WHERE Audience__c IN :aIds';
                        Map<String, Object> mBind = new Map<String, Object>{ 'aIds' => aIds };
                        String securedMSoql = bypass ? mSoql : AgentCore_SafeQuery.secureForAccessLevel(mSoql, mode);
                        List<Audience_Member__c> fetched = (List<Audience_Member__c>)Database.queryWithBinds(securedMSoql, mBind, mode);
                        for (Audience_Member__c am : fetched) {
                            if (!membersByAud.containsKey(am.Audience__c)) {
                                membersByAud.put(am.Audience__c, new List<Audience_Member__c>());
                            }
                            membersByAud.get(am.Audience__c).add(am);
                        }
                    } catch (Exception memberEx) {
                        memberFetchFailed = true;
                    }

                    if (memberFetchFailed) {
                        audiences = top;
                    } else {
                        memberCache = membersByAud;
                        audiences = new List<Audience__c>();
                        for (Audience__c a : top) {
                            Audience__c copy = a.clone(true, true, true, true);
                            try {
                                copy.put('Audience_Members__r', membersByAud.containsKey(a.Id) ? membersByAud.get(a.Id) : new List<Audience_Member__c>());
                            } catch (Exception ignoreInvalidRelationship) {
                                // Relationship not defined in org; proceed without embedding members on SObject
                            }
                            audiences.add(copy);
                        }
                    }
                } else {
                    audiences = top;
                }
                    // Enrich with CreatedBy/LastModifiedBy names in the same order 
                    Set<Id> finalIds = new Set<Id>(); 
                    for (Audience__c a : audiences) finalIds.add(a.Id); 
                    if (!finalIds.isEmpty()) { 
                        String enrichSoql = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :finalIds';
                        Map<String, Object> eb = new Map<String, Object>{ 'finalIds' => finalIds };
                        String securedEnrichSoql = bypass ? enrichSoql : AgentCore_SafeQuery.secureForAccessLevel(enrichSoql, mode);
                        List<Audience__c> enriched = (List<Audience__c>)Database.queryWithBinds(securedEnrichSoql, eb, mode);
                        Map<Id, Audience__c> eMap = new Map<Id, Audience__c>(enriched); 
                        List<Audience__c> ordered = new List<Audience__c>(); 
                        for (Audience__c a : audiences) if (eMap.containsKey(a.Id)) ordered.add(eMap.get(a.Id)); 
                        audiences = ordered; 
                    } 
            }

            if (audiences.isEmpty() && String.isNotBlank(audienceName)) {
                // The initial exact/LIKE match failed. Now, let's try a more comprehensive token-based search.
                // This will become the primary search mechanism, leveraging the fuzzy ranking.
                
                Set<String> tokens = tokenize(audienceName);

                if (!tokens.isEmpty()) {
                    Map<String, Object> fallbackBinds = new Map<String, Object>();
                    List<String> tokenClauses = new List<String>();
                    Integer idx = 0;

                    // Build OR clauses for each token and ensure wildcard characters are escaped
                    for (String t : tokens) {
                        idx++;
                        String varName = 'token' + idx;
                        tokenClauses.add('Name LIKE :' + varName);
                        fallbackBinds.put(varName, '%' + AgentCore_Text.escapeLike(t) + '%');
                    }

                    // Rebuild the WHERE clause from scratch for the fallback
                    List<String> finalFallbackClauses = new List<String>();
                    if (createdByUserId != null) {
                        finalFallbackClauses.add('CreatedById = :createdById');
                        fallbackBinds.put('createdById', createdByUserId);
                    }

                    if (!tokenClauses.isEmpty()) {
                        finalFallbackClauses.add('(' + String.join(tokenClauses, ' OR ') + ')');
                    }
                    
                        String fallbackWhere = finalFallbackClauses.isEmpty() ? '' : 'WHERE ' + String.join(finalFallbackClauses, ' AND '); 

                    // We need to re-run the count query with the new broader criteria
                    String fallbackCountQuery = 'SELECT COUNT(Id) cnt FROM Audience__c ' + fallbackWhere;

                    // Re-calculate totalCount based on the broader search and guard against
                    // queries that unexpectedly return multiple rows. Database.countQueryWithBinds
                    // isn't used here to ensure consistent error handling across API versions.
                    Integer fallbackRowCounter = 0;
                    String securedFallbackCount = bypass ? fallbackCountQuery : AgentCore_SafeQuery.secureForAccessLevel(fallbackCountQuery, mode);
                    List<AggregateResult> fallbackCountResults =
                        Database.queryWithBinds(securedFallbackCount, fallbackBinds, mode);
                    for (AggregateResult ar : fallbackCountResults) {
                        fallbackRowCounter++;
                        if (fallbackRowCounter > 1) {
                            String msg = 'Search query failed: multiple count rows returned';
                            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                                new List<String>{msg}, msg);
                        }
                        Object val = ar.get('cnt') != null ? ar.get('cnt') : ar.get('expr0');
                        if (val != null) {
                            totalCount = (Integer)val;
                        }
                    }

                    if (totalCount > 0) {
                        String orderBy2 = AgentCore_SafeQuery.orderByFrom(new Map<String, String>(), new Set<String>{ 'LastModifiedDate', 'CreatedDate', 'Name', 'Id' }, 'LastModifiedDate DESC, Id ASC');
                        AgentCore_SafeQuery.SoqlSpec spec2 = AgentCore_SafeQuery.builder();
                        spec2.type = Audience__c.SObjectType;
                        spec2.selectFields.add(Audience__c.Id);
                        spec2.selectFields.add(Audience__c.Name);
                        spec2.selectFields.add(Audience__c.CreatedDate);
                        spec2.selectFields.add(Audience__c.LastModifiedDate);
                        spec2.selectFields.add(Audience__c.CreatedById);
                        spec2.selectFields.add(Audience__c.LastModifiedById);
                        // Build fallback where from fallbackWhere string by stripping 'WHERE '
                        if (!String.isBlank(fallbackWhere)) spec2.whereClauses.add(fallbackWhere.substring(6));
                        spec2.orderBy = orderBy2;
                        spec2.limitSize = FUZZY_CANDIDATE_LIMIT;
                        spec2.withSecurity = false;
                        String fallbackSoql = AgentCore_SafeQuery.soql(spec2);
                        executedQuery = fallbackSoql;
                        String securedFallbackSoql = bypass ? fallbackSoql : AgentCore_SafeQuery.secureForAccessLevel(fallbackSoql, mode);
                        List<Audience__c> candidates = Database.queryWithBinds(securedFallbackSoql, fallbackBinds, mode);

                        // Rank all candidates from the broader search
                        List<Audience__c> ranked = fuzzyRankAndSort(candidates, audienceName);

                        // Paginate the final, ranked list
                        Integer endIndex = (recordLimit != null && recordLimit > 0) ? Math.min(recordLimit, ranked.size()) : ranked.size();
                        List<Audience__c> paginated = new List<Audience__c>();
                        for (Integer i = 0; i < endIndex; i++) {
                            paginated.add(ranked[i]);
                        }
                        audiences = paginated;
                        // Hydrate CreatedBy/LastModifiedBy names after fallback pagination
                        Set<Id> hydrateIds = new Set<Id>();
                        for (Audience__c a : audiences) hydrateIds.add(a.Id);
                        if (!hydrateIds.isEmpty()) {
                            String enrichFallback = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :hydrateIds';
                            Map<String, Object> fbBinds = new Map<String, Object>{ 'hydrateIds' => hydrateIds };
                            String securedEnrichFallback = bypass ? enrichFallback : AgentCore_SafeQuery.secureForAccessLevel(enrichFallback, mode);
                            List<Audience__c> enrichedFallback = (List<Audience__c>)Database.queryWithBinds(securedEnrichFallback, fbBinds, mode);
                            Map<Id, Audience__c> eMapFb = new Map<Id, Audience__c>(enrichedFallback);
                            List<Audience__c> orderedFb = new List<Audience__c>();
                            for (Audience__c a : audiences) if (eMapFb.containsKey(a.Id)) orderedFb.add(eMapFb.get(a.Id));
                            audiences = orderedFb;
                        }
                    }
                }
            }

            List<AudienceDetails> details = new List<AudienceDetails>();
            for (Audience__c aud : audiences) {
                List<AudienceMemberSummary> members = new List<AudienceMemberSummary>();
                try {
                    List<Audience_Member__c> relatedMembers = (List<Audience_Member__c>)aud.get('Audience_Members__r');
                    if (relatedMembers != null) {
                        for (Audience_Member__c am : relatedMembers) {
                            members.add(new AudienceMemberSummary(am));
                        }
                    }
                } catch (Exception ignored) {
                    // Relationship data not available; try the member cache if present
                }
                if ((members == null || members.isEmpty()) && memberCache != null && memberCache.containsKey(aud.Id)) {
                    for (Audience_Member__c am : memberCache.get(aud.Id)) {
                        members.add(new AudienceMemberSummary(am));
                    }
                }
                Integer cnt = members == null ? 0 : members.size();
                details.add(new AudienceDetails(aud, cnt, members == null ? new List<AudienceMemberSummary>() : members));
            }

            return new AudienceResult(true, audiences, totalCount, details, new List<String>(), null);
        } catch (Exception e) {
            System.debug('Dynamic SOQL failed. Query: ' + executedQuery + ' | Binds: ' + bindVars);
            String msg = 'Search query failed: ' + e.getMessage();
            return new AudienceResult(false, null, 0, new List<AudienceDetails>(),
                new List<String>{msg}, msg);
        }
    }

}









