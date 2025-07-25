public with sharing class FRAgentAPMAssetService {
    /**
     * Searches for Course__c and Curriculum__c records based on criteria
     * @param params Map containing search criteria (keyword, ownerId, status, createdDate, recordLimit, offset)
     * @return Map with keys: success (Boolean), message (String), records (List<FRAgentAPMAssetWrapper>)
     */
    public static Map<String, Object> search(Map<String, Object> params) {
        Map<String, Object> result = new Map<String, Object>();
        List<FRAgentAPMAssetWrapper> assets = new List<FRAgentAPMAssetWrapper>();
        String summary = '';
        try {
            String keyword = (String)params.get('keyword');
            String ownerId = (String)params.get('ownerId');
            String status = (String)params.get('status');
            String createdDate = (String)params.get('createdDate');
            Integer recordLimit = (Integer)params.get('recordLimit');
            Integer offset = (Integer)params.get('offset');
            if (recordLimit == null || recordLimit <= 0) recordLimit = 10;
            if (offset == null || offset < 0) offset = 0;

            // Build Course__c query
            String courseQuery = 'SELECT Id, Name, Status__c, Share_Url__c, Description__c, OwnerId, CreatedDate FROM Course__c WHERE IsDeleted = false';
            List<String> courseConds = new List<String>();
            if (String.isNotBlank(keyword)) {
                courseConds.add('(Name LIKE :kw OR Description__c LIKE :kw)');
            }
            if (String.isNotBlank(ownerId)) {
                courseConds.add('OwnerId = :ownerId');
            }
            if (String.isNotBlank(status)) {
                courseConds.add('Status__c = :status');
            }
            if (String.isNotBlank(createdDate)) {
                String normalizedDate = createdDate.trim().toLowerCase();
                if (normalizedDate == 'last 6 months' || normalizedDate == 'past 6 months') {
                    createdDate = 'LAST_N_MONTHS:6';
                } else if (normalizedDate == 'last year' || normalizedDate == 'past year') {
                    createdDate = 'LAST_N_YEARS:1';
                } else if (normalizedDate == 'last month' || normalizedDate == 'past month') {
                    createdDate = 'LAST_N_MONTHS:1';
                } else if (normalizedDate == 'this month') {
                    createdDate = 'THIS_MONTH';
                } else if (normalizedDate == 'this year') {
                    createdDate = 'THIS_YEAR';
                }
                String dateFilter = '';
                // Direct date (YYYY-MM-DD)
                if (Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', createdDate)) {
                    try {
                        Date singleDate = Date.valueOf(createdDate);
                        dateFilter = FRAGENTUtility.buildDateRangeClause('CreatedDate', singleDate, singleDate);
                    } catch (Exception ex) {
                        result.put('success', false);
                        result.put('message', 'Invalid date format for createdDate. Please use YYYY-MM-DD, YYYY-MM, a date range (YYYY-MM-DD:YYYY-MM-DD), or phrases like "last 6 months".');
                        return result;
                    }
                // Date range (YYYY-MM-DD:YYYY-MM-DD)
                } else if (createdDate.contains(':')) {
                    List<String> parts = createdDate.split(':');
                    if (parts.size() == 2 && Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', parts[0]) && Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', parts[1])) {
                        try {
                            Date startDate = Date.valueOf(parts[0]);
                            Date endDate = Date.valueOf(parts[1]);
                            dateFilter = FRAGENTUtility.buildDateRangeClause('CreatedDate', startDate, endDate);
                        } catch (Exception ex) {
                            result.put('success', false);
                            result.put('message', 'Invalid date range for createdDate. Please use YYYY-MM-DD:YYYY-MM-DD.');
                            return result;
                        }
                    } else {
                        // Not a valid date range, try as a literal
                        dateFilter = FRAGENTUtility.parseDateFilter('CreatedDate', createdDate);
                    }
                } else {
                    // Use as a Salesforce date literal
                    dateFilter = FRAGENTUtility.parseDateFilter('CreatedDate', createdDate);
                }
                if (String.isNotBlank(dateFilter)) {
                    courseConds.add(dateFilter);
                }
            }
            if (!courseConds.isEmpty()) {
                courseQuery += ' AND ' + String.join(courseConds, ' AND ');
            }
            courseQuery += ' ORDER BY Name ASC LIMIT :recordLimit OFFSET :offset';

            // Build Curriculum__c query
            String currQuery = 'SELECT Id, Name, Status__c, Share_Url__c, Description__c, OwnerId, CreatedDate FROM Curriculum__c WHERE IsDeleted = false';
            List<String> currConds = new List<String>();
            if (String.isNotBlank(keyword)) {
                currConds.add('(Name LIKE :kw OR Description__c LIKE :kw)');
            }
            if (String.isNotBlank(ownerId)) {
                currConds.add('OwnerId = :ownerId');
            }
            if (String.isNotBlank(status)) {
                currConds.add('Status__c = :status');
            }
            if (String.isNotBlank(createdDate)) {
                String normalizedDate = createdDate.trim().toLowerCase();
                if (normalizedDate == 'last 6 months' || normalizedDate == 'past 6 months') {
                    createdDate = 'LAST_N_MONTHS:6';
                } else if (normalizedDate == 'last year' || normalizedDate == 'past year') {
                    createdDate = 'LAST_N_YEARS:1';
                } else if (normalizedDate == 'last month' || normalizedDate == 'past month') {
                    createdDate = 'LAST_N_MONTHS:1';
                } else if (normalizedDate == 'this month') {
                    createdDate = 'THIS_MONTH';
                } else if (normalizedDate == 'this year') {
                    createdDate = 'THIS_YEAR';
                }
                String dateFilter = '';
                // Direct date (YYYY-MM-DD)
                if (Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', createdDate)) {
                    try {
                        Date singleDate = Date.valueOf(createdDate);
                        dateFilter = FRAGENTUtility.buildDateRangeClause('CreatedDate', singleDate, singleDate);
                    } catch (Exception ex) {
                        result.put('success', false);
                        result.put('message', 'Invalid date format for createdDate. Please use YYYY-MM-DD, YYYY-MM, a date range (YYYY-MM-DD:YYYY-MM-DD), or phrases like "last 6 months".');
                        return result;
                    }
                // Date range (YYYY-MM-DD:YYYY-MM-DD)
                } else if (createdDate.contains(':')) {
                    List<String> parts = createdDate.split(':');
                    if (parts.size() == 2 && Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', parts[0]) && Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', parts[1])) {
                        try {
                            Date startDate = Date.valueOf(parts[0]);
                            Date endDate = Date.valueOf(parts[1]);
                            dateFilter = FRAGENTUtility.buildDateRangeClause('CreatedDate', startDate, endDate);
                        } catch (Exception ex) {
                            result.put('success', false);
                            result.put('message', 'Invalid date range for createdDate. Please use YYYY-MM-DD:YYYY-MM-DD.');
                            return result;
                        }
                    } else {
                        // Not a valid date range, try as a literal
                        dateFilter = FRAGENTUtility.parseDateFilter('CreatedDate', createdDate);
                    }
                } else {
                    // Use as a Salesforce date literal
                    dateFilter = FRAGENTUtility.parseDateFilter('CreatedDate', createdDate);
                }
                if (String.isNotBlank(dateFilter)) {
                    currConds.add(dateFilter);
                }
            }
            if (!currConds.isEmpty()) {
                currQuery += ' AND ' + String.join(currConds, ' AND ');
            }
            currQuery += ' ORDER BY Name ASC LIMIT :recordLimit OFFSET :offset';

            // Query Courses
            List<Course__c> courses = new List<Course__c>();
            if (String.isNotBlank(keyword)) {
                courses = Database.query(courseQuery.replace(':kw', '\'' + '%' + keyword + '%' + '\'').replace(':ownerId', '\'' + ownerId + '\'').replace(':status', '\'' + status + '\'').replace(':recordLimit', String.valueOf(recordLimit)).replace(':offset', String.valueOf(offset)));
            } else {
                courses = Database.query(courseQuery.replace(':ownerId', '\'' + ownerId + '\'').replace(':status', '\'' + status + '\'').replace(':recordLimit', String.valueOf(recordLimit)).replace(':offset', String.valueOf(offset)));
            }
            for (Course__c c : courses) {
                assets.add(new FRAgentAPMAssetWrapper(c.Id, c.Name, 'Course', c.Status__c, c.Share_Url__c, c.Description__c));
            }

            // Query Curriculums
            List<Curriculum__c> curriculums = new List<Curriculum__c>();
            if (String.isNotBlank(keyword)) {
                curriculums = Database.query(currQuery.replace(':kw', '\'' + '%' + keyword + '%' + '\'').replace(':ownerId', '\'' + ownerId + '\'').replace(':status', '\'' + status + '\'').replace(':recordLimit', String.valueOf(recordLimit)).replace(':offset', String.valueOf(offset)));
            } else {
                curriculums = Database.query(currQuery.replace(':ownerId', '\'' + ownerId + '\'').replace(':status', '\'' + status + '\'').replace(':recordLimit', String.valueOf(recordLimit)).replace(':offset', String.valueOf(offset)));
            }
            for (Curriculum__c cu : curriculums) {
                assets.add(new FRAgentAPMAssetWrapper(cu.Id, cu.Name, 'Curriculum', cu.Status__c, cu.Share_Url__c, cu.Description__c));
            }
            // Format summary with bullet points
            Integer maxToShow = (recordLimit != null && recordLimit > 0) ? recordLimit : 10;
            Integer count = Math.min(assets.size(), maxToShow);
            for (Integer i = 0; i < count; i++) {
                FRAgentAPMAssetWrapper a = assets[i];
                summary += '- ' + a.assetType + ' Name: ' + (a.assetName != null ? a.assetName : '(none)') + '\n'
                    + '  Status: ' + (a.status != null ? a.status : '(none)') + '\n'
                    + '  Description: ' + (a.description != null ? a.description : '(none)') + '\n'
                    + '  Link: ' + (a.shareUrl != null ? a.shareUrl : '(none)') + '\n\n';
            }
            if (assets.size() > maxToShow) {
                summary += '- More assets available...\n  There are more than ' + String.valueOf(maxToShow) + ' results. Would you like to see more?';
            }
            // If no assets found, return a friendly message
            if (assets.isEmpty()) {
                result.put('success', true);
                result.put('records', assets);
                result.put('summary', null);
                result.put('message', 'No assets found for the given criteria.');
                return result;
            }
            result.put('success', true);
            result.put('records', assets);
            result.put('summary', summary);
            result.put('message', 'Found ' + assets.size() + ' assets.');
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Sorry, something went wrong while searching for assets. ' + e.getMessage());
        }
        return result;
    }

    /**
     * Retrieves a Course__c or Curriculum__c by Id, checks for existence and active status
     * @param assetId The Id of the asset
     * @param assetType (optional) 'Course' or 'Curriculum' (if known)
     * @return Map with keys: success (Boolean), message (String), asset (FRAgentAPMAssetWrapper)
     */
    public static Map<String, Object> retrieveById(Id assetId, String assetType) {
        Map<String, Object> result = new Map<String, Object>();
        FRAgentAPMAssetWrapper asset = null;
        try {
            SObject record;
            String type = assetType;
            if (type == null) {
                // Try to infer type from Id prefix
                String prefix = String.valueOf(assetId).substring(0,3);
                if (Schema.getGlobalDescribe().get('Course__c').getDescribe().getKeyPrefix() == prefix) {
                    type = 'Course';
                } else if (Schema.getGlobalDescribe().get('Curriculum__c').getDescribe().getKeyPrefix() == prefix) {
                    type = 'Curriculum';
                }
            }
            if (type == 'Course') {
                List<Course__c> courses = [SELECT Id, Name, Status__c, Share_Url__c, Description__c FROM Course__c WHERE Id = :assetId AND IsDeleted = false LIMIT 1];
                if (courses.isEmpty()) {
                    result.put('success', false);
                    result.put('message', 'Asset not found: ID does not exist.');
                    return result;
                }
                Course__c c = courses[0];
                if (c.Status__c != 'Active') {
                    result.put('success', false);
                    result.put('message', 'Asset is not active/outdated.');
                    return result;
                }
                asset = new FRAgentAPMAssetWrapper(c.Id, c.Name, 'Course', c.Status__c, c.Share_Url__c, c.Description__c);
            } else if (type == 'Curriculum') {
                List<Curriculum__c> curriculums = [SELECT Id, Name, Status__c, Share_Url__c, Description__c FROM Curriculum__c WHERE Id = :assetId AND IsDeleted = false LIMIT 1];
                if (curriculums.isEmpty()) {
                    result.put('success', false);
                    result.put('message', 'Asset not found: ID does not exist.');
                    return result;
                }
                Curriculum__c cu = curriculums[0];
                if (cu.Status__c != 'Active') {
                    result.put('success', false);
                    result.put('message', 'Asset is not active/outdated.');
                    return result;
                }
                asset = new FRAgentAPMAssetWrapper(cu.Id, cu.Name, 'Curriculum', cu.Status__c, cu.Share_Url__c, cu.Description__c);
            } else {
                result.put('success', false);
                result.put('message', 'Asset type could not be determined.');
                return result;
            }
            result.put('success', true);
            result.put('asset', asset);
            result.put('message', 'Asset found and is active.');
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Sorry, something went wrong while retrieving the asset. Please try again or contact support.');
        }
        return result;
    }

    public class AssetSearchInput {
        @InvocableVariable public String keyword;
        @InvocableVariable public String ownerId;
        @InvocableVariable public String status;
        @InvocableVariable public String createdDate;
        @InvocableVariable public Integer recordLimit;
        @InvocableVariable public Integer offset;
    }
    public class AssetSearchOutput {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public String summary;
    }
    @InvocableMethod(label='Search APM Assets' description='Searches for APM assets for agent')
    public static List<AssetSearchOutput> invocableSearch(List<AssetSearchInput> inputs) {
        List<AssetSearchOutput> results = new List<AssetSearchOutput>();
        for (AssetSearchInput input : inputs) {
            Map<String, Object> params = new Map<String, Object>{
                'keyword' => input.keyword,
                'ownerId' => input.ownerId,
                'status' => input.status,
                'createdDate' => input.createdDate,
                'recordLimit' => input.recordLimit,
                'offset' => input.offset
            };
            Map<String, Object> result = search(params);
            AssetSearchOutput out = new AssetSearchOutput();
            out.success = (Boolean)result.get('success');
            out.message = (String)result.get('message');
            out.summary = (String)result.get('summary');
            results.add(out);
        }
        return results;
    }
}