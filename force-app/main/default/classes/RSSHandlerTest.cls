@isTest
public class RSSHandlerTest {

    @isTest
    static void testHandleRSS() {

        // Simulate the presence of Custom Metadata record (No DML, as it's not allowed)

        RSS_Feed_Config__mdt simulatedFeedConfig = new RSS_Feed_Config__mdt(
            DeveloperName = 'TestCategory',
            Label = 'Test Category',
            RSS_Feed_URL__c = 'https://example.com/test-rss-feed',
            To_Mail__c = 'test@to.com',
            From_Name_And_Email__c = 'Test Name <test@from.com>'

        );
        RSSFeedUtil.feedConfig = simulatedFeedConfig;
        RSSFeedUtil.feedConfigList = new List<RSS_Feed_Config__mdt>{simulatedFeedConfig};
        // No insert, as we can't perform DML operations on Custom Metadata in a test context.

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test the handleRSS method
        Test.startTest();
        RSSHandler.handleRSS('TestCategory');
        Test.stopTest();

        // Add your assertions here based on the expected behavior
        // For example, query and verify the created RSS_Feed_Entry__c records
        List<RSS_Feed_Entry__c> feedEntries = [SELECT Id FROM RSS_Feed_Entry__c WHERE Feed_Category__c = 'TestCategory'];
        System.assertNotEquals(0, feedEntries.size(), 'Feed entries should be created.');

        // Additional assertions and verifications as needed
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
