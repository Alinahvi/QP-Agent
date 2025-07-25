public class AHMayQueryRequest {
    @InvocableVariable(required=true)
    public String userInput;
    
    @InvocableVariable(required=false)
    public Integer pageNumber;
    
    @InvocableVariable(required=false)
    public String sessionId;
    
    @InvocableVariable(required=false)
    public String queryMode; // Add this new field for BULK or LARGE_DATASET processing
}