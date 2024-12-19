/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Interface of service class for Lead Conversion service related logic.
 */
public interface ILeadConversionService {
    /**
     * @description It initiates sObjects creation on passed manually converted Lead Ids.
     * @param manuallyConvertedLeadIds
     * @param leadToNewStoreAccount
     */
    void initiateSObjectsCreationOnManualLeadConversion(
        Set<Id> manuallyConvertedLeadIds,
        Map<Id, Account> leadToNewStoreAccount
    );

    /**
     * @description It is used to return 'Active' Contracts on the passed Opportunities
     * associated Accounts.
     * @param opportunities
     * @return List<Contract>
     */
    Map<Id, List<Contract>> collectContractsOnAssociatedAccounts(List<Opportunity> opportunities);
}