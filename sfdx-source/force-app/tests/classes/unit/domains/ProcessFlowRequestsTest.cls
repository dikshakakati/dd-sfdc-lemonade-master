/**
* @author Aethereus
* @description Test class for the ProcessFlowRequests class
**/
@IsTest
private class ProcessFlowRequestsTest {
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
	public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_FAILURE = 'Failure';
    public static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    public static final String STATUS_COO_SUCCESS = 'COO Success';
    public static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical 1';
  	private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String LICENSOR = 'Licensor';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String BRANDANDBUSINESSFLOW_RECORDTYPE = System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name;
    private static final Id BUSINESS_REFERENCE_ID = Fake.generateId(Business_Reference__c.class);


   /**
	* @description Creates a JSON string For caseWithListOfBrandAndBizRefs
	* @param businessReferenceList List of Business_Reference__c
    * @return JSON string
	**/
    private static String serializeBrandandBizRefFullData(List<Business_Reference__c> businessReferenceList) {
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

        List<BrandWrapper.BrandAndBizRefs> brandAndBusinessRefs = new List<BrandWrapper.BrandAndBizRefs>{new BrandWrapper.BrandAndBizRefs(brand,businessReferenceList)};

            Case fakeCase = (Case) new Fake(
                Case.class
            )
            .setFakeId()
            .toSObject();

        BrandWrapper.CaseWithListOfBrandAndBizRefs caseWithListOfBrandAndBizRefs = new BrandWrapper.CaseWithListOfBrandAndBizRefs();
        caseWithListOfBrandAndBizRefs.brandAndBizRefsList = brandAndBusinessRefs;
        caseWithListOfBrandAndBizRefs.caseRecord = fakeCase;

        return JSON.serialize(CaseWithListOfBrandAndBizRefs);
    }

    /**
     * @description Test when sendNotificationForProcessFlowRequestWithExternalIdsCreated when full data then send email
     */

    @isTest
    static void testWhenSendNotificationForProcessFlowRequestWithExternalIdsCreatedWhenFullDataThenSendEmail(){
        Id brefId = Fake.generateId(Business_Reference__c.class);
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = brefId,
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                External_Id__c = '12345',
                Business_Name__c = 'Test',
                Default_Type__c = 'Corporate'
            )
                };

                    Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
            .get(BRANDANDBUSINESSFLOW_RECORDTYPE)
            .getRecordTypeId();
        List<Process_Flow_Request__c> requests = new List<Process_Flow_Request__c>();
        Process_Flow_Request__c request = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Serialized_Object_Data__c = serializeBrandandBizRefFullData(businessReferenceList),
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = brandAndBusinessFlowRecordTypeId

        );
        requests.add(request);


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProcessFlowRequestsSelector mockProcessFlowRequestSelector = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferencesSelector = (IBusinessReferencesSelector) mocks.mock(
            BusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProcessFlowRequestSelector.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(mockBusinessReferencesSelector.sObjectType()).thenReturn(Business_Reference__c.SObjectType);

        mocks.when(mockBusinessReferencesSelector.selectByIds( new Set<Id>{brefId}))
            .thenReturn(businessReferenceList);

        mocks.when(mockProcessFlowRequestSelector.selectBrandAndBusinessFlowByIds(new Set<Id>{flowRequestId}))
            .thenReturn(requests);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockProcessFlowRequestSelector);
        Application.SELECTOR.setMock(mockBusinessReferencesSelector);

        ProcessFlowRequests.newInstance(requests)
            .sendNotifcationsForProcessFlowRequestWithExternalIdsCreated();
            System.assertEquals(REQUEST_STATUS_IN_PROGRESS, requests[0].Status__c, 'The Status__c field should be updated');
    }

    /**
     * @description Test when sendNotificationForProcessFlowRequestWithExternalIdsCreated when full data then Throw error
     */
    @isTest
    static void testWhenSendEmailNotificationWhenNotificationNotProperlyConstructedThenThrowError(){
        Test.startTest();
        Exception actualException;
        try {
            ProcessFlowRequests.sendEmailNotifications(null);
        } catch (Exception e) {
            actualException = e;
        }
        Test.stopTest();
        System.assertEquals(null, actualException, 'An exception should be thrown when sendEmailNotifications is called with null');
    }

    /**
     * @description Test when SendNotificationWhenNotificationNotProperlyConstructed Then Throw Error
     */
     @isTest
    static void testWhenSendNotificationWhenNotificationNotProperlyConstructedThenThrowError(){
        Test.startTest();
        Exception actualException;
        try {
            ProcessFlowRequests.sendNotification(null, new Set<String>());
        } catch (Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assertEquals(null, actualException, 'An exception should be thrown when sendNotification is called with null and an empty set');

    }

    @isTest
    static void testWhenGetOrgWideEmailAdressWhenInCorrectAddressThenSendNull(){
        Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
            .get(BRANDANDBUSINESSFLOW_RECORDTYPE)
            .getRecordTypeId();

        List<Process_Flow_Request__c> processFlowRequestsList = new List<Process_Flow_Request__c>{
            new Process_Flow_Request__c(
                Stage__c = 'Flow Initiated',
                Status__c = REQUEST_STATUS_IN_PROGRESS,
                RecordTypeId = brandAndBusinessFlowRecordTypeId
            )
        };
        insert processFlowRequestsList;
        update processFlowRequestsList;
        Test.startTest();
	    OrgWideEmailAddress owea =  ProcessFlowRequests.getOrgWideEmailAddressforEmailNotification('SomeRandom@address.com');
        System.assertEquals(
            owea,
            null,
            'No Org Wide Email Address Should be returned'
        );
        Test.stopTest();
    }

    @isTest
    static void testWhenGetCreateBrandNotificationWhenInCorrectNameThenSendNull(){
        Test.startTest();
	    CustomNotificationType notificationType =  ProcessFlowRequests.getCreateBrandNotification('SomeRandomName');
        System.assertEquals(
            notificationType,
            null,
            'No Notification Type Should be returned'
        );
        Test.stopTest();
    }


}