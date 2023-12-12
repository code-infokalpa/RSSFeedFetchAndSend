public class RSSFeedEntryTriggerHandler {
    
    public static void processFeedEntries(List<RSS_Feed_Entry__c> feeds){
        List<Id> ids = new List<Id>();
        for(RSS_Feed_Entry__c feed : feeds){
            ids.add(feed.id);
        }
        
        System.enqueueJob(new RSSFeedSendEmailQueable(ids));
    }
    

}