public with sharing class GAEOA2IntakeHandler {

    // Inner class for request data
    public class Request {
        @InvocableVariable(label='Action Type' description='The action to perform on the Intake record. Valid values are Create, Modify, Retrieve, Search.' required=true)
        public String actionType;

        @InvocableVariable(label='Intake ID' description='The Salesforce ID of the ENB_Intake__c record. Required for Modify and Retrieve actions.')
        public String intakeId;
        
        // --- All ENB_Intake__c Fields ---
        @InvocableVariable(label='Request Name' description='Value for the Request Name (Request_Name__c) field.')
        public String requestName;
        @InvocableVariable(label='Actions / Comments' description='Value for the Actions / Comments (Actions_Comments__c) field.')
        public String actionsComments;
        @InvocableVariable(label='Additional Request Details' description='Value for the Additional Request Details (Additional_Request_Details__c) field.')
        public String additionalRequestDetails;
        @InvocableVariable(label='Anticipated Business Outcome' description='Value for the Anticipated Business Outcome (Anticipated_Business_Outcome__c) field.')
        public String anticipatedBusinessOutcome;
        @InvocableVariable(label='Assigned Delivery Specialist' description='Value for the Assigned Delivery Specialist (Assigned_Delivery_Specialist__c) field.')
        public String assignedDeliverySpecialist;
        @InvocableVariable(label='Associated Enablement Intake ID' description='Value for the Associated Enablement Intake (Associated_Enablement_Intake__c) field.')
        public String associatedEnablementIntake;
        @InvocableVariable(label='Behaviors to change/skills to develop' description='Value for the Behaviors to change/skills to develop (Behaviors_to_change_skills_to_develop__c) field.')
        public String behaviorsToChangeSkillsToDevelop;
        @InvocableVariable(label='Budget Source' description='Value for the Budget Source (Budget_Source__c) field.')
        public String budgetSource;
        @InvocableVariable(label='Business Challenge' description='Value for the Business Challenge (Business_Challenge__c) field.')
        public String businessChallenge;
        @InvocableVariable(label='Business Metrics to Track (Qualitative)' description='Value for the Business Metrics to Track (Qualitative) (Business_Metrics_to_Track_Qualitative__c) field.')
        public String businessMetricsToTrackQualitative;
        @InvocableVariable(label='Business Metrics to Track (Quantitative)' description='Value for the Business Metrics to Track (Quantitative) (Business_Metrics_to_Track_Quantitative__c) field.')
        public String businessMetricsToTrackQuantitative;
        @InvocableVariable(label='Business Outcome - Other' description='Value for the Business Outcome - Other (Business_Outcome_Other__c) field.')
        public String businessOutcomeOther;
        @InvocableVariable(label='Capacity Impact - Design Time' description='Value for the Capacity Impact - Design Time (Capacity_Impact_Design_Time__c) field.')
        public Decimal capacityImpactDesignTime;
        @InvocableVariable(label='Capacity Impact - Implementation Time' description='Value for the Capacity Impact - Implementation Time (Capacity_Impact_Implementation_Time__c) field.')
        public Decimal capacityImpactImplementationTime;
        @InvocableVariable(label='Close Date' description='Value for the Close Date (Close_Date__c) field.')
        public Date closeDate;
        @InvocableVariable(label='Comments' description='Value for the Comments (Comments__c) field.')
        public String comments;
        @InvocableVariable(label='Primary Category (Not Specified)' description='Value for the Primary Category (Not Specified) (Competency_Category_Not_Specified__c) field.')
        public String competencyCategoryNotSpecified;
        @InvocableVariable(label='Primary Category' description='Value for the Primary Category (Competency_Category__c) field.')
        public String competencyCategory;
        @InvocableVariable(label='Content Design Needed' description='Value for the Content Design Needed (Content_Design_Needed__c) field.')
        public String contentDesignNeeded;
        @InvocableVariable(label='Create New Project' description='Value for the Create New Project (Create_New_Project__c) field.')
        public Boolean createNewProject;
        @InvocableVariable(label='Decision Date' description='Value for the Decision Date (Decision_Date__c) field.')
        public Date decisionDate;
        @InvocableVariable(label='Additional Scoping Details' description='Value for the Additional Scoping Details (Additional_Scoping_Details__c) field.')
        public String additionalScopingDetails;
        @InvocableVariable(label='Delivery Resources Needed' description='Value for the Delivery Resources Needed (Delivery_Resources_Needed__c) field.')
        public String deliveryResourcesNeeded;
        @InvocableVariable(label='Dependencies or Other Initiatives' description='Value for the Dependencies or Other Initiatives (Dependencies_or_Other_Initiatives__c) field.')
        public String dependenciesOrOtherInitiatives;
        @InvocableVariable(label='Describe the Initiative or Dependency' description='Value for the Describe the Initiative or Dependency (Describe_the_Initiative_or_Dependency__c) field.')
        public String describeTheInitiativeOrDependency;
        @InvocableVariable(label='Describe the Technology feature/function' description='Value for the Describe the Technology feature/function (Describe_the_Technology_feature_function__c) field.')
        public String describeTheTechnologyFeatureFunction;
        @InvocableVariable(label='Enablement Ask' description='Value for the Enablement Ask (Enablement_Ask__c) field.')
        public String enablementAsk;
        @InvocableVariable(label='Enablement Business Unit' description='Value for the Enablement Business Unit (Enablement_Team__c) field.')
        public String enablementTeam;
        @InvocableVariable(label='Estimated Cost' description='Value for the Estimated Cost (Estimated_Cost__c) field.')
        public Decimal estimatedCost;
        @InvocableVariable(label='Exec Commitment' description='Value for the Exec Commitment (Exec_Commitment__c) field.')
        public String execCommitment;
        @InvocableVariable(label='Executive Sponsor' description='Value for the Executive Sponsor (Executive_Sponsor__c) field.')
        public String executiveSponsor;
        @InvocableVariable(label='Existing Program or Course Details' description='Value for the Existing Program or Course Details (Existing_Program_or_Course_Details__c) field.')
        public String existingProgramOrCourseDetails;
        @InvocableVariable(label='Requested Delivery Date' description='Value for the Requested Delivery Date (Expected_Delivery_Date__c) field.')
        public Date expectedDeliveryDate;
        @InvocableVariable(label='Strategy Approval Status' description='Value for the Strategy Approval Status (GER_Approval_Status__c) field.')
        public String gerApprovalStatus;
        @InvocableVariable(label='Global Program' description='Value for the Global Program (Global_Program__c) field.')
        public String globalProgram;
        @InvocableVariable(label='How often will learners perform the task' description='Value for the How often will learners perform the task (How_often_will_learners_perform_the_task__c) field.')
        public String howOftenWillLearnersPerformTheTask;
        @InvocableVariable(label='Impact to User' description='Value for the Impact to User (Impact_to_User__c) field.')
        public String impactToUser;
        @InvocableVariable(label='Intake Request Date' description='Value for the Intake Request Date (Intake_Request_Date__c) field.')
        public Date intakeRequestDate;
        @InvocableVariable(label='Intake Stage' description='Value for the Intake Stage (Intake_Stage__c) field.')
        public String intakeStage;
        @InvocableVariable(label='Intake Type' description='Value for the Intake Type (Intake_Type__c) field.')
        public String intakeType;
        @InvocableVariable(label='Link/Reference' description='Value for the Link/Reference (Link_Reference__c) field.')
        public String linkReference;
        @InvocableVariable(label='Delivery Method Type' description='Value for the Delivery Method Type (Modality_Type_of_Request__c) field.')
        public String modalityTypeOfRequest;
        @InvocableVariable(label='OU Not Specified' description='Value for the OU Not Specified (OU_Not_Specified__c) field.')
        public String ouNotSpecified;
        @InvocableVariable(label='OU benefit from request' description='Value for the OU benefit from request (OU_benefit_from_request__c) field.')
        public String ouBenefitFromRequest;
        @InvocableVariable(label='On Hold Follow Up Date' description='Value for the On Hold Follow Up Date (On_Hold_Follow_Up_Date__c) field.')
        public Date onHoldFollowUpDate;
        @InvocableVariable(label='On Hold Reason' description='Value for the On Hold Reason (On_Hold_Reason__c) field.')
        public String onHoldReason;
        @InvocableVariable(label='Project Name' description='Value for the Project Name (Project_Name__c) field.')
        public String projectName;
        @InvocableVariable(label='Rejection Reason' description='Value for the Rejection Reason (Rejection_Reason__c) field.')
        public String rejectionReason;
        @InvocableVariable(label='Related EET Record' description='Value for the Related EET Record (Related_EET_Record__c) field.')
        public String relatedEetRecord;
        @InvocableVariable(label='Related Project Link' description='Value for the Related Project Link (Related_Project_Link__c) field.')
        public String relatedProjectLink;
        @InvocableVariable(label='Related Project ID' description='Value for the Related Project (Related_Project__c) field.')
        public String relatedProject;
        @InvocableVariable(label='Request on the behalf of an Executive' description='Value for the Request on the behalf of an Executive (Request_on_the_behalf_of_an_Executive__c) field.')
        public String requestOnTheBehalfOfAnExecutive;
        @InvocableVariable(label='Request require resources outside Org' description='Value for the Request require resources outside Org (Request_require_resources_outside_Org__c) field.')
        public String requestRequireResourcesOutsideOrg;
        @InvocableVariable(label='Request to enhance enablement technology' description='Value for the Request to enhance enablement technology (Request_to_enhance_enablement_technology__c) field.')
        public String requestToEnhanceEnablementTechnology;
        @InvocableVariable(label='Request within Budget' description='Value for the Request within Budget (Request_within_Budget__c) field.')
        public String requestWithinBudget;
        @InvocableVariable(label='Requested Timeline' description='Value for the Requested Timeline (Requested_Timeline2__c) field.')
        public String requestedTimeline2;
        @InvocableVariable(label='Requestor Email' description='Value for the Requestor Email (Requestor_Email__c) field.')
        public String requestorEmail;
        @InvocableVariable(label='Requestor' description='Value for the Requestor (Requestor__c) field.')
        public String requestor;
        @InvocableVariable(label='Requestor in the Global Enablement Org' description='Value for the Requestor in the Global Enablement Org (Requestor_in_the_Global_Enablement_Org__c) field.')
        public String requestorInTheGlobalEnablementOrg;
        @InvocableVariable(label='Require PMO Support' description='Value for the Require PMO Support (Require_PMO_Support__c) field.')
        public String requirePmoSupport;
        @InvocableVariable(label='Require new Technology feature/function' description='Value for the Require new Technology feature/function (Require_new_Technology_feature_function__c) field.')
        public String requireNewTechnologyFeatureFunction;
        @InvocableVariable(label='Reviewed request with Manager' description='Value for the Reviewed request with Manager (Reviewed_request_with_Manager__c) field.')
        public String reviewedRequestWithManager;
        @InvocableVariable(label='Target Audience' description='Value for the Target Audience (Target_Audience__c) field.')
        public String targetAudience;
        @InvocableVariable(label='Target Geographic Regions' description='Value for the Target Geographic Regions (Target_Geographic_Regions__c) field.')
        public String targetGeographicRegions;
        @InvocableVariable(label='Tech Impact Level' description='Value for the Tech Impact Level (Tech_Impact_Level__c) field.')
        public String techImpactLevel;
        @InvocableVariable(label='Time for learner (hours)' description='Value for the Time for learner (hours) (Time_for_learner_hours__c) field.')
        public Decimal timeForLearnerHours;
        @InvocableVariable(label='Training Type' description='Value for the Training Type (Training_Type__c) field.')
        public String trainingType;
        @InvocableVariable(label='Tried in the Past' description='Value for the Tried in the Past (Tried_in_the_Past__c) field.')
        public String triedInThePast;
        @InvocableVariable(label='Vendor Resources' description='Value for the Vendor Resources (Vendor_Resources__c) field.')
        public String vendorResources;
        @InvocableVariable(label='Who is available to help' description='Value for the Who is available to help (Who_is_available_to_help__c) field.')
        public String whoIsAvailableToHelp;
        @InvocableVariable(label='Who needs to be involved' description='Value for the Who needs to be involved (Who_needs_to_be_involved__c) field.')
        public String whoNeedsToBeInvolved;
        @InvocableVariable(label='Assigned Team ID' description='Value for the Assigned Team (Assigned_Team__c) field.')
        public String assignedTeam;
        @InvocableVariable(label='Decision Next Step' description='Value for the Decision Next Step (Decision_Next_Step__c) field.')
        public String decisionNextStep;
        @InvocableVariable(label='Decision Reason' description='Value for the Decision Reason (Decision_Reason__c) field.')
        public String decisionReason;
        @InvocableVariable(label='Delivery Team Needed ID' description='Value for the Delivery Team Needed (Delivery_Team_Needed__c) field.')
        public String deliveryTeamNeeded;
        @InvocableVariable(label='Design Team Needed ID' description='Value for the Design Team Needed (Design_Team_Needed__c) field.')
        public String designTeamNeeded;
        @InvocableVariable(label='Executive Sponsor User ID' description='Value for the Executive Sponsor User (Executive_Sponsor_User__c) field.')
        public String executiveSponsorUser;
        @InvocableVariable(label='Initial Intake Request' description='Value for the Initial Intake Request (Initial_Intake_Request__c) field.')
        public String initialIntakeRequest;
        @InvocableVariable(label='Intake Channel' description='Value for the Intake Channel (Intake_Channel__c) field.')
        public String intakeChannel;
        @InvocableVariable(label='Intake Status' description='Value for the Intake Status (Intake_Status__c) field.')
        public String intakeStatus;
        @InvocableVariable(label='Requestor User ID' description='Value for the Requestor User (Requestor_User__c) field.')
        public String requestorUser;
        @InvocableVariable(label='Tech Tool Not Specified' description='Value for the Tech Tool Not Specified (Tech_Tool_Not_Specified__c) field.')
        public String techToolNotSpecified;
        @InvocableVariable(label='Tech Tool Request' description='Value for the Tech Tool Request (Tech_Tool_Request__c) field.')
        public String techToolRequest;
        @InvocableVariable(label='Vendor ID' description='Value for the Vendor (Vendor__c) field.')
        public String vendor;
        @InvocableVariable(label='Related Work ID' description='Value for the Related Work (Work__c) field.')
        public String work;
        @InvocableVariable(label='External ID' description='Value for the External ID (External_ID__c) field.')
        public String externalId;
        @InvocableVariable(label='Project Template ID' description='Value for the Project Template (Project_Template__c) field.')
        public String projectTemplate;
        @InvocableVariable(label='Team ID' description='Value for the Team (Team__c) field.')
        public String team;
        @InvocableVariable(label='Associated V2MOM ID' description='Value for the Associated V2MOM (V2MOM__c) field.')
        public String v2mom;
        @InvocableVariable(label='ACT 2.0 Course ID' description='Value for the ACT 2.0 Course (ACT2Course__c) field.')
        public String act2Course;
        
        // Search-specific fields
        @InvocableVariable(label='Intake Request Number for Search' description='Keyword for searching by the auto-generated Intake Request Number (Name) field.')
        public String nameSearch;
        @InvocableVariable(label='Created Date' description='Date filter for search operations on the CreatedDate field. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='Date filter for search operations on the LastModifiedDate field. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public String lastModifiedDate;
    }

    // Inner class for response data
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation succeeded, false otherwise.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result, such as success or error messages.')
        public String message = '';
        @InvocableVariable(label='Intake Records' description='A list of ENB_Intake__c records that were processed, created, or retrieved by the operation.')
        public List<ENB_Intake__c> intakeRecords = new List<ENB_Intake__c>();
    }

    /**
     * @description Main entry point for managing Intake records. A single, bulk-safe method to create, modify, retrieve, and search for Intake records.
     * @param requests A list of Request objects, each defining an operation to perform.
     * @return A list of Response objects corresponding to each input request.
     */
    @InvocableMethod(label='Manage Intake Records' description='Performs Create, Modify, Retrieve, and Search operations on Intake (ENB_Intake__c) records.')
    public static List<Response> manageIntakes(List<Request> requests) {
        List<ENB_Intake__c> toCreate = new List<ENB_Intake__c>();
        List<ENB_Intake__c> toUpdate = new List<ENB_Intake__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.requestName)) {
                        res.message = 'Error: Request Name is required for creation.';
                    } else {
                        toCreate.add(mapRequestToIntake(req, new ENB_Intake__c()));
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.intakeId)) {
                        res.message = 'Error: Intake ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.intakeId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type. Must be Create, Modify, Retrieve, or Search.';
                }
            }
        }

        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }

        if (!idsToProcess.isEmpty()) {
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('ENB_Intake__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM ENB_Intake__c WHERE Id IN :idsToProcess';
            Map<Id, ENB_Intake__c> intakesFromDb = new Map<Id, ENB_Intake__c>((List<ENB_Intake__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.intakeId) || !intakesFromDb.containsKey(req.intakeId)) continue;
                
                Response res = responseMap.get(i);
                ENB_Intake__c intake = intakesFromDb.get(req.intakeId);

                if (req.actionType == 'Modify') {
                    toUpdate.add(mapRequestToIntake(req, intake));
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Intake retrieved successfully.';
                    res.intakeRecords.add(intake);
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    /**
     * @description Maps fields from a Request wrapper object to an ENB_Intake__c SObject record.
     * @param req The Request object containing the input data.
     * @param intake The ENB_Intake__c record to populate.
     * @return The populated ENB_Intake__c record.
     */
    private static ENB_Intake__c mapRequestToIntake(Request req, ENB_Intake__c intake) {
        if(req.intakeId != null) intake.Id = req.intakeId;
        // Map all the fields from the request to the SObject
        if(req.actionsComments != null) intake.Actions_Comments__c = req.actionsComments;
        if(req.additionalRequestDetails != null) intake.Additional_Request_Details__c = req.additionalRequestDetails;
        if(req.anticipatedBusinessOutcome != null) intake.Anticipated_Business_Outcome__c = req.anticipatedBusinessOutcome;
        if(req.assignedDeliverySpecialist != null) intake.Assigned_Delivery_Specialist__c = req.assignedDeliverySpecialist;
        if(req.associatedEnablementIntake != null) intake.Associated_Enablement_Intake__c = req.associatedEnablementIntake;
        if(req.behaviorsToChangeSkillsToDevelop != null) intake.Behaviors_to_change_skills_to_develop__c = req.behaviorsToChangeSkillsToDevelop;
        if(req.budgetSource != null) intake.Budget_Source__c = req.budgetSource;
        if(req.businessChallenge != null) intake.Business_Challenge__c = req.businessChallenge;
        if(req.businessMetricsToTrackQualitative != null) intake.Business_Metrics_to_Track_Qualitative__c = req.businessMetricsToTrackQualitative;
        if(req.businessMetricsToTrackQuantitative != null) intake.Business_Metrics_to_Track_Quantitative__c = req.businessMetricsToTrackQuantitative;
        if(req.businessOutcomeOther != null) intake.Business_Outcome_Other__c = req.businessOutcomeOther;
        if(req.capacityImpactDesignTime != null) intake.Capacity_Impact_Design_Time__c = req.capacityImpactDesignTime;
        if(req.capacityImpactImplementationTime != null) intake.Capacity_Impact_Implementation_Time__c = req.capacityImpactImplementationTime;
        if(req.closeDate != null) intake.Close_Date__c = req.closeDate;
        if(req.comments != null) intake.Comments__c = req.comments;
        if(req.competencyCategoryNotSpecified != null) intake.Competency_Category_Not_Specified__c = req.competencyCategoryNotSpecified;
        if(req.competencyCategory != null) intake.Competency_Category__c = req.competencyCategory;
        if(req.contentDesignNeeded != null) intake.Content_Design_Needed__c = req.contentDesignNeeded;
        if(req.createNewProject != null) intake.Create_New_Project__c = req.createNewProject;
        if(req.decisionDate != null) intake.Decision_Date__c = req.decisionDate;
        if(req.additionalScopingDetails != null) intake.Additional_Scoping_Details__c = req.additionalScopingDetails;
        if(req.deliveryResourcesNeeded != null) intake.Delivery_Resources_Needed__c = req.deliveryResourcesNeeded;
        if(req.dependenciesOrOtherInitiatives != null) intake.Dependencies_or_Other_Initiatives__c = req.dependenciesOrOtherInitiatives;
        if(req.describeTheInitiativeOrDependency != null) intake.Describe_the_Initiative_or_Dependency__c = req.describeTheInitiativeOrDependency;
        if(req.describeTheTechnologyFeatureFunction != null) intake.Describe_the_Technology_feature_function__c = req.describeTheTechnologyFeatureFunction;
        if(req.enablementAsk != null) intake.Enablement_Ask__c = req.enablementAsk;
        if(req.enablementTeam != null) intake.Enablement_Team__c = req.enablementTeam;
        if(req.estimatedCost != null) intake.Estimated_Cost__c = req.estimatedCost;
        if(req.execCommitment != null) intake.Exec_Commitment__c = req.execCommitment;
        if(req.executiveSponsor != null) intake.Executive_Sponsor__c = req.executiveSponsor;
        if(req.existingProgramOrCourseDetails != null) intake.Existing_Program_or_Course_Details__c = req.existingProgramOrCourseDetails;
        if(req.expectedDeliveryDate != null) intake.Expected_Delivery_Date__c = req.expectedDeliveryDate;
        if(req.gerApprovalStatus != null) intake.GER_Approval_Status__c = req.gerApprovalStatus;
        if(req.globalProgram != null) intake.Global_Program__c = req.globalProgram;
        if(req.howOftenWillLearnersPerformTheTask != null) intake.How_often_will_learners_perform_the_task__c = req.howOftenWillLearnersPerformTheTask;
        if(req.impactToUser != null) intake.Impact_to_User__c = req.impactToUser;
        if(req.intakeRequestDate != null) intake.Intake_Request_Date__c = req.intakeRequestDate;
        if(req.intakeStage != null) intake.Intake_Stage__c = req.intakeStage;
        if(req.intakeType != null) intake.Intake_Type__c = req.intakeType;
        if(req.linkReference != null) intake.Link_Reference__c = req.linkReference;
        if(req.modalityTypeOfRequest != null) intake.Modality_Type_of_Request__c = req.modalityTypeOfRequest;
        if(req.ouNotSpecified != null) intake.OU_Not_Specified__c = req.ouNotSpecified;
        if(req.ouBenefitFromRequest != null) intake.OU_benefit_from_request__c = req.ouBenefitFromRequest;
        if(req.onHoldFollowUpDate != null) intake.On_Hold_Follow_Up_Date__c = req.onHoldFollowUpDate;
        if(req.onHoldReason != null) intake.On_Hold_Reason__c = req.onHoldReason;
        if(req.projectName != null) intake.Project_Name__c = req.projectName;
        if(req.rejectionReason != null) intake.Rejection_Reason__c = req.rejectionReason;
        if(req.relatedEetRecord != null) intake.Related_EET_Record__c = req.relatedEetRecord;
        if(req.relatedProjectLink != null) intake.Related_Project_Link__c = req.relatedProjectLink;
        if(req.relatedProject != null) intake.Related_Project__c = req.relatedProject;
        if(req.requestName != null) intake.Request_Name__c = req.requestName;
        if(req.requestOnTheBehalfOfAnExecutive != null) intake.Request_on_the_behalf_of_an_Executive__c = req.requestOnTheBehalfOfAnExecutive;
        if(req.requestRequireResourcesOutsideOrg != null) intake.Request_require_resources_outside_Org__c = req.requestRequireResourcesOutsideOrg;
        if(req.requestToEnhanceEnablementTechnology != null) intake.Request_to_enhance_enablement_technology__c = req.requestToEnhanceEnablementTechnology;
        if(req.requestWithinBudget != null) intake.Request_within_Budget__c = req.requestWithinBudget;
        if(req.requestedTimeline2 != null) intake.Requested_Timeline2__c = req.requestedTimeline2;
        if(req.requestorEmail != null) intake.Requestor_Email__c = req.requestorEmail;
        if(req.requestor != null) intake.Requestor__c = req.requestor;
        if(req.requestorInTheGlobalEnablementOrg != null) intake.Requestor_in_the_Global_Enablement_Org__c = req.requestorInTheGlobalEnablementOrg;
        if(req.requirePmoSupport != null) intake.Require_PMO_Support__c = req.requirePmoSupport;
        if(req.requireNewTechnologyFeatureFunction != null) intake.Require_new_Technology_feature_function__c = req.requireNewTechnologyFeatureFunction;
        if(req.reviewedRequestWithManager != null) intake.Reviewed_request_with_Manager__c = req.reviewedRequestWithManager;
        if(req.targetAudience != null) intake.Target_Audience__c = req.targetAudience;
        if(req.targetGeographicRegions != null) intake.Target_Geographic_Regions__c = req.targetGeographicRegions;
        if(req.techImpactLevel != null) intake.Tech_Impact_Level__c = req.techImpactLevel;
        if(req.timeForLearnerHours != null) intake.Time_for_learner_hours__c = req.timeForLearnerHours;
        if(req.trainingType != null) intake.Training_Type__c = req.trainingType;
        if(req.triedInThePast != null) intake.Tried_in_the_Past__c = req.triedInThePast;
        if(req.vendorResources != null) intake.Vendor_Resources__c = req.vendorResources;
        if(req.whoIsAvailableToHelp != null) intake.Who_is_available_to_help__c = req.whoIsAvailableToHelp;
        if(req.whoNeedsToBeInvolved != null) intake.Who_needs_to_be_involved__c = req.whoNeedsToBeInvolved;
        if(req.assignedTeam != null) intake.Assigned_Team__c = req.assignedTeam;
        if(req.decisionNextStep != null) intake.Decision_Next_Step__c = req.decisionNextStep;
        if(req.decisionReason != null) intake.Decision_Reason__c = req.decisionReason;
        if(req.deliveryTeamNeeded != null) intake.Delivery_Team_Needed__c = req.deliveryTeamNeeded;
        if(req.designTeamNeeded != null) intake.Design_Team_Needed__c = req.designTeamNeeded;
        if(req.executiveSponsorUser != null) intake.Executive_Sponsor_User__c = req.executiveSponsorUser;
        if(req.initialIntakeRequest != null) intake.Initial_Intake_Request__c = req.initialIntakeRequest;
        if(req.intakeChannel != null) intake.Intake_Channel__c = req.intakeChannel;
        if(req.intakeStatus != null) intake.Intake_Status__c = req.intakeStatus;
        if(req.requestorUser != null) intake.Requestor_User__c = req.requestorUser;
        if(req.techToolNotSpecified != null) intake.Tech_Tool_Not_Specified__c = req.techToolNotSpecified;
        if(req.techToolRequest != null) intake.Tech_Tool_Request__c = req.techToolRequest;
        if(req.vendor != null) intake.Vendor__c = req.vendor;
        if(req.work != null) intake.Work__c = req.work;
        if(req.externalId != null) intake.External_ID__c = req.externalId;
        if(req.projectTemplate != null) intake.Project_Template__c = req.projectTemplate;
        if(req.team != null) intake.Team__c = req.team;
        if(req.v2mom != null) intake.V2MOM__c = req.v2mom;
        if(req.act2Course != null) intake.ACT2Course__c = req.act2Course;

        return intake;
    }

    /**
     * @description Processes the results of a DML operation (insert or update) and updates the response map accordingly.
     * @param results The array of Database.SaveResult objects from the DML call.
     * @param records The list of records that were processed.
     * @param action The action performed ('Create' or 'Modify').
     * @param requests The original list of requests.
     * @param responseMap The map of responses to update.
     */
    private static void handleDmlResults(Database.SaveResult[] results, List<ENB_Intake__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
             // Only process responses for the specific action that was performed
            if (requests.get(i).actionType == action) {
                // For 'Create', a name must be present. For 'Modify', an ID must be present.
                Boolean isRequestValid = (action == 'Create' && String.isNotBlank(requests.get(i).requestName)) || (action == 'Modify' && String.isNotBlank(requests.get(i).intakeId));

                if (isRequestValid && recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Intake ' + action.toLowerCase() + 'd successfully with ID ' + sr.getId() + '.';
                        res.intakeRecords.add(records[recordIndex]);
                    } else {
                        // Concatenate all error messages for a given record
                        String errorMessage = '';
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage += err.getStatusCode() + ': ' + err.getMessage() + ' (Fields: ' + String.join(err.getFields(), ', ') + ')\n';
                        }
                        res.message = 'Error during ' + action + ': ' + errorMessage;
                    }
                    recordIndex++;
                }
            }
        }
    }

    /**
     * @description Constructs and executes a dynamic SOQL query based on search criteria in the Request object.
     * @param req The Request object containing the search parameters.
     * @param res The Response object to populate with the search results.
     */
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('ENB_Intake__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM ENB_Intake__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.nameSearch)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.nameSearch) + '%\'');
        }
        if (String.isNotBlank(req.requestName)) {
            conditions.add('Request_Name__c LIKE \'%' + String.escapeSingleQuotes(req.requestName) + '%\'');
        }
        if(req.createdDate != null) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if(dateCondition != null) conditions.add(dateCondition);
        }
        if(req.lastModifiedDate != null) {
            String dateCondition = GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate);
            if(dateCondition != null) conditions.add(dateCondition);
        }
        
        if (!conditions.isEmpty()) {
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 200';

        try {
            res.intakeRecords = Database.query(soql);
            res.success = true;
            res.message = 'Search completed successfully. Found ' + res.intakeRecords.size() + ' records.';
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}