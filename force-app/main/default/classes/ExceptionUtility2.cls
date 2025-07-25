public with sharing class ExceptionUtility2 {
    public static Boolean LOG_ENABLED = true;
    public class SDException extends Exception {}
    
    public static void logError(String appName) {
        logError(appName, '', '', '');
    }
    
    public static void logError(String appName, String className) {
        logError(appName, className, '', '');
    }
    
    public static void logError(String appName, String className, String ObjName) {
        logError(appName, className, ObjName, '');
    }

    public static void logError(String appName, String className, 
            String objectName, String errMsg) {
        
        Integration_Error__c error = createErrorLog(appName, className, objectName, errMsg);
        List<Integration_Error__c> errorList = new List<Integration_Error__c>();
        errorList.add(error);
        insertErrorLogs(errorList);

    }

    public static Integration_Error__c createErrorLog(String appName, String className, 
            String objectName, String errMsg) {
        
        System.debug(LoggingLevel.ERROR, 'Creating Error Log ....');
        String template = 'Application Name:: {0} Class Name:: {1} Object Name:: {2} Error Message:: {3}';
        List<String> parameters = new List<String>{appName,className,objectName,errMsg};
        Integration_Error__c errorMsg = new  Integration_Error__c();
        errorMsg.Http_Response_Body__c = String.format(template, parameters);
        return errorMsg;        
    }

    public static void insertErrorLogs(List<Integration_Error__c> errorList) {
        try {
            if(errorList != null && !errorList.isEmpty() && LOG_ENABLED) {
                insert as user errorList;
            }            
        } catch (System.Exception e) {
            String err = 'Error: on createErrorLogs '+e;
            System.debug(err); 
            System.debug(e.getCause());
            System.debug(e.getStackTraceString());
        }
    }
}