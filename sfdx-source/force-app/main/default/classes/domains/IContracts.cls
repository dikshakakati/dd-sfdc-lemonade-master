/**
 * @author ATG
 * @date 2022-04-11
 * @description Interface to add domain class methods
 */
public interface IContracts extends fflib_ISObjects {
    /**
     * @description activate contract
     */
    void activate();

    /**
     * @description It is used to publish notifier events on contracts withholding amendment.
     * @param existingRecords
     */
    void publishNotifierEventsOnWithholdingAmendment(Map<Id, Contract> existingRecords);

    /**
     * @description Set Quote Fields on contract on before Insert
     */
    void setQuotesFieldsOnContract();

    /**
     * @description Set Associated Accounts on the Contract with group and serialized entitlements data.
     * @param associatedAccountsWrapperList
     * @param ccpApplied
     * @param ccpAnsoFlow
     */
    void setAssociatedAccountsWithGroups(
        List<AssociatedAccountsWrapper> associatedAccountsWrapperList,
        Boolean ccpApplied,
        String ccpAnsoFlow
    );

    /**
     * @description It is used to initiate the store agreement creation for SSMO process after the contract is Activated.
     * @JIRA #LEM-14589
     */
    void initiateSSMOStoreAgreementCreationOnContracts();
    /**
     * @description It is utilized to initiate the store agreement creation for A&P Contracts once the contract is activated.
     * @JIRA #LEM-16431
     */
    void initiateAdsAndPromoStoreAgreementsCreationOnContracts();
}