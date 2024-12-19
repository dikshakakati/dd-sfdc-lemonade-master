/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface for Merchant Order Items selector class methods.
 */
public interface IMerchantOrderItemsSelector extends fflib_ISObjectSelector {
    /**
     * @description It queries Merchant Orders Items with related details
     * based on passed Tablet Merchant Order Ids.
     * @JIRA# LEM-15028
     * @param tabletMxOrderIds
     * @return List<MX_Order_Item__c>
     */
    List<MX_Order_Item__c> selectMxOrderItemWithMxOrderIds(Set<Id> tabletMxOrderIds);

    /**
     * @description It queries Merchant Orders Items with related details based on Identifier.
     * @param identifierValues
     * @JIRA# LEM-15028
     * @return List<MX_Order_Item__c>
     */
    List<MX_Order_Item__c> selectMxOrderItemWithIdentifiers(Set<String> identifierValues);

    /**
     * @description It queries Merchant Orders Items with related details
     * based on Identifier.
     * @JIRA# LEM-15028
     * @param identifierValues
     * @param types
     * @return List<MX_Order_Item__c>
     */
    List<MX_Order_Item__c> selectMxOrderItemWithIdentifiersAndTypes(Set<String> identifierValues, Set<String> types);
}