/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Test class for MxFraudDocumentsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class MxFraudDocumentsServiceImplTest {
    private static final String DOCUMENT_STATUS_PENDING = 'Pending Review';
    private static final String DOCUMENT_TYPE_PASSPORT = 'Passport';
    private static final String INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD = 'Mx_Fraud_Document_Integration';
    private static final String INTERFACE_TRANSACTION_STATUS_NEW = 'New';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String MOCK_STORE_ID = '165551';
    private static final String MX_COUNTRY_US = 'US';
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';

    /**
     * @description To test Mx Fraud Documents outboound integration is initiated
     * when Mx Fraud Document records inserted.
     * Collect Mx Fraud Documents based on Store Account SFDC Id when Store Id is not populated.
     */
    @isTest
    private static void testWhenMxFraudDocumentsReceivedThenGeneratePayloadAndCreateInterfaceTransaction() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.CreatedDate, System.now())
            .setField(Mx_Fraud_Document__c.LastModifiedDate, System.now())
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_PENDING
            )
            .setField(Mx_Fraud_Document__c.Work_Plan__c, parentWorkPlanId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
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
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                )
            )
            .thenReturn(new Interface_Transaction_Configuration__mdt(Retry_Limit__c = 3));
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(
            new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c => INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                            Interface_Transaction__c.Record_Id__c => MOCK_STORE_ID,
                            Interface_Transaction__c.Remaining_Retry_Attempts__c => 3,
                            Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Mx Fraud Documents outboound integration is initiated
     * when Mx Fraud Document records inserted.
     * Collect Mx Fraud Documents based on Store Id when Store Id is present.
     */
    @isTest
    private static void testWhenMxFraudDocumentsReceivedWithStoreIdPopulatedThenGeneratePayloadAndCreateInterfaceTransaction() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.CreatedDate, System.now())
            .setField(Mx_Fraud_Document__c.LastModifiedDate, System.now())
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Store_Id__c, MOCK_STORE_ID)
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_PENDING
            )
            .setField(Mx_Fraud_Document__c.Work_Plan__c, parentWorkPlanId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
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
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                )
            )
            .thenReturn(new Interface_Transaction_Configuration__mdt(Retry_Limit__c = 3));
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(
            new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c => INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                            Interface_Transaction__c.Record_Id__c => MOCK_STORE_ID,
                            Interface_Transaction__c.Remaining_Retry_Attempts__c => 3,
                            Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Log record (Log__c) is created when exception occurs
     * while inserting Interface Transaction.
     */
    @isTest
    private static void testWhenInsertExceptionOccursThenCreateErrorLog() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.CreatedDate, System.now())
            .setField(Mx_Fraud_Document__c.LastModifiedDate, System.now())
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Store_Id__c, MOCK_STORE_ID)
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_PENDING
            )
            .setField(Mx_Fraud_Document__c.Work_Plan__c, parentWorkPlanId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
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
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                )
            )
            .thenReturn(new Interface_Transaction_Configuration__mdt(Retry_Limit__c = 3));
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        String exceptionMessage;
        try {
            MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(
                new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
            );
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => exceptionMessage }
                )
            );
    }

    /**
     * @description To test Log record (Log__c) is created when exception occurs
     * while processing Mx Fraud Document.
     */
    @isTest
    private static void testWhenRuntimeExceptionOccursThenCreateErrorLog() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.CreatedDate, System.now())
            .setField(Mx_Fraud_Document__c.LastModifiedDate, System.now())
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Store_Id__c, MOCK_STORE_ID)
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_PENDING
            )
            .setField(Mx_Fraud_Document__c.Work_Plan__c, parentWorkPlanId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(null);
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                )
            )
            .thenReturn(null);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(
            new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.HIGH.name()
                    }
                )
            );
    }

    /**
     * @description To test Mx Fraud Documents outboound integration is not initiated
     * when Interface Transaction with payload already exists for Store Id.
     */
    @isTest
    private static void testWhenRecentInterfaceTransactionExistsForStoreIdThenDoNotInitiateOutboundIntegration() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_PENDING
            )
            .setField(Mx_Fraud_Document__c.Work_Plan__c, parentWorkPlanId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
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
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ MOCK_STORE_ID }
                )
            )
            .thenReturn(
                new List<Interface_Transaction__c>{
                    (Interface_Transaction__c) new Fake(Interface_Transaction__c.class)
                        .setField(Interface_Transaction__c.Record_Id__c, MOCK_STORE_ID)
                        .setField(
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c,
                            INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                        )
                        .setField(Interface_Transaction__c.CreatedDate, System.now().addMinutes(-4))
                        .toSObject()
                }
            );
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                )
            )
            .thenReturn(new Interface_Transaction_Configuration__mdt(Retry_Limit__c = 3));
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(
            new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Mx Fraud Documents outboound integration is initiated
     * when outdated Interface Transaction with payload exists for Store Id.
     */
    @isTest
    private static void testWhenOlderInterfaceTransactionExistsForStoreIdThenInitiateOutboundIntegration() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id mxFraudDocumentId = fflib_IDGenerator.generate(Mx_Fraud_Document__c.SObjectType);
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Id, mxFraudDocumentId)
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.CreatedDate, System.now())
            .setField(Mx_Fraud_Document__c.LastModifiedDate, System.now())
            .setField(Mx_Fraud_Document__c.Mx_Store_Id__c, storeAccountId)
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Country__c, MX_COUNTRY_US)
            .setField(
                Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
                DOCUMENT_STATUS_PENDING
            )
            .setField(Mx_Fraud_Document__c.Work_Plan__c, parentWorkPlanId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
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
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ MOCK_STORE_ID }
                )
            )
            .thenReturn(
                new List<Interface_Transaction__c>{
                    (Interface_Transaction__c) new Fake(Interface_Transaction__c.class)
                        .setField(Interface_Transaction__c.Record_Id__c, MOCK_STORE_ID)
                        .setField(
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c,
                            INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                        )
                        .setField(Interface_Transaction__c.CreatedDate, System.now().addMinutes(-6))
                        .toSObject()
                }
            );
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
                )
            )
            .thenReturn(new Interface_Transaction_Configuration__mdt(Retry_Limit__c = 3));
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        MxFraudDocumentsService.sendMxFraudDocumentDetailsForOutboundIntegration(
            new List<Mx_Fraud_Document__c>{ newMxFraudDocument }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c => INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                            Interface_Transaction__c.Record_Id__c => MOCK_STORE_ID,
                            Interface_Transaction__c.Remaining_Retry_Attempts__c => 3,
                            Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}