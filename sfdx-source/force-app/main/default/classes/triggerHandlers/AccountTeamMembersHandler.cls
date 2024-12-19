/**
 * @author Deloitte
 * @date 19/06/2023
 * @description AccountTeamMember Object Trigger Handler
 */
public class AccountTeamMembersHandler extends ApplicationDomainHandler {

    static final String CORPORATE = 'Corporate';
    private static final String FRANCHISE_REP_ROLE = 'Franchise Representative';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final Id BUSINESS_RECORD_TYPE_ID;
    static final String FRANCHISEE = 'Franchisee';
    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
    }
    /**
     * @description Constructor Method
     * @param sObjectList
     */
    public AccountTeamMembersHandler(List<AccountTeamMember> sObjectList) {
        super(sObjectList);
        setContextBypass(AccountTeamMember.sObjectType, AccountTeamMembersHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList List<SObject>
         * @return AccountTeamMembersHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountTeamMembersHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        validateIfItsAFranchiseRoleUser(this.records);
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onAfterInsert() {
        processAccountTeamMembers(this.records);
    }

    /**
     * @description Called to perform before update processing
     * @param existing
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        validateIfItsAFranchiseRoleUser(recordsWithUpdatedTeamRole());
    }

    /**
     * @description Validate and throws error if there are more than one Franchise team
     * role member in a single account Team
     * @param insertedAccountTeamMembers
     */
    private void validateIfItsAFranchiseRoleUser(
        List<AccountTeamMember> insertedAccountTeamMembers
    ) {
        AccountTeamMembers.newInstance(insertedAccountTeamMembers)
            .validateIfItsAFranchiseRoleUser();
    }

    /**
     * @description to check if team role is updated
     * @return List<AccountTeamMember>
     */
    private List<AccountTeamMember> recordsWithUpdatedTeamRole() {
        return new List<AccountTeamMember>(
            (List<AccountTeamMember>) getChangedRecords(
                new Set<SObjectField>{ AccountTeamMember.TeamMemberRole }
            )
        );
    }

/**
    * @description Helper Method for Insert of Account Team Member
    * @author rishab.goyal | 03-20-2024
    * @param teamMembers
    **/
    public void processAccountTeamMembers(List<AccountTeamMember> teamMembers) {

        Set<Id> accountIds = new Set<Id>();

        for (AccountTeamMember atm : teamMembers) {
            accountIds.add(atm.AccountId);
        }
        if(accountIds==null){
            return;
        }
        Map<Id, Account> accountsMap =
        new Map<Id, Account>(AccountsSelector.newInstance().selectById(accountIds));
            //[SELECT Id, Type, RecordType.Name FROM Account WHERE Id IN :accountIds]

        Map<Id,Id> accountIdsandOwnerIdsToProcess = new Map<Id,Id>();
        for (AccountTeamMember atm : teamMembers) {
        if(!accountsMap.containsKey(atm.AccountId)){
                continue;
            }
            Account relatedAccount = accountsMap.get(atm.AccountId);
        if(relatedAccount==null){
                continue;
            }
            if (atm.TeamMemberRole == FRANCHISE_REP_ROLE &&
                relatedAccount.Type == CORPORATE &&
                relatedAccount.RecordTypeId == BUSINESS_RECORD_TYPE_ID) {

                accountIdsandOwnerIdsToProcess.put(atm.AccountId, atm.UserId);
            }
        }

        AccountTeamMembers.newInstance(teamMembers)
            .updateAccountAndWorkOrderOwnersasFranchiseReps(accountIdsandOwnerIdsToProcess);

    }
}