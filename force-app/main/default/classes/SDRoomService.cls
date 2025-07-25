/**
 * @File Name          : SDRoomService.cls
 * @Description        : Stand & Deliver Room Service wrapper interface. This service should always be used to reference 
 *                       any SD related object
 *                        
 * @Author             : shantanu.bansal@salesforce.com
 * @Group              : 
 * @Last Modified By   : shantanu.bansal@salesforce.com
 * @Last Modified On   : 07-23-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/9/2020   shantanu.bansal@salesforce.com     Initial Version
**/
public interface SDRoomService {


    /**
     *  @Method createStarterRoom
     *  @Description This is to create room for a learner
     *  @param learningAssetId LearningAssetId for which room has to be created. 
     *  @param roomTitle  
     *  @param roomDesc  
     *  @param roomType  
     *  @param roomCapacity  
     *  @param formal  
     *  @param starter create starter room
     *   
     *  @return Id room id of newly created room
     */
    Id createStarterRoom(Id learningAssetId, String roomTitle, String roomDesc, String roomType, Integer roomCapacity , boolean formal, boolean starter);

    /**
     *  @Method cloneRooms
     *  @Description cloneRooms from the room id passed
     *  @param roomToClone room id to be cloned
     *  @param numberOfRooms number of rooms to create
     *  @param targetAudienceId targetAudienceId of the target audience for which rooms need to be created
     *     
     *  @return List<Id> list of newly creaeted rooms
     */
    List<Id> cloneRooms(Id roomToClone, Integer numberOfRooms, Id targetAudienceId);

    /**
     *  @Method findOrCloneRooms
     *  @Description finds existing rooms and clones new rooms needed from the room id passed
     *  @param roomToClone room id to be cloned
     *  @param numberOfLearners number of learners to assign
     *  @param targetAudienceId targetAudienceId of the target audience for which rooms need to be created
     *     
     *  @return Map<Id, Integer> Map of rooms with current occupancy
     */
    Map<Id, Integer> findOrCloneRooms(Id roomToClone, Integer numberOfLearners, Id targetAudienceId);

    /**
     *  @Method assignUsersToRoom
     *  @Description This is to assign users to roooms
     *  @param Map<Id, List<Id>> Map of all rooms with list of users for each room
     *  @param Boolean role of the users to be assigned admin or not
     *   
     *  @return Boolean Success or Failure
     */
    Boolean assignUsersToRoom(Map<Id, List<Id>> usersByRoom, Boolean isAdmin);

    /**
     *  @Method assignUsersToRoom
     *  @Description This is to assign users to roooms
     *  @param Map<Id, List<Id>> Map of all rooms with list of users for each room
     *  @param Boolean role of the users to be assigned admin or not
     *  @param reconcileList reconcile list by adding updating or deleting users
     *   
     *  @return Boolean Success or Failure
     */
    //Boolean assignUsersToRoom(Map<Id, List<Id>> usersByRoom, Boolean isAdmin, Boolean reconcileList);

    /**
     *  @Method assignUsersToRoomByTargetAudience
     *  @Description This is to assign users to rooms by Target Audience
     *  @param targetAudienceId TargetAudienceId to get all rooms created for this TargetAudience
     *  @param users list of users for each room
     *  @param Boolean role of the users to be assigned admin or not
     *  @param isDelete true Delete else Add
     *   
     *  @return Boolean Success or Failure
     */
    Boolean assignUsersToRoomByTargetAudience(Id targetAudienceId, List<Id> users, Boolean isAdmin, Boolean isDelete);

    /**
     *  @Method standAndDeliverSelfEnrollment
     *  @Description This is to assign users who are self enrolling in courses with Stand & Deliver assets to SD Self Enroll room
     *  @param roomToClone room id to be cloned
     *  @param List<Id> assignments to be self enrolled in SD self enroll room
     *   
     *  @return Map<Id, Id> Map of assignmentId with Value roomId
     */
    Map<Id, Id>  standAndDeliverSelfEnrollment(Id roomToClone, List<Id> assignments);

    /**
     *  @Method createBreadCrumbsExpression
     *  @Description This is to create expression to be passed as breadcrumb parameter value to stand & deliver room
     *  @param breadCrumbMap List of Maps, one map for each breadcrumb with 2 entries name & url 
     *                        Example:
     *                          Map<String, String> breadCrumb = new Map<String, String>();
     *                          breadCrumb.put('name', 'Home');
     *                          breadCrumb.put('url', '/');
     *  @param encode encode or not breadcrumb expression returned
     *   
     *  @return String returns the experssion to be passed as breadCrumb value
     */
    String createBreadCrumbsExpression(List<Map<String, String>> breadCrumbMap, Boolean encode);

    /**
     *  @Method standAndDeliverSelfEnrollment
     *  @Description This is to create room url to be passed as breadcrumb paramter value to stand & deliver room
     *  @param roomId  roomId for the stand & deliver url
     *  @param breadCrumbMap List of Maps, one map for each breadcrumb with 2 entries name & url 
     *                        Example:
     *                          Map<String, String> breadCrumb = new Map<String, String>();
     *                          breadCrumb.put('name', 'Home');
     *                          breadCrumb.put('url', '/');
     *  @param encode encode or not breadcrumb expression returned
     *   
     *  @return roomUrl
     */
    String createRoomUrl(Id roomId, List<Map<String, String>> breadCrumbMap, Boolean encode);
      
    /**
     *  @Method removeUsersFromRoom
     *  @Description This is to remove users from rooms 
     *  @param roomId from which members need to be removed
     *  @param learningAssetId for which members need to be removed
     *  @param users list of users for each room
     *  @param Boolean role of the users to be removed admin or not
     *   
     *  @return Boolean Success or Failure
     */
    Boolean removeUsersFromRoom(Id roomId, Id learningAssetId, List<Id> users);

    /**
     *  @Method licensedStandAndDeliverUser
     *  @Description This is to find out if user has stand & deliver license or not
     *  @param userId for whom license need to be checked
     *   
     *  @return has license or not
     */
    Boolean licensedStandAndDeliverUser(Id userId);

}