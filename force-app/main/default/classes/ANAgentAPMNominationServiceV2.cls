public with sharing class ANAgentAPMNominationServiceV2 {
    public static Map<String, Object> create(Map<String, Object> params) {
        Map<String, Object> result = new Map<String, Object>();
        apm_nomination_v2__c nom = new apm_nomination_v2__c();
        try {
            // Map fields from params
            if (params.containsKey('OFFERING_NAME__c')) nom.OFFERING_NAME__c = (String)params.get('OFFERING_NAME__c');
            if (params.containsKey('ENABLEMENTS_ID__c')) nom.ENABLEMENTS_ID__c = (String)params.get('ENABLEMENTS_ID__c');
            if (params.containsKey('PROGRAM_TYPE__c')) nom.PROGRAM_TYPE__c = (String)params.get('PROGRAM_TYPE__c');
            if (params.containsKey('ENABLEMENT_TOOL__c')) nom.ENABLEMENT_TOOL__c = (String)params.get('ENABLEMENT_TOOL__c');
            if (params.containsKey('START_DATE__c')) nom.START_DATE__c = (Date)params.get('START_DATE__c');
            if (params.containsKey('END_DATE__c')) nom.END_DATE__c = (Date)params.get('END_DATE__c');
            if (params.containsKey('NOTES__c')) nom.NOTES__c = (String)params.get('NOTES__c');
            if (params.containsKey('CREATED_USER__c')) nom.CREATED_USER__c = (String)params.get('CREATED_USER__c');
            
            // Removed duplicate checking logic - let the API handle duplicate detection
            
            // Get real completion count instead of hardcoded value
            Integer completionCount = getCourseCompletionCount(nom.OFFERING_NAME__c);
            nom.UNIQUE_LEARNERS__c = completionCount;
            
            // Query User email before making API call
            String email = '';
            if (nom.CreatedById != null) {
                User u = [SELECT Email FROM User WHERE Id = :nom.CreatedById LIMIT 1];
                email = u.Email;
            }
            
            // Get the real course ID for API callout (this should be the auto-generated one)
            String apiCourseId = nom.ENABLEMENTS_ID__c;
            
            // Auto-generate enablement ID if it's empty
            if (String.isBlank(apiCourseId)) {
                apiCourseId = generateEnablementId(nom.OFFERING_NAME__c);
                nom.ENABLEMENTS_ID__c = apiCourseId;
                System.debug('Auto-generated enablement ID: ' + apiCourseId);
            }
            
            // Prepare API payload
            // Add "Agentforce_" prefix to nominator name for agent-created nominations
            String nominatorName = String.isNotBlank(nom.CREATED_USER__c) ? 'Agentforce_' + nom.CREATED_USER__c : 'Agentforce_Agent User';
            
            Map<String, Object> payload = new Map<String, Object>{
                'offering_name' => nom.OFFERING_NAME__c,
                'selected_events_ids' => apiCourseId,
                'program_type' => nom.PROGRAM_TYPE__c,
                'enablement_tool' => nom.ENABLEMENT_TOOL__c,
                'no_unique_learners' => completionCount,
                'start_date' => String.valueOf(nom.START_DATE__c),
                'end_date' => String.valueOf(nom.END_DATE__c),
                'notes' => nom.NOTES__c,
                'user_name' => nominatorName,
                'email' => email
            };
            // Remove null/empty optional fields
            // Always include notes field (API requires it)
        if (String.isBlank(nom.NOTES__c)) {
            payload.put('notes', '');
        }
            
            // Make synchronous API call BEFORE inserting the record
            String apiResponse = calloutToAPM(payload);
            
            // Set the API response status before inserting
            if (apiResponse.startsWith('Success:')) {
                nom.APM_PROCESSED_STATUS__c = 'Success';
                nom.APM_STATUS_DETAILED__c = apiResponse;
                result.put('success', true);
                result.put('message', 'Nomination created successfully. ' + apiResponse);
            } else {
                nom.APM_PROCESSED_STATUS__c = 'Failed';
                nom.APM_STATUS_DETAILED__c = apiResponse;
                result.put('success', false);
                result.put('message', 'Nomination created but API call failed: ' + apiResponse);
            }
            
            // Insert the record with the API response already set
            insert nom;
            result.put('record', nom);
            result.put('nominationId', nom.Id);
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Error: ' + e.getMessage());
        }
        return result;
    }
    public static String calloutToAPM(Map<String, Object> payload) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        // Build query parameters
        String endpoint = 'https://flex-gateway-sandbox-6fb019630b06.herokuapp.com/apm/nominate_offering?';
        List<String> params = new List<String>();
        
        // Add required parameters
        if (payload.containsKey('offering_name')) params.add('offering_name=' + EncodingUtil.urlEncode((String)payload.get('offering_name'), 'UTF-8'));
        if (payload.containsKey('selected_events_ids')) params.add('selected_events_ids=' + EncodingUtil.urlEncode((String)payload.get('selected_events_ids'), 'UTF-8'));
        if (payload.containsKey('program_type')) params.add('program_type=' + EncodingUtil.urlEncode((String)payload.get('program_type'), 'UTF-8'));
        if (payload.containsKey('enablement_tool')) params.add('enablement_tool=' + EncodingUtil.urlEncode((String)payload.get('enablement_tool'), 'UTF-8'));
        if (payload.containsKey('no_unique_learners')) params.add('no_unique_learners=' + String.valueOf(payload.get('no_unique_learners')));
        if (payload.containsKey('start_date')) params.add('start_date=' + EncodingUtil.urlEncode((String)payload.get('start_date'), 'UTF-8'));
        if (payload.containsKey('end_date')) params.add('end_date=' + EncodingUtil.urlEncode((String)payload.get('end_date'), 'UTF-8'));
        if (payload.containsKey('notes')) params.add('notes=' + EncodingUtil.urlEncode((String)payload.get('notes'), 'UTF-8'));
        if (payload.containsKey('user_name')) params.add('user_name=' + EncodingUtil.urlEncode((String)payload.get('user_name'), 'UTF-8'));
        if (payload.containsKey('email')) params.add('email=' + EncodingUtil.urlEncode((String)payload.get('email'), 'UTF-8'));
        
        endpoint += String.join(params, '&');
        
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(45000);
        
        try {
            HttpResponse res = http.send(req);
            String responseBody = res.getBody();
            System.debug('API Response Status: ' + res.getStatusCode());
            System.debug('API Response Body: ' + responseBody);
            
            // Always try to parse the response body first to check for API-level errors
            try {
                Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                
                // Check if the API returned an error status in the JSON response
                if (responseData.containsKey('status') && (String)responseData.get('status') == 'error') {
                    String errorMessage = responseData.containsKey('message') ? (String)responseData.get('message') : 'Unknown API error';
                    return 'Error: API returned error status - ' + errorMessage;
                }
                
                // Check if the API returned a success status
                if (responseData.containsKey('status') && (String)responseData.get('status') == 'success') {
                    String successMessage = responseData.containsKey('message') ? (String)responseData.get('message') : 'API call completed successfully';
                    return 'Success: ' + successMessage;
                }
                
                // If no status field, check HTTP status code
                if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                    String message = responseData.containsKey('message') ? (String)responseData.get('message') : 'API call completed successfully';
                    return 'Success: ' + message;
                } else {
                    String errorMessage = responseData.containsKey('message') ? (String)responseData.get('message') : 'HTTP error: ' + res.getStatusCode();
                    return 'Error: ' + errorMessage;
                }
                
            } catch (Exception parseEx) {
                // If JSON parsing fails, fall back to HTTP status code
                System.debug('Failed to parse JSON response: ' + parseEx.getMessage());
                if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                    return 'Success: API call completed. Response: ' + responseBody;
                } else {
                    return 'Error: ' + res.getStatusCode() + ' - ' + responseBody;
                }
            }
            
        } catch (Exception e) {
            return 'Exception: ' + e.getMessage();
        }
    }
    public class NominationInput {
        @InvocableVariable(label='OFFERING_NAME__c') public String offeringName;
        @InvocableVariable(label='ENABLEMENTS_ID__c') public String enablementsId;
        @InvocableVariable(label='PROGRAM_TYPE__c') public String programType;
        @InvocableVariable(label='ENABLEMENT_TOOL__c') public String enablementTool;
        @InvocableVariable(label='START_DATE__c') public Date startDate;
        @InvocableVariable(label='END_DATE__c') public Date endDate;
        @InvocableVariable(label='NOTES__c') public String notes;
        @InvocableVariable(label='CREATED_USER__c') public String createdUser;
    }
    public class NominationOutput {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }
    @InvocableMethod(label='Create APM Nomination V2' description='Creates an APM nomination v2 and calls external API')
    public static List<NominationOutput> invocableCreateV2(List<NominationInput> inputs) {
        List<NominationOutput> results = new List<NominationOutput>();
        for (NominationInput input : inputs) {
            // Auto-populate missing values with defaults
            String enablementsId = String.isNotBlank(input.enablementsId) ? input.enablementsId : generateEnablementId(input.offeringName);
            String programType = String.isNotBlank(input.programType) ? input.programType : 'Training';
            String enablementTool = String.isNotBlank(input.enablementTool) ? mapEnablementTool(input.enablementTool) : 'course';
            String notes = String.isNotBlank(input.notes) ? input.notes : 'APM nomination created via agent for course: ' + input.offeringName;
            String createdUser = String.isNotBlank(input.createdUser) ? input.createdUser : 'Agent User';
            
            Map<String, Object> params = new Map<String, Object>{
                'OFFERING_NAME__c' => input.offeringName,
                'ENABLEMENTS_ID__c' => enablementsId,
                'PROGRAM_TYPE__c' => programType,
                'ENABLEMENT_TOOL__c' => enablementTool,
                'START_DATE__c' => input.startDate,
                'END_DATE__c' => input.endDate,
                'NOTES__c' => notes,
                'CREATED_USER__c' => createdUser
            };
            Map<String, Object> result = create(params);
            NominationOutput out = new NominationOutput();
            out.success = (Boolean)result.get('success');
            out.message = (String)result.get('message');
            results.add(out);
        }
        return results;
    }
    
    @future(callout=true)
    public static void calloutToAPMAsync(Id nominationId, String payloadJson) {
        try {
            Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(payloadJson);
            String status = calloutToAPM(payload);
            
            // Update the record with the API response
            apm_nomination_v2__c nom = new apm_nomination_v2__c(Id = nominationId);
            
            // Determine if it's a success or failure based on the status
            if (status.startsWith('Error:') || status.startsWith('Exception:')) {
                nom.APM_PROCESSED_STATUS__c = 'Failed';
                nom.APM_STATUS_DETAILED__c = status;
            } else if (status.startsWith('Success:')) {
                nom.APM_PROCESSED_STATUS__c = 'Success';
                nom.APM_STATUS_DETAILED__c = status;
            } else {
                // Default to failed for unknown status
                nom.APM_PROCESSED_STATUS__c = 'Failed';
                nom.APM_STATUS_DETAILED__c = 'Unknown status: ' + status;
            }
            
            update nom;
        } catch (Exception e) {
            // Update the record with error status
            apm_nomination_v2__c nom = new apm_nomination_v2__c(Id = nominationId);
            nom.APM_PROCESSED_STATUS__c = 'Failed';
            nom.APM_STATUS_DETAILED__c = 'Exception: ' + e.getMessage();
            update nom;
        }
    }
    
    /**
     * @description Gets real completion count for a course by querying Assigned_Course__c
     * @param courseName The name of the course to get completion data for
     * @return Integer The number of unique learners who completed the course
     */
    public static Integer getCourseCompletionCount(String courseName) {
        try {
            if (String.isBlank(courseName)) {
                return 40; // Fallback to default if no course name
            }
            
            // First, get the course ID from the course name
            List<Course__c> courses = [
                SELECT Id, Name 
                FROM Course__c 
                WHERE Name = :courseName 
                AND IsDeleted = false 
                LIMIT 1
            ];
            
            if (courses.isEmpty()) {
                System.debug('Course not found: ' + courseName);
                return 40; // Fallback to default value
            }
            
            String courseId = courses[0].Id;
            
            // Query for completed assignments for this specific course (same logic as content search)
            List<AggregateResult> completionCounts = [
                SELECT COUNT(Id) completionCount
                FROM Assigned_Course__c 
                WHERE Course__c = :courseId 
                AND Completed__c = true
            ];
            
            Integer completionCount = 0;
            if (!completionCounts.isEmpty()) {
                completionCount = (Integer)completionCounts[0].get('completionCount');
            }
            
            System.debug('Course: ' + courseName + ' - Real completion count: ' + completionCount);
            
            // Return the actual completion count (no artificial minimum)
            return completionCount;
            
        } catch (Exception e) {
            System.debug('Error getting completion count for ' + courseName + ': ' + e.getMessage());
            return 40; // Fallback to default value
        }
    }
    
    /**
     * @description Gets course details and completion statistics for enhanced response
     * @param courseName The name of the course
     * @return Map<String, Object> Course details and statistics
     */
    public static Map<String, Object> getCourseDetails(String courseName) {
        Map<String, Object> details = new Map<String, Object>();
        
        try {
            if (String.isBlank(courseName)) {
                return details;
            }
            
            // Get course information
            List<Course__c> courses = [
                SELECT Id, Name, Description__c, Status__c, Primary_Category__c, Share_Url__c
                FROM Course__c 
                WHERE Name = :courseName 
                AND IsDeleted = false 
                LIMIT 1
            ];
            
            if (!courses.isEmpty()) {
                Course__c course = courses[0];
                details.put('courseId', course.Id);
                details.put('courseName', course.Name);
                details.put('description', course.Description__c);
                details.put('status', course.Status__c);
                details.put('category', course.Primary_Category__c);
                details.put('shareUrl', course.Share_Url__c);
            }
            
            // Get completion statistics
            Integer completionCount = getCourseCompletionCount(courseName);
            details.put('completionCount', completionCount);
            
            // Get total assigned count
            Integer totalAssigned = [
                SELECT COUNT() 
                FROM Assigned_Course__c 
                WHERE Course__r.Name = :courseName 
                AND Inactive__c = false
            ];
            details.put('totalAssigned', totalAssigned);
            
            // Calculate completion rate
            Decimal completionRate = totalAssigned > 0 ? (completionCount * 100.0 / totalAssigned).setScale(1) : 0;
            details.put('completionRate', completionRate);
            
        } catch (Exception e) {
            System.debug('Error getting course details for ' + courseName + ': ' + e.getMessage());
        }
        
        return details;
    }
    
    /**
     * @description Generates a meaningful enablement ID based on the offering name
     * @param offeringName The name of the offering
     * @return String A meaningful enablement ID
     */
    public static String generateEnablementId(String offeringName) {
        if (String.isBlank(offeringName)) {
            return 'ENABLEMENT_' + String.valueOf(Datetime.now().getTime());
        }
        
        // Extract key words from the offering name
        String cleanName = offeringName.replaceAll('[^a-zA-Z0-9\\s]', '').toUpperCase();
        String[] words = cleanName.split('\\s+');
        
        // Build a meaningful ID from key words
        List<String> keyWords = new List<String>();
        for (String word : words) {
            if (word.length() > 2 && !word.equals('THE') && !word.equals('AND') && !word.equals('FOR')) {
                keyWords.add(word);
            }
        }
        
        // Take first 2-3 meaningful words
        String idPrefix = '';
        for (Integer i = 0; i < Math.min(3, keyWords.size()); i++) {
            if (i > 0) idPrefix += '_';
            idPrefix += keyWords[i];
        }
        
        // Add current year
        String currentYear = String.valueOf(Date.today().year());
        
        return idPrefix + '_' + currentYear;
    }

    /**
     * @description Maps enablement tool names to the correct APM API values.
     * The APM API only accepts: asset, course, session
     * @param toolName The name of the enablement tool (e.g., 'Trailhead', 'course', 'session', 'asset')
     * @return String The API-specific value for the enablement tool
     */
    public static String mapEnablementTool(String toolName) {
        if (String.isBlank(toolName)) {
            return 'course'; // Default for courses
        }
        
        String lowerToolName = toolName.toLowerCase();
        
        // Map common enablement tool names to APM API values
        switch on lowerToolName {
            when 'trailhead', 'course', 'learning', 'training' {
                return 'course';
            }
            when 'session', 'workshop', 'event', 'webinar' {
                return 'session';
            }
            when 'asset', 'resource', 'document', 'video', 'pdf' {
                return 'asset';
            }
            when else {
                return 'course'; // Default to 'course' for unknown tools
            }
        }
    }
} 