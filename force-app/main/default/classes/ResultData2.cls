public virtual inherited sharing class ResultData2 {

    @AuraEnabled public String status  = MediaConstants.STATUS_SUCCESS;
    @AuraEnabled public String message = '';
    @AuraEnabled public String data    = '';

    @AuraEnabled public String errorLog = '';

    public ResultData2() {

    }

    public void setData(Object data) {
        this.data = JSON.serialize(data);
    }

    public void setResultStatusAndMessage(String status, String message, Exception e) {
        this.status  = status;
        this.message = message;

        if (e != null) {
            this.errorLog = 'Error Type: ' + e.getTypeName() +
                            '\nError Message: ' + e.getMessage() +
                            '\nError Stack Trace: ' + e.getStackTraceString();
        }
    }
}