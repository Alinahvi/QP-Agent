public with sharing class ResponseData { 
    @AuraEnabled public Boolean isSuccess;
    @AuraEnabled public Map<String, Object> results;
    @AuraEnabled public String errMsg;
    @AuraEnabled public String stack;
    @AuraEnabled public Integer lineNumber;

    public ResponseData() {
        this.isSuccess = true;
        this.results = new Map<String, Object>();
    }

    public void addError(String errMsg){
        this.errMsg = errMsg;
        this.isSuccess = false;
    }

    public void addError(Exception e){
        System.debug('******************* error msg: ' + e.getCause());
        System.debug('******************* error msg: ' + e.getMessage());
        System.debug('******************* error line: ' + e.getLineNumber());
        System.debug('******************* error stack: ' + e.getStackTraceString());
        String errMsg = utilities.getErrorMessage(e);

        this.stack = e.getStackTraceString();
        this.lineNumber = e.getLineNumber();
        this.errMsg = errMsg;
        this.isSuccess = false;
    }

    public void put(String key, Object val){
        results.put(key, val);
    }

    public String getJsonString() {
        return JSON.serialize(this);
    }
}