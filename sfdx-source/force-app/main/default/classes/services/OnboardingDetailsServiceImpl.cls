/**
 * @author Deloitte
 * @date 07/04/2024
 * @description Service implementation class for onboarding details related logic.
 */
public inherited sharing class OnboardingDetailsServiceImpl implements IOnboardingDetailsService {
    private static final String BUSINESS_VERIFICATION_STATUS_APPROVED = 'Approved';
    private static final String BUSINESS_VERIFICATION_STATUS_DENIED = 'Denied';
    private static final String BUSINESS_VERIFICATION_STATUS_DOCUMENTATION_REQUIRED = 'Documentation Required';
    private static final String CASE_KEY = 'Case';
    private static final String CASE_KEY_PLACEHOLDER = 'CaseDetailsWrapper';
    private static final Integer FAILURE_STATUS_CODE = 400;
    private static final String STORE_ID_NOT_FOUND_FAILURE_MESSAGE = 'StoreId not found';
    private static final String VERTICAL_RX = 'Rx';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_DEAD = 'Dead';
    private static final String WORK_STEP_STATUS_REASON_FRAUD = 'Fraud';
    private static final String WORK_STEP_TYPE_ACTIVATE_STORE = 'Activate Store';
    private static final String WORK_STEP_TYPE_ACTIVATIONS_CHECKLIST = 'Activations Checklist';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_TYPE_ENABLE_INTEGRATION = 'Enable Integration';
    private static final String WORK_STEP_TYPE_INGEST_MENU = 'Ingest Menu';
    private static final String WORK_STEP_TYPE_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_TYPE_SETUP_MENU = 'Setup Menu';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final Set<String> WORK_STEP_TYPES_TO_QUERY = new Set<String>{
        WORK_STEP_TYPE_ACTIVATE_STORE,
        WORK_STEP_TYPE_ACTIVATIONS_CHECKLIST,
        WORK_STEP_TYPE_DELIVER_TABLET,
        WORK_STEP_TYPE_ENABLE_INTEGRATION,
        WORK_STEP_TYPE_INGEST_MENU,
        WORK_STEP_TYPE_REVIEW_AND_TRIAGE,
        WORK_STEP_TYPE_SETUP_BANKING,
        WORK_STEP_TYPE_SETUP_MENU,
        WORK_STEP_TYPE_SETUP_STORE
    };
    private enum WORKSTEPTYPES {
        ACTIVATE_STORE,
        ACTIVATIONS_CHECKLIST,
        DELIVER_TABLET,
        ENABLE_INTEGRATION,
        INGEST_MENU,
        REVIEW_AND_TRIAGE,
        SETUP_BANKING,
        SETUP_MENU,
        SETUP_STORE
    }
    private static final Map<String, WORKSTEPTYPES> WORK_STEP_TYPES = new Map<String, WORKSTEPTYPES>{
        WORK_STEP_TYPE_ACTIVATE_STORE => WORKSTEPTYPES.ACTIVATE_STORE,
        WORK_STEP_TYPE_ACTIVATIONS_CHECKLIST => WORKSTEPTYPES.ACTIVATIONS_CHECKLIST,
        WORK_STEP_TYPE_DELIVER_TABLET => WORKSTEPTYPES.DELIVER_TABLET,
        WORK_STEP_TYPE_ENABLE_INTEGRATION => WORKSTEPTYPES.ENABLE_INTEGRATION,
        WORK_STEP_TYPE_INGEST_MENU => WORKSTEPTYPES.INGEST_MENU,
        WORK_STEP_TYPE_REVIEW_AND_TRIAGE => WORKSTEPTYPES.REVIEW_AND_TRIAGE,
        WORK_STEP_TYPE_SETUP_BANKING => WORKSTEPTYPES.SETUP_BANKING,
        WORK_STEP_TYPE_SETUP_MENU => WORKSTEPTYPES.SETUP_MENU,
        WORK_STEP_TYPE_SETUP_STORE => WORKSTEPTYPES.SETUP_STORE
    };
    private static Map<Id, Contact> storeAccountIdToContact;
    private static Map<Id, List<Mx_Fraud_Document__c>> storeAccountIdToMxFraudDocuments;
    private static Map<Id, MX_Order__c> storeAccountIdToMxOrder;
    private static Map<Id, WorkOrder> storeAccountIdToWorkOrder;
    private static Map<Id, Account> storeAccounts;
    private static Map<String, String> storeIdToOnboardingDetails;
    private static Map<String, Id> storeIdToStoreAccountSFDCId;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public OnboardingDetailsServiceImpl() {
        storeAccountIdToContact = new Map<Id, Contact>();
        storeAccountIdToMxFraudDocuments = new Map<Id, List<Mx_Fraud_Document__c>>();
        storeAccountIdToMxOrder = new Map<Id, MX_Order__c>();
        storeAccountIdToWorkOrder = new Map<Id, WorkOrder>();
        storeAccounts = new Map<Id, Account>();
        storeIdToOnboardingDetails = new Map<String, String>();
        storeIdToStoreAccountSFDCId = new Map<String, Id>();
    }

    /**
     * @description It collects the related onboarding details based on the passed Store Ids.
     * @JIRA# LEM-16642
     * @param storeIds
     * @return Map<String, String>
     */
    public Map<String, String> collectOnboardingDetailsBasedOnStoreIds(Set<String> storeIds) {
        Set<String> unidentifiedStoreIds = new Set<String>();
        unidentifiedStoreIds.addAll(storeIds);
        if (storeIds == null || storeIds.isEmpty()) {
            return storeIdToOnboardingDetails;
        }
        collectStoreAccountSFDCIds(storeIds);
        unidentifiedStoreIds.removeAll(storeIdToStoreAccountSFDCId.keySet());
        addFailureResponseForUnidentifiedStoreIds(unidentifiedStoreIds);
        //if all the store Ids received are not identified in org, then return failure message.
        if (unidentifiedStoreIds.equals(storeIds)) {
            return storeIdToOnboardingDetails;
        }
        collectOnboardingDetailsForIdentifiedStoreIds();
        return storeIdToOnboardingDetails;
    }

    /**
     * @description It is used to generate failure response for Store Ids that are not present in DDMx Org.
     * @JIRA# LEM-16642
     * @param unidentifiedStoreIds
     */
    private void addFailureResponseForUnidentifiedStoreIds(Set<String> unidentifiedStoreIds) {
        for (String eachStoreId : unidentifiedStoreIds) {
            storeIdToOnboardingDetails.put(
                eachStoreId,
                JSON.serialize(
                    new OnboardingDetailsWrapper.FailureResponseWrapper(
                        STORE_ID_NOT_FOUND_FAILURE_MESSAGE,
                        false,
                        FAILURE_STATUS_CODE
                    )
                )
            );
        }
    }

    /**
     * @description It is used to collect Decision Maker contact details and Tablet MxOrder details
     * based on passed store account Ids.
     * @JIRA# LEM-16642
     */
    private void collectAccountRelatedDetailsBasedOnStoreAccountIds() {
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectStoreAccountsAndRelatedEntitiesByAccountIds(
                    new Set<Id>(storeIdToStoreAccountSFDCId.values())
                )
        ) {
            storeAccounts.put(eachStoreAccount.Id, eachStoreAccount);
            if (
                eachStoreAccount.AccountContactRelations != null &&
                !eachStoreAccount.AccountContactRelations.isEmpty()
            ) {
                storeAccountIdToContact.put(
                    eachStoreAccount.Id,
                    eachStoreAccount.AccountContactRelations[0].Contact
                );
            }
            if (
                eachStoreAccount.MX_Order_Account__r != null &&
                !eachStoreAccount.MX_Order_Account__r.isEmpty()
            ) {
                storeAccountIdToMxOrder.put(
                    eachStoreAccount.Id,
                    eachStoreAccount.MX_Order_Account__r[0]
                );
            }
        }
    }

    /**
     * @description It is used to collect Work Orders and related Work Step details
     * based on passed store account IDs.
     * @JIRA# LEM-16642
     */
    private void collectChildWorkOrderDetailsBasedOnStoreAccountIds() {
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectMarketplaceWorkOrdersAndWorkStepsByAccountIdsAndWorkStepTypes(
                    new Set<Id>(storeIdToStoreAccountSFDCId.values()),
                    WORK_STEP_TYPES_TO_QUERY
                )
        ) {
            if (!storeAccountIdToWorkOrder.containsKey(eachWorkOrder.AccountId)) {
                storeAccountIdToWorkOrder.put(eachWorkOrder.AccountId, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to collect Fraud Document details
     * based on passed store account Ids.
     * @JIRA# LEM-16642
     */
    private void collectFraudDocumentDetailsBasedOnStoreAccountIds() {
        for (
            Mx_Fraud_Document__c eachMxFraudDocument : MxFraudDocumentsSelector.newInstance()
                .selectByStoreAccountIds(new Set<Id>(storeIdToStoreAccountSFDCId.values()))
        ) {
            if (!storeAccountIdToMxFraudDocuments.containsKey(eachMxFraudDocument.Mx_Store_Id__c)) {
                storeAccountIdToMxFraudDocuments.put(
                    eachMxFraudDocument.Mx_Store_Id__c,
                    new List<Mx_Fraud_Document__c>()
                );
            }
            storeAccountIdToMxFraudDocuments.get(eachMxFraudDocument.Mx_Store_Id__c)
                .add(eachMxFraudDocument);
        }
    }

    /**
     * @description It is used to generate onboarding details payload based on the existing Store Ids.
     * @JIRA# LEM-16642
     */
    private void collectOnboardingDetailsForIdentifiedStoreIds() {
        collectAccountRelatedDetailsBasedOnStoreAccountIds();
        collectChildWorkOrderDetailsBasedOnStoreAccountIds();
        collectFraudDocumentDetailsBasedOnStoreAccountIds();
        generateOnboardingDetailsPayloads();
    }

    /**
     * @description It is used to collect store Account Ids based on passed store Ids using Xrefs.
     * @JIRA# LEM-16642
     * @param storeIds
     */
    private void collectStoreAccountSFDCIds(Set<String> storeIds) {
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefsByExternalIdsAndPrimaryVertical(new List<String>(storeIds), VERTICAL_RX)
        ) {
            storeIdToStoreAccountSFDCId.put(
                eachXref.External_ID__c,
                eachXref.Salesforce_Account_Name__c
            );
        }
    }

    /**
     * @description It is used to add Work Step details to the payload based on Work Step Type.
     * @JIRA# LEM-16642
     * @param onboardingDetailsWrapperInstance
     * @param storeOnboardingDetails
     * @param workStepDetails
     */
    private void collectWorkStepDetails(
        OnboardingDetailsWrapper onboardingDetailsWrapperInstance,
        OnboardingDetailsWrapper.OnboardingDetailsOutboundWrapper storeOnboardingDetails,
        WorkStep workStepDetails
    ) {
        switch on WORK_STEP_TYPES.get(workStepDetails.Type__c) {
            when ACTIVATE_STORE {
                onboardingDetailsWrapperInstance.setActivateStoreDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when ACTIVATIONS_CHECKLIST {
                onboardingDetailsWrapperInstance.setActivationsChecklistDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when DELIVER_TABLET {
                onboardingDetailsWrapperInstance.setTabletDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when ENABLE_INTEGRATION {
                onboardingDetailsWrapperInstance.setStorePOSIntegrationSetupDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when INGEST_MENU {
                onboardingDetailsWrapperInstance.setIngestPOSMenuDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when REVIEW_AND_TRIAGE {
                onboardingDetailsWrapperInstance.setReviewAndTriageStatusReason(
                    storeOnboardingDetails,
                    workStepDetails
                );
                onboardingDetailsWrapperInstance.setBusinessVerificationStatus(
                    storeOnboardingDetails,
                    determineBusinessVerificationStatus(workStepDetails)
                );
            }
            when SETUP_BANKING {
                onboardingDetailsWrapperInstance.setBankingDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when SETUP_MENU {
                onboardingDetailsWrapperInstance.setMenuDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
            when SETUP_STORE {
                onboardingDetailsWrapperInstance.setSetupStoreDetails(
                    storeOnboardingDetails,
                    workStepDetails
                );
            }
        }
    }

    /**
     * @description It is used to determine the Business Verification status based on
     * Review & Triage Work Step.
     * @JIRA# LEM-16642
     * @param workStepDetails
     * @return String
     */
    private String determineBusinessVerificationStatus(WorkStep workStepDetails) {
        String businessVerificationStatus = '';
        if (
            workStepDetails.Status__c == WORK_STEP_STATUS_BLOCKED &&
            workStepDetails.Status_Reason__c == WORK_STEP_STATUS_REASON_FRAUD
        ) {
            businessVerificationStatus = BUSINESS_VERIFICATION_STATUS_DOCUMENTATION_REQUIRED;
        }
        if (
            workStepDetails.Status__c == WORK_STEP_STATUS_DEAD &&
            workStepDetails.Status_Reason__c == WORK_STEP_STATUS_REASON_FRAUD
        ) {
            businessVerificationStatus = BUSINESS_VERIFICATION_STATUS_DENIED;
        }
        if (workStepDetails.Status__c == WORK_STEP_STATUS_COMPLETE) {
            businessVerificationStatus = BUSINESS_VERIFICATION_STATUS_APPROVED;
        }
        return businessVerificationStatus;
    }

    /**
     * @description It generates the onboarding details payload based on collected details.
     * @JIRA# LEM-16642
     */
    private void generateOnboardingDetailsPayloads() {
        Id storeAccountId;
        OnboardingDetailsWrapper onboardingDetailsWrapperInstance = new OnboardingDetailsWrapper();
        for (String eachStoreId : storeIdToStoreAccountSFDCId.keySet()) {
            storeAccountId = storeIdToStoreAccountSFDCId.get(eachStoreId);
            OnboardingDetailsWrapper.OnboardingDetailsOutboundWrapper storeOnboardingDetails = new OnboardingDetailsWrapper.OnboardingDetailsOutboundWrapper(
                eachStoreId
            );
            onboardingDetailsWrapperInstance.setStoreAccountDetails(
                storeOnboardingDetails,
                storeAccounts.get(storeAccountId)
            );
            if (storeAccountIdToContact.containsKey(storeAccountId)) {
                onboardingDetailsWrapperInstance.setDecisionMakerContactDetails(
                    storeOnboardingDetails,
                    storeAccountIdToContact.get(storeAccountId)
                );
            }
            if (storeAccountIdToMxOrder.containsKey(storeAccountId)) {
                onboardingDetailsWrapperInstance.setTabletMxOrderDetails(
                    storeOnboardingDetails,
                    storeAccountIdToMxOrder.get(storeAccountId)
                );
            }
            setWorkOrderDetailsOnPayload(
                onboardingDetailsWrapperInstance,
                storeOnboardingDetails,
                storeAccountId
            );
            setFraudDocumentsDetailsOnPayload(
                onboardingDetailsWrapperInstance,
                storeOnboardingDetails,
                storeAccountId
            );
            // Case is a reserved keyword, hence added below replace key to add in payload.
            storeIdToOnboardingDetails.put(
                eachStoreId,
                JSON.serialize(storeOnboardingDetails).replace(CASE_KEY_PLACEHOLDER, CASE_KEY)
            );
        }
    }

    /**
     * @description It is used to add Work Step details to the payload based on Work Step Type.
     * @JIRA# LEM-16642
     * @param onboardingDetailsWrapperInstance
     * @param storeOnboardingDetails
     * @param storeAccountId
     */
    private void setFraudDocumentsDetailsOnPayload(
        OnboardingDetailsWrapper onboardingDetailsWrapperInstance,
        OnboardingDetailsWrapper.OnboardingDetailsOutboundWrapper storeOnboardingDetails,
        Id storeAccountId
    ) {
        if (storeAccountIdToMxFraudDocuments.containsKey(storeAccountId)) {
            for (
                Mx_Fraud_Document__c eachMxFraudDocument : storeAccountIdToMxFraudDocuments.get(
                    storeAccountId
                )
            ) {
                onboardingDetailsWrapperInstance.setBusinessVerificationDocumentDetails(
                    storeOnboardingDetails,
                    eachMxFraudDocument
                );
            }
        }
    }

    /**
     * @description It is used to add Work Step details to the payload based on Work Step Type.
     * @JIRA# LEM-16642
     * @param onboardingDetailsWrapperInstance
     * @param storeOnboardingDetails
     * @param storeAccountId
     */
    private void setWorkOrderDetailsOnPayload(
        OnboardingDetailsWrapper onboardingDetailsWrapperInstance,
        OnboardingDetailsWrapper.OnboardingDetailsOutboundWrapper storeOnboardingDetails,
        Id storeAccountId
    ) {
        if (storeAccountIdToWorkOrder.containsKey(storeAccountId)) {
            onboardingDetailsWrapperInstance.setWorkOrderDetails(
                storeOnboardingDetails,
                storeAccountIdToWorkOrder.get(storeAccountId)
            );
            for (WorkStep eachWorkStep : storeAccountIdToWorkOrder.get(storeAccountId).WorkSteps) {
                collectWorkStepDetails(
                    onboardingDetailsWrapperInstance,
                    storeOnboardingDetails,
                    eachWorkStep
                );
            }
        }
    }
}