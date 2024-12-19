/**
 * @author Deloitte
 * @date 19/06/2023
 * @description Domain Class for AccountTeamMember Object.
 */
public inherited sharing class AccountTeamMembers extends fflib_SObjects implements IAccountTeamMembers {
    private static final Set<Id> ACCOUNT_IDS = new Set<Id>();
    private static final Map<Id, List<String>> ACCOUNTID_TO_TEAM_ROLES = new Map<Id, List<String>>();
    private static final Map<Id, List<AccountTeamMember>> EXISTING_TEAM_MEMBERS = new Map<Id, List<AccountTeamMember>>();
    private static final string FRANCHISE_REP_ROLE = 'Franchise Representative';
    private static final String EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT';
    private static final String EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER';
    private static final String UPDATE_OWNER_FOR_FRANCHISE_ACCOUNTS_CHUNK_SIZE_STATIC_CONFIG = 'Update_Owner_For_Franchise_Accounts';
    private static final String UPDATE_OWNER_FOR_FRANCHISE_WORKORDERS_CHUNK_SIZE_STATIC_CONFIG = 'Update_Owner_For_Franchise_WorkOrders';
    /**
     * @description This method is used to return the IAccountTeamMembers interface
     * @param recordList
     * @return IAccountTeamMembers
     */
    public static IAccountTeamMembers newInstance(List<AccountTeamMember> recordList) {
        return (IAccountTeamMembers) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public AccountTeamMembers(List<AccountTeamMember> sObjectList) {
        super(sObjectList, Schema.AccountTeamMember.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList List<Object>
         * @return fflib_SObjects
         * AccountTeamMembers - list of accountTeamMember
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (AccountTeamMembers.constructorMock != null) {
                return (fflib_SObjects) AccountTeamMembers.constructorMock.construct(objectList);
            }
            return new AccountTeamMembers((List<SObject>) objectList);
        }
    }

    /**
     * @description collects accountIds for the passed accountTeamMember records
     * @param newMemberRecords
     */
    private void getAccountIds(List<AccountTeamMember> newMemberRecords) {
        if (newMemberRecords.isEmpty()) {
            return;
        }
        for (AccountTeamMember currTeamMember : newMemberRecords) {
            ACCOUNT_IDS.add(currTeamMember.AccountId);
        }
    }

    /**
     * @description Validate and throws error if there are more than one Franchise team role member in a single account Team
     * @JIRA# LEM-7300
     */
    public void validateIfItsAFranchiseRoleUser() {
        List<AccountTeamMember> newTeamMembers = (List<AccountTeamMember>) getRecords();
        getAccountIds(newTeamMembers);
        if (ACCOUNT_IDS.isEmpty()) {
            return;
        }
        for (
            Account acc : AccountsSelector.newInstance()
                .selectAccountWithAccTeamMembers(ACCOUNT_IDS)
        ) {
            EXISTING_TEAM_MEMBERS.put(acc.Id, acc.AccountTeamMembers);
        }

        getAccountsByAccountTeamMembers(newTeamMembers);
        for (AccountTeamMember eachTeamMember : newTeamMembers) {
            if (eachTeamMember.TeamMemberRole != FRANCHISE_REP_ROLE) {
                continue;
            }
            if (
                (ACCOUNTID_TO_TEAM_ROLES.containsKey(eachTeamMember.AccountId) &&
                ACCOUNTID_TO_TEAM_ROLES.get(eachTeamMember.AccountId).size() > 1) ||
                (EXISTING_TEAM_MEMBERS.containsKey(eachTeamMember.AccountId) &&
                EXISTING_TEAM_MEMBERS.get(eachTeamMember.AccountId).size() > 0)
            ) {
                eachTeamMember.addError(System.Label.Franchise_Role_Error_Message);
            }
        }
    }

    /**
     * @description Creates Map for AccountIdToTeamRoles for the passed AccountTeamMember records
     * @param teamMemberRecords
     */
    private void getAccountsByAccountTeamMembers(List<AccountTeamMember> teamMemberRecords) {
        for (AccountTeamMember eachTeamMember : teamMemberRecords) {
            if (
                eachTeamMember.AccountId != null &&
                eachTeamMember.TeamMemberRole == FRANCHISE_REP_ROLE &&
                EXISTING_TEAM_MEMBERS.containsKey(eachTeamMember.AccountId)
            ) {
                if (ACCOUNTID_TO_TEAM_ROLES.containsKey(eachTeamMember.AccountId)) {
                    ACCOUNTID_TO_TEAM_ROLES.get(eachTeamMember.AccountId)
                        .add(eachTeamMember.TeamMemberRole);
                } else {
                    ACCOUNTID_TO_TEAM_ROLES.put(
                        eachTeamMember.AccountId,
                        new List<String>{ eachTeamMember.TeamMemberRole }
                    );
                }
            }
        }
    }

    /**
    * @description Method to upate the Accounts and Work Orders Owner as Franchise Reps
    * @author rishab.goyal | 03-20-2024
    * @param accountIdsandOwnerIdsToProcess
    **/
    public void updateAccountAndWorkOrderOwnersasFranchiseReps(Map<Id,Id> accountIdsandOwnerIdsToProcess){

        List<Account> childAccounts = AccountsSelector.newInstance().selectFranchiseAccountsForCorporateAccounts(accountIdsandOwnerIdsToProcess.keySet());
        Map<Id,Id> childAccountIdsandOwnerIdsToProcess = new Map<Id,Id>();

        for (Account childAccount : childAccounts) {
            if(childAccount.OwnerId!=accountIdsandOwnerIdsToProcess.get(childAccount.ParentId)){
                childAccountIdsandOwnerIdsToProcess.put(childAccount.Id,accountIdsandOwnerIdsToProcess.get(childAccount.ParentId));
            }
        }
        Integer accountOwnerUpdatePayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(UPDATE_OWNER_FOR_FRANCHISE_ACCOUNTS_CHUNK_SIZE_STATIC_CONFIG)//Update_Owner_For_Franchise_Accounts
                .Configuration_Value__c
        );
        Integer workOrderOwnerUpdaePayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(UPDATE_OWNER_FOR_FRANCHISE_WORKORDERS_CHUNK_SIZE_STATIC_CONFIG)//Update_Owner_For_Franchise_WorkOrders
                .Configuration_Value__c
        );

        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT => payloadGenerationFranchiseOwner(
                    childAccountIdsandOwnerIdsToProcess,accountOwnerUpdatePayloadChunkSize
                )
            }
        );

        List<WorkOrder> workOrdersToUpdate = WorkOrdersSelector.newInstance().selectMarketplaceAndDriveWorkOrderInAllowedStatusByAccounts(childAccountIdsandOwnerIdsToProcess.keySet());

        Map<Id,Id> workorderIdsandOwnerIdsToProcess = new Map<Id,Id>();
        for(WorkOrder wo : workOrdersToUpdate){
            if(wo.ownerId!=childAccountIdsandOwnerIdsToProcess.get(wo.accountId)){
                workorderIdsandOwnerIdsToProcess.put(wo.Id,childAccountIdsandOwnerIdsToProcess.get(wo.AccountId));
            }
        }

        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER => payloadGenerationFranchiseOwner(
                    workorderIdsandOwnerIdsToProcess,workOrderOwnerUpdaePayloadChunkSize
                )
            }
        );
    }

    /**
    * @description Generate Payload for the Franchise Rep to be set as Owner of the Account and Owner Work Order
    * @author rishab.goyal | 03-20-2024
    * @param recordIdsandOwnerIdsToProcess
    * @param recordUpdateChunkSize
    * @return List<String>
    **/
    private List<String> payloadGenerationFranchiseOwner(
        Map<Id,Id> recordIdsandOwnerIdsToProcess,
        Integer recordUpdateChunkSize
    ) {
        List<String> payloads = new List<String>();
        Set<Id> recordIds = recordIdsandOwnerIdsToProcess.KeySet();
        List<String> payloadsFromNotifierEvent = NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
            recordIds,
            recordUpdateChunkSize
        );

        for (String eachPayload : payloadsFromNotifierEvent) {

            List<String> eachPayloadList = (List<String>) JSON.deserialize(eachPayload, List<String>.class);

            for(String eachPayloadString : eachPayloadList){
                eachPayloadString = eachPayloadString + ':'+recordIdsandOwnerIdsToProcess.get((Id)eachPayloadString);
                payloads.add(eachPayloadString);
            }
        }

        return payloads;
    }
}