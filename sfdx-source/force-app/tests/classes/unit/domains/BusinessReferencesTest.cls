/**
 * @author Deloitte
 * @date 05/06/2022
 * @description This is test class for Contacts class
 */
@isTest(seeAllData=false)
private class BusinessReferencesTest {
    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_FAILURE = 'Failure';
    public static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    public static final String STATUS_COO_SUCCESS = 'COO Success';
    public static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String ACCOUNT_NAME = 'Mc Donalds';
    private static final String ASSERT_MESSAGE_ERROR_ON_MASTERED_IN_FIGMENT_FIELD = 'Unexpected result: mismatch in Mastered in Figment field value';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical 1';
    private static final String CURRENCY_USD = 'USD';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String LICENSOR = 'Licensor';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final string PRIMARY_VERTICAL_RX = 'Rx';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final string SEGMENT_SMB = 'SMB';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final string TRIGGER_CONTEXT_BEFORE = 'Before';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String ASSERT_MESSAGE_ERROR = 'Unexpected Result: There were errors.';

    /**
     * @description Tests the domain constructor
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>();
        //Default Constructor Call
        BusinessReferences businessReferencesObject = new BusinessReferences(businessReferenceList);
        //IContacts Instance Creation Call
        BusinessReferences.newInstance(businessReferenceList);
        System.assertNotEquals(
            BusinessReferences.newInstance(businessReferenceList),
            businessReferencesObject,
            ' Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description Tests the validate uniqueness
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUniqueIdentifierIsCreatedThenSetErrors() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Business_Vertical__c = businessVertical.Id,
                Brand__c = brand.Id,
                Business_Name__c = 'Test',
                Default_Type__c = 'Corporate'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector selectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                selectorMock.selectByBusinessReferenceUniqueIdentifierFields(businessReferenceList)
            )
            .thenReturn(businessReferenceList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        BusinessReferences.newInstance(businessReferenceList).validateUniqueness();

        ((IBusinessReferencesSelector) mocks.verify(selectorMock, 1))
            .selectByBusinessReferenceUniqueIdentifierFields(businessReferenceList);

        System.assert(
            businessReferenceList[0].getErrors().size() > 0,
            'Unexpected Result: No errors were set.'
        );
    }

    /**
     * @description Tests the validate uniqueness
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUniqueIdentifierHasNullsThenNoErrors() {
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = null,
                Business_Name__c = 'Test',
                Default_Type__c = 'Corporate'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector selectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                selectorMock.selectByBusinessReferenceUniqueIdentifierFields(businessReferenceList)
            )
            .thenReturn(businessReferenceList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        BusinessReferences.newInstance(businessReferenceList).validateUniqueness();

        ((IBusinessReferencesSelector) mocks.verify(selectorMock, 0))
            .selectByBusinessReferenceUniqueIdentifierFields(businessReferenceList);

        System.assert(
            businessReferenceList[0].getErrors().size() == 0,
            'Unexpected Result: There were errors.'
        );
    }

    /**
     * @description Tests the validate uniqueness
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUniqueIdentifierHasEmptyStringThenNoErrors() {
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = '',
                Business_Name__c = 'Test',
                Default_Type__c = 'Corporate'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector selectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                selectorMock.selectByBusinessReferenceUniqueIdentifierFields(businessReferenceList)
            )
            .thenReturn(businessReferenceList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        BusinessReferences.newInstance(businessReferenceList).validateUniqueness();

        ((IBusinessReferencesSelector) mocks.verify(selectorMock, 0))
            .selectByBusinessReferenceUniqueIdentifierFields(businessReferenceList);

        System.assert(
            businessReferenceList[0].getErrors().size() == 0,
            'Unexpected Result: There were errors.'
        );
    }

    /*
     * @description to test the Integration message convertion to business friendly message format
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningMessageOnBusRefUpdatedThenIntgerationMessageFormatted() {
        List<Business_Reference__c> busRefList = new List<Business_Reference__c>();
        Id busRefId = Fake.generateId(Business_Reference__c.class);
        string newProvisioningMessage = 'Test Integration Message';
        Business_Reference__c busRef = new Business_Reference__c(
            Id = busRefId,
            Provisioning_Error_Message__c = newProvisioningMessage
        );
        busRefList.add(busRef);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGetBusinessFriendlyMessageService serviceMock = (IGetBusinessFriendlyMessageService) mocks.mock(
            IGetBusinessFriendlyMessageService.class
        );
        Application.SERVICE.setMock(IGetBusinessFriendlyMessageService.class, serviceMock);

        Test.startTest();
        IBusinessReferences busRefInstance = BusinessReferences.newInstance(busRefList);
        busRefInstance.updateIntegrationMessage();
        Test.stopTest();

        ((IGetBusinessFriendlyMessageService) mocks.verify(serviceMock, 1))
            .getMessageDetails(newProvisioningMessage, BusinessReferences.INTEGRATION_TYPE);
    }

    /*
     * @description to test the Integration message convertion to business friendly message format
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningMessageOnBusRefUpdatedThenIntgerationMessageFormatted1() {
        List<Business_Reference__c> busRefList = new List<Business_Reference__c>();
        Id busRefId = Fake.generateId(Business_Reference__c.class);
        string newProvisioningMessage = 'Test Integration Message';
        Business_Reference__c busRef = new Business_Reference__c(
            Id = busRefId,
            Provisioning_Error_Message__c = newProvisioningMessage
        );
        busRefList.add(busRef);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGetBusinessFriendlyMessageService serviceMock = (IGetBusinessFriendlyMessageService) mocks.mock(
            IGetBusinessFriendlyMessageService.class
        );
        Application.SERVICE.setMock(IGetBusinessFriendlyMessageService.class, serviceMock);

        Test.startTest();
        IBusinessReferences busRefInstance = BusinessReferences.newInstance(busRefList);
        busRefInstance.updateProcessRequestFlowifAllExternalIdsCreated();
        Test.stopTest();

        ((IGetBusinessFriendlyMessageService) mocks.verify(serviceMock, 0))
            .getMessageDetails(newProvisioningMessage, BusinessReferences.INTEGRATION_TYPE);
    }

    /**
     * @description Creates a JSON string For caseWithListOfBrandAndBizRefs
     * @return String
     */
    private static String serializeBrandandBizRefFullData() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = Fake.generateId(Business_Reference__c.class),
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                //                External_Id__c = '12345',
                Business_Vertical__c = businessVertical.Id,
                Brand__c = brand.Id,
                Business_Name__c = 'Test',
                Default_Type__c = 'Corporate'
            )
        };

        List<BrandWrapper.BrandAndBizRefs> brandAndBusinessRefs = new List<BrandWrapper.BrandAndBizRefs>{
            new BrandWrapper.BrandAndBizRefs(brand, businessReferenceList)
        };

        Case fakeCase = (Case) new Fake(Case.class).setFakeId().toSObject();

        BrandWrapper.CaseWithListOfBrandAndBizRefs caseWithListOfBrandAndBizRefs = new BrandWrapper.CaseWithListOfBrandAndBizRefs();
        caseWithListOfBrandAndBizRefs.brandAndBizRefsList = brandAndBusinessRefs;
        caseWithListOfBrandAndBizRefs.caseRecord = fakeCase;

        return JSON.serialize(CaseWithListOfBrandAndBizRefs);
    }

    /**
     * @description Creates a JSON string For caseWithListOfBrandAndBizRefs
     * @return String
     **/
    private static String serializeBrandandBizRefWithNoBizRefs() {
        BrandWrapper.CaseWithListOfBrandAndBizRefs caseWithListOfBrandAndBizRefs = null;

        return JSON.serialize(CaseWithListOfBrandAndBizRefs);
    }

    @IsTest
    static void testWhenGetAllBzRefsFronSerializedDataWhenFullDataThenReturnBzRefsIdSet() {
        Set<Id> bzRefsSet = BusinessReferences.getAllBzRefsFromSerializedData(
            serializeBrandandBizRefFullData()
        );
        System.assert(bzRefsSet.size() != 0, 'BzRefs Should not be empty Set');
    }

    @IsTest
    static void testWhenGetAllBzRefsFronSerializedDataWhenNullThenReturnEmptySet() {
        Set<Id> bzRefsSet = BusinessReferences.getAllBzRefsFromSerializedData(
            serializeBrandandBizRefWithNoBizRefs()
        );
        System.assert(bzRefsSet.size() == 0, 'BzRefs Should be empty Set');
    }

    @isTest
    private static void testWhenUpdateFlowRequestStatusCalledThenReturnUpdatedFlowRequestForContract() {
        Id parentAccountId = Fake.generateId(Account.class);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Account parentAccount = new Account(Id = parentAccountId, name = 'Mcdonald USA');

        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentAccount.ID)
                .toSObject()
        };

        List<Process_Flow_Request__c> processRequest = new List<Process_Flow_Request__c>{
            (Process_Flow_Request__c) new Fake(Process_Flow_Request__c.class)
                .setField(Process_Flow_Request__c.Contract__c, contracts[0].Id)
                .setField(Process_Flow_Request__c.Stage__c, 'Flow Completed')
                .setField(
                    Process_Flow_Request__c.Serialized_Object_Data__c,
                    serializeBrandandBizRefFullData()
                )
                .setFakeId()
                .toSObject()
        };

        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceId1,
                Integration_Status__c = BusinessReferenceHandler.STATUS_SUCCESS,
                External_ID_Source__c = BusinessReferenceHandler.EXTERNAL_ID_SOURCE_DRIVE_DB
            )
        };

        Map<Id, Business_Reference__c> businessReferenceIdToStatusMapSuccess = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMapSuccess.put(businessReferenceId1, businessReferenceList[0]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProcessFlowRequestsSelector mockProcessFlowRequestSelector = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferencesSelector = (IBusinessReferencesSelector) mocks.mock(
            BusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProcessFlowRequestSelector.sObjectType())
            .thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(mockBusinessReferencesSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);

        mocks.when(
                mockBusinessReferencesSelector.selectBySourceIds(new List<Id>{ contracts[0].Id })
            )
            .thenReturn(businessReferenceList);
        mocks.when(
                mockProcessFlowRequestSelector.selectBrandAndBusinessFlowByIds(
                    new Set<Id>{ processRequest[0].Id }
                )
            )
            .thenReturn(processRequest);
        mocks.when(
                mockProcessFlowRequestSelector.selectBrandAndBusinessFlowByContractOrOpportunityIds(
                    new List<Id>{ contracts[0].Id }
                )
            )
            .thenReturn(processRequest);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockProcessFlowRequestSelector);
        Application.SELECTOR.setMock(mockBusinessReferencesSelector);

        Map<Id, Id> bzRefToSourceIds = new Map<Id, Id>();
        bzRefToSourceIds.put(businessReferenceId1, contracts[0].Id);
        BusinessReferences brf = new BusinessReferences(businessReferenceList);

        brf.getProcessFlowRequestsIdsForFlowCompleted(bzRefToSourceIds);

        List<Id> sourceIds = new List<Id>();
        sourceIds.add(contracts[0].Id);

        brf.updateProcessRequestFlowifAllExternalIdsCreated();

        System.assertEquals(
            STATUS_SUCCESS,
            businessReferenceList[0].Integration_Status__c,
            'The Integration_Status__c field should be updated'
        );
    }

    @isTest
    private static void testWhenUpdateProcessFlowRequestsWhenSourceIdSameAndExternalIdBlankThenDoNotUpdateStage() {
        Id parentAccountId = Fake.generateId(Account.class);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Account parentAccount = new Account(Id = parentAccountId, name = 'Mcdonald USA');

        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentAccount.ID)
                .toSObject()
        };

        List<Process_Flow_Request__c> processRequest = new List<Process_Flow_Request__c>{
            (Process_Flow_Request__c) new Fake(Process_Flow_Request__c.class)
                .setField(Process_Flow_Request__c.Contract__c, contracts[0].Id)
                .setField(
                    Process_Flow_Request__c.Serialized_Object_Data__c,
                    serializeBrandandBizRefFullData()
                )
                .setFakeId()
                .toSObject()
        };

        List<Id> businessReferenceIds = new List<Id>(
            BusinessReferences.getAllBzRefsFromSerializedData(
                processRequest[0].Serialized_Object_Data__c
            )
        );

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = businessReferenceIds[0],
                Integration_Status__c = BusinessReferenceHandler.STATUS_SUCCESS,
                External_ID_Source__c = BusinessReferenceHandler.EXTERNAL_ID_SOURCE_DRIVE_DB
            )
        };

        Map<Id, Business_Reference__c> businessReferenceIdToStatusMapSuccess = new Map<Id, Business_Reference__c>();
        businessReferenceIdToStatusMapSuccess.put(
            businessReferenceIds[0],
            businessReferenceList[0]
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProcessFlowRequestsSelector mockProcessFlowRequestSelector = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferencesSelector = (IBusinessReferencesSelector) mocks.mock(
            BusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProcessFlowRequestSelector.sObjectType())
            .thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(mockBusinessReferencesSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);

        mocks.when(
                mockBusinessReferencesSelector.selectBySourceIds(new List<Id>{ contracts[0].Id })
            )
            .thenReturn(businessReferenceList);
        mocks.when(
                mockProcessFlowRequestSelector.selectBrandAndBusinessFlowByIds(
                    new Set<Id>{ processRequest[0].Id }
                )
            )
            .thenReturn(processRequest);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockProcessFlowRequestSelector);
        Application.SELECTOR.setMock(mockBusinessReferencesSelector);

        List<Id> processFlowRequestsIds = new List<Id>();
        for (Process_Flow_Request__c pfr : processRequest) {
            processFlowRequestsIds.add(pfr.Id);
        }
        List<Id> sourceIds = new List<Id>();
        sourceIds.add(contracts[0].Id);

        BusinessReferences.updateProcessFlowRequestsIfExternalIdsCreated(
            processFlowRequestsIds,
            sourceIds
        );

        System.assertEquals(
            STATUS_SUCCESS,
            businessReferenceList[0].Integration_Status__c,
            'The Integration_Status__c field should be updated'
        );
    }

    /**
     * @description Tests the updateIntegrationMessageLinkingBizIdandBGID
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateIntegrationMessageLinkingBizIdandBGIDThenUpdateFields() {
        List<Business_Reference__c> busRefList = new List<Business_Reference__c>();
        String externalIdValue = '123456';
        String message = 'Test Message';
        String status = 'Test Status';
        Id busRefId = Fake.generateId(Business_Reference__c.class);
        Business_Reference__c busRef = new Business_Reference__c(
            Id = busRefId,
            External_ID__c = externalIdValue
        );
        busRefList.add(busRef);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector selectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
            selectorMock.selectByBizId(externalIdValue)
        ).thenReturn(busRefList);
        mocks.stopStubbing();

		Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        Test.startTest();
        IBusinessReferences busRefInstance = BusinessReferences.newInstance(busRefList);
        busRefInstance.updateIntegrationMessageLinkingBizIdandBGID(externalIdValue, message, status);
        Test.stopTest();

        ((IBusinessReferencesSelector) mocks.verify(selectorMock, 1))
            .selectByBizId(externalIdValue);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();


    }

    /**
     * @description To test update of Mastered in Figment to 'true' when Business Reference has
     * Brand with brand owner's Segment is 'SMB' and Primary Vertical is not 'Rx'.
     */
    @isTest
    private static void testWhenBusinessReferenceCreatedWithBrandMatchingCriteriaThenMarkMasteredInFigmentTrue() {
        Id parentAccountId = Fake.generateId(Account.class);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .toSObject();
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, ACCOUNT_NAME)
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setParent(
                'Brand_Owner__r',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.Segment__c, SEGMENT_SMB)
                    .setField(Account.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            )
            .toSObject();
        Business_Reference__c newBusinessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, brand.Id)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_USD)
            .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Business_Name__c, ACCOUNT_NAME)
            .setField(Business_Reference__c.Brand_Owner_Segment__c, SEGMENT_SMB)
            .setField(Business_Reference__c.Brand_Owner_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                    .setField(Brand__c.Id, brand.Id)
                    .setField(Brand__c.Name, ACCOUNT_NAME)
                    .setField(Brand__c.Brand_Owner__c, newAccount.Id)
                    .setParent(
                        'Brand_Owner__r',
                        new Fake(Account.class)
                            .setField(Account.Id, parentAccountId)
                            .setField(Account.Name, ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                            .setField(Account.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
                    )
            )
            .toSObject();
        Test.startTest();
        BusinessReferences.newInstance(new List<Business_Reference__c>{ newBusinessReference })
            .updateMasteredInFigment(TRIGGER_CONTEXT_BEFORE);
        Test.stopTest();
        System.assertEquals(
            true,
            newBusinessReference.Mastered_In_Figment__c,
            ASSERT_MESSAGE_ERROR_ON_MASTERED_IN_FIGMENT_FIELD
        );
    }

    /**
     * @description To test update of Mastered in Figment to 'false' when Business Reference has
     * Brand with brand owner's Segment is 'SMB' and Primary Vertical is 'Rx'.
     */
    @isTest
    private static void testWhenBusinessReferenceWithBrandNotMatchingCriteriaThenMarkMasteredInFigmentFalse() {
        Id parentAccountId = Fake.generateId(Account.class);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Primary_Vertical__c, PRIMARY_VERTICAL_RX)
            .toSObject();
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, ACCOUNT_NAME)
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setParent(
                'Brand_Owner__r',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.Segment__c, SEGMENT_SMB)
                    .setField(Account.Primary_Vertical__c, PRIMARY_VERTICAL_RX)
            )
            .toSObject();
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, brand.Id)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_USD)
            .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Business_Name__c, ACCOUNT_NAME)
            .setField(Business_Reference__c.Brand_Owner_Segment__c, SEGMENT_SMB)
            .setField(Business_Reference__c.Brand_Owner_Vertical__c, PRIMARY_VERTICAL_RX)
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                    .setField(Brand__c.Id, brand.Id)
                    .setField(Brand__c.Name, ACCOUNT_NAME)
                    .setField(Brand__c.Brand_Owner__c, newAccount.Id)
                    .setParent(
                        'Brand_Owner__r',
                        new Fake(Account.class)
                            .setField(Account.Id, parentAccountId)
                            .setField(Account.Name, ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                            .setField(Account.Primary_Vertical__c, PRIMARY_VERTICAL_RX)
                    )
            )
            .toSObject();
        Test.startTest();
        BusinessReferences.newInstance(new List<Business_Reference__c>{ businessReference })
            .updateMasteredInFigment(TRIGGER_CONTEXT_BEFORE);
        Test.stopTest();
        System.assertEquals(
            false,
            businessReference.Mastered_In_Figment__c,
            ASSERT_MESSAGE_ERROR_ON_MASTERED_IN_FIGMENT_FIELD
        );
    }

    /**
     * @description It is used the stamping of Brand on Business References.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessReferencesPassedThenBrandStamped() {
        Id brandId = Fake.generateId(Brand__c.class);
        Id businessRefId = Fake.generateId(Business_Reference__c.class);
        Map<Id, Id> businessRefToBrandId = new Map<Id, Id>();
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, brandId)
            .toSObject();
        businessRefToBrandId.put(businessRefId, brandId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferences businessReferencesInstance = BusinessReferences.newInstance(
            new List<Business_Reference__c>{}
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        businessReferencesInstance.setBrandOnBusinessReference(businessRefToBrandId);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(brandId, businessReference.Brand__c, ASSERT_MESSAGE_ERROR);
    }
}