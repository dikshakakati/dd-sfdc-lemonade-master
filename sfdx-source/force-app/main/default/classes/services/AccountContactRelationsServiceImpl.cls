/**
 * @author DoorDash
 * @date 07/09/2023
 * @description Service class for Account contact relationship object.
 */
public inherited sharing class AccountContactRelationsServiceImpl implements IAccountContactRelationsService {
    private static final String CONTACT_ROLE_DECISION_MAKER = 'Decision Maker';
    private static final String CONTACT_ROLE_BUSINESS_OWNER = 'Business Owner';
    private static final String CONTACT_ROLE_BUSINESS_DIRECTOR = 'Business Director';
    private static final Set<String> REQUIRED_CANADIAN_ROLES = new Set<String>{
        CONTACT_ROLE_BUSINESS_OWNER,
        CONTACT_ROLE_BUSINESS_DIRECTOR
    };
    private static final String ROLE_CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String SEMICOLON = ';';

    /**
     * @description deactivate acrs for passed accountIds
     * @param accountIds accountIds
     */
    public static void deactivateAccountAcrs(set<Id> accountIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            AccountContactRelation eachAcr : AccountContactRelationsSelector.newInstance()
                .selectActiveAcrByAccountIds(accountIds)
        ) {
            eachAcr.roles = '';
            eachAcr.isActive = false;
            uow.registerDirty(eachAcr);
        }
        uow.commitWork();
    }

    /**
     * @description Organizes ACRs by their Accounts and Roles
     * @param acrs
     * @return Map<Id, Map<String, AccountContactRelation>>
     **/
    public Map<Id, Map<String, AccountContactRelation>> sortRolesByAccountIdAndRoleName(
        List<AccountContactRelation> acrs
    ) {
        Map<Id, Map<String, AccountContactRelation>> rolesByBusinessAccountsAndRoleName = new Map<Id, Map<String, AccountContactRelation>>();

        for (AccountContactRelation acr : acrs) {
            // Skip processing if any essential fields are null or blank
            if (acr.AccountId == null || acr.Roles == null || String.isBlank(acr.Roles)) {
                continue;
            }

            // Split the Roles field into individual roles
            List<String> roles = acr.Roles.split(';');
            for (String role : roles) {
                role = role.trim(); // Clean up any extra spaces
                // Skip processing if role is blank
                if (String.isBlank(role)) {
                    continue;
                }

                // Create or retrieve the role map for the account
                Map<String, AccountContactRelation> roleMap = rolesByBusinessAccountsAndRoleName.get(
                    acr.AccountId
                );
                if (roleMap == null) {
                    roleMap = new Map<String, AccountContactRelation>();
                    rolesByBusinessAccountsAndRoleName.put(acr.AccountId, roleMap);
                }

                // Add the ACR if the role isn't already set
                if (!roleMap.containsKey(role)) {
                    roleMap.put(role, acr);
                }
            }
        }

        return rolesByBusinessAccountsAndRoleName;
    }

    /**
     * @description Returns true if the Canadian Contact Role requirements are met
     * @param rolesMap
     * @return Boolean
     **/
    public Boolean hasRequiredCanadianContactRoles(Map<String, AccountContactRelation> rolesMap) {
        if (rolesMap == null) {
            return false;
        }

        for (String requiredRole : REQUIRED_CANADIAN_ROLES) {
            // Check if the role is not present or the role is present but points to a null ACR
            if (!rolesMap.containsKey(requiredRole) || rolesMap.get(requiredRole) == null) {
                return false; // Early exit if any required role is missing
            }
        }

        return true; // Return true if all required roles are correctly assigned
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
        if (accountIdsContactIds.isEmpty()) {
            return;
        }
        Map<Id, Set<Id>> existingAcrMap = getExistingAcrMap(accountIdsContactIds.keySet());
        for (Id accountId : accountIdsContactIds.keySet()) {
            List<Id> contactIds = accountIdsContactIds.get(accountId);
            for (Id contactId : contactIds) {
                Boolean acrExists = checkIfAcrExists(accountId, contactId, existingAcrMap);
                if (!acrExists) {
                    createNewAcr(accountId, contactId, uow);
                } else {
                    updateExistingAcr(accountId, contactId, uow);
                }
            }
        }
    }

    private static Map<Id, Set<Id>> getExistingAcrMap(Set<Id> accountIds) {
        List<AccountContactRelation> acrList = AccountContactRelationsSelector.newInstance()
            .selectAcrByAccountIds(accountIds);
        Map<Id, Set<Id>> existingAcrMap = new Map<Id, Set<Id>>();

        for (AccountContactRelation acr : acrList) {
            if (!existingAcrMap.containsKey(acr.AccountId)) {
                existingAcrMap.put(acr.AccountId, new Set<Id>());
            }
            existingAcrMap.get(acr.AccountId).add(acr.ContactId);
        }
        return existingAcrMap;
    }

    private static boolean checkIfAcrExists(
        Id accountId,
        Id contactId,
        Map<Id, Set<Id>> existingAcrMap
    ) {
        Set<Id> existingContacts = existingAcrMap.get(accountId);
        return existingContacts != null && existingContacts.contains(contactId);
    }

    private static void createNewAcr(Id accountId, Id contactId, fflib_ISObjectUnitOfWork uow) {
        AccountContactRelation newAcr = new AccountContactRelation();
        newAcr.AccountId = accountId;
        newAcr.ContactId = contactId;
        newAcr.Roles = ROLE_CONTRACT_SIGNATORY;
        newAcr.IsActive = true;
        uow.registerNew(newAcr);
    }

    private static void updateExistingAcr(
        Id accountId,
        Id contactId,
        fflib_ISObjectUnitOfWork uow
    ) {
        for (
            AccountContactRelation acr : AccountContactRelationsSelector.newInstance()
                .selectAcrByAccountIds(new Set<Id>{ accountId })
        ) {
            if (acr.AccountId == accountId && acr.ContactId == contactId) {
                if (!acr.IsActive) {
                    acr.IsActive = true;
                    uow.registerDirty(acr);
                }
                if (acr.Roles == null) {
                    acr.Roles = ROLE_CONTRACT_SIGNATORY;
                    uow.registerDirty(acr);
                } else if (acr.Roles != null && !acr.Roles.contains(ROLE_CONTRACT_SIGNATORY)) {
                    acr.Roles = acr.Roles + SEMICOLON + ROLE_CONTRACT_SIGNATORY;
                    uow.registerDirty(acr);
                }
                break;
            }
        }
    }

    /**
     * @description It is used to map store account ids to associated decision maker contact ids.
     * @param accountIds
     * @return Map<Id, Id>
     */
    public Map<Id, Id> mapStoreIdToContactId(Set<Id> accountIds) {
        Map<Id, Id> storeIdToContactId = new Map<Id, Id>();
        for (
            AccountContactRelation eachRelation : AccountContactRelationsSelector.newInstance()
                .selectByAccountIds(accountIds)
        ) {
            storeIdToContactId.put(eachRelation.AccountId, eachRelation.ContactId);
        }
        return storeIdToContactId;
    }
}