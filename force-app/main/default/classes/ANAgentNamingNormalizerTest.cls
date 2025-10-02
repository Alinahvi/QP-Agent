@isTest
public class ANAgentNamingNormalizerTest {
    
    @isTest
    static void testNormalizeOUName() {
        // Test various OU name variations
        Test.startTest();
        
        // Test exact matches
        System.assertEquals('AMER ACC', ANAgentNamingNormalizer.normalizeOUName('Amer-ACC'));
        System.assertEquals('EMEA-ACC', ANAgentNamingNormalizer.normalizeOUName('EMEA-ACC'));
        
        // Test variations
        System.assertEquals('AMER ACC', ANAgentNamingNormalizer.normalizeOUName('Amer ACC'));
        System.assertEquals('AMER ACC', ANAgentNamingNormalizer.normalizeOUName('AmerACC'));
        System.assertEquals('AMER ACC', ANAgentNamingNormalizer.normalizeOUName('amer-acc'));
        System.assertEquals('AMER ACC', ANAgentNamingNormalizer.normalizeOUName('AMER-ACC'));
        
        // Test unknown values
        System.assertEquals('Unknown-OU', ANAgentNamingNormalizer.normalizeOUName('Unknown-OU'));
        System.assertEquals('NonExistent', ANAgentNamingNormalizer.normalizeOUName('NonExistent'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testNormalizeProductName() {
        Test.startTest();
        
        // Test exact matches
        System.assertEquals('Tableau Server', ANAgentNamingNormalizer.normalizeProductName('Tableau Server'));
        System.assertEquals('Sales Cloud', ANAgentNamingNormalizer.normalizeProductName('Sales Cloud'));
        
        // Test context-aware resolution
        System.assertEquals('Tableau Server', ANAgentNamingNormalizer.normalizeProductName('Tableau'));
        System.assertEquals('Agentforce Conversations', ANAgentNamingNormalizer.normalizeProductName('Agentforce'));
        
        // Test variations
        System.assertEquals('Sales Cloud', ANAgentNamingNormalizer.normalizeProductName('sales cloud'));
        System.assertEquals('Marketing Cloud - Advanced', ANAgentNamingNormalizer.normalizeProductName('MARKETING CLOUD'));
        
        // Test unknown values
        System.assertEquals('Unknown-Product', ANAgentNamingNormalizer.normalizeProductName('Unknown-Product'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testNormalizeMacroSegment() {
        Test.startTest();
        
        // Test exact matches
        System.assertEquals('ENTR', ANAgentNamingNormalizer.normalizeMacroSegment('Enterprise'));
        System.assertEquals('Mid-Market', ANAgentNamingNormalizer.normalizeMacroSegment('Mid-Market'));
        
        // Test variations
        System.assertEquals('ENTR', ANAgentNamingNormalizer.normalizeMacroSegment('ENTR'));
        System.assertEquals('ENTR', ANAgentNamingNormalizer.normalizeMacroSegment('enterprise'));
        System.assertEquals('ENTR', ANAgentNamingNormalizer.normalizeMacroSegment('ENT'));
        
        // Test unknown values
        System.assertEquals('Unknown-Segment', ANAgentNamingNormalizer.normalizeMacroSegment('Unknown-Segment'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testNormalizeCountry() {
        Test.startTest();
        
        // Test exact matches
        System.assertEquals('United States of America', ANAgentNamingNormalizer.normalizeCountry('United States'));
        System.assertEquals('United Kingdom', ANAgentNamingNormalizer.normalizeCountry('United Kingdom'));
        
        // Test variations
        System.assertEquals('United States of America', ANAgentNamingNormalizer.normalizeCountry('USA'));
        System.assertEquals('United States of America', ANAgentNamingNormalizer.normalizeCountry('US'));
        System.assertEquals('United States of America', ANAgentNamingNormalizer.normalizeCountry('united states'));
        System.assertEquals('United Kingdom', ANAgentNamingNormalizer.normalizeCountry('UK'));
        System.assertEquals('United Kingdom', ANAgentNamingNormalizer.normalizeCountry('United Kingdom'));
        
        // Test unknown values
        System.assertEquals('Unknown-Country', ANAgentNamingNormalizer.normalizeCountry('Unknown-Country'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testNormalizeSalesTerm() {
        Test.startTest();
        
        // Test exact matches
        System.assertEquals('Cross-sell', ANAgentNamingNormalizer.normalizeSalesTerm('Cross-sell'));
        System.assertEquals('Renewal', ANAgentNamingNormalizer.normalizeSalesTerm('Renewal'));
        
        // Test variations
        System.assertEquals('Cross-sell', ANAgentNamingNormalizer.normalizeSalesTerm('off-sell'));
        System.assertEquals('Cross-sell', ANAgentNamingNormalizer.normalizeSalesTerm('cross-sell'));
        System.assertEquals('Renewal', ANAgentNamingNormalizer.normalizeSalesTerm('renewal'));
        System.assertEquals('Performance Scorecard', ANAgentNamingNormalizer.normalizeSalesTerm('scorecard'));
        
        // Test unknown values
        System.assertEquals('Unknown-Term', ANAgentNamingNormalizer.normalizeSalesTerm('Unknown-Term'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testComprehensiveNormalize() {
        Test.startTest();
        
        // Test OU normalization
        System.assertEquals('AMER ACC', ANAgentNamingNormalizer.normalize('Amer-ACC', 'OU'));
        System.assertEquals('EMEA Central', ANAgentNamingNormalizer.normalize('EMEA-Central', 'OU'));
        
        // Test Country normalization
        System.assertEquals('United States of America', ANAgentNamingNormalizer.normalize('USA', 'COUNTRY'));
        System.assertEquals('United Kingdom', ANAgentNamingNormalizer.normalize('UK', 'COUNTRY'));
        
        // Test Segment normalization
        System.assertEquals('ENTR', ANAgentNamingNormalizer.normalize('Enterprise', 'SEGMENT'));
        System.assertEquals('CMRCL', ANAgentNamingNormalizer.normalize('Commercial', 'SEGMENT'));
        
        // Test Product normalization
        System.assertEquals('Tableau Server', ANAgentNamingNormalizer.normalize('Tableau', 'PRODUCT'));
        System.assertEquals('Sales Cloud', ANAgentNamingNormalizer.normalize('Sales Cloud', 'PRODUCT'));
        
        // Test Sales term normalization
        System.assertEquals('Cross-sell', ANAgentNamingNormalizer.normalize('off-sell', 'SALES'));
        System.assertEquals('Renewal', ANAgentNamingNormalizer.normalize('renewal', 'SALES'));
        
        // Test unknown type
        System.assertEquals('Test Input', ANAgentNamingNormalizer.normalize('Test Input', 'UNKNOWN'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAvailableMethods() {
        Test.startTest();
        
        // Test getting available OUs
        Set<String> ous = ANAgentNamingNormalizer.getAvailableOUs();
        System.assert(ous.contains('AMER ACC'), 'Should contain AMER ACC');
        System.assert(ous.contains('EMEA Central'), 'Should contain EMEA Central');
        
        // Test getting available countries
        Set<String> countries = ANAgentNamingNormalizer.getAvailableCountries();
        System.assert(countries.contains('United States of America'), 'Should contain United States of America');
        System.assert(countries.contains('United Kingdom'), 'Should contain United Kingdom');
        
        // Test getting available segments
        Set<String> segments = ANAgentNamingNormalizer.getAvailableSegments();
        System.assert(segments.contains('ENTR'), 'Should contain ENTR');
        System.assert(segments.contains('CMRCL'), 'Should contain CMRCL');
        
        // Test getting available product families
        Set<String> products = ANAgentNamingNormalizer.getAvailableProductFamilies();
        System.assert(products.contains('Tableau Server'), 'Should contain Tableau Server');
        System.assert(products.contains('Sales Cloud'), 'Should contain Sales Cloud');
        
        Test.stopTest();
    }
}
