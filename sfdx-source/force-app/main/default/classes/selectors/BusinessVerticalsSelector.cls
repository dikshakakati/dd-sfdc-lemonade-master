/**
 * @author Deloitte
 * @date 11/10/2022
 * @description Selector class for Business Vertical Object.
 */
public inherited sharing class BusinessVerticalsSelector extends fflib_SObjectSelector implements IBusinessVerticalsSelector {
    private static final String RX_BUSINESS_VERTICAL_ID = '';
    private static final String RX_MENU_UI_TYPE = 'Restaurant';
    private static final String RX_PRIMARY_VERTICAL = 'Rx';
    private static final String RX_PRODUCT = 'Marketplace';
    private static final String RX_VERTICAL_NAME = '';

    /**
     * @description It is used for getting the fields of Business_Vertical__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Business_Vertical__c.Id,
            Business_Vertical__c.Business_Vertical_ID__c,
            Business_Vertical__c.Primary_Vertical__c,
            Business_Vertical__c.Menu_UI_Type__c,
            Business_Vertical__c.Name,
            Business_Vertical__c.Vertical_Name__c,
            Business_Vertical__c.Product__c
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Business_Vertical__c.SObjectType;
    }

    /**
     * @description Default Constructor for the BusinessVerticalsSelector class.
     * @return IBusinessVerticalsSelector
     */
    public static IBusinessVerticalsSelector newInstance() {
        return (IBusinessVerticalsSelector) Application.Selector.newInstance(
            Business_Vertical__c.SObjectType
        );
    }

    /**
     * @description It queries Business Verticals by passed set of Ids.
     * @JIRA# LEM-11072
     * @param setIds
     * @return List<Business_Vertical__c>
     */
    public List<Business_Vertical__c> selectById(Set<Id> setIds) {
        return (List<Business_Vertical__c>) selectSObjectsById(setIds);
    }

    /**
     * @description It queries Business Vertical for Marketplace
     * @JIRA# LEM-11257
     * @return Business_Vertical__c
     */
    public List<Business_Vertical__c> selectBusinessVerticalRecords() {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Business_Vertical_ID__c')
            .selectField('Name')
            .selectField('Vertical_Name__c')
            .selectField('Menu_UI_Type__c')
            .selectField('Product__c')
            .setCondition('Product__c = :RX_PRODUCT AND Vertical_Name__c != :RX_VERTICAL_NAME');
        return (List<Business_Vertical__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries the records for Menu UI Type from  Business Vertical
     * @JIRA# LEM-11257
     * @param businessVerticalId
     * @return Business_Vertical__c
     */
    public Business_Vertical__c selectMenuUITypeByBusinessVerticalIds(Id businessVerticalId) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Menu_UI_Type__c')
            .setCondition('Id = :businessVerticalId');
        return (Business_Vertical__c) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Business Vertical with 'Rx' as Primary Vertical
     * @JIRA# LEM-11072
     * @return Business_Vertical__c
     */
    public List<Business_Vertical__c> selectPrimaryVerticalRxRecord() {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Business_Vertical_ID__c')
            .selectField('Primary_Vertical__c')
            .selectField('Menu_UI_Type__c')
            .setCondition(
                'Business_Vertical_ID__c = :RX_BUSINESS_VERTICAL_ID AND Product__c = :RX_PRODUCT AND Primary_Vertical__c = :RX_PRIMARY_VERTICAL AND Menu_UI_Type__c = :RX_MENU_UI_TYPE'
            );
        return (List<Business_Vertical__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to get the Business Vertical record by name.
     * @param name
     * @return Business_Vertical__c
     */
    public List<Business_Vertical__c> selectBusinessVerticalByName(String name) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .setCondition('Name = :name');
        return (List<Business_Vertical__c>) Database.query(query.toSOQL());
    }

}