/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Service class for Lead conversion related logic.
 */
public inherited sharing class LeadConversionService {
    /**
     * @description It initiates sObjects creation on passed manually converted Lead Ids.
     * @param manuallyConvertedLeadIds
     * @param leadToNewStoreAccount
     */
    public static void initiateSObjectsCreationOnManualLeadConversion(
        Set<Id> manuallyConvertedLeadIds,
        Map<Id, Account> leadToNewStoreAccount
    ) {
        service()
            .initiateSObjectsCreationOnManualLeadConversion(
                manuallyConvertedLeadIds,
                leadToNewStoreAccount
            );
    }

    /**
     * @description It is used to return 'Active' Contracts on the passed Opportunities
     * associated Accounts.
     * @param opportunities
     * @return Map<Id, List<Contract>>
     */
    public static Map<Id, List<Contract>> collectContractsOnAssociatedAccounts(
        List<Opportunity> opportunities
    ) {
        return service().collectContractsOnAssociatedAccounts(opportunities);
    }

    /**
     * @description It creates instance of LeadConversionServiceImpl class.
     * @return ILeadConversionService
     */
    private static ILeadConversionService service() {
        return (ILeadConversionService) Application.SERVICE.newInstance(
            ILeadConversionService.class
        );
    }
}