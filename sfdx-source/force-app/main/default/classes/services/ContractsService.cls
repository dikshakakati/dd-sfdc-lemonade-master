/**
 * @author Deloitte
 * @date 17/06/2022
 * @description Service Class for Contract Object
 */
public with sharing class ContractsService implements IHandleNotifierEvents {
    /**
     * @description It is used for getting corporate account ids from the payload
     * received via Platform Event.
     * @JIRA# LEM-10617
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    public static Map<Id, Contract> setContractOnParentAccount(Set<Id> parentAccountIds) {
        return service().setContractOnParentAccount(parentAccountIds);
    }

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    public static Map<Id, List<Contract>> setAllContractOnParentAccount(Set<Id> parentAccountIds) {
        return service().setAllContractOnParentAccount(parentAccountIds);
    }

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    public static Map<Id, List<Contract>> setMiddlewareProviderContractOnParentAccount(
        Set<Id> parentAccountIds
    ) {
        return service().setMiddlewareProviderContractOnParentAccount(parentAccountIds);
    }

    /**
     * @description Sets the contract on the related opportunity.
     *
     * @param contractIds
     */
    public static void setContractsOnRelatedOpportunities(Set<id> contractIds) {
        service().setContractsOnRelatedOpportunities(contractIds);
    }

    /**
     * @description It creates instance of ContractsServiceImpl class.
     * @return IContractsService - return instance of ContractsServiceImpl
     */
    private static IContractsService service() {
        return (IContractsService) Application.SERVICE.newInstance(IContractsService.class);
    }
    /**
     * @description 1) Sets the contract brand association by copying the opportunity's brand
     * association. 2) Sets the Contract Name to
     *    "Brand Name 1" if only one brand exists.
     *    "Brand Name 1, Brand Name 2" for 2 brands
     *    "Brand Name 1, Brand Name 2, etc..." for over 2 brands
     *
     * @param contractOppIdMap
     */
    public static void createContractBrandAssociationOnContract(Map<Id, Id> contractOppIdMap) {
        service().createContractBrandAssociationOnContract(contractOppIdMap);
    }
    /**
     * @description This method stamps the MSA / Ads and Promotion indicator on the Contract name
     * @param contractIdToContractName
     */
    public static void stampMsaOrAdsPromoOntheContract(Map<Id, String> contractIdToContractName) {
        service().stampMsaOrAdsPromoOntheContract(contractIdToContractName);
    }
    /**
     * @description this method checks the agency on the opportunity for contracts and sets the
     * corresponding field on contract to that if it is not null
     * @param contractOppIdMap
     */
    public static void setAgencyFieldOnContract(Map<Id, Id> contractOppIdMap) {
        service().setAgencyFieldOnContract(contractOppIdMap);
    }
    /**
     * @description Sets the Quote Fields On Amended Contract
     * @param contractIds
     */
    public static void setQuotesFieldsOnContract(Set<Id> contractIds) {
        service().setQuotesFieldsOnContract(contractIds);
    }

    /**
     * @description It is used to get contracts that are eligible for Work Order Creation.
     * @JIRA# LEM-15321
     * @param mxOnboardingLinks
     * @param contractIdToSubscriptionsPresent
     * @return Set<String>
     */
    public static Set<String> getEligibleContractsForOnboardingInputsWorkOrderCreation(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks,
        Map<Id, Set<String>> contractIdToSubscriptionsPresent
    ) {
        return service()
            .getEligibleContractsForOnboardingInputsWorkOrderCreation(
                mxOnboardingLinks,
                contractIdToSubscriptionsPresent
            );
    }
}