/**
 * @description       :
 * @author            : Gaurav
 * @group             :
 * @last modified on  : 10-03-2024
 * @last modified by  : Gaurav
**/
public with sharing class SendEmailCmpController {
    private static final String LOG_MERCHANT_EMAIL_HANDLER = 'SendEmailCmpController';
    private static final String LOG_EMAIL_HANDLING = 'Email Handling';
    private static final String WORK_PLAN_EMAIL_STATUS = 'Email Sent';

    /**
     * @description It is used to fetch details needs to be prepopulated in the email pop up.
     * @JIRA# LEM-13576
     * @param workplanId
     * @return WorkPlanDetails
     */
    @AuraEnabled
    public static WorkPlanDetails fetchAccountDetails(String workplanId){

        List<WorkPlan> workPlans = WorkPlansSelector.newInstance().selectByWorkPlanIds(new Set<Id>{workplanId}) ;
        List<Account> storeAccounts = new List<Account>();
        String parentAccount ;
        String parentName ;
        Map<Id,WorkPlan> storeIdToWorkPlan = new Map<Id,WorkPlan>();
        Map<Id,Account> storeIdToStoreAccount = new Map<Id,Account>();


        // gets the parent account id
        if(!workPlans.isEmpty()){
            parentAccount = workPlans[0].WorkOrder.AccountId != NULL ? workPlans[0].WorkOrder.AccountId : NULL;
            parentName = workPlans[0].WorkOrder.AccountId != NULL ? workPlans[0].WorkOrder.Account.Name: NULL;
        }

        if(parentAccount != NULL){
            // gets all the store ids linked to parent business account.
            for(Account storeAccount : AccountsSelector.newInstance().selectStoreAccountsByParentId(parentAccount) ){
                storeIdToStoreAccount.put(storeAccount.Id,storeAccount);
            }
        }

        if(!storeIdToStoreAccount.isEmpty()){
            processWorkPlans(storeIdToStoreAccount, workPlans[0].Type__c, workplanId, storeIdToWorkPlan);
        }

        for(Id storeIds: storeIdToWorkPlan.keySet()){
            storeAccounts.add(storeIdToStoreAccount.get(storeIds));
        }

        WorkPlanDetails details = new WorkPlanDetails();
        details.storeAccounts = storeAccounts;
        details.businessAccountId = parentAccount;
        details.businessAccountName = parentName;
        details.storeIdToWorkPlans = storeIdToWorkPlan;
        details.isParentWorkPlan =  workPlans[0].Parent_Work_Plan__c == NULL ? true :false;
        return details;
    }

     /**
     * @description It process Work Plan and further maps them.
     * @param storeIdToStoreAccount Map<Id,Account>
     * @param workPlanType  work plan type
     * @param workplanId  work plan id
     * @param storeIdToWorkPlan   Map<Id,WorkPlan>
     */
    private static void processWorkPlans(Map<Id,Account> storeIdToStoreAccount, String workPlanType, String workplanId,  Map<Id,WorkPlan> storeIdToWorkPlan) {
        for(WorkPlan eachWorkPlan :WorkPlansSelector.newInstance().selectWorkPlansByParentWorkPlanAndStoreAccount( storeIdToStoreAccount.keySet() ,new Set<String>{workPlanType}, workplanId ) ){
            storeIdToWorkPlan.put(eachWorkPlan.WorkOrder.AccountId,eachWorkPlan);
        }
    }

    /**
     * @description generate Email Reference Id dynamically.
     * @param recordId
     * @return emailReferenceId
     */
    private static String generateRefId(string recordId) {
        String orgId = UserInfo.getOrganizationId();
        String emailReferenceId = 'ref:'
            			+ orgId.left(4) + recordId.left(5)
            			+ '.'
            			+ orgId.right(4) + recordId.right(7)
            			+ ':ref';

        return emailReferenceId;
    }

    /**
     * @description It will update the Email Reference Id.
     * @param workplanId
     */
    @AuraEnabled
    public static void updateEmailReferenceId(String workplanId){
        List<WorkPlan> workPlans = WorkPlansSelector.newInstance().selectByWorkPlanIds(new Set<Id>{workplanId});
        List<WorkPlan> listofworkPlan = new List<WorkPlan>();
        if(!workPlans.isEmpty()){
            for(WorkPlan workPlan : workPlans){
                if(workplan.Email_Reference_Id__c == null){
                    workplan.Email_Reference_Id__c  = generateRefId(workplanId);
                    listofworkPlan.add(workPlan);
                }
            }
        }
        if(!listofworkPlan.isEmpty()){
            updateRelatedWorkPlan(listofworkPlan);
        }
    }

    /**
     * @description It fires UPDATE DML statement on Parent Work Plan.
     * @param listToUpdate
     * @JIRA LEM-21243
     */
    private static void updateRelatedWorkPlan(List<WorkPlan> listToUpdate) {
        if (listToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowWorkStepUpdate = Application.UNITOFWORK.newInstance();
        uowWorkStepUpdate.registerDirty(listToUpdate);
        try {
            uowWorkStepUpdate.commitWork();
        } catch (Exception uowWorkStepUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(uowWorkStepUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_MERCHANT_EMAIL_HANDLER,
                    LOG_EMAIL_HANDLING,
                    GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(uowWorkStepUpdateException)
            );
        }
    }


     /**
     * @description wrapper class to store work plan details.
     */
    public class WorkPlanDetails{
        @AuraEnabled public List<Account> storeAccounts;
        @AuraEnabled public String businessAccountId;
        @AuraEnabled public String businessAccountName;
        @AuraEnabled public Map<Id,WorkPlan> storeIdToWorkPlans;
        @AuraEnabled public Boolean isParentWorkPlan;
    }
}