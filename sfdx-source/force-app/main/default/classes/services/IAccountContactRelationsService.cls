/**
 * @author DoorDash
 * @date 07/09/2023
 * @description Service class for processing acrs
 */
public interface IAccountContactRelationsService {
    /**
     * @description deactivate acrs for passed accountIds
     * @param accountIds accountIds
     */
    void deactivateAccountAcrs(set<Id> accountIds);

    /**
     * @description Organizes ACRs by their Accounts and Roles
     * @param acrs
     * @return Map<Id, Map<String, AccountContactRelation>>
     **/
    Map<Id, Map<String, AccountContactRelation>> sortRolesByAccountIdAndRoleName(
        List<AccountContactRelation> acrs
    );

    /**
     * @description Returns true if the Canadian Contact Role requirements are met
     * @param rolesMap
     * @return Boolean
     **/
    Boolean hasRequiredCanadianContactRoles(Map<String, AccountContactRelation> rolesMap);

    /**
     * @description Check to see if ACR needs to be created or not
     * If they are inactive, make them active
     * @param accountIdsContactIds
     * @param uow
     */
    void validateAndCreateAcr(Map<Id, List<Id>> accountIdsContactIds, fflib_ISObjectUnitOfWork uow);

    /**
     * @description It is used to map store account ids to associated decision maker contact ids.
     * @param accountIds
     * @return Map<Id, Id>
     */
    Map<Id, Id> mapStoreIdToContactId(Set<Id> accountIds);
}