/**
 * @author atg
 * @date   06/30/2022
 * @description LEM-2081 This is the service interface for Integrating Business_Reference__c objects
 */
public interface IBusReferenceIntegrationService {
    /**
     * @description create platform Events to integrate Business_Reference__c objects
     * @param businessReferenceList
     * @param topic
     */
    void createIntegrationPlatformEvents(
        List<Business_Reference__c> businessReferenceList,
        String topic
    );

    /**
     * @description It is used to handle Notifier Events to further process
     * Business Reference Ids from the received payload.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description It initiates External Id field update using the passed corporateAccountIds.
     * @param corporateAccountIds
     */
    void processDriveWithholding(List<Id> corporateAccountIds);
}