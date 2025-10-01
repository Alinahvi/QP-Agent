# Production Testing Guide - Enhanced KPI Analysis System

## 🚀 **Ready for Production Testing**

The enhanced KPI Analysis system has been deployed and is ready for testing. Use this guide to verify that both the Growth Factor smart logic and enhanced field mapping are working correctly.

## 🧪 **Test Case 1: Growth Factor Smart Logic**

### **Test Scenario**
**User Request**: "show me top 3 growth factors in USA"

### **Expected Agent Input**
```json
{
  "filterCriteria": "country='US'",
  "limitN": 3,
  "groupBy": "AE",
  "metricKey": "PG"
}
```

### **Expected System Behavior**
1. **Smart Logic Detection**: System should detect Growth Factor intent
2. **Parameter Auto-Correction**: 
   - `metricKey: "PG"` → `"GROWTH_FACTOR"`
   - `groupBy: "AE"` → `"GROWTH_FACTOR"`
3. **Successful Analysis**: Should return Growth Factor analysis with top 3 factors

### **Success Criteria**
- ✅ System auto-corrects parameters without error
- ✅ Returns Growth Factor analysis (not Pipeline analysis)
- ✅ Shows top 3 growth factors by frequency
- ✅ Includes descriptions for each growth factor

---

## 🧪 **Test Case 2: RAMP_STATUS Analysis with API Field Names**

### **Test Scenario**
**User Request**: "show me avg calls and meetings that fast rampers in AMER have"

### **Expected Agent Input**
```json
{
  "filterCriteria": "RAMP_STATUS__c='Fast Ramper' AND OU_NAME__c='AMER'",
  "metricKey": "CALLS",
  "groupBy": "RAMP_STATUS"
}
```

### **Expected System Behavior**
1. **Field Mapping**: System should convert API field names
   - `RAMP_STATUS__c` → `ramp_status__c`
   - `OU_NAME__c` → `ou_name__c`
2. **Successful Query**: Should find records with fast rampers in AMER
3. **Proper Grouping**: Should group by ramp status and calculate averages

### **Success Criteria**
- ✅ System processes API field names without error
- ✅ Returns actual data (not 0 records)
- ✅ Shows average calls for fast rampers in AMER
- ✅ Groups results by ramp status correctly

---

## 🧪 **Test Case 3: Mixed Input Format Handling**

### **Test Scenario**
**User Request**: "show me top 5 industries by ACV in US"

### **Expected Agent Input**
```json
{
  "filterCriteria": "WORK_LOCATION_COUNTRY__c='US'",
  "limitN": 5,
  "groupBy": "INDUSTRY",
  "metricKey": "ACV"
}
```

### **Expected System Behavior**
1. **Field Mapping**: System should convert API field names
   - `WORK_LOCATION_COUNTRY__c` → `work_location_country__c`
2. **Normal Processing**: Should work as standard KPI analysis
3. **Results**: Should show top 5 industries by ACV in US

### **Success Criteria**
- ✅ System handles API field names correctly
- ✅ Returns top 5 industries by ACV
- ✅ No field mapping errors
- ✅ Results grouped by industry correctly

---

## 🧪 **Test Case 4: Growth Factor Analysis with Correct Parameters**

### **Test Scenario**
**User Request**: "show me top 5 growth factors in US and Germany"

### **Expected Agent Input**
```json
{
  "filterCriteria": "country='US' OR country='Germany'",
  "limitN": 5,
  "metricKey": "GROWTH_FACTOR",
  "groupBy": "GROWTH_FACTOR"
}
```

### **Expected System Behavior**
1. **Direct Processing**: No auto-correction needed
2. **Field Mapping**: Convert user-friendly keys to actual field names
   - `country` → `work_location_country__c`
3. **Growth Factor Analysis**: Count unique growth factors across both countries

### **Success Criteria**
- ✅ System processes correct parameters without auto-correction
- ✅ Returns growth factors from both US and Germany
- ✅ Shows top 5 by frequency
- ✅ Includes descriptions for each factor

---

## 🧪 **Test Case 5: RAMP_STATUS Analysis with Various Field Formats (Recently Fixed)**

### **Test Scenario**
**User Request**: "which portion of AEs in US are fast rampers, which portion are slow rampers?"

### **Expected Agent Input**
```json
{
  "filterCriteria": "country='US' AND RAMP_STATUS='Fast Ramper'",
  "metricKey": "CALLS",
  "groupBy": "RAMP_STATUS"
}
```

### **Expected System Behavior**
1. **Field Mapping**: System should convert field names without underscores
   - `RAMP_STATUS` → `ramp_status__c`
   - `country` → `work_location_country__c`
2. **Successful Query**: Should find records with fast rampers in US
3. **Proper Grouping**: Should group by ramp status and calculate portions

### **Success Criteria**
- ✅ System processes field names without underscores correctly
- ✅ Returns actual data (not 0 records)
- ✅ Shows portion of fast vs slow rampers in US
- ✅ Groups results by ramp status correctly

---

## 🧪 **Test Case 6: Tenure Analysis with TIME_SINCE_ONBOARDING__c Field (FIXED - Field Verified)**

### **Test Scenario**
**User Request**: "can you do the same analysis only for AEs who joined between 9 months and 3 month ago?"

### **Expected Agent Input**
```json
{
  "filterCriteria": "country='US' AND TIME_SINCE_ONBOARDING__c >= 3 AND TIME_SINCE_ONBOARDING__c <= 9",
  "metricKey": "CALLS",
  "groupBy": "RAMP_STATUS"
}
```

### **Expected System Behavior**
1. **Field Mapping**: System should convert tenure field names correctly
   - `TIME_SINCE_ONBOARDING__c` → `time_since_onboarding__c`
   - `country` → `work_location_country__c`
2. **Successful Query**: Should find records with AEs who joined between 3-9 months ago
3. **Proper Grouping**: Should group by ramp status and show distribution

### **Success Criteria**
- ✅ System processes TIME_SINCE_ONBOARDING__c field correctly
- ✅ Returns actual data (not 0 records)
- ✅ Shows ramp status distribution for AEs with 3-9 months tenure
- ✅ Groups results by ramp status correctly

---

## 🔍 **How to Test**

### **1. Use the Agent Interface**
- Ask the agent the exact questions from the test scenarios
- Monitor the agent's input parameters
- Verify the system's response

### **2. Check System Logs**
- Look for any error messages
- Verify field mapping is working
- Check if smart logic is triggering

### **3. Verify Results**
- Confirm data is returned (not 0 records)
- Verify grouping and calculations are correct
- Check that field names are properly mapped

---

## 🚨 **Common Issues to Watch For**

### **Field Mapping Issues**
- **Symptom**: "No such column" errors in SOQL
- **Cause**: API field names not being converted properly
- **Check**: Verify `parseFilterCriteria` method is working

### **Smart Logic Issues**
- **Symptom**: Wrong metric/groupBy not being auto-corrected
- **Cause**: Smart logic conditions not being met
- **Check**: Verify `limitN` is set and parameters match conditions

### **Permission Issues**
- **Symptom**: "Insufficient access rights" errors
- **Cause**: Permission set not properly configured
- **Check**: Verify `AEAE_AN_Agents_CRUD` permission set is assigned

---

## 📊 **Expected Performance**

### **Response Time**
- **Simple Queries**: < 2 seconds
- **Complex Queries**: < 5 seconds
- **Growth Factor Analysis**: < 3 seconds

### **Memory Usage**
- **Field Mapping**: < 1KB additional memory
- **Smart Logic**: Negligible overhead
- **Overall Impact**: < 5% performance degradation

---

## ✅ **Success Checklist**

### **Growth Factor Smart Logic**
- [ ] Auto-corrects wrong parameters
- [ ] Detects Growth Factor intent correctly
- [ ] Returns proper Growth Factor analysis
- [ ] No errors in parameter processing

### **Enhanced Field Mapping**
- [ ] Handles API field names (`RAMP_STATUS__c`)
- [ ] Handles field names without underscores (`RAMP_STATUS`)
- [ ] Handles tenure fields (`TIME_SINCE_ONBOARDING__c`)
- [ ] Converts to proper SOQL field names
- [ ] Works with user-friendly keys
- [ ] No field mapping errors
- [ ] Only maps fields proven to exist in object

### **Overall System**
- [ ] All test cases pass
- [ ] No new errors introduced
- [ ] Performance remains acceptable
- [ ] User experience improved

---

## 🎯 **Next Steps After Testing**

### **If All Tests Pass**
1. **Monitor Production Usage** for 1-2 weeks
2. **Collect User Feedback** on improved experience
3. **Document Success Metrics** and improvements
4. **Plan Future Enhancements**

### **If Issues Found**
1. **Document Specific Problems** with steps to reproduce
2. **Check System Logs** for error details
3. **Review Field Mappings** for completeness
4. **Adjust Smart Logic** if needed

---

## 📞 **Support Information**

### **For Technical Issues**
- Check the `ENHANCED_KPI_ANALYSIS_SYSTEM_SUMMARY.md` for implementation details
- Review the deployed Apex classes for any compilation errors
- Verify permission set assignments

### **For User Experience Issues**
- Test with different user scenarios
- Verify agent is sending expected parameters
- Check if smart logic conditions are too restrictive/loose

---

**Testing Status**: 🟡 **READY TO START**  
**Expected Duration**: 1-2 hours for comprehensive testing  
**Success Criteria**: All 4 test cases pass without errors 