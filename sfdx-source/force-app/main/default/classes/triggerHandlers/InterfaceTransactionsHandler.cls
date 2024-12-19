/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface Transaction Trigger handler class
 */
public class InterfaceTransactionsHandler extends ApplicationDomainHandler {
    private static final String EVENT_TOPIC_AMENDMENT_WORK_ORDER_CREATION = 'AMENDMENT_WORK_ORDER_GENERATION';
    private static final String EVENT_TOPIC_GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String INITIATE_RELATED_OBJECTS_CREATION = 'INITIATE_RELATED_OBJECTS_CREATION';
    private static final Integer INITIATE_RELATED_OBJECTS_CREATION_CREATION_CHUNK_SIZE = 30;
    private static final String EVENT_TOPIC_OI_DATA_CREATION = 'OI_DATA_PROCESSING';
    private static final Integer OI_DATA_SERVICE_CHUNK_SIZE = 5;
    private static final String OI_DATA_SERVICE = 'OIDataService';
    private static final String BYPASS_INTERFACE_TRANSATION = 'Bypass_Interface_Transaction';
    private enum ConfigurationNames {
        AMENDMENT_WORK_ORDER_GENERATION,
        GENERIC_WORK_ORDER_GENERATION,
        INITIATE_RELATED_OBJECTS_CREATION,
        OI_DATA_SERVICE
    }
    private static final Map<String, ConfigurationNames> INTERFACE_TRANSACTION_CONFIGURATION_NAMES = new Map<String, ConfigurationNames>{
        EVENT_TOPIC_AMENDMENT_WORK_ORDER_CREATION => ConfigurationNames.AMENDMENT_WORK_ORDER_GENERATION,
        EVENT_TOPIC_GENERIC_WORK_ORDER_CREATION => ConfigurationNames.GENERIC_WORK_ORDER_GENERATION,
        INITIATE_RELATED_OBJECTS_CREATION => ConfigurationNames.INITIATE_RELATED_OBJECTS_CREATION,
        OI_DATA_SERVICE => ConfigurationNames.OI_DATA_SERVICE
    };
    /**
     * @description default constructor method
     * @param sObjectList
     */
    public InterfaceTransactionsHandler(List<Interface_Transaction__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Interface_Transaction__c.SObjectType, InterfaceTransactionsHandler.class);
    }

    /**
     * @description constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return InterfaceTransactionsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new InterfaceTransactionsHandler(sObjectList);
        }
    }
    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        Set<Id> onboardingLinkIds = new Set<Id>();
        Set<Id> recordIdsForAgreementCreation = new Set<Id>();
        Set<Id> sObjectIdsForWorkOrderCreation = new Set<Id>();
        Set<Id> interfaceTransactionIdsForOnboardingLinks = new Set<Id>();
        // Set<Id> amendedSubscriptionIds = new Set<Id>();
        for (
            Interface_Transaction__c eachTransaction : (List<Interface_Transaction__c>) getRecords()
        ) {
            switch on
                INTERFACE_TRANSACTION_CONFIGURATION_NAMES.get(
                    eachTransaction.Interface_Transaction_Configuration_Name__c
                ) {
                when AMENDMENT_WORK_ORDER_GENERATION, GENERIC_WORK_ORDER_GENERATION {
                    sObjectIdsForWorkOrderCreation.addAll(
                        (Set<Id>) JSON.deserialize(eachTransaction.Payload__c, Set<Id>.class)
                    );
                    sObjectIdsForWorkOrderCreation.add(eachTransaction.Id);
                }
                when OI_DATA_SERVICE {
                    OnboardingLinkIds.add(eachTransaction.Payload__c);
                    interfaceTransactionIdsForOnboardingLinks.add(eachTransaction.Id);
                }
                when INITIATE_RELATED_OBJECTS_CREATION {
                    recordIdsForAgreementCreation.addAll(
                        (Set<Id>) JSON.deserialize(eachTransaction.Payload__c, Set<Id>.class)
                    );
                    recordIdsForAgreementCreation.add(eachTransaction.Id);
                }
            }
            if (!sObjectIdsForWorkOrderCreation.isEmpty()) {
                WorkOrderCreationTriggerService.fireonboardingActivationsEventsForWorkOrderCreation(
                    sObjectIdsForWorkOrderCreation,
                    eachTransaction.Interface_Transaction_Configuration_Name__c
                );
                sObjectIdsForWorkOrderCreation = new Set<Id>();
            }
            if (!recordIdsForAgreementCreation.isEmpty()) {
                OnboardingActivationsEventsService.publishBulkEvents(
                    new Map<String, List<String>>{
                        INITIATE_RELATED_OBJECTS_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                            recordIdsForAgreementCreation,
                            INITIATE_RELATED_OBJECTS_CREATION_CREATION_CHUNK_SIZE
                        )
                    }
                );
                recordIdsForAgreementCreation = new Set<Id>();
            }
        }

        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_OI_DATA_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    onboardingLinkIds,
                    OI_DATA_SERVICE_CHUNK_SIZE
                )
            }
        );

        if (!FeatureManagement.checkPermission(BYPASS_INTERFACE_TRANSATION)) {
            InterfaceTransactionsService.initiateOutboundIntegrationForinterfaceTransactions(
                this.records
            );
            ParentWorkOrdersCreationService.createParentWorkOrder(
                (List<Interface_Transaction__c>) getRecords()
            );
        }
    }
}