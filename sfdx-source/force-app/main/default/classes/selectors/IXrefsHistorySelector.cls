/**
 * @author Aethereus
 * @date 03/06/2024
 * @description Interface for XrefsHistory selector class methods.
 */
public interface IXrefsHistorySelector extends fflib_ISObjectSelector {
    /**
     * @description Selects AccountHistory records for the given Account Ids, Account fields, User Ids and Work Order Created Date.
     * @param allxrefFieldSet - Set of all Xref fields
     * @param alllookUpXref - Set of all lookup Xref fields
     * @param userIds - List of User Ids
     * @param woCreatedDate - Work Order Created Date
     * @return List of AccountHistory records
     */
    List<Xref__History> selectXrefHistory(Set<String> allxrefFieldSet, Set<String> alllookUpXref , List<String> userIds, DateTime woCreatedDate);

}