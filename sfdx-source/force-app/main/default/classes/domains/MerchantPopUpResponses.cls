/**
 * @author Deloitte
 * @date 16/08/2022
 * @description Domain Class for Merchant Pop-Up Responses
 */
public inherited sharing class MerchantPopUpResponses extends fflib_SObjects implements IMerchantPopUpResponses {
    private static final String APPROVED = 'Approved';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final Id BUSINESS_RECORD_TYPE_ID;
    private static final Id PAYMENT_ACCOUNT_RECORD_TYPE_ID;
    private static final Id PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID;
    private static final String MARKETPLACE = 'Marketplace';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        PAYMENT_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Payments')
            .getRecordTypeId();
        PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Invoice')
            .getRecordTypeId();
    }
    /**
     * @description This method is used to return the IMerchantPopUpResponses interface
     * @param recordList - Merchant Response record list
     * @return IMerchantPopUpResponses - Returns IMerchantPopUpResponses Interface
     */
    public static IMerchantPopUpResponses newInstance(
        List<Merchant_Pop_Up_Response__c> recordList
    ) {
        return (IMerchantPopUpResponses) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public MerchantPopUpResponses(List<Merchant_Pop_Up_Response__c> sObjectList) {
        super(sObjectList, Schema.Merchant_Pop_Up_Response__c.SObjectType);
    }

    /**
     * @description To create instance of MerchantPopUpResponses domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Construct
         * @param objects List<Object>
         * @return instance of MerchantPopUpResponses
         */
        public fflib_ISObjects construct(List<Object> objects) {
            return new MerchantPopUpResponses((List<Merchant_Pop_Up_Response__c>) objects);
        }
    }

    /**
     * @description This method is used to set the business, store and payment account record type id
     */
    public void updateRecordTypeIdsOnMerchantResponse() {
        for (
            Merchant_Pop_Up_Response__c eachMerchantResponse : (List<Merchant_Pop_Up_Response__c>) getRecords()
        ) {
            eachMerchantResponse.Business_Account_Record_Type_Id__c = BUSINESS_RECORD_TYPE_ID;
            eachMerchantResponse.Store_Account_Record_Type_Id__c = STORE_RECORD_TYPE_ID;
            if (eachMerchantResponse.Form_Type__c == MARKETPLACE) {
                eachMerchantResponse.Payment_Account_Record_Type_Id__c = PAYMENT_ACCOUNT_RECORD_TYPE_ID;
            } else {
                eachMerchantResponse.Payment_Account_Record_Type_Id__c = PAYMENT_ACCOUNT_RECORD_TYPE_ID;
                eachMerchantResponse.Invoice_Payment_Account_Record_Type_Id__c = PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID;
            }
        }
    }

    /**
     * @description This method is used to set latest COO exception emails on merchantresponse record.
     */
    public void updateLatestCOOExceptionEmailListOnMerchantResponse() {
        String emailString = MerchantPopUpResponseController.getEmailsOfQueueMembers();
        for (
            Merchant_Pop_Up_Response__c eachMerchantResponse : (List<Merchant_Pop_Up_Response__c>) getRecordsByFieldValue(
                Merchant_Pop_Up_Response__c.Check_COO_Exception_Email_List_Updated__c,
                true
            )
        ) {
            if (eachMerchantResponse.COO_Exception_Log_Queue_Member_Emails__c != emailString) {
                eachMerchantResponse.COO_Exception_Log_Queue_Member_Emails__c = emailString;
            }
            eachMerchantResponse.Check_COO_Exception_Email_List_Updated__c = false;
        }
    }

    /**
     * @description It initiates the update on corporate accounts to set
     * "Withholding Opt-out Expiry Date" for Franchise Form Requests with "Approval Status"
     * as 'Approved' and "Franchise Type" as 'Withholding Opt-out'.
     * @JIRA# LEM-10617
     */
    public void setWithholdingExpiryDateOnCorporateAccountsByEligibleFranchisFormRequests() {
        Set<Id> corporateAccountIds = getCoporateAccountIdsByApprovedWithholdingOptOutFranchiseFormRequests(
            (List<Merchant_Pop_Up_Response__c>) getRecords()
        );
        if (corporateAccountIds.isEmpty()) {
            return;
        }
        AccountsService.stampWithholdingExpiryDateOnCorporateAccounts(corporateAccountIds);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description It collects corporate account Ids from Franchise Form Requests
     * with "Approval Status" as 'Approved' and "Franchise Type" as 'Withholding Opt-out'.
     * @param franchiseFormRequests
     * @return Set<Id>
     */
    private Set<Id> getCoporateAccountIdsByApprovedWithholdingOptOutFranchiseFormRequests(
        List<Merchant_Pop_Up_Response__c> franchiseFormRequests
    ) {
        Set<Id> corporateAccountIds = new Set<Id>();
        for (Merchant_Pop_Up_Response__c eachFranchiseFormRequest : franchiseFormRequests) {
            if (
                eachFranchiseFormRequest.Select_the_Franchise_Type__c == WITHHOLDING_OPT_OUT &&
                eachFranchiseFormRequest.Approval_Status__c == APPROVED
            ) {
                corporateAccountIds.add(eachFranchiseFormRequest.Mx_Corporate_Account__c);
            }
        }
        return corporateAccountIds;
    }

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }
}