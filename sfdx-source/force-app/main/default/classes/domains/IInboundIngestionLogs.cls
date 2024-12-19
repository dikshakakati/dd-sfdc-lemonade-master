/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Domain interface for Inbound Ingestion Logs.
 */
public interface IInboundIngestionLogs extends fflib_ISObjects {
    /**
     * @description It is used to initiate the SSMO records creation in
     * Salesforce by publishing platform events for onboarding event.
     * @param eventName
     */
    void initiateSSMOOnboardingRecordsCreation(String eventName);

    /**
     * @description It is used to initiate the SSOB records creation in Salesforce by publishing
     * platform events for onboarding event.
     * @param eventName
     */
    void initiateSSOBOnboardingRecordsCreation(String eventName);

    /**
     * @description RESSMO Onboarding Instant Ingestor Initiation
     * @author VenkateshDD | 07-23-2024
     * @param eventName
     **/
    void initiateRESSMOOnboardingRecordsCreation(String eventName);

    /**
     * @description It is used to initiate the SSMO records creation in Salesforce
     * by publishing platform events for fallout event.
     * @param eventName
     */
    void initiateSSMOFalloutRecordsCreation(String eventName);

    /**
     * @description It rolls up the Status and Error message values from child
     * to parent ingestion log records.
     */
    void rollupStatusAndErrorMessage();

    /**
     * @description It is used to update the Inbound Ingestion Log records with Success or Failure status.
     * @param ingestionLogsIds
     * @param status
     * @param errorMessage
     * @param stackTrace
     * @param businessErrorMessage
     */
    void updateIngestionLogsWithSucessOrFailureStatus(
        Set<Id> ingestionLogsIds,
        String status,
        String errorMessage,
        String stackTrace,
        String businessErrorMessage
    );

    /**
     * @description It creates a child record if the inserted parent record's UUID does not match
     * with any existing UUID
     */
    void createParentAndChildRecordsWhenNoMatchingUUIDFound();

    /**
     * @description It runs validations on before insert of Inbound Ingestion log records.
     */
    void onBeforeInsertHandleFalloutIngestionLogs();

    /**
    * @description Update Business Id for RESSSMO Onboarding Event
    * @author VenkateshDD | 10-03-2024
    **/
    void onBeforeInsertHandleRESSMOIngestionLogs();

    /**
     * @description It is used to initiate the Mx Portal records creation in
     * Salesforce by publishing platform events for new store expansion.
     * @param eventName
     */
    void initiateMxPortalNSERecordsCreation(String eventName);

    /**
     * @description It is used to initiate the Mx Portal amendment records creation in
     * Salesforce by publishing platform events for storefront addition, package switch and A&Ps.
     * @param eventName
     */
    void initiateMxPortalAmendments(String eventName);

    /**
     * @description It is used to update failed inbound ingestion log status to pending
     */
    void updateFailedLogsWithPendingStatus();
    /**
     * @description It is used to initiate the Retry SSMO records creation in Salesforce by publishing platform events
     * for onboarding event.
     */
    void initiateRetrySSMORecordsCreation();

    /**
     * @description It is used to initiate retry RESSMO process in Salesforce by publishing
     * platform events for the corrosponding failed step.
     * @JIRA #LEM-21402
     */
    void initiateRetryRESSMORecordsCreation();

    /**
     * @description Initiates the Ads and Promos record creation by publishing platform event
     * @param eventName
     */
    void initiateAdsPromosAmendment(String eventName);

    /**
     * @description It is used to initiate the Retry SSMO records creation in Salesforce by publishing platform events
     * for onboarding event.
     */
    void initiateRetrySSOBRecordsCreation();

    /**
     * @description It is used to initiate the Retry SSMO records creation in Salesforce by publishing platform events
     * for onboarding event.
     */
    void initiateRetryMxPortalRecordsCreation();
}