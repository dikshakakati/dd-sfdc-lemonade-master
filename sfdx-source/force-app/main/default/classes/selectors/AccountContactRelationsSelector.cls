/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Selector class for AccountContactRelation object.
 */

public inherited sharing class AccountContactRelationsSelector extends fflib_SObjectSelector implements IAccountContactRelationsSelector {
    private static final String ACCOUNTING_CONTACT_ROLE = 'Accounting Contact';
    private static final String CONTRACT_SIGNATORY_ACCOUNT_CONTACT_RELATION_ROLE = 'Contract Signatory';
    private static final String DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE = 'Decision Maker';
    private static final String PHOTOSHOOT_ROLE = 'Photoshoot Contact';

    /**
     * @description Default constructor for the AccountContactRelationSelector class.
     * @return IAccountContactRelationsSelector - interface of IAccountContactRelationsSelector
     */
    public static IAccountContactRelationsSelector newInstance() {
        return (IAccountContactRelationsSelector) Application.Selector.newInstance(
            AccountContactRelation.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on AccountContactRelation object.
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AccountContactRelation.Id,
            AccountContactRelation.ContactId,
            AccountContactRelation.AccountId,
            AccountContactRelation.Roles,
            AccountContactRelation.IsActive
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AccountContactRelation.SObjectType;
    }

    /**
     * @description It is used to get the AccountContactRelations when AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .selectField('AccountId')
            .selectField('Account_Record_Type__c')
            .selectField('Contact.Account.Record_Type_Name__c')
            .selectField('Contact.Phone')
            .selectField('Contact.Name')
            .setCondition(
                'AccountId IN :accountIds' +
                ' AND Roles includes (:DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE) AND IsActive = true'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }

    /**
     * @description This method is used to get all AccountContactRelations based on passed contactIds and the it having Accounting Contact role.
     * @param contactsIds
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectAllAccountContactRelationsHavingAccountingContactRoleWithContact(
        Set<Id> contactsIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Account.ParentId')
            .selectField('AccountId')
            .selectField('Contact.Birthdate')
            .selectField('Contact.SSN_Last_4Digits__c')
            .setCondition(
                'ContactId IN: contactsIds AND Roles INCLUDES (:ACCOUNTING_CONTACT_ROLE)'
            );
        return (List<AccountContactRelation>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used to get AccountContactRelations based on contactId
     * @param contactsIds
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectAccountContactRelationsByContactIds(
        Set<Id> contactsIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Account.ParentId')
            .selectField('AccountId')
            .selectField('Contact.Birthdate')
            .selectField('Contact.SSN_Last_4Digits__c')
            .setCondition('ContactId IN: contactsIds');
        return (List<AccountContactRelation>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to get the active AccountContactRelations when AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectActiveAcrByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .selectField('AccountId')
            .selectField('ContactId')
            .selectField('Contact.Birthdate')
            .selectField('Contact.Title')
            .selectField('Contact.Email')
            .selectField('Contact.Phone')
            .selectField('Contact.MailingStreet')
            .selectField('Contact.MailingCity')
            .selectField('Contact.MailingState')
            .selectField('Contact.MailingCountry')
            .selectField('Contact.MailingPostalCode')
            .setCondition('AccountId IN :accountIds ' + 'AND IsActive  = true')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }

    /**
     * @description It is used to get the  AccountContactRelations when AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectAcrByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .setCondition('AccountId IN :accountIds');
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }

    /**
     * @description It is used to get the Decision Maker Contact details when AccountIds are passed.
     * @param accountIds
     * @param sObjectFields
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectDecisionMakerContactsByAccountIds(
        Set<Id> accountIds,
        Set<String> sObjectFields
    ) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .selectField('AccountId')
            .selectFields(sObjectFields)
            .setCondition(
                'AccountId IN :accountIds' +
                ' AND Roles includes (:DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE) AND IsActive = true'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }

    /**
     * @description It is used to get the AccountContactRelations with Photoshoot role when
     * AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> selectPhotoshootContactRolesByAccountIds(
        Set<Id> accountIds
    ) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .selectField('AccountId')
            .selectField('Contact')
            .setCondition(
                'AccountId IN :accountIds' +
                ' AND (Roles includes (:PHOTOSHOOT_ROLE)' +
                ' OR Roles includes (:DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE))' +
                ' AND IsActive = true'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }

    /**
     * @description Selects ACRs given both Account IDs and Contact IDs
     * @param accountIds
     * @param contactIds
     * @return List<AccountContactRelation>
     **/
    public List<AccountContactRelation> selectByAccountIdsAndContactIds(
        Set<Id> accountIds,
        Set<Id> contactIds
    ) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .selectField('IsActive')
            .setCondition('AccountId IN :accountIds ' + 'AND ContactId IN :contactIds')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }
    /**
     * @description It is used to get active ACRs by Account Ids for Decision Maker
     * and Contract Signatory roles.
     * @JIRA# LEM-23044
     * @param accountIds
     * @return List<AccountContactRelation>
     **/
    public List<AccountContactRelation> selectActiveACRByAccountIdsAndRoles(Set<Id> accountIds) {
        fflib_QueryFactory accountContactRelationQuery = newQueryFactory()
            .setCondition(
                'AccountId IN :accountIds' +
                ' AND (Roles includes (:DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE) OR Roles includes (:CONTRACT_SIGNATORY_ACCOUNT_CONTACT_RELATION_ROLE))' +
                ' AND IsActive = true'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<AccountContactRelation>) Database.query(accountContactRelationQuery.toSOQL());
    }
}