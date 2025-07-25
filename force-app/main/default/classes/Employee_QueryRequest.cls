/**
 * @description Wrapper class representing a request to the employee query system.
 * This is used as the parameter for the Invocable Method.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_QueryRequest {
    @InvocableVariable(label='User Query Text' description='The natural language query from the user.' required=true)
    public String userInput;

    @InvocableVariable(label='Session ID' description='The unique ID for the conversation session.')
    public String sessionId;
    
    @InvocableVariable(label='Page Number' description='The page number to retrieve for paginated results.')
    public Integer pageNumber;

    @InvocableVariable(label='Query Mode' description='Optional: Specify BULK or LARGE_DATASET for special processing.')
    public String queryMode;
}