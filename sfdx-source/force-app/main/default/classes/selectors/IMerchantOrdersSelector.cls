/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface for Merchant Orders selector class methods.
 */
public interface IMerchantOrdersSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to query the list of Mx Orders based on passed Ids.
     * @param mxOrderIds
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectById(Set<Id> mxOrderIds);

    /**
     * @description It queries Merchant Orders with related details
     * based on passed Merchant Order Ids.
     * @param merchantOrderIds
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectMerchantOrderRelatedDetailsById(Set<Id> merchantOrderIds);

    /**
     * @description It is used to query the list of Mx Orders when related Work Order Ids are passed.
     * @param workOrderIds
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectByWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description It queries Merchant Orders with photoshoot details
     * based on passed Merchant Order Ids.
     * @param merchantOrderIds
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectPhotoshootDetailsByMxOrderIds(Set<Id> merchantOrderIds);

    /**
     * @description It returns the query locator to fetch the Merchant Orders
     * with latest return label attachments.
     * @param bindingVariables
     * @return Database.QueryLocator
     */
    Database.QueryLocator queryLocatorMxOrdersWithReturnLabels(
        Map<String, Object> bindingVariables
    );

    /**
     * @description It is used to query the list of Mx Orders using the passed Work plan Ids.
     * @param workPlanIds
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectByWorkPlanIds(Set<Id> workPlanIds);

    /**
     * @description It is used to query Merchant orders using the passed Work Step Ids.
     * @param workStepIds
     * @param sObjectFields
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectByWorkStepIds(Set<Id> workStepIds, Set<String> sObjectFields);

    /**
     * @description It is used to query Merchant orders using the passed Merchant Order Names.
     * @param mxOrderNames
     * @return List<MX_Order__c>
     */
    List<MX_Order__c> selectByName(Set<String> mxOrderNames);
}