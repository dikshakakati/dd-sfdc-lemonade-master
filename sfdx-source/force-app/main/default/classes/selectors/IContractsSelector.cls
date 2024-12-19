/**
 * @author atg
 * @description Interface to add Selector class methods
 */
public interface IContractsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting object type
     * @param idSet
     * @return List<Contract> - List of Contracts
     */
    List<Contract> selectById(Set<Id> idSet);

    /**
     * @description This method is used for getting Contracts based on AccountId.
     * @param parentAccountIds
     * @return List<Contract>
     */
    List<Contract> selectByParentAccountId(Set<Id> parentAccountIds);

    /**
     * @description It is used for querying Contracts by Parent Account Ids.
     * @param parentAccountIds
     * @return List<Contract>
     */
    List<Contract> selectContractSplitCategoryByParentAccountIds(Set<Id> parentAccountIds);

    /**
     * @description This method is used for getting Contracts with Ads and Promo Subscriptions
     * @param contractIds
     * @return List<Contract>
     */
    List<Contract> selectContractsWithAdsAndPromoSubscriptions(Set<Id> contractIds);

    /**
     * @description It is used for querying 'Activated' Contracts having Payment Method
     * as 'Withholding' using the passed accountIds.
     * @param accountIds
     * @return List<Contract>
     */
    List<Contract> selectActivatedWithholdingContractsByAccountIds(Set<Id> accountIds);

    /**
     * @description This method used for querying Contracts by opportunityId.
     * @param opportunityId
     * @return List<Opportunity>
     */
    List<Contract> selectContractsByOpportunityId(Id opportunityId);

    /**
     * @description It is used for querying Contracts by account Id filtered with dynamic fields.
     * @param fieldsToQuery
     * @param parentAccountId
     * @return List<Contract>
     */
    List<Contract> selectContractsWithDynamicFields(Set<String> fieldsToQuery, Id parentAccountId);
    /**
     * @description This method is used for getting Contracts with Subscriptions
     * @JIRA# LEM-15116
     * @param contractIds
     * @return List<Contract>
     */
    List<Contract> selectContractsWithSubscriptions(Set<Id> contractIds);
    /**
     * @description It is used for querying Contracts by account Id and Split Category as core.
     * @param accountIds
     * @return List<Contract>
     */
    List<Contract> selectCoreContractsByAccountIds(Set<Id> accountIds);

    /**
     * @description It is used to get Ads and Promo Contracts by Account Ids.
     * @param accountIds
     * @return List<Contract>
     */
    List<Contract> selectAdsAndPromosContractsByAccountIds(Set<Id> accountIds);
    /**
     * @description It is used for querying Contracts by quote Id and Split Category.
     * @param quoteIds
     * @return List<Contract>
     */
    List<Contract> selectAdsAndPromosContractsByQuoteIds(Set<Id> quoteIds);

    /**
    * @description Selects contracts with related subscriptions by contract ids
    * @JIRA# LEM-17378
    * @param contractIds
    * @return List<Contract>
    **/
    List<Contract> selectContractsWithActiveSubscriptionsProducts(Set<Id> contractIds);

    /**
     * @description It is used for querying Contracts based on passed Contract Ids.
     * @param contractIds
     * @return List<Contract>
     */
    List<Contract> selectContractsWithSubscriptionsAddScenario(Set<Id> contractIds);

    /**
    * @description - select fields for contract with Active MxOnboarding
    * @author Soumya Dash | 07-18-2024
    * @param contractId
    * @return Contract
    **/
    Contract selectByIdWithMxActiveOnboarding(Id contractId);

    /**
    * @description
    * @jira LEM-17697
    * @param contractIds
    * @param sobjectToSetOfField
    * @return List<Contract>
    **/
    List<Contract> selectContractsandRelatedRecords(Set<Id> contractIds, Map<String, Set<String>> sobjectToSetOfField);

    /**
    * @description - select Contrat related fields and its mc onboarding records
    * @author Soumya Dash | 08-08-2024
    * @param contractId
    * @return Contract
    **/
    Contract selectByIdWithRESSMOSourceMxOnboarding(Id contractId);

    /**
    * @description
    * @author SamikshaDD | 08-12-2024
    * @param contractIds
    * @param fieldSet
    * @return List<Contract>
    **/
    List<Contract> selectContractByIdWithGivenFields(Set<Id> contractIds, Set<String> fieldSet);

    /**
    * @description Select Contract based on the Contract Number
    * @param contractNumbers
    * @return List<Contract>
    **/
    List<Contract> selectByContractNumber(Set<String> contractNumbers);

    /**
     * @description It is used to fetch the Contract where 'Contract Type' is "Churned Merchant".
     * @JIRA #LEM-23780
     * @return Database.QueryLocator
     **/
    Database.QueryLocator selectChurnedMxContracts();
}