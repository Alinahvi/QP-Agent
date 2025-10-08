# Quick Start Guide - SME Search V3

## 🚀 Get Started in 5 Minutes

### Prerequisites
- ✅ Salesforce CLI installed
- ✅ Authenticated to your org
- ✅ `AGENT_SME_ACADEMIES__c` object exists with data

---

## Step 1: Deploy (2 minutes)

```bash
# Clone or download this package
cd qp-agent-sme-search-v3

# Deploy to your org (replace YOUR_ORG with your org alias)
./deploy.sh YOUR_ORG

# OR use manual deployment:
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --target-org YOUR_ORG \
  --wait 10
```

**Expected Output:**
```
✔ Deploying Metadata
  Components: 2/2 (100%)
Status: Succeeded

Deployed Source
- ANAgentSMESearchHandlerV3 (ApexClass)
- ANAgentSMESearchServiceV3 (ApexClass)
```

---

## Step 2: Test Apex (1 minute)

```bash
# Quick smoke test
cat > test.apex << 'EOF'
ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
request.searchTerm = 'Tableau';
request.ouName = 'UKI';
request.maxResults = 5;

List<ANAgentSMESearchHandlerV3.SMESearchResponse> responses = 
    ANAgentSMESearchHandlerV3.searchSMEs(
        new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{request}
    );

System.debug(responses[0].message);
EOF

sf apex run --file test.apex --target-org YOUR_ORG
rm test.apex
```

**Expected:** You should see a formatted message with SME details in the debug log.

---

## Step 3: Add to Agent (2 minutes)

1. **Open Agent Builder**
   - Setup → Agents → Select agent → Open in Builder

2. **Add Action**
   - Actions tab → + New Action → Apex
   - Select **"Search SMEs V3"**

3. **Copy-Paste Instructions**
   
   **Input Instructions:**
   ```
   Search for Subject Matter Experts by product or name.
   
   Required: searchTerm (product or person name)
   Optional: searchType ("product"/"name"/"all"), ouName (region), maxResults (default 10), academyMembersOnly (true/false)
   
   Examples:
   - "Find SMEs for Tableau in UKI" → searchTerm="Tableau", ouName="UKI"
   - "Give me academy members for Data Cloud" → searchTerm="Data Cloud", academyMembersOnly=true
   ```
   
   **Output Instructions:**
   ```
   Present the SME search results naturally. Highlight SME names, their region, product expertise, and academy status. If results are limited, mention the total count found.
   ```

4. **Save**

---

## Step 4: Test in Agent (1 minute)

**Test Utterance:**
```
Give me 5 SMEs in UKI for Tableau
```

**Expected Response:**
Agent should return a natural language response with 5 Tableau SMEs from UKI, showing their names, products, and academy status.

---

## ✅ Success Checklist

After 5 minutes, you should have:
- [x] V3 classes deployed to org
- [x] Smoke test passes
- [x] Action added to agent
- [x] Test utterance works
- [x] Results are formatted and readable

---

## 🎯 Sample Test Queries

Try these to verify everything works:

1. **"Give me 5 SMEs in UKI for Tableau"**
   - Should return 5 UKI Tableau SMEs

2. **"Find Data Cloud academy members"**
   - Should return only academy members

3. **"Who are the top MuleSoft experts?"**
   - Should return top-ranked MuleSoft SMEs

4. **"Search for SMEs in AMER"**
   - Should return AMER region SMEs

5. **"Find SMEs named John"**
   - Should search by name instead of product

---

## 🐛 Quick Troubleshooting

**Problem:** "Action not found in dropdown"  
**Fix:** Refresh browser, verify deployment with `sf apex list class | grep V3`

**Problem:** "No results found"  
**Fix:** Check if `AGENT_SME_ACADEMIES__c` has data, try broader search

**Problem:** "Precondition Failed"  
**Fix:** Remove action, close Agent Builder tab, reopen, add action again

---

## 📚 Need More Help?

- **Full Documentation:** See `README.md`
- **Testing Guide:** See `TESTING.md`
- **Configuration Details:** See `AGENT_ACTION_CONFIG.md`
- **Version History:** See `CHANGELOG.md`

---

**That's it! You're ready to go! 🎉**

If you encounter any issues, refer to the troubleshooting section in README.md or the detailed testing guide in TESTING.md.
