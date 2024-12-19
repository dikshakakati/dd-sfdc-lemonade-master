/**
 * @author Deloitte
 * @date 21/08/2022
 * @description Test class for MerchantPopUpResponsesHandler
 */
@isTest(seeAllData=false)
private class MerchantPopUpResponsesHandlerTest {
    private static final String APPROVED = 'Approved';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'The two constructs should not be similar';
    private static final String EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING = 'UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING';
    private static final String PENDING = 'Pending';
    private static final String REJECTED = 'Rejected';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        //Constructor Call
        List<Merchant_Pop_Up_Response__c> responseList = new List<Merchant_Pop_Up_Response__c>();
        MerchantPopUpResponsesHandler responsesHandlerObject = new MerchantPopUpResponsesHandler(
            responseList
        );
        //Inner Class Constructor Call
        MerchantPopUpResponsesHandler.Constructor objConstructor = new MerchantPopUpResponsesHandler.Constructor();
        objConstructor.construct(responseList);
        System.assertNotEquals(
            responsesHandlerObject,
            objConstructor.construct(responseList),
            'The two constructs should not be similar'
        );
    }

    /**
     * @description To test if After Insert operations are called.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenResponsesAreInsertedThenRecordTypeIdStampsOnResponseRecord() {
        Merchant_Pop_Up_Response__c response = new Merchant_Pop_Up_Response__c(
            Id = fflib_IDGenerator.generate(Merchant_Pop_Up_Response__c.SObjectType)
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<Merchant_Pop_Up_Response__c>{ response }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantPopUpResponses responsesMock = (IMerchantPopUpResponses) mocks.mock(
            IMerchantPopUpResponses.class
        );

        mocks.startStubbing();
        mocks.when(responsesMock.getType()).thenReturn(Merchant_Pop_Up_Response__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(responsesMock);

        fflib_SObjectDomain.triggerHandler(MerchantPopUpResponsesHandler.class);
        ((IMerchantPopUpResponses) mocks.verify(responsesMock, 1))
            .updateRecordTypeIdsOnMerchantResponse();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenCheckCOOExceptionEmailListUpdatedFieldChangedThenUpdateLatestCOOExceptionEmailListOnMerchantResponseIsCalled() {
        Id franchiseRequest1 = Fake.generateId(Merchant_Pop_Up_Response__c.class);
        Id franchiseRequest2 = Fake.generateId(Merchant_Pop_Up_Response__c.class);
        Merchant_Pop_Up_Response__c[] oldFranchiseRequests = new List<Merchant_Pop_Up_Response__c>{
            new Merchant_Pop_Up_Response__c(
                Id = franchiseRequest1,
                Check_COO_Exception_Email_List_Updated__c = false
            ),
            new Merchant_Pop_Up_Response__c(
                Id = franchiseRequest2,
                Check_COO_Exception_Email_List_Updated__c = false
            )
        };
        Merchant_Pop_Up_Response__c[] newFranchiseRequests = new List<Merchant_Pop_Up_Response__c>{
            new Merchant_Pop_Up_Response__c(
                Id = franchiseRequest1,
                Check_COO_Exception_Email_List_Updated__c = true
            ),
            new Merchant_Pop_Up_Response__c(
                Id = franchiseRequest2,
                Check_COO_Exception_Email_List_Updated__c = true
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantPopUpResponses merchantPopUpResponseMock = (IMerchantPopUpResponses) mocks.mock(
            IMerchantPopUpResponses.class
        );
        mocks.startStubbing();
        mocks.when(merchantPopUpResponseMock.getType())
            .thenReturn(Schema.Merchant_Pop_Up_Response__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(merchantPopUpResponseMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newFranchiseRequests,
            new Map<Id, SObject>(oldFranchiseRequests)
        );
        fflib_SObjectDomain.triggerHandler(MerchantPopUpResponsesHandler.class);

        ((IMerchantPopUpResponses) mocks.verify(merchantPopUpResponseMock, 1))
            .updateLatestCOOExceptionEmailListOnMerchantResponse();
    }

    /**
     * @description To test MerchantPopUpResponsesTrigger.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantPopUpResponesHandlerIsCalledThenRecordInserted() {
        Merchant_Pop_Up_Response__c merchantPopUpResponse = new Merchant_Pop_Up_Response__c(
            Form_Type__c = 'Drive'
        );
        insert merchantPopUpResponse;
    }

    /**
     * @description To test stampWithholdingExpiryDateOnCorporateAccount is called when Withholding Opt-out
     * Franchise Form Request gets approved.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenWithholdingOptOutFranchiseFormRequestApprovedThenStampWithholdingExpiryDateOnCorporateAccountCalled() {
        Id franchiseFormRequestId = Fake.generateId(Merchant_Pop_Up_Response__c.class);
        Id corporateAccountId = Fake.generateId(Account.class);
        Merchant_Pop_Up_Response__c[] oldFranchiseRequests = new List<Merchant_Pop_Up_Response__c>{
            new Merchant_Pop_Up_Response__c(
                Id = franchiseFormRequestId,
                Approval_Status__c = PENDING,
                Mx_Corporate_Account__c = corporateAccountId,
                Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT
            )
        };
        Merchant_Pop_Up_Response__c[] newFranchiseRequests = new List<Merchant_Pop_Up_Response__c>{
            new Merchant_Pop_Up_Response__c(
                Id = franchiseFormRequestId,
                Approval_Status__c = APPROVED,
                Mx_Corporate_Account__c = corporateAccountId,
                Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsService mockAccountService = (IAccountsService) mocks.mock(IAccountsService.class);
        Application.Service.setMock(IAccountsService.class, mockAccountService);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newFranchiseRequests,
            new Map<Id, SObject>(oldFranchiseRequests)
        );
        fflib_SObjectDomain.triggerHandler(MerchantPopUpResponsesHandler.class);

        ((IAccountsService) mocks.verify(mockAccountService, 1))
            .stampWithholdingExpiryDateOnCorporateAccounts(new Set<Id>{ corporateAccountId });
    }
}