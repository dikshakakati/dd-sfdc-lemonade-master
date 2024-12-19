/**
 * @author Deloitte
 * @description Interface to add selector class methods.
 */
public interface IAccountsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return Map<Id, Account> - Map of Accounts
     */
    List<Account> selectById(Set<Id> idSet);

    /**
     * @description This method is used for getting Sobject type Id
     * @param recordIds
     * @return List<Account>
     */
    List<Account> selectById(Set<String> recordIds);

    /**
     * @description This method is used for getting Accounts by Id And non-activated MDS
     * @param idSet
     * @param mdsActivation
     * @return List<Account>
     */
    List<Account> selectById(Set<Id> idSet, Boolean mdsActivation);

    /**
     * @description This method id for getting child opportunities
     * @param childOpportunities
     * @return Map<Id, Account> - List of Accounts
     */
    List<Account> selectByOpportunity(List<Opportunity> childOpportunities);

    /**
     * @description This method querying account with Bussiness record type and Account life cycle status not equal to In Pursuit.
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectUnverifiedBusinessAccountsById(Set<Id> accountIds);

    /**
     * @description This method querying account with Bussiness record type and Account life cycle status is equal to In Pursuit.
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectInPursuitBusinessAccountsById(Set<Id> accountIds);

    /**
     * @description This method is used for getting Accounts based on ID
     * @param accountRecords
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectAllParents(Set<Id> accountRecords);

    /**
     * @description This method is used for getting all accounts with past NDA Dates
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectAccountsWithExpiredNda();

    /**
     * @description This method is used for getting Accounts based on ID
     * @param accountRecords
     * @return List<Account>
     */
    List<Account> selectAllAccountsWithParent(Set<Id> accountRecords);

    /**
     * @description This method is used for getting child Account records
     * @param idSet
     * @return List<Account>
     */
    List<Account> selectChildAccounts(Set<Id> idSet);
    /**
     * @description This method is used for getting franchise or Business Account records
     * @param accountRecordIds
     * @return List<Account>
     */
    List<Account> selectChildAccountsByCorporateOrFranchiseParent(Set<Id> accountRecordIds);

    /**
     * @description This method is used for getting child records to update Merchant Verticals of Parent
     * @param accountRecordIds
     * @return List<Account>
     */
    List<Account> selectChildMerchantVerticals(Set<Id> accountRecordIds);

    /**
     * @description This method is used for getting Store records to update Additional Verticals of
     * Business Parent.
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsWithPrimaryVerticalByParentAccount(Set<Id> accountIds);

    /**
     * @description This method is used for getting sum of all child store count
     * @param idSet
     * @return Aggregate[]
     */
    Aggregate[] selectSumOfChildStoreCount(Set<Id> idSet);

    /**
     * @description This method is used for getting count of franchise owned via parent
     * @param idSet
     * @return Aggregate[]
     */
    Aggregate[] selectFranchiseOwnedViaParentCount(Set<Id> idSet);

    /**
     * @description This method is used for getting count of franchise owner via franchise parent
     * @param idSet
     * @return Aggregate[]
     */
    Aggregate[] selectFranchiseOwnedViaFranchiseCount(Set<Id> idSet);

    /**
     * @description This method is used for getting count of corporate accounts
     * @param idSet
     * @return Aggregate[]
     */
    Aggregate[] selectCorporateCount(Set<Id> idSet);

    /**
     * @description This method is used for getting non franchisee accounts
     * @param idSet
     * @return List<Account>
     */
    List<Account> selectNonFranchiseeAccountsById(Set<Id> idSet);

    /**
     * @description This method is used for getting count of child busines account with partnership status
     * @param idSet
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfChildrenBusinessAccountsByPartnershipStatus(Set<Id> idSet);

    /**
     * @description This method is used for getting count of child store account with activation status
     * @param idSet
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfChildrenStoreAccountsByActivationStatus(Set<Id> idSet);

    /**
     * @description This method is used to query accounts for account hierarchy component
     * @param fieldsToQuery
     * @param recordIds
     * @return List<Account>
     */
    List<Account> selectFilteredAccount(Set<String> fieldsToQuery, List<Id> recordIds);

    /**
     * @description This method is used to query child accounts for account hierarchy component
     * @param fieldsToQuery
     * @param filteredField
     * @param recordIds
     * @return List<Account>
     */
    List<Account> selectHierachyChildAccounts(
        Set<String> fieldsToQuery,
        SObjectField filteredField,
        List<Id> recordIds
    );

    /**
     * @description It queries Account details and related records
     * (AccountPaymentAccountRelations, Agreements and Xrefs) filtered by Account Ids.
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectRelatedChildsById(Set<Id> accountIds);

    /**
     * @description This method is used to get account attributes for top down automation
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectAccountAttributesForTopDownAutomationBatch();

    /**
     * @description This method is used for getting store accounts
     * @param idSet
     * @return List<Account>
     */
    List<Account> selectStoreAccountsById(Set<Id> idSet);

    /**
     * @description This method is used for fetching store Accounts having associated
     * franchise parents for the provided corporate Accounts with appropriate Xrefs and franchise parent must have a Franchise Agreement with the Contract.
     * @param accountRecordIds
     * @param externalIdSource
     * @param contractId
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByParentIds(
        Set<String> accountRecordIds,
        String externalIdSource,
        String contractId
    );

    /**
     * @description Get all the Store Accounts where Markeplace Nintext Id equals the Opportunity
     * Nintext Id.
     * @JIRA# LEM-2352
     * @param nintextIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByMarketplaceNintextIds(Set<String> nintextIds);

    /**
     * @description Get all the Store Accounts where Drive Nintext Id equals the Opportunity
     * Nintext Id.
     * @JIRA# LEM-2674
     * @param nintextIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByDriveNintextIds(Set<String> nintextIds);

    /**
     * @description It is used to get store Account details
     * by the passed Marketplace/Drive Nintex Id.
     * @param nintexIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByMarketplaceOrDriveNintexIds(Set<String> nintexIds);

    /**
     * @description It is used to get Account details when AccountIds are passed
     * @param accountIdSet
     * @return List<Account>
     */
    List<Account> selectAccountsWithBrandName(Set<Id> accountIdSet);

    /**
     * @description It is used to select accounts by the given fieldset and Ids.
     * @param fieldSet
     * @param accountsIds
     * @return List<Account>
     **/
    List<Account> selectAccountsByIdAndFieldSet(Schema.FieldSet fieldSet, Set<Id> accountsIds);

    /**
     * @description It is used to get Account details with Activation Orders for the given AccountIds
     * @param accountIdSet
     * @return List<Account>
     */
    List<Account> selectAccountsWithXrefs(Set<Id> accountIdSet);

    /**
     * @description It is used to get Account details with Activation Orders for the given AccountIds
     * @param accountIdSet
     * @return List<Account>
     */
    List<Account> selectAccountsWithInActiveXrefs(Set<Id> accountIdSet);

    /**
     * @description It is used for querying in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order on matching search key
     * and doesn't have any child WorkOrders filtered by parentIds, parentWorkOrderId, parentField,
     * searchKey and storeIds by matching the passed search key with the Account's Name or Address.
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @param searchKey
     * @param storeIds
     * @return List<Account>
     */
    List<Account> selectVerifiedStoreAccountsByBusinessIdAndSearchKey(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField,
        String searchKey,
        Set<Id> storeIds
    );

    /**
     * @description It is used for querying in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child WorkOrders filtered by parentIds, parentWorkOrderId and parentField.
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @return List<Account>
     */
    List<Account> selectVerifiedStoreAccountsByBusinessId(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField
    );

    /**
     * @description It is used for querying in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child WorkOrders filtered by parentIds, parentWorkOrderId, parentField and lastReturnedId.
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @param lastReturnedId
     * @return List<Account>
     */
    List<Account> selectVerifiedStoreAccountsById(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField,
        Id lastReturnedId
    );

    /**
     * @description This method is used for getting child object records related to account
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectRelatedChildRecordsByAccountsWithIsMergedEnabled();

    /**
     * @description It is used for querying store Accounts related to the
     * passed franchise Accounts.
     * @param franchiseAccountIds
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectStoreAccountsByFranchiseParentIds(Set<Id> franchiseAccountIds);

    /**
     * @description It is used for getting store account with parent corporate.
     * @param accountIds
     * @return List<Account> accounts
     */
    List<Account> getStoreAccountsWithParentCorporate(Set<Id> accountIds);

    /**
     * @description It is used to get Account details with Parent Details for the given AccountIds
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectAccountsWithParentDetailsById(Set<Id> accountIds);

    /**
     * @description It is used for querying business Accounts filtered by the passed parent field
     * and parent Ids.
     * @param parentField
     * @param parentIds
     * @return List<Account>
     */
    List<Account> selectBusinessAccountsByParentIds(SObjectField parentField, Set<Id> parentIds);

    /**
     * @description This method is used for getting child corporate accounts based on account Id.
     * @param accountRecordIds
     * @return List<Account>
     */
    List<Account> selectAllChildCorporateAccountsWithParent(Set<String> accountRecordIds);

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @return List<Account>
     */
    List<Account> selectRelatedStoreAccounts(Id parentWorkOrderId);

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @param lastReturnedId
     * @return List<Account>
     */
    List<Account> selectRelatedStoreAccountsChunk(Id parentWorkOrderId, Id lastReturnedId);

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @param searchKey
     * @param storeIds
     * @return List<Account>
     */
    List<Account> selectRelatedStoreAccountsBySearchKey(
        Id parentWorkOrderId,
        String searchKey,
        Set<Id> storeIds
    );

    /**
     * @description This method is used for getting Accounts by AccountIds
     * @param accountIdSet
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectByIdsForBatchProcess(Set<Id> accountIdSet);

    /**
     * @description This method is used for getting child merchant services with Accounts by AccountIds
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectAccountsWithActiveServices(Set<Id> accountIds);

    /**
     * @description This method is used for getting child merchant services with Accounts by AccountIds
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectAccountsWithServices(Set<Id> accountIds);

    /**
     * @description This method is used for getting accounts along with its franchise
     * role accountteam members based on account Id.
     * @param recordIds
     * @return List<Account>
     */
    List<Account> selectAccountWithAccTeamMembers(Set<Id> recordIds);

    /**
     * @description This method is used for getting business Account with Account names and address Ids.
     * @param accountNames
     * @param addressIds
     * @return List<Account>
     */
    List<Account> selectBusinessAccountsWithNameAndAddressId(
        Set<String> accountNames,
        Set<String> addressIds
    );

    /**
     * @description This method is used for getting Corporate Account Ids
     * from Store account for a Franchise account.
     * @param accountsIds
     * @return List<Account>
     */
    List<Account> getCorporateAccountIdsByFranchiseAccount(Set<Id> accountsIds);

    /**
     * @description Selects Stores made in a given Bulk Store Onboarding transaction by Process Flow Request.
     * @param flowRequestId
     * @return List<Account>
     **/
    List<Account> getStoresByBulkOnboardingRequestId(Id flowRequestId);

    /**
     * @description Select the entire Corporate hierarchy
     * @param fieldsToQuery
     * @param recordIds
     * @return List<Account>
     */
    List<Account> getCorporateAccountHierarchyByUltimateParentAccount(
        Set<String> fieldsToQuery,
        List<Id> recordIds
    );

    /**
     * @description Select the entire Corporate hierarchy.
     * @param accountIds
     * @return List<Account>
     */
    List<Account> getUltimateParentAccount(Set<String> accountIds);

    /**
     * @description It is used to get the count of accounts for which the account owner is
     * not matching with parent account's owner.
     * @param accountIds
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfNonMatchingParentAccountFieldsAccounts(Set<Id> accountIds);

    /**
     * @description It is used for querying child accounts of corporate Business accounts
     * @JIRA# LEM-11918
     * @param corporateAccountIds
     * @param queryLimit
     * @return List<Account>
     */
    List<Account> selectChildAccountsForAccountFieldsTrickleDown(
        Set<Id> corporateAccountIds,
        Integer queryLimit
    );

    /**
     * @description It is used for getting related Store Accounts information based on the passed
     * Work Order Ids.
     * @param fieldSet
     * @param parentWorkOrderIds
     * @return List<Account>
     */
    List<Account> selectRelatedStoreAccountsInformation(
        Schema.FieldSet fieldSet,
        Set<Id> parentWorkOrderIds
    );

    /**
     * @description This method is used for getting Store Accounts
     * for passed list of ids.
     * @param accountsIds
     * @return Database.QueryLocator
     */
    Database.QueryLocator getStoreAccountsById(Set<Id> accountsIds);

    /**
     * @description to Fetch all Franchise Store and Business Account  by corporate Account Ids
     * @author rishab.goyal | 03-20-2024
     * @param corporateAccountIds
     * @return List<Account>
     **/
    List<Account> selectFranchiseAccountsForCorporateAccounts(Set<Id> corporateAccountIds);

    /**
     * @description Retrieves a list of Account records without applying any filters, using the specified set of fields and record IDs.
     * @param fieldsToQuery A set of field names to include in the query.
     * @param recordIds A set of record IDs to retrieve.
     * @return A list of Account records matching the specified criteria.
     */
    List<Account> selectAccountWithOutFilterswithSetOfFieldsPassed(
        Set<String> fieldsToQuery,
        Set<Id> recordIds
    );

    /**
     * @description This method is used for getting sum of all business accounts
     * @param accountsIds
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfAccounts(Set<Id> accountsIds);

    /**
     * @description This method is used for getting franchisee store accounts
     * @param accountRecordIds
     * @return List<Account>
     */
    List<Account> selectFranchiseeStoreAccountsById(Set<Id> accountRecordIds);

    /**
     * @description retrive the store accounts along with their active and valid Xrefs
     * @param storeAccountdIds
     * @return List<Account>
     */
    List<Account> getStoreAccountsWithValidActiveXrefs(Set<Id> storeAccountdIds);

    /**
     * @description It is used for getting the Store Account records for US Compliance Rules.
     * @JIRA LEM-14598
     * @param accountIds
     * @return List<Account>
     */
    List<Account> getStoreAccounts(Set<Id> accountIds);

    /**
     * @description It is used to get the count of child store account with medal rank.
     * @param accountsIds
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfStoreAccountsByMedalRank(Set<Id> accountsIds);

    /**
     * @description It is used for getting Accounts by uniqueIdentifiers And recordType.
     * @param uniqueIdentifiers
     * @param recordTypeId
     * @return List<Account>
     */
    List<Account> selectAccountsByUniqueIdentifiersAndRecordType(
        Set<String> uniqueIdentifiers,
        Id recordTypeId
    );

    /**
     * @description It is used to Query accounts with associated account contact relations
     * by passing account ids and contact ids.
     * @param accountsIds
     * @param contactIds
     * @return List<Account>
     */
    List<Account> selectAccountAndRelatedContactRelationsByAccountAndContactIds(
        Set<Id> accountsIds,
        List<Id> contactIds
    );

    /**
     * @description It is used to Query accounts where the account ultimate parent
     * is in the passed set of ultimateParentAccountIds.
     * @param ultimateParentAccountIds
     * @param contactIds
     * @return List<Account>
     */
    List<Account> selectAccountsByUltimateParentAccountIds(
        Set<Id> ultimateParentAccountIds,
        List<Id> contactIds
    );

    /**
     * @description It is used to Query accounts with associated account contact relations
     * by passing account ids.
     * @param accountsIds
     * @return List<Account>
     */
    List<Account> selectAccountAndRelatedOpportunitiesByAccountIds(Set<Id> accountsIds);

    /**
     * @description This method is used for getting the Account which has MX tag Association named as TOPMX by AccountIds
     * @JIRA LEM-14284
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectAccountsWithMxTagAssociation(Set<Id> accountIds);

    /**
     * @description This method is used for fetching store Accounts having associated
     * franchise parent for the provided corporate Accounts with appropriate Xrefs and franchise parent must have a Franchise Agreement with the Contract.
     * @param accountRecordIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByParentIdsAndExternalSource(Set<Id> accountRecordIds);

    /**
     * @description This method is used for getting Stores added to a Parent WorkOrder.
     * @param parentWorkOrderIds
     * @return List<Account>
     */
    List<Account> selectRelatedStoreAccountsQuery(Set<Id> parentWorkOrderIds);

    /**
     * @description It is used for getting Store Accounts based on
     * Parent Account Ids and UUIDs.
     * @JIRA LEM-15363
     * @param accountIds
     * @param uuids
     * @return List<Account>
     */
    List<Account> selectByUniqueIdentifiers(Set<Id> accountIds, Set<String> uuids);

    /**
     * @description Retrieves a  list of Account records based on the specified IDs and a map of fields to include.
     *
     * @param accountId The set of parent IDs to filter the Account records.
     * @param sobjectToSetOfField A map of String to a set of fields to include in the query.
     * @return A list of Account records that match the specified criteria.
     */
    List<Account> selectAccountByIdWithXrefPaymentAccount(
        Set<Id> accountId,
        Map<String, Set<String>> sobjectToSetOfField
    );

    /**
     * @description It is used to Query accounts with brand associations
     * by passing account ids.
     * @param accountIds
     * @return List<Account>
     */
    List<Account> getAccountsWithBrandAssociationsbyAccountIds(Set<Id> accountIds);

    /**
     * @description It queries store accounts along with Tablet MxOrders
     * and Decision Maker contat details based on passed Store Account Ids.
     * @param storeAccountIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsAndRelatedEntitiesByAccountIds(Set<Id> storeAccountIds);

    /**
     * @description This method is used for getting franchisee store accounts
     * @param parentIds
     * @param experienceValue
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByParentIdsAndExperience(
        Set<Id> parentIds,
        String experienceValue
    );
    /**
     * @description It is used to Query accounts with partnership expiration date in next 90 days
     * and having renewal opportunity as null by passing account ids.
     * @return Database.QueryLocator
     */
    Database.QueryLocator getAccountsForRunningRenewalBatch();


    /**
    * @description - select by business account and return store info along with its payment account
     * @author Soumya Dash | 07-30-2024
     * @param bussinessAccountId
     * @param objectTosObjectField
     * @param ;
     * @return List<Account>
     **/
    List<Account> selectByBusinessAccountIdAndgetStoreDetails(
        Id bussinessAccountId,
        Map<String, Set<String>> objectTosObjectField
    );


    /**
   * @description - select by store account and return store info along with its Payment account
     * @author Soumya Dash | 07-30-2024
     * @param storeAccountId
     * @param businessAccountId
     * @param objectTosObjectField
     * @param ;
     * @return List<Account>
     **/
    List<Account> selectByStoreAccountIdAndgetStoreDetails(
        Id storeAccountId,
        Id businessAccountId,
        Map<String, Set<String>> objectTosObjectField
    );

    /**
     * @description - select by Store account Id, Returns account with XrefRecord
     * @author Samiksha Bharti | 06-23-2024
     * @param accountId
     * @param sobjectToSetOfField
     * @return Account
     **/
    /**
     * @description It is used to get the count of active child store accounts.
     * @param accountsIds
     * @return Aggregate[]
     */
    Aggregate[] selectActiveCorporateCount(Set<Id> accountsIds);
    /**
     * @description It is used to get the count of inactive child store accounts.
     * @param accountsIds
     * @return Aggregate[]
     */
    Aggregate[] selectInActiveCorporateCount(Set<Id> accountsIds);
    /**
     * @description It is used to get the count of Active MDS Xrefs.
     * @param accountIdSet
     * @return List of Account
     */
    List<Account> selectAccountsWithMDSXrefs(Set<Id> accountIdSet);
    /**
     * @description It is used to get the count of Active non MDS Xrefs.
     * @param accountIdSet
     * @return List of Account
     */
    List<Account> selectAccountsWithNonMDSXrefs(Set<Id> accountIdSet);
    /**
     * @description It is used to get the Business Account Id from Store Account Id.
     * @param accountIds
     * @return List of Account
     */
    List<Account> selectBusinessAccountIdsFromStoreAccountId(Set<Id> accountIds);
    /**
     * @description - select by Store account Id, Returns account with XrefRecord
     * @author Samiksha Bharti | 06-23-2024
     * @param accountId
     * @param sobjectToSetOfField
     * @return Account
     **/
    List<Account> selectAccountByIdWithXref(
        Set<Id> accountId,
        Map<String, Set<String>> sobjectToSetOfField
    );

    /**
     * @description It is used for getting Accounts with passed Mx Onboarding Link Ids.
     * @JIRA# LEM-15113
     * @param mxOnboardingLinkIds
     * @return List<Account>
     */
    List<Account> selectAccountsByMxOnboardingLinkIds(Set<String> mxOnboardingLinkIds);

    /**
     * @description Retrieves a list of Account records based on the provided accountIds and bizIds.
     *
     * @param uuids A set of Account record uuids to filter the query.
     * @param bizIds A set of business reference external Ids to filter xrefs in the query.
     * @return A list of Account records that match the specified criteria.
     */
    List<Account> selectStoreAccountByUUIDWithXrefs(Set<String> uuids, Set<String> bizIds);

    /**
     * @description Store Account by Id with MDS Xref
     * @author VenkateshDD | 08-05-2024
     * @param uuids
     * @return List<Account>
     **/
    List<Account> selectStoreAccountByUUIDWithXrefs(Set<String> uuids);

    /**
     * @description This method is used for getting store accounts based on parent account id.
     * @param accountRecordIds
     * @return List<Account>
     */
    List<Account> selectStoreAccountsByParentId(Id accountRecordIds);

    /**
     * @description This method is used to query store accounts and corresponding xRef record for account dedupe logic
     * @param fieldSetToQuery
     * @param accountType
     * @param brandIds
     * @param accountIds
     * @return List<Account>
     */
    List<Account> selectMatchingAccounts(
        Schema.FieldSet fieldSetToQuery,
        Set<String> accountType,
        Set<Id> brandIds,
        Set<Id> accountIds
    );
    /**
     * @description This method is used to get store accounts by business account ID.
     * @param businessAccountId The ID of the business account.
     * @return List<Account> A list of store accounts associated with the given business account ID.
     */
    List<Account> getStoreAccountbyBusinessAccountId(Id businessAccountId);
}
