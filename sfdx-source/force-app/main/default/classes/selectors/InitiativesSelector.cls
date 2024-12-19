/**
 * @description Selector Class for Initiative Object
 * @author Deloitte
 * @date 05/04/2022
 */
public inherited sharing class InitiativesSelector extends fflib_SObjectSelector implements IInitiativesSelector {
    /**
     * @description Default Constructor for the Initiative Selector Class
     * @return IInitiativesSelector - Interface of IInitiativesSelector
     */
    public static IInitiativesSelector newInstance() {
        return (IInitiativesSelector) Application.Selector.newInstance(Initiative__c.SObjectType);
    }

    /**
     * @description This method is used for getting the fields on Initiative object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Initiative__c.Id,
            Initiative__c.Name,
            Initiative__c.Account__c,
            Initiative__c.Campaign_Member_Id__c
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Initiative - Initiative fields
     */
    public Schema.SObjectType getSObjectType() {
        return Initiative__c.SObjectType;
    }

    /**
     * @description This method is used for getting Initiatives based on Id
     * @param setIds Set of Ids
     * @return list of Initiative records
     */
    public List<Initiative__c> selectById(Set<Id> setIds) {
        return (List<Initiative__c>) selectSObjectsById(setIds);
    }

    /**
     * @description This method is used to query the parent Initiative records
     *              from child Insights
     * @param childInsights
     * @return List<Initiative__c>
     */
    public List<Initiative__c> selectByInsights(List<Product_Insights__c> childInsights) {
        Set<Id> initiativeIds = new Set<Id>();
        for (Product_Insights__c eachChildInsight : childInsights) {
            if (eachChildInsight.Initiative__c != null) {
                initiativeIds.add(eachChildInsight.Initiative__c);
            }
        }

        return selectById(initiativeIds);
    }

    /**
     * @description This metho is used to fetch all Initiatives having Campaign Members
     * @param campaignMemberIds
     * @return List<Initiative__c>
     */
    public List<Initiative__c> selectByCampaignMembers(Set<Id> campaignMemberIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Campaign_Member_Id__c IN :campaignMemberIds');
        return (List<Initiative__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch all Initiatives by AccountIds.
     * @param accountIds
     * @return List<Initiative__c>
     */
    public List<Initiative__c> selectByAccounts(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Account__c IN :accountIds');
        return (List<Initiative__c>) Database.query(query.toSOQL());
    }
}