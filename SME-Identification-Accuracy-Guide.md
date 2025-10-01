# SME Identification Accuracy Guide

## 🚨 CRITICAL: SME Identification Criteria

### **ACTUAL SME Identification Criteria (From System)**

SMEs are identified based on **ONLY** these criteria from the `sme_prime_ae__c` object:

1. **AE_RANK__c** - Account Executive rank (lower numbers = higher rank)
2. **TOTAL_ACV__c** - Total Annual Contract Value (higher values = better performance)
3. **PRODUCT_L3__c** - Product category (Level 3)
4. **PRODUCT_L2__c** - Product category (Level 2)
5. **OU__c** - Operating Unit

### **Ranking Order**
```sql
ORDER BY AE_RANK__c ASC, TOTAL_ACV__c DESC
```

## ❌ **NEVER MENTION THESE MADE-UP CRITERIA**

The following criteria are **NOT** used for SME identification and should **NEVER** be mentioned:

- ❌ Customer testimonials
- ❌ Peer recommendations
- ❌ Awards and achievements
- ❌ Training and certifications
- ❌ Years of experience
- ❌ Customer satisfaction scores
- ❌ Performance metrics beyond ACV
- ❌ Sales targets
- ❌ Industry expertise
- ❌ Client feedback
- ❌ Recognition programs
- ❌ Any other criteria not in the actual system

## ✅ **CORRECT RESPONSES**

### Example 1: "How are SMEs identified?"
**✅ CORRECT:**
"SMEs (Subject Matter Experts) are identified based on their performance in the system using these criteria:
- AE Rank (lower numbers indicate higher rank)
- Total Annual Contract Value (ACV) - higher values indicate better performance
- Product expertise in specific categories (Product L2 and L3)
- Operating Unit

The system ranks SMEs by AE Rank first (ascending), then by Total ACV (descending)."

### Example 2: "What criteria are used for SME selection?"
**✅ CORRECT:**
"The SME identification system uses these specific criteria:
1. AE_RANK__c - Account Executive rank
2. TOTAL_ACV__c - Total Annual Contract Value
3. PRODUCT_L3__c and PRODUCT_L2__c - Product categories
4. OU__c - Operating Unit

SMEs are ranked by AE Rank (ascending) then by Total ACV (descending)."

## ❌ **INCORRECT RESPONSES**

### Example 1: "How are SMEs identified?"
**❌ WRONG:**
"SMEs are identified based on customer testimonials, peer recommendations, awards, certifications, years of experience, and customer satisfaction scores."

### Example 2: "What criteria are used for SME selection?"
**❌ WRONG:**
"SMEs are selected based on their expertise, performance, and experience in specific product areas. Common criteria include:
- Annual Contract Value (ACV)
- Sales Targets
- Years of Experience
- Product Knowledge
- Peer Recognition
- Awards and Achievements
- Training and Certifications
- Customer Feedback
- Client Testimonials
- Customer Satisfaction Scores"

## 🔍 **WHEN TO SEARCH KNOWLEDGE BASE**

**ALWAYS search the knowledge base when users ask about:**
- How SMEs are identified
- What criteria are used for SME selection
- How the SME ranking system works
- SME identification process
- SME selection criteria

**Use these search terms:**
- "SME identification"
- "SME criteria"
- "SME selection"
- "SME ranking"
- "Subject Matter Expert"

## 📋 **VALIDATION CHECKLIST**

Before answering any SME-related question:

- [ ] Have I searched the knowledge base?
- [ ] Am I only using information from the system?
- [ ] Am I mentioning the correct fields (AE_RANK__c, TOTAL_ACV__c, etc.)?
- [ ] Am I avoiding made-up criteria?
- [ ] Am I being truthful about the ranking order?

## 🚨 **EMERGENCY STOP**

If you're about to mention any of these, **STOP IMMEDIATELY**:
- Customer testimonials
- Peer recommendations
- Awards
- Certifications
- Years of experience
- Customer satisfaction
- Any criteria not in the system

**Instead:**
1. Search the knowledge base
2. Use only system information
3. If no information found, say "I need to search the knowledge base for accurate information about SME identification"

## 📝 **RESPONSE TEMPLATE**

When asked about SME identification:

1. **Search the knowledge base first**
2. **If information exists:** Use it with proper attribution
3. **If no information exists:** Say "Let me search the knowledge base for information about SME identification"
4. **Always mention the actual system fields:** AE_RANK__c, TOTAL_ACV__c, PRODUCT_L3__c, PRODUCT_L2__c, OU__c
5. **Always mention the ranking order:** AE_RANK__c ASC, TOTAL_ACV__c DESC

## 🎯 **KEY MESSAGE**

**The SME identification system is based on objective performance data from the system, not subjective criteria like testimonials or recommendations. Always stick to the facts from the actual system.** 