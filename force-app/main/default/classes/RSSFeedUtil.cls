public with sharing class RSSFeedUtil {
    @TestVisible public static List<RSS_Feed_Config__mdt> feedConfigList;
    @TestVisible public static RSS_Feed_Config__mdt feedConfig;

    
    public static List<RSS_Feed_Config__mdt> getAllFeedConfigCMDT(){
        if(feedConfigList != null){
            return feedConfigList;
        }
        else{
            List<RSS_Feed_Config__mdt> feedConfigList = [SELECT Id, Label, DeveloperName, From_Name_And_Email__c,
                Order_Of_Processing__c, RSS_Feed_URL__c, To_Mail__c FROM RSS_Feed_Config__mdt ORDER BY Order_Of_Processing__c ASC];
            if(feedConfigList == null || feedConfigList.size() == 0){
                throw new RSSFeedException('No RSS Feed Configs Found');
            }
            return feedConfigList;
        }

    }

    public static RSS_Feed_Config__mdt getFeedConfigByDeveloperName(String developerName){
        if(feedConfig != null){
            return feedConfig;
        }
        else{
            List<RSS_Feed_Config__mdt> feedConfigList = [SELECT Id, Label, DeveloperName, From_Name_And_Email__c,
                Order_Of_Processing__c, RSS_Feed_URL__c, To_Mail__c FROM RSS_Feed_Config__mdt WHERE DeveloperName = :developerName];
            if(feedConfigList == null || feedConfigList.size() == 0){
                throw new RSSFeedException('No RSS Feed Config Found');
            }
            return feedConfigList[0];
        }

    }
}