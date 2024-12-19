/**
 * @author Deloitte
 * @date 05/02/2024
 * @description Selector Class for OpportunityTeamMember Object.
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ExcessiveClassLength')
public inherited sharing class OpportunityTeamMembersSelector extends fflib_SObjectSelector implements IOpportunityTeamMembersSelector {
    private static final String SALES_DEVELOPMENT_REP_ROLE = 'Sales Development Rep';

    /**
     * @description Default constructor for the class.
     * @return IOpportunityTeamMembersSelector
     */
    public static IOpportunityTeamMembersSelector newInstance() {
        return (IOpportunityTeamMembersSelector) Application.Selector.newInstance(
            OpportunityTeamMember.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method.
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunityTeamMember.SObjectType;
    }

    /**
     * @description This method is for getting the fields on OpportunityTeamMember
     * @return List<Schema.SObjectField>- OpportunityTeamMember fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OpportunityTeamMember.Id,
            OpportunityTeamMember.OpportunityId,
            OpportunityTeamMember.TeamMemberRole
        };
    }

    /**
     * @description : It is used to query Opportunity Team Members by passed Opportunity Ids.
     * @param opportunityIds
     * @return List<OpportunityTeamMember>
     */
    public List<OpportunityTeamMember> selectByOpportunityIds(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('UserId')
            .setCondition(
                'OpportunityId IN :opportunityIds AND TeamMemberRole = :SALES_DEVELOPMENT_REP_ROLE'
            );
        return (List<OpportunityTeamMember>) Database.query(query.toSOQL());
    }
    /**
     * @description : It is used to query Opportunity Team Members by passed Opportunity Ids.
     * @param opportunityIds
     * @return List<OpportunityTeamMember>
     */
    public List<OpportunityTeamMember> selectByOpportunityIdsWithoutRole(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('User.Email')
            .selectField('UserId')
            .setCondition(
                'OpportunityId IN :opportunityIds AND TeamMemberRole = :SALES_DEVELOPMENT_REP_ROLE'
            );
        return (List<OpportunityTeamMember>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to query all Opportunity Team Members by the passed Opportunity Ids
     * for OI notification flow..
     * @param opportunityIds
     * @return List<OpportunityTeamMember>
     */
    public List<OpportunityTeamMember> selectAllOpportunityTeamMembersByOpportunityIds(
        Set<String> opportunityIds
    ) {
        /* It allows querying Opportuntiy Team Members in a guest user context without
         * providing "Opportuntiy" object in "Mx Onboarding Inputs Guest User Access"
         * permission set.
         * Caution: DO NOT use this query for UI related scenarios.
         * DO NOT add other fields in this query otherwise the flow (Mx Onboarding Link: Send Bell Notification) will fail.
         */
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('OpportunityId')
            .selectField('UserId')
            .setCondition(
                'OpportunityId IN :opportunityIds AND User.IsActive = true'
            );
        return (List<OpportunityTeamMember>) Database.query(query.toSOQL());
    }
}