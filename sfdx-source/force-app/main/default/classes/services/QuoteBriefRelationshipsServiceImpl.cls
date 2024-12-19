/**
 * @author Deloitte
 * @date 03/27/2023
 * @description Service implementation class for logic related to QuoteBriefRelationship.
 */
public inherited sharing class QuoteBriefRelationshipsServiceImpl implements IQuoteBriefRelationshipsService {
    /**
     * @description It is used to create Quote Brief Relationships based on a brief to quote
     * mapping.
     * @param briefsToQuoteIds
     * @param briefsToCampaign
     */
    public void createQuoteBriefRelationshipsWithBriefToQuoteMapping(
        Map<Id, Set<Id>> briefsToQuoteIds,
        Map<Id, String> briefsToCampaign
    ) {
        fflib_ISObjectUnitOfWork unitOfWorkRelationshipCreation = Application.UNITOFWORK.newInstance();
        for (Id eachBriefId : briefsToQuoteIds.keySet()) {
            for (Id eachQuoteId : briefsToQuoteIds.get(eachBriefId)) {
                Quote_Brief_Relationship__c newQuoteBriefRelationship = new Quote_Brief_Relationship__c(
                    Quote__c = eachQuoteId,
                    Brief__c = eachBriefId,
                    Campaign_of_Brief__c = briefsToCampaign.get(eachBriefId)
                );
                unitOfWorkRelationshipCreation.registerNew(newQuoteBriefRelationship);
            }
        }
        commitUnitOfWork(unitOfWorkRelationshipCreation);
    }

    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
}