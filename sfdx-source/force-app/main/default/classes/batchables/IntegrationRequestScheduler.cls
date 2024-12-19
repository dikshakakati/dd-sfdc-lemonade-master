/**
 * @author DoorDash
 * @date 06/20/2023
 * @description IntegrationRequestSchedulerClass To retry integration requests
 */
public inherited sharing class IntegrationRequestScheduler implements Schedulable {
    private static final Set<String> SFDC_STATUS = new Set<String>{ 'Pending' };
    private static final Set<String> SFDC_ORG = new Set<String>{ 'Lemonade' };
    private static final String JOB_NAME = 'IntegrationRequest%';
    private static final String INTEGRATION_REQUEST_JOB_FREQUENCY_MINUTES = 'IntegrationRequestJobFrequency';
    private static final String INTEGRATION_REQUEST_JOB_QUERY_LAST_N_DAYS = 'IntegrationRequestQueryLostNDays';
    private static final String INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS = 'IntegrationRequestDeleteOlderThanNMonths'; // @jira LEM-10464
    private static final String INTEGRATION_REQUEST_DELETE_TYPES = 'IntegrationRequestDeleteTypes'; // @jira LEM-10464
    private static final String INTEGRATION_TYPE_ACTIVATION_CHECKLIST = 'Activation Checklist';
    private static final Set<String> INTEGRATION_TYPES_TO_SKIP_RETRY = new Set<String>{
        INTEGRATION_TYPE_ACTIVATION_CHECKLIST
    };
    private static final String RUN_AT_PARTICULAR_TIME = 'RunAtParticularTimeLines';
    private Integer integrationRequestJobFrequency;
    private Integer integrationRequestQueryLostNDays;
    private Integer integrationRequestDeleteOlderThanNMonths; // @jira LEM-10464
    private Set<String> integrationRequestDeleteTypes; // @jira LEM-10464
    private set<String> runAtParticularTime; // @jira LEM-10464

    /**
     * @description execute the process.
     * @param sc
     **/
    public void execute(SchedulableContext sc) {
        List<Integration_Request__c> integrationRequestsEligibleForRetry = new List<Integration_Request__c>();
        List<Integration_Request__c> intReq = integrationRequestsSelector.newInstance()
            .selectIntegrationRequestsByStatusAndOrg(
                SFDC_STATUS,
                SFDC_ORG,
                integrationRequestQueryLostNDays
            );
        for (Integration_Request__c eachIntegrationRequest : intReq) {
            if (
                !INTEGRATION_TYPES_TO_SKIP_RETRY.contains(
                    eachIntegrationRequest.Integration_Type__c
                )
            ) {
                integrationRequestsEligibleForRetry.add(eachIntegrationRequest);
            }
        }
        if (!integrationRequestsEligibleForRetry.isEmpty()) {
            IntegrationRequestsService.publishEventsForProcessing(
                new Map<Id, Integration_Request__c>(),
                shuffleIntegrationRecords(integrationRequestsEligibleForRetry),
                true
            );
        }

        delSchedule(); // delete this instance of the job
        setSchedule(); // schedule a new instance of the job

        // Run deleteOldRecords at 6:00 PM every day LEM-10464
        // Allowing the deleteOldRecords() method run inrespective of time while running test classes
        if (Test.isRunningTest()) {
            IntegrationRequestsService.deleteOldRecords();
        } else {
            Boolean isRunningAtParticularTime = false;
            // Fetching the set of timelines from metadata which are comma separated to determine when the deleteOldRecords() method should be executed.
            for (String timeRec : runAtParticularTime) {
                if (
                    System.now().hour() == Integer.valueOf(timeRec) && !(isRunningAtParticularTime)
                ) {
                    isRunningAtParticularTime = true;
                }
            }
            if (isRunningAtParticularTime) {
                IntegrationRequestsService.deleteOldRecords();
            }
        }
    }

    /**
     * @description shuffle the integration requests records so that when retrying records will not go with the same sequence.
     * shuffling the records so that because exception with one record other records will not fail continuously
     * @param intRequests  A Set of product status values to filter.
     * @return Set<String> A Set of batch IDs of Integration_Request__c records not in the specified product status.
     */
    public virtual List<Integration_Request__c> shuffleIntegrationRecords(
        List<Integration_Request__c> intRequests
    ) {
        Integer intReqSize = intRequests.size();
        for (Integer i = intReqSize - 1; i > 0; i--) {
            Integer j = Math.mod(Math.round(Math.random() * (i + 1)), intReqSize);
            // Swap intRequests[i] and intRequests[j]
            Integration_Request__c temp = intRequests[i];
            intRequests[i] = intRequests[j];
            intRequests[j] = temp;
        }
        return intRequests;
    }

    /**
     * @description delete the current schedule
     **/
    private void delSchedule() {
        try {
            for (
                CronTrigger ct : CronTriggersSelector.newInstance()
                    .selectCronTriggerJobByName(JOB_NAME)
            ) {
                System.abortJob(ct.id); // cancel all scheduled runs of this class
            }
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description add the schedule for the next iteration
     **/
    private void setSchedule() {
        try {
            DateTime nextRun = System.now().addMinutes(integrationRequestJobFrequency);
            String cronExp = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';
            String jobName = 'IntegrationRequest ' + nextRun.format('hh:mm a');
            IntegrationRequestScheduler job = new IntegrationRequestScheduler();
            System.schedule(jobName, cronExp, job);
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description get static static configuration from metadata
     */
    private void collectStaticConfigurations() {
        this.integrationRequestJobFrequency = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_JOB_FREQUENCY_MINUTES)
                .Configuration_Value__c
        );
        this.integrationRequestQueryLostNDays = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_JOB_QUERY_LAST_N_DAYS)
                .Configuration_Value__c
        );

        // Additional configurations for deleteOldRecords @jira LEM-10464
        this.integrationRequestDeleteOlderThanNMonths = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_DELETE_OLDER_THAN_N_MONTHS)
                .Configuration_Value__c
        );
        this.integrationRequestDeleteTypes = new Set<String>(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_DELETE_TYPES)
                .Configuration_Value__c.split(',')
        );
        this.runAtParticularTime = new Set<String>(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(RUN_AT_PARTICULAR_TIME)
                .Configuration_Value__c.split(',')
        );
    }
    /**
     * @description constructor
     */
    public IntegrationRequestScheduler() {
        collectStaticConfigurations();
    }
}