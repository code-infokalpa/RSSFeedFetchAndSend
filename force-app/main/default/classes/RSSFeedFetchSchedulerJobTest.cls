@isTest
public class RSSFeedFetchSchedulerJobTest {

    @isTest
    static void testRSSFeedFetchSchedulerJobWithCategory() {
        // Insert test data - Feed configuration
        // Insert test data - Feed entries
        RSS_Feed_Config__mdt simulatedFeedConfig = new RSS_Feed_Config__mdt(
            DeveloperName = 'TestCategory',
            Label = 'Test Category',
            RSS_Feed_URL__c = 'https://example.com/test-rss-feed',
            To_Mail__c = 'test@to.com',
            From_Name_And_Email__c = 'Test Name <test@from.com>'

        );
        RSSFeedUtil.feedConfig = simulatedFeedConfig;
        RSSFeedUtil.feedConfigList = new List<RSS_Feed_Config__mdt>{simulatedFeedConfig};
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start the scheduled job
        Test.startTest();
        RSSFeedFetchSchedulerJob schedulerJob = new RSSFeedFetchSchedulerJob('TestCategory');
        String jobId = System.schedule('Test Schedule', '0 0 0 * * ?', schedulerJob);
        Test.stopTest();

        // Verify that the job has been scheduled
        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, cronTrigger, 'Job should be scheduled');

        // Optionally, assert other conditions or check logs as needed
    }

    @isTest
    static void testRSSFeedFetchSchedulerJobWithoutCategory() {
        // Insert test data - Feed configuration
        // Insert test data - Feed entries
        RSS_Feed_Config__mdt simulatedFeedConfig = new RSS_Feed_Config__mdt(
            DeveloperName = 'TestCategory',
            Label = 'Test Category',
            RSS_Feed_URL__c = 'https://example.com/test-rss-feed',
            To_Mail__c = 'test@to.com',
            From_Name_And_Email__c = 'Test Name <test@from.com>'

        );
        RSSFeedUtil.feedConfig = simulatedFeedConfig;
        RSSFeedUtil.feedConfigList = new List<RSS_Feed_Config__mdt>{simulatedFeedConfig};
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start the scheduled job
        Test.startTest();
        RSSFeedFetchSchedulerJob schedulerJob = new RSSFeedFetchSchedulerJob();
        String jobId = System.schedule('Test Schedule', '0 0 0 * * ?', schedulerJob);
        Test.stopTest();

        // Verify that the job has been scheduled
        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, cronTrigger, 'Job should be scheduled');

        // Optionally, assert other conditions or check logs as needed
    }


        // Inner class to mock HTTP response
        private class MockHttpResponseGenerator implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req) {
                HttpResponse res = new HttpResponse();
                res.setBody('<rss><channel><item><title>Test Item</title><description>Test Description</description><guid>123456</guid><pubDate>Thu, 01 Dec 2022 12:00:00 +0000</pubDate><link>https://example.com/test-item</link></item></channel></rss>');
                res.setStatusCode(200);
                return res;
            }
        }
}
