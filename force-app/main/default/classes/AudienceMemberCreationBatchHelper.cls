public with sharing class AudienceMemberCreationBatchHelper {
    public static Boolean createAudienceMembers(Audience__c aud, Map<String, String> lastLearnerIdByAudienceId) {
        Boolean runAgain = false;

        try {
            Audience__c audience = [SELECT Id, Filter_Logic__c, Use_Custom_Filter__c,
                                    (SELECT Id FROM Targeting_Criterias__r LIMIT 1)
                                    FROM Audience__c
                                    WHERE Id =: aud.Id
                                    WITH USER_MODE];

            if(audience.Targeting_Criterias__r.isEmpty()) {
                return false;
            }

            String audienceId = audience.Id;
            String lastLearnerId = lastLearnerIdByAudienceId.get(audienceId);
            String filterLogic = audience.Use_Custom_Filter__c ? audience.Filter_Logic__c : '';
            //find all Learner Profiles where their not already part of the audience
            String subQueryWhereClause = '(SELECT Learner_Profile__c FROM Audience_Member__c WHERE Audience__c = :audienceId)';
            String whereClause = ' WHERE (' + Utilities.getCriteriaWhereClause(audienceId, filterLogic) + ') AND Id NOT IN ' + subQueryWhereClause + ' AND Id >: lastLearnerId AND Status__c = \'Active\'';
            //find all Audience Members where their LP no longer fits the crtierias
            String subQueryDeleteClause = '(SELECT Id FROM Learner_Profile__c WHERE Status__c != \'Active\' OR (NOT (' + Utilities.getCriteriaWhereClause(audienceId, filterLogic) + ')))';
            String deleteWhereClause = ' WHERE Learner_Profile__c IN ' + subQueryDeleteClause + ' AND Audience__c =: audienceId AND Manually_Added__c = false';

            String memberQuery = 'SELECT Id FROM Learner_Profile__c ' + whereClause + ' ORDER BY Id ASC LIMIT 4501';
            String deleteQuery = 'SELECT Id FROM Audience_Member__c ' + deleteWhereClause + ' LIMIT 4501';

            /* SAMPLE
                SELECT Id
                FROM User
                WHERE Percent__c < 50
                AND Date__c >= 2018-07-15
                AND Multi_Picklist__c includes ('a','d','f')
                AND ( Picklist__c = 'A' OR Picklist__c = 'B' OR Picklist__c = 'C')
                AND ( Text__c = 'some' OR Text__c = 'kind' OR Text__c = 'of text')
                AND DateTime__c >= 2018-07-15T00:00:00.000Z
                AND Number__c >= 34
                and NOT IN (audmemIds)
                LIMIT 4501
             */

            List<Learner_Profile__c> learners = Database.query(memberQuery, AccessLevel.USER_MODE);

            /* SAMPLE
                SELECT Id
                FROM User
                WHERE
                (NOT(
                    User__r.Percent__c < 50
                    AND User__r. Date__c >= 2018-07-15
                    AND User__r.Multi_Picklist__c includes ('a','d','f')
                    AND ( User__r.Picklist__c = 'A' OR User__r.Picklist__c = 'B' OR User__r.Picklist__c = 'C')
                    AND ( User__r.Text__c = 'some' OR User__r.Text__c = 'kind' OR User__r.Text__c = 'of text')
                    AND User__r.DateTime__c >= 2018-07-15T00:00:00.000Z
                    AND User__r.Number__c >= 34
                ))
                AND Audience__c = 'Audience Id'
                LIMIT 4501
             */

            List<Audience_Member__c> oldMembers = Database.query(deleteQuery, AccessLevel.USER_MODE);

            //if we have more than 4500 it means we need to run this batch again.
            //we'll chain it up to a max of 5 times as 50000 records is the max we can support
            if(learners.size() > 4500) {
                lastLearnerIdByAudienceId.put(audienceId, learners.get(learners.size() - 1).Id);
                runAgain = true;
            }

            if(oldMembers.size() > 4500) {
                runAgain = true;
            }

            delete as user oldMembers;


            // Set<String> alreadyAddedLearners = new Set<String>();
            // for(Audience_Member__c audMem : [SELECT Id, Learner_Profile__c
            //                                  FROM Audience_Member__c
            //                                  WHERE Audience__c =: audienceId
            //                                  AND Learner_Profile__c =: learners
            //                                  WITH USER_MODE]){
            //     alreadyAddedLearners.add(audMem.Learner_Profile__c);
            // }


            List<Audience_Member__c> newMembers = new List<Audience_Member__c>();

            for(Learner_Profile__c lp : learners) {
                newMembers.add(new Audience_Member__c(
                    Audience__c = audience.Id,
                    Learner_Profile__c = lp.Id
                ));
            }

            insert as user newMembers;
        } catch (Exception e){
            System.debug('****** internal error: ' + e.getMessage() + ' at ' + e.getStackTraceString());
            Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = 'Failed to create audience members for : ' + aud.Id + ' because ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                Type__c = 'AudienceMemberCreationBatch'
                );
        }

        return runAgain;
    }

    public static void createNextReccurence(String audienceId){
        List<Assigned_Learning__c> alToRecur = [SELECT Id, OwnerId, Asset__c, Audience__c, Course__c, Curriculum__c, Custom_Course_Due_Dates__c, Due_Date__c, Frequency_Weekday_Location__c, 
                                                       Frequency_Weekday__c, Frequency__c, Previous_Recurrence__c, Recur__c, Source_Recurrence__c, 
                                                       Start_Date__c, Learning_Id__c, Learning_Name__c, Learning_Type__c, Content_Distribution_Organization__c 
                                                FROM Assigned_Learning__c
                                                WHERE Start_Date__c = TODAY
                                                AND Audience__c =: audienceId
                                                AND Recur__c = true];

        List<Assigned_Learning__c> newRecurALs = new List<Assigned_Learning__c>();
        List<Integration_Error__c> errors = new List<Integration_Error__c>();
        Set<String> alreadyCreatedReccurence = new Set<String>();

        for(Assigned_Learning__c al : [SELECT Id, Previous_Recurrence__c
                                        FROM Assigned_Learning__c
                                        WHERE Previous_Recurrence__c =: alToRecur]){
            alreadyCreatedReccurence.add(al.Previous_Recurrence__c);
        }

        for(Assigned_Learning__c currentAL : alToRecur){
            if(alreadyCreatedReccurence.contains(currentAL.Id)){
                continue;
            }

            Assigned_Learning__c recurringAL = currentAL.clone(false, true, false, false);
            recurringAL.Previous_Recurrence__c = currentAL.Id;
            recurringAL.Source_Recurrence__c = currentAL.Source_Recurrence__c == null ? currentAL.Id : currentAL.Source_Recurrence__c;
            Date nextRunDate = calculateNextRecurrence(recurringAL.Start_Date__c, recurringAL.Frequency__c, recurringAL.Frequency_Weekday__c, Integer.valueOf(recurringAL.Frequency_Weekday_Location__c));

            if(nextRunDate == null){
                Integration_Error__c errorObj = new Integration_Error__c(
                    Error_Message__c = 'Failed to recur ' + currentAL.Id + '. Please make sure the Frequency and the Frequency weekday are all valid',
                    Type__c = 'AudienceMemberCreationBatch'
                );

                errors.add(errorObj);
            } else {
                recurringAL.Start_Date__c = nextRunDate;

                if(currentAL.Due_Date__c != null){
                    Integer daysBetween = currentAL.Start_Date__c.daysBetween(currentAL.Due_Date__c);
                    recurringAL.Due_Date__c = recurringAL.Start_Date__c.addDays(daysBetween);
                }

                if(currentAL.Custom_Course_Due_Dates__c != null){
                    Map<String, Object> customDueDates = (Map<String, Object>) JSON.deserializeUntyped(currentAL.Custom_Course_Due_Dates__c);

                    for(String key : customDueDates.keySet()){
                        Date customDueDate = Date.valueOf((String)customDueDates.get(key));
                        Date nextCustomDueDate = calculateNextRecurrence(customDueDate, recurringAL.Frequency__c, recurringAL.Frequency_Weekday__c, Integer.valueOf(recurringAL.Frequency_Weekday_Location__c));
                        customDueDates.put(key, nextCustomDueDate);
                    }

                    recurringAL.Custom_Course_Due_Dates__c = JSON.serialize(customDueDates);
                }

                newRecurALs.add(recurringAL);
            }
        }

        if(!errors.isEmpty()){
            insert errors;
        }

        if(!newRecurALs.isEmpty()){
            insert newRecurALs;
        }
    }

    /*
        currentDate - starting date to calcuate recurrence from
        frequency - what the recurrence frequncy is
        recurrenceWeekday - which day of the week we want
        weekdayLocation - which week of the month we want
    */
    private static Date calculateNextRecurrence(Date startDate, String frequency, String recurrenceWeekday, Integer weekdayLocation){
        Time newTime = Time.newInstance(0, 0, 0, 0);
        Date nextRunTime;
        
        if(weekdayLocation > 5){
            weekdayLocation = 5;
        } else if(weekdayLocation == null || weekdayLocation < 1){
            weekdayLocation = 1;
        }

        if(frequency == 'Daily'){
            nextRunTime = startDate.addDays(1);
        } else if(frequency == 'Weekly'){
            nextRunTime = startDate.addDays(7);
        } else if(frequency == 'Monthly'){
            Date nextMonthDate = startDate.addMonths(1);
            nextMonthDate = nextMonthDate.toStartOfMonth();
            DateTime startDT = DateTime.newInstanceGmt(nextMonthDate, newTime);
            String currentWeekday = startDT.formatGMT('EEEE');

            //move from start of month to the weekday needed
            while(currentWeekday != recurrenceWeekday){
                startDT = startDT.addDays(1);
                currentWeekday = startDT.formatGMT('EEEE');
                //if we advanced an entire month then recurrenceWeekday must be invalid
                if(startDT.month() != nextMonthDate.month()){
                    return null;
                }
            }

            //locate the weekday in the current month
            if(weekdayLocation > 1){
                //subtract 1 as we're already on the "first" weekday of the month
                Integer weeksToAdd = weekdayLocation - 1;
                startDT = startDT.addDays(weeksToAdd * 7);

                //if we over shot then the weekdayLocation should've been 5 which signifies
                //"last" weekday of the month
                if(startDT.month() != nextMonthDate.month()){
                    startDT = startDT.addDays(-7);
                }
            }
            
            nextRunTime = startDT.dateGMT();
        } else if(frequency == 'Annually'){
            nextRunTime = startDate.addYears(1);
        }

        return nextRunTime;
    }

    //need to be list otherwise security scanner complains about not bulking
    // public static void createPartnerAudienceMembers(List<Partner_Audience__c> audiences, Boolean runAgain) {
    //     Partner_Audience__c audience;

    //     try {
    //         checkAccess(createPartnerAudienceMembersAccess, true);

    //         audience = [SELECT Id,
    //                     (
    //                         SELECT Id, Field__c, Matching_Rule__c, Type__c,
    //                         Date_Value__c, Number_Value__c, Boolean_Value__c, Text_Value__c
    //                         FROM Partner_Targeting_Criterias__r
    //                     )
    //                     FROM Partner_Audience__c
    //                     WHERE Id =: audiences.get(0).Id];

    //         if(audience.Partner_Targeting_Criterias__r.isEmpty()) {
    //             return;
    //         }

    //         String audienceId = audience.Id;
    //         Map<String, String> queryStrings = generateSoqlQueries(audience.Partner_Targeting_Criterias__r, false);
    //         List<String> existingMemberIds = new List<String>();

    //         for(Partner_Audience_Member__c member : [SELECT Learner_Profile__c FROM Partner_Audience_Member__c WHERE Partner_Audience__c =: audienceId]) {
    //             existingMemberIds.add(member.Learner_Profile__c);
    //         }

    //         String memberQuery = queryStrings.get('memberQuery');
    //         String deleteQuery = queryStrings.get('deleteQuery');

    //         System.debug('***** partner member: ' + memberQuery);
    //         System.debug('***** partner delete: ' + deleteQuery);
    //         /* SAMPLE
    //             SELECT Id
    //             FROM User
    //             WHERE Percent__c < 50
    //             AND Date__c >= 2018-07-15
    //             AND Multi_Picklist__c includes ('a','d','f')
    //             AND ( Picklist__c = 'A' OR Picklist__c = 'B' OR Picklist__c = 'C')
    //             AND ( Text__c = 'some' OR Text__c = 'kind' OR Text__c = 'of text')
    //             AND DateTime__c >= 2018-07-15T00:00:00.000Z
    //             AND Number__c >= 34
    //             AND Id NOT IN :existingMemberIds
    //             AND dayInRoleField != null
    //             LIMIT 4501
    //          */

    //         List<Learner_Profile__c> learners = Database.query(memberQuery);

    //         /* SAMPLE
    //             SELECT Id
    //             FROM User
    //             WHERE
    //             (NOT(
    //                 User__r.Percent__c < 50
    //                 AND User__r. Date__c >= 2018-07-15
    //                 AND User__r.Multi_Picklist__c includes ('a','d','f')
    //                 AND ( User__r.Picklist__c = 'A' OR User__r.Picklist__c = 'B' OR User__r.Picklist__c = 'C')
    //                 AND ( User__r.Text__c = 'some' OR User__r.Text__c = 'kind' OR User__r.Text__c = 'of text')
    //                 AND User__r.DateTime__c >= 2018-07-15T00:00:00.000Z
    //                 AND User__r.Number__c >= 34
    //             ))
    //             AND Audience__c = 'Audience Id'
    //             LIMIT 4501
    //          */

    //         List<Partner_Audience_Member__c> oldMembers = Database.query(deleteQuery);

    //         //if we have more than 4500 it means we need to run this batch again.
    //         //we'll chain it up to a max of 5 times as 50000 records is the max we can support
    //         if(learners.size() > 4500) {
    //             runAgain = true;
    //         }

    //         if(oldMembers.size() > 4500) {
    //             runAgain = true;
    //         }

    //         delete oldMembers;

    //         List<Partner_Audience_Member__c> newMembers = new List<Partner_Audience_Member__c>();

    //         for(Learner_Profile__c lp : learners) {
    //             newMembers.add(new Partner_Audience_Member__c(
    //                 Partner_Audience__c = audience.Id,
    //                 Learner_Profile__c = lp.Id
    //             ));
    //         }

    //         insert newMembers;
    //     } catch (Exception e){
    //         System.debug('****** partner error: ' + e.getMessage() + ' at ' + e.getStackTraceString());
    //         Integration_Error__c errorObj = new Integration_Error__c(
    //             Error_Message__c = 'Failed to create audience members for : ' + audience.Id + ' because ' + e.getMessage() + ' at line ' + e.getLineNumber()
    //             );
    //     }
    // }

    // public static Map<String, String> generateSoqlQueries(List<sObject> criterias, Boolean isPreview, String lastProcessedLearnerName){
    //     Map<String, String> queries = new Map<String, String>();
    //     String namespaceApi = constants.NAMESPACE_API;

    //     Map<String, Schema.SObjectField> learnerProfileFieldsByName = Learner_Profile__c.SObjectType.getDescribe().fields.getMap();
    //     Map<String, Schema.SObjectField> partnerProfileFieldsByName = Partner_Profile__c.SObjectType.getDescribe().fields.getMap();

    //     Set<String> lpFields = new Set<String>();
    //     Set<String> ppFields = new Set<String>();

    //     Boolean isPartner = criterias[0].getSObjectType().getDescribe().getName().toLowerCase().contains('partner');
        
    //     String deleteQuery = 'SELECT Id FROM ' + (isPartner ? 'Partner_' : '') + 'Audience_Member__c';
    //     String deleteWhereClause = ' WHERE (NOT(';
    //     String memberQuery = 'SELECT Id, Name, Email__c, CreatedDate FROM Learner_Profile__c';
    //     String memberWhereClause = ' WHERE ';

    //     for(sObject tc : criterias) {
    //         Map<String, Object> tcMap = (Map<String, Object>) tc.getPopulatedFieldsAsMap();

    //         String fieldName = (String) tcMap.get(namespaceApi + 'Field__c');
    //         Schema.DescribeFieldResult describedField;
    //         String criteriaType = 'Learner';

    //         if(tcMap.containsKey(constants.NAMESPACE_API + 'Type__c') && (String)tcMap.get(namespaceApi + 'Type__c') == 'Partner' && fieldName != 'Custom_SOQL') {
    //             criteriaType = 'Partner';
    //             describedField = partnerProfileFieldsByName.get(fieldName).getDescribe();
    //             ppFields.add(fieldName);
    //         } else if (fieldName != 'Custom_SOQL') {
    //             describedField = learnerProfileFieldsByName.get(fieldName).getDescribe();
    //             lpFields.add(fieldName);
    //         }

    //         if(fieldName == null || (String)tcMap.get(namespaceApi + 'Matching_Rule__c') == 'All') {
    //             continue;
    //         }

    //         String fieldType = fieldName == 'Custom_SOQL' ? 'CUSTOM' : String.valueOf(describedField.getType());

    //         Boolean boolValue = (Boolean) tcMap.get(namespaceApi + 'Boolean_Value__c');
    //         Date dateValue = (Date) tcMap.get(namespaceApi + 'Date_Value__c');
    //         String textValue = (String) tcMap.get(namespaceApi + 'Text_Value__c');
    //         String customValue = (String) tcMap.get(namespaceApi + 'Custom_SOQL_Value__c');
    //         Decimal numValue = (Decimal) tcMap.get(namespaceApi + 'Number_Value__c');

    //         String matchingRule =(String) tcMap.get(namespaceApi + 'Matching_Rule__c');

    //         String deleteField = namespaceApi + 'Learner_Profile__r.' + (criteriaType == 'Partner' ? namespaceApi + 'Partner_Profile__r.' : '') + fieldName;
    //         String memberField = (criteriaType == 'Partner' ? namespaceApi + 'Partner_Profile__r.' : '') + fieldName;

    //         if(fieldType == 'BOOLEAN') {
    //             deleteWhereClause += ' ' + deleteField + ' = ' + boolValue + ' AND';
    //             memberWhereClause += ' ' + memberField + ' = ' + boolValue + ' AND';
    //         } else if(fieldType == 'DATE' || fieldType == 'DATETIME') {
    //             String operator = ' >= ';
    //             String dateValStr = String.valueOf(dateValue);

    //             if(fieldType == 'DATETIME') {
    //                 dateValStr += 'T00:00:00.000Z';
    //             }

    //             if(matchingRule == 'Less than') {
    //                 operator = ' < ';
    //             }

    //             deleteWhereClause += ' ' + deleteField + operator + dateValStr + ' AND';
    //             memberWhereClause += ' ' + memberField + operator + dateValStr + ' AND';
    //         } else if(fieldType == 'INTEGER' || fieldType == 'DOUBLE' || fieldType == 'PERCENT') {
    //             String operator = ' >= ';

    //             if(matchingRule == 'Less than') {
    //                 operator = ' < ';
    //             }

    //             deleteWhereClause += ' ' + deleteField + operator + numValue + ' AND';
    //             memberWhereClause += ' ' + memberField + operator + numValue + ' AND';
    //         } else if(fieldType == 'MULTIPICKLIST') {
    //             String textVal = String.escapeSingleQuotes(textValue);
    //             textVal = '(\'' + textVal.replace(';', '\',\'') + '\')';

    //             String operator = ' includes ';

    //             if(matchingRule == 'Exclusion') {
    //                 operator = ' excludes ';
    //             }

    //             deleteWhereClause += ' ' + deleteField + operator + textVal + ' AND';
    //             memberWhereClause += ' ' + memberField + operator + textVal + ' AND';
    //         } else if(fieldType == 'PICKLIST' || fieldType == 'STRING' || fieldType == 'EMAIL') {
    //             List<String> textVals = String.escapeSingleQuotes(textValue).split(';');
    //             String operator = ' = ';

    //             if(matchingRule == 'Exclusion') {
    //                 operator = ' != ';
    //             }

    //             String textValWhereClause = ' (';
    //             String textValDeleteWhereClause = ' (';

    //             for(String textVal : textVals) {
    //                 textValDeleteWhereClause += ' ' + deleteField + operator + '\'' + textVal + '\'';
    //                 textValWhereClause += ' ' + memberField + operator + '\'' + textVal + '\'';

    //                 if(matchingRule == 'Exclusion'){
    //                     textValDeleteWhereClause += ' AND';
    //                     textValWhereClause += ' AND';
    //                 } else {
    //                     textValDeleteWhereClause += ' OR';
    //                     textValWhereClause += ' OR';
    //                 }
    //             }

    //             if(matchingRule == 'Exclusion'){
    //                 textValDeleteWhereClause = textValDeleteWhereClause.removeEnd(' AND');
    //                 textValWhereClause = textValWhereClause.removeEnd(' AND');
    //             } else {
    //                 textValDeleteWhereClause = textValDeleteWhereClause.removeEnd(' OR');
    //                 textValWhereClause = textValWhereClause.removeEnd(' OR');
    //             }

    //             textValDeleteWhereClause += ') AND';
    //             textValWhereClause += ') AND';

    //             deleteWhereClause += textValDeleteWhereClause;
    //             memberWhereClause += textValWhereClause;
    //         } else if (fieldType == 'CUSTOM') {
    //             String customClause = ' (' + customValue + ') AND';

    //             deleteWhereClause += customClause;
    //             memberWhereClause += customClause;
    //         }
    //     }

    //     //access checks
    //     Map<String, Map<String, List<String>>> generateSoqlQueriesAccess = new Map<String, Map<String, List<String>>> {
    //         'Learner_Profile__c' => new Map<String, List<String>> {
    //             'Read' => new List<String> {
    //                 'Id'
    //             }
    //         },
    //         'Partner_Profile__c' => new Map<String, List<String>> {
    //             'Read' => new List<String>()
    //         }
    //     };

    //     //generateSoqlQueriesAccess.get('Learner_Profile__c').get('Read').addAll(lpFields);
    //     //generateSoqlQueriesAccess.get('Partner_Profile__c').get('Read').addAll(ppFields);
    //     //generateSoqlQueriesAccess.put((isPartner ? 'Partner_' : '') + 'Audience_Member__c', new Map<String, List<String>>{'Read' => new List<String>{'Id'}});
    //     //checkAccess(generateSoqlQueriesAccess, true);

    //     String escapedLastProcessedLearnerName = String.escapeSingleQuotes(lastProcessedLearnerName);
    //     if(isPreview) {
    //         lpFields.add('Id');
    //         lpFields.add('Name');
    //         lpFields.add(constants.NAMESPACE_API + 'Email__c');
    //         lpFields.add('User__r.Manager.Name');
    //         lpFields.add('User__r.Manager.Email');

    //         memberQuery = 'SELECT ' + String.join(new List<String>(lpFields), ',');

    //         if(!ppFields.isEmpty()) {
    //             memberQuery += ',';
    //             for(String field : ppFields) {
    //                 memberQuery += namespaceApi + 'Partner_Profile__r.' + field + ',';
    //             }
    //             memberQuery = memberQuery.removeEnd(',');
    //         }

    //         memberQuery += ' FROM ' + namespaceApi + 'Learner_Profile__c';
    //         memberWhereClause += ' Name > ' + '\'' + escapedLastProcessedLearnerName + '\'';
    //         memberWhereClause = memberWhereClause.removeEnd('AND');    
    //     } else if(cohortCreationBatch.cohortBatchRunning){
    //         memberWhereClause += ' Id > :lastProcessedLearnerId';
    //     } else {
    //         memberWhereClause += ' Id NOT IN :existingMemberIds';
    //     }

    //     memberWhereClause += (memberWhereClause.trim().endsWith('WHERE') ? ' ' : (memberWhereClause.contains('WHERE') ? ' AND ' : ' WHERE '));
        
    //     if(!isPartner) {
    //         memberWhereClause += namespaceApi + 'Partner_Profile__c = null';
    //     } else{
    //         memberWhereClause += namespaceApi + 'Partner_Profile__c != null AND ' + namespaceApi + 'Partner_Profile__r.' + namespaceApi + 'Status__c = \'Active\'';
    //     }

    //     memberWhereClause += ' AND ' + namespaceApi + 'Status__c = \'Active\'';

    //     deleteWhereClause = deleteWhereClause.removeEnd('AND');

    //     deleteWhereClause += ')) AND ' + namespaceApi + (isPartner ? 'Partner_' : '')  + 'Audience__c = :audienceId';

    //     deleteQuery += deleteWhereClause;
    //     deleteQuery += ' LIMIT 4501';

    //     if(memberWhereClause.trim() != 'WHERE'){
    //         memberQuery += memberWhereClause;
    //     }
    //     System.debug('*************** audience ' + cohortCreationBatch.cohortBatchRunning);
    //     if(isPreview) {
    //         memberQuery += ' ORDER BY Name LIMIT 1000';
    //     } else if(cohortCreationBatch.cohortBatchRunning){
    //         memberQuery += ' ORDER BY Id ASC';
    //         memberQuery += ' LIMIT 4501';
    //     } else {
    //         memberQuery += ' LIMIT 4501';
    //     }

    //     queries.put('memberQuery', memberQuery);
    //     queries.put('deleteQuery', deleteQuery);

    //     System.debug('memberQuery: ' + memberQuery);

    //     return queries;
    // }

    // public static Map<String, String> generateSoqlQueries(List<sObject> criterias, Boolean isPreview){
    //     return generateSoqlQueries(criterias, isPreview, '');
    // }

    // private static void checkAccess(Map<String, Map<String, List<String>>> accessChecks, Boolean appendNamespace){
    //     dmlManager.checkAccess(accessChecks, appendNamespace);
    // }
}