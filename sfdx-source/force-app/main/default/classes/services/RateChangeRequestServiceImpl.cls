/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Implementation class for  Rate_Change_Request__c object.
 */
public class RateChangeRequestServiceImpl implements IRateChangeRequestService {
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP = 'Create_Activation_Order_Products_ARP';
    private static final String EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST = 'UPDATE_RATE_CHANGE_REQUEST';
    private static final String READY_FOR_ACTIVATION = 'Ready for Activation';
    private static final String ACTIVATION_INITIATED = 'Activation Initiated';
    private static final String STATUS_CANCELED = 'Canceled';
    private static final String AGREEMENT_EVENTS_CHUNK_SIZE = 'Agreement_Events_Chunk_Size';

    /**
     * @description This method is used to complete the Rate Change Request based on Subscription Rate change.
     * @param completedSRCs
     */
    public void setRateChangeRequestComplete(List<Subscription_Rate_Change__c> completedSRCs) {
        Set<Id> rcrIds = new Set<Id>();
        List<Rate_Change_Request__c> rateChangesList = new List<Rate_Change_Request__c>();
        Map<Id, List<Subscription_Rate_Change__c>> rateChangeToAllSubscriptionRateChanges = new Map<Id, List<Subscription_Rate_Change__c>>();
        Map<Id, List<Subscription_Rate_Change__c>> rateChangeToCompletedSubscriptionRateChanges = new Map<Id, List<Subscription_Rate_Change__c>>();
        List<Rate_Change_Request__c> rateChangesToUpdate = new List<Rate_Change_Request__c>();
        List<Rate_Change_Request__c> rateChangesToComplete = new List<Rate_Change_Request__c>();

        rcrIds = getRCRIds(completedSRCs);
        rateChangesList = RateChangeRequestSelector.newInstance()
            .selectRateChangeRequestById(rcrIds);

        for (Rate_Change_Request__c eachRateChange : rateChangesList) {
            List<Subscription_Rate_Change__c> relatedSubscriptionRateChanges = new List<Subscription_Rate_Change__c>();
            relatedSubscriptionRateChanges.addAll(eachRateChange.Subscription_Rate_Changes__r);
            rateChangeToAllSubscriptionRateChanges.put(
                eachRateChange.Id,
                relatedSubscriptionRateChanges
            );
            for (Subscription_Rate_Change__c eachSRC : relatedSubscriptionRateChanges) {
                if (eachSRC.Update_Complete__c) {
                    if (
                        rateChangeToCompletedSubscriptionRateChanges.containsKey(eachRateChange.Id)
                    ) {
                        rateChangeToCompletedSubscriptionRateChanges.get(eachRateChange.Id)
                            .add(eachSRC);
                    } else {
                        rateChangeToCompletedSubscriptionRateChanges.put(
                            eachRateChange.Id,
                            new List<Subscription_Rate_Change__c>{ eachSRC }
                        );
                    }
                }
            }

            if (
                rateChangeToAllSubscriptionRateChanges.get(eachRateChange.Id).size() ==
                rateChangeToCompletedSubscriptionRateChanges.get(eachRateChange.Id).size()
            ) {
                rateChangesToUpdate.add(eachRateChange);
            }
        }

        if (rateChangesToUpdate.isEmpty()) {
            return;
        }

        for (Rate_Change_Request__c eachRcr : rateChangesToUpdate) {
            Rate_Change_Request__c newRcr = new Rate_Change_Request__c(
                Id = eachRcr.Id,
                Order_Products_Updated__c = true
            );
            if (eachRcr.Associated_stores_updated__c) {
                newRcr.Activation_Status__c = READY_FOR_ACTIVATION;
                newRcr.Ready_For_Activation_Time__c = System.Now();
            }
            rateChangesToComplete.add(newRcr);
        }
        updateRateChangeRequests(rateChangesToComplete);
    }

    private Set<Id> getRCRIds(List<Subscription_Rate_Change__c> completedSRCs) {
        Set<Id> rcrIds = new Set<Id>();
        for (Subscription_Rate_Change__c eachItem : completedSRCs) {
            rcrIds.add(eachItem.Rate_Change_Request__c);
        }
        return rcrIds;
    }

    /**
     * @description This method is used to update the Rate Change Request Store Update Flag to true
     * once all the store Accounts are updated in AccountUpdateForActiveRatesBatch.
     * @param rateChangeRequestId
     */
    public void setRateChangeRequestStoreUpdatedFlagTrue(Id rateChangeRequestId) {
        List<Rate_Change_Request__c> rateChangeRequestsToUpdate = new List<Rate_Change_Request__c>();
        List<Rate_Change_Request__c> retrievedRateChanges = RateChangeRequestSelector.newInstance()
            .selectRateChangeRequestById(new Set<Id>{ rateChangeRequestId });
        if (retrievedRateChanges.isEmpty()) {
            return;
        }
        Rate_Change_Request__c newRateChange = new Rate_Change_Request__c(
            Id = retrievedRateChanges[0].Id,
            Associated_stores_updated__c = true
        );
        if (retrievedRateChanges[0].Order_Products_Updated__c) {
            newRateChange.Activation_Status__c = READY_FOR_ACTIVATION;
            newRateChange.Ready_For_Activation_Time__c = System.Now();
        }
        rateChangeRequestsToUpdate.add(newRateChange);
        updateRateChangeRequests(rateChangeRequestsToUpdate);
    }

    /**
     * @description Update Rate Change Requests
     * @param rateChangesToUpdate
     */
    private void updateRateChangeRequests(List<Rate_Change_Request__c> rateChangesToUpdate) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(rateChangesToUpdate);
        commitWork(uow);
    }

    /**
     * @description Generates Activation Order Creation Event once Rate Change Request Activation Status is set to Ready For Activation.
     * @param rcrIds
     */
    public void publishCreateActivationOrdersNotifierEvent(Set<Id> rcrIds) {
        Set<Id> agreementIds = new Set<Id>();
        Map<Id, Agreement__c> agreementsToActivateMap = new Map<Id, Agreement__c>();
        agreementsToActivateMap = getAgreementsToActivateRates(rcrIds);
        agreementIds = agreementsToActivateMap.keySet();

        if (agreementIds.isEmpty()) {
            return;
        }
        Integer createActivationOrderPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(AGREEMENT_EVENTS_CHUNK_SIZE)
                .Configuration_Value__c
        );

        publishBulkAgreementEvents(
            NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                agreementIds, //changed paylod Ids to agreementIds
                createActivationOrderPayloadChunkSize
            )
        );
    }

    /**
     * @description It creates Agreement ACtivation Event with passed payloads
     * @JIRA# LEM-5588
     * @param payloads
     */
    private void publishBulkAgreementEvents(List<String> payloads) {
        if (payloads == null) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (String eachPayload : payloads) {
            uow.registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = eachPayload,
                    Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP
                )
            );
        }
        commitWork(uow);
    }

    /**
     * @description It is used to get Rate Change Requests
     * which has all the store accounts updated with its Id.
     * @param rcrIds
     * @return agreementsToActivateMap
     */
    private Map<Id, Agreement__c> getAgreementsToActivateRates(Set<Id> rcrIds) {
        Map<Id, Agreement__c> agreementsToActivateMap = new Map<Id, Agreement__c>(
            AgreementsSelector.newInstance().selectStoreAgreementsByRcrIds(rcrIds)
        );
        return agreementsToActivateMap;
    }

    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents list of platform events with payload
     */
    public void handleNotifierEvents(List<Notifier__e> notifierEvents) {
        Set<Id> recordIdsByPayload;

        for (Notifier__e eachEvent : notifierEvents) {
            if (eachEvent.Topic__c == EVENT_TOPIC_UPDATE_RATE_CHANGE_REQUEST) {
                recordIdsByPayload = (Set<Id>) JSON.deserialize(
                    eachEvent.Payload__c,
                    Set<Id>.class
                );
            }
            if (recordIdsByPayload == null) {
                continue;
            }
            updateRateChangeRequestAsActivationInitiated(recordIdsByPayload);
        }
    }

    private void updateRateChangeRequestAsActivationInitiated(Set<Id> recordIdsByPayload) {
        List<Rate_Change_Request__c> rateChangeRequests = new List<Rate_Change_Request__c>();
        List<Rate_Change_Request__c> rateChangeRequestsToUpdate = new List<Rate_Change_Request__c>();

        rateChangeRequests = RateChangeRequestSelector.newInstance()
            .selectRateChangeRequestById(recordIdsByPayload);

        if (rateChangeRequests.isEmpty()) {
            return;
        }

        for (Rate_Change_Request__c eachRCR : rateChangeRequests) {
            if (eachRCR.Activation_Status__c == READY_FOR_ACTIVATION) {
                Rate_Change_Request__c newRCR = new Rate_Change_Request__c(
                    Id = eachRCR.Id,
                    Activation_Status__c = ACTIVATION_INITIATED,
                    Activation_Initiated_Time__c = System.Now()
                );
                rateChangeRequestsToUpdate.add(newRCR);
            }
        }

        if (!rateChangeRequestsToUpdate.isEmpty()) {
            updateRateChangeRequests(rateChangeRequestsToUpdate);
        }
    }
    /**
     * @description It is used to update all Rate Change Requests to cancelled.
     * @param rateChangeRequests
     */
    public void updateRateChangeRequestToCancelled(
        List<Rate_Change_Request__c> rateChangeRequests
    ) {
        List<Rate_Change_Request__c> cancelledRCRList = new List<Rate_Change_Request__c>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        if (!rateChangeRequests.isEmpty()) {
            for (Rate_Change_Request__c eachRCR : rateChangeRequests) {
                Rate_Change_Request__c rateChange = new Rate_Change_Request__c(
                    Id = eachRCR.Id,
                    Status__c = STATUS_CANCELED
                );
                cancelledRCRList.add(rateChange);
            }
        } else {
            return;
        }
        if (!cancelledRCRList.isEmpty()) {
            uow.registerDirty(cancelledRCRList);
        }
        commitWork(uow);
    }

    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }
}