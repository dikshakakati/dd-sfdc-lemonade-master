/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Interface to add selector class methods.
 */
public interface IAccountContactRelationsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get the list of AccountContactRelation when AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectByAccountIds(Set<Id> accountIds);

    /**
     * @description This method is used to get all AccountContactRelations based on passed contactIds and the it having Accounting Contact role.
     * @param contactsIds
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectAllAccountContactRelationsHavingAccountingContactRoleWithContact(
        Set<Id> contactsIds
    );
    /**
     * @description This method is used to get AccountContactRelations based on contactIds
     * @param contactsIds
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectAccountContactRelationsByContactIds(Set<Id> contactsIds);
    /**
     * @description It is used to get the active AccountContactRelations when AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectActiveAcrByAccountIds(Set<Id> accountIds);

    /**
     * @description It is used to get the  AccountContactRelations when AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectAcrByAccountIds(Set<id> accountIds);

    /**
     * @description It is used to get the Decision Maker Contact details when AccountIds are passed.
     * @param accountIds
     * @param sObjectFields
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectDecisionMakerContactsByAccountIds(
        Set<Id> accountIds,
        Set<String> sObjectFields
    );

    /**
     * @description It is used to get the AccountContactRelations with Photoshoot role when
     * AccountIds are passed.
     * @param accountIds
     * @return List<AccountContactRelation>
     */
    List<AccountContactRelation> selectPhotoshootContactRolesByAccountIds(Set<Id> accountIds);

    /**
     * @description Selects ACRs given both Account IDs and Contact IDs
     * @param accountIds
     * @param contactIds
     * @return List<AccountContactRelation>
     **/
    List<AccountContactRelation> selectByAccountIdsAndContactIds(
        Set<Id> accountIds,
        Set<Id> contactIds
    );


    /**
     * @description It is used to get active ACRs by Account Ids for Decision Maker
     * and Contract Signatory roles.
     * @param accountIds
     * @return List<AccountContactRelation>
     **/
    List<AccountContactRelation> selectActiveACRByAccountIdsAndRoles(
        Set<Id> accountIds
    );
}