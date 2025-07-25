/**
 * @File Name          : ExceptionUtility.cls
 * @Description        : 
 * @Author             : shantanu.bansal@salesforce.com
 * @Group              : 
 * @Last Modified By   : shantanu.bansal@salesforce.com
 * @Last Modified On   : 6/18/2020, 12:00:00 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/17/2020   shantanu.bansal@salesforce.com     v2
**/
public with sharing class ExceptionUtility {
    public static Boolean LOG_ENABLED = true;
    public class SDException extends Exception {}
    

    /* Remove ACT 1 references
    public static void logError(String appName, String className, 
            String objectName, String errMsg) {
        
        slj__Integration_Error__c error = createErrorLog(appName, className, objectName, errMsg);
        List<slj__Integration_Error__c> errorList = new List<slj__Integration_Error__c>();
        errorList.add(error);
        insertErrorLogs(errorList);

    }

    public static slj__Integration_Error__c createErrorLog(String appName, String className, 
            String objectName, String errMsg) {
        
        System.debug(LoggingLevel.ERROR, 'Creating Error Log ....');
        String template = 'Application Name:: {0} Class Name:: {1} Object Name:: {2} Error Message:: {3}';
        List<String> parameters = new List<String>{appName,className,objectName,errMsg};
        slj__Integration_Error__c errorMsg = new  slj__Integration_Error__c();
        errorMsg.slj__Error_Message__c = String.format(template, parameters);
        return errorMsg;        
    }

    public static void insertErrorLogs(List<slj__Integration_Error__c> errorList) {
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
    */
}