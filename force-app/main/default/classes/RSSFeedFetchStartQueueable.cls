public with sharing class RSSFeedFetchStartQueueable implements Queueable, Database.AllowsCallouts  {
    String category;
    public RSSFeedFetchStartQueueable(String cat){
        category = cat;
    }
    public void execute(QueueableContext context) {
        // Your logic for the asynchronous processing goes here
        RSSHandler.handleRSS(category);
    }
}