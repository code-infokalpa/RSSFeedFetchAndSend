global class ScheduleDeleteOldFeedEntries implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        // Schedule the batch job to run
        DeleteOldFeedEntriesBatch deleteBatch = new DeleteOldFeedEntriesBatch();
        Integer batchSize = 200; // Adjust batch size as needed

        // Schedule the job
        Database.executeBatch(deleteBatch, batchSize);
    }
}
