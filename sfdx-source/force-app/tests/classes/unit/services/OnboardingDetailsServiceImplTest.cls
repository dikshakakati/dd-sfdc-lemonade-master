/**
 * @author Deloitte
 * @date 07/04/2024
 * @description Test class for OnboardingDetailsServiceImpl class.
 */
@isTest(SeeAllData=false)
private class OnboardingDetailsServiceImplTest {
    private static final String ACCOUNT_ORDER_PROTOCOL = 'Email';
    private static final String ACCOUNT_TABLET_DELIVERY_METHOD = 'Drop-ship';
    private static final String ASSERT_MESSAGE_PAYLOAD_NOT_RETURNED = 'Unexpected result: Payload not returned for expected Store Id.';
    private static final String CONTACT_EMAIL = 'mockEmail@OnboardingDetailsServiceImplTest.com';
    private static final String CONTACT_FIRSTNAME = 'Antonio';
    private static final String CONTACT_LASTNAME = 'Montana';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String DOCUMENT_STATUS = 'Approved';
    private static final String DOCUMENT_TITLE = 'Document Title';
    private static final String DOCUMENT_TYPE_PASSPORT = 'Passport';
    private static final String MENU_URL = 'test.test.com';
    private static final String MOCK_INVALID_STORE_ID = '16159557';
    private static final String MOCK_STORE_ID = '1615955';
    private static final String MX_ORDER_SHIPPING_STATUS = 'Shipped';
    private static final String MX_ORDER_TRACKING_NUMBER = '23345';
    private static final String OPPORTUNITY_TYPE = 'New';
    private static final String STORE_ID_NOT_FOUND_FAILURE_MESSAGE = 'StoreId not found';
    private static final String VERTICAL_RX = 'Rx';
    private static final String WORK_ORDER_STATUS = 'Confirmed';
    private static final String WORK_STEP_STATUS = 'Complete';
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

    /**
     * @description To test onboarding details payload is generated and returned
     * when Store Id is received.
     */
    @isTest
    private static void testWhenStoreIdReceivedThenGenerateAndReturnOnboardingDetailsPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Menu_URL__c, MENU_URL)
            .setField(Account.Order_Protocol__c, ACCOUNT_ORDER_PROTOCOL)
            .setField(Account.Tablet_Delivery_Method__c, ACCOUNT_TABLET_DELIVERY_METHOD)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Proposed_Date_of_Menu__c, System.today())
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Email, CONTACT_EMAIL)
                                .setField(Contact.Phone, CONTACT_PHONE)
                        )
                }
            )
            .setChildren(
                'MX_Order_Account__r',
                new List<Fake>{
                    new Fake(MX_Order__c.class)
                        .setField(MX_Order__c.Tracking_Number__c, MX_ORDER_TRACKING_NUMBER)
                        .setField(MX_Order__c.Shipping_Carrier__c, MX_ORDER_TRACKING_NUMBER)
                        .setField(MX_Order__c.Shipment_Status__c, MX_ORDER_SHIPPING_STATUS)
                        .setParent(
                            'Contact__r',
                            new Fake(Contact.class)
                                .setField(Contact.FirstName, CONTACT_FIRSTNAME)
                                .setField(Contact.FirstName, CONTACT_LASTNAME)
                        )
                }
            )
            .toSObject();
        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.CreatedDate, System.now())
            .setField(WorkOrder.Status, WORK_ORDER_STATUS)
            .setParent(
                'ParentWorkOrder',
                new Fake(WorkOrder.class)
                    .setParent(
                        'Opportunity__r',
                        new Fake(Opportunity.class).setField(Opportunity.Type, OPPORTUNITY_TYPE)
                    )
            )
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_ACTIVATE_STORE),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_ACTIVATIONS_CHECKLIST),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_ENABLE_INTEGRATION),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_INGEST_MENU),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_REVIEW_AND_TRIAGE),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_BANKING),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_MENU),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                        .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_STORE)
                }
            )
            .toSObject();
        Mx_Fraud_Document__c newMxFraudDocument = (Mx_Fraud_Document__c) new Fake(
                Mx_Fraud_Document__c.class
            )
            .setField(Mx_Fraud_Document__c.Document_Title__c, DOCUMENT_TITLE)
            .setField(Mx_Fraud_Document__c.Document_Version__c, 1)
            .setField(Mx_Fraud_Document__c.Mx_Document_Type__c, DOCUMENT_TYPE_PASSPORT)
            .setField(Mx_Fraud_Document__c.Mx_Document_Verification_Status__c, DOCUMENT_STATUS)
            .setField(Mx_Fraud_Document__c.Mx_Document_Verification_Notes__c, DOCUMENT_STATUS)
            .setField(Mx_Fraud_Document__c.CreatedDate, System.now())
            .setField(Mx_Fraud_Document__c.LastModifiedDate, System.now())
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IMxFraudDocumentsSelector mockMxFraudDocumentsSelector = (IMxFraudDocumentsSelector) mocks.mock(
            IMxFraudDocumentsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockMxFraudDocumentsSelector.sObjectType())
            .thenReturn(Mx_Fraud_Document__c.SObjectType);
        mocks.when(
                mockMxFraudDocumentsSelector.selectByStoreAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<Mx_Fraud_Document__c>{ newMxFraudDocument });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectXrefByExternalId(new List<String>{ MOCK_STORE_ID }))
            .thenReturn(
                new List<Xref__c>{
                    new Xref__c(
                        External_ID__c = MOCK_STORE_ID,
                        Salesforce_Account_Name__c = storeAccountId
                    )
                }
            );
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
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsAndRelatedEntitiesByAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectMarketplaceWorkOrdersAndWorkStepsByAccountIdsAndWorkStepTypes(
                    new Set<Id>{ storeAccountId },
                    WORK_STEP_TYPES_TO_QUERY
                )
            )
            .thenReturn(new List<WorkOrder>{ newWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockMxFraudDocumentsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Map<String, String> payload = OnboardingDetailsService.collectOnboardingDetailsBasedOnStoreIds(
            new Set<String>{ MOCK_STORE_ID }
        );
        System.assertEquals(
            true,
            payload.containsKey(MOCK_STORE_ID),
            ASSERT_MESSAGE_PAYLOAD_NOT_RETURNED
        );
    }

    /**
     * @description To test failure response is sent when received Store Id does not exist in DDMX.
     */
    @isTest
    private static void testWhenInvalidStoreIdReceivedThenReturnFailureResponse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByExternalId(new List<String>{ MOCK_INVALID_STORE_ID })
            )
            .thenReturn(new List<Xref__c>());
        mocks.when(
                mockXrefsSelector.selectXrefsByExternalIdsAndPrimaryVertical(
                    new List<String>{ MOCK_INVALID_STORE_ID },
                    VERTICAL_RX
                )
            )
            .thenReturn(new List<Xref__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockXrefsSelector);
        Map<String, String> payload = OnboardingDetailsService.collectOnboardingDetailsBasedOnStoreIds(
            new Set<String>{ MOCK_INVALID_STORE_ID }
        );
        System.assertEquals(
            true,
            payload.containsKey(MOCK_INVALID_STORE_ID),
            ASSERT_MESSAGE_PAYLOAD_NOT_RETURNED
        );
        System.assertEquals(
            true,
            payload.get(MOCK_INVALID_STORE_ID).contains(STORE_ID_NOT_FOUND_FAILURE_MESSAGE),
            ASSERT_MESSAGE_PAYLOAD_NOT_RETURNED
        );
    }
}