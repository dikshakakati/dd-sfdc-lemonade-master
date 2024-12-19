/**
 * @description This batchable class to update Open Lever's Predicted Incremental Sales Uplift $ from Business Recommendations.
 * @author Deloitte
 * @date 06/30/2024
 */
public class LeversDataUpdateBatch implements Database.Batchable<SObject>, Schedulable {
    /**
     * @description Called to get all open levers for the current quarter
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date currentQuarterStartDate;
        Date currentQuarterEndDate;
        Date todayDate = System.today();
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
        currentQuarterEndDate = (currentQuarterStartDate.addMonths(3) - 1);

        return new LeversSelector()
            .selectOpenLeversForCurrentQuarter(currentQuarterStartDate, currentQuarterEndDate);
    }

    /**
     * @description Called to get all open levers for the current quarter
     * @param batchableContextRef Database.BatchableContext
     * @param openLeversList List<Lever__c>
     */
    public void execute(
        Database.BatchableContext batchableContextRef,
        List<Lever__c> openLeversList
    ) {
        List<String> businessAccountIds = new List<String>();
        Set<Id> leverIds = new Set<Id>();
        Map<String, Recommendation_Business__x> vspBusinessRecommendations = new Map<String, Recommendation_Business__x>();
        List<Lever__c> activeLeversUpdateList = new List<Lever__c>();
        List<Product_Insights__c> openProductInsightsUpdateList = new List<Product_Insights__c>();
        UpdateUnitOfWorkHelper updateUnitOfWorkHelperForLevers = new UpdateUnitOfWorkHelper();
        UpdateUnitOfWorkHelper updateUnitOfWorkHelperForProductInsights = new UpdateUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork unitOfWorkInstanceForLevers = Application.UNITOFWORK.newInstance();
        fflib_ISObjectUnitOfWork unitOfWorkInstanceForProductInsights = Application.UNITOFWORK.newInstance();
        List<Database.SaveResult> leversUpdateSaveResults;

        for (Lever__c eachLever : openLeversList) {
            businessAccountIds.add(eachLever.Account__c);
        }

        List<Recommendation_Business__x> selectBusinessRecommendations;
        selectBusinessRecommendations = BusinessRecommendationsSelector.newInstance()
            .selectBusinessRecommendationsByBusinessAccountIds(businessAccountIds);

        for (Recommendation_Business__x eachRecommendation : selectBusinessRecommendations) {
            vspBusinessRecommendations.put(
                eachRecommendation.Business_Account__c + eachRecommendation.Recommendation__c,
                eachRecommendation
            );
        }
        for (Lever__c eachLever : openLeversList) {
            if (
                vspBusinessRecommendations.get(
                    eachLever.Account__c + eachLever.Solution__r.VSP_Code__c
                ) != null
            ) {
                eachLever.Predicted_Incremental_Sales__c = (vspBusinessRecommendations.get(
                        eachLever.Account__c + eachLever.Solution__r.VSP_Code__c
                    ))
                    .incremental_sales__c;
                eachLever.Lever_Points__c = (vspBusinessRecommendations.get(
                        eachLever.Account__c + eachLever.Solution__r.VSP_Code__c
                    ))
                    .points__c;
                activeLeversUpdateList.add(eachLever);
                leverIds.add(eachLever.Id);
            }
        }
        /**
         * @update Open Levers Predicted_Incremental_Sales__c and Lever_Points__c for Current Quarter
         **/
        if (activeLeversUpdateList.size() > 0) {
            unitOfWorkInstanceForLevers.registerWork(updateUnitOfWorkHelperForLevers);
            updateUnitOfWorkHelperForLevers.registerUpdate(activeLeversUpdateList);
        }
        try {
            if (activeLeversUpdateList.size() > 0) {
                unitOfWorkInstanceForLevers.commitWork();
                leversUpdateSaveResults = updateUnitOfWorkHelperForLevers.saveResults;
            }
        } catch (Exception changesFailedCommit) {
            Logger.publish(
                LogEntry.newExceptionLog(changesFailedCommit, LogEntry.SeverityLevel.HIGH)
            );
        }
        /**
         * @update related Product_Insights__c's Predicted_Sales_Uplift__c for above Levers
         **/

        if (leverIds.size() > 0) {
            updatePredictedSalesUpliftOfProductInsights(
                leverIds,
                vspBusinessRecommendations,
                openProductInsightsUpdateList,
                unitOfWorkInstanceForProductInsights,
                updateUnitOfWorkHelperForProductInsights
            );
        }

    }



    /**
     * @description update related Product_Insights__c's Predicted_Sales_Uplift__c for above Levers
     * @param leverIds
     * @param vspBusinessRecommendations
     * @param openProductInsightsUpdateList
     * @param unitOfWorkInstanceForProductInsights
     * @param updateUnitOfWorkHelperForProductInsights
     **/

    private void updatePredictedSalesUpliftOfProductInsights(
        Set<Id> leverIds,
        Map<String, Recommendation_Business__x> vspBusinessRecommendations,
        List<Product_Insights__c> openProductInsightsUpdateList,
        fflib_ISObjectUnitOfWork unitOfWorkInstanceForProductInsights,
        UpdateUnitOfWorkHelper updateUnitOfWorkHelperForProductInsights
    ) {
        List<Database.SaveResult> productInsightsUpdateSaveResults;
        for (
            Product_Insights__c eachProductInsight : ProductInsightsSelector.newInstance()
                .selectProductInsightsByLeverIdWithOpenOpportunity(leverIds)
        ) {
            if (eachProductInsight.Lever__r.Solution__r.VSP_Code__c != null) {
                eachProductInsight.Predicted_Sales_Uplift__c = (vspBusinessRecommendations.get(
                        eachProductInsight.Lever__r.Account__c +
                        eachProductInsight.Lever__r.Solution__r.VSP_Code__c
                    ))
                    .incremental_sales__c;
                openProductInsightsUpdateList.add(eachProductInsight);
            }
        }
        if (openProductInsightsUpdateList.size() > 0) {
            unitOfWorkInstanceForProductInsights.registerWork(
                updateUnitOfWorkHelperForProductInsights
            );
            updateUnitOfWorkHelperForProductInsights.registerUpdate(openProductInsightsUpdateList);
        }
        try {
            if (openProductInsightsUpdateList.size() > 0) {
                unitOfWorkInstanceForProductInsights.commitWork();
                productInsightsUpdateSaveResults = updateUnitOfWorkHelperForProductInsights.saveResults;
            }
        } catch (Exception changesFailedCommit) {
            Logger.publish(
                LogEntry.newExceptionLog(changesFailedCommit, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description Finish method to handle batch postprocessing
     * @param batchableContextRef Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContextRef) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new LeversDataUpdateBatch());
    }
}