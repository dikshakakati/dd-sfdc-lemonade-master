/**
 * @author Deloitte
 * @date 16/08/2022
 * @description Merchant Pop-Up Response Trigger Handler
 */
public inherited sharing class MerchantPopUpResponsesHandler extends ApplicationDomainHandler {
    private static final String APPROVED = 'Approved';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG = 'Corp_Acc_Size_To_Switch_Payment_Method';
    private static final String EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING = 'UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    /**
     * @description Constructor to instantiate List of Merchant Responses
     * @param sObjectList - Merchant Responses Record List
     */
    public MerchantPopUpResponsesHandler(List<Merchant_Pop_Up_Response__c> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Merchant_Pop_Up_Response__c.SobjectType,
            MerchantPopUpResponsesHandler.class
        );
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return MerchantPopUpResponsesHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MerchantPopUpResponsesHandler(sObjectList);
        }
    }

    /**
     * @description It is called to perform processing during the after update phase.
     * * @JIRA LEM-10617
     * @param existingRecords
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        MerchantPopUpResponses.newInstance(getFranchiseFormRequestsWithChangedApprovalStatus())
            .setWithholdingExpiryDateOnCorporateAccountsByEligibleFranchisFormRequests();
    }

    /**
     * @description Called to perform Before Insert operations on the Merchant Responses
     */
    public override void onBeforeInsert() {
        MerchantPopUpResponses.newInstance(this.records).updateRecordTypeIdsOnMerchantResponse();
    }
    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        MerchantPopUpResponses.newInstance(emailFlagUpdatedRecords())
            .updateLatestCOOExceptionEmailListOnMerchantResponse();
    }

    /**
     * @description It used to get changed records
     * @return List<Merchant_Pop_Up_Response__c>
     */
    private List<Merchant_Pop_Up_Response__c> emailFlagUpdatedRecords() {
        return new List<Merchant_Pop_Up_Response__c>(
            (List<Merchant_Pop_Up_Response__c>) getChangedRecords(
                new Set<SObjectField>{
                    Merchant_Pop_Up_Response__c.Check_COO_Exception_Email_List_Updated__c
                }
            )
        );
    }

    /**
     * @description It used to get the franchise form requests where the approval status is changed.
     * @return List<Merchant_Pop_Up_Response__c>
     */
    private List<Merchant_Pop_Up_Response__c> getFranchiseFormRequestsWithChangedApprovalStatus() {
        return new List<Merchant_Pop_Up_Response__c>(
            (List<Merchant_Pop_Up_Response__c>) getChangedRecords(
                new Set<SObjectField>{ Merchant_Pop_Up_Response__c.Approval_Status__c }
            )
        );
    }
}