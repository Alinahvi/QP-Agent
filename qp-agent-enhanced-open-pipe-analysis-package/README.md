# Enhanced Open Pipe Analysis System

## Overview
This package contains the complete Enhanced Open Pipe Analysis system for Salesforce, providing intelligent pipeline analysis with context-aware resolution, rich formatting, and advanced data quality insights.

## 🚀 Key Features

### Core Capabilities
- **Context-Aware Resolution**: Automatically resolves ambiguous terms (OU names, products, countries, segments, stages)
- **Rich Message Formatting**: Engaging output with emojis, structured sections, and actionable insights
- **Smart Field Selection**: Prioritizes relevant fields based on analysis type
- **Data Quality Assessment**: Identifies missing data and provides smart suggestions
- **Outlier Detection**: Statistical analysis to identify unusual stagnation patterns
- **Territory Analysis**: Comprehensive OU-level pipeline insights

### Analysis Types Supported
- **Territory Analysis**: OU-level pipeline breakdown with risk assessment
- **Product Analysis**: Product performance and diversity analysis
- **AE Analysis**: Individual sales rep performance metrics
- **Stage Analysis**: Pipeline progression and stagnation insights

## 📁 Package Contents

### Apex Classes
- `ANAgentOpenPipeAnalysisV3Handler.cls` - Main handler for invocable actions
- `ANAgentOpenPipeAnalysisV3ServiceEnhanced.cls` - Enhanced service layer with all business logic
- `ANAgentNamingNormalizer.cls` - Utility class for context-aware term resolution
- `OpenPipeTestEnhanced1.cls` - Comprehensive test class
- `ANAgentNamingNormalizerTest.cls` - Unit tests for naming normalizer

### Custom Object
- `Agent_Open_Pipe__c` - Main data object with 58K+ records containing:
  - Opportunity details (name, stage, amount, AE score)
  - Product information (L2 family, SKU level)
  - Territory data (OU, country, segment, industry)
  - Stagnation tracking (days in stage)

### Documentation
- `docs/Agent_Open_Pipe__c_schema.json` - Complete object schema
- `docs/DEPLOYMENT_GUIDE.md` - Step-by-step deployment instructions
- `docs/API_REFERENCE.md` - Complete API documentation
- `docs/TROUBLESHOOTING.md` - Common issues and solutions

## 🔧 Field Mapping

### Core Fields
| Field Name | Type | Description | Usage |
|------------|------|-------------|-------|
| `OU_NAME__C` | Text | Operating Unit | Territory Analysis |
| `OPEN_PIPE_PROD_NM__C` | Text | Product Name (SKU) | Product Analysis |
| `OPEN_PIPE_APM_L2__C` | Text | Product Family | Product Analysis (Default) |
| `WORK_LOCATION_COUNTRY__C` | Text | Customer Country | Territory Analysis |
| `MACROSGMENT__C` | Text | Customer Segment | Territory Analysis |
| `PRIMARY_INDUSTRY__C` | Text | Customer Industry | Territory Analysis |
| `OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C` | Currency | Deal Amount | Financial Analysis |
| `OPEN_PIPE_OPTY_STG_NM__C` | Text | Pipeline Stage | Stage Analysis |
| `FULL_NAME__C` | Text | AE Name | AE Analysis |
| `OPEN_PIPE_AE_SCORE__C` | Number | AE Confidence Score | AE Analysis |
| `OPEN_PIPE_OPTY_DAYS_IN_STAGE__C` | Number | Days in Current Stage | Stagnation Analysis |

### Context-Aware Resolution
The system automatically handles variations in:
- **OU Names**: "AMER ACC" → "AMER-ACC" → "Amer ACC"
- **Product Names**: "Tableau" → Context-aware resolution to specific products
- **Countries**: "US" → "United States" → "United States of America"
- **Segments**: "Enterprise" → "ENTR" → "ENT"
- **Stages**: "Stage 2" → "Stage 2 - Determining Problem, Impact, Ideal"

## 🚀 Quick Start

### 1. Deployment
```bash
# Deploy to your org
sf project deploy start --source-dir force-app --target-org your-org-alias
```

### 2. Test the System
```bash
# Run tests
sf apex run test --class-names OpenPipeTestEnhanced1 --target-org your-org-alias
```

### 3. Sample Usage
```apex
// Territory Analysis
Map<String, Object> params = new Map<String, Object>{
    'ou' => 'AMER ACC',
    'analysisType' => 'territory'
};
String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
```

## 📊 Sample Output

### Territory Analysis Example
```
🎯 **AMER ACC Territory Analysis**

**Executive Summary**
- Total Pipeline: $45.2M across 1,247 opportunities
- Average AE Score: 7.2/10 (Strong confidence)
- Top Risk: 23% of deals in Stage 2 for >30 days

**Analysis Summary**
- Product Diversity: High (12 product families)
- Geographic Spread: 15 countries
- Industry Mix: Technology (45%), Financial Services (23%)

**Critical Risk Factors**
⚠️ Stagnation Alert: 89 deals stuck in Stage 2 for >45 days
⚠️ Low AE Confidence: 156 deals with AE score <5

**Recommended Next Steps**
1. Review 89 stagnant Stage 2 deals
2. Focus on 156 low-confidence opportunities
3. Leverage strong Tableau pipeline ($12.3M)
```

## 🔍 Advanced Features

### Outlier Detection
- **Statistical Methods**: IQR and Z-score analysis
- **Stagnation Thresholds**: Stage-specific limits
- **Risk Identification**: Forgotten deals and data quality issues

### Smart Suggestions
- **Data Availability**: Warns about missing fields
- **Alternative Analysis**: Suggests fallback approaches
- **Field Recommendations**: Prioritizes relevant fields

### Error Handling
- **Governor Limits**: Dynamic query limits
- **Data Quality**: Comprehensive validation
- **User Guidance**: Actionable error messages

## 🛠️ Troubleshooting

### Common Issues
1. **"No data found"** → Check OU name variations
2. **Governor limits** → Refine search criteria
3. **Missing fields** → Verify object permissions

### Debug Mode
```apex
// Enable debug logging
System.debug('Analysis params: ' + params);
String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
System.debug('Analysis result: ' + result);
```

## 📈 Performance

### Query Optimization
- **Dynamic Limits**: Based on analysis type
- **Field Selection**: Only required fields
- **Indexed Fields**: Optimized for common filters

### Governor Limits
- **Territory Analysis**: Up to 10,000 records
- **Product Analysis**: Up to 5,000 records
- **AE Analysis**: Up to 2,000 records

## 🔒 Security

### Data Access
- **Sharing Model**: ReadWrite
- **Field Security**: Respects field-level security
- **User Context**: Runs in user's security context

### Permissions Required
- Read access to `Agent_Open_Pipe__c`
- Read access to `Learner_Profile__c`
- Execute access to Apex classes

## 📝 Version History

### v3.0 Enhanced (Current)
- ✅ Context-aware resolution
- ✅ Rich message formatting
- ✅ Outlier detection
- ✅ Smart field selection
- ✅ Data quality assessment

### v2.0 (Previous)
- Basic pipeline analysis
- Simple filtering
- Standard output format

## 🤝 Support

For issues or questions:
1. Check the troubleshooting guide
2. Review the API documentation
3. Run the test classes
4. Check Salesforce debug logs

## 📄 License

This package is part of the Salesforce Agent Intelligence system and follows the organization's internal licensing terms.

---

**Last Updated**: October 2024  
**Version**: 3.0 Enhanced  
**Compatibility**: Salesforce API 58.0+
