@isTest
public class ScheduleDeleteOldFeedEntriesTest {

    @isTest
    static void testScheduleDeleteOldFeedEntries() {
        // Start the scheduled job
        Test.startTest();
        ScheduleDeleteOldFeedEntries scheduler = new ScheduleDeleteOldFeedEntries();
        String jobId = System.schedule('Test Schedule', '0 0 0 * * ?', scheduler);
        Test.stopTest();

        // Verify that the job has been scheduled
        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, cronTrigger, 'Job should be scheduled');

        // Optionally, assert other conditions or check logs as needed
    }
}
