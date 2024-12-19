/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Test class for ContentVersionsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ContentVersionsServiceImplTest {
    private static final String CONTENT_VERSION_TYPE_FRAUD = 'Fraud';
    private static final String DOCUMENT_STATUS_APPROVED = 'Approved';
    private static final String DOCUMENT_STATUS_PENDING = 'Pending Review';
    private static final String DOCUMENT_TYPE_PASSPORT = 'Passport';
    private static final String MOCK_STORE_ID = '165551';
    private static final String MOCK_MX_ORDER_NUMBER = 'MX000001';
    private static final String MX_COUNTRY_US = 'US';
    private static final String MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME = 'Mx_Fraud_Documents_Library_Id';
    private static final String VERTICAL_RX = 'Rx';
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';

    /**
     * @description To test Mx Fraud Document records created for newly created content versions.
     */
    @isTest
    private static void testWhenContentVersionsReceivedThenCreateMxFraudDocuments() {
        Id contentVersionId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        Id contentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id contentWorkspaceId = Fake.generateId(ContentWorkspace.class);
        ContentVersion newContentVersion = (ContentVersion) new Fake(ContentVersion.class)
            .setField(ContentVersion.Id, contentVersionId)
            .setField(ContentVersion.Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(ContentVersion.ContentDocumentId, contentDocumentId)
            .setField(ContentVersion.Related_To_Id__c, MOCK_STORE_ID)
            .setField(ContentVersion.Title, DOCUMENT_TYPE_PASSPORT)
            .setField(ContentVersion.Type__c, CONTENT_VERSION_TYPE_FRAUD)
            .setField(ContentVersion.VersionNumber, 1)
            .setField(ContentVersion.Mx_Country__c, MX_COUNTRY_US)
            .setField(ContentVersion.Mx_Document_Verification_Status__c, DOCUMENT_STATUS_PENDING)
            .toSObject();
        WorkPlan newWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class).setField(WorkOrder.AccountId, storeAccountId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IMxFraudDocumentsSelector mockMxFraudDocumentsSelector = (IMxFraudDocumentsSelector) mocks.mock(
            IMxFraudDocumentsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME,
                    Configuration_Value__c = contentWorkspaceId
                )
            );
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefsByExternalIdsAndPrimaryVertical(
                    new List<String>{ MOCK_STORE_ID },
                    VERTICAL_RX
                )
            )
            .thenReturn(
                new List<Xref__c>{
                    new Xref__c(
                        External_ID__c = MOCK_STORE_ID,
                        Salesforce_Account_Name__c = storeAccountId
                    )
                }
            );
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByStoreAccountIDAndType(
                    new Set<Id>{ storeAccountId },
                    new Set<String>{ WORK_PLAN_TYPE_ONBOARDING }
                )
            )
            .thenReturn(new List<WorkPlan>{ newWorkPlan });
        mocks.when(mockMxFraudDocumentsSelector.sObjectType())
            .thenReturn(Mx_Fraud_Document__c.SObjectType);
        mocks.when(
                mockMxFraudDocumentsSelector.selectByStoreAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<Mx_Fraud_Document__c>());
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockMxFraudDocumentsSelector);
        ContentVersionsService.organizeDocumentsInsertedFromAPIService(
            new List<ContentVersion>{ newContentVersion }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            ContentDocumentLink.LinkedEntityId => contentWorkspaceId
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Mx_Fraud_Document__c.Document_Title__c => DOCUMENT_TYPE_PASSPORT,
                            Mx_Fraud_Document__c.Document_Version__c => 1,
                            Mx_Fraud_Document__c.Mx_Country__c => MX_COUNTRY_US,
                            Mx_Fraud_Document__c.Mx_Document_Type__c => DOCUMENT_TYPE_PASSPORT,
                            Mx_Fraud_Document__c.Mx_Document_Verification_Status__c => DOCUMENT_STATUS_PENDING
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ ContentVersion.Id => contentVersionId }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork();
    }

    /**
     * @description To test Mx Fraud Document records updated for newly created content versions
     * when Mx Fraud Document exists for store account.
     */
    @isTest
    private static void testWhenContentVersionsReceivedThenUpdateExistingMxFraudDocuments() {
        Id contentVersionId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        Id contentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id contentWorkspaceId = Fake.generateId(ContentWorkspace.class);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Store_Id__c, MOCK_STORE_ID)
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_APPROVED
            )
            .toSObject();
        ContentVersion newContentVersion = (ContentVersion) new Fake(ContentVersion.class)
            .setField(ContentVersion.Id, contentVersionId)
            .setField(ContentVersion.ContentDocumentId, contentDocumentId)
            .setField(ContentVersion.Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(ContentVersion.Related_To_Id__c, MOCK_STORE_ID)
            .setField(ContentVersion.Title, DOCUMENT_TYPE_PASSPORT)
            .setField(ContentVersion.Type__c, CONTENT_VERSION_TYPE_FRAUD)
            .setField(ContentVersion.VersionNumber, 1)
            .setField(ContentVersion.Mx_Country__c, MX_COUNTRY_US)
            .setField(ContentVersion.Mx_Document_Verification_Status__c, DOCUMENT_STATUS_APPROVED)
            .toSObject();
        WorkPlan newWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class).setField(WorkOrder.AccountId, storeAccountId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IMxFraudDocumentsSelector mockMxFraudDocumentsSelector = (IMxFraudDocumentsSelector) mocks.mock(
            IMxFraudDocumentsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_DOCUMENT_LIBRARY_STATIC_CONFIG_NAME,
                    Configuration_Value__c = contentWorkspaceId
                )
            );
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefsByExternalIdsAndPrimaryVertical(
                    new List<String>{ MOCK_STORE_ID },
                    VERTICAL_RX
                )
            )
            .thenReturn(
                new List<Xref__c>{
                    new Xref__c(
                        External_ID__c = MOCK_STORE_ID,
                        Salesforce_Account_Name__c = storeAccountId
                    )
                }
            );
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByStoreAccountIDAndType(
                    new Set<Id>{ storeAccountId },
                    new Set<String>{ WORK_PLAN_TYPE_ONBOARDING }
                )
            )
            .thenReturn(new List<WorkPlan>{ newWorkPlan });
        mocks.when(mockMxFraudDocumentsSelector.sObjectType())
            .thenReturn(Mx_Fraud_Document__c.SObjectType);
        mocks.when(
                mockMxFraudDocumentsSelector.selectByStoreAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<Mx_Fraud_Document__c>{ newMxFraudDocument });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockMxFraudDocumentsSelector);
        Test.startTest();
        ContentVersionsService.organizeDocumentsInsertedFromAPIService(
            new List<ContentVersion>{ newContentVersion }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            ContentDocumentLink.LinkedEntityId => contentWorkspaceId
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Mx_Fraud_Document__c.Document_Version__c => 2,
                            Mx_Fraud_Document__c.Mx_Document_Verification_Status__c => DOCUMENT_STATUS_PENDING
                        },
                        new Map<SObjectField, Object>{ ContentVersion.Id => contentVersionId }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test Return label documents are associated to Mx Orders
     * by creating Content Document Link based on Related To Id.
     */
    @isTest
    private static void testWhenReturnLabelContentVersionsReceivedThenAssociateToMxOrder() {
        Id contentVersionId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        Id contentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        ContentVersion newContentVersion = (ContentVersion) new Fake(ContentVersion.class)
            .setField(ContentVersion.Id, contentVersionId)
            .setField(ContentVersion.ContentDocumentId, contentDocumentId)
            .setField(ContentVersion.Related_To_Id__c, MOCK_MX_ORDER_NUMBER)
            .setField(ContentVersion.VersionNumber, 1)
            .toSObject();
        MX_Order__c newMxOrder = (MX_Order__c) new Fake(MX_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Name, MOCK_MX_ORDER_NUMBER)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(mockMerchantOrdersSelector.selectByName(new Set<String>{ MOCK_MX_ORDER_NUMBER }))
            .thenReturn(new List<MX_Order__c>{ newMxOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ContentVersionsService.organizeDocumentsInsertedFromAPIService(
            new List<ContentVersion>{ newContentVersion }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            ContentDocumentLink.LinkedEntityId => mxOrderId
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Content Document Link not created
     * when Invalid Mx Order Name is received on Related To Id field.
     */
    @isTest
    private static void testWhenReturnLabelContentVersionsReceivedWithInvalidMxOrderNameThenContentDocumentLinkNotCreated() {
        Id contentVersionId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        Id contentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        ContentVersion newContentVersion = (ContentVersion) new Fake(ContentVersion.class)
            .setField(ContentVersion.Id, contentVersionId)
            .setField(ContentVersion.ContentDocumentId, contentDocumentId)
            .setField(ContentVersion.Related_To_Id__c, MOCK_MX_ORDER_NUMBER)
            .setField(ContentVersion.VersionNumber, 1)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(mockMerchantOrdersSelector.selectByName(new Set<String>{ MOCK_MX_ORDER_NUMBER }))
            .thenReturn(new List<MX_Order__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ContentVersionsService.organizeDocumentsInsertedFromAPIService(
            new List<ContentVersion>{ newContentVersion }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}