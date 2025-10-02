/**
 * Agent Log Utility
 * 
 * This class provides utility methods for logging agent activities and errors.
 * It provides a simple interface for logging different types of messages.
 */
public with sharing class AgentLog {
    
    /**
     * Logs an info message
     */
    public static void info(String className, String method, Map<String, Object> context) {
        try {
            System.debug('INFO [' + className + '.' + method + ']: ' + (context != null ? JSON.serialize(context) : 'No context'));
        } catch (Exception e) {
            System.debug('Error logging info: ' + e.getMessage());
        }
    }
    
    /**
     * Logs an error message
     */
    public static void error(String className, String method, Map<String, Object> context) {
        try {
            System.debug('ERROR [' + className + '.' + method + ']: ' + (context != null ? JSON.serialize(context) : 'No context'));
        } catch (Exception e) {
            System.debug('Error logging error: ' + e.getMessage());
        }
    }
    
    /**
     * Logs a warning message
     */
    public static void warn(String className, String method, Map<String, Object> context) {
        try {
            System.debug('WARN [' + className + '.' + method + ']: ' + (context != null ? JSON.serialize(context) : 'No context'));
        } catch (Exception e) {
            System.debug('Error logging warning: ' + e.getMessage());
        }
    }
}