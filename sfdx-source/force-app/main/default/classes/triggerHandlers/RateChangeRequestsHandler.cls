/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Handler class for Rate_Change_Request__c related logic.
 */
public class RateChangeRequestsHandler extends ApplicationDomainHandler {
    private static final String ACTIVATION_ORDER_PAYLOAD_CHUNK_SIZE = 'Activation_Order_Payload_Chunk_Size';
    private static final String APPROVED = 'Approved';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'CREATE_ACTIVATION_ORDER_AND_PRODUCTS';
    private static final String READY_FOR_ACTIVATION = 'Ready for Activation';
    private List<Rate_Change_Request__c> rcrList;
    /**
     * @description Constructor Method
     * @param sObjectList
     */
    public RateChangeRequestsHandler(List<Rate_Change_Request__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Rate_Change_Request__c.sObjectType, RateChangeRequestsHandler.class);
        this.rcrList = new List<Rate_Change_Request__c>();
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList List<SObject>
         * @return RateChangeRequestsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new RateChangeRequestsHandler(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Rate_Change_Request__c> rcrDetailsList = new List<Rate_Change_Request__c>();
        List<Rate_Change_Request__c> updatedRCRs = new List<Rate_Change_Request__c>(
            (List<Rate_Change_Request__c>) getChangedRecords(
                new Set<SObjectField>{ Rate_Change_Request__c.Activation_Status__c }
            )
        );
        RateChangeRequestService.publishCreateActivationOrdersNotifierEvent(
            getStoresUpdatedRCRs(updatedRCRs)
        );
        //@JIRA# LEM-12932
        rcrDetailsList = RateChangeRequestSelector.newInstance()
            .selectRateChangeRequestById(getStoresUpdatedRCRs(updatedRCRs));
        ParentWorkOrdersCreationService.createParentWorkOrdersByRateChangeRequest(rcrDetailsList);
    }

    /**
     * @description It is used to get Rate Change Requests
     * which has all the store accounts updated with its Id.
     * @param updatedRCRs
     * @return List<Rate_Change_Request__c>
     */
    private Set<Id> getStoresUpdatedRCRs(List<Rate_Change_Request__c> updatedRCRs) {
        List<Rate_Change_Request__c> storesUpdatedRCRs = new List<Rate_Change_Request__c>();
        Set<Id> rcrIds = new Set<Id>();
        for (Rate_Change_Request__c rcr : updatedRCRs) {
            if (
                rcr.Activation_Status__c == READY_FOR_ACTIVATION &&
                rcr.Associated_stores_updated__c &&
                rcr.Order_Products_Updated__c &&
                rcr.Status__c == APPROVED
            ) {
                storesUpdatedRCRs.add(rcr);
                rcrIds.add(rcr.Id);
            }
        }
        return rcrIds;
    }
}