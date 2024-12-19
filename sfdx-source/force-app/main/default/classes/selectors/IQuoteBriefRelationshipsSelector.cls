/**
 * @author Deloitte
 * @date 12/21/2022
 * @description Interface for Quote Brief Relationship selector.
 */
public interface IQuoteBriefRelationshipsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch Quote Brief Relationships by Id
     * @param quoteBriefRelationshipIds
     * @return List<Quote_Brief_Relationship__c>
     */
    List<Quote_Brief_Relationship__c> selectById(Set<Id> quoteBriefRelationshipIds);
}