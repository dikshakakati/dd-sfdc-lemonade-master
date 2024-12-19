/**
 * @description       :
 * @author            : Gaurav
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : Gaurav
**/
public with sharing class ActivityTrackerComponentController {

    private static final String LOG_UPDATE_EMAIL_MESSAGE = 'Update Email Message Is_Message_Seen__c';
    private static final String LOG_DOMAIN = 'Rescue';


    /**
     * @description It is used to fetch details needs to be prepopulated in the email pop up.
     * @JIRA# LEM-13576
     * @param workplanId
     * @return List<EmailMessageDetails>
     */
    @AuraEnabled(cacheable=true)
    public static List<EmailMessageDetails> fetchActivityDetails(String workplanId){

        String parentAccount ;
        Set<Id> storeIds = new Set<Id>();
        Map<Id,List<EmailMessage>> storeIdToEmailMessages = new Map<Id,List<EmailMessage>>();
        Map<Id,String> storeIdToStoreName = new Map<Id,String>();
        List<EmailMessageDetails> messageDetaiList = new List<EmailMessageDetails>();

        // fetches all the workplan details, work order id, account id and etc.
        List<WorkPlan> workPlans = WorkPlansSelector.newInstance().selectByWorkPlanIds(new Set<Id>{workplanId}) ;

        // gets the parent account id
        if(!workPlans.isEmpty()){
            parentAccount = workPlans[0].WorkOrder.AccountId != NULL ? workPlans[0].WorkOrder.AccountId : NULL;
        }

        // gets all the store ids linked to parent business account.
        if(parentAccount != NULL){
            for(Account storeAccount : AccountsSelector.newInstance().selectStoreAccountsByParentId(parentAccount) ){
                storeIds.add(storeAccount.Id);
            }
        }

        Map<Id,WorkPlan> workPlanMap = new Map<Id,WorkPlan>(WorkPlansSelector.newInstance().selectWorkPlansByParentWorkPlanAndStoreAccount(storeIds ,new Set<String>{workPlans[0].Type__c}, workplanId));
        // fetches all the email messages linked to respective store accounts and further maps to wrapper.
        for(EmailMessage emailMessages: EmailMessagesSelector.newInstance().selectEmailMessagesByRelatedId(workPlanMap.keySet())){
            if(!storeIdToEmailMessages.containsKey( workPlanMap.get(emailMessages.RelatedToId).WorkOrder.AccountId )){
                storeIdToEmailMessages.put(workPlanMap.get(emailMessages.RelatedToId).WorkOrder.AccountId , new List<EmailMessage>());
                storeIdToStoreName.put( workPlanMap.get(emailMessages.RelatedToId).WorkOrder.AccountId , workPlanMap.get(emailMessages.RelatedToId).WorkOrder.Account.Name );
            }
            storeIdToEmailMessages.get( workPlanMap.get(emailMessages.RelatedToId).WorkOrder.AccountId ).add(emailMessages);
        }

        for(Id storeId :storeIdToEmailMessages.keySet()){
            EmailMessageDetails emailDetailWrapper = new EmailMessageDetails();
            emailDetailWrapper.accountName = storeIdToStoreName.get(storeId);
            emailDetailWrapper.accountId = storeId;
            emailDetailWrapper.emailMessages = storeIdToEmailMessages.get(storeId);
            messageDetaiList.add(emailDetailWrapper);
        }

        return messageDetaiList;
    }

    /**
     * @description It is used to update the "Is_Message_Seen__c" field to true for the email message record.
     * @JIRA# LEM-13576
     * @param emailMessageId
     * @return boolean
     */
    @AuraEnabled
    public static Boolean updateEmailMessageToOpened(String emailMessageId){
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerDirty(
            new EmailMessage(Id = emailMessageId, Is_Message_Seen__c = true)
        );
        try {
            uow.commitWork();
            return true;
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(LOG_UPDATE_EMAIL_MESSAGE,LOG_DOMAIN,GenericLogEntry.SeverityLevel.HIGH).logException(ex)
            );
            return false;
        }

    }

    /**
     * @description wrapper class to email message details.
     */
    public class EmailMessageDetails{
        @AuraEnabled public String accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public List<EmailMessage> emailMessages;
    }

}