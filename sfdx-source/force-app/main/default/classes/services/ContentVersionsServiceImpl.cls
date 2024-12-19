/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Service implementation class for Content Version related logic.
 */
public inherited sharing class ContentVersionsServiceImpl implements IContentVersionsService {
    private static final String CONTENT_VERSION_TYPE_FRAUD = 'Fraud';
    private static final String LOG_DOMAIN_FRAUD_DOCUMENT_CREATION = 'Mx Fraud Documents Creation';
    private static final String LOG_DOMAIN_FRAUD_DOCUMENT_UPDATE = 'Mx Fraud Documents Update';
    private static final String LOG_SERVICE_CONTENT_VERSION = 'Content Versions Service';
    private static final String MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME = 'Mx_Fraud_Documents_Library_Id';
    private static final String MX_ORDER_NAME_KEY = 'MX';
    private static final String VERIFICATION_STATUS_PENDING_REVIEW = 'Pending Review';
    private static final String VERTICAL_RX = 'Rx';
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';
    private static Map<Id, Id> storeAccountIdToWorkPlanId;
    private static Map<String, Map<String, Mx_Fraud_Document__c>> storeAccountIdToExistingMxFraudDocument;
    private static Map<Id, String> storeAccountSFDCIdToStoreId;
    private static Map<String, List<ContentVersion>> storeIdToContentVersions;
    private static Map<String, Id> storeIdToSFDCAccountId;
    private static Id mxFraudDocumentsLibraryId;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public ContentVersionsServiceImpl() {
        storeAccountIdToWorkPlanId = new Map<Id, Id>();
        storeAccountIdToExistingMxFraudDocument = new Map<String, Map<String, Mx_Fraud_Document__c>>();
        storeAccountSFDCIdToStoreId = new Map<Id, String>();
        storeIdToContentVersions = new Map<String, List<ContentVersion>>();
        storeIdToSFDCAccountId = new Map<String, Id>();
        collectMxFraudDocumentLibraryId();
    }

    /**
     * @description It organizes the Content Version Documents inserted from API services
     * based on type of document.
     * @JIRA# LEM-15836
     * @param contentVersions
     */
    public void organizeDocumentsInsertedFromAPIService(List<ContentVersion> contentVersions) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        Map<String, List<ContentVersion>> mxOrderContentVersions = new Map<String, List<ContentVersion>>();
        if (contentVersions == null || contentVersions.isEmpty()) {
            return;
        }
        for (ContentVersion eachContentVersion : contentVersions) {
            if (eachContentVersion.Type__c == CONTENT_VERSION_TYPE_FRAUD) {
                collectStoreIdToContentVersionsByRelatedToId(eachContentVersion);
                contentDocumentLinks.add(
                    new ContentDocumentLink(
                        ContentDocumentId = eachContentVersion.ContentDocumentId,
                        LinkedEntityId = mxFraudDocumentsLibraryId
                    )
                );
            } else if (
                eachContentVersion.Related_To_Id__c != null &&
                eachContentVersion.Related_To_Id__c.contains(MX_ORDER_NAME_KEY)
            ) {
                if (!mxOrderContentVersions.containsKey(eachContentVersion.Related_To_Id__c)) {
                    mxOrderContentVersions.put(
                        eachContentVersion.Related_To_Id__c,
                        new List<ContentVersion>()
                    );
                }
                mxOrderContentVersions.get(eachContentVersion.Related_To_Id__c)
                    .add(eachContentVersion);
            }
        }
        contentDocumentLinks.addAll(
            createContentDocumentLinksByMxOrderNumber(mxOrderContentVersions)
        );
        insertSObjects(contentDocumentLinks);
        if (storeIdToContentVersions.isEmpty()) {
            return;
        }
        collectSFDCStoreAccountIdsByStoreIds();
        collectWorkPlanIdsByStoreAccountIds();
        collectExistingMxFraudDocuments();
        createMxFraudDocumentsByContentVersions();
    }

    /**
     * @description It fires Insert DML statement to create sObject records.
     * @JIRA# LEM-15836
     * @param mxFraudDocuments
     * @param contentVersionToUpdateMxFraudId
     * @param contentDocumentLinks
     * @param sObjectsToUpdate
     */
    private void associateContentVersionsToInsertedMxFraudDocuments(
        List<Mx_Fraud_Document__c> mxFraudDocuments,
        Map<String, List<ContentVersion>> contentVersionToUpdateMxFraudId,
        List<ContentDocumentLink> contentDocumentLinks,
        List<SObject> sObjectsToUpdate
    ) {
        for (Mx_Fraud_Document__c eachMxFraudDocument : mxFraudDocuments) {
            for (
                ContentVersion eachContentVersion : contentVersionToUpdateMxFraudId.get(
                    eachMxFraudDocument.Store_Id__c
                )
            ) {
                sObjectsToUpdate.add(
                    new ContentVersion(
                        Id = eachContentVersion.Id,
                        Mx_Fraud_Document__c = eachMxFraudDocument.Id
                    )
                );
                contentDocumentLinks.add(
                    new ContentDocumentLink(
                        ContentDocumentId = eachContentVersion.ContentDocumentId,
                        LinkedEntityId = eachMxFraudDocument.Id
                    )
                );
            }
        }
    }

    /**
     * @description It collects the Content Versions based on Store Id
     * added in Related To Id field.
     * @JIRA# LEM-15836
     * @param contentVersionToCollect
     */
    private void collectStoreIdToContentVersionsByRelatedToId(
        ContentVersion contentVersionToCollect
    ) {
        if (!storeIdToContentVersions.containsKey(contentVersionToCollect.Related_To_Id__c)) {
            storeIdToContentVersions.put(
                contentVersionToCollect.Related_To_Id__c,
                new List<ContentVersion>()
            );
        }
        storeIdToContentVersions.get(contentVersionToCollect.Related_To_Id__c)
            .add(contentVersionToCollect);
    }

    /**
     * @description It create Content Document Link instances associtating to Mx Orders
     * based on passed Mx Order Names.
     * @JIRA# LEM-17073
     * @param mxOrderContentVersions
     * @return List<ContentDocumentLink>
     */
    private List<ContentDocumentLink> createContentDocumentLinksByMxOrderNumber(
        Map<String, List<ContentVersion>> mxOrderContentVersions
    ) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        if (mxOrderContentVersions.isEmpty()) {
            return contentDocumentLinks;
        }
        for (
            MX_Order__c eachMxOrder : MerchantOrdersSelector.newInstance()
                .selectByName(mxOrderContentVersions.keySet())
        ) {
            if (!mxOrderContentVersions.containsKey(eachMxOrder.Name)) {
                continue;
            }
            for (ContentVersion eachContentVersion : mxOrderContentVersions.get(eachMxOrder.Name)) {
                contentDocumentLinks.add(
                    new ContentDocumentLink(
                        ContentDocumentId = eachContentVersion.ContentDocumentId,
                        LinkedEntityId = eachMxOrder.Id
                    )
                );
            }
        }
        return contentDocumentLinks;
    }

    /**
     * @description It creates Mx Fraud Document records for newly created Content Version documents
     * for Fraud verification.
     * @JIRA# LEM-15836
     */
    private void createMxFraudDocumentsByContentVersions() {
        List<Mx_Fraud_Document__c> mxFraudDocumentsToInsert = new List<Mx_Fraud_Document__c>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<SObject> sObjectsToUpdate = new List<SObject>();
        Map<String, List<ContentVersion>> contentVersionToUpdateMxFraudId = new Map<String, List<ContentVersion>>();
        Mx_Fraud_Document__c mxFraudDocument;
        for (String eachStoreId : storeIdToContentVersions.keySet()) {
            for (ContentVersion eachContentVersion : storeIdToContentVersions.get(eachStoreId)) {
                if (
                    storeAccountIdToExistingMxFraudDocument.containsKey(
                        storeIdToSFDCAccountId.get(eachStoreId)
                    ) &&
                    storeAccountIdToExistingMxFraudDocument.get(
                            storeIdToSFDCAccountId.get(eachStoreId)
                        )
                        .containsKey(eachContentVersion.Document_Type__c)
                ) {
                    mxFraudDocument = storeAccountIdToExistingMxFraudDocument.get(
                            storeIdToSFDCAccountId.get(eachStoreId)
                        )
                        .get(eachContentVersion.Document_Type__c);
                    sObjectsToUpdate.add(
                        new Mx_Fraud_Document__c(
                            Id = mxFraudDocument.Id,
                            Document_Version__c = mxFraudDocument.Document_Version__c + 1,
                            Mx_Document_Verification_Status__c = VERIFICATION_STATUS_PENDING_REVIEW
                        )
                    );
                    sObjectsToUpdate.add(
                        new ContentVersion(
                            Id = eachContentVersion.Id,
                            Mx_Fraud_Document__c = mxFraudDocument.Id
                        )
                    );
                    contentDocumentLinks.add(
                        new ContentDocumentLink(
                            ContentDocumentId = eachContentVersion.ContentDocumentId,
                            LinkedEntityId = mxFraudDocument.Id
                        )
                    );
                } else {
                    mxFraudDocument = new Mx_Fraud_Document__c();
                    mxFraudDocument.Document_Title__c = eachContentVersion.Title;
                    mxFraudDocument.Document_Version__c = Integer.valueOf(
                        eachContentVersion.VersionNumber
                    );
                    mxFraudDocument.Mx_Country__c = eachContentVersion.Mx_Country__c;
                    mxFraudDocument.Mx_Document_Type__c = eachContentVersion.Document_Type__c;
                    mxFraudDocument.Mx_Document_Verification_Status__c = eachContentVersion.Mx_Document_Verification_Status__c;
                    mxFraudDocument.Store_Id__c = eachContentVersion.Related_To_Id__c;
                    if (storeIdToSFDCAccountId.containsKey(eachStoreId)) {
                        mxFraudDocument.Mx_Store_Id__c = storeIdToSFDCAccountId.get(eachStoreId);
                        if (
                            storeAccountIdToWorkPlanId.containsKey(
                                storeIdToSFDCAccountId.get(eachStoreId)
                            )
                        ) {
                            mxFraudDocument.Work_Plan__c = storeAccountIdToWorkPlanId.get(
                                storeIdToSFDCAccountId.get(eachStoreId)
                            );
                        }
                    }
                    mxFraudDocumentsToInsert.add(mxFraudDocument);
                    if (
                        !contentVersionToUpdateMxFraudId.containsKey(
                            eachContentVersion.Related_To_Id__c
                        )
                    ) {
                        contentVersionToUpdateMxFraudId.put(
                            eachContentVersion.Related_To_Id__c,
                            new List<ContentVersion>()
                        );
                    }
                    contentVersionToUpdateMxFraudId.get(eachContentVersion.Related_To_Id__c)
                        .add(eachContentVersion);
                }
            }
        }
        insertSObjects(mxFraudDocumentsToInsert);
        associateContentVersionsToInsertedMxFraudDocuments(
            mxFraudDocumentsToInsert,
            contentVersionToUpdateMxFraudId,
            contentDocumentLinks,
            sObjectsToUpdate
        );
        updateSObjects(sObjectsToUpdate);
        insertSObjects(contentDocumentLinks);
    }

    /**
     * @description It is used to collect existing Mx Fraud Documents based on Store Account Ids.
     * @JIRA# LEM-15836
     */
    private void collectExistingMxFraudDocuments() {
        for (
            Mx_Fraud_Document__c eachMxFraudDocument : MxFraudDocumentsSelector.newInstance()
                .selectByStoreAccountIds(storeAccountSFDCIdToStoreId.keySet())
        ) {
            if (
                !storeAccountIdToExistingMxFraudDocument.containsKey(
                    eachMxFraudDocument.Mx_Store_Id__c
                )
            ) {
                storeAccountIdToExistingMxFraudDocument.put(
                    eachMxFraudDocument.Mx_Store_Id__c,
                    new Map<String, Mx_Fraud_Document__c>()
                );
            }
            storeAccountIdToExistingMxFraudDocument.get(eachMxFraudDocument.Mx_Store_Id__c)
                .put(eachMxFraudDocument.Mx_Document_Type__c, eachMxFraudDocument);
        }
    }

    /**
     * @description It collects the Mx Fraud Document Library Id.
     * @JIRA# LEM-15836
     */
    private void collectMxFraudDocumentLibraryId() {
        mxFraudDocumentsLibraryId = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME)
            .Configuration_Value__c;
    }

    /**
     * @description It is used to collect store Account Ids based on passed store Ids using Xrefs.
     * @JIRA# LEM-15836
     */
    private void collectSFDCStoreAccountIdsByStoreIds() {
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefsByExternalIdsAndPrimaryVertical(
                    new List<String>(storeIdToContentVersions.keySet()),
                    VERTICAL_RX
                )
        ) {
            storeIdToSFDCAccountId.put(
                eachXref.External_ID__c,
                eachXref.Salesforce_Account_Name__c
            );
            storeAccountSFDCIdToStoreId.put(
                eachXref.Salesforce_Account_Name__c,
                eachXref.External_ID__c
            );
        }
    }

    /**
     * @description It is used to collect Work Plan Ids based on store Account Ids.
     * @JIRA# LEM-15836
     */
    private void collectWorkPlanIdsByStoreAccountIds() {
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectWorkPlansByStoreAccountIDAndType(
                    new Set<Id>(storeIdToSFDCAccountId.values()),
                    new Set<String>{ WORK_PLAN_TYPE_ONBOARDING }
                )
        ) {
            storeAccountIdToWorkPlanId.put(
                eachWorkPlan.WorkOrder.AccountId,
                eachWorkPlan.Parent_Work_Plan__c
            );
        }
    }

    /**
     * @description It fires Insert DML statement to create sObject records.
     * @JIRA# LEM-15836
     * @param sObjectsToInsert
     */
    private void insertSObjects(List<sObject> sObjectsToInsert) {
        if (sObjectsToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerNew(sObjectsToInsert);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception sObjectInsertException) {
            Logger.publish(
                LogEntry.newExceptionLog(sObjectInsertException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_CONTENT_VERSION,
                        LOG_DOMAIN_FRAUD_DOCUMENT_CREATION,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(sObjectInsertException)
            );
        }
    }

    /**
     * @description It fires Insert DML statement to update sObject records.
     * @JIRA# LEM-15836
     * @param sObjectsToUpdate
     */
    private void updateSObjects(List<sObject> sObjectsToUpdate) {
        if (sObjectsToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerDirty(sObjectsToUpdate);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception sObjectUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(sObjectUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_CONTENT_VERSION,
                        LOG_DOMAIN_FRAUD_DOCUMENT_UPDATE,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(sObjectUpdateException)
            );
        }
    }
}