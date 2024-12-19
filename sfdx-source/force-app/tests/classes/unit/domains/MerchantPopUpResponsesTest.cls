/**
 * @author Deloitte
 * @date 20/08/2022
 * @description This class is used to test MerchantPopUpResponses
 */
@isTest(seeAllData=false)
private class MerchantPopUpResponsesTest {
    private static final String APPROVED = 'Approved';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;
    private static final String PENDING = 'Pending';
    /**
     * @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Merchant_Pop_Up_Response__c> responseList = new List<Merchant_Pop_Up_Response__c>();
        MerchantPopUpResponses.newInstance(responseList);
        MerchantPopUpResponses responsesObject = new MerchantPopUpResponses(responseList);
        MerchantPopUpResponses.Constructor constructorObject = new MerchantPopUpResponses.Constructor();
        constructorObject.construct(responseList);
        System.assertNotEquals(
            MerchantPopUpResponses.newInstance(responseList),
            responsesObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description This method is used to test if record type Id is getting stamped on Merchant Pop Up Response.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantPopUpResponseGetInsertedThenStampRecordTypeId() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id paymentsRecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Payments')
            .getRecordTypeId();

        Merchant_Pop_Up_Response__c response = new Merchant_Pop_Up_Response__c(
            Id = fflib_IDGenerator.generate(Merchant_Pop_Up_Response__c.SObjectType)
        );

        MerchantPopUpResponses.newInstance(new List<Merchant_Pop_Up_Response__c>{ response })
            .updateRecordTypeIdsOnMerchantResponse();
        System.assertEquals(
            response.Business_Account_Record_Type_Id__c,
            businessRecordTypeId,
            'Business record type id is not matching'
        );
        System.assertEquals(
            response.Store_Account_Record_Type_Id__c,
            storeRecordTypeId,
            'Store record type id is not matching'
        );
        System.assertEquals(
            response.Payment_Account_Record_Type_Id__c,
            paymentsRecordTypeId,
            'Payment record type id is not matching '
        );
    }

    /**
     * @description This method is used to test if the latest coo exception mail list updated in franchise request records.
     */
    @isTest
    private static void testWhenCheckCOOExceptionEmailListUpdatedFieldToTrueThenUpdateLatestEmails() {
        Merchant_Pop_Up_Response__c response = new Merchant_Pop_Up_Response__c(
            Id = fflib_IDGenerator.generate(Merchant_Pop_Up_Response__c.SObjectType),
            Check_COO_Exception_Email_List_Updated__c = true
        );

        MerchantPopUpResponses.newInstance(new List<Merchant_Pop_Up_Response__c>{ response })
            .updateLatestCOOExceptionEmailListOnMerchantResponse();
        System.assertEquals(
            response.Check_COO_Exception_Email_List_Updated__c,
            false,
            'Unexpected Error: This value should be false'
        );
    }

    /**
     * @description It is used to validate that update to "Withholding Opt-out Expiry Date" field
     * on corporate account is initiated based on the passed approved franchise form requests.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenApprovedWithholdingOptOutFranchiseFormsReceivedThenUpdateToStampWithholdingOptOutExpiryDateOnAccountInitiated() {
        Id franchiseFormRequestId = Fake.generateId(Merchant_Pop_Up_Response__c.class);
        Id corporateAccountId = Fake.generateId(Account.class);
        Merchant_Pop_Up_Response__c[] newFranchiseRequests = new List<Merchant_Pop_Up_Response__c>{
            new Merchant_Pop_Up_Response__c(
                Id = franchiseFormRequestId,
                Approval_Status__c = APPROVED,
                Mx_Corporate_Account__c = corporateAccountId,
                Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IMerchantPopUpResponses merchantPopUpResponsesInstance = MerchantPopUpResponses.newInstance(
            newFranchiseRequests
        );
        merchantPopUpResponsesInstance.setWithholdingExpiryDateOnCorporateAccountsByEligibleFranchisFormRequests();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to validate that update to "Withholding Opt-out Expiry Date" field on
     * corporate account is not initiated based on the passed pending franchise form requests.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPendingIntegratedFranchiseFormsReceivedThenUpdateToStampWithholdingOptOutExpiryDateOnAccountNotInitiated() {
        Id franchiseFormRequestId = Fake.generateId(Merchant_Pop_Up_Response__c.class);
        Id corporateAccountId = Fake.generateId(Account.class);
        Merchant_Pop_Up_Response__c[] newFranchiseRequests = new List<Merchant_Pop_Up_Response__c>{
            new Merchant_Pop_Up_Response__c(
                Id = franchiseFormRequestId,
                Approval_Status__c = PENDING,
                Mx_Corporate_Account__c = corporateAccountId,
                Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IMerchantPopUpResponses merchantPopUpResponsesInstance = MerchantPopUpResponses.newInstance(
            newFranchiseRequests
        );
        merchantPopUpResponsesInstance.setWithholdingExpiryDateOnCorporateAccountsByEligibleFranchisFormRequests();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}