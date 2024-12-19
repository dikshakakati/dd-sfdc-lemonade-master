/**
 * @author Deloitte
 * @date 02/06/2023
 * @description It is used for sending information about contract, nintex use case
 * and list of franchise accounts to Opportunities Service Impl class.
 */
public class NintexOpportunityCreationWrapper {
    public List<String> franchiseAccountIds;
    public String contractId;
    public String useCase;
    public String daysToAdd;

    /**
     * @description Parameterized constructor to set wrapper class variables
     * for OpportunitiesServiceImpl class.
     * @param franchiseAccountIds
     * @param contractId
     * @param useCase
     * @param daysToAdd
     */
    public NintexOpportunityCreationWrapper(
        List<String> franchiseAccountIds,
        String contractId,
        String useCase,
        String daysToAdd
    ) {
        this.franchiseAccountIds = franchiseAccountIds;
        this.contractId = contractId;
        this.useCase = useCase;
        this.daysToAdd = daysToAdd;
    }
}