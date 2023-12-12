public class RSSFeedFetchSchedulerJob implements Schedulable {

    public static String category;

    public RSSFeedFetchSchedulerJob(String catName){
        category = catName;
    }
    public RSSFeedFetchSchedulerJob(){
        category = null;
    }
    public void execute(SchedulableContext sc) {
        // Your scheduled job logic goes here
        System.enqueueJob(new RSSFeedFetchStartQueueable(getNextFeedFetchJobName()));
        scheduleMeAfterOneMinute();
    }
    
    private static void scheduleMeAfterOneMinute(){
        Datetime now = Datetime.now();
        Datetime scheduledTime = now.addMinutes(1);
        
        String cronExp = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
        
        // Schedule the job
        System.schedule('RSSFeedFetchJob_' + Datetime.now().getTime()/1000, cronExp, new RSSFeedFetchSchedulerJob(category));
    }

    private static String getNextFeedFetchJobName(){
        List<RSS_Feed_Config__mdt> feedConfigList = RSSFeedUtil.getAllFeedConfigCMDT();
        String nextJob;
        if(String.isEmpty(category)){
            return feedConfigList[0].DeveloperName;
        }
        for(Integer i=0; i<feedConfigList.size(); i++){
            if(feedConfigList[i].DeveloperName == category){
                if(i == feedConfigList.size()-1){
                    nextJob = feedConfigList[0].DeveloperName;
                }
                else{
                    nextJob = feedConfigList[i+1].DeveloperName;
                }
                break;
            }
        }
        return nextJob;
        
    }
}