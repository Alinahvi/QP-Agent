public class ProvisionLJCleanup2 extends ProvisionLJ implements Database.Batchable<Id>, Database.Stateful {
  String ljAction;

  public ProvisionLJCleanup2(final String ljAction, final Set<Id> userIds) {
    this.ljAction = ljAction;
    this.USER_IDS.addAll(userIds);
  }

  public Iterable<Id> start(final Database.BatchableContext bc) {
    return new List<Id>(this.USER_IDS);
  }

  public void execute(final Database.BatchableContext bc, final Id[] scope) {
    deletePermSets(scope);
    deleteLicenses(scope);
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Phase 2 finished. Starting Phase 3...');
    Database.executeBatch(new ProvisionLJCleanup3('', this.USER_IDS), ProvisionLJCleanup.BATCH_SIZE);
  }

  void deleteLicenses(final Id[] userIds) {
    try {
      delete [SELECT Id
              FROM UserPackageLicense
              WHERE PackageLicenseId = :ProvisionLJ.PACKAGE_LICENSE_ID
              AND UserId = :userIds];
    } catch (DmlException de) {
      System.debug(de);
      throw new DmlException('Error while deleting Users\' Licenses.');
    } catch (QueryException qe) {
      System.debug('No Package Licenses deleted.');
    }
  }

  void deletePermSets(final Id[] userIds) {
    try {
      delete [SELECT Id
              FROM PermissionSetAssignment
              WHERE PermissionSet.Name IN :ProvisionLJ.PERMISSION_SETS AND AssigneeId IN :userIds];
    } catch (QueryException qe) {
      System.debug('No Permission Sets deleted.');
    } catch (Exception e) {
      System.debug(e);
      throw new DmlException('Error while deleting Users\' Permision Sets.');
    }
  }
}