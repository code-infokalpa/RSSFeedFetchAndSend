@isTest
public class RSSFeedFetchStartQueueableTest {

    @isTest
    static void testRSSFeedFetchStartQueueable() {
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
        // Start the Queueable job
        Test.startTest();
        RSSFeedFetchStartQueueable queueable = new RSSFeedFetchStartQueueable('TestCategory');
        queueable.execute(null);
        Test.stopTest();

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
