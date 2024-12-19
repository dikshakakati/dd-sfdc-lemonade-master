/**
 * @author Deloitte
 * @date 24/11/2022
 * @description Service implementation class for Initiatives related logic.
 */
public inherited sharing class InitiativesServiceImpl implements IInitiativesService {
    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed initiatives which triggers the further processing on AccountId change on initiatives.
     * @param initiatives
     */
    public void processMergedAccountsRelatedRecords(List<Initiative__c> initiatives) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Initiative__c eachInitiative : initiatives) {
            eachInitiative.Is_Parent_Account_Merged__c = true;
            uow.registerDirty(eachInitiative);
        }
        commitUnitOfWork(uow);
    }

    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private static void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception relationshipUnitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    relationshipUnitOfWorkException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }
}