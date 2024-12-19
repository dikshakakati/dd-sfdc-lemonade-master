/**
 * @author Aethereus
 * @date 23/07/2024
 * @description Selector Class for EmailMessage
 */
public inherited sharing class EmailMessagesSelector extends fflib_SObjectSelector implements IEmailMessagesSelector{

     /**
     * @description Default constructor for the EmailMessagesSelector Selector class.
     * @return IEmailMessagesSelector - interface of EmailMessagesSelector
     */
    public static IEmailMessagesSelector newInstance() {
        return (IEmailMessagesSelector) Application.Selector.newInstance(EmailMessage.SObjectType);
    }

    /**
     * @description It is for getting the fields on WorkPlan object.
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            EmailMessage.Id
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return EmailMessage.SObjectType;
    }

    /**
     * @description It is used to fetch all email message activities for store accounts.
     * @param accountIds
     * @return List<Account> accounts
     */
    public List<EmailMessage> selectEmailMessagesByRelatedId(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Subject')
            .selectField('RelatedToId')
            .selectField('RelatedTo.Name')
            .selectField('FromAddress')
            .selectField('ToAddress')
            .selectField('CcAddress')
            .selectField('BccAddress')
            .selectField('CreatedDate')
            .selectField('TextBody')
            .selectField('HtmlBody')
            .selectField('HasAttachment')
            .selectField('FirstOpenedDate')
            .selectField('MessageDate')
            .selectField('IsOpened')
            .selectField('Is_Message_Seen__c')
            .setCondition('RelatedToId IN :accountIds')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<EmailMessage>) Database.query(query.toSOQL());


    }


}