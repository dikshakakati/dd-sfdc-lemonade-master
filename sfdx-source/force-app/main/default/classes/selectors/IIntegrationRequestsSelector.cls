/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Interface for IIntegrationRequestsSelector selector class methods.
 */
public interface IIntegrationRequestsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting Integration_request__c by the Ids.
     * @param integrationRequestIds
     * @return List<Integration_request__c>
     */
    List<Integration_request__c> selectById(Set<Id> integrationRequestIds);
    /**
     * @description It is used for getting Integration_request__c by the onboardingIds.
     * @param onboardingIds
     * @param status
     * @return List<Integration_request__c>
     */
    List<Integration_request__c> selectByOnboardingId(
        Set<String> onboardingIds,
        Set<String> status
    );
    /**
     * @description It is used for getting parent IntegrationRequests by the passed onbaordingIds.
     * @param onboardingIds
     * @return List<Integration_request__c>
     */
    List<Integration_Request__c> selectParentByOnboardingId(Set<String> onboardingIds);
    /**
     * @description It is used for getting Integration_request__c by the batchIds.
     * @param batchIds
     * @return List<Integration_request__c>
     */
    List<Integration_Request__c> selectByBatchId(Set<String> batchIds);
    /**
     * @description Method for querying integration records records when you know their status and org to process.
     * @param status status of the integration request record
     * @param sfdcOrg sfdcOrg org to process the integration requests.
     * @param days days last modified should be with last 5 days.
     * @return A list of integration requests
     */
    List<Integration_Request__c> selectIntegrationRequestsByStatusAndOrg(
        Set<String> status,
        Set<String> sfdcOrg,
        Integer days
    );

    /**
     * @description
     * @param integrationTypes
     * @param integrationRequestDeleteOlderThanNMonths
     * @return List<Integration_request__c>
     */
    List<Integration_Request__c> selectIntegrationRequestsByIntegrationType(
        Set<String> integrationTypes,
        DateTime integrationRequestDeleteOlderThanNMonths
    );

    /**
     * @description It is used for getting parent IntegrationRequests by the passed onbaordingIds.
     * @param onboardingIds
     * @return List<Integration_request__c>
     */
    List<Integration_Request__c> selectIntegrationRequestsByOnboardingId(Set<Id> onboardingIds);

    /**
     * @description This method is used for getting the Integration Requests by Type in the batch mode
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectFailedIntegrationRequestsForMdsStoreSync();

    /**
     * @description It is used for getting Integration_request__c by the Ids.
     * @param integrationRequestIds
     * @return List<Integration_request__c>
     */
    List<Integration_request__c> selectByIdForParentIntegration(Set<Id> integrationRequestIds);
}