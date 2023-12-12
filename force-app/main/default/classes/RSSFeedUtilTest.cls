@isTest
public with sharing class RSSFeedUtilTest {
    @isTest
    static void testGetAllFeedConfigWithNoCMDTRecords() {

        Test.startTest();
        try{
            List<RSS_Feed_Config__mdt> result = RSSFeedUtil.getAllFeedConfigCMDT();
        }
        catch(Exception ex){
            System.assert(ex instanceof RSSFeedException, 'RSSFeedException should be thrown');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetRecByDeveloperNameFeedConfigWithNoCMDTRecord() {

        Test.startTest();
        try{
            RSS_Feed_Config__mdt result = RSSFeedUtil.getFeedConfigByDeveloperName('test');
        }
        catch(Exception ex){
            System.assert(ex instanceof RSSFeedException, 'RSSFeedException should be thrown');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetAllFeedConfigWithCMDTRecords() {


        Test.startTest();
        RSS_Feed_Config__mdt simulatedFeedConfig = new RSS_Feed_Config__mdt(
            DeveloperName = 'TestCategory',
            Label = 'Test Category',
            RSS_Feed_URL__c = 'https://example.com/test-rss-feed',
            To_Mail__c = 'test@to.com',
            From_Name_And_Email__c = 'Test Name <test@from.com>'

        );
        RSSFeedUtil.feedConfig = simulatedFeedConfig;
        RSSFeedUtil.feedConfigList = new List<RSS_Feed_Config__mdt>{simulatedFeedConfig};
        List<RSS_Feed_Config__mdt> result;
        result = RSSFeedUtil.getAllFeedConfigCMDT();
        System.assert(result.size() > 0, 'No RSS Feed Configs Found');
        Test.stopTest();
    }

    @isTest
    static void testGetRecByDeveloperNameFeedConfigWithCMDTRecord() {

        Test.startTest();
        RSS_Feed_Config__mdt simulatedFeedConfig = new RSS_Feed_Config__mdt(
            DeveloperName = 'TestCategory',
            Label = 'Test Category',
            RSS_Feed_URL__c = 'https://example.com/test-rss-feed',
            To_Mail__c = 'test@to.com',
            From_Name_And_Email__c = 'Test Name <test@from.com>'

        );
        RSSFeedUtil.feedConfig = simulatedFeedConfig;
        RSS_Feed_Config__mdt result = RSSFeedUtil.getFeedConfigByDeveloperName('test');
        System.assert(result != null, 'No RSS Feed Config Found');
        Test.stopTest();
    }

}