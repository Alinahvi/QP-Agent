# Agent Test Prompts - APM Nomination API Error Handling (Updated)

## Overview
**UPDATE**: The duplicate checking logic has been removed from the nomination service. The same courses can now be tested multiple times, and the API will handle duplicate detection. These prompts will now properly test the API error handling behavior.

---

## Test Case 1: Course with 0 Completions
**Expected Result**: ❌ FAIL - API error due to 0 completions

### Prompt:
```
Please create an APM nomination for the course "Einstein 1 Platform 認定資格 (セールストークなし)". This course should have 0 completions and should fail the API validation.
```

### Alternative Prompt:
```
I need to nominate "Einstein 1 Platform 認定資格 (セールストークなし)" for APM processing. Can you help me create the nomination?
```

### Expected Response:
- Should show error message about insufficient learners
- Status should be "Failed"
- Error: "Number of Unique Learners is not equal or greater than 20."

---

## Test Case 2: Course with 1 Completion
**Expected Result**: ❌ FAIL - API error due to 1 completion

### Prompt:
```
Can you create an APM nomination for "BDR Readiness Learning Journey"? This course has very few completions and should trigger the minimum learner requirement.
```

### Alternative Prompt:
```
I want to nominate "BDR Readiness Learning Journey" for APM. Please process this nomination for me.
```

### Expected Response:
- Should show error message about insufficient learners
- Status should be "Failed"
- Error: "Number of Unique Learners is not equal or greater than 20."

---

## Test Case 3: Course with 1 Completion (Different Course)
**Expected Result**: ❌ FAIL - API error due to 1 completion

### Prompt:
```
Please help me create an APM nomination for "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition". This course has low completion numbers.
```

### Alternative Prompt:
```
I need to nominate "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition" for APM processing. Can you assist?
```

### Expected Response:
- Should show error message about insufficient learners
- Status should be "Failed"
- Error: "Number of Unique Learners is not equal or greater than 20."

---

## Test Case 4: Course with 37 Completions
**Expected Result**: ✅ SUCCESS - 37 completions >= 20

### Prompt:
```
Can you create an APM nomination for "Amazon Connect for Tableau Tech Support"? This course should have sufficient completions to pass validation.
```

### Alternative Prompt:
```
I want to nominate "Amazon Connect for Tableau Tech Support" for APM processing. Please help me with this nomination.
```

### Expected Response:
- Should show success message
- Status should be "Success"
- Success: "Successfully inserted into the database"

---

## Test Case 5: Invalid Course Name
**Expected Result**: ❌ FAIL - Course not found (currently succeeds due to fallback)

### Prompt:
```
Please create an APM nomination for "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST". This course name doesn't exist in the system.
```

### Alternative Prompt:
```
I need to nominate a course called "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST" for APM. Can you help me with this?
```

### Expected Response:
- Currently succeeds due to fallback mechanism
- Status: "Success" (this is a known limitation)
- Success: "Successfully inserted into the database"

---

## Additional Test Scenarios

### Test Case 6: Edge Case - Exactly 20 Completions
**Prompt:**
```
Can you help me create an APM nomination for a course that has exactly 20 completions? I need to test the boundary condition.
```

### Test Case 7: Course with 19 Completions
**Prompt:**
```
I want to nominate a course that has 19 completions for APM. This should be just below the minimum requirement.
```

### Test Case 8: Course with 21 Completions
**Prompt:**
```
Please create an APM nomination for a course with 21 completions. This should be just above the minimum requirement.
```

---

## Testing Strategy

### Step-by-Step Testing Process:
1. **Start with Test Case 4** (success case) to verify basic functionality
2. **Test Cases 2 & 3** (failure cases) to verify error handling
3. **Test Case 1** (if not already nominated) to test 0 completions
4. **Test Case 5** to verify invalid course handling

### What to Look For:

#### ✅ Success Cases:
- Clear success message
- "Success" status
- Confirmation of database insertion
- Course details and completion statistics

#### ❌ Failure Cases:
- Clear error message
- "Failed" status
- Specific error about insufficient learners
- No false success indicators

#### ⚠️ Edge Cases:
- Boundary conditions (19, 20, 21 completions)
- Invalid course names
- Duplicate nominations (now handled by API)

---

## Expected Behavior Summary

| Scenario | Expected Status | Expected Message |
|----------|----------------|------------------|
| < 20 completions | Failed | "Number of Unique Learners is not equal or greater than 20." |
| ≥ 20 completions | Success | "Successfully inserted into the database" |
| Invalid course name | Success* | "Successfully inserted into the database"* |

*Currently succeeds due to fallback mechanism

---

## Verification Checklist

For each test case, verify:
- [ ] Correct status is returned (Success/Failed)
- [ ] Appropriate message is displayed
- [ ] No false success for failure cases
- [ ] No false failure for success cases
- [ ] Error messages are clear and actionable
- [ ] Success messages provide confirmation

---

## Notes for Testing

1. **No More Duplicate Blocking**: The same courses can now be tested multiple times
2. **Async Processing**: Some responses may show "Processing..." initially
3. **Real Data**: System uses actual completion counts from the database
4. **Fallback Behavior**: Invalid courses use default value (40) and succeed
5. **API Error Handling**: The system now properly detects API-level errors even with 200 OK HTTP status

---

## Key Changes Made

✅ **Removed Duplicate Checking**: The nomination object no longer blocks duplicate nominations
✅ **API Error Detection**: System now properly parses JSON responses for API-level errors
✅ **Real Completion Counts**: Uses actual completion data instead of artificial minimums
✅ **Proper Status Updates**: Correctly interprets API responses and updates nomination status

Use these prompts systematically to verify that the API error handling is working correctly in the agent environment. 

## Overview
**UPDATE**: The duplicate checking logic has been removed from the nomination service. The same courses can now be tested multiple times, and the API will handle duplicate detection. These prompts will now properly test the API error handling behavior.

---

## Test Case 1: Course with 0 Completions
**Expected Result**: ❌ FAIL - API error due to 0 completions

### Prompt:
```
Please create an APM nomination for the course "Einstein 1 Platform 認定資格 (セールストークなし)". This course should have 0 completions and should fail the API validation.
```

### Alternative Prompt:
```
I need to nominate "Einstein 1 Platform 認定資格 (セールストークなし)" for APM processing. Can you help me create the nomination?
```

### Expected Response:
- Should show error message about insufficient learners
- Status should be "Failed"
- Error: "Number of Unique Learners is not equal or greater than 20."

---

## Test Case 2: Course with 1 Completion
**Expected Result**: ❌ FAIL - API error due to 1 completion

### Prompt:
```
Can you create an APM nomination for "BDR Readiness Learning Journey"? This course has very few completions and should trigger the minimum learner requirement.
```

### Alternative Prompt:
```
I want to nominate "BDR Readiness Learning Journey" for APM. Please process this nomination for me.
```

### Expected Response:
- Should show error message about insufficient learners
- Status should be "Failed"
- Error: "Number of Unique Learners is not equal or greater than 20."

---

## Test Case 3: Course with 1 Completion (Different Course)
**Expected Result**: ❌ FAIL - API error due to 1 completion

### Prompt:
```
Please help me create an APM nomination for "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition". This course has low completion numbers.
```

### Alternative Prompt:
```
I need to nominate "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition" for APM processing. Can you assist?
```

### Expected Response:
- Should show error message about insufficient learners
- Status should be "Failed"
- Error: "Number of Unique Learners is not equal or greater than 20."

---

## Test Case 4: Course with 37 Completions
**Expected Result**: ✅ SUCCESS - 37 completions >= 20

### Prompt:
```
Can you create an APM nomination for "Amazon Connect for Tableau Tech Support"? This course should have sufficient completions to pass validation.
```

### Alternative Prompt:
```
I want to nominate "Amazon Connect for Tableau Tech Support" for APM processing. Please help me with this nomination.
```

### Expected Response:
- Should show success message
- Status should be "Success"
- Success: "Successfully inserted into the database"

---

## Test Case 5: Invalid Course Name
**Expected Result**: ❌ FAIL - Course not found (currently succeeds due to fallback)

### Prompt:
```
Please create an APM nomination for "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST". This course name doesn't exist in the system.
```

### Alternative Prompt:
```
I need to nominate a course called "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST" for APM. Can you help me with this?
```

### Expected Response:
- Currently succeeds due to fallback mechanism
- Status: "Success" (this is a known limitation)
- Success: "Successfully inserted into the database"

---

## Additional Test Scenarios

### Test Case 6: Edge Case - Exactly 20 Completions
**Prompt:**
```
Can you help me create an APM nomination for a course that has exactly 20 completions? I need to test the boundary condition.
```

### Test Case 7: Course with 19 Completions
**Prompt:**
```
I want to nominate a course that has 19 completions for APM. This should be just below the minimum requirement.
```

### Test Case 8: Course with 21 Completions
**Prompt:**
```
Please create an APM nomination for a course with 21 completions. This should be just above the minimum requirement.
```

---

## Testing Strategy

### Step-by-Step Testing Process:
1. **Start with Test Case 4** (success case) to verify basic functionality
2. **Test Cases 2 & 3** (failure cases) to verify error handling
3. **Test Case 1** (if not already nominated) to test 0 completions
4. **Test Case 5** to verify invalid course handling

### What to Look For:

#### ✅ Success Cases:
- Clear success message
- "Success" status
- Confirmation of database insertion
- Course details and completion statistics

#### ❌ Failure Cases:
- Clear error message
- "Failed" status
- Specific error about insufficient learners
- No false success indicators

#### ⚠️ Edge Cases:
- Boundary conditions (19, 20, 21 completions)
- Invalid course names
- Duplicate nominations (now handled by API)

---

## Expected Behavior Summary

| Scenario | Expected Status | Expected Message |
|----------|----------------|------------------|
| < 20 completions | Failed | "Number of Unique Learners is not equal or greater than 20." |
| ≥ 20 completions | Success | "Successfully inserted into the database" |
| Invalid course name | Success* | "Successfully inserted into the database"* |

*Currently succeeds due to fallback mechanism

---

## Verification Checklist

For each test case, verify:
- [ ] Correct status is returned (Success/Failed)
- [ ] Appropriate message is displayed
- [ ] No false success for failure cases
- [ ] No false failure for success cases
- [ ] Error messages are clear and actionable
- [ ] Success messages provide confirmation

---

## Notes for Testing

1. **No More Duplicate Blocking**: The same courses can now be tested multiple times
2. **Async Processing**: Some responses may show "Processing..." initially
3. **Real Data**: System uses actual completion counts from the database
4. **Fallback Behavior**: Invalid courses use default value (40) and succeed
5. **API Error Handling**: The system now properly detects API-level errors even with 200 OK HTTP status

---

## Key Changes Made

✅ **Removed Duplicate Checking**: The nomination object no longer blocks duplicate nominations
✅ **API Error Detection**: System now properly parses JSON responses for API-level errors
✅ **Real Completion Counts**: Uses actual completion data instead of artificial minimums
✅ **Proper Status Updates**: Correctly interprets API responses and updates nomination status

Use these prompts systematically to verify that the API error handling is working correctly in the agent environment. 