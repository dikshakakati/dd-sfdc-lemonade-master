/**
 * @author Deloitte
 * @date 09/13/2023
 * @description Test class for FranchiseFormRequestsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class FranchiseFormRequestsServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String APPROVED = 'Approved';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    /**
     * @description It is used to update the field 'Disable Mx Form Submission For This URL' to true
     * on the returned Franchise Form Requests records to expire for Withholding Opt-out.
     */
    @isTest
    private static void testWhenFranchiseFormRequestRecordsToExpireReceivedThenDisableMxFormForThisUrlFieldIsUpdatedToTrue() {
        Id merchantPopUpResponseID = fflib_IDGenerator.generate(
            Merchant_Pop_Up_Response__c.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        parentBusinessAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() - 1;
        Fake merchantPopUpResponseFakeInstance = new Fake(Merchant_Pop_Up_Response__c.class)
            .setField(Merchant_Pop_Up_Response__c.Id, merchantPopUpResponseID)
            .setField(Merchant_Pop_Up_Response__c.Approval_Status__c, APPROVED)
            .setField(Merchant_Pop_Up_Response__c.Mx_Corporate_Account__c, parentBusinessAccount.Id)
            .setField(Merchant_Pop_Up_Response__c.Select_the_Franchise_Type__c, WITHHOLDING_OPT_OUT)
            .setField(
                Merchant_Pop_Up_Response__c.Disable_Mx_Form_Submission_For_This_URL__c,
                false
            );
        Merchant_Pop_Up_Response__c testMerchantPopUpResponse = (Merchant_Pop_Up_Response__c) merchantPopUpResponseFakeInstance.toSObject();
        List<Merchant_Pop_Up_Response__c> listMerchantPopUpResponse = new List<Merchant_Pop_Up_Response__c>();
        listMerchantPopUpResponse.add(testMerchantPopUpResponse);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFranchiseFormRequestsSelector mockFranchiseFormRequestsSelector = (IFranchiseFormRequestsSelector) mocks.mock(
            IFranchiseFormRequestsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockFranchiseFormRequestsSelector.sObjectType())
            .thenReturn(Merchant_Pop_Up_Response__c.SObjectType);
        mocks.when(
                mockFranchiseFormRequestsSelector.selectApprovedWithholdingOptOutFranchiseFormsToExpire()
            )
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockFranchiseFormRequestsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        FranchiseFormRequestsService.expireWithholdingOptOutFranchiseForms(
            listMerchantPopUpResponse
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Merchant_Pop_Up_Response__c.Disable_Mx_Form_Submission_For_This_URL__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test when an exception occurs then it is handled correctly.
     */
    @isTest
    private static void testWhenExceptionOccuredThenErrorMessageLogged() {
        Id merchantPopUpResponseID = fflib_IDGenerator.generate(
            Merchant_Pop_Up_Response__c.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        parentBusinessAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() - 1;
        Fake merchantPopUpResponseFakeInstance = new Fake(Merchant_Pop_Up_Response__c.class)
            .setField(Merchant_Pop_Up_Response__c.Id, merchantPopUpResponseID)
            .setField(Merchant_Pop_Up_Response__c.Approval_Status__c, APPROVED)
            .setField(Merchant_Pop_Up_Response__c.Mx_Corporate_Account__c, parentBusinessAccount.Id)
            .setField(Merchant_Pop_Up_Response__c.Select_the_Franchise_Type__c, WITHHOLDING_OPT_OUT)
            .setField(
                Merchant_Pop_Up_Response__c.Disable_Mx_Form_Submission_For_This_URL__c,
                false
            );
        Merchant_Pop_Up_Response__c testMerchantPopUpResponse = (Merchant_Pop_Up_Response__c) merchantPopUpResponseFakeInstance.toSObject();
        List<Merchant_Pop_Up_Response__c> listMerchantPopUpResponse = new List<Merchant_Pop_Up_Response__c>();
        listMerchantPopUpResponse.add(testMerchantPopUpResponse);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFranchiseFormRequestsSelector mockFranchiseFormRequestsSelector = (IFranchiseFormRequestsSelector) mocks.mock(
            IFranchiseFormRequestsSelector.class
        );
        String exceptionMessage;
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockFranchiseFormRequestsSelector.sObjectType())
            .thenReturn(Merchant_Pop_Up_Response__c.SObjectType);
        mocks.when(
                mockFranchiseFormRequestsSelector.selectApprovedWithholdingOptOutFranchiseFormsToExpire()
            )
            .thenReturn(null);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockFranchiseFormRequestsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            FranchiseFormRequestsService.expireWithholdingOptOutFranchiseForms(
                listMerchantPopUpResponse
            );
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => exceptionMessage }
                )
            );
    }
}