/**
 * @author Aethereus
 * @date 03/04/2024
 * @description Interface for AccountHistory selector class methods.
 */
public interface IAccountHistorySelector extends fflib_ISObjectSelector {
    /**
     * @description Selects AccountHistory records for the given Account Ids, Account fields, User Ids and Work Order Created Date.
     * @param allFields Set of Account fields
     * @param accIds Set of Account Ids
     * @param userIds List of User Ids
     * @param woCreatedDate Work Order Created Date
     * @return List of AccountHistory records
     */
    List<AccountHistory> selectAccountHistory(Set<String> allFields, Set<Id> accIds, List<String> userIds, DateTime woCreatedDate);

}