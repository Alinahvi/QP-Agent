public with sharing class em_resultObj {
    private Boolean success = true;
    // private List<Object> successList = new List<Object>();
    private String errorMessage = '';
    private List<String> errorList = new List<String>();
    private Id objectId;
    private String appName = 'SOSI_APP';
    private Boolean hasErrors = false;
    private String className  = '';
    private String methodName = '';

    
    public em_resultObj(String app, Boolean s, String eMsg, Id objId, String cName, String mName) {
        appName = app;
        success = s;
        errorMessage = eMsg;
        hasErrors = false;
        objectId = objId;
        className = cName;
        methodName = mName;             
    }

    public em_resultObj(String app, Boolean s, List<String> eMsg, Id objId, String cName, String mName) {
        appName = app;
        success = s;
        errorList.addAll(eMsg);
        hasErrors = true;
        objectId = objId;
        className = cName;
        methodName = mName;              
    }

    public Id getId() { return objectId;}
    public Boolean isSuccess() {return success;}
    public String getErrorMessage() {return errorMessage;}
    public List<String> getErrorList() {return errorList;}
    public Boolean hasErrors() {return hasErrors;}
}