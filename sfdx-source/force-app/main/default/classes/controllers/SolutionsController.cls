/**
 * @author Deloitte
 * @date 06/13/2024
 * @description This is the controller class for Solutions.
 */
public with sharing class SolutionsController {
    /**
     * @description It is used to get solutions associated to the bussiness Accounts.
     * @param createAccountPlanOrAddLeversInputVariables
     * @return List<AccountLeverEntry>
     */
    @InvocableMethod(
        label='Solutions with Predictions'
        description='Get List of Solutions with VSP Predictions'
    )
    public static List<AccountLeverEntry> getSolutionsWithPredictionsByBusinessAccounts(
        List<CreateAccountPlanOrAddLeversInputVariables> createAccountPlanOrAddLeversInputVariables
    ) {
        List<String> businessAccountIds = createAccountPlanOrAddLeversInputVariables.get(0)
            .businessAccountIds;
        String accountPlanId = createAccountPlanOrAddLeversInputVariables.get(0).accountPlanId;
        List<AccountLeverEntry> solutionsToBeReturned = new List<AccountLeverEntry>();
        List<String> vspCodes = new List<String>();
        Map<Id, Map<String, Recommendation_Business__x>> vspRecByProductNameByAccountId = new Map<Id, Map<String, Recommendation_Business__x>>();

        for (
            Recommendation_Business__x eachBusinessRecommendation : BusinessRecommendationsSelector.newInstance()
                .selectBusinessRecommendationsByBusinessAccountIds(businessAccountIds)
        ) {
            vspCodes.add(eachBusinessRecommendation.Recommendation__c);
            if (
                !vspRecByProductNameByAccountId.containsKey(
                    eachBusinessRecommendation.Business_Account__r.Id
                )
            ) {
                vspRecByProductNameByAccountId.put(
                    eachBusinessRecommendation.Business_Account__r.Id,
                    new Map<String, Recommendation_Business__x>()
                );
            }
            vspRecByProductNameByAccountId.get(eachBusinessRecommendation.Business_Account__r.Id)
                .put(eachBusinessRecommendation.Recommendation__c, eachBusinessRecommendation);
        }
        solutionsToBeReturned = getAssociatedSolutions(
            vspCodes,
            vspRecByProductNameByAccountId,
            businessAccountIds,
            accountPlanId
        );
        return solutionsToBeReturned;
    }
    /**
     * @description It is used to get associated solutions to business account.
     * @param vspCodes
     * @param vspRecByProductNameByAccountId
     * @param businessAccountIds
     * @param accountPlanId
     * @return List<AccountLeverEntry>
     */
    private static List<AccountLeverEntry> getAssociatedSolutions(
        List<String> vspCodes,
        Map<Id, Map<String, Recommendation_Business__x>> vspRecByProductNameByAccountId,
        List<String> businessAccountIds,
        String accountPlanId
    ) {
        Set<String> accountPlanWithLeversAndSolutionsSet = new Set<String>();
        List<AccountLeverEntry> solutionsToBeReturned = new List<AccountLeverEntry>();
        List<Campaign_Product__c> solutions = SolutionsSelector.newInstance()
            .selectActiveSolutionsByVSPCodes();
        if (accountPlanId != null) {
            for (
                Lever__c eachLever : LeversSelector.newInstance()
                    .selectOpenLeversByAccountPlanId(new Set<Id>{ accountPlanId })
            ) {
                accountPlanWithLeversAndSolutionsSet.add(eachLever.Solution__r.Name);
            }
        }
        if (!solutions.isEmpty()) {
            //for (String eachAccountId : businessAccountIds) {
            Date currentQuarterStartDate;
            Date currentQuarterEndDate;
            Date todayDate = System.today();
            currentQuarterStartDate = getCurrentQuarter(todayDate);
            currentQuarterEndDate = (currentQuarterStartDate.addMonths(3) - 1);
            Integer totalNumberOfDaysInTheCurrentQuarter = currentQuarterStartDate.daysBetween(
                currentQuarterStartDate.addMonths(3)
            );
            Integer remainingNumberOfDaysInTheCurrentQuarter = todayDate.daysBetween(
                currentQuarterStartDate.addMonths(3)
            );
            Id eachAccountId = businessAccountIds[0];
            AccountLeverEntry accountLevers = new AccountLeverEntry();
            accountLevers.solutions = new List<Campaign_Product__c>();
            for (Campaign_Product__c eachSolution : solutions) {
                if (
                    accountPlanWithLeversAndSolutionsSet.size() > 0 &&
                    accountPlanWithLeversAndSolutionsSet.contains(eachSolution.Name)
                ) {
                    continue;
                }
                if (
                    vspRecByProductNameByAccountId.containsKey(eachAccountId) &&
                    vspRecByProductNameByAccountId.get(eachAccountId)
                        .containsKey(eachSolution.VSP_Code__c)
                ) {
                    eachSolution.IncrementalSales__c = vspRecByProductNameByAccountId.get(
                            eachAccountId
                        )
                        .get(eachSolution.VSP_Code__c)
                        .incremental_sales__c;
                    eachSolution.Adjusted_Incr_Sales_Uplift__c = ((eachSolution.IncrementalSales__c /
                        totalNumberOfDaysInTheCurrentQuarter) *
                        remainingNumberOfDaysInTheCurrentQuarter)
                        .setScale(2);
                    eachSolution.Points__c = vspRecByProductNameByAccountId.get(eachAccountId)
                        .get(eachSolution.VSP_Code__c)
                        .Points__c;
                    eachSolution.Rank__c = vspRecByProductNameByAccountId.get(eachAccountId)
                        .get(eachSolution.VSP_Code__c)
                        .Rank__c;
                }
                accountLevers.solutions.add(eachSolution);
            }
            solutionsToBeReturned.add(accountLevers);
            //}
        }
        return solutionsToBeReturned;
    }

    /**
     * @description It is used to get current quarter of the year.
     * @param todayDate
     * @return Date
     */
    private static Date getCurrentQuarter(Date todayDate) {
        Date currentQuarterStartDate;
        Integer currentQtr = Decimal.valueOf(todayDate.month())
            .divide(3.0, 0, System.RoundingMode.UP)
            .intValue();
        Date startOfYear = date.newInstance(system.today().year(), 1, 1);
        if (currentQtr == 1) {
            currentQuarterStartDate = startOfYear;
        } else if (currentQtr == 2) {
            currentQuarterStartDate = startOfYear.addMonths(3);
        } else if (currentQtr == 3) {
            currentQuarterStartDate = startOfYear.addMonths(6);
        } else if (currentQtr == 4) {
            currentQuarterStartDate = startOfYear.addMonths(9);
        }
        return currentQuarterStartDate;
    }

    /**
     * @description It is used to get business account Id and AccountPlanId (Create Account Plan & Add Levers Flows)
     * @param businessAccountIds
     * @param accountPlanId
     */
    public class CreateAccountPlanOrAddLeversInputVariables {
        @InvocableVariable
        public List<String> businessAccountIds;

        @InvocableVariable
        public String accountPlanId;
    }
}