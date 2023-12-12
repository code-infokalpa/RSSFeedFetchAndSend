public class RSSHandler {
    public static String category;
    
    public static void handleRSS(String catName){
        category = catName;
        RSS_Feed_Config__mdt feedConfig = RSSFeedUtil.getFeedConfigByDeveloperName(catName);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // url that returns the XML in the response body  
        
        req.setEndpoint(feedConfig.RSS_Feed_URL__c);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        updateCustomSetting();
        XmlStreamReader reader = res.getXmlStreamReader();
        List<FeedItemWrapper> fiwList = parseItems(reader);
		List<FeedItemWrapper> newFiwList = getOnlyNewFeedItems(fiwList);
        createNewFeedItems(newFiwList);        
        
        
    }
    
    public static void createNewFeedItems(List<FeedItemWrapper> fiwList){
        List<RSS_Feed_Entry__c> feedEntriesForInsert = new List<RSS_Feed_Entry__c>();
        for(FeedItemWrapper fiw : fiwList){
            if(!String.isEmpty(fiw.guid)){
                RSS_Feed_Entry__c rfe = new RSS_Feed_Entry__c();
                rfe.Feed_Entry_Title__c = fiw.title;
                rfe.Feed_Entry_Description__c = fiw.description;
                rfe.Entry_Link__c = fiw.link;
                rfe.Entry_GUID__c = fiw.guid;
                rfe.Publication_Date_Time__c = datetimeStringToLiteral(fiw.pubDate) ;
                rfe.Feed_Category__c = category;
                feedEntriesForInsert.add(rfe); 
            }            
        }
        if(feedEntriesForInsert.size() > 0) insert feedEntriesForInsert;
    }
    
    public static void updateCustomSetting(){
        try{
            List<RSS_Feed_Run_Config__c> rfrcList = [select id, name,SetupOwnerId from RSS_Feed_Run_Config__c WHERE SetupOwnerId = :UserInfo.getOrganizationId()];
            if(rfrcList.size() > 0 ){
                rfrcList[0].Last_Processed_Feed_Category__c = category;
                update rfrcList[0];
            }
            else{
                RSS_Feed_Run_Config__c customSettingRecord = new RSS_Feed_Run_Config__c();
                customSettingRecord.Last_Processed_Feed_Category__c = category;
                insert customSettingRecord;
            }
        }
        catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
        }
    }
    
    public static List<FeedItemWrapper> getOnlyNewFeedItems(List<FeedItemWrapper> fiwList){
        List<String> newFeedGuidList = new List<String>();
        List<String> existingFeedGuidList = new List<String>();
        List<FeedItemWrapper> truelyNewFeedItems = new List<FeedItemWrapper>();
        for(FeedItemWrapper fiw : fiwList){
            newFeedGuidList.add(fiw.guid);
        }
        List<RSS_Feed_Entry__c> existingFeeds = [SELECT Id, Name, Feed_Entry_Title__c, Entry_GUID__c FROM RSS_Feed_Entry__c WHERE Entry_GUID__c IN :newFeedGuidList];
        for(RSS_Feed_Entry__c feedEntry : existingFeeds){
            existingFeedGuidList.add(feedEntry.Entry_GUID__c);
        }
        for(FeedItemWrapper fiw : fiwList){
            if(!existingFeedGuidList.contains(fiw.guid)){
                truelyNewFeedItems.add(fiw);
            }
        }
        for(FeedItemWrapper fiw : truelyNewFeedItems){
            System.debug('fiw-title= ' + fiw.title);
            System.debug('fiw-guid= ' + fiw.guid);
        }
        return truelyNewFeedItems;
    }
    
    
    public static List<FeedItemWrapper> parseItems(XmlStreamReader reader) {
        List<FeedItemWrapper> fiwList = new List<FeedItemWrapper>();
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            // Start at the bSystem.debug('Queueable job executed!');eginning of the book and make sure that it is a book
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                System.debug('reader.getLocalName()== ' + reader.getLocalName());
                if ('item' == reader.getLocalName()) {
                    System.debug('!!!!!!From Item******');
                    if (reader.hasNext()) {
                        reader.next();
                    } 
                    // Pass the book to the parseBook method (below) 
                    FeedItemWrapper fiw = parseItem(reader);
                    //System.debug('individual-fiw= ' + fiw);
                    fiwList.add(fiw);                    
                }
            }
            // Always use hasNext() before calling next() to confirm 
            // that we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
		return fiwList;
    }
    public static FeedItemWrapper parseItem(XmlStreamReader reader){
        FeedItemWrapper fiw = new FeedItemWrapper();
        String currentAttrib;
        while(reader.getLocalName() != 'item'){
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                //System.debug('Sub.getLocalName()== ' + reader.getLocalName());
                currentAttrib = reader.getLocalName();
            }
            if(reader.getEventType() == XmlTag.CHARACTERS){
                /*System.debug('22Sub.getLocalName()== ' + reader.getLocalName());
                System.debug('L1-Text== ' + reader.getText());
                System.debug('currentAttrib= ' + currentAttrib);*/
                fiw.addValue(currentAttrib, reader.getText());
                currentAttrib = null;
            }            
            if (reader.hasNext()) {
                reader.next();
            }
        }
        return fiw;
    }
    
    private static Datetime datetimeStringToLiteral(String dateTimeString){
        // Split the input string into parts
        List<String> dateTimeParts = dateTimeString.split(' ');
        
        // Map months to numerical representation
        Map<String, String> monthMap = new Map<String, String>{
            'Jan' => '01', 'Feb' => '02', 'Mar' => '03',
                'Apr' => '04', 'May' => '05', 'Jun' => '06',
                'Jul' => '07', 'Aug' => '08', 'Sep' => '09',
                'Oct' => '10', 'Nov' => '11', 'Dec' => '12'
                };
                    
                    // Convert month abbreviation to numerical representation
                    String month = monthMap.get(dateTimeParts[2]);
        
        // Construct a new Datetime object
        Datetime lDatetime = Datetime.newInstance(
            Integer.valueOf(dateTimeParts[3]), // Year
            Integer.valueOf(month), // Month
            Integer.valueOf(dateTimeParts[1]), // Day
            Integer.valueOf(dateTimeParts[4].substring(0, 2)), // Hour
            Integer.valueOf(dateTimeParts[4].substring(3, 5)), // Minute
            Integer.valueOf(dateTimeParts[4].substring(6, 8)) // Second
        );
        
        return lDatetime;
    }
    
    public class FeedItemWrapper{
        public String title;
        public String description;
        public String guid;
        public String pubDate;
        public String link;
        
        public void addValue(String key, String val){
            if(key == 'title'){
                title = val;
            }
            else if(key == 'description'){
                description = val;
            }
            else if(key == 'guid'){
                guid = val;
            }
            else if(key == 'pubDate'){
                pubDate = val;
            }
            else if(key == 'link'){
                link = val;
            }
            else{}
        }
    }

}