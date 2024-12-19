/**
 * @author Deloitte
 * @date 19/06/2023
 * @description Interface to add domain class methods
 */
public interface IAccountTeamMembers extends fflib_ISObjects {
    /**
     * @description Validate and throws error if there are more than one Franchise team role member in a single account Team
     * @JIRA# LEM-7300
     */
    void validateIfItsAFranchiseRoleUser();

    /**
    * @description Method to upate the Account and Work Orders Owner as Franchise Reps
    * @author rishab.goyal | 03-20-2024
    * @param accountIdsandOwnerIdsToProcess
    * @param ;
    **/
    void updateAccountAndWorkOrderOwnersasFranchiseReps(Map<Id,Id> accountIdsandOwnerIdsToProcess);
}