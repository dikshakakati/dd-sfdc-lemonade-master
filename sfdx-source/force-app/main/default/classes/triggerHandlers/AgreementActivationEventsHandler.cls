/**
 * @description Agreement Activation Events Handler
 */
public with sharing class AgreementActivationEventsHandler extends ApplicationDomainHandler {
    private static final Integer AGREEMENT_ACTIVATION_SCOPE_SIZE = 1;
    private static final String UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES = 'Update Activation Order And Products For Existing Process';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP = 'Create_Activation_Order_Products_ARP';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'Create_Activation_Order_Products';
    private static final String EVENT_TOPIC_UPDATE_MERCHANT_SERVICES = 'Update_Merchant_Services';

    private enum EventTopics {
        UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES,
        EVENT_TOPIC_CREATE_ACTIVATION_ORDER,
        EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP,
        EVENT_TOPIC_UPDATE_MERCHANT_SERVICES
    }

    private static final Map<String, EventTopics> TOPIC_TO_EVENT_TOPICS = new Map<String, EventTopics>{
        UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES => EventTopics.UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES,
        EVENT_TOPIC_CREATE_ACTIVATION_ORDER => EventTopics.EVENT_TOPIC_CREATE_ACTIVATION_ORDER,
        EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP => EventTopics.EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP,
        EVENT_TOPIC_UPDATE_MERCHANT_SERVICES => EventTopics.EVENT_TOPIC_UPDATE_MERCHANT_SERVICES
    };

    /**
     * @description Constructor Method
     * @param sObjectList - Provisioning Events Record List
     */
    public AgreementActivationEventsHandler(List<Agreement_Activation_Event__e> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Agreement_Activation_Event__e.SObjectType,
            AgreementActivationEventsHandler.class
        );
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        Set<Id> agreementIdsToActivate = new Set<Id>();
        Set<Id> agreementIdsToActivateARP = new Set<Id>();
        Set<Id> existingAgreementIdsToActivate = new Set<Id>();
        Set<Id> deactivatedAgreementsIds = new Set<Id>();
        Integer scopeSize = AGREEMENT_ACTIVATION_SCOPE_SIZE;

        for (Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++) {
            Agreement_Activation_Event__e activationEvent = (Agreement_Activation_Event__e) this.records[
                    counter
                ];

            EventTopics eventType = TOPIC_TO_EVENT_TOPICS.get(activationEvent.Topic__c);

            if (eventType == null) {
                continue;
            }
            Set<Id> deserializedIds = deserializeAgreementIds(activationEvent.Agreement_Ids__c);

            switch on eventType {
                when UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES {
                    existingAgreementIdsToActivate.addAll(deserializedIds);
                }
                when EVENT_TOPIC_CREATE_ACTIVATION_ORDER {
                    agreementIdsToActivate.addAll(deserializedIds);
                }
                when EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP {
                    agreementIdsToActivateARP.addAll(deserializedIds);
                }
                when EVENT_TOPIC_UPDATE_MERCHANT_SERVICES {
                    deactivatedAgreementsIds.addAll(deserializedIds);
                }
            }
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(activationEvent.replayId);
        }

        if (!agreementIdsToActivate.isEmpty()) {
            ActivationOrdersService.createActivationOrdersAndProducts(
                getAgreementsByIds(agreementIdsToActivate),
                false
            );
        }

        if (!existingAgreementIdsToActivate.isEmpty()) {
            ActivationOrdersService.updateMerchantServicesbasedOnEntitlements(
                AgreementsSelector.newInstance()
                    .selectStoreAgreementsByIds(existingAgreementIdsToActivate)
            );
        }

        if (!agreementIdsToActivateARP.isEmpty()) {
            ActivationOrdersService.createActivationOrdersAndProducts(
                AgreementsSelector.newInstance()
                    .selectStoreAgreementsByIds(agreementIdsToActivateARP),
                true
            );
        }

        // @JIRA #LEM-15980
        if (!deactivatedAgreementsIds.isEmpty()) {
            AgreementsService.updateMxServicesBasedOnRecordsCount(
                getAgreementsByIds(deactivatedAgreementsIds),
                true
            );
        }
    }

    /**
     * @description Deserialize Agreement_Ids__c to Set<Id>
     * @param agreementIdsJson JSON string containing Agreement_Ids__c
     * @return Deserialized Set<Id>
     */
    private Set<Id> deserializeAgreementIds(String agreementIdsJson) {
        return (Set<Id>) JSON.deserialize(agreementIdsJson, Set<Id>.class);
    }

    /**
     * @description Deserialize Agreement_Ids__c to Set<Id>
     * @param agreementIds set if ids string containing Agreement Ids
     * @return agreementList List<Agreement__c>
     */
    private List<Agreement__c> getAgreementsByIds(Set<Id> agreementIds) {
        return AgreementsSelector.newInstance().selectById(agreementIds);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return RollUpEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AgreementActivationEventsHandler(sObjectList);
        }
    }
}