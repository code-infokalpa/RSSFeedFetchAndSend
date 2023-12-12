trigger RSSFeedEntryTrigger on RSS_Feed_Entry__c (after insert) {

    RSSFeedEntryTriggerHandler.processFeedEntries(Trigger.new);
}