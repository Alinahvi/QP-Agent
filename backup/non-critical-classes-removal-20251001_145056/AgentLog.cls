/**
 * Lightweight logging utility for Agent actions
 * Prevents heap size issues by truncating values and avoiding SObject logging
 */
public class AgentLog {
    
    private static final Boolean ENABLED = true; // Set to false in production
    private static final Integer MAX_VALUE_LENGTH = 200;
    
    public static void info(String location, String message) {
        if (ENABLED) {
            System.debug(LoggingLevel.INFO, '[AgentLog] ' + location + ': ' + message);
        }
    }
    
    public static void info(String location, String message, Map<String, Object> crumbs) {
        if (ENABLED) {
            String logMessage = '[AgentLog] ' + location + ': ' + message;
            if (crumbs != null && !crumbs.isEmpty()) {
                logMessage += ' | ' + formatCrumbs(crumbs);
            }
            System.debug(LoggingLevel.INFO, logMessage);
        }
    }
    
    public static void error(String location, String message) {
        if (ENABLED) {
            System.debug(LoggingLevel.ERROR, '[AgentLog] ' + location + ': ' + message);
        }
    }
    
    public static void error(String location, String message, Map<String, Object> crumbs) {
        if (ENABLED) {
            String logMessage = '[AgentLog] ' + location + ': ' + message;
            if (crumbs != null && !crumbs.isEmpty()) {
                logMessage += ' | ' + formatCrumbs(crumbs);
            }
            System.debug(LoggingLevel.ERROR, logMessage);
        }
    }
    
    private static String formatCrumbs(Map<String, Object> crumbs) {
        List<String> formattedCrumbs = new List<String>();
        
        for (String key : crumbs.keySet()) {
            Object value = crumbs.get(key);
            String formattedValue = formatValue(value);
            formattedCrumbs.add(key + '=' + formattedValue);
        }
        
        return String.join(formattedCrumbs, ', ');
    }
    
    private static String formatValue(Object value) {
        if (value == null) {
            return 'null';
        }
        
        String stringValue = String.valueOf(value);
        
        // Truncate long values
        if (stringValue.length() > MAX_VALUE_LENGTH) {
            stringValue = stringValue.substring(0, MAX_VALUE_LENGTH) + '...';
        }
        
        // Avoid logging SObject lists
        if (stringValue.contains('Agent_Renewals__c') && stringValue.contains('[')) {
            return '[SObject list - truncated]';
        }
        
        return stringValue;
    }
}
