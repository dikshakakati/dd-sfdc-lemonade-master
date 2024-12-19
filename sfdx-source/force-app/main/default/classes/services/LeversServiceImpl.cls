/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Service Implementation class for Levers related logic.
 **/
public inherited sharing class LeversServiceImpl implements ILeversService {
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_UPDATE_INTEREST_LEVEL = 'Unexpected Error in updating the Interest Level,';

    /**
     * @description Update interest level on Levers.
     * @param productInsights
     */
    public void updateInterestLevel(List<Product_Insights__c> productInsights) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            Product_Insights__c eachProductInsight : ProductInsightsSelector.newInstance()
                .selectProductInsightsAndLeversById(
                    (new Map<Id, Product_Insights__c>(productInsights)).keySet()
                )
        ) {
            if (
                String.isNotBlank(eachProductInsight.Interest_Level__c) &&
                String.isNotBlank(eachProductInsight.Lever__c) &&
                eachProductInsight.Lever__r.Interest_Level__c !=
                eachProductInsight.Interest_Level__c
            ) {
                uow.registerDirty(
                    new Lever__c(
                        Id = eachProductInsight.Lever__c,
                        Interest_Level__c = eachProductInsight.Interest_Level__c
                    )
                );
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_INTEREST_LEVEL,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }
}