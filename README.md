# RSSFeedFetchAndSend

This application enables you to retrieve multiple RSS feeds from a source, parse them, and generate corresponding records in Salesforce . Additionally, it sends new feed items (those not already existing) to a pre-defined email address using a custom Mailgun integration through their REST API, ensuring real-time processing with just a 1-minute delay

We have successfully employed this solution to actively retrieve and receive emails containing recent job postings from Upwork in near real-time.

You can also install the unmanaged package   [RSSFeedFetchAndSend Package](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5f000000H3YEAA0)


## How to Use

### Step 1 - Configure Mailgun Email Integration
After successfully registering on Mailgun, obtain the API key.

Navigate to the "RSS Feed Run Config" custom setting and populate the following values:

1. **'Mailgun API Key'**: This is the API key obtained from Mailgun registration.
2. **'Mailgun Endpoint URL'**: This is the Mailgun API endpoint to be triggered for sending emails.

### Step 2 - Configure 'RSS Feed Configs' CMDT Record
Under "RSS Feed Configs" custom metadata records, create at least one record (fetch job configuration).

1. Provide values for **'Label'** and **'RSS Feed Config Name'** (DeveloperName), categorizing the fetch job.
2. **'RSS Feed URL'**: Enter the RSS Feed URL.
3. **'Order Of Processing'**: Assign a numeric value indicating the processing order for multiple RSS Feed Configurations.
4. **'From Name And Email'**: Specify the name and email address from which emails will be sent to 'To Email', e.g., "Dore Mon dummy@example.com".
5. **'To Email'**: Enter the email address to which details of new feed items will be sent.

### Step 3 - Schedule Feed Fetch Scheduler Job

Schedule the `RSSFeedFetchSchedulerJob` job in the Salesforce Developer Console using the following code:


```java
// Schedule the job just after 1 minute from now
Datetime now = Datetime.now();
Datetime scheduledTime = now.addMinutes(1);
String cronExp = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
// Schedule the job
System.schedule('RSSFeedFetchJob_' + Datetime.now().getTime()/1000, cronExp, new RSSFeedFetchSchedulerJob());
```
This code schedules the job one minute from the current time, and you can adjust the scheduling logic as needed.