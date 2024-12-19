/**
 * @author Deloitte
 * @date 07/12/2024
 * @description Service implementation class for ShowDecisionMakersOnWorkPlanController related logic.
 */
public inherited sharing class ShowDecisionMakersOnWorkPlanServiceImpl implements IShowDecisionMakersOnWorkPlanService {
    private static final String LOG_DOMAIN_WORK_PLAN = 'WorkPlan';
    private static final String LOG_SHOW_DECISION_MAKER_SERVICE = 'ShowDecisionMakersOnWorkPlanService';
    /**
     * @description It is used to get decision maker phone details using the passed Work Plan Id.
     * @JIRA# LEM-15997
     * @param workPlanId
     * @return List<DecisionMakerWrapper>
     */
    public List<DecisionMakerWrapper> getDecisionMakerPhoneDetails(Id workPlanId) {
        Map<Id, List<AccountContactRelation>> accountContactRelations = new Map<Id, List<AccountContactRelation>>();
        Map<Id, Xref__c> accountIdToXref = new Map<Id, Xref__c>();
        Map<String, List<DecisionMakerWrapper.DecisionMakerDetails>> decisionMakerWrapperMap = new Map<String, List<DecisionMakerWrapper.DecisionMakerDetails>>();
        List<DecisionMakerWrapper> decisionMakerWrapperdetails = new List<DecisionMakerWrapper>();
        Set<Id> storeAccountIds = new Set<Id>();
        List<WorkPlan> workPlans = WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderDetailsByParentWorkPlanIds(new Set<Id>{ workPlanId });
        for (WorkPlan eachWorkPlan : workPlans) {
            if (eachWorkPlan.WorkOrder.AccountId != null) {
                storeAccountIds.add(eachWorkPlan.WorkOrder.AccountId);
            }
        }
        accountContactRelations = getAccountContactDetails(storeAccountIds);
        accountIdToXref = getXrefDetails(storeAccountIds);
        decisionMakerWrapperMap = getPhoneToDecisionMakerDetails(workPlans,accountIdToXref,accountContactRelations);
        for (String phoneNumber : decisionMakerWrapperMap.keySet()) {
            DecisionMakerWrapper decisionMakerWrapper = new DecisionMakerWrapper(
                decisionMakerWrapperMap.get(phoneNumber)[0].contactId,
                decisionMakerWrapperMap.get(phoneNumber)[0].contactName,
                decisionMakerWrapperMap.get(phoneNumber),
                phoneNumber
            );
            decisionMakerWrapperdetails.add(decisionMakerWrapper);
        }
        return decisionMakerWrapperdetails;
    }

    /**
     * @description It is used to update Number_of_Call_Attempts__c field on Work Plan.
     * @JIRA# LEM-15997
     * @param decisionMakerDetailsJSON
     */
    public static void updateNumberOfCallAttemptsOnWorkPlan(String decisionMakerDetailsJSON) {
        List<DecisionMakerWrapper.DecisionMakerDetails> childWorkPlanDetils = (List<DecisionMakerWrapper.DecisionMakerDetails>) JSON.deserialize(
            decisionMakerDetailsJSON,
            List<DecisionMakerWrapper.DecisionMakerDetails>.class
        );
        Set<Id> childWorkPlanIds = new Set<Id>();
        Map<Id, DecisionMakerWrapper.DecisionMakerDetails> decisionMakerDetailsMap = new Map<Id, DecisionMakerWrapper.DecisionMakerDetails>();
        List<WorkPlan> childWorkPlanToBeUpdated = new List<WorkPlan>();
        for (DecisionMakerWrapper.DecisionMakerDetails decisionMakerDetail : childWorkPlanDetils) {
            childWorkPlanIds.add(decisionMakerDetail.recordId);
            decisionMakerDetailsMap.put(decisionMakerDetail.recordId, decisionMakerDetail);
        }
        for (
            WorkPlan updateChildWorkPlan : WorkPlansSelector.newInstance()
                .selectById(childWorkPlanIds)
        ) {
            updateChildWorkPlan.Number_of_Call_Attempts__c = decisionMakerDetailsMap.get(
                    updateChildWorkPlan.Id
                )
                .numberCallAttempts;
            childWorkPlanToBeUpdated.add(updateChildWorkPlan);
        }
        fireWorkPlanRecordsUpdate(childWorkPlanToBeUpdated);
    }
    /**
     * @description It is used to update list of  Work Plan records .
     * @JIRA# LEM-15997
     * @param workplansToUpdate
     */
    private static void fireWorkPlanRecordsUpdate(List<WorkPlan> workplansToUpdate) {
        if (workplansToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(workplansToUpdate);
        try {
            uow.commitWork();
        } catch (Exception relationshipUnitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    relationshipUnitOfWorkException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SHOW_DECISION_MAKER_SERVICE,
                        LOG_DOMAIN_WORK_PLAN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(relationshipUnitOfWorkException)
            );
        }
    }
    /**
     * @description It will return accountContactRelations using passed storeAccountIds.
     * @JIRA# LEM-15997
     * @param storeAccountIds
     * @return Map<Id,AccountContactRelation>
     */
    private static Map<Id, List<AccountContactRelation>> getAccountContactDetails(
        Set<Id> storeAccountIds
    ) {
        Map<Id, List<AccountContactRelation>> accountContactRelations = new Map<Id, List<AccountContactRelation>>();
        for (
            AccountContactRelation eachAccountContactRelationship : AccountContactRelationsSelector.newInstance()
                .selectByAccountIds(storeAccountIds)
        ) {
            if (!accountContactRelations.isEmpty() && accountContactRelations.containsKey(eachAccountContactRelationship.AccountId)) {
                List<AccountContactRelation> eachAccountContactRelationshipDetails = accountContactRelations.get(eachAccountContactRelationship.AccountId);
                eachAccountContactRelationshipDetails.add(eachAccountContactRelationship);
                accountContactRelations.put(
                    eachAccountContactRelationship.AccountId,
                    eachAccountContactRelationshipDetails
                );
            }else{
                accountContactRelations.put(
                    eachAccountContactRelationship.AccountId,
                    new List<AccountContactRelation>{eachAccountContactRelationship}
                );
            }
        }
        return accountContactRelations;
    }
    /**
     * @description It will return accountIdToXref using passed storeAccountIds.
     * @JIRA# LEM-15997
     * @param storeAccountIds
     * @return Map<Id,Xref__c>
     */
    private static Map<Id, Xref__c> getXrefDetails(Set<Id> storeAccountIds) {
        Map<Id, Xref__c> accountIdToXref = new Map<Id, Xref__c>();
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectActiveMDSXrefsByStoreIds(storeAccountIds)
        ) {
            accountIdToXref.put(eachXref.Salesforce_Account_Name__c, eachXref);
        }
        return accountIdToXref;
    }
    /**
     * @description It will return PhoneToDecisionMakerDetails using passed workPlanDetails.
     * @JIRA# LEM-15997
     * @param workPlanDetails
     * @param accountIdToXref
     * @param accountContactRelations
     * @return Map<String, List<DecisionMakerWrapper.DecisionMakerDetails>>
     */
    private static Map<String, List<DecisionMakerWrapper.DecisionMakerDetails>> getPhoneToDecisionMakerDetails(List<WorkPlan> workPlanDetails,Map<Id, Xref__c> accountIdToXref,Map<Id, List<AccountContactRelation>> accountContactRelations) {
        Map<String, List<DecisionMakerWrapper.DecisionMakerDetails>> decisionMakerWrapperMap = new Map<String, List<DecisionMakerWrapper.DecisionMakerDetails>>();
        String storeId;
        for (WorkPlan eachChildWorkPlan : workPlanDetails) {
            if (
                !accountIdToXref.isEmpty() &&
                accountIdToXref.get(eachChildWorkPlan.WorkOrder.AccountId) != null
            ) {
                storeId = accountIdToXref.get(eachChildWorkPlan.WorkOrder.AccountId).External_ID__c;
            } else {
                storeId = '';
            }
            for(
                AccountContactRelation forEachAccountContactRelations : accountContactRelations.get(eachChildWorkPlan.WorkOrder.AccountId)
                ){
                String phoneNumber = forEachAccountContactRelations.Contact.Phone;
                if (
                    !decisionMakerWrapperMap.isEmpty() &&
                    decisionMakerWrapperMap.containsKey(phoneNumber)
                ) {
                    List<DecisionMakerWrapper.DecisionMakerDetails> decisionMakerWrapperList = decisionMakerWrapperMap.get(
                        phoneNumber
                    );
                    DecisionMakerWrapper.DecisionMakerDetails decisionMakerDetails = new DecisionMakerWrapper.DecisionMakerDetails(
                        eachChildWorkPlan.WorkOrder.Account.Name,
                        String.valueOf(forEachAccountContactRelations.Contact.Id),
                        forEachAccountContactRelations.Contact.Name,
                        Integer.valueOf(eachChildWorkPlan.Number_of_Call_Attempts__c),
                        eachChildWorkPlan.Id,
                        storeId
                    );
                    decisionMakerWrapperList.add(decisionMakerDetails);
                    decisionMakerWrapperMap.put(phoneNumber, decisionMakerWrapperList);
                } else {
                    DecisionMakerWrapper.DecisionMakerDetails decisionMakerDetails = new DecisionMakerWrapper.DecisionMakerDetails(
                        eachChildWorkPlan.WorkOrder.Account.Name,
                        String.valueOf(forEachAccountContactRelations.Contact.Id),
                        forEachAccountContactRelations.Contact.Name,
                        Integer.valueOf(eachChildWorkPlan.Number_of_Call_Attempts__c),
                        eachChildWorkPlan.Id,
                        storeId
                    );
                    decisionMakerWrapperMap.put(
                        phoneNumber,
                        new List<DecisionMakerWrapper.DecisionMakerDetails>{ decisionMakerDetails }
                    );
                }
            }
        }
        return decisionMakerWrapperMap;
    }
}