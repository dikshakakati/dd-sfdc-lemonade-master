/**
 * @author Deloitte
 * @date 07/22/2024
 * @description This is the Domain class for Mx Onboarding Link object.
 */
public inherited sharing class MxOnboardingLinks extends fflib_SObjects implements IMxOnboardingLinks {
    private static final String INITIATE_RELATED_OBJECTS_CREATION = 'INITIATE_RELATED_OBJECTS_CREATION';
    private static final String INTERFACE_TRANSACTION_STATUS_SUCCESS = 'Success';
    private static final String PACKAGE_DRIVE = 'Drive';
    private static final String PACKAGE_MARKETPLACE = 'Marketplace';
    private static final String PACKAGE_SELF_DELIVERY = 'Self-Delivery';
    private static final String PACKAGE_STOREFRONT = 'Storefront';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String ORDER_PROTOCOL_TABLET = 'Tablet';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static fflib_IDomainConstructor constructorMock;
    private static final String CREATION_STATUS_SUCCESS = 'Success';
    private static final String CREATION_STATUS_WO_CREATION_SUCCESS = 'WO Creation Success';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final Integer INITIATE_RELATED_OBJECTS_CREATION_CREATION_CHUNK_SIZE = 30;
    private static final String EXCEPTION_HEADER = 'Duplicate Store Accounts Identified during Agreement Creation via Onboarding Inputs: Store Accounts ';
    private static final String EMPTY_STRING = '';
    private static final String COMMA_DELIMITER = ', ';
    private static final String OPPORTUNITY_OWNER = ' Opportunity Owner :';
    private static final String OPEN_BRACES = ' (';
    private static final String CLOSE_BRACES = ') ';
    private static final String LOG_SERVICE = 'Onboarding Inputs';
    private static final String LOG_DOMAIN = 'CPQ';
    private static final String STORE = 'Store';

    private enum ProductCategory {
        PACKAGE_DRIVE,
        PACKAGE_MARKETPLACE,
        PACKAGE_SELF_DELIVERY,
        PACKAGE_STOREFRONT
    }
    private static final Map<String, ProductCategory> PRODUCTTOPRODUCTCATEGORY = new Map<String, ProductCategory>{
        PACKAGE_DRIVE => ProductCategory.PACKAGE_DRIVE,
        PACKAGE_MARKETPLACE => ProductCategory.PACKAGE_MARKETPLACE,
        PACKAGE_SELF_DELIVERY => ProductCategory.PACKAGE_SELF_DELIVERY,
        PACKAGE_STOREFRONT => ProductCategory.PACKAGE_STOREFRONT
    };
    private enum EventTopics {
        EVENT_TOPIC_INITIATE_RELATED_OBJECTS_CREATION
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        INITIATE_RELATED_OBJECTS_CREATION => EventTopics.EVENT_TOPIC_INITIATE_RELATED_OBJECTS_CREATION
    };

    /**
     * @description Default constructor for the class
     * @param sObjects
     */
    public MxOnboardingLinks(List<Mx_Onboarding_Link__c> sObjects) {
        super(sObjects, Schema.Mx_Onboarding_Link__c.SObjectType);
    }

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description Domain Constructor for the class.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor menthod implementation from fflib_IDomainConstructor class
         * @param objects
         * @return MxOnboardingLinks
         */
        public fflib_SObjects construct(List<Object> objects) {
            if (MxOnboardingLinks.constructorMock != null) {
                return (fflib_SObjects) MxOnboardingLinks.constructorMock.construct(objects);
            }
            return new MxOnboardingLinks((List<SObject>) objects);
        }
    }

    /**
     * @description It returns an instance of IMxOnboardingLinks.
     * @param mxOnboardingLinks
     * @return IMxOnboardingLinks
     */
    public static IMxOnboardingLinks newInstance(List<Mx_Onboarding_Link__c> mxOnboardingLinks) {
        return (IMxOnboardingLinks) Application.Domain.newInstance(mxOnboardingLinks);
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @param objectInstance
     * @return Boolean
     */
    private static Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It evaluates and initaiates the creation of Work Order when Onboarding Input
     * is submitted.
     * @JIRA# LEM-15321
     */
    public void initiateWorkOrderCreation() {
        List<Mx_Onboarding_Link__c> onboardingLinksWithStatusSuccess = (List<Mx_Onboarding_Link__c>) getRecordsByFieldValue(
            Mx_Onboarding_Link__c.Record_Creation_Status__c,
            CREATION_STATUS_SUCCESS
        );
        Set<Id> mxOnboardingLinkIds = new Set<Id>(
            new Map<Id, Mx_Onboarding_Link__c>(onboardingLinksWithStatusSuccess).keySet()
        );
        if (!mxOnboardingLinkIds.isEmpty()) {
            WorkOrderCreationTriggerService.initiateWorkOrderCreation(
                mxOnboardingLinkIds,
                GENERIC_WORK_ORDER_CREATION
            );
        }
    }

    /**
     * @description It initiates the Store Agreement creation in async process.
     * @JIRA# LEM-15321
     */
    public void initiateStoreAgreementCreationAsync() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Mx_Onboarding_Link__c> onboardingLinksWithStatusWOSuccess = (List<Mx_Onboarding_Link__c>) getRecordsByFieldValue(
            Mx_Onboarding_Link__c.Record_Creation_Status__c,
            CREATION_STATUS_WO_CREATION_SUCCESS
        );
        Set<Id> mxOnboardingLinkIds = new Set<Id>(
            new Map<Id, Mx_Onboarding_Link__c>(onboardingLinksWithStatusWOSuccess).keySet()
        );
        if (!mxOnboardingLinkIds.isEmpty()) {
            uow.registerNew(
                new Interface_Transaction__c(
                    Payload__c = JSON.serialize(mxOnboardingLinkIds),
                    Remaining_Retry_Attempts__c = 3,
                    Interface_Transaction_Configuration_Name__c = INITIATE_RELATED_OBJECTS_CREATION,
                    Status__c = INTERFACE_TRANSACTION_STATUS_SUCCESS
                )
            );
            uow.commitWork();
        }
    }

    /**
     * @description Initiating the Store Account Association for New Quotes when Onboarding inputs are received
     * and created as part of LEM-15219
     * @param mxOnboardingLinkIds
     */
    public void initiateStoreAgreementCreation(Set<Id> mxOnboardingLinkIds) {
        if (mxOnboardingLinkIds.isEmpty()) {
            return;
        }

        Map<Id, Id> contractIdToAccountId = new Map<Id, Id>();
        Map<Id, String> uuidToAccountId = new Map<Id, String>();
        Map<Id, Set<String>> storeAccountsByParentId = new Map<Id, Set<String>>();
        Map<Id, Set<String>> contractsIdToStoreAccounts = new Map<Id, Set<String>>();
        Map<Id, Account> duplicateStoreAccountsByUUID = new Map<Id, Account>();
        Map<Id, Account> validStoreAccountsByUUID = new Map<Id, Account>();
        Map<Id, String> opportunityOwners = new Map<Id, String>();
        List<Contract> contractsForStoreAssociation = new List<Contract>();

        setContractAndUUIDMapping(mxOnboardingLinkIds, contractIdToAccountId, uuidToAccountId);

        if (contractIdToAccountId.isEmpty() || uuidToAccountId.isEmpty()) {
            return;
        }

        Map<Id, Account> storeAccountsByUUID = getStoreAccountsByUUID(uuidToAccountId);

        validateIfDuplicateStoreAgreementExists(
            storeAccountsByUUID,
            validStoreAccountsByUUID,
            duplicateStoreAccountsByUUID,
            opportunityOwners
        );

        if (!duplicateStoreAccountsByUUID.isEmpty()) {
            logduplicateStoresInGenericLogger(duplicateStoreAccountsByUUID, opportunityOwners);
        }

        if (validStoreAccountsByUUID.isEmpty()) {
            return;
        }

        groupStoreAccountsByParentId(validStoreAccountsByUUID, storeAccountsByParentId);
        filterContractsForAssociation(
            contractIdToAccountId,
            contractsForStoreAssociation,
            contractsIdToStoreAccounts,
            storeAccountsByParentId
        );

        if (!contractsForStoreAssociation.isEmpty()) {
            AgreementsService.createAgreementsfromContractsWithGroup(
                contractsForStoreAssociation,
                contractsIdToStoreAccounts,
                new Map<Id, Map<Id, String>>()
            );
        }
    }

    /**
     * @description It is used to set Contract and UUID mapping.
     * @param mxOnboardingLinkIds
     * @param contractIdToAccountId
     * @param uuidToAccountId
     */
    private void setContractAndUUIDMapping(
        Set<Id> mxOnboardingLinkIds,
        Map<Id, Id> contractIdToAccountId,
        Map<Id, String> uuidToAccountId
    ) {
        for (
            Mx_Onboarding_Link__c eachMxOnboardingLink : MxOnboardingLinksSelector.newInstance()
                .selectById(mxOnboardingLinkIds)
        ) {
            if (
                eachMxOnboardingLink.Record_Creation_Status__c ==
                CREATION_STATUS_WO_CREATION_SUCCESS &&
                eachMxOnboardingLink.Onboarding_Scenario__c !=
                System.Label.OnboardingScenario_ProductAddition
            ) {
                contractIdToAccountId.put(
                    eachMxOnboardingLink.Contract__c,
                    eachMxOnboardingLink.Business_Account__c
                );
                uuidToAccountId.put(
                    eachMxOnboardingLink.Business_Account__c,
                    eachMxOnboardingLink.UUID__c
                );
            }
        }
    }

    /**
     * @description It is used to get Store Accounts by UUID.
     * @param uuidToAccountId
     * @return Map<Id, Account>
     */
    private Map<Id, Account> getStoreAccountsByUUID(Map<Id, String> uuidToAccountId) {
        return new Map<Id, Account>(
            AccountsSelector.newInstance()
                .selectAccountsByMxOnboardingLinkIds(new Set<String>(uuidToAccountId.values()))
        );
    }

    /**
     * @description It is used to group Store Accounts by Parent Id.
     * @param validStoreAccountsByUUID
     * @param storeAccountsByParentId
     */
    private void groupStoreAccountsByParentId(
        Map<Id, Account> validStoreAccountsByUUID,
        Map<Id, Set<String>> storeAccountsByParentId
    ) {
        for (Account eachStoreAccount : validStoreAccountsByUUID.values()) {
            if (!storeAccountsByParentId.containsKey(eachStoreAccount.ParentId)) {
                storeAccountsByParentId.put(eachStoreAccount.ParentId, new Set<String>());
            }
            storeAccountsByParentId.get(eachStoreAccount.ParentId).add(eachStoreAccount.Id);
        }
    }

    /**
     * @description It is used to filter Contracts for association.
     * @param contractIdToAccountId
     * @param contractsForStoreAssociation
     * @param contractsIdToStoreAccounts
     * @param storeAccountsByParentId
     */
    private void filterContractsForAssociation(
        Map<Id, Id> contractIdToAccountId,
        List<Contract> contractsForStoreAssociation,
        Map<Id, Set<String>> contractsIdToStoreAccounts,
        Map<Id, Set<String>> storeAccountsByParentId
    ) {
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectById(contractIdToAccountId.keySet());
        for (Contract eachContract : contracts) {
            if (storeAccountsByParentId.containsKey(eachContract.AccountId)) {
                contractsIdToStoreAccounts.put(
                    eachContract.Id,
                    storeAccountsByParentId.get(eachContract.AccountId)
                );
                contractsForStoreAssociation.add(eachContract);
            }
        }
    }

    /**
     * @description It is used to seggregate store accounts based on dedup check.
     * @param storeAccountsByUUID
     * @param validStoreAccountsByUUID
     * @param duplicateStoreAccountsByUUID
     * @param opportunityOwners
     */
    private void validateIfDuplicateStoreAgreementExists(
        Map<Id, Account> storeAccountsByUUID,
        Map<Id, Account> validStoreAccountsByUUID,
        Map<Id, Account> duplicateStoreAccountsByUUID,
        Map<Id, String> opportunityOwners
    ) {
        List<Agreement__c> agreements = AgreementsSelector.newInstance()
            .selectActiveAgreementsByAccountIds(new Set<Id>(storeAccountsByUUID.keySet()));

        for (Agreement__c eachAgreement : agreements) {
            if (storeAccountsByUUID.containsKey(eachAgreement.Account__c)) {
                duplicateStoreAccountsByUUID.put(
                    eachAgreement.Account__c,
                    storeAccountsByUUID.get(eachAgreement.Account__c)
                );
                String opportunityOwnerName = eachAgreement.Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner_Full_Name__c;
                String opportunityOwnerEmail = eachAgreement.Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Email;
                opportunityOwners.put(
                    eachAgreement.Account__c,
                    opportunityOwnerName + OPEN_BRACES + opportunityOwnerEmail + CLOSE_BRACES
                );
            }
        }
        for (Id eachAccountId : storeAccountsByUUID.keySet()) {
            if (
                !duplicateStoreAccountsByUUID.containsKey(eachAccountId) &&
                storeAccountsByUUID.get(eachAccountId).Record_Type_Name__c == STORE
            ) {
                validStoreAccountsByUUID.put(eachAccountId, storeAccountsByUUID.get(eachAccountId));
            }
        }
    }

    /**
     * @description It is used to log duplicate Stores in Generic Logger Object
     * @param duplicateStoreAccountsByUUID
     * @param opportunityOwners
     */
    private void logduplicateStoresInGenericLogger(
        Map<Id, Account> duplicateStoreAccountsByUUID,
        Map<Id, String> opportunityOwners
    ) {
        String storeIdsToBeLogged = EMPTY_STRING;

        for (Id eachId : duplicateStoreAccountsByUUID.keySet()) {
            storeIdsToBeLogged += eachId + COMMA_DELIMITER;
        }

        if (storeIdsToBeLogged.endsWith(COMMA_DELIMITER)) {
            storeIdsToBeLogged = storeIdsToBeLogged.removeEnd(COMMA_DELIMITER);
        }

        Id key = new List<Id>(opportunityOwners.keySet())[0];
        String exceptionMessage =
            EXCEPTION_HEADER +
            storeIdsToBeLogged +
            OPPORTUNITY_OWNER +
            opportunityOwners.get(key);

        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.Low
                )
                .logMessage(exceptionMessage)
        );
    }
}