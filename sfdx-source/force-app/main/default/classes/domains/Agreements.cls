/**
 * @author DoorDash
 * @date 06/01/2022
 * @description Domain Class for Agreements Object
 */
public inherited sharing class Agreements extends fflib_SObjects implements IAgreements {
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_TYPE_BUSINESS_AGREEMENT = 'Business Agreement';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS = 'READINESS_CHECK_ON_PARENT_WORK_ORDERS';
    private static final String PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Parent_WorkOrders_Payload_Chunk_Size';
    private static final String STATUS_CANCELLED = 'Cancelled'; //@JIRA #LEM-15980

    /**
     * @description This method is used to return the IAgreements interface
     * @param recordList - Agreements record list
     * @return IAccounts - Returns IAgreements Interface
     */
    public static IAgreements newInstance(List<Agreement__c> recordList) {
        return (IAgreements) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Agreements(List<Agreement__c> sObjectList) {
        super(sObjectList, Schema.Agreement__c.SObjectType);
    }

    /**
     * @description Method for retrieving all of the Account Ids from the records
     * @return Set of Account Ids
     */
    public Set<Id> getAccountIds() {
        Set<Id> results = new Set<Id>();
        for (Agreement__c obj : (Agreement__c[]) getRecords()) {
            results.add(obj.Account__c);
        }
        return results;
    }

    /**
     * @description It update Agreement related records on After Insert trigger event.
     * @JIRA# LEM-11106
     * @param agreements
     */
    public void onAfterInsertHandleRelatedRecords(List<Agreement__c> agreements) {
        Set<Id> contractIds = new Set<Id>();
        for (Agreement__c eachAgreement : agreements) {
            if (isEligibleBusinessAgreement(eachAgreement)) {
                contractIds.add(eachAgreement.Contract__c);
            }
        }
        if (contractIds.isEmpty()) {
            return;
        }
        Map<Id, WorkOrder> workOrders = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance().selectParentWorkOrdersByContractIds(contractIds)
        );
        if (workOrders.isEmpty()) {
            return;
        }
        Integer parentWorkOrderIdPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    workOrders.keySet(),
                    parentWorkOrderIdPayloadChunkSize
                )
            }
        );
    }

    /**
     * @description It checks whether the Agreement satisfies criteria to trigger Readiness Check.
     * @JIRA# LEM-11106
     * @param agreement
     * @return Boolean
     */
    private Boolean isEligibleBusinessAgreement(Agreement__c agreement) {
        return agreement.Status__c == AGREEMENT_STATUS_ACTIVE &&
            agreement.Type__c == AGREEMENT_TYPE_BUSINESS_AGREEMENT;
    }

    /**
     * @description To update address deactivation date or status to cancelled
     * @param agreementsList
     * @JIRA #LEM-15980
     */
    public void updateDeactivationDateOrStatus(List<Agreement__c> agreementsList) {

        if (agreementsList == null) {
            return;
        }
        for (Agreement__c eachAgreement : agreementsList) {
            if (
                eachAgreement.Status__c == STATUS_CANCELLED &&
                eachAgreement.Deactivation_Date__c == null
            ) {
                eachAgreement.Deactivation_Date__c = System.today();
            }
            if (
                eachAgreement.Status__c != STATUS_CANCELLED &&
                eachAgreement.Deactivation_Date__c == System.today()
            ) {
                eachAgreement.Status__c = STATUS_CANCELLED;
            }
        }
    }


    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Agreements - List of Agreements
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Agreements.constructorMock != null) {
                return (fflib_SObjects) Agreements.constructorMock.construct(objectList);
            }
            return new Agreements((List<SObject>) objectList);
        }
    }
}