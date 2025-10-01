/**
 * @description TSV Schema Registry for standardized export formats
 * Defines strict schemas for each analysis type to ensure consistent TSV output
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentTSVSchemaRegistry {
  
  /**
   * @description Analysis types supported for TSV export
   */
  public enum AnalysisType { 
    RENEWALS, 
    OPEN_PIPE, 
    KPIS, 
    SME, 
    CONTENT_ACT, 
    CONTENT_CONSENSUS, 
    FUTURE_PIPE,
    UNKNOWN 
  }
  
  /**
   * @description Column definition for TSV schema
   */
  public class Column { 
    public String header; 
    public String path; 
    public String format;
    
    public Column(String header, String path, String format) {
      this.header = header;
      this.path = path;
      this.format = format;
    }
  }
  
  /**
   * @description Get schema columns for a specific analysis type
   * @param analysisType The analysis type
   * @return List<Column> Ordered list of columns for the schema
   */
  public static List<Column> schemaFor(AnalysisType analysisType) {
    switch on analysisType {
      when RENEWALS {
        return new List<Column>{
          new Column('Product', 'product', 'string'),
          new Column('Total_Value', 'totalValue', 'number'),
          new Column('Opportunity_Count', 'opportunityCount', 'number'),
          new Column('Avg_Deal_Size', 'avgDealSize', 'number')
        };
      }
      when OPEN_PIPE {
        return new List<Column>{
          new Column('AE_Email', 'aeEmail', 'string'),
          new Column('Learner_Profile_Id', 'learnerProfileId', 'string'),
          new Column('Product', 'product', 'string'),
          new Column('Opportunity_Name', 'opportunityName', 'string'),
          new Column('Stage', 'stage', 'string'),
          new Column('Stagnation_Days', 'stagnationDays', 'number'),
          new Column('Amount', 'amount', 'number'),
          new Column('Opportunity_URL', 'opportunityUrl', 'string')
        };
      }
      when KPIS {
        return new List<Column>{
          new Column('AE_Email', 'aeEmail', 'string'),
          new Column('Learner_Profile_Id', 'learnerProfileId', 'string'),
          new Column('OU', 'ou', 'string'),
          new Column('AE_Score', 'aeScore', 'number'),
          new Column('Coverage', 'coverage', 'number'),
          new Column('Timeframe', 'timeframe', 'string')
        };
      }
      when SME {
        return new List<Column>{
          new Column('SME_Name', 'smeName', 'string'),
          new Column('SME_Email', 'smeEmail', 'string'),
          new Column('SME_OU', 'smeOu', 'string'),
          new Column('Product_L2', 'productL2', 'string'),
          new Column('Excellence_Academy', 'excellenceAcademy', 'string'),
          new Column('Total_ACV', 'totalAcv', 'number')
        };
      }
      when CONTENT_ACT {
        return new List<Column>{
          new Column('Title', 'title', 'string'),
          new Column('URL', 'url', 'string'),
          new Column('ProductTag', 'productTag', 'string'),
          new Column('EnrollmentCount', 'enrollmentCount', 'number'),
          new Column('CompletionRate', 'completionRate', 'number'),
          new Column('PublishedDate', 'publishedDate', 'date')
        };
      }
      when CONTENT_CONSENSUS {
        return new List<Column>{
          new Column('Title', 'title', 'string'),
          new Column('URL', 'url', 'string'),
          new Column('ProductTag', 'productTag', 'string'),
          new Column('EngagementScore', 'engagementScore', 'number'),
          new Column('PublishedDate', 'publishedDate', 'date')
        };
      }
      when FUTURE_PIPE {
        return new List<Column>{
          new Column('AE_Email', 'aeEmail', 'string'),
          new Column('Learner_Profile_Id', 'learnerProfileId', 'string'),
          new Column('Product', 'product', 'string'),
          new Column('Opp_Amount', 'oppAmount', 'number'),
          new Column('PipeGen_Type', 'pipeGenType', 'string')
        };
      }
      when else {
        return new List<Column>{
          new Column('Field', 'field', 'string'),
          new Column('Value', 'value', 'string')
        };
      }
    }
  }
  
  /**
   * @description Detect analysis type from memory payload
   * @param analysisData The analysis data from memory
   * @return AnalysisType Detected analysis type
   */
  public static AnalysisType detectAnalysisType(Map<String, Object> analysisData) {
    if (analysisData == null || analysisData.isEmpty()) {
      return AnalysisType.UNKNOWN;
    }
    
    // Check explicit analysis type first
    String analysisTypeStr = (String) analysisData.get('analysisType');
    if (String.isNotBlank(analysisTypeStr)) {
      return mapStringToAnalysisType(analysisTypeStr);
    }
    
    // Infer from data structure
    Map<String, Object> detailedData = (Map<String, Object>) analysisData.get('analysisData');
    if (detailedData != null) {
      // Check for renewals indicators
      if (detailedData.containsKey('renewal_products') || 
          detailedData.containsKey('renewal_summary') ||
          detailedData.containsKey('product_performance')) {
        return AnalysisType.RENEWALS;
      }
      
      // Check for open pipe indicators
      if (detailedData.containsKey('open_pipe_data') || 
          detailedData.containsKey('stagnation_analysis') ||
          detailedData.containsKey('opportunity_data')) {
        return AnalysisType.OPEN_PIPE;
      }
      
      // Check for KPI indicators
      if (detailedData.containsKey('kpi_data') || 
          detailedData.containsKey('ae_performance') ||
          detailedData.containsKey('ramp_analysis')) {
        return AnalysisType.KPIS;
      }
      
      // Check for SME indicators
      if (detailedData.containsKey('sme_data') || 
          detailedData.containsKey('subject_matter_experts') ||
          detailedData.containsKey('expert_analysis')) {
        return AnalysisType.SME;
      }
      
      // Check for content indicators
      if (detailedData.containsKey('content_data') || 
          detailedData.containsKey('training_content') ||
          detailedData.containsKey('enrollment_data')) {
        return AnalysisType.CONTENT_ACT;
      }
      
      // Check for consensus indicators
      if (detailedData.containsKey('consensus_data') || 
          detailedData.containsKey('engagement_analysis') ||
          detailedData.containsKey('content_consensus')) {
        return AnalysisType.CONTENT_CONSENSUS;
      }
      
      // Check for future pipeline indicators
      if (detailedData.containsKey('future_pipeline') || 
          detailedData.containsKey('pipegen_analysis') ||
          detailedData.containsKey('upsell_crosssell')) {
        return AnalysisType.FUTURE_PIPE;
      }
    }
    
    return AnalysisType.UNKNOWN;
  }
  
  /**
   * @description Map string analysis type to enum
   * @param analysisTypeStr String representation of analysis type
   * @return AnalysisType Corresponding enum value
   */
  private static AnalysisType mapStringToAnalysisType(String analysisTypeStr) {
    if (String.isBlank(analysisTypeStr)) {
      return AnalysisType.UNKNOWN;
    }
    
    String upper = analysisTypeStr.toUpperCase();
    if (upper.contains('RENEWAL')) return AnalysisType.RENEWALS;
    if (upper.contains('OPEN_PIPE') || upper.contains('OPENPIPE')) return AnalysisType.OPEN_PIPE;
    if (upper.contains('KPI') || upper.contains('RAMP')) return AnalysisType.KPIS;
    if (upper.contains('SME') || upper.contains('EXPERT')) return AnalysisType.SME;
    if (upper.contains('CONTENT') && upper.contains('ACT')) return AnalysisType.CONTENT_ACT;
    if (upper.contains('CONSENSUS')) return AnalysisType.CONTENT_CONSENSUS;
    if (upper.contains('FUTURE') || upper.contains('PIPEGEN')) return AnalysisType.FUTURE_PIPE;
    
    return AnalysisType.UNKNOWN;
  }
  
  /**
   * @description Convert raw value to TSV-safe string
   * @param value The raw value to convert
   * @param format The expected format (string, number, date)
   * @return String TSV-safe string representation
   */
  public static String formatValue(Object value, String format) {
    if (value == null) {
      return '';
    }
    
    switch on format {
      when 'number' {
        if (value instanceof Decimal) {
          return String.valueOf(((Decimal) value).setScale(2));
        } else if (value instanceof Double) {
          return String.valueOf(Decimal.valueOf((Double) value).setScale(2));
        } else if (value instanceof Integer) {
          return String.valueOf(value);
        } else {
          // Try to parse as number
          try {
            Decimal d = Decimal.valueOf(String.valueOf(value));
            return String.valueOf(d.setScale(2));
          } catch (Exception e) {
            return String.valueOf(value);
          }
        }
      }
      when 'date' {
        if (value instanceof Date) {
          return ((Date) value).format();
        } else if (value instanceof Datetime) {
          return ((Datetime) value).format('yyyy-MM-dd');
        } else {
          return String.valueOf(value);
        }
      }
      when else {
        return escapeTSV(String.valueOf(value));
      }
    }
  }
  
  /**
   * @description Escape string for TSV format (RFC-4180)
   * @param raw The raw string to escape
   * @return String Escaped string safe for TSV
   */
  public static String escapeTSV(String raw) {
    if (String.isBlank(raw)) {
      return '';
    }
    
    // Escape quotes by doubling them
    String escaped = raw.replace('"', '""');
    
    // Quote if contains tab, newline, or quote
    if (escaped.contains('\t') || escaped.contains('\n') || escaped.contains('\r') || escaped.contains('"')) {
      return '"' + escaped + '"';
    }
    
    return escaped;
  }
  
  /**
   * @description Convert list of rows to TSV string
   * @param rows List of rows, each row is a list of values
   * @return String TSV formatted string
   */
  public static String toTSV(List<List<String>> rows) {
    if (rows == null || rows.isEmpty()) {
      return '';
    }
    
    List<String> lines = new List<String>();
    for (List<String> row : rows) {
      if (row != null && !row.isEmpty()) {
        lines.add(String.join(row, '\t'));
      }
    }
    
    return String.join(lines, '\n');
  }
}
