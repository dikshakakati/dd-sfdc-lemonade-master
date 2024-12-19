/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Interface for Mx Fraud Documents selector class methods.
 */
public interface IMxFraudDocumentsSelector extends fflib_ISObjectSelector {
    /**
     * @description It returns Mx Fraud Documents based on passed Store Account Ids.
     * @param storeAccountIds
     * @return List<Mx_Fraud_Document__c>
     */
    List<Mx_Fraud_Document__c> selectByStoreAccountIds(Set<Id> storeAccountIds);
}