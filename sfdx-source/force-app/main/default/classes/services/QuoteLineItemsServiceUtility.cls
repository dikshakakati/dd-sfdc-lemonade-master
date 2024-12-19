/**
 * @author Aethereus
 * @date   11th Sep 2024
 * @description This is a utility class for QuoteLineItemsServiceImp runs in without sharing context
 */
public without sharing class QuoteLineItemsServiceUtility {

     /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private static void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description LEM-13065 Delete Brief Items before delete an associated Quote Line.
     * @param existingQuoteLines
     */
    public static void deleteBriefItemBeforeQuoteLineIsDeletedImpl(List<SBQQ__QuoteLine__c> existingQuoteLines){
       List<Brief_Item__c> briefItemIdsToBeDeleted = new List<Brief_Item__c>();
       fflib_ISObjectUnitOfWork uow = APPLICATION.UNITOFWORK.newInstance();

        for(SBQQ__QuoteLine__c currentQuoteLine : existingQuoteLines){
            if(currentQuoteLine.Brief_Item__c != null){
                briefItemIdsToBeDeleted.add(new Brief_Item__c(Id = currentQuoteLine.Brief_Item__c));
            }
        }
        if(!briefItemIdsToBeDeleted.isEmpty()){
            uow.registerDeleted(briefItemIdsToBeDeleted);
        }
		commitUnitOfWork(uow);
    }
}