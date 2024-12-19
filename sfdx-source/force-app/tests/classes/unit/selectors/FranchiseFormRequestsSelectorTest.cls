/**
 * @author Deloitte
 * @date 09/12/2023
 * @description Test class for FranchiseFormRequestsSelector class.
 */
@isTest(SeeAllData=false)
private class FranchiseFormRequestsSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String APPROVED = 'Approved';
    private static final String ASSERT_MESSAGE_APPROVAL_STATUS_DO_NOT_MATCH = 'Unexpected result: Franchise Form Requests Status does not match.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Franchise Form Request (Merchant_Pop_Up_Response__c).';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Franchise Form Requests count does not match.';
    private static final String PENDING = 'Pending';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        FranchiseFormRequestsSelector franchiseFormRequestsSelectorInstance = new FranchiseFormRequestsSelector();
        Schema.SObjectType typeOfObject = franchiseFormRequestsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = franchiseFormRequestsSelectorInstance.getSObjectFieldList();
        FranchiseFormRequestsSelector.newInstance();
        System.assertEquals(
            Schema.Merchant_Pop_Up_Response__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Merchant_Pop_Up_Response__c.Id,
                Merchant_Pop_Up_Response__c.Franchise_Account__c,
                Merchant_Pop_Up_Response__c.Mx_Corporate_Account__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description Used to get the to be expired Withholding Opt-out Franchise Forms Request records when
     * Number of Days to Opt out is zero on corporate Account.
     */
    @isTest
    private static void testWhenOptOutExpiryDateIsLessThanTodayThenToBeExpiredWithholdingOptOutFranchiseFormReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Type = ACCOUNT_TYPE_CORPORATE;
        parentAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() - 1;
        insert parentAccount;
        Merchant_Pop_Up_Response__c franchiseFormRequest = new Merchant_Pop_Up_Response__c(
            Approval_Status__c = APPROVED,
            Mx_Corporate_Account__c = parentAccount.Id,
            Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT,
            Disable_Mx_Form_Submission_For_This_URL__c = false
        );
        insert franchiseFormRequest;
        Test.startTest();
        Database.QueryLocator queryMerchantPopUpResponse = FranchiseFormRequestsSelector.newInstance()
            .selectApprovedWithholdingOptOutFranchiseFormsToExpire();
        Test.stopTest();

        Database.QueryLocatorIterator iteratorOnMerchantPopUpResponse = queryMerchantPopUpResponse.iterator();

        List<Merchant_Pop_Up_Response__c> fetchedMerchantPopUpResponse = new List<Merchant_Pop_Up_Response__c>();

        while (iteratorOnMerchantPopUpResponse.hasNext()) {
            fetchedMerchantPopUpResponse.add(
                (Merchant_Pop_Up_Response__c) iteratorOnMerchantPopUpResponse.next()
            );
        }

        System.assertEquals(
            false,
            fetchedMerchantPopUpResponse.isEmpty(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test that no Withholding Opt-out Franchise Forms Request record retrieved when
     * Number of Days to Opt out is not zero on corporate Account.
     */
    @isTest
    private static void testWhenOptOutExpiryDateGreaterThanTodayThenNoToBeExpiredWithholdingOptOutFranchiseFormReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Type = ACCOUNT_TYPE_CORPORATE;
        parentAccount.Withholding_Opt_out_Expiry_Date__c = Date.today() + 1;
        insert parentAccount;
        Merchant_Pop_Up_Response__c franchiseFormRequest = new Merchant_Pop_Up_Response__c(
            Approval_Status__c = PENDING,
            Mx_Corporate_Account__c = parentAccount.Id,
            Select_the_Franchise_Type__c = WITHHOLDING_OPT_OUT,
            Disable_Mx_Form_Submission_For_This_URL__c = false
        );
        insert franchiseFormRequest;
        Test.startTest();
        Database.QueryLocator queryMerchantPopUpResponse = FranchiseFormRequestsSelector.newInstance()
            .selectApprovedWithholdingOptOutFranchiseFormsToExpire();
        Test.stopTest();

        Database.QueryLocatorIterator iteratorOnMerchantPopUpResponse = queryMerchantPopUpResponse.iterator();

        List<Merchant_Pop_Up_Response__c> fetchedMerchantPopUpResponse = new List<Merchant_Pop_Up_Response__c>();

        while (iteratorOnMerchantPopUpResponse.hasNext()) {
            fetchedMerchantPopUpResponse.add(
                (Merchant_Pop_Up_Response__c) iteratorOnMerchantPopUpResponse.next()
            );
        }

        System.assertEquals(
            true,
            fetchedMerchantPopUpResponse.isEmpty(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}