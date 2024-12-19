/**
 * @author Deloitte
 * @date 04/22/2024
 * @description Interface to add Selector class methods.
 */
public interface IMxTagAssociationsSelector extends fflib_ISObjectSelector {
    /**
     * @description  It is used to get MxTag Associations by Business Account Ids.
     * @param businessAccountIds
     * @return List<Mx_Tag_Association__c>
     */

    List<Mx_Tag_Association__c> selectByBusinessAccountIds(Set<Id> businessAccountIds);

    /**
     * @description  It is used to get MxTag Associations by Opportunity Ids.
     * @param opportunityIds
     * @return List<Mx_Tag_Association__c>
     */

    List<Mx_Tag_Association__c> selectByOpportunityIds(Set<Id> opportunityIds);

    /**
     * @description It is used to get Mx Tag Associations by business Account Ids where Top Mx tag is present.
     * @param businessAccountIds
     * @return List<Mx_Tag_Association__c>
     */
    List<Mx_Tag_Association__c> selectTopMXTagByBusinessAccountIds(Set<Id> businessAccountIds);
}