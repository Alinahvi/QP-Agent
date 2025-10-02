/**
 * COMPREHENSIVE NAMING NORMALIZER
 * 
 * This class provides intelligent normalization of various naming conventions
 * used across the Salesforce ecosystem, with context-aware resolution for
 * products, OUs, countries, and segments.
 * 
 * Key Features:
 * - Context-aware product family resolution
 * - Comprehensive OU name variations
 * - Country name standardization
 * - Macro segment normalization
 * - Sales terminology mapping
 * 
 * @version 1.0 - Data-Driven Normalization
 */
public with sharing class ANAgentNamingNormalizer {
    
    // ============================================================================
    // PRODUCT FAMILY MAPPINGS (Based on Real Data Analysis)
    // ============================================================================
    
    private static final Map<String, String> PRODUCT_FAMILY_MAP = new Map<String, String>{
        // Tableau Family - Context-aware resolution
        'Tableau' => 'Tableau Server', // Most common pattern in data
        'Tableau Server' => 'Tableau Server',
        'Tableau Desktop' => 'Tableau Desktop',
        'Tableau Prep' => 'Tableau Prep',
        'Tableau Cloud' => 'Tableau Cloud',
        'Tableau Analytics' => 'Tableau Server',
        
        // Agentforce Family - Context-aware resolution
        'Agentforce' => 'Agentforce Conversations', // Most common pattern in data
        'Agentforce Service' => 'Agentforce Conversations',
        'Agentforce Sales Coach' => 'Agentforce Conversations',
        'Agentforce Conversations' => 'Agentforce Conversations',
        
        // Marketing Cloud Family
        'Marketing Cloud' => 'Marketing Cloud - Advanced',
        'Marketing Cloud Advanced' => 'Marketing Cloud - Advanced',
        'Marketing Cloud Campaign' => 'Marketing Cloud - Campaign Manager',
        'Marketing Cloud Engagement' => 'Marketing Cloud - Engagement Manager',
        
        // Salesforce Core Products
        'Sales Cloud' => 'Sales Cloud',
        'Service Cloud' => 'Service Cloud',
        'Einstein' => 'Salesforce Einstein',
        'Slack' => 'Slack (Salesforce)',
        'MuleSoft' => 'MuleSoft (Salesforce)',
        
        // Industry Clouds
        'Health Cloud' => 'Health Cloud',
        'Financial Services Cloud' => 'Financial Services Cloud',
        'Manufacturing Cloud' => 'Manufacturing Cloud',
        'Consumer Goods Cloud' => 'Consumer Goods Cloud',
        'Automotive Cloud' => 'Automotive Cloud',
        'Communications Cloud' => 'Communications Cloud',
        'Energy & Utilities Cloud' => 'Energy & Utilities Cloud',
        'Life Sciences Cloud' => 'Life Sciences Cloud',
        'Education Cloud' => 'Education Cloud',
        'Field Service Cloud' => 'Field Service Cloud'
    };
    
    // ============================================================================
    // OU NAME MAPPINGS (Based on Real Data from Learner_Profile__c)
    // ============================================================================
    
    private static final Map<String, String> OU_ALIAS_MAP = new Map<String, String>{
        // AMER Variations
        'AMER-ACC' => 'AMER ACC',
        'AMER_ACC' => 'AMER ACC',
        'Amer-ACC' => 'AMER ACC',
        'Amer ACC' => 'AMER ACC',
        'AmerACC' => 'AMER ACC',
        'AMERACC' => 'AMER ACC',
        
        'AMER-ICE' => 'AMER ICE',
        'AMER_ICE' => 'AMER ICE',
        'Amer-ICE' => 'AMER ICE',
        'Amer ICE' => 'AMER ICE',
        'AmerICE' => 'AMER ICE',
        'AMERICE' => 'AMER ICE',
        
        'AMER-REG' => 'AMER REG',
        'AMER_REG' => 'AMER REG',
        'Amer-REG' => 'AMER REG',
        'Amer REG' => 'AMER REG',
        'AmerREG' => 'AMER REG',
        'AMERREG' => 'AMER REG',
        
        // AMER Industry Specific
        'AMER-CAN' => 'AMER - CAN',
        'AMER_CAN' => 'AMER - CAN',
        'AMER-CBS' => 'AMER - CBS',
        'AMER_CBS' => 'AMER - CBS',
        'AMER-CMT' => 'AMER - CMT',
        'AMER_CMT' => 'AMER - CMT',
        'AMER-FINS' => 'AMER - FINS',
        'AMER_FINS' => 'AMER - FINS',
        'AMER-HLS' => 'AMER - HLS',
        'AMER_HLS' => 'AMER - HLS',
        'AMER-MAE' => 'AMER - MAE',
        'AMER_MAE' => 'AMER - MAE',
        'AMER-MCRC' => 'AMER - MCRC',
        'AMER_MCRC' => 'AMER - MCRC',
        
        // SMB Variations
        'SMB-AMER' => 'SMB - AMER SMB',
        'SMB_AMER' => 'SMB - AMER SMB',
        'SMBAMER' => 'SMB - AMER SMB',
        'AMER-SMB' => 'SMB - AMER SMB',
        'AMER_SMB' => 'SMB - AMER SMB',
        'AMERSMB' => 'SMB - AMER SMB',
        'SMB AMER' => 'SMB - AMER SMB',
        'AMER SMB' => 'SMB - AMER SMB',
        
        'SMB-EMEA' => 'SMB - EMEA SMB',
        'SMB_EMEA' => 'SMB - EMEA SMB',
        'SMBEMEA' => 'SMB - EMEA SMB',
        'EMEA-SMB' => 'SMB - EMEA SMB',
        'EMEA_SMB' => 'SMB - EMEA SMB',
        'EMEASMB' => 'SMB - EMEA SMB',
        'SMB EMEA' => 'SMB - EMEA SMB',
        'EMEA SMB' => 'SMB - EMEA SMB',
        
        'SMB-EBOU' => 'SMB - EBOU',
        'SMB_EBOU' => 'SMB - EBOU',
        'SMBEBOU' => 'SMB - EBOU',
        'EBOU-SMB' => 'SMB - EBOU',
        'EBOU_SMB' => 'SMB - EBOU',
        'EBOUSMB' => 'SMB - EBOU',
        'SMB EBOU' => 'SMB - EBOU',
        'EBOU SMB' => 'SMB - EBOU',
        
        // EMEA Variations
        'EMEA-Central' => 'EMEA Central',
        'EMEA_Central' => 'EMEA Central',
        'EMEACentral' => 'EMEA Central',
        'Central-EMEA' => 'EMEA Central',
        'Central_EMEA' => 'EMEA Central',
        'CentralEMEA' => 'EMEA Central',
        
        'EMEA-North' => 'EMEA North',
        'EMEA_North' => 'EMEA North',
        'EMEANorth' => 'EMEA North',
        'North-EMEA' => 'EMEA North',
        'North_EMEA' => 'EMEA North',
        'NorthEMEA' => 'EMEA North',
        
        'EMEA-South' => 'EMEA South',
        'EMEA_South' => 'EMEA South',
        'EMEASouth' => 'EMEA South',
        'South-EMEA' => 'EMEA South',
        'South_EMEA' => 'EMEA South',
        'SouthEMEA' => 'EMEA South',
        
        // Regional Variations
        'Central-Europe' => 'Central Europe',
        'Central_Europe' => 'Central Europe',
        'CentralEurope' => 'Central Europe',
        
        'Northern-Europe' => 'Northern Europe',
        'Northern_Europe' => 'Northern Europe',
        'NorthernEurope' => 'Northern Europe',
        
        // Asia Pacific Variations
        'South-Asia-India' => 'South Asia - India',
        'South_Asia_India' => 'South Asia - India',
        'SouthAsiaIndia' => 'South Asia - India',
        'India-South-Asia' => 'South Asia - India',
        'India_South_Asia' => 'South Asia - India',
        'IndiaSouthAsia' => 'South Asia - India',
        
        'South-Asia-ASEAN' => 'South Asia - ASEAN',
        'South_Asia_ASEAN' => 'South Asia - ASEAN',
        'SouthAsiaASEAN' => 'South Asia - ASEAN',
        'ASEAN-South-Asia' => 'South Asia - ASEAN',
        'ASEAN_South_Asia' => 'South Asia - ASEAN',
        'ASEANSouthAsia' => 'South Asia - ASEAN',
        
        'ASEAN' => 'South Asia - ASEAN',
        'asean' => 'South Asia - ASEAN',
        'ASEAN-REGION' => 'South Asia - ASEAN',
        'ASEAN_REGION' => 'South Asia - ASEAN',
        
        // Product-Specific OUs
        'NextGen-Platform' => 'NextGen Platform',
        'NextGen_Platform' => 'NextGen Platform',
        'NextGenPlatform' => 'NextGen Platform',
        'Next-Gen-Platform' => 'NextGen Platform',
        'Next_Gen_Platform' => 'NextGen Platform',
        'NextGen' => 'NextGen Platform',
        'NEXTGEN' => 'NextGen Platform',
        
        'PubSec-Plus-Org' => 'PubSec+.Org',
        'PubSec_Plus_Org' => 'PubSec+.Org',
        'PubSecPlusOrg' => 'PubSec+.Org',
        'PubSec+.Org' => 'PubSec+.Org',
        'PubSec' => 'PubSec+.Org',
        'PUBSEC' => 'PubSec+.Org',
        'PUB_SEC' => 'PubSec+.Org',
        'PUB_SEC_PLUS' => 'PubSec+.Org',
        
        // Standard OUs (no aliases needed)
        'UKI' => 'UKI',
        'LATAM' => 'LATAM',
        'ANZ' => 'ANZ',
        'APAC' => 'APAC',
        'France' => 'France',
        'Japan' => 'Japan',
        'India' => 'India',
        'GCR' => 'GCR',
        'EBOU' => 'EBOU',
        'MuleSoft' => 'MuleSoft',
        'Slack' => 'Slack',
        'Tableau' => 'Tableau',
        'STHCEN' => 'STHCEN',
        'CMT Media' => 'CMT Media',
        'CMT Tech' => 'CMT Tech',
        'Japan & Korea' => 'Japan & Korea',
        'Northern Europe' => 'Northern Europe',
        'Central Europe' => 'Central Europe',
        'SEMEA' => 'SEMEA',
        'TBD' => 'TBD',
        'OU Not Specified' => 'OU Not Specified',
        'Unmapped' => 'Unmapped'
    };
    
    // ============================================================================
    // COUNTRY NAME MAPPINGS (Based on Real Data from Learner_Profile__c)
    // ============================================================================
    
    private static final Map<String, String> COUNTRY_ALIAS_MAP = new Map<String, String>{
        // United States Variations
        'USA' => 'United States of America',
        'U.S.' => 'United States of America',
        'U.S.A.' => 'United States of America',
        'U.S.A' => 'United States of America',
        'United States' => 'United States of America',
        'US' => 'United States of America',
        'us' => 'United States of America',
        'u.s.a' => 'United States of America',
        'u.s.a.' => 'United States of America',
        
        // United Kingdom Variations
        'UK' => 'United Kingdom',
        'U.K.' => 'United Kingdom',
        'U.K' => 'United Kingdom',
        'Great Britain' => 'United Kingdom',
        'Britain' => 'United Kingdom',
        'England' => 'United Kingdom',
        'Scotland' => 'United Kingdom',
        'Wales' => 'United Kingdom',
        'Northern Ireland' => 'United Kingdom',
        
        // Canada Variations
        'CA' => 'Canada',
        'ca' => 'Canada',
        'CAN' => 'Canada',
        'can' => 'Canada',
        
        // Brazil Variations
        'Brasil' => 'Brazil',
        'brasil' => 'Brazil',
        'BR' => 'Brazil',
        'br' => 'Brazil',
        
        // Korea Variations
        'South Korea' => 'Korea, Republic of',
        'Korea' => 'Korea, Republic of',
        'ROK' => 'Korea, Republic of',
        'Republic of Korea' => 'Korea, Republic of',
        
        // Other Common Variations
        'UAE' => 'United Arab Emirates',
        'United Arab Emirates' => 'United Arab Emirates',
        'Emirates' => 'United Arab Emirates',
        
        // Standard names (no aliases needed)
        'Argentina' => 'Argentina',
        'Australia' => 'Australia',
        'Austria' => 'Austria',
        'Belgium' => 'Belgium',
        'Chile' => 'Chile',
        'Colombia' => 'Colombia',
        'Denmark' => 'Denmark',
        'Finland' => 'Finland',
        'France' => 'France',
        'Germany' => 'Germany',
        'India' => 'India',
        'Indonesia' => 'Indonesia',
        'Ireland' => 'Ireland',
        'Israel' => 'Israel',
        'Italy' => 'Italy',
        'Japan' => 'Japan',
        'Mexico' => 'Mexico',
        'Morocco' => 'Morocco',
        'Netherlands' => 'Netherlands',
        'New Zealand' => 'New Zealand',
        'Norway' => 'Norway',
        'Portugal' => 'Portugal',
        'Singapore' => 'Singapore',
        'South Africa' => 'South Africa',
        'Spain' => 'Spain',
        'Sweden' => 'Sweden',
        'Switzerland' => 'Switzerland',
        'Thailand' => 'Thailand'
    };
    
    // ============================================================================
    // MACRO SEGMENT MAPPINGS (Based on Real Data from Agent_Open_Pipe__c)
    // ============================================================================
    
    private static final Map<String, String> SEGMENT_ALIAS_MAP = new Map<String, String>{
        // Commercial Variations
        'CMRCL' => 'CMRCL',
        'cmrcl' => 'CMRCL',
        'Commercial' => 'CMRCL',
        'commercial' => 'CMRCL',
        'COMM' => 'CMRCL',
        'comm' => 'CMRCL',
        'COMMERCIAL' => 'CMRCL',
        'COMMERCIAL' => 'CMRCL',
        
        // Enterprise Variations
        'ENTR' => 'ENTR',
        'entr' => 'ENTR',
        'Enterprise' => 'ENTR',
        'enterprise' => 'ENTR',
        'ENT' => 'ENTR',
        'ent' => 'ENTR',
        'ENTRPRISE' => 'ENTR',
        'entrprise' => 'ENTR',
        
        // Enterprise SMB Variations
        'ESMB' => 'ESMB',
        'esmb' => 'ESMB',
        'Enterprise SMB' => 'ESMB',
        'enterprise smb' => 'ESMB',
        'ENT_SMB' => 'ESMB',
        'ent_smb' => 'ESMB',
        'ENT-SMB' => 'ESMB',
        'ent-smb' => 'ESMB',
        'ENTERSMB' => 'ESMB',
        'entersmb' => 'ESMB',
        
        // Public Sector Variations
        'PubSec' => 'PubSec',
        'pubsec' => 'PubSec',
        'Public Sector' => 'PubSec',
        'public sector' => 'PubSec',
        'PUB_SEC' => 'PubSec',
        'pub_sec' => 'PubSec',
        'PUB-SEC' => 'PubSec',
        'pub-sec' => 'PubSec',
        'GOVT' => 'PubSec',
        'govt' => 'PubSec',
        'Government' => 'PubSec',
        'government' => 'PubSec',
        
        // Unmapped
        'Unmapped' => 'Unmapped',
        'unmapped' => 'Unmapped',
        'UNMAPPED' => 'Unmapped'
    };
    
    // ============================================================================
    // SALES TERMINOLOGY MAPPINGS
    // ============================================================================
    
    private static final Map<String, String> SALES_TERM_MAP = new Map<String, String>{
        // Cross-sell Variations
        'off-sell' => 'Cross-sell',
        'offsell' => 'Cross-sell',
        'cross-sell' => 'Cross-sell',
        'crosssell' => 'Cross-sell',
        'cross sell' => 'Cross-sell',
        'Cross Sell' => 'Cross-sell',
        'CROSS_SELL' => 'Cross-sell',
        'cross_sell' => 'Cross-sell',
        
        // Renewal Variations
        'renewal' => 'Renewal',
        'renewals' => 'Renewal',
        'Renewal' => 'Renewal',
        'RENEWAL' => 'Renewal',
        'RENEWALS' => 'Renewal',
        
        // Upsell Variations
        'upsell' => 'Upsell',
        'up-sell' => 'Upsell',
        'up sell' => 'Upsell',
        'Upsell' => 'Upsell',
        'UPSELL' => 'Upsell',
        'UP_SELL' => 'Upsell',
        'up_sell' => 'Upsell',
        
        // Scorecard Variations
        'scorecard' => 'Performance Scorecard',
        'Scorecard' => 'Performance Scorecard',
        'SCORECARD' => 'Performance Scorecard',
        'performance scorecard' => 'Performance Scorecard',
        'Performance Scorecard' => 'Performance Scorecard',
        'PERFORMANCE_SCORECARD' => 'Performance Scorecard',
        'performance_scorecard' => 'Performance Scorecard',
        
        // Ramp Variations
        'ramp' => 'Ramp Status',
        'Ramp' => 'Ramp Status',
        'RAMP' => 'Ramp Status',
        'ramping' => 'Ramp Status',
        'Ramping' => 'Ramp Status',
        'RAMPING' => 'Ramp Status',
        'ramp status' => 'Ramp Status',
        'Ramp Status' => 'Ramp Status',
        'RAMP_STATUS' => 'Ramp Status',
        'ramp_status' => 'Ramp Status'
    };
    
    // ============================================================================
    // PUBLIC NORMALIZATION METHODS
    // ============================================================================
    
    /**
     * Normalizes OU names with comprehensive alias mapping
     * @param input Raw OU name input
     * @return Normalized OU name
     */
    public static String normalizeOUName(String input) {
        if (String.isBlank(input)) return input;
        
        String normalized = input.trim();
        
        // Check for exact match first
        if (OU_ALIAS_MAP.containsKey(normalized)) {
            return OU_ALIAS_MAP.get(normalized);
        }
        
        // Check case-insensitive match
        for (String key : OU_ALIAS_MAP.keySet()) {
            if (key.equalsIgnoreCase(normalized)) {
                return OU_ALIAS_MAP.get(key);
            }
        }
        
        return normalized; // Return original if no match found
    }
    
    /**
     * Normalizes country names with comprehensive alias mapping
     * @param input Raw country name input
     * @return Normalized country name
     */
    public static String normalizeCountry(String input) {
        if (String.isBlank(input)) return input;
        
        String normalized = input.trim();
        
        // Check for exact match first
        if (COUNTRY_ALIAS_MAP.containsKey(normalized)) {
            return COUNTRY_ALIAS_MAP.get(normalized);
        }
        
        // Check case-insensitive match
        for (String key : COUNTRY_ALIAS_MAP.keySet()) {
            if (key.equalsIgnoreCase(normalized)) {
                return COUNTRY_ALIAS_MAP.get(key);
            }
        }
        
        return normalized; // Return original if no match found
    }
    
    /**
     * Normalizes macro segment names with comprehensive alias mapping
     * @param input Raw segment name input
     * @return Normalized segment name
     */
    public static String normalizeMacroSegment(String input) {
        if (String.isBlank(input)) return input;
        
        String normalized = input.trim();
        
        // Check for exact match first
        if (SEGMENT_ALIAS_MAP.containsKey(normalized)) {
            return SEGMENT_ALIAS_MAP.get(normalized);
        }
        
        // Check case-insensitive match
        for (String key : SEGMENT_ALIAS_MAP.keySet()) {
            if (key.equalsIgnoreCase(normalized)) {
                return SEGMENT_ALIAS_MAP.get(key);
            }
        }
        
        return normalized; // Return original if no match found
    }
    
    /**
     * Normalizes product names with context-aware family resolution
     * @param input Raw product name input
     * @return Normalized product name
     */
    public static String normalizeProductName(String input) {
        if (String.isBlank(input)) return input;
        
        String normalized = input.trim();
        
        // Check for exact match first
        if (PRODUCT_FAMILY_MAP.containsKey(normalized)) {
            return PRODUCT_FAMILY_MAP.get(normalized);
        }
        
        // Check case-insensitive match
        for (String key : PRODUCT_FAMILY_MAP.keySet()) {
            if (key.equalsIgnoreCase(normalized)) {
                return PRODUCT_FAMILY_MAP.get(key);
            }
        }
        
        return normalized; // Return original if no match found
    }
    
    /**
     * Normalizes sales terminology
     * @param input Raw sales term input
     * @return Normalized sales term
     */
    public static String normalizeSalesTerm(String input) {
        if (String.isBlank(input)) return input;
        
        String normalized = input.trim();
        
        // Check for exact match first
        if (SALES_TERM_MAP.containsKey(normalized)) {
            return SALES_TERM_MAP.get(normalized);
        }
        
        // Check case-insensitive match
        for (String key : SALES_TERM_MAP.keySet()) {
            if (key.equalsIgnoreCase(normalized)) {
                return SALES_TERM_MAP.get(key);
            }
        }
        
        return normalized; // Return original if no match found
    }
    
    /**
     * Comprehensive normalization that handles all types
     * @param input Raw input string
     * @param type Type of normalization ('OU', 'COUNTRY', 'SEGMENT', 'PRODUCT', 'SALES')
     * @return Normalized string
     */
    public static String normalize(String input, String type) {
        if (String.isBlank(input) || String.isBlank(type)) return input;
        
        switch on type.toUpperCase() {
            when 'OU' {
                return normalizeOUName(input);
            }
            when 'COUNTRY' {
                return normalizeCountry(input);
            }
            when 'SEGMENT' {
                return normalizeMacroSegment(input);
            }
            when 'PRODUCT' {
                return normalizeProductName(input);
            }
            when 'SALES' {
                return normalizeSalesTerm(input);
            }
            when else {
                return input; // Return original if type not recognized
            }
        }
    }
    
    /**
     * Gets all available OU names for reference
     * @return Set of all canonical OU names
     */
    public static Set<String> getAvailableOUs() {
        return new Set<String>(OU_ALIAS_MAP.values());
    }
    
    /**
     * Gets all available country names for reference
     * @return Set of all canonical country names
     */
    public static Set<String> getAvailableCountries() {
        return new Set<String>(COUNTRY_ALIAS_MAP.values());
    }
    
    /**
     * Gets all available segment names for reference
     * @return Set of all canonical segment names
     */
    public static Set<String> getAvailableSegments() {
        return new Set<String>(SEGMENT_ALIAS_MAP.values());
    }
    
    /**
     * Gets all available product families for reference
     * @return Set of all canonical product family names
     */
    public static Set<String> getAvailableProductFamilies() {
        return new Set<String>(PRODUCT_FAMILY_MAP.values());
    }
    
    // Stage Mapping - Human-friendly stage numbers to full stage names
    private static final Map<String, String> STAGE_MAP = new Map<String, String>{
        'stage 1' => 'Stage 1 - Identifying Opportunity',
        'stage1' => 'Stage 1 - Identifying Opportunity',
        'stage 2' => 'Stage 2 - Determining Problem, Impact, Ideal',
        'stage2' => 'Stage 2 - Determining Problem, Impact, Ideal',
        'stage 3' => 'Stage 3 - Validating Benefits & Value',
        'stage3' => 'Stage 3 - Validating Benefits & Value',
        'stage 4' => 'Stage 4 - Confirming Value With Power',
        'stage4' => 'Stage 4 - Confirming Value With Power',
        'stage 5' => 'Stage 5 - Negotiating $$ & Mutual Plan',
        'stage5' => 'Stage 5 - Negotiating $$ & Mutual Plan',
        'stage 6' => 'Stage 6 - Finalizing Closure',
        'stage6' => 'Stage 6 - Finalizing Closure',
        'stage 7' => 'Stage 7 - Pending',
        'stage7' => 'Stage 7 - Pending',
        '1' => 'Stage 1 - Identifying Opportunity',
        '2' => 'Stage 2 - Determining Problem, Impact, Ideal',
        '3' => 'Stage 3 - Validating Benefits & Value',
        '4' => 'Stage 4 - Confirming Value With Power',
        '5' => 'Stage 5 - Negotiating $$ & Mutual Plan',
        '6' => 'Stage 6 - Finalizing Closure',
        '7' => 'Stage 7 - Pending'
    };
    
    /**
     * Normalizes stage names from human-friendly format to full stage names
     * @param input The stage input (e.g., "stage 2", "2", "stage2")
     * @return The normalized stage name or original input if not found
     */
    public static String normalizeStage(String input) {
        if (String.isBlank(input)) {
            return input;
        }
        
        String normalizedInput = input.toLowerCase().trim();
        return STAGE_MAP.containsKey(normalizedInput) ? STAGE_MAP.get(normalizedInput) : input;
    }
}
