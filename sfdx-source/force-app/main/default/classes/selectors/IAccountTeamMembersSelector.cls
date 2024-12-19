/**
 * @author Deloitte
 * @date 06/20/2022
 * @description Interface for AccountTeamMember selector class methods.
 */
public interface IAccountTeamMembersSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting list of AccountTeamMember having Franchise Representative role by an account.
     * @param accountId
     * @return List<AccountTeamMember>
     */
    List<AccountTeamMember> selectFranchiseRepRoleAccountTeamMembersByAccountId(Id accountId);

    /**
     * @description It is used for getting list of AccountTeamMember by Account Id.
     * @param accountId
     * @return List<AccountTeamMember>
     */
    List<AccountTeamMember> selectAccountTeamMembersByAccountId(Id accountId);
}