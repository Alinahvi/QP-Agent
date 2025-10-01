/**
 * ENHANCED FUTURE PIPELINE ANALYSIS SERVICE
 * 
 * This service extends the original Future Pipeline Analysis with intelligence capabilities:
 * - Renewal Risk Scoring
 * - AE Performance Analysis
 * - Product-Market Fit Analysis
 * - Pipeline Health Scoring
 * 
 * All intelligence features are feature-toggled and gracefully degrade when data is missing.
 */
public with sharing class ABAgentFuturePipeAnalysisServiceEnhanced {
    
    // Feature toggles
    private static Boolean enableRenewalRisk = false;
    private static Boolean enableAEPerf = false;
    private static Boolean enablePMF = false;
    private static Boolean enableHealthScore = false;
    private static Boolean enableExplain = true;
    private static Boolean enableLearnerEnrichment = false;
    
    // Initialize feature toggles
    static {
        // Enable intelligence features by default
        enableRenewalRisk = true;
        enableAEPerf = true;
        enablePMF = true;
        enableHealthScore = true;
        enableExplain = true;
        enableLearnerEnrichment = false;
    }
    
    // Enhanced response DTO
    public class EnhancedResponse {
        public Map<String, Object> aggregates { get; set; }
        public List<Map<String, Object>> renewalRisk { get; set; }
        public List<Map<String, Object>> aePerformance { get; set; }
        public List<Map<String, Object>> pmfFindings { get; set; }
        public Map<String, Object> healthScore { get; set; }
        public List<String> explain { get; set; }
        public List<String> nextBestActions { get; set; }
        
        public EnhancedResponse() {
            this.aggregates = new Map<String, Object>();
            this.renewalRisk = new List<Map<String, Object>>();
            this.aePerformance = new List<Map<String, Object>>();
            this.pmfFindings = new List<Map<String, Object>>();
            this.healthScore = new Map<String, Object>();
            this.explain = new List<String>();
            this.nextBestActions = new List<String>();
        }
    }
    
    /**
     * Enhanced analyzePipeline method with intelligence capabilities
     */
    public static String analyzePipelineEnhanced(String analysisType, String ouName, String workLocationCountry, String groupBy,
                                                String filterCriteria, String restrictInValuesCsv, Boolean perAENormalize,
                                                Integer limitN, String aggregationType, String analysisTypeDetail,
                                                Date startDate, Date endDate, Boolean includeRenewalRisk, Boolean includeAEPerf,
                                                Boolean includePMF, Boolean includeHealthScore) {
        
        String originalResult = '';
        
        try {
            // Get original analysis results
            originalResult = ABAgentFuturePipeAnalysisService.analyzePipeline(
                analysisType, ouName, workLocationCountry, groupBy, filterCriteria, restrictInValuesCsv,
                perAENormalize, limitN, aggregationType, analysisTypeDetail, startDate, endDate
            );
            
            // Create enhanced response
            EnhancedResponse enhancedResponse = new EnhancedResponse();
            
            // Parse original result into aggregates (simplified)
            enhancedResponse.aggregates.put('originalResult', originalResult);
            enhancedResponse.aggregates.put('analysisType', analysisType);
            enhancedResponse.aggregates.put('ouName', ouName);
            enhancedResponse.aggregates.put('groupBy', groupBy);
            
            // Add intelligence capabilities based on feature toggles and request flags
            if (enableRenewalRisk && includeRenewalRisk && analysisType == 'RENEWALS') {
                addRenewalRiskAnalysis(enhancedResponse, ouName, workLocationCountry);
            }
            
            if (enableAEPerf && includeAEPerf) {
                addAEPerformanceAnalysis(enhancedResponse, ouName, workLocationCountry, analysisType);
            }
            
            if (enablePMF && includePMF) {
                addPMFAnalysis(enhancedResponse, ouName, workLocationCountry, analysisType);
            }
            
            if (enableHealthScore && includeHealthScore) {
                addHealthScoreAnalysis(enhancedResponse, ouName, workLocationCountry, analysisType);
            }
            
            // Add explainability
            if (enableExplain) {
                addExplainability(enhancedResponse, analysisType, ouName);
            }
            
            // Convert enhanced response to markdown
            return convertToMarkdown(enhancedResponse, originalResult);
            
        } catch (Exception e) {
            // Graceful degradation - return original result with error explanation
            String errorMsg = 'Intelligence features unavailable: ' + e.getMessage() + '. Returning basic analysis.';
            return originalResult + '\n\n## Intelligence Features\n\n' + errorMsg;
        }
    }
    
    /**
     * Add renewal risk analysis with real calculations
     */
    private static void addRenewalRiskAnalysis(EnhancedResponse response, String ou, String country) {
        try {
            // Query actual renewal data for risk analysis
            String whereClause = 'IsDeleted = false';
            if (String.isNotBlank(ou)) {
                whereClause += ' AND ou_name__c = \'' + String.escapeSingleQuotes(ou) + '\'';
            }
            if (String.isNotBlank(country)) {
                whereClause += ' AND work_location_country__c = \'' + String.escapeSingleQuotes(country) + '\'';
            }
            
            String query = 'SELECT Id, full_name__c, renewal_prod_nm__c, ou_name__c, ' +
                          'renewal_opty_amt__c, AE_Score__c, CloseDate__c ' +
                          'FROM Agent_Renewals__c WHERE ' + whereClause + ' LIMIT 50';
            
            List<Agent_Renewals__c> renewals = Database.query(query);
            
            if (renewals.isEmpty()) {
                response.explain.add('No renewal data found for risk analysis');
                return;
            }
            
            List<Map<String, Object>> renewalRisks = new List<Map<String, Object>>();
            Date today = Date.today();
            
            for (Agent_Renewals__c renewal : renewals) {
                Map<String, Object> risk = new Map<String, Object>();
                risk.put('aeName', renewal.full_name__c);
                risk.put('product', renewal.renewal_prod_nm__c);
                risk.put('ou', renewal.ou_name__c);
                
                // Calculate renewal risk based on weighted factors
                Decimal timeRisk = 0.0;
                Decimal aeRisk = 0.0;
                Decimal amountRisk = 0.0;
                
                // Time Proximity Risk (50% weight) - Risk increases as close date approaches
                if (renewal.CloseDate__c != null) {
                    Integer daysToClose = renewal.CloseDate__c.daysBetween(today);
                    if (daysToClose < 30) {
                        timeRisk = 0.9; // Very high risk
                    } else if (daysToClose < 60) {
                        timeRisk = 0.7; // High risk
                    } else if (daysToClose < 90) {
                        timeRisk = 0.5; // Medium risk
                    } else {
                        timeRisk = 0.3; // Low risk
                    }
                } else {
                    timeRisk = 0.6; // Medium-high risk if no close date
                }
                
                // AE Performance Risk (30% weight) - Risk increases with lower AE scores
                if (renewal.AE_Score__c != null) {
                    if (renewal.AE_Score__c < 3.0) {
                        aeRisk = 0.8; // High risk
                    } else if (renewal.AE_Score__c < 4.0) {
                        aeRisk = 0.5; // Medium risk
                    } else {
                        aeRisk = 0.2; // Low risk
                    }
                } else {
                    aeRisk = 0.6; // Medium risk if no AE score
                }
                
                // Deal Amount Risk (20% weight) - Slightly higher risk for larger deals
                if (renewal.renewal_opty_amt__c != null) {
                    if (renewal.renewal_opty_amt__c > 200000) {
                        amountRisk = 0.6; // Higher risk for large deals
                    } else if (renewal.renewal_opty_amt__c > 100000) {
                        amountRisk = 0.4; // Medium risk
                    } else {
                        amountRisk = 0.2; // Lower risk for smaller deals
                    }
                } else {
                    amountRisk = 0.5; // Medium risk if no amount
                }
                
                // Calculate weighted renewal risk
                Decimal renewalRisk = (timeRisk * 0.5) + (aeRisk * 0.3) + (amountRisk * 0.2);
                renewalRisk = Math.min(renewalRisk, 1.0); // Cap at 1.0
                
                risk.put('renewalRisk', renewalRisk);
                risk.put('renewalProbability', 1.0 - renewalRisk);
                
                // Determine risk tier
                String riskTier;
                if (renewalRisk >= 0.7) {
                    riskTier = 'HIGH';
                } else if (renewalRisk >= 0.4) {
                    riskTier = 'MEDIUM';
                } else {
                    riskTier = 'LOW';
                }
                risk.put('riskTier', riskTier);
                
                // Identify top risk factors
                List<String> topFactors = new List<String>();
                if (timeRisk >= 0.7) topFactors.add('Time proximity risk');
                if (aeRisk >= 0.7) topFactors.add('AE performance risk');
                if (amountRisk >= 0.5) topFactors.add('Large deal complexity');
                risk.put('topFactors', topFactors);
                
                risk.put('why', 'Renewal risk calculated based on time proximity (' + timeRisk + '), AE performance (' + aeRisk + '), and deal amount (' + amountRisk + ')');
                
                renewalRisks.add(risk);
            }
            
            response.renewalRisk = renewalRisks;
            
        } catch (Exception e) {
            response.explain.add('Renewal risk analysis unavailable: ' + e.getMessage());
        }
    }
    
    /**
     * Add AE performance analysis with real calculations
     */
    private static void addAEPerformanceAnalysis(EnhancedResponse response, String ou, String country, String analysisType) {
        try {
            // Determine which object to query based on analysis type
            String objectName;
            String productField;
            String amountField;
            
            if (analysisType == 'RENEWALS') {
                objectName = 'Agent_Renewals__c';
                productField = 'renewal_prod_nm__c';
                amountField = 'renewal_opty_amt__c';
            } else if (analysisType == 'CROSS_SELL') {
                objectName = 'Agent_Cross_Sell__c';
                productField = 'cross_sell_next_best_product__c';
                amountField = 'Amount__c';
            } else if (analysisType == 'UPSELL') {
                objectName = 'Agent_Upsell__c';
                productField = 'upsell_sub_category__c';
                amountField = 'Amount__c';
            } else {
                response.explain.add('Invalid analysis type for AE performance analysis');
                return;
            }
            
            // Build where clause
            String whereClause = 'IsDeleted = false';
            if (String.isNotBlank(ou)) {
                whereClause += ' AND ou_name__c = \'' + String.escapeSingleQuotes(ou) + '\'';
            }
            if (String.isNotBlank(country)) {
                whereClause += ' AND work_location_country__c = \'' + String.escapeSingleQuotes(country) + '\'';
            }
            
            // Query for OU averages
            String avgQuery = 'SELECT AVG(AE_Score__c) avgScore, AVG(Coverage__c) avgCoverage ' +
                             'FROM ' + objectName + ' WHERE ' + whereClause + ' AND AE_Score__c != null AND Coverage__c != null';
            
            List<AggregateResult> avgResults = Database.query(avgQuery);
            Decimal ouAvgScore = 0.0;
            Decimal ouAvgCoverage = 0.0;
            
            if (!avgResults.isEmpty()) {
                AggregateResult avgResult = avgResults[0];
                ouAvgScore = (Decimal) avgResult.get('avgScore');
                ouAvgCoverage = (Decimal) avgResult.get('avgCoverage');
            }
            
            // Query individual AE performance
            String aeQuery = 'SELECT full_name__c, ' + productField + ', ou_name__c, ' +
                            'AE_Score__c, Coverage__c, ' + amountField + ' ' +
                            'FROM ' + objectName + ' WHERE ' + whereClause + ' AND AE_Score__c != null AND Coverage__c != null ' +
                            'GROUP BY full_name__c, ' + productField + ', ou_name__c, AE_Score__c, Coverage__c, ' + amountField + ' ' +
                            'LIMIT 20';
            
            List<sObject> aeRecords = Database.query(aeQuery);
            
            if (aeRecords.isEmpty()) {
                response.explain.add('No AE performance data found for analysis');
                return;
            }
            
            List<Map<String, Object>> aePerformance = new List<Map<String, Object>>();
            
            for (sObject record : aeRecords) {
                Map<String, Object> perf = new Map<String, Object>();
                
                String aeName = (String) record.get('full_name__c');
                String product = (String) record.get(productField);
                String recordOU = (String) record.get('ou_name__c');
                Decimal aeScore = (Decimal) record.get('AE_Score__c');
                Decimal coverage = (Decimal) record.get('Coverage__c');
                Decimal amount = (Decimal) record.get(amountField);
                
                perf.put('aeName', aeName);
                perf.put('ou', recordOU);
                perf.put('product', product);
                
                // Calculate performance percentile relative to OU average
                Decimal performanceScore = 0.0;
                if (ouAvgScore > 0) {
                    performanceScore = (aeScore / ouAvgScore) * 100;
                }
                perf.put('performancePercentile', performanceScore);
                
                // Determine performance tier
                String performanceTier;
                List<String> coachingFlags = new List<String>();
                List<String> recommendations = new List<String>();
                
                if (performanceScore >= 120) {
                    performanceTier = 'Top Performer';
                    recommendations.add('Share best practices with team');
                    recommendations.add('Consider mentorship opportunities');
                } else if (performanceScore >= 100) {
                    performanceTier = 'Above Average';
                    recommendations.add('Continue current approach');
                    recommendations.add('Identify growth opportunities');
                } else if (performanceScore >= 80) {
                    performanceTier = 'Average';
                    coachingFlags.add('Performance below OU average');
                    recommendations.add('Focus on skill development');
                    recommendations.add('Increase activity levels');
                } else {
                    performanceTier = 'Needs Improvement';
                    coachingFlags.add('Significantly below OU average');
                    coachingFlags.add('Requires immediate attention');
                    recommendations.add('Intensive coaching program');
                    recommendations.add('Review pipeline generation');
                    recommendations.add('Skill assessment and training');
                }
                
                // Add coverage-specific coaching flags
                if (coverage != null && ouAvgCoverage > 0) {
                    Decimal coverageRatio = (coverage / ouAvgCoverage);
                    if (coverageRatio < 0.8) {
                        coachingFlags.add('Coverage below threshold');
                        recommendations.add('Increase prospecting activities');
                    }
                }
                
                // Add AE score specific flags
                if (aeScore != null && aeScore < 3.0) {
                    coachingFlags.add('AE Score needs improvement');
                    recommendations.add('Product training and certification');
                    recommendations.add('Sales methodology coaching');
                }
                
                perf.put('performanceTier', performanceTier);
                perf.put('coachingFlags', coachingFlags);
                perf.put('recommendations', recommendations);
                perf.put('why', 'AE performance calculated as ' + performanceScore + '% of OU average (Score: ' + aeScore + ', Coverage: ' + coverage + ')');
                
                aePerformance.add(perf);
            }
            
            response.aePerformance = aePerformance;
            
        } catch (Exception e) {
            response.explain.add('AE performance analysis unavailable: ' + e.getMessage());
        }
    }
    
    /**
     * Add PMF analysis with real calculations
     */
    private static void addPMFAnalysis(EnhancedResponse response, String ou, String country, String analysisType) {
        try {
            // Determine which object to query based on analysis type
            String objectName;
            String productField;
            String amountField;
            
            if (analysisType == 'RENEWALS') {
                objectName = 'Agent_Renewals__c';
                productField = 'renewal_prod_nm__c';
                amountField = 'renewal_opty_amt__c';
            } else if (analysisType == 'CROSS_SELL') {
                objectName = 'Agent_Cross_Sell__c';
                productField = 'cross_sell_next_best_product__c';
                amountField = 'Amount__c';
            } else if (analysisType == 'UPSELL') {
                objectName = 'Agent_Upsell__c';
                productField = 'upsell_sub_category__c';
                amountField = 'Amount__c';
            } else {
                response.explain.add('Invalid analysis type for PMF analysis');
                return;
            }
            
            // Build where clause
            String whereClause = 'IsDeleted = false';
            if (String.isNotBlank(ou)) {
                whereClause += ' AND ou_name__c = \'' + String.escapeSingleQuotes(ou) + '\'';
            }
            if (String.isNotBlank(country)) {
                whereClause += ' AND work_location_country__c = \'' + String.escapeSingleQuotes(country) + '\'';
            }
            
            // Query PMF data by product and segment
            String pmfQuery = 'SELECT ' + productField + ', macrosgment__c, primary_industry__c, ' +
                             'COUNT(Id) oppCount, SUM(' + amountField + ') totalAmount, AVG(Coverage__c) avgCoverage ' +
                             'FROM ' + objectName + ' WHERE ' + whereClause + ' AND ' + productField + ' != null ' +
                             'GROUP BY ' + productField + ', macrosgment__c, primary_industry__c ' +
                             'ORDER BY SUM(' + amountField + ') DESC LIMIT 15';
            
            List<AggregateResult> pmfResults = Database.query(pmfQuery);
            
            if (pmfResults.isEmpty()) {
                response.explain.add('No PMF data found for analysis');
                return;
            }
            
            List<Map<String, Object>> pmfFindings = new List<Map<String, Object>>();
            
            for (AggregateResult result : pmfResults) {
                Map<String, Object> pmf = new Map<String, Object>();
                
                String product = (String) result.get(productField);
                String segment = (String) result.get('macrosgment__c');
                String industry = (String) result.get('primary_industry__c');
                Integer oppCount = (Integer) result.get('oppCount');
                Decimal totalAmount = (Decimal) result.get('totalAmount');
                Decimal avgCoverage = (Decimal) result.get('avgCoverage');
                
                pmf.put('product', product);
                pmf.put('segment', segment);
                pmf.put('industry', industry);
                pmf.put('oppCount', oppCount);
                pmf.put('weightedAmount', totalAmount);
                
                // Calculate efficiency based on coverage and opportunity count
                // Higher coverage and more opportunities indicate better PMF
                Decimal efficiency = 0.0;
                if (avgCoverage != null && oppCount > 0) {
                    // Efficiency = (Coverage * 0.6) + (Opportunity Density * 0.4)
                    Decimal coverageScore = Math.min(avgCoverage * 100, 150) / 150; // Normalize to 0-1
                    Decimal opportunityDensity = Math.min(oppCount / 20.0, 1.0); // Normalize to 0-1
                    efficiency = (coverageScore * 0.6) + (opportunityDensity * 0.4);
                } else {
                    // Fallback calculation based on amount per opportunity
                    if (totalAmount != null && oppCount > 0) {
                        Decimal avgAmountPerOpp = totalAmount / oppCount;
                        efficiency = Math.min(avgAmountPerOpp / 100000, 1.0); // Normalize to 0-1
                    }
                }
                
                pmf.put('efficiency', efficiency);
                
                // Generate PMF insights
                String why = 'PMF analysis based on ';
                List<String> factors = new List<String>();
                
                if (efficiency >= 0.8) {
                    factors.add('high efficiency (' + (efficiency * 100).setScale(1) + '%)');
                    factors.add('strong market adoption');
                } else if (efficiency >= 0.6) {
                    factors.add('moderate efficiency (' + (efficiency * 100).setScale(1) + '%)');
                    factors.add('good market fit');
                } else if (efficiency >= 0.4) {
                    factors.add('below average efficiency (' + (efficiency * 100).setScale(1) + '%)');
                    factors.add('opportunities for improvement');
                } else {
                    factors.add('low efficiency (' + (efficiency * 100).setScale(1) + '%)');
                    factors.add('requires market strategy review');
                }
                
                factors.add(oppCount + ' opportunities');
                factors.add('$' + totalAmount.setScale(0) + ' total value');
                
                if (avgCoverage != null) {
                    factors.add(avgCoverage.setScale(2) + '% average coverage');
                }
                
                pmf.put('why', 'PMF analysis based on ' + String.join(factors, ', '));
                
                pmfFindings.add(pmf);
            }
            
            response.pmfFindings = pmfFindings;
            
        } catch (Exception e) {
            response.explain.add('PMF analysis unavailable: ' + e.getMessage());
        }
    }
    
    /**
     * Add health score analysis with real calculations
     */
    private static void addHealthScoreAnalysis(EnhancedResponse response, String ou, String country, String analysisType) {
        try {
            Map<String, Object> healthScore = new Map<String, Object>();
            
            // Calculate composite health score based on available intelligence features
            Decimal compositeScore = 0.0;
            List<String> contributingFactors = new List<String>();
            List<String> nextBestActions = new List<String>();
            Integer factorsCount = 0;
            
            // Factor 1: Renewal Risk Score (30% weight)
            if (!response.renewalRisk.isEmpty()) {
                Decimal avgRenewalProbability = 0.0;
                Integer riskCount = 0;
                
                for (Map<String, Object> risk : response.renewalRisk) {
                    Decimal probability = (Decimal) risk.get('renewalProbability');
                    if (probability != null) {
                        avgRenewalProbability += probability;
                        riskCount++;
                    }
                }
                
                if (riskCount > 0) {
                    avgRenewalProbability = avgRenewalProbability / riskCount;
                    compositeScore += avgRenewalProbability * 0.3 * 10; // Scale to 0-10
                    factorsCount++;
                    
                    if (avgRenewalProbability >= 0.7) {
                        contributingFactors.add('Strong renewal probability (' + (avgRenewalProbability * 100).setScale(1) + '%)');
                    } else if (avgRenewalProbability >= 0.5) {
                        contributingFactors.add('Moderate renewal probability (' + (avgRenewalProbability * 100).setScale(1) + '%)');
                    } else {
                        contributingFactors.add('Low renewal probability (' + (avgRenewalProbability * 100).setScale(1) + '%)');
                        nextBestActions.add('Focus on renewal risk mitigation');
                    }
                }
            }
            
            // Factor 2: AE Performance Score (25% weight)
            if (!response.aePerformance.isEmpty()) {
                Decimal avgPerformance = 0.0;
                Integer perfCount = 0;
                
                for (Map<String, Object> perf : response.aePerformance) {
                    Decimal percentile = (Decimal) perf.get('performancePercentile');
                    if (percentile != null) {
                        avgPerformance += percentile;
                        perfCount++;
                    }
                }
                
                if (perfCount > 0) {
                    avgPerformance = avgPerformance / perfCount;
                    compositeScore += (avgPerformance / 100) * 0.25 * 10; // Scale to 0-10
                    factorsCount++;
                    
                    if (avgPerformance >= 100) {
                        contributingFactors.add('Strong AE performance (' + avgPerformance.setScale(1) + '% of OU average)');
                    } else if (avgPerformance >= 80) {
                        contributingFactors.add('Average AE performance (' + avgPerformance.setScale(1) + '% of OU average)');
                    } else {
                        contributingFactors.add('Below average AE performance (' + avgPerformance.setScale(1) + '% of OU average)');
                        nextBestActions.add('Implement AE coaching and training programs');
                    }
                }
            }
            
            // Factor 3: PMF Score (20% weight)
            if (!response.pmfFindings.isEmpty()) {
                Decimal avgEfficiency = 0.0;
                Integer pmfCount = 0;
                
                for (Map<String, Object> pmf : response.pmfFindings) {
                    Decimal efficiency = (Decimal) pmf.get('efficiency');
                    if (efficiency != null) {
                        avgEfficiency += efficiency;
                        pmfCount++;
                    }
                }
                
                if (pmfCount > 0) {
                    avgEfficiency = avgEfficiency / pmfCount;
                    compositeScore += avgEfficiency * 0.2 * 10; // Scale to 0-10
                    factorsCount++;
                    
                    if (avgEfficiency >= 0.7) {
                        contributingFactors.add('Strong product-market fit (' + (avgEfficiency * 100).setScale(1) + '% efficiency)');
                    } else if (avgEfficiency >= 0.5) {
                        contributingFactors.add('Moderate product-market fit (' + (avgEfficiency * 100).setScale(1) + '% efficiency)');
                    } else {
                        contributingFactors.add('Weak product-market fit (' + (avgEfficiency * 100).setScale(1) + '% efficiency)');
                        nextBestActions.add('Review product positioning and market strategy');
                    }
                }
            }
            
            // Factor 4: Data Quality Score (15% weight) - Based on available data
            Decimal dataQualityScore = 0.0;
            Integer dataFactors = 0;
            
            // Check for data availability
            if (!response.renewalRisk.isEmpty()) {
                dataQualityScore += 3.0;
                dataFactors++;
            }
            if (!response.aePerformance.isEmpty()) {
                dataQualityScore += 3.0;
                dataFactors++;
            }
            if (!response.pmfFindings.isEmpty()) {
                dataQualityScore += 2.0;
                dataFactors++;
            }
            
            if (dataFactors > 0) {
                dataQualityScore = (dataQualityScore / 8.0) * 10; // Normalize to 0-10
                compositeScore += dataQualityScore * 0.15;
                factorsCount++;
                
                if (dataQualityScore >= 7.0) {
                    contributingFactors.add('Comprehensive data availability');
                } else if (dataQualityScore >= 4.0) {
                    contributingFactors.add('Limited data availability');
                    nextBestActions.add('Improve data collection and quality');
                } else {
                    contributingFactors.add('Insufficient data for analysis');
                    nextBestActions.add('Implement data collection initiatives');
                }
            }
            
            // Factor 5: Volume Score (10% weight) - Based on opportunity volume
            Decimal volumeScore = 0.0;
            Integer totalOpportunities = 0;
            
            for (Map<String, Object> pmf : response.pmfFindings) {
                Integer oppCount = (Integer) pmf.get('oppCount');
                if (oppCount != null) {
                    totalOpportunities += oppCount;
                }
            }
            
            if (totalOpportunities > 0) {
                if (totalOpportunities >= 50) {
                    volumeScore = 10.0;
                } else if (totalOpportunities >= 20) {
                    volumeScore = 7.0;
                } else if (totalOpportunities >= 10) {
                    volumeScore = 5.0;
                } else {
                    volumeScore = 3.0;
                }
                
                compositeScore += volumeScore * 0.1;
                factorsCount++;
                
                contributingFactors.add(totalOpportunities + ' total opportunities');
                
                if (totalOpportunities < 20) {
                    nextBestActions.add('Increase pipeline generation');
                }
            }
            
            // Normalize score if we have factors
            if (factorsCount > 0) {
                compositeScore = compositeScore / factorsCount;
            } else {
                compositeScore = 5.0; // Default neutral score
                contributingFactors.add('Limited data available for health assessment');
            }
            
            // Determine health tier
            String healthTier;
            if (compositeScore >= 8.0) {
                healthTier = 'Excellent';
                nextBestActions.add('Scale successful patterns');
                nextBestActions.add('Share best practices across teams');
            } else if (compositeScore >= 6.0) {
                healthTier = 'Healthy';
                nextBestActions.add('Continue current strategies');
                nextBestActions.add('Identify optimization opportunities');
            } else if (compositeScore >= 4.0) {
                healthTier = 'Moderate';
                nextBestActions.add('Implement improvement initiatives');
                nextBestActions.add('Review and adjust strategies');
            } else {
                healthTier = 'At Risk';
                nextBestActions.add('Immediate action required');
                nextBestActions.add('Comprehensive pipeline review');
                nextBestActions.add('Executive escalation');
            }
            
            healthScore.put('healthScore', compositeScore.setScale(1));
            healthScore.put('healthTier', healthTier);
            healthScore.put('contributingFactors', contributingFactors);
            healthScore.put('nextBestActions', nextBestActions);
            healthScore.put('why', 'Composite health score calculated from ' + factorsCount + ' factors: renewal probability, AE performance, PMF efficiency, data quality, and opportunity volume');
            
            response.healthScore = healthScore;
            
        } catch (Exception e) {
            response.explain.add('Health score analysis unavailable: ' + e.getMessage());
        }
    }
    
    /**
     * Add explainability
     */
    private static void addExplainability(EnhancedResponse response, String analysisType, String ou) {
        response.explain.add('Analysis performed for ' + analysisType + ' in ' + ou);
        response.explain.add('Intelligence features enabled: ' + getEnabledFeatures());
        response.explain.add('Data availability: Some fields may be missing, using fallback calculations');
    }
    
    /**
     * Get enabled features string
     */
    private static String getEnabledFeatures() {
        List<String> features = new List<String>();
        if (enableRenewalRisk) features.add('Renewal Risk');
        if (enableAEPerf) features.add('AE Performance');
        if (enablePMF) features.add('PMF');
        if (enableHealthScore) features.add('Health Score');
        return String.join(features, ', ');
    }
    
    /**
     * Convert enhanced response to markdown
     */
    private static String convertToMarkdown(EnhancedResponse response, String originalResult) {
        String markdown = originalResult;
        
        // Add intelligence sections
        if (!response.renewalRisk.isEmpty()) {
            markdown += '\n\n## 🎯 Renewal Risk Analysis\n\n';
            for (Map<String, Object> risk : response.renewalRisk) {
                markdown += '**' + risk.get('aeName') + '** (' + risk.get('product') + ')\n';
                markdown += '- Risk Score: ' + risk.get('renewalRisk') + '\n';
                markdown += '- Probability: ' + risk.get('renewalProbability') + '\n';
                markdown += '- Tier: ' + risk.get('riskTier') + '\n';
                markdown += '- Why: ' + risk.get('why') + '\n\n';
            }
        }
        
        if (!response.aePerformance.isEmpty()) {
            markdown += '\n\n## 👥 AE Performance Analysis\n\n';
            for (Map<String, Object> perf : response.aePerformance) {
                markdown += '**' + perf.get('aeName') + '** (' + perf.get('product') + ')\n';
                markdown += '- Percentile: ' + perf.get('performancePercentile') + '%\n';
                markdown += '- Tier: ' + perf.get('performanceTier') + '\n';
                markdown += '- Why: ' + perf.get('why') + '\n\n';
            }
        }
        
        if (!response.pmfFindings.isEmpty()) {
            markdown += '\n\n## 📊 Product-Market Fit Analysis\n\n';
            for (Map<String, Object> pmf : response.pmfFindings) {
                markdown += '**' + pmf.get('product') + '** in ' + pmf.get('segment') + ' (' + pmf.get('industry') + ')\n';
                markdown += '- Opportunities: ' + pmf.get('oppCount') + '\n';
                markdown += '- Weighted Amount: $' + pmf.get('weightedAmount') + '\n';
                markdown += '- Efficiency: ' + pmf.get('efficiency') + '\n';
                markdown += '- Why: ' + pmf.get('why') + '\n\n';
            }
        }
        
        if (!response.healthScore.isEmpty()) {
            markdown += '\n\n## 🏥 Pipeline Health Score\n\n';
            markdown += '**Health Score**: ' + response.healthScore.get('healthScore') + '/10\n';
            markdown += '**Tier**: ' + response.healthScore.get('healthTier') + '\n';
            markdown += '**Why**: ' + response.healthScore.get('why') + '\n\n';
        }
        
        if (!response.explain.isEmpty()) {
            markdown += '\n\n## 💡 Explainability\n\n';
            for (String explanation : response.explain) {
                markdown += '- ' + explanation + '\n';
            }
        }
        
        return markdown;
    }
}
