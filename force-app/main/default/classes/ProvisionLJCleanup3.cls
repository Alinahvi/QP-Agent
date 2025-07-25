public class ProvisionLJCleanup3 extends ProvisionLJ implements Database.Batchable<AutoProvisionLJCleanup__c> {
  String ljAction;
  Set<Id> usersWithPermSets = new Set<Id>();
  Set<Id> usersWithLicenses = new Set<Id>();
  Set<Id> usersWithLurniture = new Set<Id>();

  public ProvisionLJCleanup3(final String ljAction, final Set<Id> userIds) {
    this.ljAction = ljAction;
    this.USER_IDS.addAll(userIds);
  }

  public Iterable<AutoProvisionLJCleanup__c> start(Database.BatchableContext bc) {
    return [SELECT Id,
                   Removed_Lurniture_User__c,
                   User__c
            FROM AutoProvisionLJCleanup__c
            WHERE Complete__c != true
            AND User__c = :USER_IDS
            LIMIT 50000];
  }

  public void execute(Database.BatchableContext bc, AutoProvisionLJCleanup__c[] scope) {
    final Set<Id> userIds = new Set<Id>();

    for(AutoProvisionLJCleanup__c record: scope) {
      userIds.add(record.User__c);
    }

    deleteLurnitureUsers(userIds);
    getUsersWithRecords(userIds);

    for (Integer i = 0; i < scope.size(); i++) {
      scope[i].Removed_Lurniture_User__c = !usersWithLurniture.contains(scope[i].User__c);
      scope[i].Removed_Permission_Sets__c = !usersWithPermSets.contains(scope[i].User__c);
      scope[i].Removed_License__c = !usersWithLicenses.contains(scope[i].User__c);
      scope[i].Complete__c = true;
    }

    update scope;
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Phase 3 finished...');
  }

  void getUsersWithRecords(final Set<Id> userIds) {
    for (PermissionSetAssignment record: [SELECT AssigneeId
              FROM PermissionSetAssignment
              WHERE PermissionSet.Name IN :ProvisionLJ.PERMISSION_SETS AND AssigneeId IN :userIds]) {
      usersWithPermSets.add(record.AssigneeId);
    }

    for (UserPackageLicense record: [SELECT UserId FROM UserPackageLicense WHERE PackageLicenseId = :ProvisionLJ.PACKAGE_LICENSE_ID AND UserId = :userIds]) {
      usersWithLicenses.add(record.UserId);
    }

    for (LRN__Lurniture_User__c record: [SELECT LRN__User__c FROM LRN__Lurniture_User__c WHERE LRN__User__c = :userIds]) {
      usersWithLurniture.add(record.LRN__User__c);
    }
  }

  void deleteLurnitureUsers(final Set<Id> userIds) {
    try {
      delete [SELECT Id
              FROM LRN__Lurniture_User__c
              WHERE LRN__User__c = :userIds];
    } catch (QueryException qe) {
      System.debug('No Stand and Deliver Users deleted.');
    } catch (DmlException de) {
      System.debug(de);
      throw new DmlException('Error while deleting Stand and Deliver Users.');
    }
  }
}