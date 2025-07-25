public with sharing class AHSessionTrainer_GetTeamSchedule {

    public class GetTeamScheduleRequest {
        // A dummy variable to make this a valid Invocable type.
        // This input is not used by the logic but is required by the platform.
        @InvocableVariable(label='Start Request' description='Set to true to run the action.')
        public Boolean startRequest;
    }

    public class TeamMemberSchedule {
        @InvocableVariable(label='Team Member')
        public Learner_Profile__c teamMember;
        @InvocableVariable(label='Upcoming Assignments')
        public List<Session_Guest__c> upcomingAssignments;
    }

    @InvocableMethod(label='AHSessionTrainer - Get Team Schedule' description='Retrieves the upcoming session schedule for the current user\'s direct reports.' category='AHSessionTrainer')
    public static List<List<TeamMemberSchedule>> getTeamSchedule(List<GetTeamScheduleRequest> requests) {
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): ----- Get Team Schedule Action Started -----');
        
        // Step 1: Log the current user's email
        String managerEmail = UserInfo.getUserEmail();
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): 1. Current User Email from UserInfo: ' + managerEmail);

        if (String.isBlank(managerEmail)) {
            System.debug('AHSessionTrainer DEBUG (TeamSchedule): EXITING - Could not get email for current user.');
            return new List<List<TeamMemberSchedule>>();
        }

        // Step 2: Log the result of the Learner Profile (team member) query
        List<Learner_Profile__c> teamMembers = [
            SELECT Id, Name 
            FROM Learner_Profile__c 
            WHERE Manager_Email__c = :managerEmail
        ];
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): 2. Found ' + teamMembers.size() + ' team members with that manager email.');

        if (teamMembers.isEmpty()) {
            System.debug('AHSessionTrainer DEBUG (TeamSchedule): EXITING - No team members found.');
            return new List<List<TeamMemberSchedule>>();
        }
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): 2a. Team Member IDs: ' + JSON.serialize(new Map<Id, Learner_Profile__c>(teamMembers).keySet()));
        
        // Step 3: Log the result of the Session Guest query
        Map<Id, Learner_Profile__c> teamMembersMap = new Map<Id, Learner_Profile__c>(teamMembers);
        List<Session_Guest__c> allAssignments = [
            SELECT Learner_Profile__c, Role__c, Session_Role_Status__c, 
                   Session__r.Name, Session__r.Start_Date__c
            FROM Session_Guest__c
            WHERE Learner_Profile__c IN :teamMembersMap.keySet()
              AND Session__r.Start_Date__c >= TODAY
            ORDER BY Session__r.Start_Date__c
        ];
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): 3. Found ' + allAssignments.size() + ' total upcoming assignments for the team.');

        // Step 4: Group the assignments and prepare the response
        Map<Id, TeamMemberSchedule> scheduleMap = new Map<Id, TeamMemberSchedule>();
        for(Session_Guest__c assignment : allAssignments) {
            Id teamMemberId = assignment.Learner_Profile__c;
            
            if (!scheduleMap.containsKey(teamMemberId)) {
                TeamMemberSchedule memberSchedule = new TeamMemberSchedule();
                memberSchedule.teamMember = teamMembersMap.get(teamMemberId);
                memberSchedule.upcomingAssignments = new List<Session_Guest__c>();
                scheduleMap.put(teamMemberId, memberSchedule);
            }
            
            scheduleMap.get(teamMemberId).upcomingAssignments.add(assignment);
        }
        
        List<TeamMemberSchedule> finalResponse = scheduleMap.values();
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): 4. Final structured response contains ' + finalResponse.size() + ' team members.');
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): 4a. Final response payload: ' + JSON.serializePretty(finalResponse));
        System.debug('AHSessionTrainer DEBUG (TeamSchedule): ----- Get Team Schedule Action Finished -----');
        
        return new List<List<TeamMemberSchedule>>{finalResponse};
    }
}