/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Selector Class for Mx_Tag Association Object
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class MxTagAssociationsSelector extends fflib_SObjectSelector implements IMxTagAssociationsSelector {
    private static final String ACTIVE = 'Active';
    private static final String BUSINESS = System.Label.BusinessAccountRecordTypeName;
    private static final String MX_TAG_BATCH_UPDATE_CRITERIA = System.Label.MxTagAssociationQueryConditionForBatch;
    private static final String STORE = System.Label.StoreAccountRecordTypeName;
    private static final String TOP_MX_TAG = 'Top MX';
    /**
     * @description Default constructor for the class
     * @return IMxTagAssociationsSelector - interface of IMxTagAssociationsSelector.
     */
    public static IMxTagAssociationsSelector newInstance() {
        return (IMxTagAssociationsSelector) Application.Selector.newInstance(
            Mx_Tag_Association__c.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method.
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return Mx_Tag_Association__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Mx_Tag_Association__c.
     * @return List<Schema.SObjectField>- Mx_Tag_Association__c fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mx_Tag_Association__c.Description__c,
            Mx_Tag_Association__c.Account__c,
            Mx_Tag_Association__c.Id,
            Mx_Tag_Association__c.Opportunity__c,
            Mx_Tag_Association__c.MxTag__c,
            Mx_Tag_Association__c.Lead__c,
            Mx_Tag_Association__c.Name,
            Mx_Tag_Association__c.MxTagAssociation_Status__c,
            Mx_Tag_Association__c.MxTagName__c
        };
    }

    /**
     * @description  It is used to get Mx_Tag Associations by Business Account Ids.
     * @param businessAccountIds
     * @return List<Mx_Tag_Association__c>
     */
    public List<Mx_Tag_Association__c> selectByBusinessAccountIds(Set<Id> businessAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Account__c IN :businessAccountIds AND MxTagAssociation_Status__c =: ACTIVE'
            );
        return (List<Mx_Tag_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description  It is used to get Mx_Tag Associations by Opportunity Ids.
     * @param opportunityIds
     * @return List<Mx_Tag_Association__c>
     */
    public List<Mx_Tag_Association__c> selectByOpportunityIds(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Opportunity__c IN :opportunityIds');
        return (List<Mx_Tag_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Mx Tag Associations by business Account Ids where Top Mx tag is present.
     * @param businessAccountIds
     * @return List<Mx_Tag_Association__c>
     */
    public List<Mx_Tag_Association__c> selectTopMXTagByBusinessAccountIds(
        Set<Id> businessAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Account__c IN :businessAccountIds AND MxTag__r.name__c = :TOP_MX_TAG');
        return (List<Mx_Tag_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get active Mx Tag Associations associated with Business Account
     * which are created/updated within last 24 hours.
     * @return List<Mx_Tag_Association__c >
     */
    public Database.QueryLocator selectActiveMxTagAssociationsCreatedUpdatedInLast24Hours() {
        fflib_QueryFactory query = newQueryFactory(false);
        query.selectField('Account__c');
        query.selectField('Account__r.Mx_Tag_Associations_Concatenated__c');
        query.selectField('Account__r.RecordType.Name');
        query.selectField('CreatedDate');
        query.selectField('LastModifiedDate');
        query.selectField('MxTagName__c');
        query.selectField('Opportunity_Account__c');
        query.setCondition(MX_TAG_BATCH_UPDATE_CRITERIA);
        return Database.getQueryLocator(query.toSOQL());
    }
}