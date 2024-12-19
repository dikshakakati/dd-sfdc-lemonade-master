/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Test class for MerchantOrdersServiceImpl class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class MerchantOrdersServiceImplTest {
    private static final String ACCOUNT_DECK_RANK = 'King of Spades';
    private static final String ACCOUNT_NAME = 'Vito Cafe';
    private static final String CONTACT_FIRST_NAME = 'Michael';
    private static final String CONTACT_LAST_NAME = 'Corleone';
    private static final String CONTACT_EMAIL = 'VitoC@vitocorptest.com';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String FAILED_RETURN_LABEL_TO_MX = 'Failed to Send to Mx';
    private static final String INTERFACE_TRANSACTION_STATUS_FAILURE = 'Failure';
    private static final String INTERFACE_TRANSACTION_STATUS_NEW = 'New';
    private static final String MX_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_NAME = 'MX-0001';
    private static final String MX_ORDER_STATUS_FAILED = 'Failed';
    private static final String MX_ORDER_VENDOR_NAME = 'Denali';
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String PHOTOSHOOT_OUTBOUND_CONFIG_NAME = 'Photoshoot_Outbound_Integration';
    private static final Integer REMAINING_RETRY_VALUE = 3;
    private static final String RETURN_LABEL_SENT_TO_MX = 'Return Label Sent to Mx';
    private static final String SHIPPING_ADDRESS = '221 Baker Street';
    private static final String SHIPPING_CITY = 'Moon City';
    private static final String SHIPPING_POSTAL_CODE = 'T-101';
    private static final String SHIPPING_STATE_CODE = 'NY';
    private static final String SHIPPING_COUNTRY_CODE = 'US';
    private static final String TABLET_OUTBOUND_CONFIG_NAME = 'Tablet_Outbound_Integration';
    private static final String MOCK_TRACKING_NUMBER = 'Track123';
    private static final Integer METADATA_VALUE = 5;
    private static final String REQUEST_TYPE_REPLACEMENT = 'Replacement';
    private static final String SHIPPING_CARRIER_FEDEX = 'Fedex';
    private static final String SHIPPING_TYPE_STANDARD = 'Standard';
    private static final String TABLET_PASSWORD = 'securePassword';
    private static final String TABLET_USERNAME = 'UserName';
    private static final String PRODUCT_SKU = '0987654321';
    private static final String XREF_EXTERNAL_ID = 'TestID123';
    private static final String XREF_FIGMENTID = 'TestFigmentID';
    private static final String MX_ORDER_VENDOR_ORDER_ID = 'abc-123-abc';
    private static final String MX_ORDER_ITEM_IDENTIFIER = '2344556';
    private static final String VENDOR_ORDER_ID_STATUS = 'We have found Vendor Order Id';
    private static final String VENDOR_ORDER_ID_NEGATIVE_CASE = 'Vendor ID was null';
    private static final String VENDOR_SOCIAL_MOBILE = 'Social Mobile';

    /**
     * @description To test Tablet outbound integration is initiated when Tablet Mx Order is created.
     */
    @isTest
    private static void testWhenMxOrdersCreatedThenGeneratePayloadAndCreateInterfaceTransactionRecord() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Shipping_Address__City__s, SHIPPING_CITY)
            .setField(MX_Order__c.Shipping_Address__PostalCode__s, SHIPPING_POSTAL_CODE)
            .setField(MX_Order__c.Shipping_Address__StateCode__s, SHIPPING_STATE_CODE)
            .setField(MX_Order__c.Shipping_Address__CountryCode__s, SHIPPING_COUNTRY_CODE)
            .setField(MX_Order__c.Tracking_Number__c, MOCK_TRACKING_NUMBER)
            .setField(MX_Order__c.Shipping_Carrier__c, SHIPPING_CARRIER_FEDEX)
            .setField(MX_Order__c.Shipping_Type__c, SHIPPING_TYPE_STANDARD)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            )
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.FirstName, CONTACT_FIRST_NAME)
                    .setField(Contact.LastName, CONTACT_LAST_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
                    .setField(Contact.Phone, CONTACT_PHONE)
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(Mx_Order_Product_Bundle__c.class)
                    .setField(Mx_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_TABLET)
            )
            .setChildren(
                'Merchant_Order_Items__r',
                new List<Fake>{
                    new Fake(MX_Order_Item__c.class)
                        .setField(MX_Order_Item__c.Quantity__c, 1)
                        .setField(MX_Order_Item__c.Password__c, TABLET_PASSWORD)
                        .setField(MX_Order_Item__c.Username__c, TABLET_USERNAME)
                        .setParent(
                            'Product__r',
                            new Fake(Product2.class)
                                .setField(Product2.StockKeepingUnit, PRODUCT_SKU)
                                .setField(Product2.Family, MX_ORDER_TYPE_TABLET)
                                .setField(Product2.Name, MX_ORDER_TYPE_TABLET)
                        )
                }
            )
            .toSObject();

        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.Figment_ID__c, XREF_FIGMENTID)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
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
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(new List<Interface_Transaction__c>{});
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectMDSXrefsBySalesforceAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectMerchantOrderRelatedDetailsById(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.initiateTabletIntegrationOnOrderCreation(
            new List<MX_Order__c>{ mockMxOrder }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Record_Id__c => String.valueOf(mxOrderId)
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test update on Actual Number of Stores field in parent WorkOrder
     * based on unique Store Accounts linked to the child Work Orders.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOrdersCreatedThenUpdateOrderStatusModifiedDate() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Status__c, ORDER_STATUS_DRAFT)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.updateStatusModifiedDate(new List<MX_Order__c>{ mockMxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Tablet outbound integration is initiated when Photoshoot Mx Order is created.
     */
    @isTest
    private static void testWhenPhotoshootMxOrdersCreatedThenGeneratePayloadAndCreateInterfaceTransactionRecord() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_PHOTOSHOOT)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Photoshoot_Review_Notes_Tags__c, MX_ORDER_VENDOR_NAME)
            .setParent('Account__r', new Fake(Account.class).setField(Account.Name, ACCOUNT_NAME))
            .setParent(
                'Work_Order__r',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Photoshoot_Date__c, System.today())
                    .setField(WorkOrder.Photoshoot_Time__c, System.now().time())
                    .setField(WorkOrder.Duration, 1)
                    .setParent(
                        'Store_Location_for_Photoshoot__r',
                        new Fake(Account.class).setField(Account.Name, ACCOUNT_NAME)
                    )
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(Mx_Order_Product_Bundle__c.class)
                    .setField(Mx_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_PHOTOSHOOT)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
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
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(new List<Interface_Transaction__c>{});
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectPhotoshootDetailsByMxOrderIds(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.initiateTabletIntegrationOnOrderCreation(
            new List<MX_Order__c>{ mockMxOrder }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Record_Id__c => String.valueOf(mxOrderId)
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test MxOrder 'Return_Label_Status__c' update
     * based on failed return label email response.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFailedRetunLabelResponseReceivedThenUpdateOrderReturnLabelStatus() {
        Id failedMxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.updateMxOrdersReturnLabelStatusBasedOnEmailResults(
            new Set<Id>{ failedMxOrderId },
            new Set<Id>()
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            MX_Order__c.Id => failedMxOrderId,
                            MX_Order__c.Return_Label_Status__c => FAILED_RETURN_LABEL_TO_MX
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test MxOrder 'Return_Label_Status__c' update
     * based on passed return label email response.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPassedRetunLabelResponseReceivedThenUpdateOrderReturnLabelStatus() {
        Id successMxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.updateMxOrdersReturnLabelStatusBasedOnEmailResults(
            new Set<Id>(),
            new Set<Id>{ successMxOrderId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            MX_Order__c.Id => successMxOrderId,
                            MX_Order__c.Return_Label_Status__c => RETURN_LABEL_SENT_TO_MX
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Tablet outbound payload regenarated when Tablet Mx order status is updated.
     */
    @isTest
    private static void testWhenMxOrdersStatusUpdatedThenRegeneratePayloadAndUpdateInterfaceTransaction() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Shipping_Address__City__s, SHIPPING_CITY)
            .setField(MX_Order__c.Shipping_Address__PostalCode__s, SHIPPING_POSTAL_CODE)
            .setField(MX_Order__c.Shipping_Address__StateCode__s, SHIPPING_STATE_CODE)
            .setField(MX_Order__c.Shipping_Address__CountryCode__s, SHIPPING_COUNTRY_CODE)
            .setField(MX_Order__c.Tracking_Number__c, MOCK_TRACKING_NUMBER)
            .setField(MX_Order__c.Shipping_Carrier__c, SHIPPING_CARRIER_FEDEX)
            .setField(MX_Order__c.Shipping_Type__c, SHIPPING_TYPE_STANDARD)
            .setField(MX_Order__c.Status__c, MX_ORDER_STATUS_FAILED)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            )
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.FirstName, CONTACT_FIRST_NAME)
                    .setField(Contact.LastName, CONTACT_LAST_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
                    .setField(Contact.Phone, CONTACT_PHONE)
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(Mx_Order_Product_Bundle__c.class)
                    .setField(Mx_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_TABLET)
            )
            .setChildren(
                'Merchant_Order_Items__r',
                new List<Fake>{
                    new Fake(MX_Order_Item__c.class)
                        .setField(MX_Order_Item__c.Quantity__c, 1)
                        .setField(MX_Order_Item__c.Password__c, TABLET_PASSWORD)
                        .setField(MX_Order_Item__c.Username__c, TABLET_USERNAME)
                        .setParent(
                            'Product__r',
                            new Fake(Product2.class)
                                .setField(Product2.StockKeepingUnit, PRODUCT_SKU)
                                .setField(Product2.Family, MX_ORDER_TYPE_TABLET)
                                .setField(Product2.Name, MX_ORDER_TYPE_TABLET)
                        )
                }
            )
            .toSObject();

        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.Figment_ID__c, XREF_FIGMENTID)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
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
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(
                new List<Interface_Transaction__c>{
                    new Interface_Transaction__c(
                        Payload__c = TABLET_OUTBOUND_CONFIG_NAME,
                        Record_Id__c = mxOrderId,
                        Remaining_Retry_Attempts__c = METADATA_VALUE,
                        Status__c = INTERFACE_TRANSACTION_STATUS_NEW
                    )
                }
            );
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectMDSXrefsBySalesforceAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectMerchantOrderRelatedDetailsById(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.retryPayloadGeneration(new List<MX_Order__c>{ mockMxOrder });

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Record_Id__c => String.valueOf(mxOrderId)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test Vendor Order Id will be stamped on the Mx Order when the tablet/printer is return with
     * same Identifier
     */
    @isTest
    private static void testWhenMxOrdersItemIsCreatedandReturnedWithSameIndentifierThenStampVendorOrderIdOnMerchantOrder() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id originalOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Tablet_IMEI__c, MX_ORDER_ITEM_IDENTIFIER)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Type_Of_Request__c, REQUEST_TYPE_REPLACEMENT)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, VENDOR_SOCIAL_MOBILE)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Shipping_Address__City__s, SHIPPING_CITY)
            .setField(MX_Order__c.Shipping_Address__PostalCode__s, SHIPPING_POSTAL_CODE)
            .setField(MX_Order__c.Shipping_Address__StateCode__s, SHIPPING_STATE_CODE)
            .setField(MX_Order__c.Shipping_Address__CountryCode__s, SHIPPING_COUNTRY_CODE)
            .setField(MX_Order__c.Tracking_Number__c, MOCK_TRACKING_NUMBER)
            .setField(MX_Order__c.Shipping_Carrier__c, SHIPPING_CARRIER_FEDEX)
            .setField(MX_Order__c.Shipping_Type__c, SHIPPING_TYPE_STANDARD)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            )
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.FirstName, CONTACT_FIRST_NAME)
                    .setField(Contact.LastName, CONTACT_LAST_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
                    .setField(Contact.Phone, CONTACT_PHONE)
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(Mx_Order_Product_Bundle__c.class)
                    .setField(Mx_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_TABLET)
            )
            .setChildren(
                'Merchant_Order_Items__r',
                new List<Fake>{
                    new Fake(MX_Order_Item__c.class)
                        .setField(MX_Order_Item__c.Quantity__c, 1)
                        .setField(MX_Order_Item__c.Password__c, TABLET_PASSWORD)
                        .setField(MX_Order_Item__c.Username__c, TABLET_USERNAME)
                        .setField(MX_Order_Item__c.Identifier__c, MX_ORDER_ITEM_IDENTIFIER)
                        .setParent(
                            'Product__r',
                            new Fake(Product2.class)
                                .setField(Product2.StockKeepingUnit, PRODUCT_SKU)
                                .setField(Product2.Family, MX_ORDER_TYPE_TABLET)
                                .setField(Product2.Name, MX_ORDER_TYPE_TABLET)
                        )
                }
            )
            .toSObject();
        Fake mxOrderItemFake = new Fake(MX_Order_Item__c.class)
            .setField(MX_Order_Item__c.Mx_Order__c, originalOrderId)
            .setField(MX_Order_Item__c.Identifier__c, MX_ORDER_ITEM_IDENTIFIER)
            .setParent(
                'Mx_Order__r',
                new Fake(MX_Order__c.class)
                    .setField(MX_Order__c.Id, originalOrderId)
                    .setField(MX_Order__c.Vendor_Order_Id__c, MX_ORDER_VENDOR_ORDER_ID)
            );
        MX_Order_Item__c originalMxOrderItem = (MX_Order_Item__c) mxOrderItemFake.toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IMerchantOrderItemsSelector mockMerchantOrderItemsSelector = (IMerchantOrderItemsSelector) mocks.mock(
            IMerchantOrderItemsSelector.class
        );
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectMerchantOrderRelatedDetailsById(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });
        mocks.when(mockMerchantOrderItemsSelector.sObjectType())
            .thenReturn(MX_Order_Item__c.SObjectType);
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithMxOrderIds(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(
                new List<MX_Order_Item__c>{
                    new MX_Order_Item__c(
                        Mx_Order__c = mxOrderId,
                        Identifier__c = MX_ORDER_ITEM_IDENTIFIER
                    )
                }
            );
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithIdentifiers(
                    new Set<String>{ MX_ORDER_ITEM_IDENTIFIER }
                )
            )
            .thenReturn(new List<MX_Order_Item__c>{ originalMxOrderItem });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.SELECTOR.setMock(mockMerchantOrderItemsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        MerchantOrdersService.initiateTabletIntegrationOnOrderCreation(
            new List<MX_Order__c>{ mockMxOrder }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();

        List<Interface_Transaction__c> capturedArguments = (List<Interface_Transaction__c>) capturedInsertUOWArguments.getValue();
        String payload = capturedArguments[0].Payload__c;
        MerchantOrdersPayloads merchantOrderPayloadInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.MxOrdersOutboundWrapper payloadParsed = (MerchantOrdersPayloads.MxOrdersOutboundWrapper) JSON.deserialize(
            payload,
            MerchantOrdersPayloads.MxOrdersOutboundWrapper.class
        );
        String vendorId = merchantOrderPayloadInstance.getVendorOrderId(payloadParsed);

        System.assertEquals(MX_ORDER_VENDOR_ORDER_ID, vendorId, VENDOR_ORDER_ID_STATUS);
    }

    /**
     * @description Negative test case to verify that Vendor Order Id is not stamped on the Mx Order
     * when the tablet/printer is returned with the same Identifier.
     */
    @isTest
    private static void testWhenIdentifierPassedThenMxOrderItemWithoutIdentifierNotReturned() {
        // Generate mock IDs for testing.
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        // Create a mock MX_Order__c object without Vendor Order Id
        MX_Order__c mockMxOrder = (MX_Order__c) new Fake(MX_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Shipping_Address__City__s, SHIPPING_CITY)
            .setField(MX_Order__c.Shipping_Address__PostalCode__s, SHIPPING_POSTAL_CODE)
            .setField(MX_Order__c.Shipping_Address__StateCode__s, SHIPPING_STATE_CODE)
            .setField(MX_Order__c.Shipping_Address__CountryCode__s, SHIPPING_COUNTRY_CODE)
            .setField(MX_Order__c.Tracking_Number__c, MOCK_TRACKING_NUMBER)
            .setField(MX_Order__c.Shipping_Carrier__c, SHIPPING_CARRIER_FEDEX)
            .setField(MX_Order__c.Shipping_Type__c, SHIPPING_TYPE_STANDARD)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            )
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.FirstName, CONTACT_FIRST_NAME)
                    .setField(Contact.LastName, CONTACT_LAST_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
                    .setField(Contact.Phone, CONTACT_PHONE)
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(MX_Order_Product_Bundle__c.class)
                    .setField(MX_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_TABLET)
            )
            .setChildren(
                'Merchant_Order_Items__r',
                new List<Fake>{
                    new Fake(MX_Order_Item__c.class)
                        .setField(MX_Order_Item__c.Quantity__c, 1)
                        .setField(MX_Order_Item__c.Password__c, TABLET_PASSWORD)
                        .setField(MX_Order_Item__c.Username__c, TABLET_USERNAME)
                        .setField(MX_Order_Item__c.Identifier__c, MX_ORDER_ITEM_IDENTIFIER)
                        .setParent(
                            'Product__r',
                            new Fake(Product2.class)
                                .setField(Product2.StockKeepingUnit, PRODUCT_SKU)
                                .setField(Product2.Family, MX_ORDER_TYPE_TABLET)
                                .setField(Product2.Name, MX_ORDER_TYPE_TABLET)
                        )
                }
            )
            .toSObject();

        // Mocking ApexMocks for unit testing
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IMerchantOrderItemsSelector mockMerchantOrderItemsSelector = (IMerchantOrderItemsSelector) mocks.mock(
            IMerchantOrderItemsSelector.class
        );
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Start stubbing behavior
        mocks.startStubbing();

        // Stubbing for InterfaceTransactionConfigSelector
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );

        // Stubbing for MerchantOrdersSelector
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectMerchantOrderRelatedDetailsById(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });

        // Stubbing for MerchantOrderItemsSelector
        mocks.when(mockMerchantOrderItemsSelector.sObjectType())
            .thenReturn(MX_Order_Item__c.SObjectType);
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithMxOrderIds(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(
                new List<MX_Order_Item__c>{
                    new MX_Order_Item__c(
                        MX_Order__c = mxOrderId,
                        Identifier__c = MX_ORDER_ITEM_IDENTIFIER
                    )
                }
            );
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithIdentifiers(
                    new Set<String>{ MX_ORDER_ITEM_IDENTIFIER }
                )
            )
            .thenReturn(new List<MX_Order_Item__c>{});

        mocks.stopStubbing();

        // Set the mocks in the Application class
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        // Call the method under test
        Test.startTest();
        MerchantOrdersService.initiateTabletIntegrationOnOrderCreation(
            new List<MX_Order__c>{ mockMxOrder }
        );
        Test.stopTest();

        // Verify that no Vendor Order Id is stamped
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();

        // Perform assertion that Vendor Order Id should not be stamped
        List<Interface_Transaction__c> capturedArguments = (List<Interface_Transaction__c>) capturedInsertUOWArguments.getValue();
        if (!capturedArguments.isEmpty()) {
            String payload = capturedArguments[0].Payload__c;
            MerchantOrdersPayloads merchantOrderPayloadInstance = new MerchantOrdersPayloads();
            MerchantOrdersPayloads.MxOrdersOutboundWrapper payloadParsed = (MerchantOrdersPayloads.MxOrdersOutboundWrapper) JSON.deserialize(
                payload,
                MerchantOrdersPayloads.MxOrdersOutboundWrapper.class
            );
            String vendorId = merchantOrderPayloadInstance.getVendorOrderId(payloadParsed);
            System.assertNotEquals(
                MX_ORDER_VENDOR_ORDER_ID,
                vendorId,
                VENDOR_ORDER_ID_NEGATIVE_CASE
            );
        }
    }

    /**
     * @description To test Mx Order Items are reevaluated and payload is regenarated
     * when Mx Order Vendor is updated.
     */
    @isTest
    private static void testWhenMxOrdersVendorUpdatedThenReevaluateMxOrderItemsAndGeneratePayload() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Shipping_Address__City__s, SHIPPING_CITY)
            .setField(MX_Order__c.Shipping_Address__PostalCode__s, SHIPPING_POSTAL_CODE)
            .setField(MX_Order__c.Shipping_Address__StateCode__s, SHIPPING_STATE_CODE)
            .setField(MX_Order__c.Shipping_Address__CountryCode__s, SHIPPING_COUNTRY_CODE)
            .setField(MX_Order__c.Tracking_Number__c, MOCK_TRACKING_NUMBER)
            .setField(MX_Order__c.Shipping_Carrier__c, SHIPPING_CARRIER_FEDEX)
            .setField(MX_Order__c.Shipping_Type__c, SHIPPING_TYPE_STANDARD)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            )
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.FirstName, CONTACT_FIRST_NAME)
                    .setField(Contact.LastName, CONTACT_LAST_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
                    .setField(Contact.Phone, CONTACT_PHONE)
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(Mx_Order_Product_Bundle__c.class)
                    .setField(Mx_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_TABLET)
            )
            .setChildren(
                'Merchant_Order_Items__r',
                new List<Fake>{
                    new Fake(MX_Order_Item__c.class)
                        .setField(MX_Order_Item__c.Quantity__c, 1)
                        .setField(MX_Order_Item__c.Password__c, TABLET_PASSWORD)
                        .setField(MX_Order_Item__c.Username__c, TABLET_USERNAME)
                        .setField(MX_Order_Item__c.Identifier__c, MX_ORDER_ITEM_IDENTIFIER)
                        .setFakeId()
                        .setParent(
                            'Product__r',
                            new Fake(Product2.class)
                                .setField(Product2.StockKeepingUnit, PRODUCT_SKU)
                                .setField(Product2.Family, MX_ORDER_TYPE_TABLET)
                                .setField(Product2.Name, MX_ORDER_TYPE_TABLET)
                        )
                }
            )
            .toSObject();

        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.Figment_ID__c, XREF_FIGMENTID)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IMerchantOrderItemsSelector mockMerchantOrderItemsSelector = (IMerchantOrderItemsSelector) mocks.mock(
            IMerchantOrderItemsSelector.class
        );
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        ISobjectDeletionService sobjectDeletionServiceMock = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IMerchantOrderItemsService mxOrderItemsServiceMock = (IMerchantOrderItemsService) mocks.mock(
            IMerchantOrderItemsService.class
        );
        IInterfaceTransactionsService interfaceTransactionsServiceMock = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(
                new List<Interface_Transaction__c>{
                    new Interface_Transaction__c(
                        Id = interfaceTransactionId,
                        Payload__c = TABLET_OUTBOUND_CONFIG_NAME,
                        Record_Id__c = mxOrderId,
                        Remaining_Retry_Attempts__c = REMAINING_RETRY_VALUE,
                        Status__c = INTERFACE_TRANSACTION_STATUS_FAILURE
                    )
                }
            );
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.when(
                mockXrefsSelector.selectMDSXrefsBySalesforceAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectMerchantOrderRelatedDetailsById(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });
        mocks.when(mockMerchantOrderItemsSelector.sObjectType())
            .thenReturn(MX_Order_Item__c.SObjectType);
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithMxOrderIds(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(mockMxOrder.Merchant_Order_Items__r);
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithIdentifiers(
                    new Set<String>{ MX_ORDER_ITEM_IDENTIFIER }
                )
            )
            .thenReturn(new List<MX_Order_Item__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.SELECTOR.setMock(mockMerchantOrderItemsSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, sobjectDeletionServiceMock);
        Application.SERVICE.setMock(IMerchantOrderItemsService.class, mxOrderItemsServiceMock);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            interfaceTransactionsServiceMock
        );
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.reevaluateMerchantOrderItemsOnVendorChange(
            new List<MX_Order__c>{ mockMxOrder }
        );
        ((ISobjectDeletionService) mocks.verify(sobjectDeletionServiceMock, 1))
            .fireRecordsDeletion(mockMxOrder.Merchant_Order_Items__r);
        ((IMerchantOrderItemsService) mocks.verify(mxOrderItemsServiceMock, 1))
            .createMxOrderItems(new List<MX_Order__c>{ mockMxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Id => interfaceTransactionId,
                        Interface_Transaction__c.Record_Id__c => String.valueOf(mxOrderId),
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => METADATA_VALUE,
                        Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((IInterfaceTransactionsService) mocks.verify(interfaceTransactionsServiceMock, 1))
            .initiateOutboundIntegrationForinterfaceTransactions(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Id => interfaceTransactionId
                        }
                    }
                )
            );
    }

    /**
     * @description To test Mx Order Items are created and payload is genarated
     * when Mx Order Vendor is updated and Mx Order Items does not exists initially.
     */
    @isTest
    private static void testWhenMxOrdersVendorUpdatedThenCreateMxOrderItemsAndGeneratePayload() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
            .setField(MX_Order__c.Contact__c, contactId)
            .setField(MX_Order__c.Shipping_Address__City__s, SHIPPING_CITY)
            .setField(MX_Order__c.Shipping_Address__PostalCode__s, SHIPPING_POSTAL_CODE)
            .setField(MX_Order__c.Shipping_Address__StateCode__s, SHIPPING_STATE_CODE)
            .setField(MX_Order__c.Shipping_Address__CountryCode__s, SHIPPING_COUNTRY_CODE)
            .setField(MX_Order__c.Tracking_Number__c, MOCK_TRACKING_NUMBER)
            .setField(MX_Order__c.Shipping_Carrier__c, SHIPPING_CARRIER_FEDEX)
            .setField(MX_Order__c.Shipping_Type__c, SHIPPING_TYPE_STANDARD)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            )
            .setParent(
                'Contact__r',
                new Fake(Contact.class)
                    .setField(Contact.FirstName, CONTACT_FIRST_NAME)
                    .setField(Contact.LastName, CONTACT_LAST_NAME)
                    .setField(Contact.Email, CONTACT_EMAIL)
                    .setField(Contact.Phone, CONTACT_PHONE)
            )
            .setParent(
                'Product_Bundle__r',
                new Fake(Mx_Order_Product_Bundle__c.class)
                    .setField(Mx_Order_Product_Bundle__c.Name, MX_ORDER_TYPE_TABLET)
            )
            .toSObject();

        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.Figment_ID__c, XREF_FIGMENTID)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IMerchantOrderItemsSelector mockMerchantOrderItemsSelector = (IMerchantOrderItemsSelector) mocks.mock(
            IMerchantOrderItemsSelector.class
        );
        IInterfaceTransactionConfigSelector mockInterfaceTransactionConfigSelector = (IInterfaceTransactionConfigSelector) mocks.mock(
            IInterfaceTransactionConfigSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        ISobjectDeletionService sobjectDeletionServiceMock = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IMerchantOrderItemsService mxOrderItemsServiceMock = (IMerchantOrderItemsService) mocks.mock(
            IMerchantOrderItemsService.class
        );
        IInterfaceTransactionsService interfaceTransactionsServiceMock = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(
                new List<Interface_Transaction__c>{
                    new Interface_Transaction__c(
                        Id = interfaceTransactionId,
                        Payload__c = TABLET_OUTBOUND_CONFIG_NAME,
                        Record_Id__c = mxOrderId,
                        Remaining_Retry_Attempts__c = REMAINING_RETRY_VALUE,
                        Status__c = INTERFACE_TRANSACTION_STATUS_FAILURE
                    )
                }
            );
        mocks.when(mockInterfaceTransactionConfigSelector.sObjectType())
            .thenReturn(Interface_Transaction_Configuration__mdt.SObjectType);
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(TABLET_OUTBOUND_CONFIG_NAME)
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = TABLET_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockInterfaceTransactionConfigSelector.getInstanceValue(
                    PHOTOSHOOT_OUTBOUND_CONFIG_NAME
                )
            )
            .thenReturn(
                new Interface_Transaction_Configuration__mdt(
                    Label = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                    Retry_Limit__c = METADATA_VALUE
                )
            );
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.when(
                mockXrefsSelector.selectMDSXrefsBySalesforceAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ mockXref });
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectMerchantOrderRelatedDetailsById(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order__c>{ mockMxOrder });
        mocks.when(mockMerchantOrderItemsSelector.sObjectType())
            .thenReturn(MX_Order_Item__c.SObjectType);
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithMxOrderIds(
                    new Set<Id>{ mxOrderId }
                )
            )
            .thenReturn(new List<MX_Order_Item__c>());
        mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithIdentifiers(new Set<String>())
            )
            .thenReturn(new List<MX_Order_Item__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInterfaceTransactionConfigSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.SELECTOR.setMock(mockMerchantOrderItemsSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, sobjectDeletionServiceMock);
        Application.SERVICE.setMock(IMerchantOrderItemsService.class, mxOrderItemsServiceMock);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            interfaceTransactionsServiceMock
        );
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantOrdersService.reevaluateMerchantOrderItemsOnVendorChange(
            new List<MX_Order__c>{ mockMxOrder }
        );
        ((ISobjectDeletionService) mocks.verify(sobjectDeletionServiceMock, 1))
            .fireRecordsDeletion(new List<MX_Order_Item__c>());
        ((IMerchantOrderItemsService) mocks.verify(mxOrderItemsServiceMock, 1))
            .createMxOrderItems(new List<MX_Order__c>{ mockMxOrder });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Id => interfaceTransactionId,
                        Interface_Transaction__c.Record_Id__c => String.valueOf(mxOrderId),
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => METADATA_VALUE,
                        Interface_Transaction__c.Status__c => INTERFACE_TRANSACTION_STATUS_NEW
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((IInterfaceTransactionsService) mocks.verify(interfaceTransactionsServiceMock, 1))
            .initiateOutboundIntegrationForinterfaceTransactions(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Id => interfaceTransactionId
                        }
                    }
                )
            );
    }
}