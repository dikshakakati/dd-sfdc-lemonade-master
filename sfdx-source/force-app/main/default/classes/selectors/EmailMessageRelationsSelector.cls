/**
 * @author Deloitte
 * @date 29/04/2024
 * @description Selector Class for EmailMessageRelation Object
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ExcessiveClassLength')
public inherited sharing class EmailMessageRelationsSelector extends fflib_SObjectSelector implements IEmailMessageRelationsSelector{
	/**
     * @description Default constructor for the class
     * @return IEmailMessageRelationsSelector - interface of IEmailMessageRelationsSelector.
     */
    public static IEmailMessageRelationsSelector newInstance() {
        return (IEmailMessageRelationsSelector) Application.Selector.newInstance(
            EmailMessageRelation.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method.
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return EmailMessageRelation.SObjectType;
    }
    
    /**
     * @description This method is for getting the fields on EmailMessageRelation
     * @return List<Schema.SObjectField>- EmailMessageRelation fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            EmailMessageRelation.Id,
            EmailMessageRelation.EmailMessage.Id,
            EmailMessageRelation.RelationId
        };
    }
    
    /**
     * @description  It is used to get EmailMessageRelation by EmailMessage Ids.
     * @param emailMessageIds
     * @return List<EmailMessageRelation>
     */
    public List<EmailMessageRelation> selectByEmailMessageIds(Set<Id> emailMessageIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('RelationObjectType')
            .selectField('EmailMessage.Id')
            .selectField('EmailMessage.Incoming')
            .selectField('RelationId')
            .selectField('EmailMessage.RelatedToId')
            .setCondition('EmailMessage.Id IN :emailMessageIds');
        return (List<EmailMessageRelation>) Database.query(query.toSOQL());
    }
}