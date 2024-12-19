/**
 * @author Deloitte
 * @date 11/22/2022
 * @description Service implementation class for merchant support inbound email related logic.
 */
public inherited sharing class MerchantSupportInboundEmailServiceImpl implements IMerchantSupportInboundEmailService {
    private static final String COMMA_SEPARATOR = ',';
    private static final String EMAIL_MESSAGE_METHOD_NAME = 'createEmailMessagesOnWorkOrders';
    private static final String EMAIL_MESSAGE_DEFAULT_STATUS_STATIC_CONFIG_NAME = 'Inbound_Email_Message_Status';
    private static final String EMAIL_REFERENCE_ID_END_KEYWORD = ':ref';
    private static final String EMAIL_REFERENCE_ID_START_KEYWORD = 'ref:';
    private static final String FORMAT_EMAIL_FROM_ADDRESS_VIA_KEYWORD = ' via ';
    private static final String FORMAT_EMAIL_FROM_ADDRESS_SINGLE_QUOTE = '\'';
    private static final String INVALID_REFERENCE_ID_ERROR = 'Inbound Email is received with invalid Reference Id in subject: ';



    private String emailMessageDefaultStatus;
    private Set<String> emailReferenceIds;
    private Map<String, Id> emailReferenceIdToWorkOrderId;
    private static final String LOG_MERCHANT_EMAIL_HANDLER = 'MerchantSupportInboundEmailServiceImpl';
    private static final String LOG_EMAIL_HANDLING = 'Email Handling';
    private Map<String, Id> emailReferenceIdToWorkPlanId;
    private static Set<String> workPlanIds = new Set<String>();
    private static Boolean updateWorkSteps = false;
    private Id attachmentLinkId;
    private boolean hasAttachment = false;
    public static final String FAILURE_EMAIL_ALERT = System.label.Inbound_Thread_Failure_Response_Email_Alert;
    public static final String FAILURE_EMAIL_ALERT_CONTACT = System.label.Email_Thread_Failure_Response_Contact_ID;
    private static final String WORK_STEP_STATUS = 'Resolved';
    private static final String WORK_PLAN_EMAIL_SENT_STATUS = 'Email Sent';
    private static final String WORK_PLAN_EMAIL_RESPONSE_STATUS = 'Response Received';
    private static final String WORK_PLAN_TYPE = 'Onboarding';

    /**
     * @description Default Constructor to initialize class variables.
     */
    public MerchantSupportInboundEmailServiceImpl() {
        emailReferenceIds = new Set<String>();
        emailReferenceIdToWorkOrderId = new Map<String, Id>();
        emailReferenceIdToWorkPlanId = new Map<String, Id>();
        collectStaticConfigurations();
    }

    /**
     * @description It creates Email Message records based on received inbound emails
     * and associates it to Work Orders.
     * @JIRA# LEM-3548
     * @param inboundEmails
     */
    public void createEmailMessagesOnWorkOrders(List<Messaging.InboundEmail> inboundEmails) {
        List<Messaging.InboundEmail> validInboundEmails = new List<Messaging.InboundEmail>();
        List<String> invalidInboundEmailSubjects = new List<String>();
        string emailReferenceIdsVar;
        for (Messaging.InboundEmail eachInboundEmail : inboundEmails) {
            if (isValidInboundEmail(eachInboundEmail.subject)) {
                emailReferenceIds.add(getEmailReferenceId(eachInboundEmail.subject));
                validInboundEmails.add(eachInboundEmail);
                continue;
            }
            else{
                emailReferenceIdsVar = extractRefKeyName(eachInboundEmail.plainTextBody);
                validInboundEmails.add(eachInboundEmail);
                if(!string.isblank(emailReferenceIdsVar)){
                	emailReferenceIds.add(extractRefKeyName(eachInboundEmail.plainTextBody));
                	updateWorkSteps = true;
                	continue;
                }
            }
            invalidInboundEmailSubjects.add(INVALID_REFERENCE_ID_ERROR + eachInboundEmail.subject);
        }
        createLogEntries(invalidInboundEmailSubjects);
        if (validInboundEmails.isEmpty()) {
            return;
        }

        collectWorkOrdersByEmailReferenceIds();

        if(!emailReferenceIds.isEmpty()){
        	collectWorkPlanByEmailReferenceIds();
        }
        if(!emailReferenceIds.isEmpty() && updateWorkSteps){
            updateWorkPlanandWorkordeStatus(emailReferenceIds);
        }
        generateEmailMessagesByInboundEmails(validInboundEmails);
        if(hasAttachment){
            createAttachments(validInboundEmails);
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.emailMessageDefaultStatus = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(EMAIL_MESSAGE_DEFAULT_STATUS_STATIC_CONFIG_NAME)
            .Configuration_Value__c;
    }

    /**
     * @description It is used to collect Work Order records based on Email Reference Ids.
     * @JIRA# LEM-3548
     */
    private void collectWorkOrdersByEmailReferenceIds() {
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByEmailReferenceIds(emailReferenceIds)
        ) {
            emailReferenceIdToWorkOrderId.put(
                eachWorkOrder.Email_Reference_Id__c,
                eachWorkOrder.Id
            );
        }
    }

    /**
     * @description It is used to collect work plan records based on Email Reference Ids.
     * @JIRA# LEM-13576
     */
    private void collectWorkPlanByEmailReferenceIds() {
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectWorkPlansByEmailRefId(emailReferenceIds)
        ) {
            emailReferenceIdToWorkPlanId.put(
                eachWorkPlan.Email_Reference_Id__c,
                eachWorkPlan.Id
            );
        }
    }


    /**
     * @description It creates Email Message instance with the passed Inbound Email.
     * @JIRA# LEM-3548
     * @param inboundEmail
     * @return EmailMessage
     */
    private EmailMessage createEmailMessageInstance(Messaging.InboundEmail inboundEmail) {
        Id relatedToIdCustom;
        if(isValidInboundEmail(inboundEmail.subject)) {
            relatedToIdCustom = emailReferenceIdToWorkOrderId.get(getEmailReferenceId(inboundEmail.subject));
        } else if(emailReferenceIdToWorkPlanId.size() > 0){
            if((inboundEmail.textAttachments != null) || (inboundEmail.binaryAttachments != null)){
                hasAttachment = true;
            }
            relatedToIdCustom = id.valueOf(emailReferenceIdToWorkPlanId.get(extractRefKeyName(inboundEmail.plainTextBody)));
        } else {
            updateDummyContact(inboundEmail.replyTo);
            relatedToIdCustom = id.valueOf(FAILURE_EMAIL_ALERT_CONTACT);
            sendNoReplyEmailAlert(FAILURE_EMAIL_ALERT_CONTACT,FAILURE_EMAIL_ALERT);
        }
        EmailMessage emailMessageInstance = new EmailMessage(
            CcAddress = inboundEmail.ccAddresses != null
                ? String.join(inboundEmail.ccAddresses, COMMA_SEPARATOR)
                : null,
            FromName = getFromName(inboundEmail.fromName),
            Headers = inboundEmail.headers != null
                ? String.join(inboundEmail.headers, COMMA_SEPARATOR)
                : null,
            HtmlBody = inboundEmail?.htmlBody,
            MessageIdentifier = inboundEmail.messageId,
            ReplyToEmailMessage = inboundEmail.inReplyTo != null
                ? new EmailMessage(MessageIdentifier = inboundEmail.inReplyTo)
                : null,
            /* If a user replies to Merchant Support address then it is forwarded from corresponding
               google group to salesforce. In this scenario,
               - fromAddress displays the Merchant Support address.
               - replyTo contains the original sender's address.
               Hence using replyTo instead of fromAddress. */
            FromAddress = inboundEmail.replyTo,
            ToAddress = inboundEmail.toAddresses != null
                ? String.join(inboundEmail.toAddresses, COMMA_SEPARATOR)
                : null,
            Status = emailMessageDefaultStatus,
            Subject = inboundEmail.subject,
            TextBody = inboundEmail.plainTextBody,
            RelatedToId = relatedToIdCustom,
            Incoming = true
        );
        return emailMessageInstance;
    }

    /**
     * @description It is used to create log records for inbound email receieved
     * without reference Ids.
     * @JIRA# LEM-3548
     * @param errorMessages
     */
    private void createLogEntries(List<String> errorMessages) {
        if (errorMessages.isEmpty()) {
            return;
        }
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        for (String eachErrorMessage : errorMessages) {
            logEntryInstance = LogEntry.newLog(
                MerchantSupportInboundEmailServiceImpl.class.getName(),
                EMAIL_MESSAGE_METHOD_NAME,
                eachErrorMessage
            );
            if (loggerInstance == null) {
                loggerInstance = Logger.add(logEntryInstance);
                continue;
            }
            loggerInstance.add(logEntryInstance);
        }
        if (loggerInstance != null) {
            loggerInstance.publish();
        }
    }

    /**
     * @description It is used to create EmailMessage instances for valid inbound Emails.
     * @JIRA# LEM-3548
     * @param validInboundEmails
     */
    private void generateEmailMessagesByInboundEmails(
        List<Messaging.InboundEmail> validInboundEmails
    ) {
        /* Implemented partial commit to resolve the error observed with fflib_ISObjectUnitOfWork
         * registerNew function for EmailMessage object.
         * Exception: INVALID_FIELD_FOR_INSERT_UPDATE, cannot specify Id in an insert call: [Id]
         */
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
        List<Database.SaveResult> workOrderInsertSaveResults;
        for (Messaging.InboundEmail eachInboundEmail : validInboundEmails) {
            insertUnitOfWorkHelper.registerInsert(createEmailMessageInstance(eachInboundEmail));
        }
        try {
            unitOfWorkInstance.commitWork();
            workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
            attachmentLinkId = getEmailMessagesId(workOrderInsertSaveResults);
        } catch (Exception emailMessagesCreationException) {
            Logger.publish(
                LogEntry.newDmlLog(
                    workOrderInsertSaveResults,
                    new List<SObject>(),
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It extracts the Email Reference Id from the email subject.
     * @JIRA# LEM-3548
     * @param emailSubject
     * @return String
     */
    private String getEmailReferenceId(String emailSubject) {
        return emailSubject.substring(
            emailSubject.lastIndexOf(EMAIL_REFERENCE_ID_START_KEYWORD),
            // Added 4 to the index to include length of end keyword ':ref' for calculation.
            emailSubject.lastIndexOf(EMAIL_REFERENCE_ID_END_KEYWORD) + 4
        );
    }

    /**
     * @description It returns the sender's name by formatting From Name value of
     * the received inboud email.
     * @example If a user replies to Merchant Support address then it is forwarded from
     * corresponding google group to salesforce. The From Name received in this scenario appears as
     * "'User_Name' via Group_Name". It needs to be formatted to show the exact sender's name
     * removing the group name.
     * @JIRA# LEM-4091
     * @param fromName
     * @return String
     */
    private String getFromName(String fromName) {
        String formattedFromName = fromName;
        if (fromName.contains(FORMAT_EMAIL_FROM_ADDRESS_VIA_KEYWORD)) {
            formattedFromName = fromName.substring(
                    0,
                    fromName.IndexOfIgnoreCase(FORMAT_EMAIL_FROM_ADDRESS_VIA_KEYWORD)
                )
                .remove(FORMAT_EMAIL_FROM_ADDRESS_SINGLE_QUOTE)
                .trim();
        }
        return formattedFromName;
    }

    /**
     * @description It extracts the Email Reference Id from the email subject.
     * @JIRA# LEM-3548
     * @param emailSubject
     * @return Boolean
     */
    private Boolean isValidInboundEmail(String emailSubject) {
        return emailSubject.contains(EMAIL_REFERENCE_ID_START_KEYWORD) &&
            emailSubject.contains(EMAIL_REFERENCE_ID_END_KEYWORD) &&
            (emailSubject.lastIndexOf(EMAIL_REFERENCE_ID_END_KEYWORD) -
            // Subtracted 4 to the index to exclude length of keyword ':ref' for calculation.
            // The total length of the unique identifier within start
            // and end keywords ('ref:',':ref') is 18.
            emailSubject.lastIndexOf(EMAIL_REFERENCE_ID_START_KEYWORD) - 4 == 18);
    }

    /**
     * @description It is used to process email and update work plan
     * @JIRA LEM-13576
     * @param workPlanEmailRefIds
     */
    private static void updateWorkPlanandWorkordeStatus(Set<String> workPlanEmailRefIds) {
        List<WorkPlan> workPlans = WorkPlansSelector.newInstance().selectWorkPlansByEmailRefId(workPlanEmailRefIds);
        if (workPlans.isEmpty()) {
            return;
        }

        Set<Id> workPlanIds = new Set<Id>();
        List<WorkPlan> parentWorkPlansToUpdate = extractParentWorkPlansToUpdate(workPlans, workPlanIds);
        if (!parentWorkPlansToUpdate.isEmpty()) {
            updateRelatedWorkPlan(parentWorkPlansToUpdate);
        }
        if (workPlanIds.isEmpty()) {
            return;
        }
        Set<Id> workOrderIds = extractWorkOrderIds(workPlanIds);

        if (!workOrderIds.isEmpty()) {
            updateWorkOrders(workOrderIds);
        }
    }

    private static List<WorkPlan> extractParentWorkPlansToUpdate(List<WorkPlan> workPlans, Set<Id> workPlanIds) {
        List<WorkPlan> parentWorkPlansToUpdate = new List<WorkPlan>();

        for (WorkPlan workPlan : workPlans) {
            if (workPlan.Parent_Work_Plan__c != null) {
                WorkPlan parentWorkPlan = new WorkPlan(
                    Id = workPlan.Parent_Work_Plan__c,
                    Rescue_Email_Status__c = WORK_PLAN_EMAIL_RESPONSE_STATUS
                );
                parentWorkPlansToUpdate.add(parentWorkPlan);
                workPlanIds.add(workPlan.Parent_Work_Plan__c);
            }
        }

        return parentWorkPlansToUpdate;
    }

    private static Set<Id> extractWorkOrderIds(Set<Id> workPlanIds) {
        Set<Id> workOrderIds = new Set<Id>();
        List<WorkPlan> parentWorkPlans = WorkPlansSelector.newInstance().selectByWorkPlanIds(workPlanIds);
        for (WorkPlan wp : parentWorkPlans) {
            if (wp.Type__c == WORK_PLAN_TYPE && wp.WorkOrderId != null) {
                workOrderIds.add(wp.WorkOrderId);
            }
        }

        return workOrderIds;
    }

    private static void updateWorkOrders(Set<Id> workOrderIds) {
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectById(workOrderIds);
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        for (WorkOrder wo : workOrders) {
            wo.WO_Email_Status__c = WORK_PLAN_EMAIL_RESPONSE_STATUS;
            workOrdersToUpdate.add(wo);
        }
        if (!workOrdersToUpdate.isEmpty()) {
            updateRelatedWorkOrder(workOrdersToUpdate);
        }
    }


    /*Helper method to extract REF key name from email Body
     *@JIRA LEM-13576
     */
    private static String extractRefKeyName(String emailSubject) {
        String refKeyName = '';
        System.Pattern pattern = System.Pattern.compile('ref:[A-Za-z0-9\\.]+:ref');
        System.Matcher matcher = pattern.matcher(emailSubject);
        if (matcher.find() == true ) {
            refKeyName = matcher.group(0);
        }
        return refKeyName;
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
     * @description It fires UPDATE DML statement on Work Order.
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
     * @description It fires UPDATE DML statement on Parent records.
     * @param listToInsert
     * @JIRA LEM-13576
     */
    private static void insertAttachments(List<Attachment> listToInsert) {
        if (listToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowuowAttachmentInsert = Application.UNITOFWORK.newInstance();
        uowuowAttachmentInsert.registerNew(listToInsert);
        try {
            uowuowAttachmentInsert.commitWork();
        } catch (Exception uowAttachmentInsertException) {
            Logger.publish(
                LogEntry.newExceptionLog(uowAttachmentInsertException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_MERCHANT_EMAIL_HANDLER,
                    LOG_EMAIL_HANDLING,
                    GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(uowAttachmentInsertException)
            );
        }
    }

    /**
     * @description It create Email Message Attachments with the passed Inbound Email.
     * @JIRA# LEM-13577
     * @param inboundEmail
     */
    private void createEmailMessageAttachments(Messaging.InboundEmail inboundEmail){
        List<Attachment> listofAttachments = new List<Attachment>();
        if(inboundEmail.textAttachments != null)
        {
            for (Messaging.Inboundemail.TextAttachment tAttachment : inboundEmail.textAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = attachmentLinkId;
                listofAttachments.add(attachment);
            }
        }
        if(inboundEmail.binaryAttachments != null)
        {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : inboundEmail.binaryAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = attachmentLinkId;
                listofAttachments.add(attachment);
            }
        }
        insertAttachments(listofAttachments);
    }

    private Id getEmailMessagesId(List<Database.SaveResult> createdEmailMessages){
        Id emailMessageId;
        for(Database.SaveResult result : createdEmailMessages){
            emailMessageId = result.getId();
        }
        return emailMessageId;
    }

    private void createAttachments(List<Messaging.InboundEmail> inboundEmails){
        for (Messaging.InboundEmail eachInboundEmail : inboundEmails) {
            createEmailMessageAttachments(eachInboundEmail);
        }
    }

    /**
     * @description It Send Email Alert by passing recordId and emailAlertName using flow.
     * @JIRA# LEM-13579
     * @param recordId
     * @param emailAlertName
     */
    private void sendNoReplyEmailAlert(String recordId, String emailAlertName){
        Map<String, Object> params = new Map<String, Object>();
        Params.put('RecordId',recordId);
        Params.put('EmailAlertName',emailAlertName);
        Flow.Interview emailAlertFlow;
        emailAlertFlow = new Flow.Interview.Workflow_Mx_Email_Thread_Failure_Response(Params);
        if(emailAlertFlow != null){
            emailAlertFlow.start();
        }
    }

    /**
     * @description update dummy contact with from email address.
     * @JIRA# LEM-13579
     * @param fromEmail
     */
    private void updateDummyContact(string fromEmail){
        List<Contact> contacts = ContactsSelector.newInstance()
            .selectDummyContactByRecordId(
                new Set<Id>{ FAILURE_EMAIL_ALERT_CONTACT }
            );
        if(!contacts.isEmpty()){
            for (contact con: contacts) {
                con.Email = fromEmail;
            }
            updateRelatedDummyContact(contacts);
        }
    }

    /**
     * @description It fires UPDATE DML statement on dummy contact.
     * @param listToUpdate
     * @JIRA LEM-13579
     */
    private static void updateRelatedDummyContact(List<contact> listToUpdate) {
        if (listToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowContactUpdate = Application.UNITOFWORK.newInstance();
        uowContactUpdate.registerDirty(listToUpdate);
        try {
            uowContactUpdate.commitWork();
        } catch (Exception uowContactUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(uowContactUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_MERCHANT_EMAIL_HANDLER,
                    LOG_EMAIL_HANDLING,
                    GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(uowContactUpdateException)
            );
        }
    }

}