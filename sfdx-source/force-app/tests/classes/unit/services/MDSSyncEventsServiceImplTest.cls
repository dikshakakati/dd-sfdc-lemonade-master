/**
 * @description Test class for MDSSyncEventsServiceImpl.
 * Suppressed Warnings since mock verify method does not require System Assert statements. Blank Commit
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class MDSSyncEventsServiceImplTest {

    private static final String PROCESSED_STATUS = 'Processed';
    private static final String BATCH_ID_TEST = 'test-batch-id';
    private static final String IS_ACTIVE_ATTRIBUTE = 'is_active';
    private static final String ADDRESS_ID_ATTRIBUTE = 'address_id';
    private static final String NAME_ATTRIBUTE = 'name';
    private static final String PHONE_NUMBER_ATTRIBUTE = 'phone_number';
    private static final String XREF_ACTIVATION_STATUS_ACTIVE  = 'Active';
    private static final string STATIC_RESOURCE_NAME = 'MDS_Store_Sync_Mock';
        private static final String NO_XREF_FOUND = 'No Xref found for this store in DDMx';

    private static final String LOG_SERVICE_MDS_STORE_SYNC = 'MDS Store Sync';
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';

    @isTest
    public static void testWhenIntegrationRequestCreatedThenNoXrefFound(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(jsonString);

        String storeIdInThisPayload = storeUpdate.Updated_store.id.value;
        String businessIdInThisPayload = storeUpdate.Updated_store.business_id.value;

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);

        Integration_Request__c intReq = new Integration_Request__c(
            Id = integrationRequestId,
            payload__c = jsonString,
            Batch_Id__c = BATCH_ID_TEST,
            Store_Update_Event_Received_Date_Time__c = thisEventRecievedDateTime

        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(
            IXrefsSelector.class
        );
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
            xrefSelectorMock.selectByStoreIdAndBusinessId(storeIdInThisPayload, businessIdInThisPayload)
            )
            .thenReturn(new List<Xref__c>{});

        IIntegrationRequestsSelector intRequestSelectorMock = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        mocks.when(intRequestSelectorMock.sObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
            intRequestSelectorMock.selectById(new Set<Id>{integrationRequestId})
            )
            .thenReturn(new List<Integration_Request__c>{intReq});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(intRequestSelectorMock);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IGenericLogger genericLoggerServiceMock = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerServiceMock);

        Test.startTest();
        MDSSyncEventsService.processMDSUpdates(new Set<Id>{integrationRequestId});
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.Id => integrationRequestId,
                Integration_Request__c.Sfdc_Status__c => PROCESSED_STATUS,
                Integration_Request__c.Error_Message__c => NO_XREF_FOUND
            }
        ) );
    }

    @isTest
    public static void testWhenIntegrationRequestCreatedThenProcessStoreSync() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(jsonString);

        String storeIdInThisPayload = storeUpdate.Updated_store.id.value;
        String businessIdInThisPayload = storeUpdate.Updated_store.business_id.value;

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');

        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);

        Integration_Request__c intReq = new Integration_Request__c(
            Id = integrationRequestId,
            payload__c = jsonString,
            Store_Update_Event_Received_Date_Time__c = thisEventRecievedDateTime

        );

        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId)
            .setParent(
                'Salesforce_Account_Name__r',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.Order_Protocol__c, 'Email')
                )
            .toSObject();
        MDS_Sync_Mapping__mdt isActiveMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = IS_ACTIVE_ATTRIBUTE,
            MasterLabel = IS_ACTIVE_ATTRIBUTE,
            DDMx_Field_to_Update__c = 'Xref_Status__c',
            DDMx_Object_Name__c = 'Xref__c',
            DDMx_Update_Type__c = 'Complex',
            Target_Field_Data_Type__c = 'String'
        );
        MDS_Sync_Mapping__mdt phoneNumberMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = PHONE_NUMBER_ATTRIBUTE,
            MasterLabel = PHONE_NUMBER_ATTRIBUTE,
            DDMx_Field_to_Update__c = 'Phone',
            DDMx_Object_Name__c = 'Account',
            DDMx_Update_Type__c = 'Simple',
            Target_Field_Data_Type__c = 'String'
        );
        MDS_Sync_Mapping__mdt addressIdMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = ADDRESS_ID_ATTRIBUTE,
            MasterLabel = ADDRESS_ID_ATTRIBUTE,
            DDMx_Field_to_Update__c = 'Address_ID__c',
            DDMx_Object_Name__c = 'Account',
            DDMx_Update_Type__c = 'Complex',
            Target_Field_Data_Type__c = 'String'
        );
        MDS_Sync_Mapping__mdt driveStoreIdMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = 'drive_store_id',
            MasterLabel = 'drive_store_id',
            DDMx_Field_to_Update__c = 'Drive_Store_Id__c',
            DDMx_Object_Name__c = 'Xref__c',
            DDMx_Update_Type__c = 'Simple',
            Target_Field_Data_Type__c = 'String'
        );

        string subMktId = '6';
        string subMarketName = 'San Francisco';

        Id submarketId = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        Submarket__c newSubMkt = new Submarket__c(Id = submarketId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(
            IXrefsSelector.class
        );
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
            xrefSelectorMock.selectByStoreIdAndBusinessId(storeIdInThisPayload, businessIdInThisPayload)
            )
            .thenReturn(new List<Xref__c>{mockXref});

        IIntegrationRequestsSelector intRequestSelectorMock = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        mocks.when(intRequestSelectorMock.sObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
            intRequestSelectorMock.selectById(new Set<Id>{integrationRequestId})
            )
            .thenReturn(new List<Integration_Request__c>{intReq});

        IMDSSyncMappingsSelector mdsMappingSelectorMock = (IMDSSyncMappingsSelector) mocks.mock(
            IMDSSyncMappingsSelector.class
        );
        mocks.when(mdsMappingSelectorMock.sObjectType()).thenReturn(MDS_Sync_Mapping__mdt.SObjectType);
        mocks.when(
            mdsMappingSelectorMock.getActiveMDSSyncMappings()
            )
            .thenReturn(new List<MDS_Sync_Mapping__mdt>{isActiveMapping, phoneNumberMapping, addressIdMapping, driveStoreIdMapping});
        ISubmarketsSelector subMarketSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.when(subMarketSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(
            subMarketSelector.getSubmarketsByIdAndName(subMktId,subMarketName)
            )
            .thenReturn(new List<Submarket__c>{newSubMkt});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(intRequestSelectorMock);
        Application.SELECTOR.setMock(mdsMappingSelectorMock);
        Application.SELECTOR.setMock(subMarketSelector);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        MDSSyncEventsService.processMDSUpdates(new Set<Id>{integrationRequestId});
        Test.stopTest();
        Map<String, String> xrefLastMdsUpdatedMap = new Map<String, String> {'Xref_Status__c' => String.valueOf(thisEventRecievedDateTime),'Drive_Store_Id__c' => String.valueOf(thisEventRecievedDateTime)};
        Map<String, String> accountLastMdsUpdatedMap = new Map<String, String> {'Phone' => String.valueOf(thisEventRecievedDateTime), 'Address_ID__c' => String.valueOf(thisEventRecievedDateTime)};
        String mdsUpdatedPhoneInJson = '4694546531';
        String addressId = '264237581';
        String newDriveStoreId = 'uvwxyz';
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Xref__c.Id => xrefId,
                Xref__c.Xref_Status__c => XREF_ACTIVATION_STATUS_ACTIVE,
                Xref__c.Date_of_Status_Change__c => thisEventRecievedDateTime,
                Xref__c.Drive_Store_Id__c => newDriveStoreId,
                Xref__c.MDS_Last_Synced__c => String.valueOf(JSON.serialize(xrefLastMdsUpdatedMap))
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Account.Id => accountId,
                Account.MDS_Last_Synced__c => String.valueOf(JSON.serialize(accountLastMdsUpdatedMap)),
                Account.Phone => mdsUpdatedPhoneInJson,
                Account.Address_ID__c => addressId,
                Account.SubMarket__c => submarketId
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.Id => integrationRequestId,
                Integration_Request__c.Sfdc_Status__c => PROCESSED_STATUS
            }
        ) );
    }

    @isTest
    public static void testWhenIntegrationRequestCreatedThenNotProcessStoreSync() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =:STATIC_RESOURCE_NAME LIMIT 1];
        String jsonString = sr.Body.toString();
        StoreUpdateIntegrationWrapper storeUpdate = StoreUpdateIntegrationWrapper.parse(jsonString);

        String storeIdInThisPayload = storeUpdate.Updated_store.id.value;
        String businessIdInThisPayload = storeUpdate.Updated_store.business_id.value;

        Datetime thisEventRecievedDateTime = DateTime.parse('03/24/2024, 11:45 AM');
        Datetime futureDateTimeThanEventTime = DateTime.parse('03/25/2024, 11:45 AM');

        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);

        Integration_Request__c intReq = new Integration_Request__c(
            Id = integrationRequestId,
            payload__c = jsonString,
            Store_Update_Event_Received_Date_Time__c = thisEventRecievedDateTime

        );
        Map<String, String> accountExistingMdsUpdate = new Map<String, String>{'Phone' => String.valueOf(futureDateTimeThanEventTime)};
        Xref__c mockXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId)
            .setParent(
                'Salesforce_Account_Name__r',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.Order_Protocol__c, 'Email')
                        .setField(Account.Name, 'old-test-account')
                        .setField(Account.MDS_Last_Synced__c, String.valueOf(JSON.serialize(accountExistingMdsUpdate)))
                )
            .toSObject();
        MDS_Sync_Mapping__mdt isActiveMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = IS_ACTIVE_ATTRIBUTE,
            MasterLabel = IS_ACTIVE_ATTRIBUTE,
            DDMx_Field_to_Update__c = 'Xref_Status__c',
            DDMx_Object_Name__c = 'Xref__c',
            DDMx_Update_Type__c = 'Complex',
            Target_Field_Data_Type__c = 'String'
        );
        MDS_Sync_Mapping__mdt phoneNumberMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = PHONE_NUMBER_ATTRIBUTE,
            MasterLabel = PHONE_NUMBER_ATTRIBUTE,
            DDMx_Field_to_Update__c = 'Phone',
            DDMx_Object_Name__c = 'Account',
            DDMx_Update_Type__c = 'Simple',
            Target_Field_Data_Type__c = 'String'
        );
        MDS_Sync_Mapping__mdt nameMapping = new MDS_Sync_Mapping__mdt(
            DeveloperName = NAME_ATTRIBUTE,
            MasterLabel = NAME_ATTRIBUTE,
            DDMx_Field_to_Update__c = NAME_ATTRIBUTE,
            DDMx_Object_Name__c = 'Account',
            DDMx_Update_Type__c = 'Simple',
            Target_Field_Data_Type__c = 'String'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(
            IXrefsSelector.class
        );
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
            xrefSelectorMock.selectByStoreIdAndBusinessId(storeIdInThisPayload, businessIdInThisPayload)
            )
            .thenReturn(new List<Xref__c>{mockXref});

        IIntegrationRequestsSelector intRequestSelectorMock = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        mocks.when(intRequestSelectorMock.sObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
            intRequestSelectorMock.selectById(new Set<Id>{integrationRequestId})
            )
            .thenReturn(new List<Integration_Request__c>{intReq});

        IMDSSyncMappingsSelector mdsMappingSelectorMock = (IMDSSyncMappingsSelector) mocks.mock(
            IMDSSyncMappingsSelector.class
        );
        mocks.when(mdsMappingSelectorMock.sObjectType()).thenReturn(MDS_Sync_Mapping__mdt.SObjectType);
        mocks.when(
            mdsMappingSelectorMock.getActiveMDSSyncMappings()
            )
            .thenReturn(new List<MDS_Sync_Mapping__mdt>{isActiveMapping, phoneNumberMapping, nameMapping});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(intRequestSelectorMock);
        Application.SELECTOR.setMock(mdsMappingSelectorMock);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        MDSSyncEventsService.processMDSUpdates(new Set<Id>{integrationRequestId});
        Test.stopTest();
        Map<String, String> xrefLastMdsUpdatedMap = new Map<String, String> {'Xref_Status__c' => String.valueOf(thisEventRecievedDateTime)};
        Map<String, String> accountLastMdsUpdatedMap = new Map<String, String> {'Phone' => String.valueOf(futureDateTimeThanEventTime), NAME_ATTRIBUTE => String.valueOf(thisEventRecievedDateTime)};
        String name = 'new-test-account';
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Xref__c.Id => xrefId,
                Xref__c.Xref_Status__c => XREF_ACTIVATION_STATUS_ACTIVE,
                Xref__c.Date_of_Status_Change__c => thisEventRecievedDateTime,
                Xref__c.MDS_Last_Synced__c => String.valueOf(JSON.serialize(xrefLastMdsUpdatedMap))
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Account.Id => accountId,
                Account.MDS_Last_Synced__c => String.valueOf(JSON.serialize(accountLastMdsUpdatedMap)),
                Account.Name => name
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Integration_Request__c.Id => integrationRequestId,
                Integration_Request__c.Sfdc_Status__c => PROCESSED_STATUS
            }
        ) );
    }
}