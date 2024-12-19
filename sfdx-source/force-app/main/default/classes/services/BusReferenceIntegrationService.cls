/**
 * @author atg
 * @date   06/30/2022
 * @description This is the service interface for Integrating Business_Reference__c objects
 */
public inherited sharing class BusReferenceIntegrationService implements IHandleNotifierEvents {
    /**
     * @description create platform Events to integrate Business_Reference__c objects
     * @param businessReferenceList
     * @param topic
     */
    public static void createIntegrationPlatformEvents(
        List<Business_Reference__c> businessReferenceList,
        String topic
    ) {
        service().createIntegrationPlatformEvents(businessReferenceList, topic);
    }

    /**
     * @description It is used for getting Business Reference Ids from the payload
     * received via Platform Event.
     * @JIRA# LEM-9551
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description It initiates External Id field update using the passed corporateAccountIds.
     * @JIRA# LEM-9551
     * @param corporateAccountIds
     */
    @InvocableMethod(
        label='Initiate External Id Update'
        description='Get MP Bz Id and update External Id on business reference'
    )
    public static void processDriveWithholding(List<Id> corporateAccountIds) {
        service().processDriveWithholding(corporateAccountIds);
    }

    private static IBusReferenceIntegrationService service() {
        return (IBusReferenceIntegrationService) Application.Service.newInstance(
            IBusReferenceIntegrationService.class
        );
    }
}