# Enhanced Lifecycle Management V2

## 🎯 **Overview**
Enhanced Lifecycle Management V2 is a comprehensive Salesforce agent action system that provides intelligent content search with advanced lifecycle management capabilities, including enrollment metrics, completion rates, and CSAT integration.

## ✨ **Key Features**

### **🔍 Intelligent Search**
- **Smart Routing**: Automatic detection of ACT vs Consensus content based on user utterances
- **Search Term Extraction**: Intelligent extraction of core product names from natural language
- **Multiple Search Modes**: AUTO, ACT, CONSENSUS, and BOTH modes for flexible searching

### **📊 Lifecycle Management**
- **Enrollment Analytics**: Total learner counts per course
- **Completion Tracking**: Completion rates and percentages
- **Performance Analysis**: High-performing vs low-performing content identification
- **Optimization Recommendations**: AI-driven suggestions for content improvement

### **⭐ CSAT Integration**
- **Customer Satisfaction Scores**: Integration with Course__c.CSAT__c field
- **Quality Assessment**: Low-satisfaction content identification (<3.0 CSAT)
- **Performance Correlation**: CSAT scores displayed in top results
- **Quality Recommendations**: CSAT-based content optimization suggestions

## 🏗️ **Architecture**

```
ANAgentContentSearchHandlerV2 (Handler)
├── Intelligent Routing Logic
├── Search Term Extraction
├── Lifecycle Analysis Engine
└── CSAT Integration

ANAgentContentSearchServiceV2 (Service)
├── ACT Content Search
├── Consensus Demo Search
├── Enrollment Data Population
└── CSAT Score Integration
```

## 📦 **Package Contents**

### **Apex Classes**
- `ANAgentContentSearchHandlerV2.cls` - Main handler with enhanced lifecycle management
- `ANAgentContentSearchServiceV2.cls` - Service layer with CSAT integration

### **Documentation**
- `DEPLOYMENT_MANIFEST.md` - Complete deployment guide
- `IMPLEMENTATION_GUIDE.md` - Detailed implementation instructions
- `CSAT_INTEGRATION_GUIDE.md` - CSAT field integration guide

### **Deployment Scripts**
- `deploy.sh` - Automated deployment script
- `test-deployment.sh` - Comprehensive testing script

## 🚀 **Quick Start**

### **1. Prerequisites**
- Salesforce org with Course__c, Asset__c, Curriculum__c, and Assigned_Course__c objects
- Course__c.CSAT__c field (optional, for CSAT integration)
- SF CLI configured with org access

### **2. Deployment**
```bash
# Make deployment script executable
chmod +x deployment/deploy.sh

# Run deployment
./deployment/deploy.sh
```

### **3. Testing**
```bash
# Run comprehensive tests
./deployment/test-deployment.sh
```

## 📊 **Enhanced Output Example**

```
Found 110 ACT learning content records:

📊 Course Performance Summary:
• Total enrollment across all courses: 15,039 learners
• Total completions: 12,345 learners
• Average completion rate: 82%
• Average CSAT score: 4.0/5.0 (39 courses with ratings)

🎯 Lifecycle Analysis:
• High-performing courses (≥50 learners, ≥25% completion): 28
• Low-enrollment courses (<20 learners): 6
• Low-completion courses (<10% completion): 6
• Low-satisfaction courses (<3.0 CSAT): 2

⚠️ Content Optimization Opportunities:
• Consider promoting or updating 6 low-enrollment courses
• Review and improve 6 courses with low completion rates
• Redesign 2 courses with low satisfaction scores

✅ Strong Content:
• 28 courses showing excellent performance - consider expanding similar content

📚 Top Results:
• Data Cloud Overview (1,970 learners, 57% completion, 4.2/5.0 CSAT)
• Sales Cloud Fundamentals (1,558 learners, 68% completion, 4.5/5.0 CSAT)
• Marketing Cloud Essentials (1,147 learners, 50% completion, 3.8/5.0 CSAT)
```

## 🔧 **Configuration**

### **Lifecycle Thresholds**
- **Low Enrollment**: <20 learners
- **Low Completion**: <10% completion rate
- **Low CSAT**: <3.0 satisfaction score
- **High Performing**: ≥50 learners + ≥25% completion

### **Routing Keywords**
- **Consensus**: consensus, demo, demo video, video, demo pack, presentation
- **ACT**: act, course, training, learning, curriculum, asset

## 📈 **Performance Metrics**

### **Before Enhancement**
- Basic enrollment tracking
- Limited lifecycle insights
- No satisfaction metrics

### **After Enhancement**
- Comprehensive enrollment, completion, and CSAT metrics
- Detailed lifecycle analysis with optimization recommendations
- Rich formatted output with actionable insights
- CSAT-based quality assessment

## 🧪 **Testing**

### **Test Scenarios**
1. **Basic Search**: Test fundamental search functionality
2. **Lifecycle Analysis**: Test comprehensive lifecycle management
3. **CSAT Integration**: Test customer satisfaction score integration
4. **Search Term Extraction**: Test intelligent term extraction
5. **Performance**: Test with large datasets

### **Sample Test Query**
```json
{
  "searchTerm": "Tableau",
  "searchMode": "ACT",
  "userUtterance": "Do a life cycle analysis on the ACT content related to Tableau and tell me which content I need to remove and which content I need to modify and which I need to keep. Use enrollment and completion rate as major KPIs for this analysis"
}
```

## 🔍 **Troubleshooting**

### **Common Issues**
1. **CSAT Field Missing**: Ensure Course__c.CSAT__c field exists
2. **Deployment Order**: Deploy service before handler
3. **Test Failures**: Check field permissions and data availability

### **Debug Steps**
1. Check field existence and permissions
2. Verify data availability
3. Run test deployment script
4. Review debug logs

## 📞 **Support**

For issues or questions:
1. Check deployment logs
2. Verify field availability
3. Test with sample data
4. Review documentation

## 📝 **Changelog**

### **Version 2.0** (October 1, 2025)
- ✅ Enhanced lifecycle management with CSAT integration
- ✅ Improved search term extraction
- ✅ Rich formatted output with metrics
- ✅ Comprehensive optimization recommendations
- ✅ Performance analytics and insights

### **Version 1.0** (Previous)
- Basic content search functionality
- Simple routing logic
- Basic enrollment tracking

---

**Enhanced Lifecycle Management V2**  
**Version**: 2.0  
**Created**: October 1, 2025  
**Status**: Production Ready ✅
