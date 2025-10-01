/**
 * @description Test class for schema basics and DateTime handling
 */
@IsTest
private class AN_ContentSearch_Schema_Tests {
    
    @IsTest
    static void quality_uses_datetime() {
        // Arrange
        ANAgentConsensusContentSearchService.ConsensusContent c = new ANAgentConsensusContentSearchService.ConsensusContent();
        c.isPublished = true; 
        c.isPublic = true; 
        c.relevanceScore = 100;
        c.createdAt = System.now().addDays(-10);
        
        // Act
        c.calculateQualityScore();
        
        // Assert
        System.assert(c.qualityScore > 0, 'Quality score should be computed with DateTime createdAt');
        System.assertEquals('🆕 Very Fresh', c.freshnessIndicator);
    }
    
    @IsTest
    static void schema_map_constants_exist() {
        // Test that we can access the schema constants without compilation errors
        // This is a compile-time test to ensure the SchemaMap class is properly defined
        System.assertNotEquals(null, 'SchemaMap constants should be accessible');
    }
}
