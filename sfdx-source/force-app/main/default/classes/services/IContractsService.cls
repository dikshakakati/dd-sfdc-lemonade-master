/**
 * @description Interface for Service Class of the Contract objectC
 */
public interface IContractsService {
    /**
     * @description It is used for getting corporate account ids from the payload
     * received via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    Map<Id, Contract> setContractOnParentAccount(Set<Id> parentAccountIds);

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    Map<Id, List<Contract>> setAllContractOnParentAccount(Set<Id> parentAccountIds);

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    Map<Id, List<Contract>> setMiddlewareProviderContractOnParentAccount(Set<Id> parentAccountIds);

    /**
     * @description Sets the contract on the related opportunity.
     *
     * @param contractIds
     */
    void setContractsOnRelatedOpportunities(Set<Id> contractIds);
    /**
     * @description creates the Contract Brand Association
     * @param contractOppIdMap
     */
    void createContractBrandAssociationOnContract(Map<Id, Id> contractOppIdMap);
    /**
     * @description This method stamps the MSA / Ads and Promotion indicator on the
     * Contract Name
     * @param contractIdToContractName
     */
    void stampMsaOrAdsPromoOntheContract(Map<Id, String> contractIdToContractName);
    /**
     * @description this method checks the agency on the opportunity for contracts and sets the
     * corresponding field on contract to that if it is not null
     * @param contractOppIdMap
     */
    void setAgencyFieldOnContract(Map<Id, Id> contractOppIdMap);
    /**
     * @description Sets the Quote Fields On Amended Contract
     * @param contractIds
     */
    void setQuotesFieldsOnContract(Set<Id> contractIds);
    /**
     * @description Sets the contract's Compliance Check Failure Field.
     * @param contractIdToStoreAccountName
     */

    /**
     * @description It is used to get contracts that are eligible for Work Order Creation.
     * @JIRA# LEM-15321
     * @param mxOnboardingLinks
     * @param contractIdToSubscriptionsPresent
     * @return Set<String>
     */
    Set<String> getEligibleContractsForOnboardingInputsWorkOrderCreation(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks,
        Map<Id, Set<String>> contractIdToSubscriptionsPresent
    );
}