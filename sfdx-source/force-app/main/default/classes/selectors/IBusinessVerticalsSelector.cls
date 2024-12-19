/**
 * @author Deloitte
 * @date 11/09/2023
 * @description Interface for BusinessVerticalsSelector class methods.
 */
public interface IBusinessVerticalsSelector extends fflib_ISObjectSelector {
    /**
     * @description It queries Business Verticals by passed set of Ids.
     * @JIRA# LEM-11072
     * @param setIds
     * @return List<Business_Vertical__c>
     */
    List<Business_Vertical__c> selectById(Set<Id> setIds);

    /**
     * @description It queries Business Vertical for Marketplace
     * @JIRA# LEM-11257
     * @return Business_Vertical__c
     */
    List<Business_Vertical__c> selectBusinessVerticalRecords();

    /**
     * @description It queries the records for Menu UI Type from  Business Vertical
     * @JIRA# LEM-11257
     * @param businessVerticalId
     * @return Business_Vertical__c
     */
    Business_Vertical__c selectMenuUITypeByBusinessVerticalIds(Id businessVerticalId);

    /**
     * @description It queries Business Vertical with 'Rx' as Primary Vertical
     * @JIRA# LEM-11072
     * @return Business_Vertical__c
     */
    List<Business_Vertical__c> selectPrimaryVerticalRxRecord();

    /**
     * @description It is used to get the Business Vertical record by name.
     * @param name
     * @return Business_Vertical__c
     */
    List<Business_Vertical__c> selectBusinessVerticalByName(string name);
}