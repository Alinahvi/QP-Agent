public virtual class ProvisionLJCleanup extends ProvisionLJ implements Database.Batchable<User>, Schedulable, Database.Stateful {
  public static final Integer BATCH_SIZE = 200;

  @AuraEnabled
  public static void manual(final String[] emails) {
    try {
      String filter = '(';

      while (emails.size() > 0) {
        if (!filter.equals('(')) {
          filter += ',';
        }

        filter += '\'' + emails.remove(0)+'\'';
      }

      filter += ')';

      fireBatchJob('SELECT Id FROM User WHERE Email IN ' + filter, '');
    } catch (Exception e) {
      System.debug(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void processFile(final String data) {
    try {
      final Id[] userIds = new List<Id>(new Map<Id, sObject>(FileUtility.parseCSVToRecords(data, 'User')).keySet());

      if (userIds.size() == 0) {
        throw new ListException('No User records with an ID field were uploaded in CSV.');
      }

      String queryList = '(';

      while (userIds.size() > 0) {
        if (!queryList.equals('(')) {
          queryList += ',';
        }
        queryList += '\'' + userIds.remove(0) + '\'';
      }

      queryList += ')';

      System.debug(queryList);

      fireBatchJob('SELECT Id FROM User WHERE Id IN ' + queryList, '');
    }
    catch (Exception e) {
      System.debug(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void execute(SchedulableContext sc) {
    fireBatchJob('', '');
  }

  public static void fireBatchJob(final String query, final String ljAction) {
    try {
      Database.executeBatch(new ProvisionLJCleanup(query, ljAction), BATCH_SIZE);
    } catch (Exception e) {
      System.debug(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  // ------------------------------ Phase 1 of Batch Job -----------------------
  public String query = 'SELECT Id FROM User WHERE IsActive = true';
  public final String ljAction;

  public ProvisionLJCleanup(final String query, final String action) {
    if (!String.isBlank(query)) {
      this.query = query;
    }

    this.query += ' LIMIT 50000';

    System.debug(this.query);

    this.ljAction = action;
  }

  public Iterable<User> start(Database.BatchableContext bc) {
    return (User[]) Database.query(query);
  }

  public void execute(Database.BatchableContext bc, User[] scope) {
    final AutoProvisionLJCleanup__c[] toBeInserted = new AutoProvisionLJCleanup__c[]{};

    for (User user : scope) {
      this.USER_IDS.add(user.Id);
      toBeInserted.add(new AutoProvisionLJCleanup__c(User__c = user.Id));
    }

    insert toBeInserted;
  }

  public void finish(Database.BatchableContext bc) {
    Database.executeBatch(new ProvisionLJCleanup2('', this.USER_IDS), BATCH_SIZE);
  }
}