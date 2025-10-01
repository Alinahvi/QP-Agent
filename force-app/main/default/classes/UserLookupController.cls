public with sharing class UserLookupController {
    @AuraEnabled(cacheable=true)
    public static List<User> findUsers(String searchTerm) {
        if (!Schema.sObjectType.User.isAccessible()) return new List<User>();
        String term = '%' + (searchTerm == null ? '' : searchTerm) + '%';
        return [SELECT Id, Name FROM User WHERE Name LIKE :term ORDER BY Name LIMIT 20];
    }
}