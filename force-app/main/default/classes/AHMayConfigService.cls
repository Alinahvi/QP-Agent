/**
 * Configuration service for centralized settings
 */
public class AHMayConfigService {
    // Cached configuration values
    private static Map<String, Object> configSettings;
    
    // Default settings
    private static final Map<String, Object> DEFAULT_SETTINGS = new Map<String, Object>{
        'DefaultPageSize' => 20,
        'MaxPageSize' => 100,
        'CacheExpiryMinutes' => 30,
        'MaxCacheEntries' => 100,
        'EnableDetailedLogging' => false,
        'PerformanceThresholdWarnMs' => 3000,
        'PerformanceThresholdErrorMs' => 6000,
        'EnableNameResolutionCache' => true,
        'MaxManagerLookupResults' => 5,
        'EnableBackgroundProcessing' => true,
        'BackgroundProcessingBatchSize' => 200,
        'EnableErrorNotifications' => false,
        'ErrorNotificationEmails' => '',
        'PromptTemplateApiName' => 'Parse_User_Query'
    };
    
    /**
     * Get a configuration setting
     */
    public static Object getSetting(String settingName) {
        // Lazy load configuration
        if (configSettings == null) {
            loadConfiguration();
        }
        
        // Return setting or default value
        if (configSettings.containsKey(settingName)) {
            return configSettings.get(settingName);
        } else if (DEFAULT_SETTINGS.containsKey(settingName)) {
            return DEFAULT_SETTINGS.get(settingName);
        }
        
        return null;
    }
    
    /**
     * Get a configuration setting as Integer
     */
    public static Integer getIntegerSetting(String settingName) {
        Object value = getSetting(settingName);
        
        if (value instanceof Integer) {
            return (Integer)value;
        } else if (value instanceof String) {
            try {
                return Integer.valueOf((String)value);
            } catch (Exception e) {
                // Return default if parsing fails
                if (DEFAULT_SETTINGS.containsKey(settingName) && 
                    DEFAULT_SETTINGS.get(settingName) instanceof Integer) {
                    return (Integer)DEFAULT_SETTINGS.get(settingName);
                }
            }
        }
        
        return 0; // Default fallback
    }
    
    /**
     * Get a configuration setting as Boolean
     */
    public static Boolean getBooleanSetting(String settingName) {
        Object value = getSetting(settingName);
        
        if (value instanceof Boolean) {
            return (Boolean)value;
        } else if (value instanceof String) {
            String strValue = (String)value;
            return 'true'.equalsIgnoreCase(strValue) || 
                  'yes'.equalsIgnoreCase(strValue) || 
                  '1'.equals(strValue);
        }
        
        // Return default if available
        if (DEFAULT_SETTINGS.containsKey(settingName) && 
            DEFAULT_SETTINGS.get(settingName) instanceof Boolean) {
            return (Boolean)DEFAULT_SETTINGS.get(settingName);
        }
        
        return false; // Default fallback
    }
    
    /**
     * Get a configuration setting as String
     */
    public static String getStringSetting(String settingName) {
        Object value = getSetting(settingName);
        
        if (value instanceof String) {
            return (String)value;
        } else if (value != null) {
            return String.valueOf(value);
        }
        
        // Return default if available
        if (DEFAULT_SETTINGS.containsKey(settingName) && 
            DEFAULT_SETTINGS.get(settingName) instanceof String) {
            return (String)DEFAULT_SETTINGS.get(settingName);
        }
        
        return ''; // Default fallback
    }
    
   /**
 * Load configuration from custom metadata
 */
private static void loadConfiguration() {
    configSettings = new Map<String, Object>();
    
    try {
        // In a production implementation, you'd query from Custom Metadata
        // For now, use default settings as a fallback
        configSettings.putAll(DEFAULT_SETTINGS);
        
        // Example of how it would be implemented with Custom Metadata:
        /*
        List<AHMay_Configuration__mdt> configs = [
            SELECT DeveloperName, Value__c, Type__c
            FROM AHMay_Configuration__mdt
            WHERE Active__c = true
        ];
        
        for (AHMay_Configuration__mdt config : configs) {
            Object typedValue;
            
            // Convert to appropriate type
            switch on config.Type__c {
                when 'String' {
                    typedValue = config.Value__c;
                }
                when 'Integer' {
                    typedValue = Integer.valueOf(config.Value__c);
                }
                when 'Boolean' {
                    typedValue = Boolean.valueOf(config.Value__c);
                }
                when 'Decimal' {
                    typedValue = Decimal.valueOf(config.Value__c);
                }
                when else {
                    typedValue = config.Value__c;
                }
            }
            
            configSettings.put(config.DeveloperName, typedValue);
        }
        */
        
        // Apply org-specific overrides if needed
        applyOrgSpecificOverrides();
        
    } catch (Exception e) {
        // Log error and fall back to defaults
        System.debug(LoggingLevel.ERROR, 'Error loading configuration: ' + 
                   e.getMessage() + '. Using default settings.');
        configSettings = new Map<String, Object>(DEFAULT_SETTINGS);
    }
}

/**
 * Apply org-specific configuration overrides
 */
private static void applyOrgSpecificOverrides() {
    // This method would contain any org-specific configuration adjustments
    // For example, in a sandbox we might want more verbose logging
    
    if (isSandboxOrg()) {
        configSettings.put('EnableDetailedLogging', true);
    }
    
    // Add any performance optimizations for production
    if (isProductionOrg()) {
        configSettings.put('EnableNameResolutionCache', true);
        configSettings.put('CacheExpiryMinutes', 60); // Longer cache in production
    }
}

/**
 * Check if running in a sandbox
 */
private static Boolean isSandboxOrg() {
    // Get the org ID to determine if we're in a sandbox
    String orgId = UserInfo.getOrganizationId();
    
    // Sandbox orgs have IDs that end with 's'
    return orgId.endsWith('s');
}

/**
 * Check if running in production
 */
private static Boolean isProductionOrg() {
    // Get the org ID to determine if we're in production
    String orgId = UserInfo.getOrganizationId();
    
    // Production orgs have IDs that don't end with 's'
    return !orgId.endsWith('s');
}

/**
 * Refresh configuration settings
 */
public static void refreshConfiguration() {
    // Clear cached settings and reload
    configSettings = null;
    loadConfiguration();
    
    System.debug('Configuration refreshed at ' + System.now());
}

/**
 * Get all configuration settings
 */
public static Map<String, Object> getAllSettings() {
    // Lazy load configuration if needed
    if (configSettings == null) {
        loadConfiguration();
    }
    
    return configSettings;
}
}