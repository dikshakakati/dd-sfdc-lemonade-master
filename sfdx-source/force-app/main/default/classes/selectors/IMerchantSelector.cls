/**
 * @author Deloitte
 * @date 05/06/2022
 *@description This is the Selector interface for merchant Selector related logic
 */
public interface IMerchantSelector extends fflib_ISObjectSelector {
    /**
     * @description method to be implemented in child class.
     * @return List of Merchant Service Rec Ids.
     * @param merchantRecIds - Merchant_Service__c Record Ids
     */
    List<Merchant_Service__c> queryMerchantRecords(Set<Id> merchantRecIds);

    /**
     * @description method to be implemented in child class.
     * @return List of Merchant Service Rec Ids.
     * @param storeRecIds
     * @param mxRecIds
     * @param packageExclusion
     */
    List<Merchant_Service__c> selectExistingMerchantServiceToExcludeByStoreIdsAndPackage(
        Set<Id> storeRecIds,
        Set<Id> mxRecIds,
        set<String> packageExclusion
    );

    /**
     * @description method to be implemented in child class.
     * @return List<Merchant_Service__c> List of Merchant Service Rec Ids.
     * @param accountIds - Merchant_Service__c Record Ids
     */
    List<Merchant_Service__c> queryMerchantRecordsWithAccountIds(Set<Id> accountIds);

    /**
     * @description method to be implemented in child class.
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - Franchise Parent Record Ids
     */
    List<Merchant_Service__c> queryMerchantRecordsWithFranchiseParentAccountIds(Set<Id> accountIds);

    /**
     * @description returns Order Products that should should now be activated.
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - account Ids to search.
     */
    List<Merchant_Service__c> queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId(
        Set<Id> accountIds
    );

    /**
     * @description returns Order Products that should should now be activated.
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - account Ids to search.
     */
    List<Merchant_Service__c> queryActiveDriveServicesWithDraftOrderProductsByAccountId(
        Set<Id> accountIds
    );

    /**
     * @description It is used for getting Accounts Ids linked to Merchant Services
     * based on the passed Subscription ids.
     * @param subIds
     * @return Aggregate[]
     */
    Aggregate[] selectServicesBySubIdsGroupedByAccount(Set<Id> subIds);

    /**
     * @description It queries Merchant Services based on the associated Account
     * with product name as Alcohol Delivery or Alcohol Pickup.
     * @param accountIds
     * @return List<Merchant_Service__c>
     */
    List<Merchant_Service__c> selectServicesWithAlcoholProductsByAccountIds(Set<Id> accountIds);

    /**
     * @description Returns active services by account Ids.
     * @JIRA #LEM-15980
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - account Ids to search.
     * @param contractIds - account Ids to search.
     */
    List<Merchant_Service__c> selectActiveServicesByAccountIds(
        Set<Id> accountIds,
        Set<Id> contractIds
    );
    /**
     * @description It is for getting the records on Merchant Service object
     * @param businessAccountId
     * @param contractId
     * @return List<Merchant_Service__c>
     */
    List<Merchant_Service__c> selectMerchantServiceToShowUnderContractsAmendment(
        Id businessAccountId,
        Id contractId
    );

    /**
     * @description It is used to fetch churned merchant services by the passed contract ids.
     * @param contractIds
     * @return List<Merchant_Service__c>
     */
    List<Merchant_Service__c> selectChurnedMxServicesByContractIds(Set<Id> contractIds);
}