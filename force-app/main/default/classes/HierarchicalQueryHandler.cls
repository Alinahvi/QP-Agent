// HierarchicalQueryHandler.cls
// MODIFIED:
// - Corrected access to Assigned_Curriculum__c ID on Assigned_Course__c sObject.
// - Uses TrainingQueryBuilder.executeCountQuery() for total record counting.
// - Stores totalMatchingAssignments in request.RESPONSE_CRITERIA.totalRecords for session context.
// - Ensures consistent pagination info in response messages.
public class HierarchicalQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        if (this.request.HIERARCHY_CONTEXT == null ||
            String.isBlank(this.request.HIERARCHY_CONTEXT.ANCHOR_NAME) ||
            String.isBlank(this.request.HIERARCHY_CONTEXT.TYPE)) {
            return formatter.formatBooleanResult(false, '', 'Please specify the manager/leader and the scope (team or organization) for this query.');
        }

        String anchorName = this.request.HIERARCHY_CONTEXT.ANCHOR_NAME;
        String hierarchyType = this.request.HIERARCHY_CONTEXT.TYPE.toUpperCase();

        String trainingNameInput = this.request.FILTERS?.Training_Name;
        String completionStatusFilter = this.request.FILTERS?.Completion_Status;
        String assignmentStatusCategory = this.request.FILTERS?.Assignment_Status_Category;
        String trainingTypeHint = this.request.FILTERS?.Training_Type_Hint;

        Integer pageSize = (this.request.FILTERS?.queryLimit != null && this.request.FILTERS.queryLimit > 0)
                            ? this.request.FILTERS.queryLimit
                            : 20;
        Integer offset = (this.request.FILTERS?.queryOffset != null && this.request.FILTERS.queryOffset >= 0)
                          ? this.request.FILTERS.queryOffset
                          : 0;

        Boolean targetCompletionState = null;
        Boolean filterBySpecificCompletionStatus = false;

        if (String.isNotBlank(completionStatusFilter)) {
            if (completionStatusFilter.equalsIgnoreCase('COMPLETED')) {
                targetCompletionState = true;
                filterBySpecificCompletionStatus = true;
            } else if (completionStatusFilter.equalsIgnoreCase('NOT_COMPLETED')) {
                targetCompletionState = false;
                filterBySpecificCompletionStatus = true;
            } else if (completionStatusFilter.equalsIgnoreCase('ANY_STATUS_ASSIGNED') || completionStatusFilter.equalsIgnoreCase('ANY') ) {
                filterBySpecificCompletionStatus = false;
                System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: NLU requested ANY completion status.');
            } else {
                return formatter.formatBooleanResult(false, '', 'Invalid completion status specified: ' + completionStatusFilter + '. Use "completed", "not completed", or "any".');
            }
        } else if (String.isNotBlank(assignmentStatusCategory) && 'ACTIVE_PENDING'.equalsIgnoreCase(assignmentStatusCategory)) {
            targetCompletionState = false;
            filterBySpecificCompletionStatus = true;
            System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Assignment_Status_Category is ACTIVE_PENDING. Setting targetCompletionState to false.');
        } else {
            if (String.isNotBlank(trainingNameInput)) {
                filterBySpecificCompletionStatus = false;
                System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: No specific completion status from NLU for training "' + trainingNameInput + '". Fetching all assigned (completed and not completed).');
            } else {
                return formatter.formatBooleanResult(false, '', 'Please specify the completion status (e.g., "completed", "not completed", or "any") or a specific training name for this hierarchical query.');
            }
        }

        Set<Id> targetLearnerProfileIds;
        try {
            if ('DIRECT_REPORTS'.equals(hierarchyType)) {
                targetLearnerProfileIds = getDirectReportsLearnerProfileIds(anchorName);
            } else if ('ORGANIZATION_MEMBERS'.equals(hierarchyType)) {
                targetLearnerProfileIds = getOrganizationLearnerProfileIds(anchorName);
            } else {
                return formatter.formatBooleanResult(false, '', 'Invalid hierarchy type specified: ' + hierarchyType);
            }
        } catch (Exception e) {
             System.debug(LoggingLevel.ERROR, 'Error retrieving learner set for ' + anchorName + ' (' + hierarchyType + '): ' + e.getMessage() + '. Stacktrace: ' + e.getStackTraceString());
            return 'Could not retrieve the team/organization for ' + anchorName.escapeHtml4() + '. This could be due to an issue finding the specified leader or their organizational data.';
        }

        if (targetLearnerProfileIds == null || targetLearnerProfileIds.isEmpty()) {
            String scopeText = 'DIRECT_REPORTS'.equals(hierarchyType) ? 'team members' : 'organization members';
            return formatter.formatBooleanResult(false, '', 'No active ' + scopeText + ' found for ' + anchorName.escapeHtml4() + '. Please ensure the leader name is correct and they are an active user with organizational data.');
        }

        List<String> searchTargets = determineSearchTargets(trainingTypeHint, String.isNotBlank(trainingNameInput));
        String inactiveField = 'Inactive__c';
        String completedField = 'Completed__c';
        String dueDateField = 'Due_Date__c';
        String completionDateField = 'Completion_Date__c';
        String assetTypeFieldPath = 'Asset__r.RecordType.Name';
        String selfAssignedField = 'Self_Assigned__c';

        List<String> keywords = new List<String>();
        if (String.isNotBlank(trainingNameInput)) {
            for(String keyword : trainingNameInput.trim().split(' ')) {
                if (String.isNotBlank(keyword)) { keywords.add(keyword); }
            }
            if (keywords.isEmpty() && String.isNotBlank(trainingNameInput)) { keywords.add(trainingNameInput.trim()); }
        }
        if (String.isNotBlank(trainingNameInput) && keywords.isEmpty()) {
            return formatter.formatBooleanResult(false, '', 'Could not extract keywords from the provided training name: ' + trainingNameInput.escapeHtml4());
        }

        Integer totalMatchingAssignments = 0;
        for (String assignmentObjectApiName : searchTargets) {
            TrainingQueryBuilder countQb = new TrainingQueryBuilder(this.request);
            String currentTrainingNameFieldPathForCount = getTrainingNameFieldPath(assignmentObjectApiName);
            countQb.selectFrom(assignmentObjectApiName).clearSelectFields().addSelectField('COUNT()');

            applyCommonHierarchicalFilters(countQb, currentTrainingNameFieldPathForCount, keywords,
                                           filterBySpecificCompletionStatus, targetCompletionState,
                                           completedField, inactiveField, selfAssignedField, assignmentObjectApiName,
                                           targetLearnerProfileIds);
            try {
                Integer count = countQb.executeCountQuery();
                totalMatchingAssignments += count;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Error executing count query for ' + assignmentObjectApiName + ': ' + e.getMessage());
            }
        }
        System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Total matching assignments found: ' + totalMatchingAssignments); // [cite: 10]

        if (this.request.RESPONSE_CRITERIA == null) this.request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        this.request.RESPONSE_CRITERIA.totalRecords = totalMatchingAssignments;
        this.request.RESPONSE_CRITERIA.FORMAT = 'LIST';

        List<IndividualLearnerQueryHandler.TrainingResultWrapper> comprehensiveResults = new List<IndividualLearnerQueryHandler.TrainingResultWrapper>();
        if (totalMatchingAssignments > 0 && offset < totalMatchingAssignments) {
            for (String assignmentObjectApiName : searchTargets) {
                TrainingQueryBuilder currentQb = new TrainingQueryBuilder(this.request);
                String currentTrainingNameFieldPath = getTrainingNameFieldPath(assignmentObjectApiName);
                String trainingTypeLabelForWrapper = getTrainingTypeLabel(assignmentObjectApiName);

                currentQb.selectFrom(assignmentObjectApiName)
                         .addSelectField('Learner_Profile__r.Name')
                         .addSelectField(currentTrainingNameFieldPath)
                         .addSelectField(completedField)
                         .addSelectField(inactiveField)
                         .addSelectField(dueDateField)
                         .addSelectField(completionDateField)
                         .addSelectField(selfAssignedField);
                if(assignmentObjectApiName.equals('Assignment__c')){
                    currentQb.addSelectField(assetTypeFieldPath);
                    currentQb.addSelectField('Assigned_Course__c');
                    currentQb.addSelectField('Assigned_Curriculum__c');
                } else if (assignmentObjectApiName.equals('Assigned_Course__c')) {
                    currentQb.addSelectField('Assigned_Curriculum__c'); // For top-level filtering logic
                }

                applyCommonHierarchicalFilters(currentQb, currentTrainingNameFieldPath, keywords,
                                               filterBySpecificCompletionStatus, targetCompletionState,
                                               completedField, inactiveField, selfAssignedField, assignmentObjectApiName,
                                               targetLearnerProfileIds);

                currentQb.orderBy('Learner_Profile__r.Name', 'ASC');
                if (keywords.isEmpty()) { 
                    if(String.isNotBlank(currentTrainingNameFieldPath)) currentQb.orderBy(currentTrainingNameFieldPath, 'ASC');
                } else { 
                    if (filterBySpecificCompletionStatus && targetCompletionState == true && String.isNotBlank(completionDateField)) {
                        currentQb.orderBy(completionDateField, 'DESC');
                    } else if (filterBySpecificCompletionStatus && targetCompletionState == false && String.isNotBlank(dueDateField)) {
                        currentQb.orderBy(dueDateField, 'ASC');
                    }
                }

                currentQb.setLimit(pageSize);
                currentQb.setOffset(offset);

                try {
                    System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Executing Query for ' + assignmentObjectApiName + ': ' + currentQb.buildSOQLString()); // [cite: 11, 26]
                    List<SObject> queryResults = currentQb.executeQuery();
                    for(SObject sObj : queryResults){
                        // *** MODIFIED HERE ***
                        if (assignmentObjectApiName.equals('Assigned_Course__c') && sObj.get('Assigned_Curriculum__c') != null) { // Use .get() for ID field
                            System.debug(LoggingLevel.INFO, 'Skipping Assigned_Course ' + sObj.Id + ' as it is part of an Assigned_Curriculum__c: ' + sObj.get('Assigned_Curriculum__c'));
                            continue; 
                        }

                        String actualTypeForWrapper = trainingTypeLabelForWrapper;
                        if(assignmentObjectApiName.equals('Assignment__c')){
                            Object assetTypeVal = IndividualLearnerQueryHandler.getStaticNestedSObjectValue(sObj, assetTypeFieldPath);
                            actualTypeForWrapper = (assetTypeVal != null && String.isNotBlank(String.valueOf(assetTypeVal))) ?
                                                    String.valueOf(assetTypeVal).escapeHtml4() : 'Asset';
                        }
                        comprehensiveResults.add(
                            new IndividualLearnerQueryHandler.TrainingResultWrapper(sObj, actualTypeForWrapper, currentTrainingNameFieldPath, dueDateField)
                        );
                    }
                } catch (Exception e) {
                    // Log from apex-07LD700000VgOJyMAN.txt line 189 shows this debug message
                    System.debug(LoggingLevel.ERROR, 'Error querying ' + assignmentObjectApiName + ' in HierarchicalQueryHandler: ' +
                                 e.getMessage() + '. Stacktrace: ' + e.getStackTraceString()); // [cite: 13]
                }
            }
        }

        String nonSelfAssignedText = 'non-self-assigned';
        String scopeText = 'DIRECT_REPORTS'.equals(hierarchyType) ? 'team' : 'organization';

        if (comprehensiveResults.isEmpty()) {
            String statusText = filterBySpecificCompletionStatus ? (targetCompletionState ? 'completed' : 'not yet completed') : 'assigned (any status)';
            String forTrainingText = String.isNotBlank(trainingNameInput) ? ' for training matching keywords from "' + trainingNameInput.escapeHtml4() + '"' : ' training';
            String message;
            if (offset > 0) {
                 message = String.format('No more active members of {0}\'s {1} found who have {2} ({3}, active enrollment){4} for this page. (Total assignments matching criteria: {5})',
                    new List<Object>{anchorName.escapeHtml4(), scopeText, statusText, nonSelfAssignedText, forTrainingText, totalMatchingAssignments});
            } else {
                 message = String.format('No one in {0}\'s {1} (who is active and actively enrolled in {2} training) has {3}{4}. (Total assignments matching criteria: {5})',
                new List<Object>{anchorName.escapeHtml4(), scopeText, nonSelfAssignedText, statusText, forTrainingText, totalMatchingAssignments});
            }
            return formatter.formatBooleanResult(false, '', message);
        }
        this.formatter = new TrainingResultFormatter(this.request);

        String statusMessagePart;
        if (filterBySpecificCompletionStatus) {
            statusMessagePart = targetCompletionState ? 'completed' : 'not yet completed';
            if (String.isBlank(this.request.FILTERS?.Completion_Status) && 'ACTIVE_PENDING'.equalsIgnoreCase(this.request.FILTERS?.Assignment_Status_Category) && !targetCompletionState) {
                statusMessagePart = 'assigned (active, ' + nonSelfAssignedText + ', and not yet completed)';
            }
        } else {
            statusMessagePart = 'assigned (status shown below)';
        }
        String enrollmentContext = '(' + nonSelfAssignedText + ', actively enrolled)';
        String introMsg = '';
        String paginationDetails = String.format('(showing page results {0} to {1} of {2} total matching assignments)',
            new List<Object>{offset + 1, offset + comprehensiveResults.size(), totalMatchingAssignments});

        if (String.isNotBlank(trainingNameInput)) {
            Map<String, List<String>> trainingToLearnersWithStatusMap = new Map<String, List<String>>();
            for(IndividualLearnerQueryHandler.TrainingResultWrapper wrap : comprehensiveResults) {
                String learnerNameDisplay = '[Unknown Learner]';
                SObject lpRecord = wrap.originalRecord.getSObject('Learner_Profile__r');
                if(lpRecord != null && lpRecord.get('Name') != null){
                    learnerNameDisplay = String.valueOf(lpRecord.get('Name')).escapeHtml4();
                }

                String assignmentDetail = learnerNameDisplay;
                 if (!filterBySpecificCompletionStatus || wrap.isCompleted) { 
                    Date cd = (Date)wrap.originalRecord.get(completionDateField);
                    assignmentDetail += ' (Completed' + (cd != null ? ' on: ' + cd.format() : '') + ')';
                } else if (!wrap.isCompleted) { 
                    assignmentDetail += ' (Not Completed' + (wrap.dueDate != null ? ', Due: ' + wrap.dueDate.format() + (wrap.isOverdue ? ' - OVERDUE' : '') : ', No due date') + ')';
                }

                if(!trainingToLearnersWithStatusMap.containsKey(wrap.trainingItemName)){
                    trainingToLearnersWithStatusMap.put(wrap.trainingItemName, new List<String>());
                }
                trainingToLearnersWithStatusMap.get(wrap.trainingItemName).add(assignmentDetail);
            }
            for(String key : trainingToLearnersWithStatusMap.keySet()){ trainingToLearnersWithStatusMap.get(key).sort(); }

            List<String> fullResponseParts = new List<String>();
            String forTrainingText = 'training where the name contains keywords from "' + trainingNameInput.escapeHtml4() + '"';
            introMsg = String.format('In {0}\'s {1}, for {2}, here are the people {3} and their status {4}:',
                                      new List<Object>{anchorName.escapeHtml4(), scopeText, forTrainingText, enrollmentContext, paginationDetails});
            fullResponseParts.add(introMsg);
            List<String> sortedMatchedTrainingNames = new List<String>(trainingToLearnersWithStatusMap.keySet());
            sortedMatchedTrainingNames.sort();
            for(String actualTraining : sortedMatchedTrainingNames) {
                fullResponseParts.add('- For "' + actualTraining.escapeHtml4() + '": ' + String.join(trainingToLearnersWithStatusMap.get(actualTraining), '; ') + '.');
            }
            if (offset + comprehensiveResults.size() < totalMatchingAssignments) {
                 fullResponseParts.add('(More results may be available.)');
            }
            return String.join(fullResponseParts, '\n');

        } else { 
            Map<String, List<String>> learnerToTrainingsMap = new Map<String, List<String>>();
            Set<String> uniqueLearnerNames = new Set<String>();
            for(IndividualLearnerQueryHandler.TrainingResultWrapper item : comprehensiveResults){
                String learnerNameDisplay = '[Unknown Learner]';
                SObject lpRecord = item.originalRecord.getSObject('Learner_Profile__r');
                if(lpRecord != null && lpRecord.get('Name') != null){
                    learnerNameDisplay = String.valueOf(lpRecord.get('Name')).escapeHtml4();
                }
                uniqueLearnerNames.add(learnerNameDisplay);

                if(!learnerToTrainingsMap.containsKey(learnerNameDisplay)){
                    learnerToTrainingsMap.put(learnerNameDisplay, new List<String>());
                }
                String trainingDetail = item.trainingType.escapeHtml4() + ': ' + item.trainingItemName.escapeHtml4();

                if (filterBySpecificCompletionStatus) {
                    if (targetCompletionState && item.isCompleted) { 
                        Date cd = (Date) item.originalRecord.get(completionDateField);
                        trainingDetail += ' (Completed' + (cd != null ? ' on: ' + cd.format() : '') + ')';
                    } else if (!targetCompletionState && !item.isCompleted) { 
                        trainingDetail += ' (Due: ' + (item.dueDate != null ? item.dueDate.format() : 'N/A') + (item.isOverdue ? ' - OVERDUE' : '') + ')';
                    }
                } else { 
                     if (item.isCompleted) {
                        Date cd = (Date) item.originalRecord.get(completionDateField);
                        trainingDetail += ' (Completed' + (cd != null ? ' on: ' + cd.format() : '') + ')';
                    } else {
                        trainingDetail += ' (Not Completed, Due: ' + (item.dueDate != null ? item.dueDate.format() : 'N/A') + (item.isOverdue ? ' - OVERDUE' : '') + ')';
                    }
                }
                learnerToTrainingsMap.get(learnerNameDisplay).add(trainingDetail);
            }

            List<String> sortedLearnerNames = new List<String>(uniqueLearnerNames);
            sortedLearnerNames.sort();

            List<String> fullResponseParts = new List<String>();
            String forTrainingTextAll = 'top-level, ' + nonSelfAssignedText + ' training items';
            introMsg = String.format('For {0}\'s {1}, here are the {2} that are {3} {4} {5}:',
                                new List<Object>{anchorName.escapeHtml4(), scopeText, forTrainingTextAll, statusMessagePart, enrollmentContext, paginationDetails});
            fullResponseParts.add(introMsg);
            for(String currentLearnerName : sortedLearnerNames){
                if(learnerToTrainingsMap.containsKey(currentLearnerName) && !learnerToTrainingsMap.get(currentLearnerName).isEmpty()){
                     List<String> trainingsForLearner = learnerToTrainingsMap.get(currentLearnerName);
                     trainingsForLearner.sort(); 
                     fullResponseParts.add(currentLearnerName + ' - ' + String.join(trainingsForLearner, '; ') + '.');
                }
            }
            if (offset + comprehensiveResults.size() < totalMatchingAssignments) {
                 fullResponseParts.add('(More results may be available.)');
            }
            return String.join(fullResponseParts, '\n');
        }
    }

    private void applyCommonHierarchicalFilters(TrainingQueryBuilder qb,
                                    String trainingNameFieldPath,
                                    List<String> keywords,
                                    Boolean filterBySpecificCompletion,
                                    Boolean targetCompletionState,
                                    String completedField, String inactiveField, String selfAssignedField,
                                    String assignmentObjectApiName, Set<Id> learnerProfileIds) {

        if (!keywords.isEmpty()) {
            if(String.isNotBlank(trainingNameFieldPath)){
                Integer keywordIndex = 0;
                for (String keyword : keywords) {
                    String keywordPattern = '%' + keyword + '%';
                    String bindKey = 'kwP' + assignmentObjectApiName.left(3) + keywordIndex; 
                    qb.addWhereCondition(trainingNameFieldPath + ' LIKE :' + bindKey, bindKey, keywordPattern);
                    keywordIndex++;
                }
            } else {
                 System.debug(LoggingLevel.WARN, 'HierarchicalQueryHandler.applyCommonFilters: Keywords provided but trainingNameFieldPath is blank for ' + assignmentObjectApiName + '. Adding Id = null condition to prevent matching this object type.');
                 qb.addWhereConditionRaw('Id = null');
                 return;
            }
        } else if (String.isNotBlank(this.request.FILTERS?.Training_Name) && keywords.isEmpty()) {
            System.debug(LoggingLevel.WARN, 'HierarchicalQueryHandler.applyCommonFilters: Training name provided but no valid keywords extracted. Adding Id = null condition.');
            qb.addWhereConditionRaw('Id = null');
            return;
        }

        String objSuffix = assignmentObjectApiName.left(3).replaceAll('[^a-zA-Z0-9]','');

        if (filterBySpecificCompletion && targetCompletionState != null) { 
            qb.addWhereCondition(completedField + ' = :compStateH' + objSuffix, 'compStateH' + objSuffix, targetCompletionState);
        }
        qb.addWhereCondition('Learner_Profile__c IN :lpIdsH' + objSuffix, 'lpIdsH' + objSuffix, new List<Id>(learnerProfileIds));
        qb.addWhereCondition(inactiveField + ' = :inactiveFH' + objSuffix, 'inactiveFH' + objSuffix, false);
        qb.addWhereCondition(selfAssignedField + ' = :saFalseH' + objSuffix, 'saFalseH' + objSuffix, false);
        qb.addWhereCondition('Learner_Profile__r.Status__c = :lpStatusH' + objSuffix, 'lpStatusH' + objSuffix, 'Active');

        if (assignmentObjectApiName.equals('Assigned_Course__c')) {
            qb.addWhereConditionRaw('Assigned_Curriculum__c = null');
        } else if (assignmentObjectApiName.equals('Assignment__c')) {
            qb.addWhereConditionRaw('Assigned_Course__c = null');
            qb.addWhereConditionRaw('Assigned_Curriculum__c = null');
        }
    }

    private String getTrainingNameFieldPath(String assignmentObjectApiName) {
        if (assignmentObjectApiName.equals('Assigned_Course__c')) { return 'Course__r.Name'; }
        else if (assignmentObjectApiName.equals('Assigned_Curriculum__c')) { return 'Curriculum__r.Name'; }
        else if (assignmentObjectApiName.equals('Assignment__c')) { return 'Asset__r.Name'; }
        return '';
    }

    private String getTrainingTypeLabel(String assignmentObjectApiName) {
        if (assignmentObjectApiName.equals('Assigned_Course__c')) { return 'Course'; }
        else if (assignmentObjectApiName.equals('Assigned_Curriculum__c')) { return 'Curriculum'; }
        return 'Asset'; 
    }
    
    private Set<Id> getDirectReportsLearnerProfileIds(String managerName) {
        Set<Id> learnerProfileIds = new Set<Id>();
        if(String.isBlank(managerName)) {
            System.debug(LoggingLevel.WARN, 'HierarchicalQueryHandler.getDirectReportsLearnerProfileIds: managerName is blank.');
            return learnerProfileIds;
        }
        // Manager__c is a text field storing the manager's name
        for (Learner_Profile__c lp : [SELECT Id FROM Learner_Profile__c
                                      WHERE Manager__c = :managerName 
                                        AND Status__c = 'Active']) {
            learnerProfileIds.add(lp.Id);
        }
        System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Found ' + learnerProfileIds.size() + ' direct reports for manager name: ' + managerName.escapeHtml4());
        return learnerProfileIds;
    }

    private Set<Id> getOrganizationLearnerProfileIds(String organizationManagerName) {
        Set<Id> learnerProfileIds = new Set<Id>();
        if(String.isBlank(organizationManagerName)) {
            System.debug(LoggingLevel.WARN, 'HierarchicalQueryHandler: organizationManagerName is blank for getOrganizationLearnerProfileIds.');
            return learnerProfileIds;
        }

        String managerEmail;
        try {
            List<Learner_Profile__c> managerProfiles = [
                SELECT Primary_Email__c
                FROM Learner_Profile__c
                WHERE Name = :organizationManagerName AND Status__c = 'Active'
                LIMIT 1
            ];
            if (managerProfiles.isEmpty() || String.isBlank(managerProfiles[0].Primary_Email__c)) {
                System.debug(LoggingLevel.WARN, 'HierarchicalQueryHandler: Could not find an active manager or their primary email for: ' + organizationManagerName.escapeHtml4());
                return learnerProfileIds; 
            }
            managerEmail = managerProfiles[0].Primary_Email__c;
            System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Found email "' + managerEmail + '" for anchor manager: ' + organizationManagerName.escapeHtml4());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'HierarchicalQueryHandler: Error fetching email for manager "' + organizationManagerName.escapeHtml4() + '": ' + e.getMessage() + '. Stacktrace: ' + e.getStackTraceString());
            return learnerProfileIds; 
        }

        List<String> chainConditions = new List<String>();
        for(Integer i = 1; i <= 12; i++) { 
            String levelField = String.format('Emp_Mgt_Chain_Lvl_{0}_Nm__c', new List<String>{String.valueOf(i).leftPad(2, '0')});
            chainConditions.add(levelField + ' = :orgManagerEmailParam');
        }
        String hierarchySoqlFilter = '(' + String.join(chainConditions, ' OR ') + ')';
        hierarchySoqlFilter += ' OR Primary_Email__c = :orgManagerEmailParam'; 

        String soqlQueryForLearners = 'SELECT Id FROM Learner_Profile__c WHERE (' + hierarchySoqlFilter + ') AND Status__c = \'Active\'';
        Map<String, Object> bindMap = new Map<String, Object>{'orgManagerEmailParam' => managerEmail};

        try {
            for(SObject sObj : Database.queryWithBinds(soqlQueryForLearners, bindMap, AccessLevel.USER_MODE)){
                 learnerProfileIds.add(sObj.Id);
            }
            System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Found ' + learnerProfileIds.size() + ' organization members for ' + organizationManagerName.escapeHtml4() + ' (using email: ' + managerEmail + ')');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'HierarchicalQueryHandler: Error querying organization members by email: ' + e.getMessage());
        }
        return learnerProfileIds;
    }

    private List<String> determineSearchTargets(String trainingTypeHint, Boolean isTrainingNameNotBlank) {
        List<String> targets = new List<String>();
        if (isTrainingNameNotBlank || String.isBlank(trainingTypeHint) || !isTrainingNameNotBlank) { 
            targets.add('Assigned_Curriculum__c');
            targets.add('Assigned_Course__c');
            targets.add('Assignment__c');
            System.debug(LoggingLevel.INFO, 'HierarchicalQueryHandler: Searching all assignment types. NameProvided=' + isTrainingNameNotBlank + ', Hint="' + trainingTypeHint + '"');
        } else if (String.isNotBlank(trainingTypeHint)) {
            if ('Course'.equalsIgnoreCase(trainingTypeHint)) { targets.add('Assigned_Course__c'); }
            else if ('Curriculum'.equalsIgnoreCase(trainingTypeHint)) { targets.add('Assigned_Curriculum__c'); }
            else if ('Event'.equalsIgnoreCase(trainingTypeHint) || 'Asset'.equalsIgnoreCase(trainingTypeHint)) { targets.add('Assignment__c'); }
            else { targets.addAll(new List<String>{'Assigned_Course__c', 'Assigned_Curriculum__c', 'Assignment__c'}); }
        }
        return targets;
    }
}