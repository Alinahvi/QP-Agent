// SessionQueryHandler.cls
// MODIFIED:
// - Uses TrainingQueryBuilder.executeCountQuery() for COUNT operations.
// - Integrates pagination for list-based responses.
public class SessionQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;
    // TrainingDateHelper methods are static

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        String sessionNameFilter = this.request.FILTERS?.Session_Name;
        String specificDateStr = this.request.FILTERS?.Session_Start_Date;
        String relativeDateTerm = this.request.FILTERS?.RELATIVE_DATE_TERM;
        String participantStatusFilter = this.request.FILTERS?.Session_Participant_Status;
        String learnerName = this.request.LEARNER_CONTEXT?.LEARNER_NAME;
        String eventNameForFilter = this.request.FILTERS?.Event_Name_For_Session_Filter;
        String agentAction = this.request.AGENT_ACTION != null ? this.request.AGENT_ACTION.toUpperCase() : '';

        Integer pageSize = (this.request.FILTERS?.queryLimit != null && this.request.FILTERS.queryLimit > 0)
                            ? this.request.FILTERS.queryLimit
                            : 20;
        Integer offset = (this.request.FILTERS?.queryOffset != null && this.request.FILTERS.queryOffset >= 0)
                          ? this.request.FILTERS.queryOffset
                          : 0;

        if (String.isBlank(participantStatusFilter) &&
            (agentAction.contains('PARTICIPANT') || agentAction.contains('STATUS_QUERY'))) {
            String missingInfoError = 'Please specify the participant status (e.g., registered, attended, waitlisted)';
            if (String.isNotBlank(learnerName) && 'CHECK_SESSION_PARTICIPATION'.equals(agentAction)) {
                return formatter.formatBooleanResult(false, '', missingInfoError + ' for ' + learnerName.escapeHtml4() + '.');
            } else if (String.isNotBlank(sessionNameFilter) || String.isNotBlank(eventNameForFilter)) {
                String forContext = String.isNotBlank(eventNameForFilter) ? 'event "' + eventNameForFilter.escapeHtml4() + '"' : 'session "' + sessionNameFilter.escapeHtml4() + '"';
                return formatter.formatBooleanResult(false, '', missingInfoError + ' for ' + forContext + '.');
            } else if (String.isBlank(sessionNameFilter) && String.isBlank(learnerName) && String.isBlank(eventNameForFilter) && 'CHECK_SESSION_PARTICIPATION'.equals(agentAction)){
                return formatter.formatBooleanResult(false, '', missingInfoError + ' and provide a learner, session, or event name.');
             }
        }

        Id targetLearnerProfileId = null;
        if (String.isNotBlank(learnerName)) {
            try {
                List<Learner_Profile__c> learnersFound = [
                    SELECT Id, Name
                    FROM Learner_Profile__c
                    WHERE Name = :learnerName AND Status__c = 'Active'
                    LIMIT 2
                ];
                if (learnersFound.isEmpty()) {
                    return formatter.formatBooleanResult(false, '', 'I could not find an active learner named: ' + learnerName.escapeHtml4());
                }
                if (learnersFound.size() > 1) {
                    // Consider if this should use the standard ambiguity handling used in IndividualLearnerQueryHandler
                    return 'I found multiple active people named ' + learnerName.escapeHtml4() + '. Please be more specific.';
                }
                targetLearnerProfileId = learnersFound[0].Id;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Error querying Learner_Profile__c for ' + learnerName + ': ' + e.getMessage());
                return 'An error occurred while looking up ' + learnerName.escapeHtml4() + '.';
            }
        }

        if (String.isBlank(sessionNameFilter) && targetLearnerProfileId == null && String.isBlank(eventNameForFilter) &&
            (agentAction.contains('PARTICIPANT') || agentAction.contains('STATUS_QUERY'))) {
            return formatter.formatBooleanResult(false, '', 'Please specify a session name, a learner name, or an event name for this query.');
        }

        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom('Assigned_Session__c');

        if (String.isNotBlank(sessionNameFilter)) {
            qb.addWhereCondition('Session__r.Name = :sessionNameParam', 'sessionNameParam', sessionNameFilter);
        }
        if (targetLearnerProfileId != null) {
            qb.addWhereCondition('Learner_Profile__c = :learnerIdParam', 'learnerIdParam', targetLearnerProfileId);
        }
        if (String.isNotBlank(eventNameForFilter)) {
            qb.addWhereCondition('Session__r.Asset__r.Name = :eventNameParam', 'eventNameParam', eventNameForFilter);
        }

        Date targetDate = null;
        TrainingDateHelper.DateRange dateRange = null;

        if (String.isNotBlank(relativeDateTerm)) {
            dateRange = TrainingDateHelper.parseRelativeDateTerm(relativeDateTerm);
            if (dateRange != null) {
                qb.addWhereCondition('Session__r.Start_Date__c >= :startDateParam', 'startDateParam', dateRange.startDate);
                qb.addWhereCondition('Session__r.Start_Date__c <= :endDateParam', 'endDateParam', dateRange.endDate);
            } else {
                return formatter.formatBooleanResult(false, '', 'I could not understand the date timeframe: ' + relativeDateTerm);
            }
        } else if (String.isNotBlank(specificDateStr)) {
            targetDate = TrainingDateHelper.parseDateString(specificDateStr);
            if (targetDate != null) {
                qb.addWhereCondition('Session__r.Start_Date__c = :targetDateParam', 'targetDateParam', targetDate);
            } else {
                return formatter.formatBooleanResult(false, '', 'The session date provided was not in a recognizable format (YYYY-MM-DD).');
            }
        }

        if(String.isNotBlank(participantStatusFilter)){
            qb.addWhereCondition('Status__c = :statusParam', 'statusParam', participantStatusFilter);
        }

        String responseFormat = (this.request.RESPONSE_CRITERIA != null && String.isNotBlank(this.request.RESPONSE_CRITERIA.FORMAT))
                                 ? this.request.RESPONSE_CRITERIA.FORMAT.toUpperCase()
                                 : 'LIST';
        try {
            if ('COUNT'.equalsIgnoreCase(responseFormat) || 'BOOLEAN_COUNT'.equalsIgnoreCase(responseFormat)) {
                qb.clearSelectFields().addSelectField('COUNT()'); // Standardized to COUNT()
                
                // *** MODIFIED TO USE executeCountQuery() ***
                Integer count = qb.executeCountQuery();
                
                String forContextText = '';
                if (targetLearnerProfileId != null) forContextText += ' for ' + learnerName.escapeHtml4();
                if (String.isNotBlank(eventNameForFilter)) forContextText += ' in event "' + eventNameForFilter.escapeHtml4() + '"';
                else if (String.isNotBlank(sessionNameFilter)) forContextText += ' for session "' + sessionNameFilter.escapeHtml4() + '"';
                // Removed 'else if (targetLearnerProfileId != null) forContextText += ' for any session';' as it's covered by the first learner check
                
                String statusText = String.isNotBlank(participantStatusFilter) ? ' with status "' + participantStatusFilter.toLowerCase().escapeHtml4() + '"' : '';

                if ('BOOLEAN_COUNT'.equalsIgnoreCase(responseFormat)) {
                    if (count > 0) {
                         return formatter.formatBooleanResult(true,
                                                         'Yes, ' + (targetLearnerProfileId != null ? learnerName.escapeHtml4() + ' has' : 'there ' + (count == 1 ? 'is ' : 'are ') + count + ' ' + (count == 1 ? 'participant' : 'participants')) + // Changed 'person/people' to 'participant(s)'
                                                         statusText + forContextText + '.', '');
                    } else {
                         return formatter.formatBooleanResult(false, '',
                                                         'No, ' + (targetLearnerProfileId != null ? learnerName.escapeHtml4() + ' does not have' : 'no participants were found') + // Changed wording
                                                         statusText.trim() +
                                                         forContextText +
                                                         (targetDate != null ? (' on ' + targetDate.format()) : (dateRange != null ? ' within the specified timeframe' : '')) + '.');
                    }
                } else { // COUNT format
                    return formatter.formatCountResult(count, 'participants' + statusText + forContextText); // Changed 'people' to 'participants'
                }

            } else { // LIST format or similar
                if (targetLearnerProfileId != null) {
                    qb.addSelectField('Session__r.Name').addSelectField('Session__r.Start_Date__c');
                    if (String.isBlank(eventNameForFilter)) {
                        qb.addSelectField('Session__r.Asset__r.Name');
                    }
                    qb.orderBy('Session__r.Start_Date__c', 'ASC').orderBy('Session__r.Name', 'ASC');
                } else {
                    qb.addSelectField('Learner_Profile__r.Name');
                    qb.orderBy('Learner_Profile__r.Name', 'ASC');
                }
                
                qb.setLimit(pageSize);
                if (offset > 0) {
                    qb.setOffset(offset);
                }
                
                List<SObject> results = qb.executeQuery();
                
                this.formatter = new TrainingResultFormatter(this.request); // Re-init if request criteria was updated for totalRecords

                if (results.isEmpty()) {
                     String forText = '';
                     if(targetLearnerProfileId != null) forText += ' for ' + learnerName.escapeHtml4();
                     if(String.isNotBlank(eventNameForFilter)) forText += ' in event "' + eventNameForFilter.escapeHtml4() + '"';
                     else if(String.isNotBlank(sessionNameFilter)) forText += ' for session "' + sessionNameFilter.escapeHtml4() + '"';

                     String dateInfo = (targetDate != null ? (' on ' + targetDate.format()) : (dateRange != null ? ' within the specified timeframe' : ''));
                     String noResultsMessage = 'No records found' + forText +
                                               (String.isNotBlank(participantStatusFilter) ? ' with status "' + participantStatusFilter.toLowerCase().escapeHtml4() + '"' : '') +
                                               dateInfo;
                     if (offset > 0) {
                         noResultsMessage = 'No more records found' + forText +
                                            (String.isNotBlank(participantStatusFilter) ? ' with status "' + participantStatusFilter.toLowerCase().escapeHtml4() + '"' : '') +
                                            dateInfo + ' for this page.';
                     }
                     return noResultsMessage + '.';
                }
                
                String responseIntro = '';
                List<String> itemsToFormat = new List<String>();

                if (targetLearnerProfileId != null) {
                    responseIntro = learnerName.escapeHtml4() +
                                    (String.isNotBlank(participantStatusFilter) ? ' has status "' + participantStatusFilter.toLowerCase().escapeHtml4() + '" for ' : ' is associated with ') +
                                    (String.isNotBlank(eventNameForFilter) ? 'event "' + eventNameForFilter.escapeHtml4() + '" for ' : '') +
                                    'the following sessions';
                    for(SObject s : results) {
                        String sName = String.valueOf(s.getSObject('Session__r')?.get('Name'));
                        Date sDate = (Date)s.getSObject('Session__r')?.get('Start_Date__c');
                        String detail = sName.escapeHtml4();
                        if(sDate != null) {
                            detail += ' (on ' + sDate.format() + ')';
                        }
                        if(String.isBlank(eventNameForFilter) && s.getSObject('Session__r')?.getSObject('Asset__r') != null){
                            detail += ' - Event: ' + String.valueOf(s.getSObject('Session__r').getSObject('Asset__r').get('Name')).escapeHtml4();
                        }
                        itemsToFormat.add(detail);
                    }
                } else {
                    String dateInfoForMessage = (targetDate != null ? (' on ' + targetDate.format()) : (dateRange != null ? ' within the specified timeframe' : ''));
                    String statusInfoForMessage = (String.isNotBlank(participantStatusFilter) ? ' have status "' + participantStatusFilter.toLowerCase().escapeHtml4() + '"' : ' are associated');
                    String forWhat = String.isNotBlank(eventNameForFilter) ? 'event "' + eventNameForFilter.escapeHtml4() + '"' : 'session "' + sessionNameFilter.escapeHtml4() + '"';
                    
                    responseIntro = 'For ' + forWhat + dateInfoForMessage +
                                          ', the following people' + statusInfoForMessage;
                    for(SObject s : results) {
                        itemsToFormat.add(String.valueOf(s.getSObject('Learner_Profile__r')?.get('Name')).escapeHtml4());
                    }
                }

                if (this.request.FILTERS?.queryLimit != null) { // Check if pagination was active
                     Integer totalRecordsForPaginationMessage = (this.request.RESPONSE_CRITERIA?.totalRecords != null) ? this.request.RESPONSE_CRITERIA.totalRecords : results.size();
                    // If counting was done via executeCountQuery, totalRecords might not be easily available here unless specifically queried again for the LIST format.
                    // For simplicity, this example assumes totalRecords for the LIST format would need a separate full count if not already available.
                    // If SessionQueryHandler doesn't populate RESPONSE_CRITERIA.totalRecords for LIST, then a simple message or just page item count.
                    responseIntro += String.format(' (showing results {0} to {1}',
                                                new List<Object>{offset + 1, offset + results.size()});
                    // A more complex "has more" check would involve querying pageSize + 1 records
                    // or comparing results.size() with pageSize if a separate total count is not done for LIST.
                    if (results.size() == pageSize && (offset + pageSize < totalRecordsForPaginationMessage || totalRecordsForPaginationMessage == 0 && results.size() == pageSize) ) { // Simple check
                        responseIntro += ', more may be available';
                    }
                    responseIntro += ')';
                }
                responseIntro += ': ';
                
                itemsToFormat.sort();
                return responseIntro + String.join(itemsToFormat, '; ') + '.';
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in SessionQueryHandler for session "' + (sessionNameFilter != null ? sessionNameFilter.escapeHtml4() : 'N/A') +
                         '", event "' + (eventNameForFilter != null ? eventNameForFilter.escapeHtml4() : 'N/A') +
                         '" and learner "' + (learnerName != null ? learnerName.escapeHtml4() : 'N/A') + '": ' +
                         e.getMessage() + '. Stacktrace: ' + e.getStackTraceString());
            return 'I encountered an error while trying to fetch session participation information: ' + e.getMessage();
        }
    }
}