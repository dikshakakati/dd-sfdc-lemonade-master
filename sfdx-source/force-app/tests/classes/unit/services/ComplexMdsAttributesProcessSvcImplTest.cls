/**
 * @author Doordash
 * @date 03/12/2024
 * @description Test class for ComplexMdsAttributesProcessServiceImpl
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ComplexMdsAttributesProcessSvcImplTest {
    private static final String IS_ACTIVE_ATTRIBUTE = 'is_active';
    private static final String ADDRESS_ID_ATTRIBUTE = 'address_id';
    private static final String BUSINESS_ID_ATTRIBUTE = 'business_id';
    private static final String ORDER_PROTOCOL_ATTRIBUTE = 'order_protocol';
    private static final String NAME_ATTRIBUTE = 'name';
    private static final string STATIC_RESOURCE_NAME = 'MDS_Store_Sync_Mock';
    private static final string STATIC_RESOURCE_NAME_NOT_IN_COVERAGE = 'MDS_Store_Sync_Mock_Not_In_Coverage';
    private static final string STATIC_RESOURCE_NAME_UPDATE = 'MDS_Store_Sync_Name_Update';
    private static final string STATIC_RESOURCE_NAME_UPDATE_REJECTED = 'MDS_Store_Sync_Name_Update_Rejected';
    private static final string STATIC_RESOURCE_NAME_REJECTED = 'MDS_Store_Sync_Mock_Rejected';
    private static final string STATIC_RESOURCE_NAME_OP_IPAD_TO_POS = 'MDS_Store_Sync_OP_Ipad_To_Pos';
    private static final string STATIC_RESOURCE_NAME_OP_EMAIL_TO_POS = 'MDS_Store_Sync_OP_Email_To_Pos';
    private static final String XREF_ACTIVATION_STATUS_ACTIVE  = 'Active';
    private static final String OP_PHONE = 'Phone';
    private static final String MDS_POS_OP = 'POINT_OF_SALE';
    private static final String DDMX_POS_OP = 'POS';
    private static final String DDMX_POS_TABLET = 'POS and Tablet (Merchant Owns)';
    private static final String UNVERIFIED_STATUS = 'Unverified';
    private static final String TEST_POS_TYPE = 'test-provider-type';
    private static final String TEST_LOCATION_ID = 'test-location';

    private static final Map<String, String> ATTRIBUTE_REPLACEMENT_MAP = new Map<String, String>{
        'Sub_Market__c' => 'Sub_Market_Name',
        'Sub_Market_ID__c' => 'Sub_Market_ID'
    };

    private static string replaceJsonPayload(string payload){
        for(String attrKey: ATTRIBUTE_REPLACEMENT_MAP.keyset()) {
            payload = payload.replaceAll(attrKey, ATTRIBUTE_REPLACEMENT_MAP.get(attrKey));
        }
        return payload;
    }

    @isTest
    public static void testWhenAddressIdChangedThenAccountAddressUpdatedWithAddressAsRejected() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME_REJECTED LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ADDRESS_ID_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);

        Account addressAccount = (Account) storeUpdate.AddressValidationResponse.addressResponse;
        string addressRejected = 'Rejected';

        Assert.areEqual(addressAccount.Address_Verification_Date__c, complexServiceReturn.accountRecord.Address_Verification_Date__c, 'Address Verification was not updated on Account as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
        Assert.areEqual(addressRejected, complexServiceReturn.accountRecord.Address_Verification_Status__c, 'Address should not rejected');
    }

    @isTest
    public static void testWhenAddressIdChangedThenAccountAddressUpdatedWithAddressAsNotInCoverage() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME_NOT_IN_COVERAGE LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ADDRESS_ID_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);

        Account addressAccount = (Account) storeUpdate.AddressValidationResponse.addressResponse;
        string addressNotInCoverage = 'Not In Coverage';

        Assert.areEqual(addressAccount.Address_ID__c, complexServiceReturn.accountRecord.Address_ID__c, 'Address Id was not updated on Account as expected');
        Assert.areEqual(addressAccount.Address_Verification_Date__c, complexServiceReturn.accountRecord.Address_Verification_Date__c, 'Address Verification was not updated on Account as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
        Assert.areEqual(addressNotInCoverage, complexServiceReturn.accountRecord.Coverage__c, 'Address should not be in coverage');
    }

    @isTest
    public static void testWhenAddressIdChangedThenAccountAddressUpdatedWithExistingSubmarket() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ADDRESS_ID_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId);

        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        Submarket__c newSubMkt = new Submarket__c(Id = submarketId);
        string subMktId = '6';
        string subMarketName = 'San Francisco';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubmarketsSelector subMarketSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.startStubbing();
        mocks.when(subMarketSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(
            subMarketSelector.getSubmarketsByIdAndName(subMktId,subMarketName)
            )
            .thenReturn(new List<Submarket__c>{newSubMkt});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subMarketSelector);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);

        Account addressAccount = (Account) storeUpdate.AddressValidationResponse.addressResponse;
        string addressInCoverage = 'In Coverage';
        Assert.areEqual(addressAccount.Address_ID__c, complexServiceReturn.accountRecord.Address_ID__c, 'Address Id was not updated on Account as expected');
        Assert.areEqual(addressAccount.Address_Verification_Date__c, complexServiceReturn.accountRecord.Address_Verification_Date__c, 'Address Verification was not updated on Account as expected');
        Assert.areEqual(addressAccount.Starting_Point_ID__c, complexServiceReturn.accountRecord.Starting_Point_ID__c, 'Address Starting_Point_ID__c was not updated on Account as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
        Assert.areEqual(submarketId, complexServiceReturn.accountRecord.SubMarket__c, 'Sub market Id was not returned as expected');
        Assert.areEqual(addressInCoverage, complexServiceReturn.accountRecord.Coverage__c, 'Address should be in coverage');
    }

    @isTest
    public static void testWhenAddressIdChangedThenAccountAddressUpdatedWithNoSubmarket() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ADDRESS_ID_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        string subMarketId = '6';
        string subMarketName = 'San Francisco';

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);

        Account addressAccount = (Account) storeUpdate.AddressValidationResponse.addressResponse;

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Submarket__c.Name => subMarketName+', '+complexServiceReturn.accountRecord.BillingStateCode,
                Submarket__c.Submarket_ID__c => subMarketId,
                Submarket__c.Status__c => UNVERIFIED_STATUS
            }
        ) );

        Assert.areEqual(addressAccount.Address_ID__c, complexServiceReturn.accountRecord.Address_ID__c, 'Address Id was not updated on Account as expected');
        Assert.areEqual(addressAccount.Address_Verification_Date__c, complexServiceReturn.accountRecord.Address_Verification_Date__c, 'Address Verification was not updated on Account as expected');
        Assert.areEqual(addressAccount.Starting_Point_ID__c, complexServiceReturn.accountRecord.Starting_Point_ID__c, 'Address Starting_Point_ID__c was not updated on Account as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

    @isTest
    public static void testWhenIsActiveChangedThenXrefActivationStatusUpdated() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = IS_ACTIVE_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Xref__c newXref = new Xref__c(Id = xrefId);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.xrefRecord = newXref;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        Assert.areEqual(XREF_ACTIVATION_STATUS_ACTIVE, complexServiceReturn.xrefRecord.Xref_Status__c, 'Xref Status was not updated as expected');
        Assert.areEqual(thisEventRecievedDateTime, complexServiceReturn.xrefRecord.Date_of_Status_Change__c, 'Xref Status change date was not updated as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

    @isTest
    public static void testWhenBusinessIdChangedThenXrefBusinessReferenceUpdated() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = BUSINESS_ID_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Xref__c newXref = new Xref__c(Id = xrefId);

        Id bizRefId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Business_Reference__c newBizRef = new Business_Reference__c(Id = bizRefId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector bizRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(bizRefSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
            bizRefSelectorMock.selectBusRefByExternalIdAndDefaultType(
                    new Set<String>{ storeUpdate.updated_store.business_id.value },
                    new Set<String>{'Corporate', 'COO Graveyard'}
                )
            )
            .thenReturn(new List<Business_Reference__c>{newBizRef});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(bizRefSelectorMock);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.xrefRecord = newXref;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        Assert.areEqual(bizRefId, complexServiceReturn.xrefRecord.Business_Reference__c, 'Xref Biz Ref Id was not updated as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

    @isTest
    public static void testWhenOrderProtocolChangedFromEmailToPhoneThenUpdateAccount() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ORDER_PROTOCOL_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId, Order_Protocol__c = 'Email');

        Order_Protocol_Mapping__mdt op = new Order_Protocol_Mapping__mdt(
            MasterLabel = 'PHONE',
            Active__c = true,
            Contains__c = null,
            Old_Value__c = null,
            Result__c = OP_PHONE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderProtocolMappingsSelector orderProtocolSelectorMock = (IOrderProtocolMappingsSelector) mocks.mock(
            IOrderProtocolMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(orderProtocolSelectorMock.sObjectType()).thenReturn(Order_Protocol_Mapping__mdt.SObjectType);
        mocks.when(
            orderProtocolSelectorMock.getActiveOrderProtocolMappings()
            )
            .thenReturn(new List<Order_Protocol_Mapping__mdt>{op});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(orderProtocolSelectorMock);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        Assert.areEqual(OP_PHONE, complexServiceReturn.accountRecord.Order_Protocol__c, 'Account Order Protocol was not updated as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

    @isTest
    public static void testWhenOrderProtocolChangedFromEmailToPOSThenUpdateAccount() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME_OP_EMAIL_TO_POS LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(jsonString);

        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ORDER_PROTOCOL_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId, Order_Protocol__c = 'Email');

        Order_Protocol_Mapping__mdt op = new Order_Protocol_Mapping__mdt(
            MasterLabel = MDS_POS_OP,
            Active__c = true,
            Contains__c = null,
            Old_Value__c = 'EMAIL',
            Result__c = DDMX_POS_OP
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderProtocolMappingsSelector orderProtocolSelectorMock = (IOrderProtocolMappingsSelector) mocks.mock(
            IOrderProtocolMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(orderProtocolSelectorMock.sObjectType()).thenReturn(Order_Protocol_Mapping__mdt.SObjectType);
        mocks.when(
            orderProtocolSelectorMock.getActiveOrderProtocolMappings()
            )
            .thenReturn(new List<Order_Protocol_Mapping__mdt>{op});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(orderProtocolSelectorMock);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, StoreUpdate);
        Assert.areEqual(DDMX_POS_OP, complexServiceReturn.accountRecord.Order_Protocol__c, 'Account Order Protocol was not updated to POS as expected');
        Assert.areEqual(TEST_POS_TYPE, complexServiceReturn.accountRecord.POS_Integration_Type__c, 'POS Integration Type was not updated as expected');
        Assert.areEqual(TEST_LOCATION_ID, complexServiceReturn.accountRecord.POS_Integration_ID__c, 'POS Integration Id was not updated as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

    @isTest
    public static void testWhenOrderProtocolChangedFromIpadToPOSThenUpdateAccount() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME_OP_IPAD_TO_POS LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));
        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = ORDER_PROTOCOL_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId, Order_Protocol__c = 'Android Tablet (Merchant Owns)');

        Order_Protocol_Mapping__mdt op = new Order_Protocol_Mapping__mdt(
            MasterLabel = MDS_POS_OP,
            Active__c = true,
            Contains__c = 'Merchant Owns',
            Old_Value__c = 'IPAD',
            Result__c = DDMX_POS_TABLET
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderProtocolMappingsSelector orderProtocolSelectorMock = (IOrderProtocolMappingsSelector) mocks.mock(
            IOrderProtocolMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(orderProtocolSelectorMock.sObjectType()).thenReturn(Order_Protocol_Mapping__mdt.SObjectType);
        mocks.when(
            orderProtocolSelectorMock.getActiveOrderProtocolMappings()
            )
            .thenReturn(new List<Order_Protocol_Mapping__mdt>{op});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(orderProtocolSelectorMock);

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        Assert.areEqual(DDMX_POS_TABLET, complexServiceReturn.accountRecord.Order_Protocol__c, 'Account Order Protocol was not updated to POS as expected');
        Assert.areEqual(TEST_POS_TYPE, complexServiceReturn.accountRecord.POS_Integration_Type__c, 'POS Integration Type was not updated as expected');
        Assert.areEqual(TEST_LOCATION_ID, complexServiceReturn.accountRecord.POS_Integration_ID__c, 'POS Integration Id was not updated as expected');
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }


    @isTest
    public static void testWhenAccountNameChangedThenUpdateAccountName() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME_UPDATE LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));
        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = NAME_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId, Name = 'Spaceage Stereo-July-2024 - X88426277210');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();
        mocks.stopStubbing();

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        Assert.areEqual(String.valueOf(thisEventRecievedDateTime), complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

    @isTest
    public static void testWhenAccountNameChangedThenDoNotUpdateAccountName() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME_UPDATE_REJECTED LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(replaceJsonPayload(jsonString));
        MDS_Sync_Mapping__mdt mdsSyncMapping = new MDS_Sync_Mapping__mdt(DeveloperName = NAME_ATTRIBUTE);

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(Id = storeAccountId, Name = 'Spaceage Stereo-July-2024 - X88426277210');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();
        mocks.stopStubbing();

        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = null;
        complexServiceInput.accountRecord = newAccount;

        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        Assert.areEqual(null, complexServiceReturn.thisFieldLastMdsUpdatedDateTime, 'MDS Last modified time stamp is not updated as expected');
    }

}