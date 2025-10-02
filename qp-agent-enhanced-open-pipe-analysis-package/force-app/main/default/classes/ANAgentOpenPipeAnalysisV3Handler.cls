/**
 * ENHANCED HANDLER - Unified OpenPipe Analysis with Integrated MCP Logic
 * Business Requirement: Single entry point for all OpenPipe analysis with built-in MCP pattern detection
 * @description Handler class for Open Pipe Analysis operations on Agent_Open_Pipe__c records.
 * This class is the primary entry point for the AI agent to analyze open pipeline data across AEs.
 * It includes integrated MCP pattern detection for negative intent and product filtering.
 *
 * The service fetches Agent_Open_Pipe__c records and provides insights on active pipeline patterns,
 * opportunity stages, product performance, and AE metrics with grouping, filtering, and aggregation.
 *
 * @version 3.1 - Enhanced with MCP Integration
 */
public with sharing class ANAgentOpenPipeAnalysisV3Handler {
  
  // MCP Pattern Detection - Advanced Negative Intent Patterns
  private static final Set<String> NEGATIVE_INTENT_PATTERNS = new Set<String>{
    // Basic negative patterns
    'don\'t have', 'doesn\'t have', 'without', 'excluding', 'exclude', 'lack', 'no product',
    'missing', 'not having', 'not include', 'not including', 'absent', 'absence',
    
    // Question patterns
    'who don\'t', 'who doesn\'t', 'who without', 'who excluding', 'who lack', 'who missing', 
    'who not having', 'who not include', 'which don\'t', 'which doesn\'t', 'which without',
    'which excluding', 'which lack', 'which missing', 'which not having',
    
    // Action patterns
    'list don\'t', 'list doesn\'t', 'list without', 'list excluding', 'list lack', 'list missing',
    'show don\'t', 'show doesn\'t', 'show without', 'show excluding', 'show lack', 'show missing',
    'find don\'t', 'find doesn\'t', 'find without', 'find excluding', 'find lack', 'find missing',
    'display don\'t', 'display doesn\'t', 'display without', 'display excluding', 'display lack',
    'get don\'t', 'get doesn\'t', 'get without', 'get excluding', 'get lack', 'get missing',
    'return don\'t', 'return doesn\'t', 'return without', 'return excluding', 'return lack',
    
    // Comparative patterns
    'don\'t have any', 'doesn\'t have any', 'have no', 'has no', 'don\'t carry', 'doesn\'t carry',
    'don\'t sell', 'doesn\'t sell', 'don\'t offer', 'doesn\'t offer', 'don\'t support', 'doesn\'t support',
    
    // Exclusion patterns
    'except', 'other than', 'besides', 'apart from', 'not counting', 'not including',
    'excluding', 'exclude', 'minus', 'less', 'subtract',
    
    // Negative qualifiers
    'never had', 'never have', 'never used', 'never sold', 'never offered', 'never supported',
    'not yet', 'not currently', 'not presently', 'not right now', 'not at this time',
    
    // Zero patterns
    'zero', 'none', 'no one', 'no ae', 'no sales', 'no deals', 'no opportunities',
    'empty', 'blank', 'void', 'null', 'nil',
    
    // Advanced patterns
    'are there any aes who don\'t', 'are there any aes who doesn\'t', 'are there any aes who don\'t have',
    'are there any aes who doesn\'t have', 'do we have any aes who don\'t', 'do we have any aes who doesn\'t',
    'can you find aes who don\'t', 'can you find aes who doesn\'t', 'can you show aes who don\'t',
    'can you show aes who doesn\'t', 'can you list aes who don\'t', 'can you list aes who doesn\'t'
  };
  
  // Product name patterns for extraction - Comprehensive mapping
  private static final Map<String, String> PRODUCT_ALIAS_MAP = new Map<String, String>{
    // Agentforce variations
    'Agentforce' => 'Agentforce',
    'Agentforce Platform' => 'Agentforce',
    'Agentforce Analytics' => 'Agentforce',
    'Agentforce for Sales' => 'Agentforce',
    'Agentforce for Service' => 'Agentforce',
    'Agentforce Conversations' => 'Agentforce',
    'A4S' => 'Agentforce',
    'A4S Add-on' => 'Agentforce',
    'AFS' => 'Agentforce',
    'AFS Add-on' => 'Agentforce',
    
    // Tableau variations
    'Tableau' => 'Tableau',
    'Tableau Cloud' => 'Tableau',
    'Tableau Server' => 'Tableau',
    'Tableau Pulse' => 'Tableau',
    'Tableau Plus' => 'Tableau',
    'Tableau Creator' => 'Tableau',
    'Tableau Explorer' => 'Tableau',
    'Tableau Viewer' => 'Tableau',
    'TAB' => 'Tableau',
    
    // Data Cloud variations
    'Data Cloud' => 'Data Cloud',
    'Customer Data Cloud' => 'Data Cloud',
    'Data Cloud Starter' => 'Data Cloud',
    'Data Cloud for Marketing' => 'Data Cloud',
    'Data Cloud One' => 'Data Cloud',
    'DC' => 'Data Cloud',
    'CDP' => 'Data Cloud',
    
    // Slack variations
    'Slack' => 'Slack',
    'Slack Enterprise' => 'Slack',
    'Slack Business Plus' => 'Slack',
    'Slack Enterprise Plus' => 'Slack',
    'Slack Enterprise Grid' => 'Slack',
    'Slack AI' => 'Slack',
    'Slack Connect' => 'Slack',
    'SLK' => 'Slack',
    
    // Sales Cloud variations
    'Sales Cloud' => 'Sales Cloud',
    'Sales Cloud Enterprise' => 'Sales Cloud',
    'Sales Cloud Unlimited' => 'Sales Cloud',
    'Sales Cloud Einstein' => 'Sales Cloud',
    'Sales Cloud Agentforce' => 'Sales Cloud',
    'SC' => 'Sales Cloud',
    
    // Service Cloud variations
    'Service Cloud' => 'Service Cloud',
    'Service Cloud Enterprise' => 'Service Cloud',
    'Service Cloud Unlimited' => 'Service Cloud',
    'Service Cloud Einstein' => 'Service Cloud',
    'Service Cloud Voice' => 'Service Cloud',
    'Field Service' => 'Service Cloud',
    'Field Service Lightning' => 'Service Cloud',
    'FSL' => 'Service Cloud',
    
    // Marketing Cloud variations
    'Marketing Cloud' => 'Marketing Cloud',
    'Marketing Cloud Engagement' => 'Marketing Cloud',
    'Marketing Cloud Account Engagement' => 'Marketing Cloud',
    'Marketing Cloud Personalization' => 'Marketing Cloud',
    'Marketing Cloud Intelligence' => 'Marketing Cloud',
    'Marketing Cloud Journey Builder' => 'Marketing Cloud',
    'MC' => 'Marketing Cloud',
    'MCAE' => 'Marketing Cloud',
    'MCP' => 'Marketing Cloud',
    'MCI' => 'Marketing Cloud',
    
    // MuleSoft variations
    'MuleSoft' => 'MuleSoft',
    'MuleSoft Integration Platform' => 'MuleSoft',
    'MuleSoft Anypoint' => 'MuleSoft',
    'MuleSoft Runtime' => 'MuleSoft',
    'Mule' => 'MuleSoft',
    
    // Einstein variations
    'Einstein' => 'Einstein',
    'Einstein for Sales' => 'Einstein',
    'Einstein for Service' => 'Einstein',
    'Einstein Analytics' => 'Einstein',
    'Einstein AI' => 'Einstein',
    
    // Revenue Cloud variations
    'Revenue Cloud' => 'Revenue Cloud',
    'Revenue Cloud Advanced' => 'Revenue Cloud',
    'Revenue Cloud Billing' => 'Revenue Cloud',
    'Revenue Intelligence' => 'Revenue Cloud',
    'CPQ' => 'Revenue Cloud',
    'RCA' => 'Revenue Cloud',
    'RCB' => 'Revenue Cloud',
    
    // Platform variations
    'Salesforce Platform' => 'Platform',
    'Lightning Platform' => 'Platform',
    'Platform Starter' => 'Platform',
    'Platform Plus' => 'Platform',
    'Platform Unlimited' => 'Platform',
    
    // Other common products
    'Quip' => 'Quip',
    'Heroku' => 'Heroku',
    'Trailhead' => 'Trailhead',
    'Commerce Cloud' => 'Commerce Cloud',
    'Health Cloud' => 'Health Cloud',
    'Financial Services Cloud' => 'Financial Services Cloud',
    'Education Cloud' => 'Education Cloud',
    'Nonprofit Cloud' => 'Nonprofit Cloud'
  };

  /**
   * @description The request object for the Open Pipe Analysis invocable method.
   */
  public class Request {
    @InvocableVariable(
      label='OU Name'
      description='The Organizational Unit to filter by. This is a required baseline filter for all queries. Examples: "AMER ICE", "SMB - AMER SMB", "NextGen Platform".'
      required=true
    )
    public String ouName;

    @InvocableVariable(
      label='Work Location Country'
      description='Optional work location country filter. Use as fallback when OU is not specified. Examples: "US", "Canada", "Switzerland".'
      required=false
    )
    public String workLocationCountry;

    @InvocableVariable(
      label='Group By'
      description='The field to group results by. Must be one of: "STAGE", "PRODUCT", "INDUSTRY", "MACRO_SEGMENT", "AE", "COUNTRY". Defaults to "STAGE".'
      required=false
    )
    public String groupBy;

    @InvocableVariable(
      label='Filter Criteria'
      description='SOQL WHERE clause filter using allowed fields: ou_name, work_location_country, primary_industry, macrosgment, open_pipe_opty_stg_nm, open_pipe_prod_nm, open_pipe_opty_days_in_stage, open_pipe_ae_score, open_pipe_opp_manager_nt, emp_mgr_nm, time_since_onboarding, ramp_status. Example: "open_pipe_opty_stg_nm=\'03 - Validating Benefits & Value\' AND open_pipe_opty_days_in_stage > 30"'
      required=false
    )
    public String filterCriteria;

    @InvocableVariable(
      label='Restrict Values CSV'
      description='Comma-separated values to restrict results to specific groups. Example: "US,Brazil" for country grouping.'
      required=false
    )
    public String restrictInValuesCsv;

    @InvocableVariable(
      label='Per AE Normalize'
      description='If true, returns average per AE instead of total sum. Defaults to false.'
      required=false
    )
    public Boolean perAENormalize;

    @InvocableVariable(
      label='Record Limit'
      description='Maximum number of grouped results to return. Only send when user explicitly requests a limit (e.g., "top 10", "show me 5"). Leave empty to show all results.'
      required=false
    )
    public Integer limitN;

    @InvocableVariable(
      label='Aggregation Type'
      description='The type of aggregation to perform: "SUM", "AVG", "MAX", "MIN", "COUNT", "MEDIAN". Defaults to "COUNT".'
      required=false
    )
    public String aggregationType;

    @InvocableVariable(
      label='Analysis Type'
      description='The type of analysis to perform: "STAGE_COUNT", "PRODUCT_PERFORMANCE", "AE_SCORE_ANALYSIS", "DAYS_IN_STAGE", "OPPORTUNITY_DETAILS". Defaults to "STAGE_COUNT".'
      required=false
    )
    public String analysisType;

    // Intelligence capabilities flags
    @InvocableVariable(
      label='Include Closure Probability'
      description='Include AE score to closure probability analysis. Defaults to false.'
      required=false
    )
    public Boolean includeClosureProb;

    @InvocableVariable(
      label='Include Stage Bottlenecks'
      description='Include stage bottleneck detection with peer comparison. Defaults to false.'
      required=false
    )
    public Boolean includeStageBottlenecks;

    @InvocableVariable(
      label='Include Product Market Fit'
      description='Include product-market fit analysis. Defaults to false.'
      required=false
    )
    public Boolean includePMF;

    @InvocableVariable(
      label='Include AE Benchmarks'
      description='Include AE performance benchmarking. Defaults to false.'
      required=false
    )
    public Boolean includeAEBenchmarks;

    // Product filtering capabilities
    @InvocableVariable(
      label='Include Product List'
      description='Comma-separated list of products to include in analysis (e.g., "Tableau,Slack,Data Cloud"). Uses partial matching to catch variations like "Tableau Server", "Tableau Pulse".'
      required=false
    )
    public String includeProductListCsv;

    @InvocableVariable(
      label='Exclude Product List'
      description='Comma-separated list of products to exclude from analysis (e.g., "Agentforce,Data Cloud"). Uses partial matching to catch variations like "Agentforce Platform", "Agentforce Analytics".'
      required=false
    )
    public String excludeProductListCsv;

    @InvocableVariable(
      label='Require No Product Match'
      description='Set to true to find AEs who do NOT have any of the specified products in their open pipe'
      required=false
    )
    public Boolean requireNoProductMatch;

    @InvocableVariable(
      label='Negative Intent'
      description='Set to true when user intent is to find AEs without specific products (e.g., "don\'t have", "without", "excluding")'
      required=false
    )
    public Boolean negativeIntent;

    @InvocableVariable(
      label='Include Health Score'
      description='Include pipeline health scoring. Defaults to false.'
      required=false
    )
    public Boolean includeHealthScore;

    // NEW: Natural language query field for MCP pattern detection
    @InvocableVariable(
      label='Natural Language Query'
      description='The original user query in natural language for MCP pattern detection and intent analysis.'
      required=false
    )
    public String naturalLanguageQuery;
  }

  /**
   * @description The response object for the Open Pipe Analysis invocable method.
   * Follows FR agent best practices: only message field exposed to agent.
   */
  public class Response {
    @InvocableVariable(
      label='Analysis Message'
      description='Complete Open Pipe analysis results formatted as a human-readable message with Markdown structure and compact JSON data.'
      required=true
    )
    public String message;

    public Response() {
      this.message = '';
    }
  }

  /**
   * @description ENHANCED MCP-Integrated Analysis Method
   * Automatically detects negative intent and product filtering from natural language queries
   * @param requests A list of analysis requests with optional natural language queries
   * @return A list of analysis responses with MCP-enhanced logic
   */
  @InvocableMethod(
    label='ANAGENT Open Pipe Analysis V3 - MCP Enhanced'
    description='Analyzes open pipeline data with integrated MCP pattern detection for negative intent and product filtering. Automatically detects queries like "who don\'t have Agentforce deals" and routes appropriately.'
  )
  public static List<Response> analyzeOpenPipe(List<Request> requests) {
    List<Response> responses = new List<Response>();

    if (requests == null || requests.isEmpty()) {
      Response errRes = new Response();
      errRes.message = 'No request provided.';
      responses.add(errRes);
      return responses;
    }

    for (Request req : requests) {
      Response res = new Response();

      try {
        // ENHANCED: MCP Pattern Detection and Intent Analysis
        Request enhancedReq = detectAndEnhanceIntent(req);

        // Validate required fields
        if (String.isBlank(enhancedReq.ouName)) {
          res.message = 'OU Name is required for all Open Pipe Analysis queries.';
          responses.add(res);
          continue;
        }

        // Set defaults if not provided
        String groupBy = String.isNotBlank(enhancedReq.groupBy) ? enhancedReq.groupBy : 'STAGE';
        Boolean perAENormalize = enhancedReq.perAENormalize != null ? enhancedReq.perAENormalize : false;
        Integer limitN = enhancedReq.limitN; // No default limit - only apply if user requests one
        String aggregationType = String.isNotBlank(enhancedReq.aggregationType) ? enhancedReq.aggregationType : 'COUNT';
        String analysisType = String.isNotBlank(enhancedReq.analysisType) ? enhancedReq.analysisType : 'STAGE_COUNT';

        // Validate inputs
        if (!isValidGroupBy(groupBy)) {
          res.message = 'Invalid group by: ' + groupBy + '. Valid values are: STAGE, PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY.';
          responses.add(res);
          continue;
        }

        if (!isValidAggregationType(aggregationType)) {
          res.message = 'Invalid aggregation type: ' + aggregationType + '. Valid values are: SUM, AVG, MAX, MIN, COUNT, MEDIAN.';
          responses.add(res);
          continue;
        }

        if (!isValidAnalysisType(analysisType)) {
          res.message = 'Invalid analysis type: ' + analysisType + '. Valid values are: STAGE_COUNT, PRODUCT_PERFORMANCE, AE_SCORE_ANALYSIS, DAYS_IN_STAGE, OPPORTUNITY_DETAILS.';
          responses.add(res);
          continue;
        }

        // Set defaults for intelligence flags
        Boolean includeClosureProb = enhancedReq.includeClosureProb != null ? enhancedReq.includeClosureProb : false;
        Boolean includeStageBottlenecks = enhancedReq.includeStageBottlenecks != null ? enhancedReq.includeStageBottlenecks : false;
        Boolean includePMF = enhancedReq.includePMF != null ? enhancedReq.includePMF : false;
        Boolean includeAEBenchmarks = enhancedReq.includeAEBenchmarks != null ? enhancedReq.includeAEBenchmarks : false;
        Boolean includeHealthScore = enhancedReq.includeHealthScore != null ? enhancedReq.includeHealthScore : false;

        // Set defaults for product filtering flags (ENHANCED by MCP detection)
        String includeProductListCsv = enhancedReq.includeProductListCsv;
        String excludeProductListCsv = enhancedReq.excludeProductListCsv;
        Boolean requireNoProductMatch = enhancedReq.requireNoProductMatch != null ? enhancedReq.requireNoProductMatch : false;
        Boolean negativeIntent = enhancedReq.negativeIntent != null ? enhancedReq.negativeIntent : false;

        // Call enhanced service to perform analysis - service builds the complete message
        Map<String, Object> params = new Map<String, Object>{
          'ou' => enhancedReq.ouName,
          'product' => enhancedReq.includeProductListCsv,
          'country' => enhancedReq.workLocationCountry,
          'segment' => enhancedReq.restrictInValuesCsv,
          'analysisType' => analysisType,
          'groupBy' => groupBy,
          'filterCriteria' => enhancedReq.filterCriteria,
          'perAENormalize' => perAENormalize,
          'limitN' => limitN,
          'aggregationType' => aggregationType,
          'includeClosureProb' => includeClosureProb,
          'includeStageBottlenecks' => includeStageBottlenecks,
          'includePMF' => includePMF,
          'includeAEBenchmarks' => includeAEBenchmarks,
          'includeHealthScore' => includeHealthScore,
          'excludeProductListCsv' => excludeProductListCsv,
          'requireNoProductMatch' => requireNoProductMatch,
          'negativeIntent' => negativeIntent,
          'naturalLanguageQuery' => enhancedReq.naturalLanguageQuery
        };
        
        res.message = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);

        // Store analysis data in memory for TSV export
        try {
          // Generate session ID from request parameters
          String sessionId = generateSessionId(enhancedReq);

          // Prepare structured data for memory storage
          Map<String, Object> pipelineData = new Map<String, Object>();
          pipelineData.put('ouName', enhancedReq.ouName);
          pipelineData.put('workLocationCountry', enhancedReq.workLocationCountry);
          pipelineData.put('groupBy', groupBy);
          pipelineData.put('filterCriteria', enhancedReq.filterCriteria);
          pipelineData.put('restrictInValuesCsv', enhancedReq.restrictInValuesCsv);
          pipelineData.put('perAENormalize', perAENormalize);
          pipelineData.put('limitN', limitN);
          pipelineData.put('aggregationType', aggregationType);
          pipelineData.put('analysisType', analysisType);

          // Prepare metadata
          Map<String, Object> metadata = new Map<String, Object>();
          metadata.put('analysisType', 'Pipeline');
          metadata.put('timestamp', System.now().format());
          metadata.put('ouName', enhancedReq.ouName);
          metadata.put('groupBy', groupBy);
          metadata.put('analysisType', analysisType);
          metadata.put('mcpEnhanced', true);
          metadata.put('negativeIntent', negativeIntent);
          metadata.put('excludeProducts', excludeProductListCsv);

          // Store in memory for TSV export
          ANAgentMemoryContext.storeAnalysisData(
            sessionId,
            'Pipeline',
            pipelineData,
            res.message,
            metadata
          );
        } catch (Exception memEx) {
          System.debug(
            LoggingLevel.WARN,
            'Memory storage failed for Pipeline analysis: ' + memEx.getMessage()
          );
          // Don't fail the main operation if memory storage fails
        }
      } catch (Exception e) {
        res.message = 'An error occurred during Open Pipe analysis: ' + e.getMessage();
        System.debug(
          LoggingLevel.ERROR,
          'Open Pipe Analysis Handler Error: ' + e.getStackTraceString()
        );
      }

      responses.add(res);
    }

    return responses;
  }

  /**
   * @description Advanced MCP Pattern Detection and Intent Enhancement
   * Detects negative intent and extracts product information from natural language queries
   * @param req The original request
   * @return Enhanced request with detected intent and extracted parameters
   */
  private static Request detectAndEnhanceIntent(Request req) {
    // If no natural language query, return request as-is
    if (String.isBlank(req.naturalLanguageQuery)) {
      return req;
    }

    // Clone the request to avoid modifying the original
    Request enhancedReq = cloneRequest(req);

    String query = req.naturalLanguageQuery.toLowerCase();
    
    // Advanced negative intent detection with confidence scoring
    Boolean hasNegativeIntent = false;
    Integer confidenceScore = 0;
    
    // Check for explicit negative patterns
    for (String pattern : NEGATIVE_INTENT_PATTERNS) {
      if (query.contains(pattern.toLowerCase())) {
        hasNegativeIntent = true;
        confidenceScore += 10; // Base score for pattern match
        
        // Boost score for multiple pattern matches
        if (query.contains('don\'t') || query.contains('doesn\'t')) {
          confidenceScore += 5;
        }
        if (query.contains('without') || query.contains('excluding')) {
          confidenceScore += 5;
        }
        if (query.contains('no') || query.contains('none') || query.contains('zero')) {
          confidenceScore += 3;
        }
        break;
      }
    }
    
    // Additional context-based detection
    if (!hasNegativeIntent) {
      // Check for implicit negative patterns
      List<String> implicitPatterns = new List<String>{
        'find.*who.*not', 'show.*who.*not', 'list.*who.*not',
        'any.*who.*not', 'aes.*who.*not', 'sales.*who.*not'
      };
      
      for (String pattern : implicitPatterns) {
        if (System.Pattern.matches('.*' + pattern + '.*', query)) {
          hasNegativeIntent = true;
          confidenceScore += 7;
          break;
        }
      }
    }
    
    // Check for comparative negative patterns
    if (!hasNegativeIntent) {
      List<String> comparativePatterns = new List<String>{
        'compared to', 'versus', 'vs', 'different from', 'not like', 'unlike'
      };
      
      for (String pattern : comparativePatterns) {
        if (query.contains(pattern)) {
          // Check if the comparison implies exclusion
          if (query.contains('don\'t') || query.contains('doesn\'t') || 
              query.contains('without') || query.contains('excluding')) {
            hasNegativeIntent = true;
            confidenceScore += 8;
            break;
          }
        }
      }
    }

    // Only proceed if confidence score is high enough
    if (hasNegativeIntent && confidenceScore >= 5) {
      enhancedReq.negativeIntent = true;
      enhancedReq.requireNoProductMatch = true;
      
      // Extract product names for exclusion with enhanced logic
      String excludeProducts = extractProductNames(query);
      if (String.isNotBlank(excludeProducts)) {
        enhancedReq.excludeProductListCsv = excludeProducts;
      }
      
      System.debug(LoggingLevel.INFO, 'MCP: Detected negative intent (confidence: ' + confidenceScore + '). Exclude products: ' + excludeProducts);
    } else if (hasNegativeIntent && confidenceScore < 5) {
      System.debug(LoggingLevel.INFO, 'MCP: Low confidence negative intent detected (score: ' + confidenceScore + '). Proceeding with regular analysis.');
    }

    return enhancedReq;
  }

  /**
   * @description Extract product names from natural language query using advanced NLP
   * @param query The natural language query
   * @return Comma-separated list of product names to exclude
   */
  private static String extractProductNames(String query) {
    List<String> products = new List<String>();
    String normalizedQuery = query.toLowerCase();
    
    // Enhanced product extraction with context awareness
    for (String productKey : PRODUCT_ALIAS_MAP.keySet()) {
      String normalizedProduct = productKey.toLowerCase();
      
      // Direct match
      if (normalizedQuery.contains(normalizedProduct)) {
        String canonicalProduct = PRODUCT_ALIAS_MAP.get(productKey);
        if (!products.contains(canonicalProduct)) {
          products.add(canonicalProduct);
        }
        continue;
      }
      
      // Partial match with word boundaries for better accuracy
      String[] words = normalizedQuery.split('\\s+');
      for (String word : words) {
        if (normalizedProduct.contains(word) && word.length() > 3) {
          String canonicalProduct = PRODUCT_ALIAS_MAP.get(productKey);
          if (!products.contains(canonicalProduct)) {
            products.add(canonicalProduct);
          }
          break;
        }
      }
    }
    
    // Additional context-based extraction for common phrases
    Map<String, String> contextPatterns = new Map<String, String>{
      'salesforce' => 'Sales Cloud',
      'crm' => 'Sales Cloud',
      'service desk' => 'Service Cloud',
      'customer service' => 'Service Cloud',
      'support' => 'Service Cloud',
      'marketing automation' => 'Marketing Cloud',
      'email marketing' => 'Marketing Cloud',
      'data platform' => 'Data Cloud',
      'cdp' => 'Data Cloud',
      'collaboration' => 'Slack',
      'messaging' => 'Slack',
      'chat' => 'Slack',
      'analytics' => 'Tableau',
      'business intelligence' => 'Tableau',
      'bi' => 'Tableau',
      'dashboards' => 'Tableau',
      'visualization' => 'Tableau',
      'integration' => 'MuleSoft',
      'api management' => 'MuleSoft',
      'artificial intelligence' => 'Einstein',
      'ai' => 'Einstein',
      'machine learning' => 'Einstein',
      'pricing' => 'Revenue Cloud',
      'quoting' => 'Revenue Cloud',
      'billing' => 'Revenue Cloud',
      'cpq' => 'Revenue Cloud'
    };
    
    for (String contextKey : contextPatterns.keySet()) {
      if (normalizedQuery.contains(contextKey)) {
        String canonicalProduct = contextPatterns.get(contextKey);
        if (!products.contains(canonicalProduct)) {
          products.add(canonicalProduct);
        }
      }
    }
    
    return String.join(products, ',');
  }

  /**
   * @description Clone request to avoid modifying original
   * @param original The original request
   * @return Cloned request
   */
  private static Request cloneRequest(Request original) {
    Request clone = new Request();
    clone.ouName = original.ouName;
    clone.workLocationCountry = original.workLocationCountry;
    clone.groupBy = original.groupBy;
    clone.filterCriteria = original.filterCriteria;
    clone.restrictInValuesCsv = original.restrictInValuesCsv;
    clone.perAENormalize = original.perAENormalize;
    clone.limitN = original.limitN;
    clone.aggregationType = original.aggregationType;
    clone.analysisType = original.analysisType;
    clone.includeClosureProb = original.includeClosureProb;
    clone.includeStageBottlenecks = original.includeStageBottlenecks;
    clone.includePMF = original.includePMF;
    clone.includeAEBenchmarks = original.includeAEBenchmarks;
    clone.includeProductListCsv = original.includeProductListCsv;
    clone.excludeProductListCsv = original.excludeProductListCsv;
    clone.requireNoProductMatch = original.requireNoProductMatch;
    clone.negativeIntent = original.negativeIntent;
    clone.includeHealthScore = original.includeHealthScore;
    clone.naturalLanguageQuery = original.naturalLanguageQuery;
    return clone;
  }

  /**
   * @description Provides field suggestions and validation for better agent accuracy
   * @param requests A list containing a single request with query field
   * @return A list of responses with field suggestions
   */
  public static List<Response> getFieldSuggestions(List<Request> requests) {
    List<Response> responses = new List<Response>();

    if (requests == null || requests.isEmpty()) {
      Response errRes = new Response();
      errRes.message = 'No request provided for field suggestions.';
      responses.add(errRes);
      return responses;
    }

    for (Request req : requests) {
      Response res = new Response();

      try {
        if (String.isBlank(req.filterCriteria)) {
          res.message = 'Please provide a query in filterCriteria to get field suggestions.';
        } else {
          res.message = ANAgentOpenPipeAnalysisV3ServiceEnhanced.getFieldSuggestions(req.filterCriteria);
        }
      } catch (Exception e) {
        res.message = 'An error occurred while getting field suggestions: ' + e.getMessage();
      }

      responses.add(res);
    }

    return responses;
  }

  /**
   * @description Validates filter criteria and provides suggestions for common errors
   * @param requests A list containing a single request with filterCriteria field
   * @return A list of responses with validation results
   */
  public static List<Response> validateFilterCriteria(List<Request> requests) {
    List<Response> responses = new List<Response>();

    if (requests == null || requests.isEmpty()) {
      Response errRes = new Response();
      errRes.message = 'No request provided for filter validation.';
      responses.add(errRes);
      return responses;
    }

    for (Request req : requests) {
      Response res = new Response();

      try {
        if (String.isBlank(req.filterCriteria)) {
          res.message = 'Please provide filter criteria to validate.';
        } else {
          res.message = ANAgentOpenPipeAnalysisV3ServiceEnhanced.validateFilterCriteria(req.filterCriteria);
        }
      } catch (Exception e) {
        res.message = 'An error occurred while validating filter criteria: ' + e.getMessage();
      }

      responses.add(res);
    }

    return responses;
  }

  private static Boolean isValidGroupBy(String groupBy) {
    Set<String> validGroupBy = new Set<String>{
      'STAGE',
      'PRODUCT',
      'INDUSTRY',
      'MACRO_SEGMENT',
      'AE',
      'COUNTRY'
    };
    return validGroupBy.contains(groupBy);
  }

  private static Boolean isValidAggregationType(String aggregationType) {
    Set<String> validAggregationTypes = new Set<String>{
      'SUM',
      'AVG',
      'MAX',
      'MIN',
      'COUNT',
      'MEDIAN'
    };
    return validAggregationTypes.contains(aggregationType);
  }

  private static Boolean isValidAnalysisType(String analysisType) {
    Set<String> validAnalysisTypes = new Set<String>{
      'STAGE_COUNT',
      'PRODUCT_PERFORMANCE',
      'AE_SCORE_ANALYSIS',
      'AE_ANALYSIS',
      'DAYS_IN_STAGE',
      'OPPORTUNITY_DETAILS'
    };
    return validAnalysisTypes.contains(analysisType);
  }

  private static String generateSessionId(Request req) {
    // Generate a unique session ID based on request parameters
    String sessionKey =
      req.ouName +
      '_' +
      req.workLocationCountry +
      '_' +
      req.groupBy +
      '_' +
      req.filterCriteria +
      '_' +
      req.restrictInValuesCsv +
      '_' +
      req.perAENormalize +
      '_' +
      req.limitN +
      '_' +
      req.aggregationType +
      '_' +
      req.analysisType +
      '_' +
      req.negativeIntent +
      '_' +
      req.excludeProductListCsv;
    return String.valueOf(sessionKey.hashCode());
  }
}