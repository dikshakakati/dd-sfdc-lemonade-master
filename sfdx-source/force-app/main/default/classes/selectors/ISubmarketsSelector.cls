/**
 * @author DoorDash
 * @date 04/01/2024
 * @description Selector interface for the Submarket__c record data.
 **/
public interface ISubmarketsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on Submarket__c Object.
     * @return List<Schema.SObjectField>- Submarket__c Object fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description It fetches the records that match the Submarket_ID__c & Name from Submarket__c object.
     * @param subMarketId
     * @param subMarketName
     * @return List<Submarket__c> - Returns list of Submarket__c records
     */
    List<Submarket__c> getSubmarketsByIdAndName(String subMarketId, String subMarketName);

    /**
     * @description It is used for retrieving all Submarket records by the passed submarketId.
     * @param submarketId
     * @return List<Submarket__c>
     */
    List<Submarket__c> getSubmarketById(String submarketId);

    /**
     * @description It is used for retrieving all Submarket records by the passed submarketIds.
     * @param submarketIds
     * @return List<Submarket__c>
     */
    List<Submarket__c> getSubmarketsByIds(Set<String> submarketIds);
}