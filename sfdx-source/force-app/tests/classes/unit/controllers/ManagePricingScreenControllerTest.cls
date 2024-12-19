/**
* @author Deloitte
* @date 16/09/2023
* @description This is test class for ManagePricingController class
*/
@isTest(seeAllData=false)
public class ManagePricingScreenControllerTest {
    @isTest
    private static void testWhenManagePricingIsSubmittedForActiveRatesProvisioningThenCallCreateRateChangeRequest() {
        ManagePricingRateChangeReqServiceImpl service = new ManagePricingRateChangeReqServiceImpl();
        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(
            SBQQ__Subscription__c.SObjectType
        );
        Id subscriptionId2 = fflib_IDGenerator.generate(
            SBQQ__Subscription__c.SObjectType
        );
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Date todaysDate = System.today();
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Corporate')
            .setField(Account.Id, accountId)
            .toSObject();

        ManagePricingWrapper.SubscriptionWrapper subWrap1 = new ManagePricingWrapper.SubscriptionWrapper(
            subscriptionId1,
            1,
            6
        );
        ManagePricingWrapper.SubscriptionWrapper subWrap2 = new ManagePricingWrapper.SubscriptionWrapper(
            subscriptionId2,
            2,
            7
        );

        List<ManagePricingWrapper.SubscriptionWrapper> subscriptionWrappers = new List<ManagePricingWrapper.SubscriptionWrapper>();
        subscriptionWrappers.add(subWrap1);
        subscriptionWrappers.add(subWrap2);
        List<Account> storeAccounts = new List<Account>();
        storeAccounts.add(storeAccount);
        String storeAccountStr = String.valueOf(storeAccount.Id);

        ManagePricingWrapper manageWrap = new ManagePricingWrapper(
            subscriptionWrappers,
            caseId,
            todaysDate,
            contractId,
            storeAccountStr
        );
        ManagePricingWrapper[] manageWrapList = new ManagePricingWrapper[]{};
            manageWrapList.add(manageWrap);

        String manageWrapperStr = JSON.serialize(manageWrapList);
        List<ManagePricingWrapper> managePricingWrappers = (List<ManagePricingWrapper>) JSON.deserialize(
            manageWrapperStr,
            List<ManagePricingWrapper>.class
        );
        ManagePricingWrapper pricingWrapper = managePricingWrappers[0];

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IManagePricingRateChangeReqService serviceMock = (IManagePricingRateChangeReqService) mocks.mock(
            IManagePricingRateChangeReqService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(serviceMock.createRateChangeRequest(pricingWrapper))
            .thenReturn(rateChangeReqId);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IManagePricingRateChangeReqService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ManagePricingScreenController.createRateChangeRequest(manageWrapperStr);
        Test.stopTest();

        Id rateChangeId1 = service.createRateChangeRequest(pricingWrapper);

        (( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                Rate_Change_Request__c.Id => rateChangeId1
                    }
        ));
        Rate_Change_Request__c rc = new Rate_Change_Request__c();
        rc = service.rateChangeReq;
        System.assertNotEquals(null, rc, 'Rate Change is created');
    }

    @isTest
    static void testWhenSubmittingSearchInfoToFetchRecordsThenReturnResultWrapper() {
        // Initialize SearchWrapper instance
        Account testAccount = TestDataFactory.createAccount(true);

		Id soCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      	.get('SO_Support_Request')
      	.getRecordTypeId();

        Case soSupportCase = new Case();
    	soSupportCase.AccountId = testAccount.Id;
    	soSupportCase.RecordTypeId = soCaseRecordTypeId;
        soSupportCase.Subject = 'test Case';
    	insert soSupportCase;

        ManagePricingScreenController.SearchWrapper wrapper = new ManagePricingScreenController.SearchWrapper();
        wrapper.objectApiName = 'Case';
        wrapper.fieldApiName = 'Subject';
        wrapper.otherFieldApiName = 'CaseNumber';
        wrapper.searchString = 'test';
        wrapper.selectedRecordId = soSupportCase.Id;
        wrapper.parentFieldApiName = 'AccountId';
        wrapper.parentRecordId = testAccount.Id;

        ManagePricingScreenController.ResultWrapper resultWrapper = new ManagePricingScreenController.ResultWrapper();
        resultWrapper.mainField = 'Subject';
        resultWrapper.subField = 'CaseNumber';
        resultWrapper.Id = soSupportCase.Id;

        List<ManagePricingScreenController.ResultWrapper> results = ManagePricingScreenController.fetchRecords(wrapper);

        System.assertNotEquals(null, results, 'When passing null to the fetch() method, we should receive null.');

        // Validate fields
        for (ManagePricingScreenController.ResultWrapper res : results) {
            System.assertNotEquals(null, res.mainField, 'All fields shoul be null from `results`');
            System.assertNotEquals(null, res.subField, 'All fields shoul be null from `results`');
            System.assertNotEquals(null, res.id, 'All fields shoul be null from `results`');
        }

        // Pass a null SearchWrapper
        List<ManagePricingScreenController.ResultWrapper> shouldBeNullResults = ManagePricingScreenController.fetchRecords(null);

        System.assertEquals(null, shouldBeNullResults, 'When passing null to the fetch() method, we should receive null.');

        // Initialize SearchWrapper with incorrect data
        ManagePricingScreenController.SearchWrapper invalidWrapper = new ManagePricingScreenController.SearchWrapper();
        invalidWrapper.objectApiName = 'InvalidObject';

        // Test exception handling
        try {
            ManagePricingScreenController.fetchRecords(invalidWrapper);
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'An exception should be thrown with an invalid input.');
        }
    }

    @isTest
    private static void testWhenContractIsPassedThenReturnARPEligibleSubscriptionRecords() {
        Id contractId = Fake.generateId(Contract.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1= Fake.generateId(OrderItem.class);
        Id orderItemId2= Fake.generateId(OrderItem.class);
        Id orderItemId3= Fake.generateId(OrderItem.class);
        Id subscriptionId1= Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2= Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3= Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        Fake fakeContractInstance = new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.SBQQ__Order__c, orderId1)
            .setField(Contract.AccountId, contractingAccountId);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 4')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setParent('Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r',fakeContractInstance)
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setParent('Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r',fakeContractInstance)
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setParent('Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r',fakeContractInstance)
            .toSObject();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{subscription1,subscription2,subscription3};
		List<ManagePricingScreenController.GroupSubscriptionsWrapper> viewGroupWrappersList = new List<ManagePricingScreenController.GroupSubscriptionsWrapper>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectSubscriptionRecordsByContract(new Set<Id>{contractId})).thenReturn(subList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
		viewGroupWrappersList = ManagePricingScreenController.selectExistingSubscriptionsWithGroup(
            contractId
        );
		System.assertEquals(
            viewGroupWrappersList.size(),
            1,
            'WrapperList is not equal'
        );

        List<SBQQ__Subscription__c> returnSubscriptions = new List<SBQQ__Subscription__c>();
        for(ManagePricingScreenController.GroupSubscriptionsWrapper wrap : viewGroupWrappersList){
            returnSubscriptions = wrap.subsList;
        }

        System.assertEquals(
            returnSubscriptions.size(),
            subList.size(),
            'Subscription List is not equal'
        );
    }

    /**
     * @description This method is used to test uploadFile
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFileIsUploadedThenCallTheService() {
        Id contractId = Fake.generateId(Contract.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentVersionService contentVersionService = (IContentVersionService) mocks.mock(
            IContentVersionService.class
        );
        Application.SERVICE.setMock(IContentVersionService.class, contentVersionService);

        String blobdata = 'Id,Type,Recordtype';
        String testFileName = 'test.csv';

        ManagePricingScreenController.uploadFile(blobdata, testFileName, contractId);

        ((IContentVersionService) mocks.verify(contentVersionService, 1))
            .createContentVersion(blobdata, testFileName, contractId);
    }
}