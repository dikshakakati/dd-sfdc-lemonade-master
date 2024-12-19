/**
 * @author Deloitte
 * @date 24/03/2022
 * @description Selector Class for Opportunity Contact Role Object
 */
public inherited sharing class OpportunityContactRoleSelector extends fflib_SObjectSelector implements IOpportunityContactRoleSelector {
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';
    /**
     * @description Default constructor for the OpportunityContactRoleSelector class
     * @return IOpportunityContactRoleSelector - interface of IOpportunityContactRoleSelector
     */
    public static IOpportunityContactRoleSelector newInstance() {
        return (IOpportunityContactRoleSelector) Application.Selector.newInstance(
            OpportunityContactRole.SObjectType
        );
    }

    /**
     * @description This method is used for getting the fields on OpportunityContactRole object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OpportunityContactRole.Id,
            OpportunityContactRole.CurrencyIsoCode,
            OpportunityContactRole.ContactId,
            OpportunityContactRole.OpportunityId,
            OpportunityContactRole.Role,
            OpportunityContactRole.Quote__c,
            OpportunityContactRole.IsPrimary
        };
    }

    /**
     * @description This method is used for getting object type
     * @return Quote - Quote fields
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunityContactRole.SObjectType;
    }

    /**
     * @description This method is used for getting OpportunityContactRole based on Id
     * @param setIds Set of Ids
     * @return list of OpportunityContactRole records
     */
    public List<OpportunityContactRole> selectById(Set<Id> setIds) {
        return (List<OpportunityContactRole>) selectSObjectsById(setIds);
    }

    /**
     * @description This method is used to get the list of OpportunityContactRole for opportunities
     * @param opportunityIds
     * @return List<OpportunityContactRole>
     */
    public List<OpportunityContactRole> selectByOpportunity(Set<Id> opportunityIds) {
        fflib_QueryFactory opportunityContactRoleQuery = newQueryFactory(false, false, true)
            .setCondition('OpportunityId IN :opportunityIds AND IsPrimary = true')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<OpportunityContactRole>) Database.query(opportunityContactRoleQuery.toSOQL());
    }

    /**
     * @description It is used to get the list of Primary OpportunityContactRole for the passed
     * Opportunities and role.
     * @param opportunityIds
     * @return List<OpportunityContactRole>
     */
    public List<OpportunityContactRole> selectPrimaryOrContractSignatoryOpportunityContactRoleByOpportunity(
        Set<Id> opportunityIds
    ) {
        fflib_QueryFactory opportunityContactRoleQuery = newQueryFactory(false, false, true)
            .setCondition(
                'OpportunityId IN :opportunityIds AND (IsPrimary = true OR Role = :CONTRACT_SIGNATORY_CONTACT_ROLE)'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<OpportunityContactRole>) Database.query(opportunityContactRoleQuery.toSOQL());
    }

    /**
     * @description This method is used to get the list of OpportunityContactRole for opportunities
     *              with Role as 'Contract Signatory'
     * @param opportunityIds
     * @return List<OpportunityContactRole>
     */
    public List<OpportunityContactRole> selectContractSignatoryOppContactRole(
        Set<Id> opportunityIds
    ) {
        fflib_QueryFactory opportunityContactRoleQuery = newQueryFactory(false, false, true)
            .setCondition(
                'OpportunityId IN :opportunityIds AND Role = :CONTRACT_SIGNATORY_CONTACT_ROLE'
            );
        return (List<OpportunityContactRole>) Database.query(opportunityContactRoleQuery.toSOQL());
    }

    /**
     * @description This method is used to get the list of Contract Signatory
     *  OpportunityContactRole for opportunities by quote id.
     * @param quoteIds
     * @return List<OpportunityContactRole>
     */
    public List<OpportunityContactRole> selectByQuoteIdAndFilterByContractSignatory(
        Set<Id> quoteIds
    ) {
        return (List<OpportunityContactRole>) Database.query(
            newQueryFactory()
                .setCondition('Quote__c IN : quoteIds AND Role = :CONTRACT_SIGNATORY_CONTACT_ROLE')
                .toSOQL()
        );
    }
}