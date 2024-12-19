/**
 * @author Deloitte
 * @date 04/26/2024
 * @description Domain Class for EmailMessage Object.
 */
@SuppressWarnings(
    'PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength, PMD.StdCyclomaticComplexity'
)
public inherited sharing class EmailMessages extends fflib_SObjects implements IEmailMessages {
    fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final String LEAD = 'Lead';
    private static final String LOG_MERCHANT_EMAIL_HANDLER = 'createEmailReferenceMapping';
    private static final String LOG_EMAIL_HANDLING = 'Email Reference Mapping Handling';

    private static final String WORK_PLAN_EMAIL_SENT_STATUS = 'Email Sent';
    private static final String WORK_PLAN_EMAIL_RESPONSE_STATUS = 'Response Received';
    private static final String WORK_PLAN_TYPE = 'Onboarding';
    private static Boolean incoming = false;
    /**
     * @description This method is used to return the IEmailMessage interface
     * @param recordList - Orders record list
     * @return IEmailMessages - Returns IEmailMessages Interface
     */
    public static IEmailMessages newInstance(List<EmailMessage> recordList) {
        return (IEmailMessages) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public EmailMessages(List<EmailMessage> sObjectList) {
        super(sObjectList, Schema.EmailMessage.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of EmailMessage domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of EmailMessage
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (EmailMessages.constructorMock != null) {
                return (fflib_ISObjects) EmailMessages.constructorMock.construct(objects);
            }
            return new EmailMessages((List<EmailMessage>) objects);
        }
    }

    /**
     * @description It is used to update Email Count when EmailMessages are Inserted
     */
    public void updateEmailCountWhenEmailMessageInserted() {
        Map<Id, Integer> opportunityIdWithEmailCount = new Map<Id, Integer>();
        Map<Id, Integer> opportunityIdWithEmailCountForActivity = new Map<Id, Integer>();
        Map<Id, Integer> relationIdWithCountForSObject = new Map<Id, Integer>();
        Set<Id> emailMessageIds = new Set<Id>();

        for (EmailMessage email : (List<EmailMessage>) getRecords()) {
            emailMessageIds.add(email.id);
            if (
                email.RelatedToId != null &&
                email.Incoming == false &&
                email.RelatedToId.getsObjectType() == Opportunity.SObjectType
            ) {
                if (!opportunityIdWithEmailCount.containsKey(email.RelatedToId)) {
                    opportunityIdWithEmailCount.put(email.RelatedToId, 0);
                }
                opportunityIdWithEmailCount.put(
                    email.RelatedToId,
                    opportunityIdWithEmailCount.get(email.RelatedToId) + 1
                );
            } else if (
                email.RelatedToId != null &&
                email.RelatedToId.getsObjectType() == Opportunity.SObjectType
            ) {
                if (!opportunityIdWithEmailCountForActivity.containsKey(email.RelatedToId)) {
                    opportunityIdWithEmailCountForActivity.put(email.RelatedToId, 0);
                }
                opportunityIdWithEmailCountForActivity.put(
                    email.RelatedToId,
                    opportunityIdWithEmailCountForActivity.get(email.RelatedToId) + 1
                );
            }
        }

        relationIdWithCountForSObject = updatereLationIdWithCountForSObject(emailMessageIds);
        if (!relationIdWithCountForSObject.isEmpty()) {
            updateEmailCountOnLead(relationIdWithCountForSObject, uow);
            updateEmailCountOnContact(relationIdWithCountForSObject, uow);
        }
        if (
            !opportunityIdWithEmailCount.isEmpty() ||
            !opportunityIdWithEmailCountForActivity.isEmpty()
        ) {
            updateEmailCountOnOpportunity(
                opportunityIdWithEmailCount,
                uow,
                opportunityIdWithEmailCountForActivity
            );
        }

        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Called to perform update LationIdWithCountForSObject Map
     * @param emailMessageIds
     * @return Map<Id, Integer>
     */
    private static Map<Id, Integer> updatereLationIdWithCountForSObject(Set<Id> emailMessageIds) {
        Map<Id, Integer> relationIdWithCountForSObject = new Map<Id, Integer>();
        for (
            EmailMessageRelation emailMessageRelation : EmailMessageRelationsSelector.newInstance()
                .selectByEmailMessageIds(emailMessageIds)
        ) {
            if (emailMessageRelation.RelationId != null) {
                if (!relationIdWithCountForSObject.containsKey(emailMessageRelation.RelationId)) {
                    relationIdWithCountForSObject.put(emailMessageRelation.RelationId, 0);
                }
                relationIdWithCountForSObject.put(
                    emailMessageRelation.RelationId,
                    relationIdWithCountForSObject.get(emailMessageRelation.RelationId) + 1
                );
            }
        }
        return relationIdWithCountForSObject;
    }

    /**
     * @description Called to perform updateEmailCount, First & last Activity field on Lead
     * @param relationIdWithCountForLead - Map with Lead Id and new EmailMessage Related to that Lead
     * @param uow
     */
    private static void updateEmailCountOnLead(
        Map<Id, Integer> relationIdWithCountForLead,
        fflib_ISobjectUnitOfWork uow
    ) {
        DateTime firstQualifiedActivity;

        if (!hasRelevantObjectTypes(relationIdWithCountForLead.keySet(), Schema.Lead.SObjectType)) {
            return;
        }

        for (
            Lead eachLead : LeadsSelector.newInstance()
                .selectById(relationIdWithCountForLead.keySet())
        ) {
            decimal countOfEmailSent = eachLead.Count_of_Emails_Sent__c == null
                ? relationIdWithCountForLead.get(eachLead.Id)
                : eachLead.Count_of_Emails_Sent__c + relationIdWithCountForLead.get(eachLead.Id);
            firstQualifiedActivity = (eachLead.First_Qualified_Activity__c == null)
                ? System.now()
                : eachLead.First_Qualified_Activity__c;
            uow.registerDirty(
                new Lead(
                    Id = eachLead.Id,
                    Count_of_Emails_Sent__c = countOfEmailSent,
                    First_Qualified_Activity__c = firstQualifiedActivity,
                    Last_Qualified_Activity__c = System.now()
                )
            );
        }
    }
    /**
     * @description Called to perform updateEmailCount field on Contact
     * @param relationIdWithCountForContact - Map with Contact Id and new EmailMessage Related to that Contact
     * @param uow
     */
    private static void updateEmailCountOnContact(
        Map<Id, Integer> relationIdWithCountForContact,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (!hasRelevantObjectTypes(relationIdWithCountForContact.keySet(), Schema.Contact.SObjectType)) {
            return;
        }

        for (
            Contact eachContact : ContactsSelector.newInstance()
                .selectById(relationIdWithCountForContact.keySet())
        ) {
            Decimal countOfEmailSent = eachContact.Count_of_Emails_Sent__c == null
                ? relationIdWithCountForContact.get(eachContact.Id)
                : eachContact.Count_of_Emails_Sent__c +
                  relationIdWithCountForContact.get(eachContact.Id);
            uow.registerDirty(
                new Contact(Id = eachContact.Id, Count_of_Emails_Sent__c = countOfEmailSent)
            );
        }
    }
    /**
     * @description Called to perform updateEmailCount field on Opportunity
     * @param opportunityIdWithEmailCount
     * @param uow
     * @param opportunityIdWithEmailCountForActivity
     */
    private static void updateEmailCountOnOpportunity(
        Map<Id, Integer> opportunityIdWithEmailCount,
        fflib_ISobjectUnitOfWork uow,
        Map<Id, Integer> opportunityIdWithEmailCountForActivity
    ) {
        if (!opportunityIdWithEmailCountForActivity.isEmpty()) {
            opportunityIdWithEmailCount = opportunityIdWithEmailCountForActivity;
        }
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectById(opportunityIdWithEmailCount.KeySet())
        ) {
            decimal countOfEmailSent = eachOpportunity.Count_of_Emails_Sent__c == null
                ? 0
                : eachOpportunity.Count_of_Emails_Sent__c;

            if (opportunityIdWithEmailCountForActivity.isEmpty()) {
                countOfEmailSent = eachOpportunity.Count_of_Emails_Sent__c == null
                    ? opportunityIdWithEmailCount.get(eachOpportunity.Id)
                    : eachOpportunity.Count_of_Emails_Sent__c +
                      opportunityIdWithEmailCount.get(eachOpportunity.Id);
            }

            DateTime firstQualifiedActivity;
            if (eachOpportunity.First_Activity__c == null) {
                firstQualifiedActivity = System.Now();
            } else {
                firstQualifiedActivity = eachOpportunity.First_Activity__c;
            }
            uow.registerDirty(
                new Opportunity(
                    Id = eachOpportunity.Id,
                    Count_of_Emails_Sent__c = countOfEmailSent,
                    First_Activity__c = firstQualifiedActivity,
                    Last_Activity__c = System.Now()
                )
            );
        }
    }

    /**
     * @description It is used to fetch the opportunityIdToEmailMessageRelation and
     * leadIdToEmailMessageRelation maps
     * @param emailMessageRelations
     * @param opportunityIdToEmailMessageRelation
     * @param leadIdToEmailMessageRelation
     */
    private static void fetchOpportunitiesAndLeadtoEmailMessageRelations(
        List<EmailMessageRelation> emailMessageRelations,
        Map<Id, EmailMessageRelation> opportunityIdToEmailMessageRelation,
        Map<Id, EmailMessageRelation> leadIdToEmailMessageRelation
    ) {
        for (EmailMessageRelation eachEmailRelation : emailMessageRelations) {
            if (
                eachEmailRelation.EmailMessage.RelatedToId != null &&
                eachEmailRelation.EmailMessage.RelatedToId.getsObjectType() ==
                Opportunity.SObjectType
            ) {
                opportunityIdToEmailMessageRelation.put(
                    eachEmailRelation.RelationId,
                    eachEmailRelation
                );
            } else if (
                eachEmailRelation.RelationObjectType != null &&
                eachEmailRelation.RelationObjectType == LEAD
            ) {
                leadIdToEmailMessageRelation.put(eachEmailRelation.RelationId, eachEmailRelation);
            }
        }
    }
    /**
     * @description It is used to update the Last Received Email Date on Opportunity and Lead
     * when an Email message is received.
     */
    public void setLastEmailReceivedDate() {
        Map<Id, EmailMessage> emailMessages = new Map<Id, EmailMessage>(
            (List<EmailMessage>) getRecords()
        );
        List<EmailMessageRelation> emailMessageRelations = EmailMessageRelationsSelector.newInstance()
            .selectByEmailMessageIds(emailMessages.keySet());
        Map<Id, EmailMessageRelation> opportunityIdToEmailMessageRelation = new Map<Id, EmailMessageRelation>();
        Map<Id, EmailMessageRelation> leadIdToEmailMessageRelation = new Map<Id, EmailMessageRelation>();

        fetchOpportunitiesAndLeadtoEmailMessageRelations(
            emailMessageRelations,
            opportunityIdToEmailMessageRelation,
            leadIdToEmailMessageRelation
        );
        if (!opportunityIdToEmailMessageRelation.isEmpty()) {
            for (
                Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                    .selectById(opportunityIdToEmailMessageRelation.keySet())
            ) {
                if (
                    opportunityIdToEmailMessageRelation.get(eachOpportunity.Id)
                        .EmailMessage.Incoming
                ) {
                    eachOpportunity.Last_Email_Received_Date__c = Date.today();
                    uow.registerDirty(eachOpportunity);
                }
            }
        }
        if (!leadIdToEmailMessageRelation.isEmpty()) {
            for (
                Lead eachLead : LeadsSelector.newInstance()
                    .selectById(leadIdToEmailMessageRelation.keySet())
            ) {
                if (leadIdToEmailMessageRelation.get(eachLead.Id).EmailMessage.Incoming) {
                    eachLead.Last_Email_Received_Date__c = Date.today();
                    uow.registerDirty(eachLead);
                }
            }
        }
        try {
            uow.commitWork();
        } catch (Exception exp) {
            Logger.publish(LogEntry.newExceptionLog(exp, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to update Parent Work Plan Related
     * to email when EmailMessages are Inserted
     * @JIRA LEM-21243
     */
    public void updateWorkPlanWhenEmailMessageInserted() {
        Set<Id> childWorkPlanIds = extractChildWorkPlanIds();

        // Not every Email will be related to WorkPlans, so exit early when possible
        if (childWorkPlanIds.isEmpty()) {
            return;
        }

        List<WorkPlan> childWorkPlans = WorkPlansSelector.newInstance()
            .selectByWorkPlanIds(childWorkPlanIds);

        if (childWorkPlans.isEmpty()) {
            return;
        }

        Set<Id> parentWorkPlanIds = extractParentWorkPlanIds(childWorkPlans);
        if (!parentWorkPlanIds.isEmpty()) {
            List<WorkPlan> parentWorkPlans = WorkPlansSelector.newInstance()
                .selectByWorkPlanIds(parentWorkPlanIds);

            List<WorkPlan> parentWorkPlansToUpdate = updateParentWorkPlans(parentWorkPlans);

            if (!parentWorkPlansToUpdate.isEmpty()) {
                updateRelatedWorkPlan(parentWorkPlansToUpdate);
            }

            Set<Id> workOrderIds = extractWorkOrderIds(parentWorkPlans);
            if (!workOrderIds.isEmpty()) {
                updateWorkOrders(workOrderIds);
            }
        }
    }

    private Set<Id> extractChildWorkPlanIds() {
        Set<Id> childWorkPlanIds = new Set<Id>();
        for (EmailMessage email : (List<EmailMessage>) getRecords()) {
            if (
                email.RelatedToId != null &&
                email.RelatedToId.getSObjectType() == WorkPlan.SObjectType
            ) {
                incoming = email.Incoming;
                childWorkPlanIds.add(email.RelatedToId);
            }
        }
        return childWorkPlanIds;
    }

    private Set<Id> extractParentWorkPlanIds(List<WorkPlan> childWorkPlans) {
        Set<Id> parentWorkPlanIds = new Set<Id>();
        for (WorkPlan cWorkPlan : childWorkPlans) {
            if (cWorkPlan.Parent_Work_Plan__c != null) {
                parentWorkPlanIds.add(cWorkPlan.Parent_Work_Plan__c);
            }
        }
        return parentWorkPlanIds;
    }

    private List<WorkPlan> updateParentWorkPlans(List<WorkPlan> parentWorkPlans) {
        List<WorkPlan> parentWorkPlansToUpdate = new List<WorkPlan>();
        for (WorkPlan pWorkPlan : parentWorkPlans) {
            if (incoming == false) {
                pWorkPlan.Rescue_Email_Status__c = WORK_PLAN_EMAIL_SENT_STATUS;
                parentWorkPlansToUpdate.add(pWorkPlan);
            }
        }
        return parentWorkPlansToUpdate;
    }

    private Set<Id> extractWorkOrderIds(List<WorkPlan> parentWorkPlans) {
        Set<Id> workOrderIds = new Set<Id>();
        for (WorkPlan pWorkPlan : parentWorkPlans) {
            if (pWorkPlan.Type__c == WORK_PLAN_TYPE && pWorkPlan.WorkOrderId != null) {
                workOrderIds.add(pWorkPlan.WorkOrderId);
            }
        }
        return workOrderIds;
    }

    private void updateWorkOrders(Set<Id> workOrderIds) {
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectById(workOrderIds);
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();

        for (WorkOrder wo : workOrders) {
            if (incoming == false) {
                wo.WO_Email_Status__c = WORK_PLAN_EMAIL_SENT_STATUS;
                workOrdersToUpdate.add(wo);
            }
        }

        if (!workOrdersToUpdate.isEmpty()) {
            updateRelatedWorkOrder(workOrdersToUpdate);
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
     * @description It fires UPDATE DML statement on Parent Work Order.
     * @param listToUpdate
     * @JIRA LEM-21243
     */
    private static void updateRelatedWorkOrder(List<WorkOrder> listToUpdate) {
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
     * @description Returns `true` if the Set has the expected type of record IDs.
     *              This helper method allows our logic to stay generic without consuming
     *              unnecessary queries.
     * @param setOfIds
     * @param sobjectType
     * @return Boolean
     */
    @TestVisible
    private static Boolean hasRelevantObjectTypes(
        Set<Id> setOfIds,
        Schema.SObjectType sobjectType
    ) {
        if (setOfIds != null && !setOfIds.isEmpty()) {
            for (Id thisId : setOfIds) {
                if (thisId.getSObjectType() == sobjectType) {
                    return true; // Return true if there are ANY of the same members in the set
                }
            }
        }

        return false;
    }
}