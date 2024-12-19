/**
 * @author Deloitte
 * @date 09/11/2023
 * @description Selector class for Merchant_Pop_Up_Response__c object.
 */
public inherited sharing class FranchiseFormRequestsSelector extends fflib_SObjectSelector implements IFranchiseFormRequestsSelector {
    private static final String APPROVED = 'Approved';
    private static final String NUMBER_OF_DAYS_TO_OPT_OUT_ZERO = '0';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;

    /**
     * @description Default constructor for the class.
     * @return IFranchiseFormRequestsSelector
     */
    public static IFranchiseFormRequestsSelector newInstance() {
        return (IFranchiseFormRequestsSelector) Application.Selector.newInstance(
            Merchant_Pop_Up_Response__c.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Merchant_Pop_Up_Response__c.SObjectType;
    }

    /**
     * @description It is for getting the fields on
     * Franchise Form Request (Merchant_Pop_Up_Response__c).
     * @JIRA# LEM-9497
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Merchant_Pop_Up_Response__c.Id,
            Merchant_Pop_Up_Response__c.Franchise_Account__c,
            Merchant_Pop_Up_Response__c.Mx_Corporate_Account__c
        };
    }

    /**
     * @description It is used to get the approved Withholding Opt-out Franchise Form Request records
     * where the 'Number of Days to Opt-out' on corporate Account is 0.
     * @JIRA# LEM-9550
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectApprovedWithholdingOptOutFranchiseFormsToExpire() {
        fflib_QueryFactory franchiseFormRequestToExpireQuery = newQueryFactory()
            .selectField('Disable_Mx_Form_Submission_For_This_URL__c')
            .setCondition(
                'Select_the_Franchise_Type__c = :WITHHOLDING_OPT_OUT' +
                    ' AND Approval_Status__c = :APPROVED' +
                    ' AND Disable_Mx_Form_Submission_For_This_URL__c = FALSE' +
                    ' AND Mx_Corporate_Account__r.Number_of_Days_to_Opt_out__c = :NUMBER_OF_DAYS_TO_OPT_OUT_ZERO'
            );
        return Database.getQueryLocator(franchiseFormRequestToExpireQuery.toSOQL());
    }
}