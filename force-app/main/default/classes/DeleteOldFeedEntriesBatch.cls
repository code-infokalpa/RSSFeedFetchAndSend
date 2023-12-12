public class DeleteOldFeedEntriesBatch implements Database.Batchable<SObject>, Database.Stateful {

    private static final Integer BATCH_SIZE = 200; // Adjust batch size as needed

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Query for RSS_Feed_Entry__c records older than one week
        Date oneWeekAgo = System.today().addDays(-7);
        String query = 'SELECT Id FROM RSS_Feed_Entry__c WHERE CreatedDate < :oneWeekAgo';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<RSS_Feed_Entry__c> feedEntries) {
        // Permanently delete the records
        delete feedEntries;
    }

    public void finish(Database.BatchableContext context) {
        // Perform any post-processing logic if needed
    }
}
