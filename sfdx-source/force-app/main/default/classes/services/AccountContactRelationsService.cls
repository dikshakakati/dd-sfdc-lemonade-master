/**
 * @author DoorDash
 * @date 07/09/2023
 * @description Service class for Account contact relationship object.
 */
public inherited sharing class AccountContactRelationsService {
    private static IAccountContactRelationsService service() {
        return (IAccountContactRelationsService) Application.SERVICE.newInstance(
            IAccountContactRelationsService.class
        );
    }
    /**
     * @description deactivate acrs for passed accountIds
     * @param accountIds accountIds
     */
    public static void deactivateAccountAcrs(set<Id> accountIds) {
        service().deactivateAccountAcrs(accountIds);
    }

    /**
     * @description Organizes ACRs by their Accounts and Roles
     * @param acrs
     * @return Map<Id, Map<String, AccountContactRelation>>
     **/
    public static Map<Id, Map<String, AccountContactRelation>> sortRolesByAccountIdAndRoleName(
        List<AccountContactRelation> acrs
    ) {
        return service().sortRolesByAccountIdAndRoleName(acrs);
    }

    /**
     * @description Returns true if the Canadian Contact Role requirements are met
     * @param rolesMap
     * @return Boolean
     **/
    public static Boolean hasRequiredCanadianContactRoles(
        Map<String, AccountContactRelation> rolesMap
    ) {
        return service().hasRequiredCanadianContactRoles(rolesMap);
    }

    /**
     * @description Check to see if ACR needs to be created
     * @param accountIdsContactIds
     * @param uow
     */
    public static void validateAndCreateAcr(
        Map<Id, List<Id>> accountIdsContactIds,
        fflib_ISObjectUnitOfWork uow
    ) {
        service().validateAndCreateAcr(accountIdsContactIds, uow);
    }

    /**
     * @description It is used to map store account ids to associated decision maker contact ids.
     * @param accountIds
     * @return Map<Id, Id>
     */
    public static Map<Id, Id> mapStoreIdToContactId(Set<Id> accountIds) {
        return service().mapStoreIdToContactId(accountIds);
    }
}