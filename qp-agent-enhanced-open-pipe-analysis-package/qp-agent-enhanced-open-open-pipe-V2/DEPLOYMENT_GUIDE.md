# Deployment Guide - ANAgent Recommended Learning

## Quick Start

```bash
# 1. Deploy Apex classes
sf project deploy start \
  --source-dir force-app/main/default/classes/ANAgentRecommendedLearning*.cls \
  --target-org YOUR_ORG_ALIAS

# 2. Run tests
sf apex run test \
  --class-names ANAgentRecommendedLearningService_Tests \
  --target-org YOUR_ORG_ALIAS \
  --result-format human \
  --code-coverage

# 3. Verify deployment
sf apex run --file test_deployment_verification.apex --target-org YOUR_ORG_ALIAS
```

## Prerequisites

### Required Custom Objects

Your Salesforce org must have these custom objects:

1. **Recommended_Learning__c**
   - Fields:
     - `Learner_Profile__c` (Lookup to Learner_Profile__c)
     - `Course__c` (Lookup to Course__c)
     - `Asset__c` (Lookup to Asset__c)
     - `Curriculum__c` (Lookup to Curriculum__c)
     - `Status__c` (Picklist)
     - `SEED_Recommended__c` (Checkbox)
     - `SEED_Source__c` (Text)
     - `Expiration_Date__c` (Date)
     - `Audience__c` (Lookup to Audience__c)
     - `OU_Leader__c` (Lookup to User)
     - `Key__c` (Formula: TEXT(Learner_Profile__c) + '-' + TEXT(Course/Asset/Curriculum))

2. **Learner_Profile__c**
   - Basic setup with Name field

3. **Course__c**
   - Basic setup with Name field

4. **Asset__c**
   - Basic setup with Name field

5. **Curriculum__c**
   - Basic setup with Name field

6. **Audience__c**
   - Basic setup with Name field

### Required Permissions

- Read/Create/Edit on `Recommended_Learning__c`
- Read on `Learner_Profile__c`, `Course__c`, `Asset__c`, `Curriculum__c`, `Audience__c`
- Read on `User` (for OU_Leader__c)

## Step-by-Step Deployment

### Step 1: Backup Current Code (if exists)

```bash
# Export existing Apex classes
sf project retrieve start \
  --metadata ApexClass:ANAgentRecommendedLearning* \
  --target-org YOUR_ORG_ALIAS
```

### Step 2: Deploy Apex Classes

```bash
# Deploy all three classes
sf project deploy start \
  --source-dir force-app/main/default/classes/ANAgentRecommendedLearningInvocable.cls \
  --source-dir force-app/main/default/classes/ANAgentRecommendedLearningService.cls \
  --source-dir force-app/main/default/classes/ANAgentRecommendedLearningService_Tests.cls \
  --target-org YOUR_ORG_ALIAS
```

Or deploy entire directory:

```bash
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --target-org YOUR_ORG_ALIAS
```

### Step 3: Run Unit Tests

```bash
# Run tests with coverage
sf apex run test \
  --class-names ANAgentRecommendedLearningService_Tests \
  --target-org YOUR_ORG_ALIAS \
  --result-format human \
  --code-coverage \
  --output-dir test-results
```

**Expected Output:**
```
=== Test Results
Outcome: Passed
Tests Ran: 11
Pass Rate: 100%
```

### Step 4: Verify Deployment

Create file `test_deployment_verification.apex`:

```apex
// Verify classes are deployed
System.debug('Testing ANAgentRecommendedLearning deployment...');

// Get sample data
List<Learner_Profile__c> learners = [SELECT Id FROM Learner_Profile__c LIMIT 1];
List<Course__c> courses = [SELECT Id FROM Course__c LIMIT 1];

if (learners.isEmpty() || courses.isEmpty()) {
    System.debug('ERROR: No test data. Create at least 1 Learner Profile and 1 Course.');
} else {
    // Test invocable
    ANAgentRecommendedLearningInvocable.Request req = new ANAgentRecommendedLearningInvocable.Request();
    req.learnerProfileId = learners[0].Id;
    req.courseId = courses[0].Id;
    req.seedSource = 'Deployment Verification Test';
    req.status = 'Learning Assigned';
    
    List<ANAgentRecommendedLearningInvocable.Response> responses = 
        ANAgentRecommendedLearningInvocable.createOrUpdateRecommendations(
            new List<ANAgentRecommendedLearningInvocable.Request>{ req }
        );
    
    if (!responses.isEmpty()) {
        String message = responses[0].message;
        System.debug('Response: ' + message);
        
        if (message.contains('status')) {
            System.debug('✅ DEPLOYMENT SUCCESSFUL! JSON response received.');
        } else {
            System.debug('❌ DEPLOYMENT ISSUE: Unexpected response format.');
        }
    }
}
```

Run verification:

```bash
sf apex run --file test_deployment_verification.apex --target-org YOUR_ORG_ALIAS
```

### Step 5: Configure Permission Set

```bash
# Create permission set (if not exists)
sf data create record --sobject PermissionSet \
  --values "Name=AgentIntegrationUser Label='Agent Integration User'" \
  --target-org YOUR_ORG_ALIAS
```

Add Apex class to permission set:

1. Setup → Permission Sets → Agent Integration User
2. Apex Class Access → Edit
3. Add: `ANAgentRecommendedLearningInvocable`
4. Save

Or use metadata:

```xml
<!-- force-app/main/default/permissionsets/AgentIntegrationUser.permissionset-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <classAccesses>
        <apexClass>ANAgentRecommendedLearningInvocable</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <hasActivationRequired>false</hasActivationRequired>
    <label>Agent Integration User</label>
</PermissionSet>
```

Deploy permission set:

```bash
sf project deploy start \
  --source-dir force-app/main/default/permissionsets \
  --target-org YOUR_ORG_ALIAS
```

### Step 6: Assign Permission Set to Agent User

```bash
# Get agent user ID
sf data query --query "SELECT Id, Username FROM User WHERE Username = 'agent@yourorg.com'" \
  --target-org YOUR_ORG_ALIAS

# Assign permission set
sf data create record --sobject PermissionSetAssignment \
  --values "PermissionSetId=YOUR_PERMSET_ID AssigneeId=YOUR_USER_ID" \
  --target-org YOUR_ORG_ALIAS
```

### Step 7: Configure in Agent Builder

1. Go to Setup → Agent Builder
2. Select your agent
3. Actions → Add Action → Apex
4. Search: "ANAgentRecommendedLearning"
5. Select: `createOrUpdateRecommendations`
6. Configure inputs:
   - `learnerProfileId` → Map to agent output
   - `courseId` → Map to agent output
   - `seedSource` → Set to descriptive text
   - Other fields as needed
7. Configure output:
   - Map `message` field to agent context
8. Save action

### Step 8: Test in Agent UI

1. Open Agent UI
2. Test prompt: "Create a Tableau learning recommendation for learner profile [ID]"
3. Verify:
   - ✅ No crashes
   - ✅ JSON response received
   - ✅ Record created in Recommended_Learning__c

## Rollback Procedure

If deployment fails:

### 1. Restore Previous Version

```bash
# If you backed up (Step 1)
sf project deploy start \
  --source-dir backup-classes \
  --target-org YOUR_ORG_ALIAS
```

### 2. Delete New Classes

```bash
sf project delete source \
  --metadata ApexClass:ANAgentRecommendedLearningInvocable \
  --metadata ApexClass:ANAgentRecommendedLearningService \
  --metadata ApexClass:ANAgentRecommendedLearningService_Tests \
  --target-org YOUR_ORG_ALIAS
```

### 3. Remove from Agent

1. Agent Builder → Actions
2. Remove "Create/Update Recommended Learning" action
3. Save

## Troubleshooting

### Issue: Deployment Fails with "Field does not exist"

**Cause:** Custom object/field missing

**Solution:**
1. Verify all required custom objects exist
2. Check field API names match exactly
3. Deploy custom objects first, then Apex

### Issue: Tests Fail with "No test data"

**Cause:** No Learner Profiles or Courses in org

**Solution:**
```bash
# Create test data
sf data create record --sobject Learner_Profile__c \
  --values "Name='Test Learner'" \
  --target-org YOUR_ORG_ALIAS

sf data create record --sobject Course__c \
  --values "Name='Test Course'" \
  --target-org YOUR_ORG_ALIAS
```

### Issue: Agent shows "Method not found"

**Cause:** Permission set not assigned or class not visible

**Solution:**
1. Verify permission set assigned to agent user
2. Check class is `global` (it is in this implementation)
3. Verify `@InvocableMethod` annotation present

### Issue: "System.LimitException" still occurring

**Cause:** Old version still deployed

**Solution:**
1. Verify latest version deployed
2. Check debug logs for which class is being called
3. Redeploy with `--ignore-warnings` flag

## Post-Deployment Validation

### Checklist

- [ ] All 3 Apex classes deployed
- [ ] Unit tests passing (11/11)
- [ ] Code coverage ≥75%
- [ ] Permission set configured
- [ ] Permission set assigned to agent user
- [ ] Action configured in Agent Builder
- [ ] Test in Agent UI successful
- [ ] JSON response format validated
- [ ] Error handling tested (invalid ID)
- [ ] Bulk processing tested (multiple records)

### Validation Tests

Run these test scenarios in Agent UI:

1. **Single valid record**
   - Expected: `"status": "success"`

2. **Invalid learner profile ID**
   - Expected: `"status": "failed"` with clear error

3. **Mix of valid and invalid**
   - Expected: `"status": "partial_success"` with both records and errors

4. **Duplicate request**
   - Expected: `"action": "updated"` (idempotent)

## Monitoring

### Debug Logs

Enable debug logs for agent user:

1. Setup → Debug Logs
2. New → User = Agent User, Debug Level = FINEST
3. Monitor for:
   - No exceptions thrown
   - JSON responses returned
   - Reasonable execution time (<5s)

### Dashboard

Create dashboard to monitor:
- Recommended_Learning__c records created per day
- Success rate (created/updated vs errors)
- Most common error types
- Performance metrics

## Support

### Getting Help

1. Check troubleshooting section above
2. Review debug logs
3. Run test class to isolate issue
4. Create GitHub issue with:
   - Debug logs
   - Input parameters
   - Expected vs actual output
   - Org edition

### Useful Commands

```bash
# Get debug logs
sf apex tail log --target-org YOUR_ORG_ALIAS

# Query recent recommendations
sf data query --query "SELECT Id, Learner_Profile__c, Status__c, SEED_Source__c, CreatedDate FROM Recommended_Learning__c ORDER BY CreatedDate DESC LIMIT 10" --target-org YOUR_ORG_ALIAS

# Check code coverage
sf apex get test --test-run-id TEST_RUN_ID --target-org YOUR_ORG_ALIAS

# Validate deployment without deploying
sf project deploy start --source-dir force-app --check-only --target-org YOUR_ORG_ALIAS
```

## Next Steps

After successful deployment:

1. Train agent with example prompts
2. Document use cases for your organization
3. Create monitoring dashboard
4. Set up alerts for errors
5. Plan regular reviews of success/failure rates
