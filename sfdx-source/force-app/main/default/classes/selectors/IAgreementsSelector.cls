/**
 * @author atg
 * @date 05/23/2022
 * @description Interface for Agreement__c selector class methods.
 */
public interface IAgreementsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectById(Set<Id> idSet);

    /**
     * @description This method is used to fetch the Agreements with Parent Account Id
     * @param parentAccountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectAgreementsByParentAccounts(Set<Id> parentAccountIds);
    /**
     * @description This method is used to fetch the Agreements with Account Id
     * @param accountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectAgreementsByAccounts(Set<Id> accountIds);
    /**
     * @description This method is used to fetch the Store Agreements with Account Id
     * @param accountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectStoreAgreementsByAccountIds(Set<Id> accountIds);

    /**
     * @description This method is used to fetch the Store Agreements by Contract Id that are not deaactivated
     * @param contractIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAgreementsByContractIds(Set<Id> contractIds);

    /**
     * @description This method is used to fetch the Opportunity information for the Store Agreements by Id
     * @param idSet
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectOpportunityInfoByIds(Set<Id> idSet);

    /**
     * @description This method is used to fetch the Store Agreements by Store Accounts Ninxtex Id
     *               that are not deaactivated
     * @param storeMarketPlaceNinxtexIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectAgreementsByMarketplaceNintexIds(
      Set<String> storeMarketPlaceNinxtexIds
    );

    /**
     * @description This method is used to fetch the Store Agreements by Contract Id that are associated to a Account
     * @param contractIds
     * @param accountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectAgreementsByContractAndAccount(
      Set<Id> contractIds,
      Set<Id> accountIds
    );

    /**
     * @description It is used for querying count of Franchise Accounts not having Payment Method
     * as 'Withholding' associated with 'Active' Agreement using the passed Corporate Account Ids.
     * @param corporateAccountIds
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
      Set<Id> corporateAccountIds
    );

    /**
     * @description It is used for querying 'Active' Franchise Agreements with Franchise Accounts
     * not having Payment Method as 'Withholding' using the passed Corporate Account Ids.
     * @param corporateAccountIds
     * @param queryLimit
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectNonWithholdingFranchiseAccountsByActiveAgreements(
      Set<Id> corporateAccountIds,
      Integer queryLimit
    );

    /**
     * @description It is used for querying 'Active' Franchise Agreements with Contracts
     * having Payment Method as 'Withholding' using the passed Corporate Account Ids.
     * @param corporateAccountIds
     * @param queryLimit
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectWithholdingCorporateAccountsByActiveAgreements(
      Set<Id> corporateAccountIds,
      Integer queryLimit
    );

    /**
     * @description It is used for querying 'Active' Franchise Agreements
     * using the passed Contract Ids.
     * @param contractIds
     * @param queryLimit
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveFranchiseAgreementsByContractIds(
      Set<Id> contractIds,
      Integer queryLimit
    );

    /**
     * @description This method is used to fetch the Store Agreements with RCR Id
     * @param rcrIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectStoreAgreementsByRcrIds(Set<Id> rcrIds);

    /**
     * @description This method is used to fetch the Store Agreements by account Id that are not deaactivated
     * @param accountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAgreementsByaccountIds(Set<Id> accountIds);

    /**
     * @description This method is used to fetch the Store Agreements by Agreement Id that are not deactivated
     * @param agreementIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectStoreAgreementsByIds(Set<Id> agreementIds);
    /**
     * @description This method is used to fetch the Store Agreements by account Id that are ACTIVE and CANCELLED
     * @param accountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAndCancelledAgreementsByAccountIds(
      Set<Id> accountIds
    );

    /** @description This method is used to fetch the Store Agreements by account Id that are not deaactivated
     * @description It is used for querying count of stores
     * @JIRA# LEM-15403
     * @param accountID
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfStoresAccountsByStoreAgreements(Id accountID);

    /**
     * @description This method is used to fetch the Store Agreements by account Id that are not deaactivated
     * @param accountIds
     * @param contractId
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAgreementsByAccountContractIds(
      Set<Id> accountIds,
      Id contractId
    );

    /**
     * @description This method is used to fetch the Store Agreements by Contract Id.
     * @param contractIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAgreementsByCoreContractIds(
      Set<Id> contractIds
    );

    /**
     * @description This method is used to fetch the Store Agreements by Ads and Promos Contract Ids.
     * @param contractIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAgreementsByAdsPromosContractIds(
      Set<Id> contractIds
    );
    /**
     * @description This method is used to fetch the Agreements by Account Ids.
     * @param accountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectAgreementsByAccountsIds(Set<Id> accountIds);
    /**
     * @description It is used to fetch the Active Store Agreements based on Contract Ids.
     * @param contractIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveStoreAgreementsByContractIds(Set<Id> contractIds);

    /**
     * @description This method is used to fetch the Store Agreements of type Core by store account Ids for SMB.
     * @param storeAccountIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectActiveAgreementsAndCoreContractsByStoreAccountIds(Set<Id> storeAccountIds);

    /**
     * @description It is used to fetch the Agreements by the passed churned merchant
     * contract Ids.
     * @param contractIds
     * @return List<Agreement__c>
     */
    List<Agreement__c> selectChurnedMxAgreementsByContractIds(Set<Id> contractIds);
  }