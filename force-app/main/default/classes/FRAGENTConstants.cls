/**
 * Constants class for the Field Readiness Agent
 * 
 * This class provides centralized constants and configuration values
 * used throughout the Field Readiness Agent application.
 * 
 * Key Features:
 * - Success and error message templates
 * - Configuration limits and defaults
 * - Validation constants
 * - Business rule constants
 * 
 * @author Field Readiness Agent Team
 * @version 2.0
 */
public with sharing class FRAGENTConstants {
    
    // Action Types
    public static final String ACTION_CREATE = 'Create';
    public static final String ACTION_MODIFY = 'Modify';
    public static final String ACTION_RETRIEVE = 'Retrieve';
    public static final String ACTION_SEARCH = 'Search';
    public static final String ACTION_INACTIVATE = 'Inactivate';
    
    // Limits
    public static final Integer MAX_SEARCH_RESULTS = 500;
    public static final Integer MAX_BULK_RECORDS = 200;
    public static final Integer MAX_QUERY_ROWS = 50000;
    
    // Error Messages
    public static final String ERROR_REQUIRED_FIELD = 'Required field is missing: ';
    public static final String ERROR_INVALID_ACTION = 'Invalid action type: ';
    public static final String ERROR_RECORD_NOT_FOUND = 'Record not found with ID: ';
    public static final String ERROR_DUPLICATE_RECORD = 'Duplicate record already exists.';
    public static final String ERROR_FUTURE_DATE_REQUIRED = 'Start Date must be in the future.';
    public static final String ERROR_EXACTLY_ONE_CONTENT = 'Exactly one content ID (Asset, Course, or Curriculum) must be provided.';
    
    // Success Messages
    public static final String SUCCESS_CREATED = 'Record created successfully.';
    public static final String SUCCESS_UPDATED = 'Record updated successfully.';
    public static final String SUCCESS_RETRIEVED = 'Record retrieved successfully.';
    public static final String SUCCESS_SEARCH = 'Search executed successfully. Records found: ';
    public static final String SUCCESS_INACTIVATED = 'Record inactivated successfully.';
    
    // Content Distribution Organizations
    public static final Set<String> VALID_CONTENT_DISTRIBUTION_ORGS = new Set<String>{
        'Business Technology', 'Corporate Marketing', 'CSG - Customer Success', 
        'CSG - Partners', 'CSG - Professional Services', 'Employee Learning', 
        'Employee Success', 'Equality', 'Field Marketing', 'Finance', 
        'Global Business Services', 'Global Enablement', 'Global Recruiting', 
        'Global Safety & Security', 'GO Center', 'Japan Enablement', 'Legal', 
        'Mulesoft', 'OU Leader', 'Product Marketing', 
        'Real Estate & Workspaces Services (REWS)', 'Salesforce.org', 
        'Sales Programs', 'Sales Strategy', 'Security', 'SEED', 'Slack', 
        'Tableau', 'Talent Marketplace', 'TMP', 'Trailhead', 'Trust'
    };
    
    // Frequency Values
    public static final Set<String> VALID_FREQUENCIES = new Set<String>{
        'Daily', 'Weekly', 'Monthly', 'Annually'
    };
    
    // Weekday Values
    public static final Set<String> VALID_WEEKDAYS = new Set<String>{
        'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    };
    
    // Object API Names
    public static final String OBJECT_ASSIGNED_LEARNING = 'Assigned_Learning__c';
    public static final String OBJECT_AUDIENCE = 'Audience__c';
    public static final String OBJECT_AUDIENCE_MEMBER = 'Audience_Member__c';
    public static final String OBJECT_CHECKLIST = 'Checklist__c';
    public static final String OBJECT_CHECKLIST_ASSET = 'Checklist_Asset__c';
    public static final String OBJECT_AUDIENCE_CHECKLIST = 'Audience_Checklist__c';
    
    // Field API Names - Assigned Learning
    public static final String FIELD_AUDIENCE = 'Audience__c';
    public static final String FIELD_ASSET = 'Asset__c';
    public static final String FIELD_COURSE = 'Course__c';
    public static final String FIELD_CURRICULUM = 'Curriculum__c';
    public static final String FIELD_DUE_DATE = 'Due_Date__c';
    public static final String FIELD_START_DATE = 'Start_Date__c';
    public static final String FIELD_RECUR = 'Recur__c';
    public static final String FIELD_FREQUENCY = 'Frequency__c';
    public static final String FIELD_FREQUENCY_WEEKDAY = 'Frequency_Weekday__c';
    public static final String FIELD_CONTENT_DISTRIBUTION_ORG = 'Content_Distribution_Organization__c';
    
    // Field API Names - Audience Member
    public static final String FIELD_LEARNER_PROFILE = 'Learner_Profile__c';
    public static final String FIELD_MANUALLY_ADDED = 'Manually_Added__c';
    
    // Date Formats
    public static final String DATE_FORMAT_YYYY_MM_DD = 'yyyy-MM-dd';
    public static final String DATETIME_FORMAT_ISO = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    
    // Validation Patterns
    public static final String PATTERN_SALESFORCE_ID = '^[a-zA-Z0-9]{15,18}$';
    public static final String PATTERN_DATE_YYYY_MM_DD = '^\\d{4}-\\d{2}-\\d{2}$';
    
    /**
     * Validates if a content distribution organization is valid
     */
    public static Boolean isValidContentDistributionOrg(String org) {
        return String.isNotBlank(org) && VALID_CONTENT_DISTRIBUTION_ORGS.contains(org);
    }
    
    /**
     * Validates if a frequency value is valid
     */
    public static Boolean isValidFrequency(String frequency) {
        return String.isNotBlank(frequency) && VALID_FREQUENCIES.contains(frequency);
    }
    
    /**
     * Validates if a weekday value is valid
     */
    public static Boolean isValidWeekday(String weekday) {
        return String.isNotBlank(weekday) && VALID_WEEKDAYS.contains(weekday);
    }
    
    /**
     * Validates if a Salesforce ID format is valid
     */
    public static Boolean isValidSalesforceId(String id) {
        return String.isNotBlank(id) && Pattern.matches(PATTERN_SALESFORCE_ID, id);
    }
    
    /**
     * Validates if a date string is in YYYY-MM-DD format
     */
    public static Boolean isValidDateFormat(String dateStr) {
        return String.isNotBlank(dateStr) && Pattern.matches(PATTERN_DATE_YYYY_MM_DD, dateStr);
    }
}