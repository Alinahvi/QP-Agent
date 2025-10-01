/**
 * @description Manages agent memory for storing analysis data and insights
 * This service uses Salesforce Platform Cache to store analysis results that can be
 * retrieved later for TSV export functionality.
 *
 * @author AI Copilot Development Team
 * @date 2025-01-15
 * @version 1.0
 */
public with sharing class ANAgentMemoryContext {
  private static final String ANALYSIS_SUFFIX = '.analysisData';
  private static final String METADATA_SUFFIX = '.analysisMetadata';
  private static final String INSIGHTS_SUFFIX = '.insightsData';
  private static final Integer CACHE_TTL_SECONDS = 7200; // 2 hours

  // Use static maps as fallback when Platform Cache is not available
  private static Map<String, Object> analysisDataCache = new Map<String, Object>();
  private static Map<String, String> insightsDataCache = new Map<String, String>();
  private static Map<String, Object> metadataCache = new Map<String, Object>();

  /**
   * @description Stores analysis data in agent memory for later retrieval
   * @param sessionId The unique session ID for the conversation
   * @param analysisType The type of analysis (KPI, Pipeline, Renewals, etc.)
   * @param analysisData The structured analysis data
   * @param insightsData The formatted insights text
   * @param metadata Additional metadata about the analysis
   */
  public static void storeAnalysisData(
    String sessionId,
    String analysisType,
    Map<String, Object> analysisData,
    String insightsData,
    Map<String, Object> metadata
  ) {
    if (String.isBlank(sessionId)) {
      return;
    }

    try {
      // Store structured analysis data
      try {
        Cache.Session.put(
          sessionId + ANALYSIS_SUFFIX,
          analysisData,
          CACHE_TTL_SECONDS
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        analysisDataCache.put(sessionId + ANALYSIS_SUFFIX, analysisData);
        System.debug(
          'Using static map fallback for analysis data: ' +
          cacheException.getMessage()
        );
      }

      // Store formatted insights
      try {
        Cache.Session.put(
          sessionId + INSIGHTS_SUFFIX,
          insightsData,
          CACHE_TTL_SECONDS
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        insightsDataCache.put(sessionId + INSIGHTS_SUFFIX, insightsData);
        System.debug(
          'Using static map fallback for insights data: ' +
          cacheException.getMessage()
        );
      }

      // Store metadata with analysis type and timestamp
      Map<String, Object> enrichedMetadata = new Map<String, Object>();
      enrichedMetadata.putAll(metadata);
      enrichedMetadata.put('analysisType', analysisType);
      enrichedMetadata.put(
        'timestamp',
        Datetime.now().format('yyyy-MM-dd HH:mm:ss')
      );
      enrichedMetadata.put('sessionId', sessionId);

      try {
        Cache.Session.put(
          sessionId + METADATA_SUFFIX,
          enrichedMetadata,
          CACHE_TTL_SECONDS
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        metadataCache.put(sessionId + METADATA_SUFFIX, enrichedMetadata);
        System.debug(
          'Using static map fallback for metadata: ' +
          cacheException.getMessage()
        );
      }

      System.debug(
        'Stored analysis data for session: ' +
          sessionId +
          ', type: ' +
          analysisType
      );
    } catch (Exception e) {
      System.debug('Error storing analysis data: ' + e.getMessage());
    }
  }

  /**
   * @description Retrieves stored analysis data from agent memory
   * @param sessionId The unique session ID for the conversation
   * @return Map containing analysisData, insightsData, and metadata
   */
  public static Map<String, Object> getAnalysisData(String sessionId) {
    Map<String, Object> result = new Map<String, Object>();

    if (String.isBlank(sessionId)) {
      return result;
    }

    try {
      // Get structured analysis data
      Map<String, Object> analysisData = null;
      try {
        analysisData = (Map<String, Object>) Cache.Session.get(
          sessionId + ANALYSIS_SUFFIX
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        analysisData = (Map<String, Object>) analysisDataCache.get(
          sessionId + ANALYSIS_SUFFIX
        );
        System.debug(
          'Using static map fallback for analysis data retrieval: ' +
          cacheException.getMessage()
        );
      }
      result.put(
        'analysisData',
        analysisData != null ? analysisData : new Map<String, Object>()
      );

      // Get formatted insights
      String insightsData = null;
      try {
        insightsData = (String) Cache.Session.get(sessionId + INSIGHTS_SUFFIX);
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        insightsData = insightsDataCache.get(sessionId + INSIGHTS_SUFFIX);
        System.debug(
          'Using static map fallback for insights data retrieval: ' +
          cacheException.getMessage()
        );
      }
      result.put('insightsData', insightsData != null ? insightsData : '');

      // Get metadata
      Map<String, Object> metadata = null;
      try {
        metadata = (Map<String, Object>) Cache.Session.get(
          sessionId + METADATA_SUFFIX
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        metadata = (Map<String, Object>) metadataCache.get(
          sessionId + METADATA_SUFFIX
        );
        System.debug(
          'Using static map fallback for metadata retrieval: ' +
          cacheException.getMessage()
        );
      }
      result.put(
        'metadata',
        metadata != null ? metadata : new Map<String, Object>()
      );
    } catch (Exception e) {
      System.debug('Error retrieving analysis data: ' + e.getMessage());
    }

    return result;
  }

  /**
   * @description Checks if analysis data exists in memory for a session
   * @param sessionId The unique session ID for the conversation
   * @return Boolean indicating if data exists
   */
  public static Boolean hasAnalysisData(String sessionId) {
    if (String.isBlank(sessionId)) {
      return false;
    }

    try {
      Map<String, Object> analysisData = null;
      try {
        analysisData = (Map<String, Object>) Cache.Session.get(
          sessionId + ANALYSIS_SUFFIX
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        analysisData = (Map<String, Object>) analysisDataCache.get(
          sessionId + ANALYSIS_SUFFIX
        );
        System.debug(
          'Using static map fallback for analysis data check: ' +
          cacheException.getMessage()
        );
      }
      return analysisData != null && !analysisData.isEmpty();
    } catch (Exception e) {
      System.debug('Error checking analysis data: ' + e.getMessage());
      return false;
    }
  }

  /**
   * @description Clears stored analysis data from memory
   * @param sessionId The unique session ID for the conversation
   */
  public static void clearAnalysisData(String sessionId) {
    if (String.isBlank(sessionId)) {
      return;
    }

    try {
      try {
        Cache.Session.remove(sessionId + ANALYSIS_SUFFIX);
        Cache.Session.remove(sessionId + INSIGHTS_SUFFIX);
        Cache.Session.remove(sessionId + METADATA_SUFFIX);
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        analysisDataCache.remove(sessionId + ANALYSIS_SUFFIX);
        insightsDataCache.remove(sessionId + INSIGHTS_SUFFIX);
        metadataCache.remove(sessionId + METADATA_SUFFIX);
        System.debug(
          'Using static map fallback for clearing data: ' +
          cacheException.getMessage()
        );
      }

      System.debug('Cleared analysis data for session: ' + sessionId);
    } catch (Exception e) {
      System.debug('Error clearing analysis data: ' + e.getMessage());
    }
  }

  /**
   * @description Gets the analysis type for the current session
   * @param sessionId The unique session ID for the conversation
   * @return String analysis type or empty string if not found
   */
  public static String getAnalysisType(String sessionId) {
    if (String.isBlank(sessionId)) {
      return '';
    }

    try {
      Map<String, Object> metadata = null;
      try {
        metadata = (Map<String, Object>) Cache.Session.get(
          sessionId + METADATA_SUFFIX
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        metadata = (Map<String, Object>) metadataCache.get(
          sessionId + METADATA_SUFFIX
        );
        System.debug(
          'Using static map fallback for analysis type: ' +
          cacheException.getMessage()
        );
      }
      if (metadata != null && metadata.containsKey('analysisType')) {
        return (String) metadata.get('analysisType');
      }
    } catch (Exception e) {
      System.debug('Error getting analysis type: ' + e.getMessage());
    }

    return '';
  }

  /**
   * @description Gets the timestamp of the last analysis for the current session
   * @param sessionId The unique session ID for the conversation
   * @return String timestamp or empty string if not found
   */
  public static String getAnalysisTimestamp(String sessionId) {
    if (String.isBlank(sessionId)) {
      return '';
    }

    try {
      Map<String, Object> metadata = null;
      try {
        metadata = (Map<String, Object>) Cache.Session.get(
          sessionId + METADATA_SUFFIX
        );
      } catch (Exception cacheException) {
        // Fallback to static map if Platform Cache fails
        metadata = (Map<String, Object>) metadataCache.get(
          sessionId + METADATA_SUFFIX
        );
        System.debug(
          'Using static map fallback for analysis timestamp: ' +
          cacheException.getMessage()
        );
      }
      if (metadata != null && metadata.containsKey('timestamp')) {
        return (String) metadata.get('timestamp');
      }
    } catch (Exception e) {
      System.debug('Error getting analysis timestamp: ' + e.getMessage());
    }

    return '';
  }

  /**
   * @description Gets the most recent analysis data without requiring a specific session ID
   * This is useful when the agent doesn't know the exact session ID used to store the data
   * @return Map containing the most recent analysis data and its session ID
   */
  public static Map<String, Object> getMostRecentAnalysisData() {
    Map<String, Object> result = new Map<String, Object>();
    
    try {
      // Check static maps first (since Platform Cache is having issues)
      String mostRecentSessionId = null;
      String mostRecentTimestamp = null;
      
      // Find the most recent analysis in static maps
      for (String key : metadataCache.keySet()) {
        if (key.endsWith(METADATA_SUFFIX)) {
          Map<String, Object> metadata = (Map<String, Object>) metadataCache.get(key);
          if (metadata != null && metadata.containsKey('timestamp')) {
            String timestamp = (String) metadata.get('timestamp');
            if (mostRecentTimestamp == null || timestamp > mostRecentTimestamp) {
              mostRecentTimestamp = timestamp;
              mostRecentSessionId = key.replace(METADATA_SUFFIX, '');
            }
          }
        }
      }
      
      if (String.isNotBlank(mostRecentSessionId)) {
        result.put('sessionId', mostRecentSessionId);
        result.put('analysisData', getAnalysisData(mostRecentSessionId));
        result.put('analysisType', getAnalysisType(mostRecentSessionId));
        result.put('timestamp', mostRecentTimestamp);
        System.debug('Found most recent analysis data for session: ' + mostRecentSessionId);
      } else {
        System.debug('No analysis data found in memory');
      }
    } catch (Exception e) {
      System.debug('Error getting most recent analysis data: ' + e.getMessage());
    }
    
    return result;
  }

  /**
   * @description Checks if there is any analysis data stored in memory
   * @return true if any analysis data exists, false otherwise
   */
  public static Boolean hasAnyAnalysisData() {
    try {
      // Check static maps first
      return !metadataCache.isEmpty();
    } catch (Exception e) {
      System.debug('Error checking for any analysis data: ' + e.getMessage());
      return false;
    }
  }
}