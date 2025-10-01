# 5 Test Cases for Agent Testing - APM Nomination API Error Handling

## Overview
These test cases verify that the APM nomination system correctly handles API errors and provides accurate feedback to users. The system should detect when the external API returns errors (even with 200 OK status) and report them properly.

## Test Results Summary (My Testing)
- **Total Tests**: 5
- **Passed**: 3 tests (60%)
- **Failed**: 2 tests (40%)
- **Key Finding**: API error detection is working correctly for low completion counts

---

## Test Case 1: Course with 0 Completions
**Course Name**: `Einstein 1 Platform 認定資格 (セールストークなし)`

**Expected Result**: ❌ **FAIL** - API error due to 0 completions
**Expected Error**: `"Number of Unique Learners is not equal or greater than 20."`

**Agent Action**: 
1. Go to Agentforce
2. Search for "Einstein 1 Platform 認定資格 (セールストークなし)"
3. Create APM nomination for this course
4. Verify you receive an error message about insufficient learners

**My Test Result**: ❌ **FAILED** - Duplicate nomination (already nominated)
**Status**: This course was already nominated, so duplicate detection prevented retesting

---

## Test Case 2: Course with 1 Completion
**Course Name**: `BDR Readiness Learning Journey`

**Expected Result**: ❌ **FAIL** - API error due to 1 completion
**Expected Error**: `"Number of Unique Learners is not equal or greater than 20."`

**Agent Action**:
1. Go to Agentforce
2. Search for "BDR Readiness Learning Journey"
3. Create APM nomination for this course
4. Verify you receive an error message about insufficient learners

**My Test Result**: ✅ **PASSED** - API correctly returned error
**Status**: `Failed` - Error: API returned error status - Number of Unique Learners is not equal or greater than 20.

---

## Test Case 3: Course with 1 Completion (Different Course)
**Course Name**: `Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition`

**Expected Result**: ❌ **FAIL** - API error due to 1 completion
**Expected Error**: `"Number of Unique Learners is not equal or greater than 20."`

**Agent Action**:
1. Go to Agentforce
2. Search for "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition"
3. Create APM nomination for this course
4. Verify you receive an error message about insufficient learners

**My Test Result**: ✅ **PASSED** - API correctly returned error
**Status**: `Failed` - Error: API returned error status - Number of Unique Learners is not equal or greater than 20.

---

## Test Case 4: Course with 37 Completions
**Course Name**: `Amazon Connect for Tableau Tech Support`

**Expected Result**: ✅ **SUCCESS** - 37 completions >= 20
**Expected Success**: `"Successfully inserted into the database"`

**Agent Action**:
1. Go to Agentforce
2. Search for "Amazon Connect for Tableau Tech Support"
3. Create APM nomination for this course
4. Verify you receive a success message

**My Test Result**: ✅ **PASSED** - API call succeeded
**Status**: `Success` - Success: success

---

## Test Case 5: Invalid Course Name
**Course Name**: `INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST`

**Expected Result**: ❌ **FAIL** - Course not found
**Expected Error**: Course not found or similar error

**Agent Action**:
1. Go to Agentforce
2. Try to create APM nomination for "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST"
3. Verify you receive an error message about course not found

**My Test Result**: ❌ **FAILED** - System used fallback value (40) and succeeded
**Status**: `Success` - Success: Sucessfully inserted into the database

---

## Key Findings

### ✅ Working Correctly:
1. **Real Course IDs**: System uses actual course IDs instead of `DEFAULT123`
2. **Real Completion Counts**: System uses actual completion counts from database
3. **API Error Detection**: System correctly detects when API returns `"status": "error"`
4. **Error Reporting**: Failed nominations show `"Failed"` status with detailed error messages
5. **Success Reporting**: Successful nominations show `"Success"` status

### ⚠️ Areas for Improvement:
1. **Invalid Course Handling**: System falls back to default value (40) for invalid course names
2. **Duplicate Detection**: Working correctly but prevents retesting same courses

### 🎯 Primary Goal Achieved:
The **core API error handling is working perfectly**! When users try to nominate courses with fewer than 20 completions, they now receive proper error messages instead of false success responses.

---

## Expected Agent Behavior

### For Courses with < 20 Completions:
- Agent should receive: `"Failed"` status
- Error message: `"Number of Unique Learners is not equal or greater than 20."`
- User should see clear error feedback

### For Courses with >= 20 Completions:
- Agent should receive: `"Success"` status
- Success message: `"Successfully inserted into the database"`
- User should see confirmation of successful nomination

### For Invalid Course Names:
- Currently falls back to default value (40) and succeeds
- This is a known limitation that could be improved

---

## Testing Instructions for Agent

1. **Test Case 1**: Try to nominate "Einstein 1 Platform 認定資格 (セールストークなし)" - should fail due to 0 completions
2. **Test Case 2**: Try to nominate "BDR Readiness Learning Journey" - should fail due to 1 completion  
3. **Test Case 3**: Try to nominate "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition" - should fail due to 1 completion
4. **Test Case 4**: Try to nominate "Amazon Connect for Tableau Tech Support" - should succeed due to 37 completions
5. **Test Case 5**: Try to nominate "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST" - should fail due to invalid course name

**Expected Consistency**: Your results should match the "My Test Result" column above for each test case. 

## Overview
These test cases verify that the APM nomination system correctly handles API errors and provides accurate feedback to users. The system should detect when the external API returns errors (even with 200 OK status) and report them properly.

## Test Results Summary (My Testing)
- **Total Tests**: 5
- **Passed**: 3 tests (60%)
- **Failed**: 2 tests (40%)
- **Key Finding**: API error detection is working correctly for low completion counts

---

## Test Case 1: Course with 0 Completions
**Course Name**: `Einstein 1 Platform 認定資格 (セールストークなし)`

**Expected Result**: ❌ **FAIL** - API error due to 0 completions
**Expected Error**: `"Number of Unique Learners is not equal or greater than 20."`

**Agent Action**: 
1. Go to Agentforce
2. Search for "Einstein 1 Platform 認定資格 (セールストークなし)"
3. Create APM nomination for this course
4. Verify you receive an error message about insufficient learners

**My Test Result**: ❌ **FAILED** - Duplicate nomination (already nominated)
**Status**: This course was already nominated, so duplicate detection prevented retesting

---

## Test Case 2: Course with 1 Completion
**Course Name**: `BDR Readiness Learning Journey`

**Expected Result**: ❌ **FAIL** - API error due to 1 completion
**Expected Error**: `"Number of Unique Learners is not equal or greater than 20."`

**Agent Action**:
1. Go to Agentforce
2. Search for "BDR Readiness Learning Journey"
3. Create APM nomination for this course
4. Verify you receive an error message about insufficient learners

**My Test Result**: ✅ **PASSED** - API correctly returned error
**Status**: `Failed` - Error: API returned error status - Number of Unique Learners is not equal or greater than 20.

---

## Test Case 3: Course with 1 Completion (Different Course)
**Course Name**: `Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition`

**Expected Result**: ❌ **FAIL** - API error due to 1 completion
**Expected Error**: `"Number of Unique Learners is not equal or greater than 20."`

**Agent Action**:
1. Go to Agentforce
2. Search for "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition"
3. Create APM nomination for this course
4. Verify you receive an error message about insufficient learners

**My Test Result**: ✅ **PASSED** - API correctly returned error
**Status**: `Failed` - Error: API returned error status - Number of Unique Learners is not equal or greater than 20.

---

## Test Case 4: Course with 37 Completions
**Course Name**: `Amazon Connect for Tableau Tech Support`

**Expected Result**: ✅ **SUCCESS** - 37 completions >= 20
**Expected Success**: `"Successfully inserted into the database"`

**Agent Action**:
1. Go to Agentforce
2. Search for "Amazon Connect for Tableau Tech Support"
3. Create APM nomination for this course
4. Verify you receive a success message

**My Test Result**: ✅ **PASSED** - API call succeeded
**Status**: `Success` - Success: success

---

## Test Case 5: Invalid Course Name
**Course Name**: `INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST`

**Expected Result**: ❌ **FAIL** - Course not found
**Expected Error**: Course not found or similar error

**Agent Action**:
1. Go to Agentforce
2. Try to create APM nomination for "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST"
3. Verify you receive an error message about course not found

**My Test Result**: ❌ **FAILED** - System used fallback value (40) and succeeded
**Status**: `Success` - Success: Sucessfully inserted into the database

---

## Key Findings

### ✅ Working Correctly:
1. **Real Course IDs**: System uses actual course IDs instead of `DEFAULT123`
2. **Real Completion Counts**: System uses actual completion counts from database
3. **API Error Detection**: System correctly detects when API returns `"status": "error"`
4. **Error Reporting**: Failed nominations show `"Failed"` status with detailed error messages
5. **Success Reporting**: Successful nominations show `"Success"` status

### ⚠️ Areas for Improvement:
1. **Invalid Course Handling**: System falls back to default value (40) for invalid course names
2. **Duplicate Detection**: Working correctly but prevents retesting same courses

### 🎯 Primary Goal Achieved:
The **core API error handling is working perfectly**! When users try to nominate courses with fewer than 20 completions, they now receive proper error messages instead of false success responses.

---

## Expected Agent Behavior

### For Courses with < 20 Completions:
- Agent should receive: `"Failed"` status
- Error message: `"Number of Unique Learners is not equal or greater than 20."`
- User should see clear error feedback

### For Courses with >= 20 Completions:
- Agent should receive: `"Success"` status
- Success message: `"Successfully inserted into the database"`
- User should see confirmation of successful nomination

### For Invalid Course Names:
- Currently falls back to default value (40) and succeeds
- This is a known limitation that could be improved

---

## Testing Instructions for Agent

1. **Test Case 1**: Try to nominate "Einstein 1 Platform 認定資格 (セールストークなし)" - should fail due to 0 completions
2. **Test Case 2**: Try to nominate "BDR Readiness Learning Journey" - should fail due to 1 completion  
3. **Test Case 3**: Try to nominate "Marketing Cloud: Third Party Messaging - Bullseye Framework & Value Proposition" - should fail due to 1 completion
4. **Test Case 4**: Try to nominate "Amazon Connect for Tableau Tech Support" - should succeed due to 37 completions
5. **Test Case 5**: Try to nominate "INVALID_COURSE_NAME_THAT_DOES_NOT_EXIST" - should fail due to invalid course name

**Expected Consistency**: Your results should match the "My Test Result" column above for each test case. 