@isTest
public class DeleteOldFeedEntriesBatchTest {

    @isTest
    static void testDeleteOldFeedEntriesBatch() {
        RSS_Feed_Run_Config__c customSettingRecord = new RSS_Feed_Run_Config__c();
        customSettingRecord.Last_Processed_Feed_Category__c = 'category';
        insert customSettingRecord;

        RSS_Feed_Config__mdt simulatedFeedConfig = new RSS_Feed_Config__mdt(
            DeveloperName = 'TestCategory',
            Label = 'Test Category',
            RSS_Feed_URL__c = 'https://example.com/test-rss-feed',
            To_Mail__c = 'test@to.com',
            From_Name_And_Email__c = 'Test Name <test@from.com>'

        );
        RSSFeedUtil.feedConfig = simulatedFeedConfig;
        RSSFeedUtil.feedConfigList = new List<RSS_Feed_Config__mdt>{simulatedFeedConfig};

        // Insert test data - Feed entries older than one week
        List<RSS_Feed_Entry__c> feedEntries = new List<RSS_Feed_Entry__c>();
        for (Integer i = 0; i < 10; i++) {
            RSS_Feed_Entry__c feedEntry = new RSS_Feed_Entry__c(
                Feed_Entry_Title__c = 'Test Entry ' + i,
                Publication_Date_Time__c = System.now().addDays(-8),
                Entry_Link__c = 'https://example.com/test-entry-' + i,
                Feed_Category__c = 'TestCategory',
                Feed_Entry_Description__c = 'Test Description ' + i,
                Entry_GUID__c = '123456'+i
            );
            feedEntries.add(feedEntry);
        }
        insert feedEntries;
        (new DeleteOldFeedEntriesBatch()).start(null);
        (new DeleteOldFeedEntriesBatch()).finish(null);
        (new DeleteOldFeedEntriesBatch()).execute(null, feedEntries);

        // Verify that the records were deleted
        List<RSS_Feed_Entry__c> deletedFeedEntries = [SELECT Id FROM RSS_Feed_Entry__c WHERE CreatedDate < :System.today().addDays(-7)];
        System.assertEquals(0, deletedFeedEntries.size(), 'Feed entries should be deleted.');

    }
}
