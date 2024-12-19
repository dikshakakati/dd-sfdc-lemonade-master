/**
 * @author Deloitte
 * @date 06/20/2023
 * @description Selector class for AccountTeamMember object.
 */
public inherited sharing class AccountTeamMembersSelector extends fflib_SObjectSelector implements IAccountTeamMembersSelector {
    private static final String FRANCHISE_REP_ROLE = 'Franchise Representative';
    /**
     * @description Default constructor for the AccountTeamMember selector class.
     * @return IAccountTeamMembersSelector
     */
    public static IAccountTeamMembersSelector newInstance() {
        return (IAccountTeamMembersSelector) Application.Selector.newInstance(
            AccountTeamMember.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on AccountTeamMember object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AccountTeamMember.Id,
            AccountTeamMember.TeamMemberRole,
            AccountTeamMember.UserId
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AccountTeamMember.SObjectType;
    }

    /**
     * @description It is used for getting list of AccountTeamMember having Franchise Representative role by an account.
     * @param accountId
     * @return List<AccountTeamMember>
     */
    public List<AccountTeamMember> selectFranchiseRepRoleAccountTeamMembersByAccountId(
        Id accountId
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('AccountId =: accountId and TeamMemberRole =: FRANCHISE_REP_ROLE');
        return (List<AccountTeamMember>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting list of AccountTeamMember by Account Id.
     * @param accountId
     * @return List<AccountTeamMember>
     */
    public List<AccountTeamMember> selectAccountTeamMembersByAccountId(Id accountId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('AccountId =: accountId');
        return (List<AccountTeamMember>) Database.query(query.toSOQL());
    }
}