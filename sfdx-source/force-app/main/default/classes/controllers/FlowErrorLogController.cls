/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Controller class for flow error handling.
 */
public with sharing class FlowErrorLogController {
    private static final String STATUS_FAILED = 'Failed';
    private static final String UPDATE_AGREEMENTS_MERCHANTS_FLOW = 'Update_Agreement_Status_and_Merchant_Services';
    /**
     * @description To log errors from flow.
     * @param errorDetailsWithagreementsList
     * @JIRA# LEM-15980
     */
    @InvocableMethod(
        label='Log error from flow'
        description='It creates the logs if there is any error in flow'
    )
    public static void logError(List<ErrorDetails> errorDetailsWithagreementsList) {
        List<Agreement__c> deactivatedAgreementsList = new List<Agreement__c>();
        String error = '';
        for (ErrorDetails eachDetail : errorDetailsWithagreementsList) {
            if (eachDetail.deactivatedAgreementsList != null) {
                deactivatedAgreementsList = eachDetail.deactivatedAgreementsList;
            }
            error = eachDetail.error;
        }
        createLog(deactivatedAgreementsList, error);
    }

    /**
     * @author Doordash
     * @date   07/03/2024
     * @description Inner class for FlowErrorLogController - this is used for the flow inputs
     */
    public class ErrorDetails {
        @InvocableVariable
        public List<Agreement__c> deactivatedAgreementsList;
        @InvocableVariable
        public String error;
    }

    /**
     * @description Create a Log__c for flow record
     * @param allAgreementsList
     * @param error
     */
    public static void createLog(List<Agreement__c> allAgreementsList, String error) {
        Map<Id, Agreement__c> agreementMapList = new Map<Id, Agreement__c>();

        if (allAgreementsList != null) {
            agreementMapList = new Map<Id, Agreement__c>(allAgreementsList);
        }

        Set<Id> agreementsInfo = agreementMapList.keySet();
        String message = error + agreementsInfo;
        Logger.publish(
            LogEntry.newLog(
                UPDATE_AGREEMENTS_MERCHANTS_FLOW,
                UPDATE_AGREEMENTS_MERCHANTS_FLOW,
                message
            )
        );
    }
}