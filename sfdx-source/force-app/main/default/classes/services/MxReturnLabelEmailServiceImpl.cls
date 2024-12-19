/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Service implementation class for sending return label emails to Merchants.
 */
public inherited sharing class MxReturnLabelEmailServiceImpl implements IMxReturnLabelEmailService {
    private static final String AWB_LABEL_KEYWORD = 'awb';
    private static final String GENERIC_LOG_ERROR_MESSAGE = 'Unable to send return label email for the record Ids: ';
    private static final String HTTP_REQUEST_METHOD = 'POST';
    private static final String INVOICE_KEYWORD = 'invoice';
    private static final String LOG_DOMAIN_RETURN_LABEL_EMAIL = 'Return Label Email';
    private static final String LOG_METHOD_NAME = 'sendReturnLabelEmailsToMerchants';
    private static final String LOG_SERVICE_OUTBOUND_EMAIL = 'Mx Return Label Email Service';
    private static final String MERCHANT_ORDER_ITEM_DYNAMIC_PLACEHOLDER = '<p>Merchant_Order_Items_For_Return_PlaceHolder</p>';
    private static final String MERCHANT_SUPPORT_EMAIL_DISPLAY_NAME = System.Label.Merchant_Support_Email_Display_Name;
    private static final String MERCHANT_ORDER_ITEMS_NOT_AVAILABLE_FOR_RETURN = '<p>Products are not selected for return.</p>';
    private static final String NEW_LINE_TAG = '<br>';
    private static final String PARAGRAPH_TAG_CLOSE = '</p>';
    private static final String PARAGRAPH_TAG_START = '<p>';
    private static final String RETURN_LABEL_EMAIL_TEMPLATE = System.Label.Return_Label_Email_Template_Name;
    private static final String SHIPPING_LABEL_KEYWORD = 'shipping';
    private static String orgWideEmailAddressId;
    private static EmailTemplate returnEmailTemplate;
    private Map<Id, Set<Id>> contactIdToOrderIds;
    private Map<Id, Id> contentDocumentIdToOrderId;
    private Map<Id, MxAttachmentsEntry> returnLabelAttachments;
    private RegisterEmailHelper registerEmailHelperInstance;
    private fflib_ISObjectUnitOfWork unitOfWorkInstance;

    /**
     * @description It is used to initialize the static variables.
     */
    static {
        collectRelatedEntitiesForOutboundEmail();
    }

    /**
     * @description Default Constructor to initialize class variables.
     */
    public MxReturnLabelEmailServiceImpl() {
        this.contactIdToOrderIds = new Map<Id, Set<Id>>();
        this.contentDocumentIdToOrderId = new Map<Id, Id>();
        this.registerEmailHelperInstance = new RegisterEmailHelper();
        this.returnLabelAttachments = new Map<Id, MxAttachmentsEntry>();
        this.unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerWork(registerEmailHelperInstance);
    }

    /**
     * @description Wrapper lass to store attachment details related to Mx Orders.
     */
    private class MxAttachmentsEntry {
        public Messaging.EmailFileAttachment awbLabel;
        public Messaging.EmailFileAttachment invoice;
        public Messaging.EmailFileAttachment shippingLabel;
        public List<Messaging.EmailFileAttachment> unlabeledAttachments;

        /**
         * @description Default constructor to set wrapper class variables.
         */
        public MxAttachmentsEntry() {
            this.awbLabel = null;
            this.invoice = null;
            this.shippingLabel = null;
            this.unlabeledAttachments = new List<Messaging.EmailFileAttachment>();
        }
    }

    /**
     * @description It generates email messages based on Return labels
     * (Shipping label, AWB label and Invoice) attached to the merchant orders
     * and sends the email message to the merchants.
     * @JIRA# LEM-14703
     * @param mxOrdersWithReturnLabels
     */
    public void sendReturnLabelEmailsToMerchants(List<MX_Order__c> mxOrdersWithReturnLabels) {
        if (mxOrdersWithReturnLabels.isEmpty()) {
            return;
        }
        Messaging.SingleEmailMessage emailMessage;
        for (MX_Order__c eachMxOrder : mxOrdersWithReturnLabels) {
            for (ContentDocumentLink eachContentDocumentLink : eachMxOrder.ContentDocumentLinks) {
                contentDocumentIdToOrderId.put(
                    eachContentDocumentLink.ContentDocumentId,
                    eachMxOrder.Id
                );
            }
        }
        collectContentVersionsForAttachments();
        for (MX_Order__c eachMxOrder : mxOrdersWithReturnLabels) {
            Set<Messaging.EmailFileAttachment> emailAttachments = new Set<Messaging.EmailFileAttachment>();
            if (!contactIdToOrderIds.containsKey(eachMxOrder.Contact__c)) {
                contactIdToOrderIds.put(eachMxOrder.Contact__c, new Set<Id>());
            }
            contactIdToOrderIds.get(eachMxOrder.Contact__c).add(eachMxOrder.Id);
            emailAttachments.add(returnLabelAttachments.get(eachMxOrder.Id).awbLabel);
            emailAttachments.add(returnLabelAttachments.get(eachMxOrder.Id).invoice);
            emailAttachments.add(returnLabelAttachments.get(eachMxOrder.Id).shippingLabel);
            if(String.isNotBlank(eachMxOrder.Vendor__c) && eachMxOrder.Vendor__c.equalsIgnoreCase('Denali')){
                emailAttachments.addAll(returnLabelAttachments.get(eachMxOrder.Id).unlabeledAttachments);
            }
            emailAttachments.remove(null);
            createEmailMessageInstanceByMxOrder(
                emailMessage,
                eachMxOrder,
                new List<Messaging.EmailFileAttachment>(emailAttachments)
            );
        }
        sendEmailsWithReturnLabelAttachmentsToMx(mxOrdersWithReturnLabels);
    }

    /**
     * @description It generates email file attachment based on files attached to MxOrder.
     * @param contentVersionDetails
     * @param returnLabelAttachment
     * @return Messaging.EmailFileAttachment
     */
    private Messaging.EmailFileAttachment collectAttachmentsForMxEmail(
        ContentVersion contentVersionDetails,
        Messaging.EmailFileAttachment returnLabelAttachment
    ) {
        returnLabelAttachment = new Messaging.EmailFileAttachment();
        returnLabelAttachment.setFileName(contentVersionDetails.Title);
        returnLabelAttachment.setBody(contentVersionDetails.VersionData);
        return returnLabelAttachment;
    }

    /**
     * @description It collects the content versions to add email attachment body using VersionData.
     */
    private void collectContentVersionsForAttachments() {
        Id orderId;
        Messaging.EmailFileAttachment returnLabelAttachment;
        for (
            ContentVersion eachContentVersion : ContentVersionsSelector.newInstance()
                .selectByContentDocumentIds(contentDocumentIdToOrderId.keySet())
        ) {
            orderId = contentDocumentIdToOrderId.get(eachContentVersion.ContentDocumentId);
            if (!returnLabelAttachments.containsKey(orderId)) {
                returnLabelAttachments.put(orderId, new MxAttachmentsEntry());
            }
            collectLatestDocumentDetails(eachContentVersion, orderId, returnLabelAttachment);
        }
    }

    /**
     * @description It collects the valid and latest document Ids related to Mx Orders.
     * @param contentVersionDetails
     * @param mxOrderId
     * @param returnLabelAttachment
     */
    private void collectLatestDocumentDetails(
        ContentVersion contentVersionDetails,
        Id mxOrderId,
        Messaging.EmailFileAttachment returnLabelAttachment
    ) {
        if (String.isBlank(contentVersionDetails.Title)) {
            return;
        }
        if (
            contentVersionDetails.Title.containsIgnoreCase(AWB_LABEL_KEYWORD) &&
            returnLabelAttachments.get(mxOrderId).awbLabel == null
        ) {
            returnLabelAttachments.get(mxOrderId).awbLabel = collectAttachmentsForMxEmail(
                contentVersionDetails,
                returnLabelAttachment
            );
        } else if (
            contentVersionDetails.Title.containsIgnoreCase(INVOICE_KEYWORD) &&
            returnLabelAttachments.get(mxOrderId).invoice == null
        ) {
            returnLabelAttachments.get(mxOrderId).invoice = collectAttachmentsForMxEmail(
                contentVersionDetails,
                returnLabelAttachment
            );
        } else if (
            contentVersionDetails.Title.containsIgnoreCase(SHIPPING_LABEL_KEYWORD) &&
            returnLabelAttachments.get(mxOrderId).shippingLabel == null
        ) {
            returnLabelAttachments.get(mxOrderId).shippingLabel = collectAttachmentsForMxEmail(
                contentVersionDetails,
                returnLabelAttachment
            );
        } else {
            returnLabelAttachments.get(mxOrderId).unlabeledAttachments.add(collectAttachmentsForMxEmail(
                contentVersionDetails,
                returnLabelAttachment
            ));
        }
    }

    /**
     * @description It collects email template ids and organization wide email id for email processing.
     */
    private static void collectRelatedEntitiesForOutboundEmail() {
        orgWideEmailAddressId = OrgWideEmailAddressesSelector.newInstance()
                .selectOrgWideAddressByDisplayNames(
                    new Set<String>{ MERCHANT_SUPPORT_EMAIL_DISPLAY_NAME }
                )[0]
            .Id;
        returnEmailTemplate = EmailTemplateSelector.newInstance()
            .selectByTemplateNames(new Set<String>{ RETURN_LABEL_EMAIL_TEMPLATE })[0];
    }

    /**
     * @description It generates SingleEmailMessage instance for passed MxOrder.
     * @param emailMessage
     * @param mxOrder
     * @param emailAttachments
     */
    private void createEmailMessageInstanceByMxOrder(
        Messaging.SingleEmailMessage emailMessage,
        MX_Order__c mxOrder,
        List<Messaging.EmailFileAttachment> emailAttachments
    ) {
        emailMessage = new Messaging.SingleEmailMessage();
        String dynamicEmailBody = returnEmailTemplate.HtmlValue;
        String mxOrderItemsToReturn = PARAGRAPH_TAG_START + '';
        if (mxOrder.Merchant_Order_Items__r != null && !mxOrder.Merchant_Order_Items__r.isEmpty()) {
            for (MX_Order_Item__c eachMxOrderItem : mxOrder.Merchant_Order_Items__r) {
                mxOrderItemsToReturn =
                    mxOrderItemsToReturn +
                    eachMxOrderItem.Product__r.Name +
                    NEW_LINE_TAG;
            }
            mxOrderItemsToReturn = mxOrderItemsToReturn + PARAGRAPH_TAG_CLOSE;
            dynamicEmailBody = dynamicEmailBody.replace(
                MERCHANT_ORDER_ITEM_DYNAMIC_PLACEHOLDER,
                mxOrderItemsToReturn
            );
        } else {
            dynamicEmailBody = dynamicEmailBody.replace(
                MERCHANT_ORDER_ITEM_DYNAMIC_PLACEHOLDER,
                MERCHANT_ORDER_ITEMS_NOT_AVAILABLE_FOR_RETURN
            );
        }
        emailMessage.setTargetObjectId(mxOrder.Contact__c);
        emailMessage.setOrgWideEmailAddressId(orgWideEmailAddressId);
        emailMessage.setTreatTargetObjectAsRecipient(true);
        emailMessage.setWhatId(mxOrder.Id);
        emailMessage.setFileAttachments(emailAttachments);
        emailMessage.setSaveAsActivity(false);
        emailMessage.setSubject(returnEmailTemplate.Subject);
        emailMessage.setHtmlBody(dynamicEmailBody);
        registerEmailHelperInstance.registerSingleEmailMessage(emailMessage);
    }

    /**
     * @description It initiates update of Merchant orders based on Email result.
     * @param emailResults
     * @param mxOrderIds
     */
    private void processEmailResults(
        List<Messaging.SendEmailResult> emailResults,
        Set<Id> mxOrderIds
    ) {
        Set<Id> failedOrderIds = new Set<Id>();
        Id contactId;
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        for (Messaging.SendEmailResult eachEmailResult : emailResults) {
            if (!eachEmailResult.isSuccess()) {
                contactId = eachEmailResult.getErrors()[0].getTargetObjectId();
                for (Id eachMxOrderId : contactIdToOrderIds.get(contactId)) {
                    failedOrderIds.add(eachMxOrderId);
                    mxOrderIds.remove(eachMxOrderId);
                }
                logEntryInstance = LogEntry.newLog(
                    MxReturnLabelEmailServiceImpl.class.getName(),
                    LOG_METHOD_NAME,
                    eachEmailResult.getErrors()[0].getMessage()
                );
                logEntryInstance.recordId = contactId;
                if (loggerInstance == null) {
                    loggerInstance = Logger.add(logEntryInstance);
                    continue;
                }
                loggerInstance.add(logEntryInstance);
            }
        }
        if (loggerInstance != null) {
            loggerInstance.publish();
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_OUTBOUND_EMAIL,
                        LOG_DOMAIN_RETURN_LABEL_EMAIL,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logMessage(GENERIC_LOG_ERROR_MESSAGE + failedOrderIds)
            );
        }
        if (emailResults.isEmpty()) {
            //Updates the MxOrders return label status to 'Failed to send to Mx'.
            MerchantOrdersService.updateMxOrdersReturnLabelStatusBasedOnEmailResults(
                mxOrderIds,
                new Set<Id>()
            );
        } else {
            MerchantOrdersService.updateMxOrdersReturnLabelStatusBasedOnEmailResults(
                failedOrderIds,
                mxOrderIds
            );
        }
    }

    /**
     * @description It performs the Messaging.sendEmail operation to send the email instances to Mx.
     * @param mxOrdersWithReturnLabels
     */
    private void sendEmailsWithReturnLabelAttachmentsToMx(
        List<MX_Order__c> mxOrdersWithReturnLabels
    ) {
        List<Messaging.SendEmailResult> emailResults = new List<Messaging.SendEmailResult>();
        Set<Id> mxOrderIds = new Map<Id, MX_Order__c>(mxOrdersWithReturnLabels).keySet();
        try {
            unitOfWorkInstance.commitWork();
            emailResults = registerEmailHelperInstance.sendEmailResults;
        } catch (Exception emailProcessException) {
            Logger.publish(
                LogEntry.newExceptionLog(emailProcessException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_OUTBOUND_EMAIL,
                        LOG_DOMAIN_RETURN_LABEL_EMAIL,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(emailProcessException)
            );
        }
        processEmailResults(emailResults, mxOrderIds);
    }
}