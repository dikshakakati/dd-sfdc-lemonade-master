/**
 * @author Deloitte
 * @date 06/24/2023
 * @description Domain Class for SBQQ__SUBSCRIPTION__C Object.
 */
public inherited sharing class Subscriptions extends fflib_SObjects implements ISubscriptions {
    private static final String AMENDMENT_WORK_ORDER_CREATION = 'AMENDMENT_WORK_ORDER_GENERATION';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String INTEGRATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String INTEGRATION_SOURCE_SSMO = 'SSMO';
    private static final String INTEGRATION_SOURCE_RESSMO = 'RESSMO';
    private static final String INTEGRATION_SOURCE_SSOB = 'SSOB';
    private static final String INTEGRATION_TYPE_PACKAGE_SWITCH = 'Mx Portal Package Switch';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String LOG_SERVICE = 'Subscription Changes';
    private static final String LOG_DOMAIN = 'CPQ';
    private static final set<String> INTEGRATION_SOURCES = new Set<String>{
        INTEGRATION_SOURCE_RESSMO,
        INTEGRATION_SOURCE_SSMO,
        INTEGRATION_SOURCE_SSOB,
        INTEGRATION_SOURCE_MX_PORTAL
    };
    private static final set<String> INTEGRATION_SOURCES_NOT_ELIGIBLE_FOR_AMENDMENTS = new Set<String>{
        INTEGRATION_SOURCE_SSMO,
        INTEGRATION_SOURCE_SSOB,
        INTEGRATION_SOURCE_MX_PORTAL
    };
    private static final Set<String> INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION = new Set<String>{
        INTEGRATION_TYPE_PACKAGE_SWITCH
    };
    /**
     * @description This method is used to return the ISubscriptions interface
     * @param recordList
     * @return ISubscriptions
     */
    public static ISubscriptions newInstance(List<SBQQ__Subscription__c> recordList) {
        return (ISubscriptions) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Subscriptions(List<SBQQ__Subscription__c> sObjectList) {
        super(sObjectList, Schema.SBQQ__Subscription__c.SObjectType);
    }

    /**
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
         * @param objectList List<Object>
         * @return fflib_SObjects
         * Subscription - list of SBQQ__Subscription__c
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Subscriptions.constructorMock != null) {
                return (fflib_SObjects) Subscriptions.constructorMock.construct(objectList);
            }
            return new Subscriptions((List<SObject>) objectList);
        }
    }

    /**
     * @description To call contract service when subscription
     * is inserted
     * @JIRA# LEM-6861
     */
    public void callContractServiceToUpdateContractName() {
        set<Id> contractIds = new Set<Id>();
        Map<Id, String> contractIdToNameMap = new Map<Id, String>();

        for (SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>) getRecords()) {
            if (sub.SBQQ__Contract__c == null) {
                continue;
            }
            contractIds.add(sub.SBQQ__Contract__c);
        }
        if (contractIds.isEmpty()) {
            return;
        }
        for (contract con : ContractsSelector.newInstance().selectById(contractIds)) {
            contractIdToNameMap.put(con.Id, con.Contract_Name__c);
        }
        ContractsService.stampMsaOrAdsPromoOntheContract(contractIdToNameMap);
    }

    /**
     * @description Updates Quote line Group Fields on Subscriptions
     */
    public void populateQuoteLineGroup() {
        Map<Id, Id> quotelineIdsToGroupIds = new Map<Id, Id>();

        List<SBQQ__Subscription__c> newSubsList = (List<SBQQ__Subscription__c>) getRecords();
        if (newSubsList.isEmpty()) {
            return;
        }
        for (SBQQ__Subscription__c subs : newSubsList) {
            quotelineIdsToGroupIds.put(subs.SBQQ__QuoteLine__c, null);
        }
        for (
            SBQQ__QuoteLine__c quoteLine : QuoteLineItemsSelector.newInstance()
                .selectQuoteLineGroupFields(quotelineIdsToGroupIds.keySet())
        ) {
            if (String.isBlank(quoteLine.SBQQ__Group__r.CCP_Unique_Group_Id__c)) {
                quotelineIdsToGroupIds.put(quoteLine.Id, quoteLine.SBQQ__Group__c);
            } else {
                quotelineIdsToGroupIds.put(
                    quoteLine.Id,
                    Id.valueOf(quoteLine.SBQQ__Group__r.CCP_Unique_Group_Id__c)
                );
            }
        }
        for (SBQQ__Subscription__c subs : newSubsList) {
            if (quotelineIdsToGroupIds.get(subs.SBQQ__QuoteLine__c) == null) {
                continue;
            }
            subs.Quote_Line_Group__c = quotelineIdsToGroupIds.get(subs.SBQQ__QuoteLine__c);
        }
    }

    /**
     * @description It validates Subscription fields and for SSMO/SSOB Work Order Creation.
     * @JIRA# LEM-15362
     */
    public void evaluateAndInitalizeForWorkOrderCreation() {
        Set<Id> subscriptionIdsEligibleForWorkOrderCreation = new Set<Id>();
        Set<Id> subscriptionIds = new Set<Id>(
            new Map<Id, SBQQ__Subscription__c>((List<SBQQ__Subscription__c>) getRecords()).keySet()
        );
        Set<Id> subscriptionsIdsEligibleForAmendment = new Set<Id>();
        Map<String, Set<Id>> uuidToSubscriptions = new Map<String, Set<Id>>();
        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectBySubscriptionIds(subscriptionIds)
        ) {
            if (INTEGRATION_SOURCES.contains(eachSubscription.Integration_Source__c)) {
                if (eachSubscription.Integration_Source__c == INTEGRATION_SOURCE_RESSMO) {
                    subscriptionIdsEligibleForWorkOrderCreation.add(eachSubscription.Id);
                    continue;
                }
                if (String.isBlank(eachSubscription.Unique_Identifier__c)) {
                    continue;
                }
                if (!uuidToSubscriptions.containsKey(eachSubscription.Unique_Identifier__c)) {
                    uuidToSubscriptions.put(eachSubscription.Unique_Identifier__c, new Set<Id>());
                }
                uuidToSubscriptions.get(eachSubscription.Unique_Identifier__c)
                    .add(eachSubscription.Id);
            }
            if (
                !INTEGRATION_SOURCES_NOT_ELIGIBLE_FOR_AMENDMENTS.contains(
                    eachSubscription.Integration_Source__c
                ) && eachSubscription.SBQQ__Contract__r.Account.Segment__c == SEGMENT_SMB
            ) {
                subscriptionsIdsEligibleForAmendment.add(eachSubscription.Id);
            }
        }
        filterSubscriptionsByIneligibleIntegrationTypes(
            uuidToSubscriptions,
            subscriptionIdsEligibleForWorkOrderCreation
        );
        WorkOrderCreationTriggerService.initiateWorkOrderCreation(
            subscriptionIdsEligibleForWorkOrderCreation,
            GENERIC_WORK_ORDER_CREATION
        );
        WorkOrderCreationTriggerService.initiateWorkOrderCreation(
            subscriptionsIdsEligibleForAmendment,
            AMENDMENT_WORK_ORDER_CREATION
        );
    }

    /**
     * @description It is used to filter subscriptions by ineligible integration types.
     * @JIRA# LEM-23340
     * @param uuidToSubscriptions
     * @param subscriptionIdsEligibleForWorkOrderCreation
     */
    private void filterSubscriptionsByIneligibleIntegrationTypes(
        Map<String, Set<Id>> uuidToSubscriptions,
        Set<Id> subscriptionIdsEligibleForWorkOrderCreation
    ) {
        if (uuidToSubscriptions.isEmpty()) {
            return;
        }
        Set<String> uuidsIneligibleForWorkOrderCreation = new Set<String>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectInboundIngestionLogsByUniqueIdentifiers(
                    INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION,
                    uuidToSubscriptions.keySet()
                )
        ) {
            uuidsIneligibleForWorkOrderCreation.add(eachInboundIngestionLog.UUID__c);
        }
        for (String eachUUID : uuidToSubscriptions.keySet()) {
            if (uuidsIneligibleForWorkOrderCreation.contains(eachUUID)) {
                continue;
            }
            subscriptionIdsEligibleForWorkOrderCreation.addAll(uuidToSubscriptions.get(eachUUID));
        }
    }
    /**
     * @description It is used to update Subscription's Product Family on Contract.
     * @JIRA# LEM-24915
     */
    public void updateContractWithSubscritionProductFamily() {
        Set<Id> contractIdsToUpdate = new Set<Id>();

        for (SBQQ__Subscription__c eachSubscription : (List<SBQQ__Subscription__c>) getRecords()) {
            if (eachSubscription.SBQQ__Contract__c != null) {
                contractIdsToUpdate.add(eachSubscription.SBQQ__Contract__c);
            }
        }
        if (contractIdsToUpdate.isEmpty()) {
            return;
        }
        List<SBQQ__Subscription__c> subscriptionWithProductFamily = SubscriptionSelector.newInstance()
            .getSubscriptionsByContractIds(contractIdsToUpdate);

        if (subscriptionWithProductFamily.isEmpty()) {
            return;
        }
        updateContractProductFamily(subscriptionWithProductFamily);
    }

    /**
     * @description It is used to update Subscription's Product Family on Contract.
     * @param subscriptionWithProductFamily
     */

    private void updateContractProductFamily(
        List<SBQQ__Subscription__c> subscriptionWithProductFamily
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id, Set<String>> contractsWithProductFamilies = new Map<Id, Set<String>>();

        for (SBQQ__Subscription__c eachSubscription : subscriptionWithProductFamily) {
            if (!contractsWithProductFamilies.containsKey(eachSubscription.SBQQ__Contract__c)) {
                contractsWithProductFamilies.put(
                    eachSubscription.SBQQ__Contract__c,
                    new Set<String>()
                );
            }
            if (
                eachSubscription.SBQQ__Product__r != null &&
                eachSubscription.SBQQ__Product__r.Family != null
            ) {
                contractsWithProductFamilies.get(eachSubscription.SBQQ__Contract__c)
                    .add(eachSubscription.SBQQ__Product__r.Family);
            }
        }

        for (Id eachContractId : contractsWithProductFamilies.keySet()) {
            Set<String> productFamilies = contractsWithProductFamilies.get(eachContractId);
            if (!productFamilies.isEmpty()) {
                Contract contractsToUpdate = new Contract(Id = eachContractId);
                contractsToUpdate.Product_Family__c = String.join(
                    new List<String>(productFamilies),
                    ', '
                );
                uow.registerDirty(contractsToUpdate);
            }
        }
        commitWork(uow);
    }

    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }
}