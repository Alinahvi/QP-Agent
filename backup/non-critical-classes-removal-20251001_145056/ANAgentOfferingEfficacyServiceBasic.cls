/**
 * @description Basic offering efficacy service for agent actions.
 * Provides core functionality for analyzing offering efficacy and performance metrics.
 * 
 * 🚨 CRITICAL INSTRUCTION FOR TOPIC CONFIGURATION:
 * 
 * ## PARAMETER MAPPING FOR GEOGRAPHIC FILTERING
 * 
 * When user says "within AMER", "in AMER", "AMER region", etc.:
 * 
 * INTERNAL MAPPING RULES:
 * - Geographic terms (AMER, EMEA, APAC) → operatingUnit parameter
 * - NEVER use region parameter for geographic filtering
 * - region parameter filters REGION__c field (mostly null = ineffective filtering)
 * - operatingUnit parameter filters OU_NAME__c field (contains actual OU values)
 * 
 * PARAMETER CONVERSION:
 * - "within AMER" → operatingUnit: "AMER"  // ✅ CORRECT - filters OU_NAME__c
 * - "within AMER" → region: "AMER"         // ❌ WRONG - filters REGION__c (mostly null)
 * 
 * EXAMPLES:
 * - User: "ACV programs within AMER" → operatingUnit: "AMER"
 * - User: "best programs in EMEA" → operatingUnit: "EMEA"  
 * - User: "top courses in APAC" → operatingUnit: "APAC"
 * 
 * @version 1.1
 */
public with sharing class ANAgentOfferingEfficacyServiceBasic {

    /**
     * @description Map region to OU for geographic filtering
     * Since OUs often contain region names (e.g., "AMER ICE", "AMER ESMB"), 
     * this method maps region requests to appropriate OU patterns
     */
    private static String mapRegionToOU(String region) {
        if (String.isBlank(region)) return null;
        
        String normalizedRegion = region.toUpperCase().trim();
        
        // Map region to OU patterns
        if (normalizedRegion == 'AMER') {
            return 'AMER'; // This will trigger the AMER OU logic in getEfficacyForPrograms
        } else if (normalizedRegion == 'EMEA') {
            return 'EMEA'; // This will trigger the EMEA OU logic in getEfficacyForPrograms
        } else if (normalizedRegion == 'APAC') {
            return 'APAC'; // This will trigger the APAC OU logic in getEfficacyForPrograms
        }
        
        // For other regions, return as-is (exact match)
        return region;
    }

    /**
     * @description Efficacy record wrapper
     */
    public class EfficacyRecord {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String offeringLabel { get; set; }
        @AuraEnabled public String programType { get; set; }
        @AuraEnabled public String region { get; set; }
        @AuraEnabled public String macroSegment { get; set; }
        @AuraEnabled public String fiscalQuarter { get; set; }
        @AuraEnabled public String kpiName { get; set; }
        @AuraEnabled public String product { get; set; }
        @AuraEnabled public String offeringEnablementCategory { get; set; }
        @AuraEnabled public String significanceIndicator { get; set; }
        @AuraEnabled public String ouName { get; set; }
        @AuraEnabled public String offeringProgramType { get; set; }
        @AuraEnabled public Decimal meanEffectiveness { get; set; }
        @AuraEnabled public Decimal meanTreatment { get; set; }
        @AuraEnabled public Decimal meanControl { get; set; }
        @AuraEnabled public Decimal calculatedLift { get; set; }
        @AuraEnabled public Decimal avgInfluencedAcvPerHead { get; set; }
        @AuraEnabled public Decimal totalInfluencedAcv { get; set; }
        @AuraEnabled public Decimal distinctLearners { get; set; }
        @AuraEnabled public String effectivenessDisplay { get; set; }
        @AuraEnabled public String liftDisplay { get; set; }
        @AuraEnabled public String acvDisplay { get; set; }
        
        public EfficacyRecord() {
            // Initialize with default values
        }
        
        public EfficacyRecord(apm_outcome_v2__c record) {
            this();
            this.id = record.Id;
            this.offeringLabel = record.OFFERING_LABEL__c;
            this.programType = record.PROGRAM_TYPE__c;
            this.region = record.REGION__c;  // Note: REGION__c is mostly null, OU_NAME__c contains actual geographic info
            this.macroSegment = record.MACRO_SEGMENT__c;
            this.fiscalQuarter = record.FISCAL_QUARTER__c;
            this.kpiName = record.KPI_NM__c;
            this.product = record.PRODUCT__c;
            this.offeringEnablementCategory = record.OFFERING_ENABLEMENT_CATEGORY__c;
            this.significanceIndicator = record.SIGNIFICANCE_INDICATOR__c;
            this.ouName = record.OU_NAME__c;  // This field contains actual OU values like "AMER ICE", "EMEA", "APAC"
            this.offeringProgramType = record.OFFERING_PROGRAM_TYPE__c;
            this.meanEffectiveness = record.MEAN_EFFECTIVENESS__c;
            this.meanTreatment = record.MEAN_TREATMENT__c;
            this.meanControl = record.MEAN_CONTROL__c;
            this.calculatedLift = record.CALCULATED_LIFT__c;
            this.avgInfluencedAcvPerHead = record.AVG_INFLUENCED_ACV_PER_HEAD__c;
            this.totalInfluencedAcv = record.TOTAL_INFLUENCED_ACV__c;
            this.distinctLearners = record.DISTINCT_LEARNERS__c;
            
            // Format displays
            this.effectivenessDisplay = formatPercentage(this.meanEffectiveness);
            this.liftDisplay = formatPercentage(this.calculatedLift);
            this.acvDisplay = formatCurrency(this.totalInfluencedAcv);
        }
        
        /**
         * @description Clone this efficacy record
         */
        public EfficacyRecord cloneRecord() {
            EfficacyRecord cloned = new EfficacyRecord();
            cloned.id = this.id;
            cloned.offeringLabel = this.offeringLabel;
            cloned.programType = this.programType;
            cloned.region = this.region;
            cloned.macroSegment = this.macroSegment;
            cloned.fiscalQuarter = this.fiscalQuarter;
            cloned.kpiName = this.kpiName;
            cloned.product = this.product;
            cloned.offeringEnablementCategory = this.offeringEnablementCategory;
            cloned.significanceIndicator = this.significanceIndicator;
            cloned.ouName = this.ouName;
            cloned.offeringProgramType = this.offeringProgramType;
            cloned.meanEffectiveness = this.meanEffectiveness;
            cloned.meanTreatment = this.meanTreatment;
            cloned.meanControl = this.meanControl;
            cloned.calculatedLift = this.calculatedLift;
            cloned.avgInfluencedAcvPerHead = this.avgInfluencedAcvPerHead;
            cloned.totalInfluencedAcv = this.totalInfluencedAcv;
            cloned.distinctLearners = this.distinctLearners;
            cloned.effectivenessDisplay = this.effectivenessDisplay;
            cloned.liftDisplay = this.liftDisplay;
            cloned.acvDisplay = this.acvDisplay;
            return cloned;
        }
    }

    /**
     * @description Search result wrapper
     */
    public class EfficacySearchResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<EfficacyRecord> efficacyRecords { get; set; }
        @AuraEnabled public Integer totalRecordCount { get; set; }
        @AuraEnabled public List<EfficacyRecord> topPerformers { get; set; }
        @AuraEnabled public String summaryMetrics { get; set; }
        @AuraEnabled public String batchJobId { get; set; }
        @AuraEnabled public Boolean needsFallback { get; set; }
        @AuraEnabled public String fallbackSearchTerm { get; set; }

        public EfficacySearchResult() {
            this.success = false;
            this.message = '';
            this.efficacyRecords = new List<EfficacyRecord>();
            this.totalRecordCount = 0;
            this.topPerformers = new List<EfficacyRecord>();
            this.summaryMetrics = '';
            this.batchJobId = '';
            this.needsFallback = false;
            this.fallbackSearchTerm = '';
        }
    }

    /**
     * @description Light, focused search functionality with clarifying questions approach
     */
    public static EfficacySearchResult searchEfficacyData(
        String offeringLabel, String programType, String region, String macroSegment,
        String fiscalQuarter, String kpiName, String product, Integer maxResults) {
        
        EfficacySearchResult result = new EfficacySearchResult();
        
        try {
            // Check if user is asking about "ineffective" courses (0 influenced ACV)
            if (String.isNotBlank(offeringLabel) && 
                (offeringLabel.toLowerCase().contains('ineffective') || offeringLabel.toLowerCase().contains('not effective')) &&
                String.isNotBlank(kpiName)) {
                
                // User wants "ineffective" courses with specific KPI - find courses with 0 influenced ACV
                result = findIneffectiveCourses(kpiName, region, macroSegment, fiscalQuarter, product, maxResults);
                return result;
            }
            
            // Check if user is asking about "effectiveness" without specifying KPI
            if (String.isNotBlank(offeringLabel) && 
                (offeringLabel.toLowerCase().contains('effective') || offeringLabel.toLowerCase().contains('effectiveness')) &&
                String.isBlank(kpiName)) {
                
                // User wants "effective" courses but didn't specify KPI
                result.success = false;
                result.message = 'I see you\'re asking about "effective" courses! I\'ll show you the best programs based on lift and ACV impact. ' +
                               'Here are the available KPIs in our APM library:\n\n' +
                               '📊 Available KPIs:\n' +
                               '• PIPE_QUALITY - Pipeline quality improvement\n' +
                               '• PIPE_CONVERSION - Pipeline conversion rates\n' +
                               '• PIPE_CREATECLOSE - Pipeline creation and closure\n' +
                               '• ACV - Annual Contract Value impact\n' +
                               '• PG - Pipeline generation\n' +
                               '• ACTIVITY_MEETINGS - Meeting activity impact\n' +
                               '• ACTIVITY_CALL_CONNECT - Call connection impact\n' +
                               '• PARTICIPATION_PG - Participation in pipeline generation\n' +
                               '• PARTICIPATION_ACV - Participation in ACV activities\n\n' +
                               '💡 Please ask me again with a specific KPI, for example:\n' +
                               '• "Show me top 5 PIPE_QUALITY courses on Data Cloud"\n' +
                               '• "What are the most effective ACV courses for Data Cloud?"\n' +
                               '• "Show me Data Cloud courses with highest PIPE_CONVERSION lift"\n\n' +
                               '🔍 Or ask for ineffective courses:\n' +
                               '• "Show me ineffective ACV courses" (courses with 0 influenced ACV)\n' +
                               '• "Find courses with no ACV impact"';
                
                return result;
            }
            
            // Check if user is asking about programs vs courses
            Boolean isProgramQuery = String.isNotBlank(offeringLabel) && 
                                   (offeringLabel.toLowerCase().contains('program') || 
                                    offeringLabel.toLowerCase().contains('programs'));
            
            // Build focused query - only exact matches with proper KPI filtering
            String soql = buildBasicQuery(offeringLabel, programType, region, macroSegment, 
                                        fiscalQuarter, kpiName, product, maxResults);
            
            // Execute query
            List<apm_outcome_v2__c> records = Database.query(soql);
            
            // Convert to efficacy records
            List<EfficacyRecord> efficacyRecords = new List<EfficacyRecord>();
            for (apm_outcome_v2__c record : records) {
                efficacyRecords.add(new EfficacyRecord(record));
            }
            
            // Set results - return ONLY exact matches (no broadening)
            result.success = true;
            result.totalRecordCount = efficacyRecords.size();
            
            if (efficacyRecords.isEmpty()) {
                // No APM data found - check if ANY related courses exist (regardless of KPI)
                String broaderSoql = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                                    'WHERE IsDeleted = false AND OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(offeringLabel) + '%\'';
                
                // If user specified a KPI, include it in the broader search
                if (String.isNotBlank(kpiName)) {
                    broaderSoql += ' AND KPI_NM__c = \'' + String.escapeSingleQuotes(kpiName) + '\'';
                }
                
                Integer totalRelatedCourses = Database.countQuery(broaderSoql);
                
                if (totalRelatedCourses > 0) {
                    // Related courses exist but no data for current filters - suggest KPI options
                    result.message = 'I found ' + totalRelatedCourses + ' related ' + 
                                   (isProgramQuery ? 'programs' : 'courses') + ' for "' + offeringLabel + '" in our APM library, ' +
                                   'but no data matches your current criteria. Here are your options:\n\n' +
                                   '🔍 Option 1: Search for related ' + (isProgramQuery ? 'programs' : 'courses') + '\n' +
                                   'Ask me: "Search for ' + offeringLabel + ' ' + (isProgramQuery ? 'programs' : 'courses') + '" to find available learning content\n\n' +
                                   '📊 Option 2: Try different KPIs\n' +
                                   'Since related ' + (isProgramQuery ? 'programs' : 'courses') + ' exist, you can ask about specific KPIs:\n' +
                                   '• "Show me ' + offeringLabel + ' ' + (isProgramQuery ? 'programs' : 'courses') + ' by PIPE_QUALITY"\n' +
                                   '• "What are the ACV results for ' + offeringLabel + '?"\n' +
                                   '• "Show me ' + offeringLabel + ' ' + (isProgramQuery ? 'programs' : 'courses') + ' with highest PIPE_CONVERSION lift"\n\n' +
                                   '🎯 Option 3: Nominate for APM measurement\n' +
                                   'If you find a relevant ' + (isProgramQuery ? 'program' : 'course') + ', you can nominate it for APM measurement';
                    
                } else {
                    // No related courses exist at all - don't suggest KPIs
                    result.message = 'I couldn\'t find any APM efficacy data for "' + offeringLabel + '". ' +
                                   'Here are your options:\n\n' +
                                   '🔍 Option 1: Search for related ' + (isProgramQuery ? 'programs' : 'courses') + '\n' +
                                   'Ask me: "Search for ' + offeringLabel + ' ' + (isProgramQuery ? 'programs' : 'courses') + '" to find available learning content\n\n' +
                                   '📊 Option 2: Nominate for APM measurement\n' +
                                   'If you find a relevant ' + (isProgramQuery ? 'program' : 'course') + ', you can nominate it for APM measurement to track its impact\n\n' +
                                   '💡 Note: Since no related ' + (isProgramQuery ? 'programs' : 'courses') + ' exist in our APM library, ' +
                                   'trying different KPIs won\'t help. Focus on finding relevant ' + (isProgramQuery ? 'programs' : 'courses') + ' first.';
                }
                
                // Set fallback flag for the handler to use
                result.needsFallback = true;
                result.fallbackSearchTerm = offeringLabel;
                
            } else {
                // Get aggregated, unique offerings (no KPI duplicates)
                List<EfficacyRecord> aggregatedOfferings = getTopPerformers(efficacyRecords);
                result.efficacyRecords = aggregatedOfferings;
                
                Integer uniqueOfferings = aggregatedOfferings.size();
                result.message = 'Found ' + result.totalRecordCount + ' records (' + uniqueOfferings + ' unique offerings) for "' + offeringLabel + '".';
                
                // Generate insights using aggregated offerings
                result.topPerformers = aggregatedOfferings;
                result.summaryMetrics = generateFocusedSummary(efficacyRecords, offeringLabel);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error searching efficacy data: ' + e.getMessage();
            System.debug('Error in searchEfficacyData: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Find ineffective courses (courses with 0 influenced ACV) for a specific KPI
     * This method handles the case where users want to find "ineffective courses" without specifying a course name
     */
    public static EfficacySearchResult findIneffectiveCourses(String kpiName, String region, String macroSegment, 
                                                            String fiscalQuarter, String product, Integer maxResults) {
        EfficacySearchResult result = new EfficacySearchResult();
        
        try {
            // Build query to find courses with 0 influenced ACV
            String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                          'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                          'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                          'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                          'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c, ' +
                          'CreatedDate ' +
                          'FROM apm_outcome_v2__c ' +
                          'WHERE IsDeleted = false';
            
            // Add KPI filtering
            if (String.isNotBlank(kpiName)) {
                soql += ' AND KPI_NM__c = \'' + String.escapeSingleQuotes(kpiName) + '\'';
            }
            
            // Add region filtering (map to OU for geographic filtering)
            if (String.isNotBlank(region)) {
                String mappedOU = mapRegionToOU(region);
                if (mappedOU != null) {
                    if (mappedOU == 'AMER') {
                        soql += ' AND (OU_NAME__c LIKE \'%AMER%\' OR OU_NAME__c LIKE \'%CAN%\' OR OU_NAME__c LIKE \'%LATAM%\' OR OU_NAME__c = \'AMER FINS, HLS, CAN\')';
                    } else if (mappedOU == 'EMEA') {
                        soql += ' AND (OU_NAME__c LIKE \'%EMEA%\' OR OU_NAME__c LIKE \'%UKI%\')';
                    } else if (mappedOU == 'APAC') {
                        soql += ' AND (OU_NAME__c LIKE \'%APAC%\' OR OU_NAME__c LIKE \'%ASEAN%\' OR OU_NAME__c LIKE \'%ANZ%\')';
                    } else {
                        soql += ' AND OU_NAME__c = \'' + String.escapeSingleQuotes(mappedOU) + '\'';
                    }
                } else {
                    soql += ' AND REGION__c = \'' + String.escapeSingleQuotes(region) + '\'';
                }
            }
            
            // Add macro segment filtering
            if (String.isNotBlank(macroSegment) && macroSegment != 'ALL') {
                soql += ' AND MACRO_SEGMENT__c = \'' + String.escapeSingleQuotes(macroSegment) + '\'';
            }
            
            // Add fiscal quarter filtering
            if (String.isNotBlank(fiscalQuarter)) {
                soql += ' AND FISCAL_QUARTER__c = \'' + String.escapeSingleQuotes(fiscalQuarter) + '\'';
            }
            
            // Add product filtering
            if (String.isNotBlank(product)) {
                soql += ' AND PRODUCT__c = \'' + String.escapeSingleQuotes(product) + '\'';
            }
            
            // Add filter for courses with 0 influenced ACV
            soql += ' AND (TOTAL_INFLUENCED_ACV__c = 0 OR TOTAL_INFLUENCED_ACV__c = null)';
            
            // Order by offering label for better readability
            soql += ' ORDER BY OFFERING_LABEL__c ASC';
            
            // Limit results
            if (maxResults != null && maxResults > 0) {
                soql += ' LIMIT ' + maxResults;
            } else {
                soql += ' LIMIT 100'; // Default limit for ineffective courses
            }
            
            System.debug('🔍 Ineffective Courses SOQL: ' + soql);
            
            // Execute query
            List<apm_outcome_v2__c> records = Database.query(soql);
            
            // Convert to efficacy records
            List<EfficacyRecord> efficacyRecords = new List<EfficacyRecord>();
            for (apm_outcome_v2__c record : records) {
                efficacyRecords.add(new EfficacyRecord(record));
            }
            
            // Set results
            result.success = true;
            result.totalRecordCount = efficacyRecords.size();
            
            if (efficacyRecords.isEmpty()) {
                result.message = 'No courses found with 0 influenced ACV for the specified criteria. ' +
                               'This could mean:\n' +
                               '• All courses in this category have some ACV impact\n' +
                               '• The courses haven\'t been measured yet\n' +
                               '• Try broadening your search criteria';
                result.needsFallback = true;
                result.fallbackSearchTerm = 'ineffective courses';
            } else {
                // Get aggregated, unique offerings (no KPI duplicates)
                List<EfficacyRecord> aggregatedOfferings = getTopPerformers(efficacyRecords);
                result.efficacyRecords = aggregatedOfferings;
                
                Integer uniqueOfferings = aggregatedOfferings.size();
                result.message = 'Found ' + result.totalRecordCount + ' records (' + uniqueOfferings + ' unique offerings) with 0 influenced ACV for ' + kpiName + '.';
                result.topPerformers = aggregatedOfferings;
                result.summaryMetrics = generateIneffectiveCoursesSummary(efficacyRecords, kpiName);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error finding ineffective courses: ' + e.getMessage();
            System.debug('Error in findIneffectiveCourses: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Find ineffective courses created over the past N months
     * This method specifically handles the "past 9 months" requirement
     */
    public static EfficacySearchResult findIneffectiveCoursesByDate(String kpiName, String region, String macroSegment, 
                                                                  String fiscalQuarter, String product, Integer monthsBack, Integer maxResults) {
        EfficacySearchResult result = new EfficacySearchResult();
        
        try {
            // Calculate the date threshold (e.g., 9 months ago)
            Integer monthsToSubtract = monthsBack != null ? monthsBack : 9; // Default to 9 months
            Date thresholdDate = Date.today().addMonths(-monthsToSubtract);
            
            // Build query to find courses with 0 influenced ACV created within the date range
            String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                          'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                          'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                          'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                          'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c, ' +
                          'CreatedDate ' +
                          'FROM apm_outcome_v2__c ' +
                          'WHERE IsDeleted = false';
            
            // Add KPI filtering
            if (String.isNotBlank(kpiName)) {
                soql += ' AND KPI_NM__c = \'' + String.escapeSingleQuotes(kpiName) + '\'';
            }
            
            // Add region filtering (map to OU for geographic filtering)
            if (String.isNotBlank(region)) {
                String mappedOU = mapRegionToOU(region);
                if (mappedOU != null) {
                    if (mappedOU == 'AMER') {
                        soql += ' AND (OU_NAME__c LIKE \'%AMER%\' OR OU_NAME__c LIKE \'%CAN%\' OR OU_NAME__c LIKE \'%LATAM%\' OR OU_NAME__c = \'AMER FINS, HLS, CAN\')';
                    } else if (mappedOU == 'EMEA') {
                        soql += ' AND (OU_NAME__c LIKE \'%EMEA%\' OR OU_NAME__c LIKE \'%UKI%\')';
                    } else if (mappedOU == 'APAC') {
                        soql += ' AND (OU_NAME__c LIKE \'%APAC%\' OR OU_NAME__c LIKE \'%ASEAN%\' OR OU_NAME__c LIKE \'%ANZ%\')';
                    } else {
                        soql += ' AND OU_NAME__c = \'' + String.escapeSingleQuotes(mappedOU) + '\'';
                    }
                } else {
                    soql += ' AND REGION__c = \'' + String.escapeSingleQuotes(region) + '\'';
                }
            }
            
            // Add macro segment filtering
            if (String.isNotBlank(macroSegment) && macroSegment != 'ALL') {
                soql += ' AND MACRO_SEGMENT__c = \'' + String.escapeSingleQuotes(macroSegment) + '\'';
            }
            
            // Add fiscal quarter filtering
            if (String.isNotBlank(fiscalQuarter)) {
                soql += ' AND FISCAL_QUARTER__c = \'' + String.escapeSingleQuotes(fiscalQuarter) + '\'';
            }
            
            // Add product filtering
            if (String.isNotBlank(product)) {
                soql += ' AND PRODUCT__c = \'' + String.escapeSingleQuotes(product) + '\'';
            }
            
            // Add filter for courses with 0 influenced ACV
            soql += ' AND (TOTAL_INFLUENCED_ACV__c = 0 OR TOTAL_INFLUENCED_ACV__c = null)';
            
            // Add date filtering for courses created within the specified months
            soql += ' AND CreatedDate >= :thresholdDate';
            
            // Order by creation date (newest first) then by offering label
            soql += ' ORDER BY CreatedDate DESC, OFFERING_LABEL__c ASC';
            
            // Limit results
            if (maxResults != null && maxResults > 0) {
                soql += ' LIMIT ' + maxResults;
            } else {
                soql += ' LIMIT 100'; // Default limit for ineffective courses
            }
            
            System.debug('🔍 Ineffective Courses by Date SOQL: ' + soql);
            System.debug('🔍 Date threshold: ' + thresholdDate + ' (past ' + monthsToSubtract + ' months)');
            
            // Execute query
            List<apm_outcome_v2__c> records = Database.query(soql);
            
            // Convert to efficacy records
            List<EfficacyRecord> efficacyRecords = new List<EfficacyRecord>();
            for (apm_outcome_v2__c record : records) {
                efficacyRecords.add(new EfficacyRecord(record));
            }
            
            // Set results
            result.success = true;
            result.totalRecordCount = efficacyRecords.size();
            
            if (efficacyRecords.isEmpty()) {
                result.message = 'No courses found with 0 influenced ACV created in the past ' + monthsToSubtract + ' months for the specified criteria. ' +
                               'This could mean:\n' +
                               '• All recently created courses have some ACV impact\n' +
                               '• The courses haven\'t been measured yet\n' +
                               '• Try broadening your search criteria or increasing the time range';
                result.needsFallback = true;
                result.fallbackSearchTerm = 'ineffective courses past ' + monthsToSubtract + ' months';
            } else {
                // Get aggregated, unique offerings (no KPI duplicates)
                List<EfficacyRecord> aggregatedOfferings = getTopPerformers(efficacyRecords);
                result.efficacyRecords = aggregatedOfferings;
                
                Integer uniqueOfferings = aggregatedOfferings.size();
                result.message = 'Found ' + result.totalRecordCount + ' records (' + uniqueOfferings + ' unique offerings) with 0 influenced ACV for ' + kpiName + 
                               ' created in the past ' + monthsToSubtract + ' months.';
                result.topPerformers = aggregatedOfferings;
                result.summaryMetrics = generateIneffectiveCoursesByDateSummary(efficacyRecords, kpiName, monthsToSubtract);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error finding ineffective courses by date: ' + e.getMessage();
            System.debug('Error in findIneffectiveCoursesByDate: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Generate summary for ineffective courses (courses with 0 influenced ACV)
     */
    private static String generateIneffectiveCoursesSummary(List<EfficacyRecord> records, String kpiName) {
        if (records == null || records.isEmpty()) {
            return 'No data available for summary.';
        }
        
        // Get top 5 different offerings (aggregated)
        List<EfficacyRecord> top5DifferentOfferings = getTopNDifferentOfferings(records, 5);
        
        // Build summary for ineffective courses
        String summary = 'Summary of ' + records.size() + ' records with 0 influenced ACV for ' + kpiName + ':\n\n';
        
        // Calculate aggregated metrics across all records
        Integer significantCount = 0;
        Integer recordsWithLift = 0;
        Decimal totalLift = 0;
        
        for (EfficacyRecord record : records) {
            if (record.calculatedLift != null) {
                totalLift += record.calculatedLift;
                recordsWithLift++;
            }
            if (record.significanceIndicator == 'SIGNIFICANT') {
                significantCount++;
            }
        }
        
        Integer recordCount = records.size();
        Decimal avgLift = recordsWithLift > 0 ? totalLift / recordsWithLift : 0;
        
        // Show metrics for ineffective courses
        summary += '• Average Lift: ' + formatPercentage(avgLift) + '\n';
        summary += '• Total Influenced ACV: $0 (all courses have 0 ACV impact)\n';
        summary += '• Significant Results: ' + significantCount + ' of ' + recordCount + ' (' + formatPercentage((Decimal)significantCount / recordCount * 100) + ')\n\n';
        
        // Add top 5 different offering names
        summary += 'Courses with 0 Influenced ACV:\n';
        for (Integer i = 0; i < top5DifferentOfferings.size(); i++) {
            EfficacyRecord record = top5DifferentOfferings[i];
            String offeringName = String.isNotBlank(record.offeringLabel) ? record.offeringLabel : 'Unnamed Offering';
            String lift = record.calculatedLift != null ? formatPercentage(record.calculatedLift) : 'N/A';
            String acv = record.totalInfluencedAcv != null ? formatCurrency(record.totalInfluencedAcv) : '$0';
            
            summary += (i + 1) + '. ' + offeringName + '\n';
            summary += '   Lift: ' + lift + ', Total ACV: ' + acv + '\n';
        }
        
        if (records.size() > 5) {
            summary += '... and ' + (records.size() - 5) + ' more courses\n';
        }
        
        // Add insights about ineffective courses
        summary += '\n📊 Understanding Ineffective Courses:\n';
        summary += '• These courses have 0 influenced ACV, meaning no measurable revenue impact\n';
        summary += '• They may still have other benefits (pipeline quality, conversion rates)\n';
        summary += '• Consider reviewing content, delivery method, or target audience\n\n';
        
        // Add suggestions for improvement
        summary += '💡 Suggestions for Improvement:\n';
        summary += '• Review course content and relevance to current business needs\n';
        summary += '• Check if the course is reaching the right audience\n';
        summary += '• Consider updating content based on latest industry trends\n';
        summary += '• Evaluate if the course timing aligns with business cycles\n\n';
        
        // Add guidance for finding effective alternatives
        summary += '🔍 Want to Find Effective Alternatives?\n';
        summary += 'Ask me:\n';
        summary += '• "Show me effective ' + kpiName + ' courses" (courses with positive ACV impact)\n';
        summary += '• "What are the best performing ' + kpiName + ' courses?"\n';
        summary += '• "Show me top ' + kpiName + ' courses by lift"';
        
        return summary;
    }
    
    /**
     * @description Generate summary for ineffective courses created over the past N months
     */
    private static String generateIneffectiveCoursesByDateSummary(List<EfficacyRecord> records, String kpiName, Integer monthsBack) {
        if (records == null || records.isEmpty()) {
            return 'No data available for summary.';
        }
        
        // Get top 5 different offerings (aggregated)
        List<EfficacyRecord> top5DifferentOfferings = getTopNDifferentOfferings(records, 5);
        
        // Build summary for ineffective courses
        String summary = 'Summary of ' + records.size() + ' records with 0 influenced ACV for ' + kpiName + ' created in the past ' + monthsBack + ' months:\n\n';
        
        // Calculate aggregated metrics across all records
        Integer significantCount = 0;
        Integer recordsWithLift = 0;
        Decimal totalLift = 0;
        
        for (EfficacyRecord record : records) {
            if (record.calculatedLift != null) {
                totalLift += record.calculatedLift;
                recordsWithLift++;
            }
            if (record.significanceIndicator == 'SIGNIFICANT') {
                significantCount++;
            }
        }
        
        Integer recordCount = records.size();
        Decimal avgLift = recordsWithLift > 0 ? totalLift / recordsWithLift : 0;
        
        // Show metrics for ineffective courses
        summary += '• Average Lift: ' + formatPercentage(avgLift) + '\n';
        summary += '• Total Influenced ACV: $0 (all courses have 0 ACV impact)\n';
        summary += '• Significant Results: ' + significantCount + ' of ' + recordCount + ' (' + formatPercentage((Decimal)significantCount / recordCount * 100) + ')\n\n';
        
        // Add top 5 different offering names
        summary += 'Courses with 0 Influenced ACV:\n';
        for (Integer i = 0; i < top5DifferentOfferings.size(); i++) {
            EfficacyRecord record = top5DifferentOfferings[i];
            String offeringName = String.isNotBlank(record.offeringLabel) ? record.offeringLabel : 'Unnamed Offering';
            String lift = record.calculatedLift != null ? formatPercentage(record.calculatedLift) : 'N/A';
            String acv = record.totalInfluencedAcv != null ? formatCurrency(record.totalInfluencedAcv) : '$0';
            
            summary += (i + 1) + '. ' + offeringName + '\n';
            summary += '   Lift: ' + lift + ', Total ACV: ' + acv + '\n';
        }
        
        if (records.size() > 5) {
            summary += '... and ' + (records.size() - 5) + ' more courses\n';
        }
        
        // Add insights about ineffective courses
        summary += '\n📊 Understanding Ineffective Courses:\n';
        summary += '• These courses have 0 influenced ACV, meaning no measurable revenue impact\n';
        summary += '• They may still have other benefits (pipeline quality, conversion rates)\n';
        summary += '• Consider reviewing content, delivery method, or target audience\n\n';
        
        // Add suggestions for improvement
        summary += '💡 Suggestions for Improvement:\n';
        summary += '• Review course content and relevance to current business needs\n';
        summary += '• Check if the course is reaching the right audience\n';
        summary += '• Consider updating content based on latest industry trends\n';
        summary += '• Evaluate if the course timing aligns with business cycles\n\n';
        
        // Add guidance for finding effective alternatives
        summary += '🔍 Want to Find Effective Alternatives?\n';
        summary += 'Ask me:\n';
        summary += '• "Show me effective ' + kpiName + ' courses" (courses with positive ACV impact)\n';
        summary += '• "What are the best performing ' + kpiName + ' courses?"\n';
        summary += '• "Show me top ' + kpiName + ' courses by lift"';
        
        return summary;
    }
    
    /**
     * @description Get efficacy for programs by KPI and vertical/OU - handles program-specific queries
     */
    public static EfficacySearchResult getEfficacyForPrograms(String kpiName, String vertical, String ou) {
        EfficacySearchResult result = new EfficacySearchResult();
        
        try {
            // Build query for programs
            String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                          'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                          'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                          'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                          'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                          'FROM apm_outcome_v2__c ' +
                          'WHERE IsDeleted = false';
            
            // Add KPI filtering if specified
            if (String.isNotBlank(kpiName)) {
                soql += ' AND KPI_NM__c = \'' + String.escapeSingleQuotes(kpiName) + '\'';
            }
            
            // Add vertical filtering if specified
            if (String.isNotBlank(vertical)) {
                soql += ' AND MACRO_SEGMENT__c = \'' + String.escapeSingleQuotes(vertical) + '\'';
            }
            
            // Add OU filtering if specified - this is the key fix
            if (String.isNotBlank(ou)) {
                // Handle different OU patterns
                if (ou.equalsIgnoreCase('AMER')) {
                    // AMER should include AMER, CAN, LATAM, etc.
                    soql += ' AND (OU_NAME__c LIKE \'%AMER%\' OR OU_NAME__c LIKE \'%CAN%\' OR OU_NAME__c LIKE \'%LATAM%\' OR OU_NAME__c = \'AMER FINS, HLS, CAN\')';
                } else if (ou.equalsIgnoreCase('EMEA')) {
                    // EMEA should include EMEA, UKI, etc.
                    soql += ' AND (OU_NAME__c LIKE \'%EMEA%\' OR OU_NAME__c LIKE \'%UKI%\')';
                } else if (ou.equalsIgnoreCase('APAC')) {
                    // APAC should include APAC, ASEAN, ANZ, etc.
                    soql += ' AND (OU_NAME__c LIKE \'%APAC%\' OR OU_NAME__c LIKE \'%ASEAN%\' OR OU_NAME__c LIKE \'%ANZ%\')';
                } else {
                    // Exact match for other OUs
                    soql += ' AND OU_NAME__c = \'' + String.escapeSingleQuotes(ou) + '\'';
                }
            }
            
            // Focus on programs
            soql += ' AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null)';
            
            // Order by effectiveness and ACV
            soql += ' ORDER BY MEAN_EFFECTIVENESS__c DESC NULLS LAST, TOTAL_INFLUENCED_ACV__c DESC NULLS LAST';
            
            // Limit results
            soql += ' LIMIT 50';
            
            System.debug('🔍 Program Efficacy SOQL: ' + soql);
            
            // Execute query
            List<apm_outcome_v2__c> records = Database.query(soql);
            
            // Convert to efficacy records
            List<EfficacyRecord> efficacyRecords = new List<EfficacyRecord>();
            for (apm_outcome_v2__c record : records) {
                efficacyRecords.add(new EfficacyRecord(record));
            }
            
            // Set results
            result.success = true;
            result.totalRecordCount = efficacyRecords.size();
            
            if (efficacyRecords.isEmpty()) {
                result.message = 'No APM efficacy data found for programs with the specified criteria. ' +
                               'Try broadening your search or using different KPI/vertical combinations.';
                result.needsFallback = true;
                result.fallbackSearchTerm = 'programs';
            } else {
                // Get aggregated, unique programs
                List<EfficacyRecord> aggregatedPrograms = getTopPerformers(efficacyRecords);
                result.efficacyRecords = aggregatedPrograms;
                
                Integer uniquePrograms = aggregatedPrograms.size();
                result.message = 'Found ' + result.totalRecordCount + ' records (' + uniquePrograms + ' unique programs) with the specified criteria.';
                result.topPerformers = aggregatedPrograms;
                result.summaryMetrics = generateFocusedSummary(efficacyRecords, 'programs');
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error searching for program efficacy: ' + e.getMessage();
            System.debug('Error in getEfficacyForPrograms: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Get efficacy for a specific course - with clarifying questions approach
     */
    public static EfficacySearchResult getEfficacyForCourse(String courseName) {
        EfficacySearchResult result = new EfficacySearchResult();
        
        try {
            if (String.isBlank(courseName)) {
                result.success = false;
                result.message = 'Course name is required.';
                return result;
            }
            
            // Check if user is asking about "effectiveness" without specifying KPI
            if (courseName.toLowerCase().contains('effective') || courseName.toLowerCase().contains('effectiveness')) {
                // User wants "effective" courses but didn't specify KPI
                result.success = false;
                result.message = 'I see you\'re asking about "effective" courses, but I need to know which KPI you\'re referring to. ' +
                               'Here are the available KPIs in our APM library:\n\n' +
                               '📊 Available KPIs:\n' +
                               '• PIPE_QUALITY - Pipeline quality improvement\n' +
                               '• PIPE_CONVERSION - Pipeline conversion rates\n' +
                               '• PIPE_CREATECLOSE - Pipeline creation and closure\n' +
                               '• ACV - Annual Contract Value impact\n' +
                               '• PG - Pipeline generation\n' +
                               '• ACTIVITY_MEETINGS - Meeting activity impact\n' +
                               '• ACTIVITY_CALL_CONNECT - Call connection impact\n' +
                               '• PARTICIPATION_PG - Participation in pipeline generation\n' +
                               '• PARTICIPATION_ACV - Participation in ACV activities\n\n' +
                               '💡 Please ask me again with a specific KPI, for example:\n' +
                               '• "Show me Data Cloud courses by PIPE_QUALITY"\n' +
                               '• "What are the ACV results for Data Cloud?"\n' +
                               '• "Show me Data Cloud courses with highest PIPE_CONVERSION lift"';
                
                return result;
            }
            
            // Focused search - only exact matches
            List<apm_outcome_v2__c> records = searchForCourseFocused(courseName);
            
            // Convert to efficacy records
            List<EfficacyRecord> efficacyRecords = new List<EfficacyRecord>();
            for (apm_outcome_v2__c record : records) {
                efficacyRecords.add(new EfficacyRecord(record));
            }
            
            // Set results
            result.success = true;
            result.totalRecordCount = efficacyRecords.size();
            
            if (efficacyRecords.isEmpty()) {
                // No APM data found - check if ANY related courses exist (regardless of KPI)
                String broaderSoql = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                                    'WHERE IsDeleted = false AND OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(courseName) + '%\'';
                
                Integer totalRelatedCourses = Database.countQuery(broaderSoql);
                
                // Check if user is asking about programs vs courses
                Boolean isProgramQuery = String.isNotBlank(courseName) && 
                                       (courseName.toLowerCase().contains('program') || 
                                        courseName.toLowerCase().contains('programs'));
                
                if (totalRelatedCourses > 0) {
                    // Related courses exist but no data for current filters - suggest KPI options
                    result.message = 'I found ' + totalRelatedCourses + ' related ' + 
                                   (isProgramQuery ? 'programs' : 'courses') + ' for "' + courseName + '" in our APM library, ' +
                                   'but no data matches your current criteria. Here are your options:\n\n' +
                                   '🔍 Option 1: Search for related ' + (isProgramQuery ? 'programs' : 'courses') + '\n' +
                                   'Ask me: "Search for ' + courseName + ' ' + (isProgramQuery ? 'programs' : 'courses') + '" to find available learning content\n\n' +
                                   '📊 Option 2: Try different KPIs\n' +
                                   'Since related ' + (isProgramQuery ? 'programs' : 'courses') + ' exist, you can ask about specific KPIs:\n' +
                                   '• "Show me ' + courseName + ' ' + (isProgramQuery ? 'programs' : 'courses') + ' by PIPE_QUALITY"\n' +
                                   '• "What are the ACV results for ' + courseName + '?"\n' +
                                   '• "Show me ' + courseName + ' ' + (isProgramQuery ? 'programs' : 'courses') + ' with highest PIPE_CONVERSION lift"\n\n' +
                                   '🎯 Option 3: Nominate for APM measurement\n' +
                                   'If you find a relevant ' + (isProgramQuery ? 'program' : 'course') + ', you can nominate it for APM measurement';
                    
                } else {
                    // No related courses exist at all - don't suggest KPIs
                    result.message = 'I couldn\'t find any APM efficacy data for course: "' + courseName + '". ' +
                                   'Here are your options:\n\n' +
                                   '🔍 Option 1: Search for related ' + (isProgramQuery ? 'programs' : 'courses') + '\n' +
                                   'Ask me: "Search for ' + courseName + ' ' + (isProgramQuery ? 'programs' : 'courses') + '" to find available learning content\n\n' +
                                   '📊 Option 2: Nominate for APM measurement\n' +
                                   'If you find a relevant ' + (isProgramQuery ? 'program' : 'course') + ', you can nominate it for APM measurement to track its effectiveness\n\n' +
                                   '💡 Note: Since no related ' + (isProgramQuery ? 'programs' : 'courses') + ' exist in our APM library, ' +
                                   'trying different KPIs won\'t help. Focus on finding relevant ' + (isProgramQuery ? 'programs' : 'courses') + ' first.';
                }
                
                // Set fallback flag for the handler to use
                result.needsFallback = true;
                result.fallbackSearchTerm = courseName;
                
            } else {
                // Get aggregated, unique offerings (no KPI duplicates)
                List<EfficacyRecord> aggregatedOfferings = getTopPerformers(efficacyRecords);
                result.efficacyRecords = aggregatedOfferings;
                
                Integer uniqueOfferings = aggregatedOfferings.size();
                result.message = 'Found ' + result.totalRecordCount + ' records (' + uniqueOfferings + ' unique offerings) for course: "' + courseName + '".';
                result.topPerformers = aggregatedOfferings;
                result.summaryMetrics = generateFocusedSummary(efficacyRecords, courseName);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error getting efficacy for course: ' + e.getMessage();
            System.debug('Error getting efficacy for course: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Search for course with option for broader search
     */
    private static List<apm_outcome_v2__c> searchForCourse(String courseName, Boolean broaderSearch) {
        String searchTerm = broaderSearch ? 
            // Broader search: look for partial matches and related terms
            '(OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(courseName) + '%\' OR ' +
            'OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(courseName.split(' ')[0]) + '%\')' :
            // Exact search: look for exact course name
            'OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(courseName) + '%\'';
        
        String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                     'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                     'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                     'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                     'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                     'FROM apm_outcome_v2__c ' +
                     'WHERE IsDeleted = false AND ' + searchTerm + ' ' +
                     'ORDER BY TOTAL_INFLUENCED_ACV__c DESC ' +
                     'LIMIT ' + (broaderSearch ? '200' : '100');
        
        return Database.query(soql);
    }
    
    /**
     * @description Focused search for course - no broadening
     */
    private static List<apm_outcome_v2__c> searchForCourseFocused(String courseName) {
        // Only exact matches - no broadening
        String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                     'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                     'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                     'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                     'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                     'FROM apm_outcome_v2__c ' +
                     'WHERE IsDeleted = false AND OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(courseName) + '%\' ' +
                     'ORDER BY TOTAL_INFLUENCED_ACV__c DESC ' +
                     'LIMIT 50';
        
        return Database.query(soql);
    }
    
    /**
     * @description Count unique offerings in a list of records
     */
    private static Integer getUniqueOfferingsCount(List<apm_outcome_v2__c> records) {
        Set<String> uniqueOfferings = new Set<String>();
        for (apm_outcome_v2__c record : records) {
            if (record.OFFERING_LABEL__c != null) {
                uniqueOfferings.add(record.OFFERING_LABEL__c);
            }
        }
        return uniqueOfferings.size();
    }
    
    /**
     * @description Build basic SOQL query with proper KPI filtering
     */
    private static String buildBasicQuery(String offeringLabel, String programType, String region, 
                                        String macroSegment, String fiscalQuarter, String kpiName, 
                                        String product, Integer maxResults) {
        
        String soql = 'SELECT Id, OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MACRO_SEGMENT__c, ' +
                     'FISCAL_QUARTER__c, KPI_NM__c, PRODUCT__c, OFFERING_ENABLEMENT_CATEGORY__c, ' +
                     'SIGNIFICANCE_INDICATOR__c, OU_NAME__c, MEAN_EFFECTIVENESS__c, MEAN_TREATMENT__c, ' +
                     'MEAN_CONTROL__c, CALCULATED_LIFT__c, AVG_INFLUENCED_ACV_PER_HEAD__c, ' +
                     'TOTAL_INFLUENCED_ACV__c, DISTINCT_LEARNERS__c, OFFERING_PROGRAM_TYPE__c ' +
                     'FROM apm_outcome_v2__c ' +
                     'WHERE IsDeleted = false';
        
        // Add KPI filtering FIRST - this is critical for specific KPI requests
        if (String.isNotBlank(kpiName)) {
            soql += ' AND KPI_NM__c = \'' + String.escapeSingleQuotes(kpiName) + '\'';
        }
        
        // Add offering label filtering
        if (String.isNotBlank(offeringLabel)) {
            soql += ' AND OFFERING_LABEL__c LIKE \'%' + String.escapeSingleQuotes(offeringLabel) + '%\'';
        }
        
        // Add other filters
        if (String.isNotBlank(programType)) {
            soql += ' AND PROGRAM_TYPE__c = \'' + String.escapeSingleQuotes(programType) + '\'';
        }
        
        if (String.isNotBlank(region)) {
            // Map region to OU for geographic filtering since OUs contain region names
            String mappedOU = mapRegionToOU(region);
            if (mappedOU != null) {
                // Use OU filtering instead of region filtering for better results
                if (mappedOU == 'AMER') {
                    soql += ' AND (OU_NAME__c LIKE \'%AMER%\' OR OU_NAME__c LIKE \'%CAN%\' OR OU_NAME__c LIKE \'%LATAM%\' OR OU_NAME__c = \'AMER FINS, HLS, CAN\')';
                } else if (mappedOU == 'EMEA') {
                    soql += ' AND (OU_NAME__c LIKE \'%EMEA%\' OR OU_NAME__c LIKE \'%UKI%\')';
                } else if (mappedOU == 'APAC') {
                    soql += ' AND (OU_NAME__c LIKE \'%APAC%\' OR OU_NAME__c LIKE \'%ASEAN%\' OR OU_NAME__c LIKE \'%ANZ%\')';
                } else {
                    // For other regions, use exact OU match
                    soql += ' AND OU_NAME__c = \'' + String.escapeSingleQuotes(mappedOU) + '\'';
                }
            } else {
                // Fallback to original region filtering if mapping fails
                soql += ' AND REGION__c = \'' + String.escapeSingleQuotes(region) + '\'';
            }
        }
        
        if (String.isNotBlank(macroSegment)) {
            soql += ' AND MACRO_SEGMENT__c = \'' + String.escapeSingleQuotes(macroSegment) + '\'';
        }
        
        if (String.isNotBlank(fiscalQuarter)) {
            soql += ' AND FISCAL_QUARTER__c = \'' + String.escapeSingleQuotes(fiscalQuarter) + '\'';
        }
        
        if (String.isNotBlank(product)) {
            soql += ' AND PRODUCT__c = \'' + String.escapeSingleQuotes(product) + '\'';
        }
        
        // Order by ACV for better relevance
        soql += ' ORDER BY TOTAL_INFLUENCED_ACV__c DESC';
        
        // Limit results
        if (maxResults != null && maxResults > 0) {
            soql += ' LIMIT ' + maxResults;
        } else {
            soql += ' LIMIT 50'; // Default limit
        }
        
        return soql;
    }

    /**
     * @description Get top performers with KPI aggregation to avoid duplicates
     */
    public static List<EfficacyRecord> getTopPerformers(List<EfficacyRecord> records) {
        if (records == null || records.isEmpty()) {
            return new List<EfficacyRecord>();
        }
        
        // First, aggregate by offering label to avoid KPI duplicates
        Map<String, EfficacyRecord> aggregatedMap = aggregateOfferingsByLabel(records);
        
        // Convert back to list and sort
        List<EfficacyRecord> aggregatedRecords = new List<EfficacyRecord>(aggregatedMap.values());
        aggregatedRecords.sort(new EfficacyRecordComparator());
        
        return aggregatedRecords;
    }
    
    /**
     * @description Aggregate offerings by label, combining different KPI metrics
     */
    private static Map<String, EfficacyRecord> aggregateOfferingsByLabel(List<EfficacyRecord> records) {
        Map<String, EfficacyRecord> aggregatedMap = new Map<String, EfficacyRecord>();
        
        for (EfficacyRecord record : records) {
            String offeringLabel = record.offeringLabel;
            
            if (aggregatedMap.containsKey(offeringLabel)) {
                // Aggregate with existing record
                EfficacyRecord existing = aggregatedMap.get(offeringLabel);
                aggregatedMap.put(offeringLabel, aggregateEfficacyRecords(existing, record));
            } else {
                // First occurrence of this offering
                aggregatedMap.put(offeringLabel, record.cloneRecord());
            }
        }
        
        return aggregatedMap;
    }
    
    /**
     * @description Aggregate two efficacy records for the same offering
     */
    private static EfficacyRecord aggregateEfficacyRecords(EfficacyRecord existing, EfficacyRecord newRecord) {
        // Clone existing record to avoid modifying the original
        EfficacyRecord aggregated = existing.cloneRecord();
        
        // Sum ACV values
        if (existing.totalInfluencedAcv != null && newRecord.totalInfluencedAcv != null) {
            aggregated.totalInfluencedAcv = existing.totalInfluencedAcv + newRecord.totalInfluencedAcv;
        } else if (newRecord.totalInfluencedAcv != null) {
            aggregated.totalInfluencedAcv = newRecord.totalInfluencedAcv;
        }
        
        // Sum distinct learners (take the maximum to avoid double counting)
        if (existing.distinctLearners != null && newRecord.distinctLearners != null) {
            aggregated.distinctLearners = Math.max(existing.distinctLearners, newRecord.distinctLearners);
        } else if (newRecord.distinctLearners != null) {
            aggregated.distinctLearners = newRecord.distinctLearners;
        }
        
        // For effectiveness and lift, we'll show the best performing KPI
        // This gives users the most optimistic view of the offering's performance
        if (newRecord.meanEffectiveness != null && (existing.meanEffectiveness == null || 
            newRecord.meanEffectiveness > existing.meanEffectiveness)) {
            aggregated.meanEffectiveness = newRecord.meanEffectiveness;
            aggregated.effectivenessDisplay = newRecord.effectivenessDisplay;
        }
        
        if (newRecord.calculatedLift != null && (existing.calculatedLift == null || 
            newRecord.calculatedLift > existing.calculatedLift)) {
            aggregated.calculatedLift = newRecord.calculatedLift;
            aggregated.liftDisplay = newRecord.liftDisplay;
        }
        
        // Update ACV display
        if (aggregated.totalInfluencedAcv != null) {
            aggregated.acvDisplay = formatCurrency(aggregated.totalInfluencedAcv);
        }
        
        // Add note about KPI aggregation
        aggregated.kpiName = 'Multiple KPIs (Aggregated)';
        
        return aggregated;
    }
    
    /**
     * @description Get top N different offerings (aggregated by KPI)
     */
    public static List<EfficacyRecord> getTopNDifferentOfferings(List<EfficacyRecord> records, Integer n) {
        if (records == null || records.isEmpty()) {
            return new List<EfficacyRecord>();
        }
        
        // Get aggregated offerings
        List<EfficacyRecord> aggregatedOfferings = getTopPerformers(records);
        
        // Return top N
        List<EfficacyRecord> topN = new List<EfficacyRecord>();
        Integer count = Math.min(n, aggregatedOfferings.size());
        
        for (Integer i = 0; i < count; i++) {
            topN.add(aggregatedOfferings[i]);
        }
        
        return topN;
    }
    
    /**
     * @description Generate a focused summary for specific offerings
     * When users ask for "effective courses", we focus on lift and ACV, not effectiveness scores
     */
    private static String generateFocusedSummary(List<EfficacyRecord> records, String searchTerm) {
        if (records == null || records.isEmpty()) {
            return 'No data available for summary.';
        }
        
        // Get top 3 different offerings (aggregated)
        List<EfficacyRecord> top3DifferentOfferings = getTopNDifferentOfferings(records, 3);
        
        // Build enhanced summary with different offering names
        String summary = 'Summary of ' + records.size() + ' records for "' + searchTerm + '":\n';
        
        // Calculate aggregated metrics across all records - FOCUS ON LIFT AND ACV
        Decimal totalLift = 0;
        Decimal totalAcv = 0;
        Integer significantCount = 0;
        Integer recordsWithLift = 0;
        
        for (EfficacyRecord record : records) {
            if (record.calculatedLift != null) {
                totalLift += record.calculatedLift;
                recordsWithLift++;
            }
            if (record.totalInfluencedAcv != null) {
                totalAcv += record.totalInfluencedAcv;
            }
            if (record.significanceIndicator == 'SIGNIFICANT') {
                significantCount++;
            }
        }
        
        Integer recordCount = records.size();
        Decimal avgLift = recordsWithLift > 0 ? totalLift / recordsWithLift : 0;
        
        // Show only lift and ACV metrics (hide effectiveness scores)
        summary += '• Average Lift: ' + formatPercentage(avgLift) + '\n';
        summary += '• Total Influenced ACV: ' + formatCurrency(totalAcv) + '\n';
        summary += '• Significant Results: ' + significantCount + ' of ' + recordCount + ' (' + formatPercentage((Decimal)significantCount / recordCount * 100) + ')\n\n';
        
        // Add top 3 different offering names - SHOW ONLY LIFT AND ACV
        summary += 'Top Different Offerings:\n';
        for (Integer i = 0; i < top3DifferentOfferings.size(); i++) {
            EfficacyRecord record = top3DifferentOfferings[i];
            String offeringName = String.isNotBlank(record.offeringLabel) ? record.offeringLabel : 'Unnamed Offering';
            String lift = record.calculatedLift != null ? formatPercentage(record.calculatedLift) : 'N/A';
            String acv = record.totalInfluencedAcv != null ? formatCurrency(record.totalInfluencedAcv) : 'N/A';
            
            summary += (i + 1) + '. ' + offeringName + '\n';
            summary += '   Lift: ' + lift + ', Total ACV: ' + acv + '\n';
        }
        
        // Add KPI guidance - FOCUS ON LIFT AND ACV
        summary += '\n📊 Understanding the Metrics:\n';
        summary += '• Lift: Performance improvement compared to control group (higher is better)\n';
        summary += '• Total ACV: Annual Contract Value influenced by the offering\n';
        summary += '• Significant Results: Number of offerings with statistically significant impact\n';
        summary += '• Multiple KPIs are aggregated to show overall offering impact\n\n';
        
        // Add user guidance with clarifying questions
        summary += '💡 Need More Specific Data?\n';
        summary += 'To get better results, ask me clarifying questions like:\n';
        summary += '• "Show me Data Cloud courses by PIPE_QUALITY"\n';
        summary += '• "What are the ACV results for Data Cloud?"\n';
        summary += '• "Show me Data Cloud courses with highest lift"\n';
        summary += '• "What Data Cloud courses focus on pipeline conversion?"\n\n';
        
        // Add instruction-based guidance
        summary += '🎯 Pro Tip: Be specific about what you want!\n';
        summary += 'Instead of "Data Cloud courses", try:\n';
        summary += '• "Data Cloud pipeline quality courses"\n';
        summary += '• "Data Cloud courses with highest ACV impact"\n';
        summary += '• "Data Cloud courses by specific KPI"\n';
        
        return summary;
    }

    /**
     * @description Comparator for sorting efficacy records
     */
    public class EfficacyRecordComparator implements Comparator<EfficacyRecord> {
        public Integer compare(EfficacyRecord a, EfficacyRecord b) {
            // Primary sort: Total ACV (highest first)
            Decimal aAcv = a.totalInfluencedAcv != null ? a.totalInfluencedAcv : 0;
            Decimal bAcv = b.totalInfluencedAcv != null ? b.totalInfluencedAcv : 0;
            
            if (aAcv > bAcv) return -1;
            if (aAcv < bAcv) return 1;
            
            // Secondary sort: Lift (highest first)
            Decimal aLift = a.calculatedLift != null ? a.calculatedLift : 0;
            Decimal bLift = b.calculatedLift != null ? b.calculatedLift : 0;
            
            if (aLift > bLift) return -1;
            if (aLift < bLift) return 1;
            
            return 0;
        }
    }

    /**
     * @description Format percentage values
     */
    private static String formatPercentage(Decimal value) {
        if (value == null) return 'N/A';
        return (value * 100).setScale(1) + '%';
    }

    /**
     * @description Format currency values
     */
    private static String formatCurrency(Decimal value) {
        if (value == null) return 'N/A';
        if (value >= 1000000) {
            return '$' + (value / 1000000).setScale(1) + 'M';
        } else if (value >= 1000) {
            return '$' + (value / 1000).setScale(1) + 'K';
        } else {
            return '$' + value.setScale(0);
        }
    }

    /**
     * @description Get available KPIs for user guidance
     */
    public static String getAvailableKPIs() {
        return '📊 Available KPIs in APM Library:\n\n' +
               '🎯 Pipeline Metrics:\n' +
               '• PIPE_QUALITY - Pipeline quality improvement\n' +
               '• PIPE_CONVERSION - Pipeline conversion rates\n' +
               '• PIPE_CREATECLOSE - Pipeline creation and closure\n' +
               '• PG - Pipeline generation\n\n' +
               '💰 Revenue Metrics:\n' +
               '• ACV - Annual Contract Value impact\n' +
               '• PARTICIPATION_ACV - Participation in ACV activities\n\n' +
               '📞 Activity Metrics:\n' +
               '• ACTIVITY_MEETINGS - Meeting activity impact\n' +
               '• ACTIVITY_CALL_CONNECT - Call connection impact\n' +
               '• PARTICIPATION_PG - Participation in pipeline generation\n\n' +
               '💡 How to Use:\n' +
               'Instead of "effective courses", ask:\n' +
               '• "Show me top 5 PIPE_QUALITY courses on Data Cloud"\n' +
               '• "What are the most effective ACV courses for Data Cloud?"\n' +
               '• "Show me Data Cloud courses with highest PIPE_CONVERSION lift"\n\n' +
               '🎯 Note: When you ask for "effective courses", I\'ll show you lift and ACV impact, not effectiveness scores.';
    }
    
    /**
     * @description Get fallback options when no APM data is found
     */
    public static String getFallbackOptions(String searchTerm) {
        return 'I couldn\'t find any APM efficacy data for "' + searchTerm + '". ' +
               'Here are your options:\n\n' +
               '🔍 Option 1: Search for related courses\n' +
               'Ask me: "Search for ' + searchTerm + ' courses" to find available learning content\n\n' +
               '📊 Option 2: Nominate for APM measurement\n' +
               'If you find a relevant course, you can nominate it for APM measurement to track its effectiveness\n\n' +
               '💡 Option 3: Try a different KPI\n' +
               'Ask me about specific KPIs like "PIPE_QUALITY" or "ACV" for ' + searchTerm + '\n\n' +
               '🎯 Option 4: Get available KPIs\n' +
               'Ask me: "What KPIs are available?" to see all options';
    }

    /**
     * @description Try APM efficacy first, then fall back to completion rate if no APM data
     */
    public static EfficacySearchResult searchWithFallback(String offeringLabel, String programType, String region, 
                                                        String macroSegment, String fiscalQuarter, String kpiName, 
                                                        String product, Integer maxResults) {
        
        EfficacySearchResult result = new EfficacySearchResult();
        
        try {
            // First, try to get APM efficacy data
            result = searchEfficacyData(offeringLabel, programType, region, macroSegment, 
                                      fiscalQuarter, kpiName, product, maxResults);
            
            // If no APM data found, set fallback flag for completion rate search
            if (result.success && result.totalRecordCount == 0) {
                result.needsFallback = true;
                result.fallbackSearchTerm = offeringLabel;
                result.message = 'No APM efficacy data found for "' + offeringLabel + '". ' +
                               'I\'ll search for courses by completion rate instead.';
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error in APM search: ' + e.getMessage();
            System.debug('Error in searchWithFallback: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Check if query should try APM first (effectiveness-related keywords)
     */
    public static Boolean shouldTryAPMFirst(String query) {
        if (String.isBlank(query)) return false;
        
        String normalizedQuery = query.toLowerCase().trim();
        
        // Effectiveness-related keywords that should try APM first
        Set<String> effectivenessKeywords = new Set<String>{
            'best', 'most effective', 'top performing', 'highest performing', 'most successful',
            'top rated', 'best performing', 'most impactful', 'highest impact', 'best results',
            'top results', 'most valuable', 'highest value', 'best outcomes', 'top outcomes',
            'most productive', 'highest productivity', 'best performance', 'top performance',
            'most efficient', 'highest efficiency', 'best quality', 'top quality'
        };
        
        for (String keyword : effectivenessKeywords) {
            if (normalizedQuery.contains(keyword)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * @description Get information about region-OU mapping for debugging and understanding
     * This method helps explain why region filtering doesn't work and why OU filtering should be used
     */
    public static String getRegionOUMappingInfo() {
        return '🔍 REGION vs OU MAPPING EXPLANATION:\n\n' +
               '❌ PROBLEM WITH REGION FILTERING:\n' +
               '• REGION__c field is mostly null in apm_outcome_v2__c\n' +
               '• Filtering by region="AMER" returns programs from everywhere\n' +
               '• That\'s why you get "[Korea] FY25 Q1 Slack Certification" for AMER requests\n\n' +
               
               '✅ SOLUTION WITH OU FILTERING:\n' +
               '• OU_NAME__c field contains actual geographic values\n' +
               '• Examples: "AMER ICE", "AMER ESMB", "EMEA", "APAC", "ASEAN"\n' +
               '• Filtering by operatingUnit="AMER" returns only AMER-related programs\n\n' +
               
               '🎯 CORRECT PARAMETER MAPPING:\n' +
               '• User: "within AMER" → operatingUnit: "AMER" (✅ CORRECT)\n' +
               '• User: "within AMER" → region: "AMER" (❌ WRONG)\n\n' +
               
               '💡 IMPLEMENTATION:\n' +
               '• The service now automatically maps region="AMER" to OU filtering\n' +
               '• But the topic should still send operatingUnit="AMER" for clarity\n' +
               '• This provides a safety net while encouraging correct parameter usage';
    }
} 