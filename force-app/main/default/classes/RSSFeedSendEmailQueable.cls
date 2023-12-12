public class RSSFeedSendEmailQueable implements Queueable, Database.AllowsCallouts{
    List<Id> recordIds = new List<Id>();
    
    public RSSFeedSendEmailQueable(List<Id> ids){
        recordIds = ids;
    }
    public void execute(QueueableContext context) {
        List<RSS_Feed_Run_Config__c> rfrcList = [select id, name,Last_Processed_Feed_Category__c,SetupOwnerId,Mailgun_API_Key__c,Mailgun_Endpoint_URL__c from RSS_Feed_Run_Config__c WHERE SetupOwnerId = :UserInfo.getOrganizationId()];
        if(!(rfrcList.size() > 0) ){
            throw new RSSFeedException('No RSS Feed Run Config Found');
        }        
        RSS_Feed_Run_Config__c rfrc = rfrcList[0];
        //RSS_Feed_Config__mdt feedConfig = [SELECT Id, DeveloperName, Label, RSS_Feed_URL__c,To_Mail__c,From_Name_And_Email__c FROM RSS_Feed_Config__mdt WHERE DeveloperName = :rfrc.Last_Processed_Feed_Category__c];
        RSS_Feed_Config__mdt feedConfig = RSSFeedUtil.getFeedConfigByDeveloperName(rfrc.Last_Processed_Feed_Category__c);
        List<RSS_Feed_Entry__c> feeds = [SELECT Id, Name, Feed_Entry_Title__c, Feed_Entry_Description__c, Entry_GUID__c, Publication_Date_Time__c, Entry_Link__c, Feed_Category__c FROM RSS_Feed_Entry__c WHERE Id IN : recordIds];        
        String endpoint = rfrc.Mailgun_Endpoint_URL__c;
        String username = 'api';
        String password = rfrc.Mailgun_API_Key__c; // Replace with your actual token
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
        List<RSS_Feed_Entry__c> feedsToUpdate = new List<RSS_Feed_Entry__c>();
        for(RSS_Feed_Entry__c feed : feeds){
            String body = 'html=' + EncodingUtil.urlEncode(feed.Feed_Entry_Description__c, 'UTF-8') + '&subject='+ EncodingUtil.urlEncode(feed.Feed_Entry_Title__c, 'UTF-8')  + '&from=' + feedConfig.From_Name_And_Email__c; // Your form-urlencoded parameters
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint + '?to=' + feedConfig.To_Mail__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', authHeader);
            request.setBody(body);
            
            // Perform the callout
            HttpResponse response = new Http().send(request);
            
            // Process the response
            if (response.getStatusCode() == 200) {
                // Successful response handling
                System.debug('Response Body: ' + response.getBody());
                feed.Email_Send_Status__c = 'Sent';
                feedsToUpdate.add(feed);
            } else {
                // Error handling
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
            }
            
        }
        if(feedsToUpdate.size() > 0) update feedsToUpdate;
    }
}