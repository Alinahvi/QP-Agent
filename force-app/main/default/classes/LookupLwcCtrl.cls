public with sharing class LookupLwcCtrl {

    private static final String USER_TYPE_INTERNAL          = 'Internal';
    private static final String USER_TYPE_COMMUNITY         = 'Community';
    private static final String USER_TYPE_PORTAL            = 'PortalUser';
    private static final String USER_TYPE_PARTNER           = 'PartnerUser';
    private static final String PROFILE_TYPE_INTERNAL       = 'ProfileInternal';
    private static final String PROFILE_TYPE_EXTERNAL       = 'ProfileExternal';
    private static final String API_NAME_PROFILE            = 'Profile';
    private static final String API_NAME_ROLE               = 'UserRole';
    /**
     * Aura enabled method to search a specified SObject for a specific string
     *
     * @return LookupWrapper[] - Array of results
     */
    @AuraEnabled
    public static ResultData lookup(
        String searchString,
        String sObjectAPIName,
        String userType,
        List<String> excludeIds,
        String sortField,
        String sortFieldValue,
        String addCondition,
        String searchLimit
    ) {

        ResultData result = new ResultData();

        // Sanitize the input
        String sanitizedSearchString    = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName  = String.escapeSingleQuotes(sObjectAPIName);
        String searchLimitString        = String.escapeSingleQuotes(searchLimit);
        Set<String> excludeIdsSet       = new Set<String>(excludeIds);
        Set<String> internalUserTypes   = new Set<String>{'Standard'};
        Set<String> portalUserTypes     = new Set<String>{'CSPLitePortal', 'PowerCustomerSuccess'};
        Set<String> partnerUserTypes    = new Set<String>{'PowerPartner' , 'CustomerSuccess'};
        Set<String> communityUserTypes  = new Set<String>{};
        Set<String> availableUserTypes  = new Set<String>{};

        communityUserTypes.addAll(portalUserTypes);
        communityUserTypes.addAll(partnerUserTypes);
        availableUserTypes.addAll(internalUserTypes);
        availableUserTypes.addAll(communityUserTypes);

        String sortingLine = '';

        if (!String.isBlank(sortField) && !String.isBlank(sortFieldValue)) {
            if (sortFieldValue == PROFILE_TYPE_INTERNAL) {
                sortingLine = ' AND ' + sortField + ' IN :internalUserTypes ';
            } else if (sortFieldValue == PROFILE_TYPE_EXTERNAL) {
                sortingLine = ' AND ' + sortField + ' IN :communityUserTypes ';
            } else {
                sortingLine = ' AND ' + sortField + ' = :sortFieldValue ';
            }
        }

        List<LookupWrapper> results = new List<LookupWrapper>();


        String searchQuery = 'SELECT Id, Name FROM '
            + sanitizedSObjectAPIName
            + ' WHERE Name LIKE \'%' + sanitizedSearchString + ' %\''
            + ' AND Id NOT IN :excludeIdsSet '
            + ' WITH SECURITY_ENFORCED '
            + ' LIMIT ' + searchLimitString;

        try {
            for (SObject so : Database.query(searchQuery)) {
                results.add(new LookupWrapper((String) so.get('Name'), so.Id, null));
            }

            result.setData(results);
        } catch (QueryException e) {
            result.setResultStatusAndMessage(MediaConstants.STATUS_ACCESS_DENIED, e.getMessage(), e);
        }

        return result;
    }

    @AuraEnabled
    public static ResultData lookupById (String recordId, String sObjectAPIName) {
        ResultData result = new ResultData();

        // Sanitize the input
        String sanitizedId              = String.escapeSingleQuotes(recordId);
        String sanitizedSObjectAPIName  = String.escapeSingleQuotes(sObjectAPIName);

        // Build our SOSL query
        String searchQuery = 'SELECT Id, Name FROM '
            + sanitizedSObjectAPIName
            + ' WHERE Id = :sanitizedId'
            + ' WITH SECURITY_ENFORCED'
            + ' LIMIT 1';

        try {
            List<SObject> searchList = Database.query(searchQuery);

            // Create a list of matches to return
            if (!searchList.isEmpty()) {
                SObject so  = searchList[0];

                result.setData(new LookupWrapper((String)so.get('Name'), so.Id, null));
            }
        } catch (QueryException e) {
            result.setResultStatusAndMessage(MediaConstants.STATUS_ACCESS_DENIED, e.getMessage(), e);
        }

        return result;
    }

    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class LookupWrapper
    {
        @AuraEnabled public String  SObjectAdditionalField {get; set;}
        @AuraEnabled public String  SObjectLabel {get; set;}
        @AuraEnabled public Id      SObjectId {get; set;}

        public LookupWrapper(String sObjectLabel, Id sObjectId, String SObjectAdditionalField)
        {
            this.SObjectLabel   = sObjectLabel;
            this.SObjectId      = sObjectId;
            this.SObjectAdditionalField = SObjectAdditionalField;
        }

        public LookupWrapper(String sObjectLabel, Id sObjectId) {
            this.SObjectLabel   = sObjectLabel;
            this.SObjectId      = sObjectId;
        }

    }
}