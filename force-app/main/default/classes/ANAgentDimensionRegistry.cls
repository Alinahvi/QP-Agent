public with sharing class ANAgentDimensionRegistry {
    
    public class DimensionDefinition {
        public String dimensionKey;
        public String fieldName;
        public String cardinality;
        public String parentDimension;
        public Map<String, String> aliases;
        
        public DimensionDefinition(String key, String field, String card, String parent, Map<String, String> aliasMap) {
            this.dimensionKey = key;
            this.fieldName = field;
            this.cardinality = card;
            this.parentDimension = parent;
            this.aliases = aliasMap != null ? aliasMap : new Map<String, String>();
        }
    }
    
    // Singleton instance
    private static ANAgentDimensionRegistry instance;
    
    // Dimension definitions cache
    private Map<String, DimensionDefinition> dimensions;
    
    private ANAgentDimensionRegistry() {
        initializeDimensions();
    }
    
    public static ANAgentDimensionRegistry getInstance() {
        if (instance == null) {
            instance = new ANAgentDimensionRegistry();
        }
        return instance;
    }
    
    private void initializeDimensions() {
        dimensions = new Map<String, DimensionDefinition>();
        
        // Country/Region dimensions
        Map<String, String> countryAliases = new Map<String, String>{
            'USA' => 'US', 'U.S.' => 'US', 'United States' => 'US',
            'Brasil' => 'Brazil', 'UK' => 'UKI', 'U.K.' => 'UKI'
        };
        
        dimensions.put('COUNTRY', new DimensionDefinition(
            'COUNTRY', 'WORK_LOCATION_COUNTRY__c', 'high', 'REGION', countryAliases
        ));
        
        dimensions.put('REGION', new DimensionDefinition(
            'REGION', 'WORK_LOCATION_COUNTRY__c', 'medium', null, null
        ));
        
        // Organizational dimensions
        dimensions.put('OU', new DimensionDefinition(
            'OU', 'OU_NAME__c', 'medium', 'REGION', null
        ));
        
        dimensions.put('INDUSTRY', new DimensionDefinition(
            'INDUSTRY', 'PRIMARY_INDUSTRY__c', 'medium', null, null
        ));
        
        // Employee dimensions
        dimensions.put('AE', new DimensionDefinition(
            'AE', 'EMP_ID__c', 'high', 'OU', null
        ));
        
        dimensions.put('MANAGER', new DimensionDefinition(
            'MANAGER', 'EMP_MGR_NM__c', 'medium', 'OU', null
        ));
        
        dimensions.put('FULL_NAME', new DimensionDefinition(
            'FULL_NAME', 'FULL_NAME__c', 'high', 'AE', null
        ));
        
        dimensions.put('EMAIL', new DimensionDefinition(
            'EMAIL', 'EMP_EMAIL_ADDR__c', 'high', 'AE', null
        ));
        
        // Learning dimensions
        dimensions.put('LEARNER_PROFILE', new DimensionDefinition(
            'LEARNER_PROFILE', 'LEARNER_PROFILE_ID__c', 'high', 'AE', null
        ));
        
        // Legacy aliases for backward compatibility
        dimensions.put('WORK_LOCATION_COUNTRY', new DimensionDefinition(
            'WORK_LOCATION_COUNTRY', 'WORK_LOCATION_COUNTRY__c', 'high', 'REGION', countryAliases
        ));
        
        dimensions.put('OU_NAME', new DimensionDefinition(
            'OU_NAME', 'OU_NAME__c', 'medium', 'REGION', null
        ));
        
        dimensions.put('PRIMARY_INDUSTRY', new DimensionDefinition(
            'PRIMARY_INDUSTRY', 'PRIMARY_INDUSTRY__c', 'medium', null, null
        ));
        
        dimensions.put('EMP_ID', new DimensionDefinition(
            'EMP_ID', 'EMP_ID__c', 'high', 'OU', null
        ));
        
        dimensions.put('EMP_MGR_NM', new DimensionDefinition(
            'EMP_MGR_NM', 'EMP_MGR_NM__c', 'medium', 'OU', null
        ));
        
        dimensions.put('EMP_EMAIL_ADDR', new DimensionDefinition(
            'EMP_EMAIL_ADDR', 'EMP_EMAIL_ADDR__c', 'high', 'AE', null
        ));
        
        dimensions.put('LEARNER_PROFILE_ID', new DimensionDefinition(
            'LEARNER_PROFILE_ID', 'LEARNER_PROFILE_ID__c', 'high', 'AE', null
        ));
    }
    
    /**
     * Get field name for dimension
     * @param dimKey String dimension key
     * @return String field name or null if not found
     */
    public String fieldFor(String dimKey) {
        if (String.isBlank(dimKey)) return null;
        
        DimensionDefinition def = dimensions.get(dimKey.toUpperCase());
        if (def != null) {
            return def.fieldName;
        }
        
        // Fallback: if it already has __c, return as is, otherwise append it
        return dimKey.endsWith('__c') ? dimKey : dimKey + '__c';
    }
    
    /**
     * Normalize dimension value using aliases and rules
     * @param dimKey String dimension key
     * @param raw String raw value
     * @return String normalized value
     */
    public String normalize(String dimKey, String raw) {
        if (String.isBlank(raw)) return raw;
        
        String v = raw.trim();
        DimensionDefinition def = dimensions.get(dimKey.toUpperCase());
        
        if (def != null && def.aliases.containsKey(v)) {
            return def.aliases.get(v);
        }
        
        return v;
    }
    
    /**
     * Get dimension definition by key
     * @param dimKey String dimension key
     * @return DimensionDefinition or null if not found
     */
    public DimensionDefinition get(String dimKey) {
        if (String.isBlank(dimKey)) return null;
        return dimensions.get(dimKey.toUpperCase());
    }
    
    /**
     * Check if dimension exists
     * @param dimKey String dimension key
     * @return Boolean true if dimension exists
     */
    public Boolean hasDimension(String dimKey) {
        return get(dimKey) != null;
    }
    
    /**
     * Get cardinality hint for dimension
     * @param dimKey String dimension key
     * @return String cardinality (high/medium/low)
     */
    public String getCardinality(String dimKey) {
        DimensionDefinition def = get(dimKey);
        return def != null ? def.cardinality : 'medium';
    }
    
    /**
     * Get parent dimension for hierarchy
     * @param dimKey String dimension key
     * @return String parent dimension key or null
     */
    public String getParentDimension(String dimKey) {
        DimensionDefinition def = get(dimKey);
        return def != null ? def.parentDimension : null;
    }
    
    /**
     * Get all available dimension keys
     * @return List<String> of dimension keys
     */
    public List<String> getAllDimensionKeys() {
        return new List<String>(dimensions.keySet());
    }
    
    /**
     * Get canonical dimension key (resolve aliases to primary keys)
     * @param dimKey String dimension key
     * @return String canonical dimension key
     */
    public String getCanonicalKey(String dimKey) {
        if (String.isBlank(dimKey)) return dimKey;
        
        // Check if this is already a canonical key
        if (dimensions.containsKey(dimKey.toUpperCase())) {
            return dimKey.toUpperCase();
        }
        
        // Check if it's an alias of any dimension
        for (String key : dimensions.keySet()) {
            DimensionDefinition def = dimensions.get(key);
            if (def.aliases.containsKey(dimKey)) {
                return key;
            }
        }
        
        return dimKey.toUpperCase();
    }
} 