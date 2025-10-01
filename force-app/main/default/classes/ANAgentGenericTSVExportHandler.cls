/**
 * @description Generic TSV Export Handler that works with any analysis type
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentGenericTSVExportHandler {
  
  /**
   * @description Generic TSV Export Request
   */
  public class GenericTSVExportRequest {
    @InvocableVariable(
      label='Analysis Type Filter'
      description='Optional: Filter by specific analysis type (KPI, PIPELINE, OPEN_PIPE, etc.)'
    )
    public String analysisTypeFilter;
    
    @InvocableVariable(
      label='Custom File Name'
      description='Optional: Custom file name for the export'
    )
    public String customFileName;
    
    @InvocableVariable(
      label='Export Type'
      description='Type of export: Full, Summary, or Custom'
    )
    public String exportType;
    
    @InvocableVariable(
      label='Include Metadata'
      description='Include metadata headers in the TSV file'
    )
    public Boolean includeMetadata;
    
    @InvocableVariable(
      label='Request ID'
      description='Unique identifier for tracking'
    )
    public String requestId;
  }
  
  /**
   * @description Generic TSV Export Response
   */
  public class GenericTSVExportResponse {
    @InvocableVariable(label='Success' description='Whether the export was successful')
    public Boolean success;
    
    @InvocableVariable(label='Message' description='Response message')
    public String message;
    
    @InvocableVariable(label='Download Link' description='Link to download the TSV file')
    public String downloadLink;
    
    @InvocableVariable(label='File Name' description='Name of the generated file')
    public String fileName;
    
    @InvocableVariable(label='File Size' description='Size of the TSV file in bytes')
    public Integer fileSize;
    
    @InvocableVariable(label='Record Count' description='Number of records in the TSV file')
    public Integer recordCount;
    
    @InvocableVariable(label='Analysis Type' description='Type of analysis that was exported')
    public String analysisType;
    
    @InvocableVariable(label='Request ID' description='Echo of the original request ID')
    public String requestId;
  }
  
  /**
   * @description Main invocable method for generic TSV export
   * @param requests List of generic TSV export requests
   * @return List<GenericTSVExportResponse>
   */
  @InvocableMethod(
    label='Export Any Analysis as TSV'
    description='Export any stored analysis data as TSV file'
  )
  public static List<GenericTSVExportResponse> exportAnyAnalysisAsTSV(
    List<GenericTSVExportRequest> requests
  ) {
    List<GenericTSVExportResponse> responses = new List<GenericTSVExportResponse>();
    
    for (GenericTSVExportRequest request : requests) {
      GenericTSVExportResponse response = new GenericTSVExportResponse();
      response.requestId = request.requestId;
      
      try {
        // Get the most recent analysis data
        Map<String, Object> analysisData = ANAgentMemoryContext.getMostRecentAnalysisData();
        
        if (analysisData == null || analysisData.isEmpty()) {
          response.success = false;
          response.message = 'No analysis data found in memory. Please run an analysis first.';
          responses.add(response);
          continue;
        }
        
        // Check if analysis type filter matches (if specified)
        String storedAnalysisType = (String) analysisData.get('analysisType');
        if (String.isNotBlank(request.analysisTypeFilter) && 
            !request.analysisTypeFilter.equalsIgnoreCase(storedAnalysisType)) {
          response.success = false;
          response.message = 'No ' + request.analysisTypeFilter + ' analysis data found. Most recent analysis is: ' + storedAnalysisType;
          responses.add(response);
          continue;
        }
        
        // Generate file name if not provided
        String fileName = request.customFileName;
        if (String.isBlank(fileName)) {
          String timestamp = String.valueOf(System.now().getTime());
          fileName = storedAnalysisType + '_Analysis_' + timestamp;
        }
        
        // Create TSV content
        String tsvContent = generateTSVContent(analysisData, request);
        
        // Create and save the file
        ContentVersion file = new ContentVersion();
        file.Title = fileName + '.tsv';
        file.PathOnClient = fileName + '.tsv';
        file.VersionData = Blob.valueOf(tsvContent);
        file.IsMajorVersion = true;
        insert file;
        
        // Get the download link
        String downloadLink = getDownloadLink(file.Id);
        
        // Set response
        response.success = true;
        response.message = '✅ Analysis exported successfully!\n\n' +
                          '📊 Analysis Type: ' + storedAnalysisType + '\n' +
                          '📊 Records: ' + getRecordCount(analysisData) + '\n' +
                          '📁 File: ' + fileName + '.tsv\n' +
                          '🔗 Download: ' + downloadLink;
        response.downloadLink = downloadLink;
        response.fileName = fileName + '.tsv';
        response.fileSize = tsvContent.length();
        response.recordCount = getRecordCount(analysisData);
        response.analysisType = storedAnalysisType;
        
        System.debug('Generic TSV export completed for analysis type: ' + storedAnalysisType);
        
      } catch (Exception e) {
        response.success = false;
        response.message = 'Error exporting analysis: ' + e.getMessage();
        System.debug('Generic TSV export error: ' + e.getMessage());
      }
      
      responses.add(response);
    }
    
    return responses;
  }
  
  /**
   * @description Generate TSV content from analysis data using schema registry
   * @param analysisData The analysis data to export
   * @param request The export request
   * @return String TSV content
   */
  private static String generateTSVContent(Map<String, Object> analysisData, GenericTSVExportRequest request) {
    try {
      // Detect analysis type
      ANAgentTSVSchemaRegistry.AnalysisType analysisType = ANAgentTSVSchemaRegistry.detectAnalysisType(analysisData);
      
      System.debug('TSV Export - Detected analysis type: ' + analysisType);
      
      // Get schema for this analysis type
      List<ANAgentTSVSchemaRegistry.Column> schema = ANAgentTSVSchemaRegistry.schemaFor(analysisType);
      
      // Extract data rows based on analysis type
      List<List<String>> dataRows = extractDataRows(analysisData, analysisType, schema);
      
      System.debug('TSV Export - Extracted ' + dataRows.size() + ' data rows');
      
      // Build TSV content
      List<List<String>> allRows = new List<List<String>>();
      
      // Add header row
      List<String> headerRow = new List<String>();
      for (ANAgentTSVSchemaRegistry.Column col : schema) {
        headerRow.add(col.header);
      }
      allRows.add(headerRow);
      
      // Add data rows
      allRows.addAll(dataRows);
      
      // Convert to TSV string
      String tsvContent = ANAgentTSVSchemaRegistry.toTSV(allRows);
      
      // Add metadata header if requested
      if (request.includeMetadata == true) {
        List<String> metadataLines = new List<String>();
        metadataLines.add('# Analysis Export Metadata');
        metadataLines.add('# Generated: ' + String.valueOf(System.now()));
        metadataLines.add('# Analysis Type: ' + analysisType);
        metadataLines.add('# Session ID: ' + analysisData.get('sessionId'));
        metadataLines.add('# Timestamp: ' + analysisData.get('timestamp'));
        metadataLines.add('# Record Count: ' + dataRows.size());
        metadataLines.add('');
        metadataLines.add(tsvContent);
        return String.join(metadataLines, '\n');
      }
      
      return tsvContent;
      
    } catch (Exception e) {
      System.debug('Error generating TSV content: ' + e.getMessage());
      // Fallback to simple key-value format
      return generateFallbackTSVContent(analysisData, request);
    }
  }
  
  /**
   * @description Extract data rows based on analysis type and schema
   * @param analysisData The analysis data
   * @param analysisType The detected analysis type
   * @param schema The schema columns
   * @return List<List<String>> Data rows
   */
  private static List<List<String>> extractDataRows(Map<String, Object> analysisData, ANAgentTSVSchemaRegistry.AnalysisType analysisType, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    try {
      Map<String, Object> detailedData = (Map<String, Object>) analysisData.get('analysisData');
      if (detailedData == null || detailedData.isEmpty()) {
        return rows;
      }
      
      switch on analysisType {
        when RENEWALS {
          rows = extractRenewalsData(detailedData, schema);
        }
        when OPEN_PIPE {
          rows = extractOpenPipeData(detailedData, schema);
        }
        when KPIS {
          rows = extractKPIData(detailedData, schema);
        }
        when SME {
          rows = extractSMEData(detailedData, schema);
        }
        when CONTENT_ACT {
          rows = extractContentACTData(detailedData, schema);
        }
        when CONTENT_CONSENSUS {
          rows = extractContentConsensusData(detailedData, schema);
        }
        when FUTURE_PIPE {
          rows = extractFuturePipeData(detailedData, schema);
        }
        when else {
          rows = extractGenericData(detailedData, schema);
        }
      }
    } catch (Exception e) {
      System.debug('Error extracting data rows: ' + e.getMessage());
    }
    
    return rows;
  }
  
  /**
   * @description Extract renewals data rows
   */
  private static List<List<String>> extractRenewalsData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    System.debug('🔍 extractRenewalsData - detailedData keys: ' + detailedData.keySet());
    
    // Look for product performance data
    List<Object> productData = (List<Object>) detailedData.get('product_performance');
    System.debug('🔍 product_performance data: ' + productData);
    
    if (productData == null) {
      productData = (List<Object>) detailedData.get('renewal_products');
      System.debug('🔍 renewal_products data: ' + productData);
    }
    if (productData == null) {
      productData = (List<Object>) detailedData.get('renewal_summary');
      System.debug('🔍 renewal_summary data: ' + productData);
    }
    
    System.debug('🔍 Final productData size: ' + (productData != null ? String.valueOf(productData.size()) : 'null'));
    
    if (productData != null) {
      for (Integer i = 0; i < productData.size(); i++) {
        Object item = productData[i];
        System.debug('🔍 Processing item ' + i + ': ' + item);
        
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          System.debug('🔍 Item ' + i + ' keys: ' + itemMap.keySet());
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            System.debug('🔍 Column ' + col.header + ' (path: ' + col.path + ') = ' + value);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          System.debug('🔍 Row ' + i + ': ' + row);
          rows.add(row);
        }
      }
    }
    
    System.debug('🔍 Total rows extracted: ' + rows.size());
    return rows;
  }
  
  /**
   * @description Extract open pipe data rows
   */
  private static List<List<String>> extractOpenPipeData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Look for opportunity data
    List<Object> opportunityData = (List<Object>) detailedData.get('opportunity_data');
    if (opportunityData == null) {
      opportunityData = (List<Object>) detailedData.get('open_pipe_data');
    }
    if (opportunityData == null) {
      opportunityData = (List<Object>) detailedData.get('stagnation_analysis');
    }
    
    if (opportunityData != null) {
      for (Object item : opportunityData) {
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          rows.add(row);
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Extract KPI data rows
   */
  private static List<List<String>> extractKPIData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Look for AE performance data
    List<Object> aeData = (List<Object>) detailedData.get('ae_performance');
    if (aeData == null) {
      aeData = (List<Object>) detailedData.get('kpi_data');
    }
    if (aeData == null) {
      aeData = (List<Object>) detailedData.get('ramp_analysis');
    }
    
    if (aeData != null) {
      for (Object item : aeData) {
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          rows.add(row);
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Extract SME data rows
   */
  private static List<List<String>> extractSMEData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Look for SME data
    List<Object> smeData = (List<Object>) detailedData.get('sme_data');
    if (smeData == null) {
      smeData = (List<Object>) detailedData.get('subject_matter_experts');
    }
    if (smeData == null) {
      smeData = (List<Object>) detailedData.get('expert_analysis');
    }
    
    if (smeData != null) {
      for (Object item : smeData) {
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          rows.add(row);
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Extract Content ACT data rows
   */
  private static List<List<String>> extractContentACTData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Look for content data
    List<Object> contentData = (List<Object>) detailedData.get('content_data');
    if (contentData == null) {
      contentData = (List<Object>) detailedData.get('training_content');
    }
    if (contentData == null) {
      contentData = (List<Object>) detailedData.get('enrollment_data');
    }
    
    if (contentData != null) {
      for (Object item : contentData) {
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          rows.add(row);
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Extract Content Consensus data rows
   */
  private static List<List<String>> extractContentConsensusData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Look for consensus data
    List<Object> consensusData = (List<Object>) detailedData.get('consensus_data');
    if (consensusData == null) {
      consensusData = (List<Object>) detailedData.get('engagement_analysis');
    }
    if (consensusData == null) {
      consensusData = (List<Object>) detailedData.get('content_consensus');
    }
    
    if (consensusData != null) {
      for (Object item : consensusData) {
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          rows.add(row);
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Extract Future Pipeline data rows
   */
  private static List<List<String>> extractFuturePipeData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Look for future pipeline data
    List<Object> futureData = (List<Object>) detailedData.get('future_pipeline');
    if (futureData == null) {
      futureData = (List<Object>) detailedData.get('pipegen_analysis');
    }
    if (futureData == null) {
      futureData = (List<Object>) detailedData.get('upsell_crosssell');
    }
    
    if (futureData != null) {
      for (Object item : futureData) {
        if (item instanceof Map<String, Object>) {
          Map<String, Object> itemMap = (Map<String, Object>) item;
          List<String> row = new List<String>();
          
          for (ANAgentTSVSchemaRegistry.Column col : schema) {
            Object value = getNestedValue(itemMap, col.path);
            String formattedValue = ANAgentTSVSchemaRegistry.formatValue(value, col.format);
            row.add(formattedValue);
          }
          
          rows.add(row);
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Extract generic data rows (fallback)
   */
  private static List<List<String>> extractGenericData(Map<String, Object> detailedData, List<ANAgentTSVSchemaRegistry.Column> schema) {
    List<List<String>> rows = new List<List<String>>();
    
    // Try to find any array data
    for (String key : detailedData.keySet()) {
      Object value = detailedData.get(key);
      if (value instanceof List<Object>) {
        List<Object> listValue = (List<Object>) value;
        if (!listValue.isEmpty() && listValue[0] instanceof Map<String, Object>) {
          // This looks like structured data
          for (Object item : listValue) {
            if (item instanceof Map<String, Object>) {
              Map<String, Object> itemMap = (Map<String, Object>) item;
              List<String> row = new List<String>();
              
              for (ANAgentTSVSchemaRegistry.Column col : schema) {
                Object fieldValue = getNestedValue(itemMap, col.path);
                String formattedValue = ANAgentTSVSchemaRegistry.formatValue(fieldValue, col.format);
                row.add(formattedValue);
              }
              
              rows.add(row);
            }
          }
          break; // Use first array found
        }
      }
    }
    
    return rows;
  }
  
  /**
   * @description Get nested value from map using dot notation path
   * @param data The data map
   * @param path The dot notation path (e.g., "user.name")
   * @return Object The value at the path
   */
  private static Object getNestedValue(Map<String, Object> data, String path) {
    if (String.isBlank(path) || data == null) {
      return null;
    }
    
    String[] pathParts = path.split('\\.');
    Object current = data;
    
    for (String part : pathParts) {
      if (current instanceof Map<String, Object>) {
        current = ((Map<String, Object>) current).get(part);
      } else {
        return null;
      }
    }
    
    return current;
  }
  
  /**
   * @description Generate fallback TSV content when schema-based extraction fails
   * @param analysisData The analysis data
   * @param request The export request
   * @return String Fallback TSV content
   */
  private static String generateFallbackTSVContent(Map<String, Object> analysisData, GenericTSVExportRequest request) {
    List<String> lines = new List<String>();
    
    // Add metadata header if requested
    if (request.includeMetadata == true) {
      lines.add('# Analysis Export Metadata');
      lines.add('# Generated: ' + String.valueOf(System.now()));
      lines.add('# Analysis Type: ' + analysisData.get('analysisType'));
      lines.add('# Session ID: ' + analysisData.get('sessionId'));
      lines.add('# Timestamp: ' + analysisData.get('timestamp'));
      lines.add('');
    }
    
    // Add data header
    lines.add('Field\tValue');
    
    // Add analysis data
    for (String key : analysisData.keySet()) {
      if (key != 'analysisData' && key != 'sessionId' && key != 'timestamp') {
        Object value = analysisData.get(key);
        String valueStr = value != null ? String.valueOf(value) : '';
        lines.add(key + '\t' + ANAgentTSVSchemaRegistry.escapeTSV(valueStr));
      }
    }
    
    // Add detailed analysis data if available
    Map<String, Object> detailedData = (Map<String, Object>) analysisData.get('analysisData');
    if (detailedData != null && !detailedData.isEmpty()) {
      lines.add('');
      lines.add('# Detailed Analysis Data');
      lines.add('Detail_Field\tDetail_Value');
      
      for (String key : detailedData.keySet()) {
        Object value = detailedData.get(key);
        String valueStr = value != null ? String.valueOf(value) : '';
        lines.add(key + '\t' + ANAgentTSVSchemaRegistry.escapeTSV(valueStr));
      }
    }
    
    return String.join(lines, '\n');
  }
  
  /**
   * @description Get download link for the file
   * @param contentVersionId The ContentVersion ID
   * @return String Download link
   */
  private static String getDownloadLink(Id contentVersionId) {
    try {
      ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
      return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
    } catch (Exception e) {
      System.debug('Error generating download link: ' + e.getMessage());
      return 'Download link not available';
    }
  }
  
  /**
   * @description Get record count from analysis data
   * @param analysisData The analysis data
   * @return Integer Record count
   */
  private static Integer getRecordCount(Map<String, Object> analysisData) {
    try {
      // Try to get count from detailed data first
      Map<String, Object> detailedData = (Map<String, Object>) analysisData.get('analysisData');
      if (detailedData != null) {
        if (detailedData.containsKey('totalRecords')) {
          return (Integer) detailedData.get('totalRecords');
        }
        
        // Count records in arrays
        for (String key : detailedData.keySet()) {
          Object value = detailedData.get(key);
          if (value instanceof List<Object>) {
            List<Object> listValue = (List<Object>) value;
            if (!listValue.isEmpty() && listValue[0] instanceof Map<String, Object>) {
              return listValue.size();
            }
          }
        }
      }
      
      return 0;
    } catch (Exception e) {
      System.debug('Error getting record count: ' + e.getMessage());
      return 0;
    }
  }
}