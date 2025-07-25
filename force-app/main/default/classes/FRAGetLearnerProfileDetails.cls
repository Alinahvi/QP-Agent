public with sharing class FRAGetLearnerProfileDetails {

    /**
     * Invocable method to retrieve Learner Profile records based on provided IDs.
     * @param requests List containing Learner Profile IDs to retrieve.
     * @return List of LearnerProfileResponse including detailed record data and summaries.
     */
    @InvocableMethod(label='GA-FRA Get Learner Profile Details' description='Retrieves full details of Learner Profiles by IDs.')
    public static List<LearnerProfileResponse> getLearnerProfileDetails(List<LearnerProfileRequest> requests) {
        List<Id> profileIds = new List<Id>();
        for (LearnerProfileRequest request : requests) {
            profileIds.add(request.learnerProfileId);
        }

        List<Learner_Profile__c> learnerProfiles = [
            SELECT Id, Name, Acquired_Company__c, Admin__c, AE_Type__c, Business_Title__c, Business_Unit_Name__c,
            Commissionable__c, Company__c, Contingent_Worker_Type__c, Contractor_Type__c, Cost_Center_ID__c,
            Cost_Center_Name__c, Current_Role_Start_Date__c, Customer_Market_Segment__c, Days_in_Current_Role__c,
            Division__c, Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, Emp_Mgt_Chain_Lvl_03_Nm__c,
            Emp_Mgt_Chain_Lvl_04_Nm__c, Emp_Mgt_Chain_Lvl_05_Nm__c, Emp_Mgt_Chain_Lvl_06_Nm__c,
            Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, Emp_Mgt_Chain_Lvl_09_Nm__c,
            Emp_Mgt_Chain_Lvl_10_Nm__c, Emp_Mgt_Chain_Lvl_11_Nm__c, Emp_Mgt_Chain_Lvl_12_Nm__c,
            Employee_Location__c, Employee_Number__c, Employee_on_Leave__c, Employee_Region__c,
            Employee_Tenure__c, externalid__c, externalUserid__c, Is_FLM__c, FTE__c, GE_Business_Role__c,
            Global_Role_L1__c, Global_Role_L2__c, Hire_Date__c, em_Industry_Focused__c, Is_Trainer__c,
            Job_Code__c, Job_Family__c, Job_Grade__c, L1_Cloud__c, L1_Product__c, L2_Cloud__c,
            Language_Proficiency__c, Last_Trailhead_Sync__c, Macro_Segment__c, Manager__c, Manager_Email__c,
            Manager_Employee_Number__c, Manager_Level__c, Manager_Type__c, Membership__c, Org62_User_ID__c,
            Original_Hire_Date__c, OU_Name__c, OU_Leader__c, OwnerId, People_Manager__c, Physical_Location__c,
            Preferred_Language__c, Preferred_Language_Key__c, Primary_Country_of_Coverage__c,
            Primary_Email__c, em_Industry__c, em_Sub_Vertical__c, Role_Level_3__c, Role_Level_4__c,
            Role_Level_5__c, Role_Level_6__c, Sales_Profile_Seller__c, em_Secondary_Industry__c,
            em_Secondary_Sector__c, em_Sector_Focused__c, Seller_Group__c, Selling_Role__c,
            Show_Settings_Modal__c, Show_Walkthrough_Modal__c, SlackId__c, Is_SLM__c, SME_Do_My_Job_DMJ__c,
            SME_Industry__c, SME_Product__c, SME_Skills__c, Status__c, Tenure_Category_in_Days__c,
            Title__c, User__c, Work_Location_Country__c, Work_Location_Region__c, Working_Location__c,
            Working_Region__c, Working_Time_Zone__c
            FROM Learner_Profile__c
            WHERE Id IN :profileIds
        ];

        List<LearnerProfileResponse> responses = new List<LearnerProfileResponse>();
        for (Learner_Profile__c profile : learnerProfiles) {
            LearnerProfileResponse response = new LearnerProfileResponse();
            response.learnerProfileRecord = profile;
            response.summary = 'Retrieved Learner Profile for ID ' + profile.Id;
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Learner Profiles.
     */
    public class LearnerProfileRequest {
        @InvocableVariable(label='GA-FRA Learner Profile ID' description='The Salesforce ID of the Learner Profile record.' required=true)
        public Id learnerProfileId;
    }

    /**
     * Inner class representing the response structure including Learner Profile records and summaries.
     */
    public class LearnerProfileResponse {
        @InvocableVariable(label='GA-FRA Learner Profile Record' description='Detailed Learner Profile record.')
        public Learner_Profile__c learnerProfileRecord;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of the Learner Profile retrieval.')
        public String summary;
    }
}