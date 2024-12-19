/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Interface to add Selector class methods.
 */
public interface IXrefsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Xref based on parent account id
     * @param recordId
     * @return List<Xref__c>
     */
    List<Xref__c> selectAllInAccountHierarchy(Id recordId);

    /**
     * @description This method is used for getting active Xrefs by account id
     * @param recordId
     * @return List<Xref__c>
     */
    List<Xref__c> selectActiveXrefsByAccountId(Id recordId);

    /**
     * @description This method is used for getting Xref based on Business_Reference__c
     * @param busRefIdSet
     * @return List<Xref__c>
     */
    List<Xref__c> selectAllMatchingBusinessReference(Set<Id> busRefIdSet);

    /**
     * @description This method is used for getting all Xref info needed to send the platform events.
     * @param xRefIdSet
     * @return List<Xref__c>
     */
    List<Xref__c> selectAllInfoNeededForPlatformEvent(Set<Id> xRefIdSet);

    /**
     * @description It queries Xref details based on passed Xref Ids.
     * @param xrefIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectById(Set<Id> xrefIds);

    /**
     * @description This method is used for getting Xref based on Salesforce Account Name
     * @param sfAccountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectBySalesforceAccountName(Set<Id> sfAccountIds);

    /**
     * @description This method is used for getting Drive Xrefs based on Salesforce Account Name And Franchise Account
     * @param sfAccountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectDriveDbXrefsBySalesforceAccountName(Set<Id> sfAccountIds);

    /**
     * @description It queries MDS Xrefs based on the passed Account Ids and Parent Work Order Ids.
     * @param accountIds
     * @param parentWorkOrderIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
        Set<Id> accountIds,
        Set<String> parentWorkOrderIds
    );

    /**
     * @description It is used for querying active Xrefs by matching the passed search key
     * with the External Id field.
     * @param searchKey
     * @return List<Xref__c>
     */
    List<Xref__c> selectBySearchKey(String searchKey);

    /**
     * @description This method is used for getting Xref based on Business_Reference__c where Account RecordType is Business
     * @param busRefIdSet
     * @return List<Xref__c>
     */
    List<Xref__c> selectAllMatchingBusinessReferenceForDriveDb(Set<Id> busRefIdSet);

    /**
     * @description It is used for querying active Xrefs by matching the External Id's
     * @JIRA# LEM-4723
     * @param externalIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefByExternalId(List<String> externalIds);

    /**
     * @description It is used for querying active Xrefs by matching the External Id's
     * and the passed primary vertical.
     * @param externalIds
     * @param primaryVertical
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefsByExternalIdsAndPrimaryVertical(
        List<String> externalIds,
        String primaryVertical
    );

    /**
     * @description It is used for querying Xrefs by matching the External Id's
     * @param externalIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefByExternalIdOnly(List<String> externalIds);

    /**
     * @description It is used for querying active Xrefs by matching the business reference External Id's
     * @JIRA# LEM-4723
     * @param externalIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefByBusinessReferenceExternalId(List<String> externalIds);

    /**
     * @description This method is used for getting Xrefs based on Mint store Id.
     * @param storeIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefsByStoreIds(Set<String> storeIds);

    /**
     * @description This method is used for getting Xrefs based on record Id and Coo Process.
     * @param xrefIds
     * @param cooProcessSet
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefsByIdAndCooProcess(Set<Id> xrefIds, Set<String> cooProcessSet);

    /**
     * @description This method is used for getting Xrefs based on Coo Process.
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectXrefsByCooProcess();

    /**
     * @description This method is used for getting Active Failed Xrefs
     * @param storeAccountIds
     * @return Database.QueryLocator
     */
    List<Xref__c> selectActiveFailedXrefsBySalesforceAccountName(Set<Id> storeAccountIds);

    /**
     * @description This method is used for getting Active Xrefs based on storeIds.
     * @param storeIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectActiveMDSXrefsByStoreIds(Set<Id> storeIds);

    /**
     * @description This method is used for getting Xrefs based on Mint store Id.
     * @param storeAccountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectActiveXrefsBySalesforceAccountName(Set<Id> storeAccountIds);

    /**
     * @description It is used for querying count of 'DriveDb' Xrefs with Business Reference not having
     * External Id as the passed MP Bz Id using the passed salesforce Account Ids.
     * @param salesforceAccountIds
     * @param mpBzIds
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
        Set<Id> salesforceAccountIds,
        Set<String> mpBzIds
    );

    /**
     * @description It is used for querying 'DriveDb' Xrefs with Business Reference not having
     * External Id as the passed MP Bz Id using the passed salesforce Account Ids.
     * @param salesforceAccountIds
     * @param mpBzIds
     * @param queryLimit
     * @return List<Xref__c>
     */
    List<Xref__c> selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
        Set<Id> salesforceAccountIds,
        Set<String> mpBzIds,
        Integer queryLimit
    );

    /**
     * @description It is used to retrieve Xrefs and related Business Reference by associated Store
     * Account.
     * @param storeIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectByStoreAccounts(Set<Id> storeIds);

    /**
     * @description It is used to fetch a fitered list of Store Accounts.
     * @param parentIds
     * @param filterCriteriaAndValues
     * @return List<Account>
     */
    List<Xref__c> selectByStoreAccountsAndOtherFilters(
        Set<Id> parentIds,
        Map<String, List<String>> filterCriteriaAndValues
    );

    /**
     * @description It is used for querying Xrefs with Store Accounts related to the Ultimate
     * Parent Account for brand and vertical values.
     * @param ultimateParentAccountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectByUltimateParentAccountsForBrandsAndVerticals(
        Set<Id> ultimateParentAccountIds
    );
    /**
     * @description It is used for querying Xrefs related to the passed Rate Change Request Ids.
     * @param rcrIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectRelatedRateChangeIds(Set<Id> rcrIds);

    /**
     * @description This method is used for getting Drivedb Xrefs based on Salesforce Account Name and Integration Status
     * @JIRA#LEM-12654
     * @param accIds
     * @param woCreatedDate
     * @param userIds
     * @param xrefWrapper
     * @return List<Xref__c>
     */
    List<Xref__c> selectDriveDbXrefsByAccountAndIntegrationStatus(
        Set<Id> accIds,
        DateTime woCreatedDate,
        List<String> userIds,
        NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper xrefWrapper
    );

    /**
     * @description This method is used for getting MDS Xrefs based on Salesforce Account Name and Integration Status.
     * @JIRA#LEM-12654
     * @param accIds
     * @param woCreatedDate
     * @param userIds
     * @param xrefWrapper
     * @return List<Xref__c>
     */
    List<Xref__c> selectMDSXrefsByAccountAndIntegrationStatus(
        Set<Id> accIds,
        DateTime woCreatedDate,
        List<String> userIds,
        NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper xrefWrapper
    );

    /**
     * @description It is used for querying Xref details by store Id & business Id
     * @param storeId
     * @param businessId
     * @return List<Xref__c>
     */
    List<Xref__c> selectByStoreIdAndBusinessId(string storeId, string businessId);
    /**
     * @description It is used for querying Xrefs with Store Accounts related to the Ultimate
     * Parent Account for brand and vertical values.
     * @param ultimateParentAccountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectByUltimateParentAccountsforActivationValidation(
        Set<Id> ultimateParentAccountIds
    );
    /**
     * @description It is used for querying Xrefs by matching the External Ids.
     * @param externalIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefByExternalIdsAndExternalSourceMDS(Set<String> externalIds);

    /**
     * @description It is used for querying Xrefs by matching the External Ids.
     * @param externalIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
        Set<String> externalIds
    );

    /**
     * @description It is used for querying Xrefs with Account and Business Reference having brands.
     * @param accountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectByAccountIds(Set<Id> accountIds);

    /**
     * @description It is used for getting Xrefs based on Business Ids and Store Ids.
     * @param externalIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectXrefsByBusinessReferenceExternalIdOrStoreIds(Set<String> externalIds);

    /**
     * @description
     * @param businessId
     * @param businessVertical
     * @param currencyCodes
     * @return List<Xref__c>
     **/
    List<Xref__c> selectByBusinessAccountId(
        Set<String> businessId,
        Set<String> businessVertical,
        Set<String> currencyCodes
    );

    /**
     * @description It queries 'MDS' Xrefs (both, Active & Inactive) based on the passed Salesforce Account's Ids.
     * @param salesforceAccountIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectMDSXrefsBySalesforceAccountIds(Set<Id> salesforceAccountIds);

    /**
     * @description It is used for querying Xref details by business reference Id.
     * @param businessReferenceIds
     * @return List<Xref__c>
     */
    List<Xref__c> selectActiveXrefByBusinessReferenceId(Set<Id> businessReferenceIds);
}