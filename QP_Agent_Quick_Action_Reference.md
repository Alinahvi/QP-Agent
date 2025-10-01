# QP Agent - Quick Action Reference Guide

**Quick decision guide for selecting the right agent action based on user utterances and business purpose.**

---

## 🎯 **ACTION SELECTION MATRIX**

| **User Utterance Type** | **Action to Use** | **Purpose** | **Key Keywords** |
|-------------------------|-------------------|-------------|------------------|
| **Sales & Pipeline Analysis** | `ANAGENT Open Pipe Analysis V3` | Analyze sales opportunities, ACV, product performance | "ACV", "pipeline", "sales opportunities", "products", "territory", "revenue", "forecast" |
| **Learning Content Search** | `ANAgent Search Content V2` | Find courses, training materials, curriculum with enrollment data | "courses", "training", "learning", "curriculum", "education", "completion rates", "enrollment data" |
| **Demo Video Search** | `ANAgent Search Content (Consensus)` | Find demo videos and demonstrations | "demo", "demo video", "demonstration", "show me demo", "video demo" |
| **Effectiveness Analysis** | `ANAgent Search Content (Consensus or ACT)` | Find best/most effective courses and programs | "best", "most effective", "top performing", "highest quality", "most successful" |
| **KPI & Performance Analysis** | `ANAGENT KPI Analysis V5` | Analyze KPIs, territory performance, AE metrics | "KPIs", "performance", "metrics", "territory analysis", "AE performance", "ramp status" |
| **Expert & Knowledge Search** | `ANAgent Search SMEs` | Find subject matter experts and knowledge | "SME", "expert", "subject matter expert", "knowledge", "expertise" |
| **Upsell Opportunities** | `ABAGENT Upsell Analysis` | Analyze upsell opportunities and patterns | "upsell", "expansion", "upgrade", "additional products" |
| **Cross-Sell Opportunities** | `ABAGENT Cross-Sell Analysis` | Analyze cross-sell opportunities and next best products | "cross-sell", "next best product", "additional products", "cross-sell patterns" |
| **Renewal Analysis** | `ABAGENT Renewals Analysis` | Analyze renewal opportunities and contract renewals | "renewals", "contract renewal", "renewal opportunities", "retention" |
| **APM Nominations** | `AN Agent: Create APM Nomination V2` | Create nominations for APM system | "nominate", "APM", "submit course", "course nomination" |

---

uct from open pipe ACV
e this t 
### **Sales & Revenue Queries**
- *"Show me top 5 products in AMER ENTR territory by ACV"* → **Open Pipe Analysis V3**
- *"Which products have highest ACV in Canada?"* → **Open Pipe Analysis V3**
- *"Sales opportunities in EMEA region"* → **Open Pipe Analysis V3**
- *"Top performing products by revenue"* → **Open Pipe Analysis V3**

### **Learning & Training Queries**
- *"Show me courses related to financial industries"* → **Search Content V2**
- *"Find training materials for Tableau"* → **Search Content V2**
- *"Search for curriculum about sales training"* → **Search Content V2**
- *"What courses are available for data analytics?"* → **Search Content V2**
- *"Show me ACT courses related to data cloud with enrollment and completion data"* → **Search Content V2**

### **Demo Video Queries**
- *"Show me demo videos on data cloud"* → **Search Content (Consensus)**
- *"Find demo videos for consensus"* → **Search Content (Consensus)**
- *"Show me the most recent demo videos"* → **Search Content (Consensus)**
- *"I need demo videos on sales cloud"* → **Search Content (Consensus)**

### **Effectiveness & Quality Queries**
- *"Give me best course on data cloud"* → **Search Content (Consensus or ACT)**
- *"Show me most effective training programs"* → **Search Content (Consensus or ACT)**
- *"What are the top performing courses"* → **Search Content (Consensus or ACT)**
- *"Highest quality learning programs"* → **Search Content (Consensus or ACT)**

### **Performance & KPI Queries**
- *"Compare average calls between Brazil and US territories"* → **KPI Analysis V5**
- *"What's the average ACV for AEs with tenure >= 6 months in US?"* → **KPI Analysis V5**
- *"Show pipeline generation by OU, top 5"* → **KPI Analysis V5**
- *"Analyze new hire performance in EMEA"* → **KPI Analysis V5**

### **Expert & Knowledge Queries**
- *"Find SMEs for Data Cloud"* → **Search SMEs**
- *"Who are the experts in Tableau?"* → **Search SMEs**
- *"Subject matter experts for financial services"* → **Search SMEs**

### **Sales Opportunity Queries**
- *"Analyze upsell opportunities in LATAM"* → **Upsell Analysis**
- *"Show cross-sell patterns by industry"* → **Cross-Sell Analysis**
- *"Renewal opportunities in EMEA"* → **Renewals Analysis**

### **APM Nomination Queries**
- *"Create an APM nomination for 'Tableau Fundamentals'"* → **Create APM Nomination V2**
- *"Nominate 'Sales Cloud Basics' for APM"* → **Create APM Nomination V2**
- *"Submit 'Data Analytics Course' to APM system"* → **Create APM Nomination V2**

---

## ⚡ **QUICK DECISION RULES**

### **1. Contains ACV, Pipeline, or Sales Keywords?**
→ **Use Open Pipe Analysis V3**

### **2. Contains Demo Video Keywords?**
→ **Use Search Content (Consensus)**

### **3. Contains Course, Training, or Learning Keywords?**
→ **Check for effectiveness keywords first**
- **If "best", "most effective", "top performing"** → **Use Consensus Search**
- **If regular content search** → **Use Search Content V2**

### **4. Contains KPI, Performance, or Metrics Keywords?**
→ **Use KPI Analysis V5**

### **5. Contains Expert, SME, or Knowledge Keywords?**
→ **Use Search SMEs**

### **6. Contains Upsell, Cross-sell, or Renewal Keywords?**
→ **Use appropriate ABAGENT action**

### **7. Contains Nominate or APM Keywords?**
→ **Use Create APM Nomination V2**

---

## 🚨 **CRITICAL ROUTING MISTAKES TO AVOID**

| **❌ WRONG** | **✅ CORRECT** | **Reason** |
|--------------|----------------|------------|
| Using Content Search for "top 5 products by ACV" | Use Open Pipe Analysis V3 | ACV = sales data, not learning content |
| Using Open Pipe for "courses about Tableau" | Use Search Content V2 | Courses = learning content, not sales data |
| Using Content Search for "best courses" | Use Consensus Search | "Best" = effectiveness analysis |
| Using KPI Analysis for "sales opportunities" | Use Open Pipe Analysis V3 | Sales opportunities = pipeline data |
| Using Open Pipe for "SMEs for Data Cloud" | Use Search SMEs | SMEs = expert search, not sales data |

---

## 📊 **DATA SOURCE QUICK REFERENCE**

| **Action** | **Primary Data Source** | **What It Analyzes** |
|------------|------------------------|---------------------|
| **Open Pipe Analysis V3** | `prime_ae_amer_plan__c` | Sales opportunities, ACV, pipeline data |
| **Search Content V2** | `Course__c`, `Asset__c`, `Curriculum__c` | Learning content, courses, training materials |
| **Search Content (Consensus)** | Consensus dataset | Demo videos, demonstrations, consensus content |
| **KPI Analysis V5** | `AGENT_OU_PIPELINE_V2__c` | KPIs, performance metrics, territory analysis |
| **Search SMEs** | `AGENT_SME_ACADEMIES__c` | Subject matter experts, knowledge, expertise |
| **Upsell Analysis** | `Agent_Upsell__c` | Upsell opportunities, expansion patterns |
| **Cross-Sell Analysis** | `Agent_Cross_Sell__c` | Cross-sell opportunities, next best products |
| **Renewals Analysis** | `Agent_Renewals__c` | Renewal opportunities, contract renewals |
| **APM Nomination V2** | `apm_nomination_v2__c` | APM nominations, course submissions |

---

**💡 Remember: When in doubt, ask the user to clarify their intent rather than guessing the wrong action!**
