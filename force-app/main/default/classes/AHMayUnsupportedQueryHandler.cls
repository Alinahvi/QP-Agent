public class AHMayUnsupportedQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            String unsupportedAttribute = '';
            if (queryData.containsKey('QUERY_ATTRIBUTE')) {
                unsupportedAttribute = (String)queryData.get('QUERY_ATTRIBUTE');
            }
            
            result.success = true;
            result.totalRecords = 0;
            result.message = 'I\'m sorry, but I can\'t search for employees based on "' + unsupportedAttribute + 
                          '" as that information is not available in our employee database.\n\n' +
                          'You can search based on:\n' +
                          '- Location (Division, Country, Office)\n' +
                          '- Role (Job Family, Business Unit, Job Code)\n' +
                          '- Type (FTE, Contractor, Commissionable)\n' +
                          '- Reporting structure (direct reports, organization hierarchy)\n\n' +
                          'Try asking: "What employee data fields do you have?" to see all available search criteria.';
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing query: ' + e.getMessage();
        }
        
        return result;
    }
}