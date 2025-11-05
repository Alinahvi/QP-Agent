/**
 * @description Service layer for ANAgent Planning - Creates quarterly plans in Salesforce
 * @version 1.0.0
 * @date 2025-10-22
 */
public with sharing class ANAgentPlanningServiceV1 {
    
    /**
     * @description Creates complete quarterly plan with all related records
     * @param request Handler request object
     * @return Map with success status and created record IDs
     */
    public static Map<String, Object> createPlan(Map<String, Object> request) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Step 1: Parse analysis data
            Map<String, Object> analysisData = (Map<String, Object>)JSON.deserializeUntyped((String)request.get('analysisDataJson'));
            
            // Step 1a: Validate analysis data structure
            validateAnalysisDataStructure(analysisData);
            
            // Step 2: Parse recommendations
            List<Object> recommendationsData = (List<Object>)JSON.deserializeUntyped((String)request.get('recommendationsJson'));
            
            // Step 3: Create parent Quarterly_Planning__c record
            Quarterly_Planning__c qp = createQuarterlyPlanningRecord(request, analysisData);
            insert qp;
            
            // Step 4: Create Agent_OU_Quarterly_Plan__c metrics record
            Agent_OU_Quarterly_Plan__c metrics = createMetricsRecord(request, analysisData);
            insert metrics;
            
            // Step 5: Create Enablement_Solutions__c records
            List<Enablement_Solutions__c> solutions = createEnablementSolutions(
                qp.Id, 
                request, 
                recommendationsData
            );
            insert solutions;
            
            // Step 6: Build success response
            result.put('success', true);
            result.put('quarterlyPlanningId', qp.Id);
            result.put('agentOuPlanId', metrics.Id);
            result.put('enablementSolutionIds', buildIdList(solutions));
            result.put('totalRecordsCreated', 2 + solutions.size());
            result.put('message', 'Successfully created quarterly plan ' + qp.Name + ' with ' + solutions.size() + ' enablement solutions');
            result.put('errorDetails', null);
            
        } catch (Exception e) {
            Database.rollback(sp);
            result.put('success', false);
            result.put('quarterlyPlanningId', null);
            result.put('agentOuPlanId', null);
            result.put('enablementSolutionIds', null);
            result.put('totalRecordsCreated', 0);
            result.put('message', 'Error: ' + e.getMessage());
            result.put('errorDetails', e.getStackTraceString());
        }
        
        return result;
    }
    
    /**
     * @description Creates Quarterly_Planning__c parent record in Draft status
     */
    private static Quarterly_Planning__c createQuarterlyPlanningRecord(
        Map<String, Object> request,
        Map<String, Object> analysisData
    ) {
        Quarterly_Planning__c qp = new Quarterly_Planning__c();
        
        // Required fields
        qp.Quarterly_Plan_Name__c = (String)request.get('ouName') + ' ' + (String)request.get('fiscalQuarter') + ' ' + (String)request.get('fiscalYear') + ' Enablement Plan';
        qp.Fiscal_Quarter__c = (String)request.get('fiscalQuarter');
        qp.Fiscal_Year__c = (String)request.get('fiscalYear');
        qp.OU__c = (String)request.get('ouName');
        qp.Global_Region__c = (String)request.get('globalRegion');
        // Note: No Status__c field exists - records are created in active state
        
        // Optional fields from request
        qp.TEMPLATE__c = request.get('templateFlag') != null ? (Boolean)request.get('templateFlag') : false;
        
        // Set owner if provided
        if (String.isNotBlank((String)request.get('planOwnerUserId'))) {
            qp.Quarterly_Plan_Owner__c = (String)request.get('planOwnerUserId');
        }
        
        // Set leader if provided
        if (String.isNotBlank((String)request.get('leaderUserId'))) {
            qp.Leader__c = (String)request.get('leaderUserId');
        }
        
        // Set business priority if provided
        if (String.isNotBlank((String)request.get('businessPriority'))) {
            qp.Business_Priority__c = (String)request.get('businessPriority');
        }
        
        // Set quarter timing if provided
        if (String.isNotBlank((String)request.get('quarterTiming'))) {
            qp.Quarter_Timing__c = (String)request.get('quarterTiming');
        }
        
        // Set EBP type if provided
        if (String.isNotBlank((String)request.get('ebpType'))) {
            qp.EBP_Type__c = (String)request.get('ebpType');
        }
        
        return qp;
    }
    
    /**
     * @description Creates Agent_OU_Quarterly_Plan__c metrics record
     */
    private static Agent_OU_Quarterly_Plan__c createMetricsRecord(
        Map<String, Object> request,
        Map<String, Object> analysisData
    ) {
        Agent_OU_Quarterly_Plan__c metrics = new Agent_OU_Quarterly_Plan__c();
        
        // Core identification fields
        metrics.OU_NAME__c = (String)request.get('ouName');
        metrics.MACROSGMENT__c = (String)request.get('macroSegment');
        metrics.PRIMARY_INDUSTRY__c = (String)request.get('primaryIndustry');
        
        // Extract metrics from analysis data
        Map<String, Object> renewalsData = (Map<String, Object>)analysisData.get('renewals');
        Map<String, Object> crossSellData = (Map<String, Object>)analysisData.get('cross_sell');
        Map<String, Object> upsellData = (Map<String, Object>)analysisData.get('upsell');
        Map<String, Object> openPipeData = (Map<String, Object>)analysisData.get('open_pipeline');
        
        // Populate from RENEWALS
        if (renewalsData != null) {
            Map<String, Object> renewalTotals = (Map<String, Object>)renewalsData.get('totals');
            if (renewalTotals != null && renewalTotals.get('total_amount') != null) {
                metrics.RENEWAL_OPTY_AMT__c = Decimal.valueOf(String.valueOf(renewalTotals.get('total_amount')));
            }
        }
        
        // Populate from CROSS_SELL
        if (crossSellData != null) {
            Map<String, Object> crossSellTotals = (Map<String, Object>)crossSellData.get('totals');
            if (crossSellTotals != null && crossSellTotals.get('count') != null) {
                metrics.CROSS_OPTY_CNT__c = Integer.valueOf(crossSellTotals.get('count'));
            }
        }
        
        // Populate from UPSELL
        if (upsellData != null) {
            Map<String, Object> upsellTotals = (Map<String, Object>)upsellData.get('totals');
            if (upsellTotals != null && upsellTotals.get('count') != null) {
                metrics.UPSELL_OPTY_CNT__c = Integer.valueOf(upsellTotals.get('count'));
            }
        }
        
        // Populate from OPEN PIPELINE
        if (openPipeData != null) {
            Map<String, Object> openPipeTotals = (Map<String, Object>)openPipeData.get('totals');
            if (openPipeTotals != null && openPipeTotals.get('sum') != null) {
                metrics.OPEN_PIPE_AMT__c = Decimal.valueOf(String.valueOf(openPipeTotals.get('sum')));
            }
        }
        
        return metrics;
    }
    
    /**
     * @description Creates Enablement_Solutions__c records from recommendations
     */
    private static List<Enablement_Solutions__c> createEnablementSolutions(
        Id quarterlyPlanId,
        Map<String, Object> request,
        List<Object> recommendationsData
    ) {
        List<Enablement_Solutions__c> solutions = new List<Enablement_Solutions__c>();
        Integer recIndex = 0;
        
        for (Object recObj : recommendationsData) {
            recIndex++;
            Map<String, Object> rec = (Map<String, Object>)recObj;
            
            // Validate required fields for data quality
            validateRecommendationFields(rec, recIndex);
            
            Enablement_Solutions__c sol = new Enablement_Solutions__c();
            
            // Master-Detail link
            sol.Quarterly_Plan__c = quarterlyPlanId;
            
            // Program links (if found from SearchProgramsV4)
            if (rec.get('ge_program_menu_item__c') != null) {
                sol.GE_Program_Menu_Item__c = String.valueOf(rec.get('ge_program_menu_item__c'));
            }
            if (rec.get('regional_program_menu_item__c') != null) {
                sol.Regional_Program_Menu_Item__c = String.valueOf(rec.get('regional_program_menu_item__c'));
            }
            
            // Required picklists
            sol.Status__c = 'Planned'; // Initial status - requires user approval to Complete
            sol.Global_Region__c = (String)request.get('globalRegion');
            sol.Hierarchy__c = 'Individual Contributor'; // Fixed for Prime AEs
            sol.Role__c = 'AE'; // Fixed for Prime AEs
            
            // Segment (map from ENTR to Enterprise, etc.)
            String segmentRaw = String.valueOf(rec.get('segment'));
            sol.Segment__c = mapSegmentToPicklist(segmentRaw);
            
            // Priority based on severity
            String severity = String.valueOf(rec.get('severity'));
            sol.Required_Recommended__c = mapSeverityToPriority(severity);
            
            // Enablement type
            String enablementType = String.valueOf(rec.get('enablement_type'));
            sol.Enablement_Type__c = enablementType; // Should already be picklist value
            
            // Product hierarchy
            sol.Product_L1__c = String.valueOf(rec.get('product_l1__c'));
            sol.Product_L2__c = String.valueOf(rec.get('product_l2__c'));
            
            // Industry
            sol.Industry_L1__c = String.valueOf(rec.get('industry_l1__c'));
            sol.Industry_L2__c = String.valueOf(rec.get('industry_l2__c'));
            
            // Business priority
            sol.BusinessPriority__c = String.valueOf(rec.get('businesspriority__c'));
            
            // Learner count (actual count from learnerProfileIds)
            if (rec.get('of_learners__c') != null) {
                sol.of_Learners__c = Integer.valueOf(rec.get('of_learners__c'));
            }
            
            // Dates
            if (rec.get('delivery_date__c') != null) {
                sol.Delivery_Date__c = Date.valueOf(String.valueOf(rec.get('delivery_date__c')));
            }
            if (rec.get('end_date__c') != null) {
                sol.End_Date__c = Date.valueOf(String.valueOf(rec.get('end_date__c')));
            }
            
            // Rationale (detailed)
            sol.Additional_Details__c = String.valueOf(rec.get('additional_details__c'));
            if (sol.Additional_Details__c != null && sol.Additional_Details__c.length() > 255) {
                sol.Additional_Details__c = sol.Additional_Details__c.substring(0, 255);
            }
            
            solutions.add(sol);
        }
        
        return solutions;
    }
    
    /**
     * @description Maps analysis segment to picklist value
     */
    private static String mapSegmentToPicklist(String segmentRaw) {
        if (String.isBlank(segmentRaw)) {
            return 'Enterprise'; // Default
        }
        
        Map<String, String> mapping = new Map<String, String>{
            'ENTR' => 'Enterprise',
            'CMRCL' => 'Commercial',
            'ESMB' => 'SMB',
            'PubSec' => 'ECS',
            'Enterprise' => 'Enterprise', // Already mapped
            'Commercial' => 'Commercial',
            'SMB' => 'SMB'
        };
        
        String mapped = mapping.get(segmentRaw);
        return mapped != null ? mapped : 'Enterprise';
    }
    
    /**
     * @description Maps gap severity to priority picklist
     */
    private static String mapSeverityToPriority(String severity) {
        if (String.isBlank(severity)) {
            return 'Locally Recommended';
        }
        
        Map<String, String> mapping = new Map<String, String>{
            'CRITICAL' => 'Locally Required',
            'HIGH' => 'Locally Recommended',
            'MEDIUM' => 'Locally Recommended',
            'LOW' => 'Locally Recommended'
        };
        
        String mapped = mapping.get(severity.toUpperCase());
        return mapped != null ? mapped : 'Locally Recommended';
    }
    
    /**
     * @description Builds comma-separated list of record IDs
     */
    private static String buildIdList(List<Enablement_Solutions__c> solutions) {
        List<String> ids = new List<String>();
        for (Enablement_Solutions__c sol : solutions) {
            if (sol.Id != null) {
                ids.add(sol.Id);
            }
        }
        return String.join(ids, ',');
    }
    
    /**
     * @description Validates recommendation has required fields for data quality
     * @param rec Recommendation map
     * @param index Recommendation index (1-based for error messages)
     */
    private static void validateRecommendationFields(Map<String, Object> rec, Integer index) {
        List<String> errors = new List<String>();
        
        // Required for meaningful enablement solution
        if (rec.get('program_name') == null || String.isBlank(String.valueOf(rec.get('program_name')))) {
            errors.add('program_name (the name of the enablement program)');
        }
        if (rec.get('enablement_type') == null || String.isBlank(String.valueOf(rec.get('enablement_type')))) {
            errors.add('enablement_type (must be: Do My Job, Industry, Product, or Skills)');
        }
        if (rec.get('of_learners__c') == null) {
            errors.add('of_learners__c (count of learnerProfileIds from analysis with issues in this area)');
        }
        if (rec.get('delivery_date__c') == null || String.isBlank(String.valueOf(rec.get('delivery_date__c')))) {
            errors.add('delivery_date__c (format: YYYY-MM-DD, example: 2025-03-15)');
        }
        if (rec.get('end_date__c') == null || String.isBlank(String.valueOf(rec.get('end_date__c')))) {
            errors.add('end_date__c (format: YYYY-MM-DD, same as delivery_date for single-day)');
        }
        if (rec.get('segment') == null || String.isBlank(String.valueOf(rec.get('segment')))) {
            errors.add('segment (must be: Enterprise, Commercial, SMB, etc.)');
        }
        if (rec.get('additional_details__c') == null || String.isBlank(String.valueOf(rec.get('additional_details__c')))) {
            errors.add('additional_details__c (rationale explaining why this recommendation addresses the identified gap, max 255 chars)');
        }
        
        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(
                '❌ RECOMMENDATION #' + index + ' MISSING REQUIRED FIELDS: ' + String.join(errors, '; ') + '. ' +
                'Each recommendation must include: program_name, enablement_type, product_l1__c (if product-related), ' +
                'segment, of_learners__c, delivery_date__c, end_date__c, additional_details__c. ' +
                'Use SearchProgramsV4 to find valid programs with proper IDs and metadata.'
            );
        }
        
        // Validate picklist values if provided
        validatePicklistValues(rec, index);
        
        // Validate data constraints
        validateDataConstraints(rec, index);
    }
    
    /**
     * @description Validates picklist values match allowed values
     */
    private static void validatePicklistValues(Map<String, Object> rec, Integer index) {
        // Enablement Type - STRICT validation
        String enablementType = String.valueOf(rec.get('enablement_type'));
        if (String.isNotBlank(enablementType)) {
            Set<String> validEnablementTypes = new Set<String>{'Do My Job', 'Industry', 'Product', 'Skills'};
            if (!validEnablementTypes.contains(enablementType)) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID ENABLEMENT TYPE: "' + enablementType + '". ' +
                    'Valid values: Do My Job, Industry, Product, Skills (case-sensitive). ' +
                    'Please use exact values. Example: "Product" for product enablement, "Skills" for skills training.'
                );
            }
        }
        
        // Product L1 - Validate if provided (restricted picklist)
        String productL1 = String.valueOf(rec.get('product_l1__c'));
        if (String.isNotBlank(productL1) && productL1 != 'null') {
            Set<String> validProducts = new Set<String>{
                'Automotive Cloud', 'Commerce Cloud', 'Communications Cloud', 'Consumer Goods Cloud',
                'Cross Portfolio Bundles/Packages/Solutions', 'Customer Data Cloud', 'Digital 360',
                'Education Cloud', 'Energy and Utilities Cloud', 'Essentials', 'Financial Services Cloud',
                'Health Cloud', 'Loyalty Management', 'Manufacturing Cloud', 'Marketing Cloud',
                'Media Cloud', 'MuleSoft', 'Net Zero Cloud', 'Nonprofit Cloud', 'Philanthropy Cloud',
                'Product Offerings', 'Professional Services (Products)', 'Public Sector Solutions',
                'Sales and Service Cloud', 'Sales Cloud', 'Salesforce Platform', 'Salesforce Starter',
                'Salesforce.org', 'Service Cloud', 'Slack', 'Success Plans', 'Trailhead', 'Vaccine Cloud'
            };
            if (!validProducts.contains(productL1)) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID PRODUCT L1: "' + productL1 + '". ' +
                    'Valid values: Sales Cloud, Service Cloud, Marketing Cloud, Slack, Salesforce Platform, MuleSoft, Customer Data Cloud, ' +
                    'Commerce Cloud, Health Cloud, Financial Services Cloud, Manufacturing Cloud, etc. ' +
                    'Please use exact product names from the Product_L1__c picklist. Common products: Sales Cloud, Service Cloud, Marketing Cloud, Slack.'
                );
            }
        }
        
        // Business Priority - Validate format if provided (unrestricted but should follow pattern)
        String businessPriority = String.valueOf(rec.get('businesspriority__c'));
        if (String.isNotBlank(businessPriority) && businessPriority != 'null') {
            Set<String> validPriorities = new Set<String>{
                'Priority 1: High Performance Culture',
                'Priority 2: ACV growth (sales plays, Signature Success)',
                'Priority 3: Field success (participation/ DMJ/ skills)',
                'Priority 4: Big Deal motion',
                'Priority 5: Customer Success (Industry, Product, Ensure Customer Loyalty, Customer Adoption/Performance/Engagement)'
            };
            if (!validPriorities.contains(businessPriority)) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID BUSINESS PRIORITY: "' + businessPriority + '". ' +
                    'Valid values: Priority 1: High Performance Culture | Priority 2: ACV growth (sales plays, Signature Success) | ' +
                    'Priority 3: Field success (participation/ DMJ/ skills) | Priority 4: Big Deal motion | ' +
                    'Priority 5: Customer Success (Industry, Product, Ensure Customer Loyalty, Customer Adoption/Performance/Engagement). ' +
                    'Please use exact format including "Priority N:" prefix.'
                );
            }
        }
        
        // Segment - Validate if provided (restricted multi-picklist)
        String segment = String.valueOf(rec.get('segment'));
        if (String.isNotBlank(segment) && segment != 'null') {
            Set<String> validSegments = new Set<String>{
                'Commercial', 'CSG', 'ECS', 'Enterprise', 'Field AE', 'Leader', 
                'Sales Dev', 'SMB', 'Solutions', 'Specialist'
            };
            if (!validSegments.contains(segment)) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID SEGMENT: "' + segment + '". ' +
                    'Valid values: Commercial, CSG, ECS, Enterprise, Field AE, Leader, Sales Dev, SMB, Solutions, Specialist. ' +
                    'For macro segment mapping: ENTR→Enterprise, CMRCL→Commercial, ESMB→SMB, PubSec→use Enterprise or Commercial. ' +
                    'Use exact case-sensitive values.'
                );
            }
        }
    }
    
    /**
     * @description Validates data constraints (positive numbers, text length, date format)
     */
    private static void validateDataConstraints(Map<String, Object> rec, Integer index) {
        // Validate learner count is positive
        if (rec.get('of_learners__c') != null) {
            Decimal learners = Decimal.valueOf(String.valueOf(rec.get('of_learners__c')));
            if (learners <= 0) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID LEARNER COUNT: ' + learners + '. ' +
                    'Number of learners must be positive (greater than 0). ' +
                    'This should be the count of learnerProfileIds from ANAGENT Open Pipeline Analysis V4 and ABAGENT Future Pipeline Analysis V4 ' +
                    'that have issues in this specific area (product/skill/industry gap). ' +
                    'Example: If 87 learners have low Service Cloud renewal scores, set of_learners__c to 87.'
                );
            }
        }
        
        // Validate additional details length (max 255)
        String additionalDetails = String.valueOf(rec.get('additional_details__c'));
        if (String.isNotBlank(additionalDetails) && additionalDetails != 'null' && additionalDetails.length() > 255) {
            throw new IllegalArgumentException(
                '❌ RECOMMENDATION #' + index + ' TEXT TOO LONG: additional_details__c is ' + additionalDetails.length() + ' characters. ' +
                'Maximum allowed: 255 characters. Current length: ' + additionalDetails.length() + '. ' +
                'Please shorten your rationale. Focus on: (1) What gap this addresses, (2) Which analysis it came from, (3) Expected impact. ' +
                'Example: "Addresses renewal risk in Service Cloud ($16.2M at risk). Low AE confidence (2.9/5). Targets 87 learners with renewal gaps."'
            );
        }
        
        // Validate date format (YYYY-MM-DD)
        if (rec.get('delivery_date__c') != null) {
            String dateStr = String.valueOf(rec.get('delivery_date__c'));
            if (!isValidDateFormat(dateStr)) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID DATE FORMAT: delivery_date__c = "' + dateStr + '". ' +
                    'Required format: YYYY-MM-DD (ISO 8601). ' +
                    'Examples: "2025-03-15" (March 15, 2025), "2025-12-31" (December 31, 2025). ' +
                    'Do NOT use: MM/DD/YYYY, DD-MM-YYYY, or text dates like "March 15, 2025".'
                );
            }
        }
        if (rec.get('end_date__c') != null) {
            String dateStr = String.valueOf(rec.get('end_date__c'));
            if (!isValidDateFormat(dateStr)) {
                throw new IllegalArgumentException(
                    '❌ RECOMMENDATION #' + index + ' INVALID DATE FORMAT: end_date__c = "' + dateStr + '". ' +
                    'Required format: YYYY-MM-DD (ISO 8601). For single-day programs, use same date as delivery_date__c.'
                );
            }
        }
        
        // Validate program_name is not empty
        String programName = String.valueOf(rec.get('program_name'));
        if (String.isBlank(programName) || programName == 'null') {
            throw new IllegalArgumentException(
                '❌ RECOMMENDATION #' + index + ' MISSING PROGRAM NAME: program_name is required. ' +
                'This should be the actual program name from SearchProgramsV4 results. ' +
                'If no matching program found, create a descriptive name based on the enablement need. ' +
                'Example: "Service Cloud Renewal Mastery" or "Financial Services Industry Deep Dive".'
            );
        }
    }
    
    /**
     * @description Validates date string format (YYYY-MM-DD)
     */
    private static Boolean isValidDateFormat(String dateStr) {
        if (String.isBlank(dateStr) || dateStr == 'null') {
            return false;
        }
        // Pattern: YYYY-MM-DD (4 digits, dash, 2 digits, dash, 2 digits)
        Pattern datePattern = Pattern.compile('^\\d{4}-\\d{2}-\\d{2}$');
        return datePattern.matcher(dateStr).matches();
    }
    
    /**
     * @description Validates analysis data structure
     */
    private static void validateAnalysisDataStructure(Map<String, Object> analysisData) {
        List<String> missingKeys = new List<String>();
        
        if (!analysisData.containsKey('renewals')) {
            missingKeys.add('renewals');
        }
        if (!analysisData.containsKey('cross_sell')) {
            missingKeys.add('cross_sell');
        }
        if (!analysisData.containsKey('upsell')) {
            missingKeys.add('upsell');
        }
        if (!analysisData.containsKey('open_pipeline')) {
            missingKeys.add('open_pipeline');
        }
        
        if (!missingKeys.isEmpty()) {
            throw new IllegalArgumentException(
                '❌ ANALYSIS DATA STRUCTURE ERROR: Missing required sections: ' + String.join(missingKeys, ', ') + '. ' +
                'Expected structure from combining ANAGENT Open Pipeline Analysis V4 and ABAGENT Future Pipeline Analysis V4: ' +
                '{"renewals":{"totals":{...}}, "cross_sell":{"totals":{...}}, "upsell":{"totals":{...}}, "open_pipeline":{"totals":{...}}}. ' +
                'Please run both pipeline analyses first and combine their results into this format.'
            );
        }
    }
}

