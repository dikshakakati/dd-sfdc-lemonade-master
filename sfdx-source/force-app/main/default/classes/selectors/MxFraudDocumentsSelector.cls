/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Selector class for Mx Fraud Documents object.
 */
public inherited sharing class MxFraudDocumentsSelector extends fflib_SObjectSelector implements IMxFraudDocumentsSelector {
    /**
     * @description It returns the instance of IMxFraudDocumentsSelector interface.
     * @return IMxFraudDocumentsSelector
     */
    public static IMxFraudDocumentsSelector newInstance() {
        return (IMxFraudDocumentsSelector) Application.Selector.newInstance(
            Mx_Fraud_Document__c.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method.
     * @JIRA# LEM-15836
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Mx_Fraud_Document__c.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Mx Fraud Document.
     * @JIRA# LEM-15836
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mx_Fraud_Document__c.Id,
            Mx_Fraud_Document__c.CreatedDate,
            Mx_Fraud_Document__c.Document_Title__c,
            Mx_Fraud_Document__c.Document_Version__c,
            Mx_Fraud_Document__c.LastModifiedDate,
            Mx_Fraud_Document__c.Mx_Country__c,
            Mx_Fraud_Document__c.Mx_Document_Type__c,
            Mx_Fraud_Document__c.Mx_Document_Verification_Notes__c,
            Mx_Fraud_Document__c.Mx_Document_Verification_Status__c,
            Mx_Fraud_Document__c.Mx_Store_Id__c,
            Mx_Fraud_Document__c.Name,
            Mx_Fraud_Document__c.Store_Id__c,
            Mx_Fraud_Document__c.Work_Plan__c
        };
    }

    /**
     * @description It returns Mx Fraud Documents based on passed Store Account Ids.
     * @JIRA# LEM-15836
     * @param storeAccountIds
     * @return List<Mx_Fraud_Document__c>
     */
    public List<Mx_Fraud_Document__c> selectByStoreAccountIds(Set<Id> storeAccountIds) {
        // LEM-18563 - Bypassed CRUD check for this query only during Trigger execution.
        if (Trigger.isExecuting) {
            ignoreCRUD();
        }
        fflib_QueryFactory mxFraudDocumentsQuery = newQueryFactory()
            .setCondition('Mx_Store_Id__c IN :storeAccountIds');
        return (List<Mx_Fraud_Document__c>) Database.query(mxFraudDocumentsQuery.toSOQL());
    }
}