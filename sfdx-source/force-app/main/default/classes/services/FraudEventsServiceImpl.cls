/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Service Implementation for processing Fraud Events.
 */
public inherited sharing class FraudEventsServiceImpl implements IFraudEventsService {
    private static final String BUSINESS_VERIFICATION = 'BusinessVerification';
    private static final String EVENT_TOPIC_FRAUD_EVENT_CHECK = 'EVENT_TOPIC_FRAUD_EVENT_CHECK';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String STORE_ID = 'StoreId';
    private enum EventTopics {
        EVENT_TOPIC_FRAUD_EVENT_CHECK
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_FRAUD_EVENT_CHECK => EventTopics.EVENT_TOPIC_FRAUD_EVENT_CHECK
    };

    /**
     * @description It is used to handle the published onboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> recordIdsByPayload;
        Set<Id> fraudEventIntegrationRequestIds = new Set<Id>();
        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_FRAUD_EVENT_CHECK {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    fraudEventIntegrationRequestIds.addAll(recordIdsByPayload);
                }
            }
        }
        if (!fraudEventIntegrationRequestIds.isEmpty()) {
            parseFraudEventPayloads(fraudEventIntegrationRequestIds);
        }
    }

    /**
     * @description It is used to parse Business Verification Details for all stores.
     * @param fraudEventIntegrationRequestIds
     */
    private void parseFraudEventPayloads(Set<Id> fraudEventIntegrationRequestIds) {
        List<String> storeIds = new List<String>();
        Set<Id> accountIds = new Set<Id>();
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails = new Map<String, BusinessVerficationDetails>();
        Map<Id, String> salesforceAccountIdToStoreId = new Map<Id, String>();
        if (fraudEventIntegrationRequestIds.isEmpty()) {
            return;
        }
        BusinessVerficationDetails storeData;
        Map<String, Object> dataString;
        for (
            Integration_Request__c eachIntegrationRequest : IntegrationRequestsSelector.newInstance()
                .selectById(fraudEventIntegrationRequestIds)
        ) {
            dataString = (Map<String, Object>) JSON.deserializeUntyped(
                eachIntegrationRequest.Payload__c
            );
            storeData = new BusinessVerficationDetails((String) dataString.get(STORE_ID));
            storeData.businessVerificationDetails = parseBusinessVerificationDetails(
                dataString.get(BUSINESS_VERIFICATION)
            );
            storeIds.add((String) dataString.get(STORE_ID));
            storeIdsToBusinessVertificationDetails.put(
                (String) dataString.get(STORE_ID),
                storeData
            );
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefsByExternalIdsAndPrimaryVertical(storeIds, PRIMARY_VERTICAL_RX)
        ) {
            accountIds.add(eachXref.Salesforce_Account_Name__r.Account_ID18__c);
            salesforceAccountIdToStoreId.put(
                eachXref.Salesforce_Account_Name__r.Account_ID18__c,
                eachXref.External_Id__c
            );
        }
        //LEM-15834: This updates the Work Steps Status based on Business Verification details.
        WorkStepsService.updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
            accountIds,
            salesforceAccountIdToStoreId,
            storeIdsToBusinessVertificationDetails
        );
    }

    /**
     * @description It parses Business Verification Details for all stores.
     * @param businessVerificationDetails
     * @return BusinessVerficationDetails.BusinessVerificationStatusDetails
     */
    private BusinessVerficationDetails.BusinessVerificationStatusDetails parseBusinessVerificationDetails(
        Object businessVerificationDetails
    ) {
        return (BusinessVerficationDetails.BusinessVerificationStatusDetails) JSON.deserialize(
            JSON.serialize(businessVerificationDetails),
            BusinessVerficationDetails.BusinessVerificationStatusDetails.class
        );
    }
}