/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Selector class for Business Recommendations object.
 */
public inherited sharing class BusinessRecommendationsSelector extends fflib_SObjectSelector implements IBusinessRecommendationsSelector {
    /**
     * @description Default constructor for the class.
     * @return IBusinessRecommendationsSelector
     */
    public static IBusinessRecommendationsSelector newInstance() {
        return (IBusinessRecommendationsSelector) Application.Selector.newInstance(
            Recommendation_Business__x.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Recommendation_Business__x.SObjectType;
    }

    /**
     * @description It is used to get the SObjectFields.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Recommendation_Business__x.Id,
            Recommendation_Business__x.Recommendation__c,
            Recommendation_Business__x.incremental_sales__c,
            Recommendation_Business__x.Business_Account__c,
            Recommendation_Business__x.Rank__c,
            Recommendation_Business__x.points__c
        };
    }

    /**
     * @description It is used to get the Business Recommendations by the passed business account Ids.
     * @param businessAccountIds
     * @return List<Recommendation_Business__x>
     */
    public List<Recommendation_Business__x> selectBusinessRecommendationsByBusinessAccountIds(
        List<String> businessAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Account__c')
            .selectField('Business_Account__r.Id')
            .selectField('Recommendation__c')
            .selectField('incremental_sales__c')
            .selectField('points__c')
            .setCondition('Business_Account__c IN :businessAccountIds');
        return (List<Recommendation_Business__x>) Database.query(query.toSOQL());
    }
}