/**
 * @description MCP Integration for TSV Export functionality
 * Provides invocable method for MCP server to call TSV export
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentTSVExportViaMCP {
  
  /**
   * @description MCP TSV Export Request
   */
  public class MCPTSVExportRequest {
    @InvocableVariable(
      label='Analysis Type'
      description='Optional: Specific analysis type to export (RENEWALS, OPEN_PIPE, KPIS, etc.)'
    )
    public String analysisType;
    
    @InvocableVariable(
      label='Limit Records'
      description='Optional: Maximum number of records to export'
    )
    public Integer limitRecords;
    
    @InvocableVariable(
      label='Custom File Name'
      description='Optional: Custom file name for the export'
    )
    public String customFileName;
    
    @InvocableVariable(
      label='Request ID'
      description='Unique identifier for tracking'
    )
    public String requestId;
  }
  
  /**
   * @description MCP TSV Export Response
   */
  public class MCPTSVExportResponse {
    @InvocableVariable(label='Success' description='Whether the export was successful')
    public Boolean success;
    
    @InvocableVariable(label='Message' description='Response message')
    public String message;
    
    @InvocableVariable(label='Download URL' description='URL to download the TSV file')
    public String downloadUrl;
    
    @InvocableVariable(label='File Name' description='Name of the generated file')
    public String fileName;
    
    @InvocableVariable(label='Record Count' description='Number of records in the TSV file')
    public Integer recordCount;
    
    @InvocableVariable(label='Analysis Type' description='Type of analysis that was exported')
    public String analysisType;
    
    @InvocableVariable(label='Request ID' description='Echo of the original request ID')
    public String requestId;
  }
  
  /**
   * @description Main invocable method for MCP TSV export
   * @param requests List of MCP TSV export requests
   * @return List<MCPTSVExportResponse>
   */
  @InvocableMethod(
    label='Export Analysis as TSV via MCP'
    description='Export analysis data as TSV file via MCP integration'
  )
  public static List<MCPTSVExportResponse> exportAnalysisAsTSV(List<MCPTSVExportRequest> requests) {
    List<MCPTSVExportResponse> responses = new List<MCPTSVExportResponse>();
    
    for (MCPTSVExportRequest request : requests) {
      MCPTSVExportResponse response = new MCPTSVExportResponse();
      response.requestId = request.requestId;
      
      try {
        // Convert MCP request to generic request
        ANAgentGenericTSVExportHandler.GenericTSVExportRequest genericRequest = 
          new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
        genericRequest.analysisTypeFilter = request.analysisType;
        genericRequest.customFileName = request.customFileName;
        genericRequest.exportType = 'Full';
        genericRequest.includeMetadata = false; // Keep TSV clean for MCP
        genericRequest.requestId = request.requestId;
        
        // Call the generic TSV handler
        List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> genericResponses = 
          ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{genericRequest});
        
        if (!genericResponses.isEmpty()) {
          ANAgentGenericTSVExportHandler.GenericTSVExportResponse genericResponse = genericResponses[0];
          
          // Convert generic response to MCP response
          response.success = genericResponse.success;
          response.message = genericResponse.message;
          response.downloadUrl = genericResponse.downloadLink;
          response.fileName = genericResponse.fileName;
          response.recordCount = genericResponse.recordCount;
          response.analysisType = genericResponse.analysisType;
          
          // Apply record limit if specified
          if (request.limitRecords != null && request.limitRecords > 0 && response.recordCount > request.limitRecords) {
            response.message += '\n\nNote: Limited to ' + request.limitRecords + ' records as requested.';
            response.recordCount = request.limitRecords;
          }
        } else {
          response.success = false;
          response.message = 'No response received from TSV handler';
        }
        
      } catch (Exception e) {
        response.success = false;
        response.message = 'Error in MCP TSV export: ' + e.getMessage();
        System.debug('MCP TSV export error: ' + e.getMessage());
      }
      
      responses.add(response);
    }
    
    return responses;
  }
  
  /**
   * @description Check if there's recent analysis data available for export
   * @return Boolean indicating if data is available
   */
  public static Boolean hasRecentAnalysisData() {
    return ANAgentMemoryContext.hasAnyAnalysisData();
  }
  
  /**
   * @description Get the most recent analysis type
   * @return String The most recent analysis type
   */
  public static String getMostRecentAnalysisType() {
    Map<String, Object> recentData = ANAgentMemoryContext.getMostRecentAnalysisData();
    if (recentData != null && !recentData.isEmpty()) {
      return (String) recentData.get('analysisType');
    }
    return null;
  }
}

