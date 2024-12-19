/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Service implementation class for inbound email related logic.
 */
public class EmailToLeadServiceImpl implements IEmailToLeadService {
    private static final String COMMA_SEPARATOR = ',';
    private static final String COLON = ':';
    private static final String SPACE_COLON_SPACE = ' : ';
    private static final String EMAIL_MESSAGE_METHOD_NAME = 'initiateLeadCreationFromInboundEmail';
    private static final String EMAIL_MESSAGE_SUBJECT = 'Onboarding Onto Doordash';
    private static final String FORMAT_EMAIL_FROM_ADDRESS_SINGLE_QUOTE = '\'';
    private static final String FORMAT_EMAIL_FROM_ADDRESS_VIA_KEYWORD = ' via ';
    private static final String INBOUND_EMAIL_ADDRESS = 'Email Address';
    private static final String INVALID_INBOUND_EMAIL = 'The email should contain an email address or phone number and a physical address and Rx name.';
    private static final String INBOUND_OWNER_NAME = 'Manager / Owner Name';
    private static final String INBOUND_PHONE_NUMBER = 'Phone Number';
    private static final String INBOUND_PHONE_NUMBER_WITH_COLON = 'Phone Number :';
    private static final String INBOUND_STORE_ADDRESS = 'Restaurant Address';
    private static final String INBOUND_STORE_NAME = 'Store name';
    private static final String INBOUND_STORE_NAME_WITH_COLON = 'Store name :';
    private static final String LEAD_SOURCE = 'Inbound Support';
    private static final String UNKNOWN = 'Unknown';
    private static final String LEAD_PRIMARY_VERTICAL = 'Rx';
    LeadDetailsWrapper leadWrapper = new LeadDetailsWrapper();
    Lead leadInstance = new Lead();
    List<Lead> existingLeadWithAddress = new List<Lead>();
    Boolean isValidInboundEmail = false;

    /**
     * @description It creates Email Message and Lead record based on
     * the received inbound email.
     * @JIRA# LEM-13420
     * @param inboundEmail
     */
    public void initiateLeadCreationFromInboundEmail(Messaging.InboundEmail inboundEmail) {
        String plainEmailText = inboundEmail.plainTextBody;
        collectLeadDetailsFromEmailBody(plainEmailText);
        checkValidityOfEmail(leadWrapper);
        if (isValidInboundEmail) {
            for (
                Lead eachLead : LeadsSelector.newInstance()
                    .selectLeadsByEmailAndCompany(leadWrapper.email, leadWrapper.storeName)
            ) {
                if ((leadWrapper.storeAddress).contains(eachLead.Street)) {
                    existingLeadWithAddress.add(eachLead);
                }
            }
            if (existingLeadWithAddress.size() == 0) {
                createLead(leadWrapper);
                createEmailMessageInstance(inboundEmail);
            } else {
                createEmailMessageInstance(inboundEmail);
            }
        } else {
            createLogEntries(INVALID_INBOUND_EMAIL);
        }
    }

    /**
     * @description It checks whether the passed inbound Email is Valid
     * @param leadWrapper
     */
    private void checkValidityOfEmail(LeadDetailsWrapper leadWrapper) {
        if (
            (String.isNotBlank(leadWrapper.phone) || String.isNotBlank(leadWrapper.email)) &&
            String.isNotBlank(leadWrapper.storeAddress) &&
            String.isNotBlank(leadWrapper.storeName)
        ) {
            isValidInboundEmail = true;
        } else {
            isValidInboundEmail = false;
        }
    }

    /**
     * @description It creates a wrapper from the passed inbound email plain text body.
     * @param plainEmailText
     */
    private void collectLeadDetailsFromEmailBody(String plainEmailText) {
        leadWrapper.phone = extractPhoneNumber(plainEmailText);
        leadWrapper.email = extractEmailAddress(plainEmailText);
        leadWrapper.firstName = extractFirstName(plainEmailText);
        leadWrapper.lastName = extractLastName(plainEmailText);
        leadWrapper.storeAddress = extractStoreAddress(plainEmailText);
        leadWrapper.storeName = extractStoreName(plainEmailText);
    }

    /**
     * @description It extracts the phone number from the inbound email plain text body.
     * @param plainEmailText
     * @return phoneNum
     */
    private String extractPhoneNumber(String plainEmailText) {
        if (plainEmailText.containsIgnoreCase(INBOUND_PHONE_NUMBER)) {
            String splitPhoneNumberWithKey = plainEmailText.substring(
                plainEmailText.IndexOfIgnoreCase(INBOUND_PHONE_NUMBER),
                plainEmailText.IndexOfIgnoreCase(INBOUND_OWNER_NAME)
            );
            String splitPhoneNumber = splitPhoneNumberWithKey.remove(
                INBOUND_PHONE_NUMBER_WITH_COLON
            );
            String splitPhoneNumberTrimmed = splitPhoneNumber.trim();
            return splitPhoneNumberTrimmed;
        } else {
            String splitPhoneNumberTrimmed = '';
            return splitPhoneNumberTrimmed;
        }
    }

    /**
     * @description It extracts the email address from the inbound email plain text body.
     * @param plainEmailText
     * @return emailAddress
     */
    private String extractEmailAddress(String plainEmailText) {
        if (plainEmailText.containsIgnoreCase(INBOUND_EMAIL_ADDRESS)) {
            String splitEmailAddressWithoutKey = plainEmailText.substringBetween(
                INBOUND_EMAIL_ADDRESS,
                '\n'
            );
            String splitEmailAddressWithoutColon = splitEmailAddressWithoutKey.remove(
                SPACE_COLON_SPACE
            );
            String splitEmailAddressTrimmed = splitEmailAddressWithoutColon.trim();
            return splitEmailAddressTrimmed;
        } else {
            String splitEmailAddressTrimmed = '';
            return splitEmailAddressTrimmed;
        }
    }

    /**
     * @description It extracts the First Name from the inbound email plain text body.
     * @param plainEmailText
     * @return splitFirstNameTrimmed
     */
    private String extractFirstName(String plainEmailText) {
        String splitFirstNameWithKey = plainEmailText.substringAfter(INBOUND_OWNER_NAME);
        if (splitFirstNameWithKey.contains('\n')) {
            splitFirstNameWithKey = plainEmailText.substringBetween(INBOUND_OWNER_NAME, '\n');
        }
        String splitFirstNameWithKeyRemoved = splitFirstNameWithKey.remove(SPACE_COLON_SPACE);
        if (splitFirstNameWithKeyRemoved.containsWhitespace()) {
            String splitFirstNameTrimmed = splitFirstNameWithKeyRemoved.substringBefore(' ');
            return splitFirstNameTrimmed;
        } else {
            String splitFirstNameTrimmed = '';
            return splitFirstNameTrimmed;
        }
    }

    /**
     * @description It extracts the Last Name from the inbound email plain text body.
     * @param plainEmailText
     * @return splitName
     */
    private String extractLastName(String plainEmailText) {
        String splitLastNameTrimmed = '';
        String splitLastNameWithKey = plainEmailText.substringAfter(INBOUND_OWNER_NAME);
        if (splitLastNameWithKey.contains('\n')) {
            splitLastNameWithKey = plainEmailText.substringBetween(INBOUND_OWNER_NAME, '\n');
        }
        String splitNameWithKeyRemoved = splitLastNameWithKey.remove(SPACE_COLON_SPACE);
        if (splitNameWithKeyRemoved.containsWhitespace()) {
            splitLastNameTrimmed = splitNameWithKeyRemoved.substringAfter(' ');
        } else {
            splitLastNameTrimmed = splitNameWithKeyRemoved.trim();
        }
        if (splitLastNameTrimmed.contains(COLON)) {
            return splitLastNameTrimmed.remove(COLON);
        } else {
            return splitLastNameTrimmed;
        }
    }

    /**
     * @description It extracts the store address from the inbound email plain text body.
     * @param plainEmailText
     * @return splitAddress
     */
    private String extractStoreAddress(String plainEmailText) {
        String splitAddressWithoutKey = '';
        if (plainEmailText.contains(INBOUND_EMAIL_ADDRESS)) {
            splitAddressWithoutKey = plainEmailText.substringBetween(
                INBOUND_STORE_ADDRESS,
                INBOUND_EMAIL_ADDRESS
            );
        } else {
            splitAddressWithoutKey = plainEmailText.substringBetween(
                INBOUND_STORE_ADDRESS,
                INBOUND_PHONE_NUMBER
            );
        }
        String splitAddressWithoutColon = splitAddressWithoutKey.remove(COLON);
        String splitAddressTrimmed = splitAddressWithoutColon.trim();
        return splitAddressTrimmed;
    }

    /**
     * @description It extracts the store name from the inbound email plain text body.
     * @param plainEmailText
     * @return splitStoreName
     */
    private String extractStoreName(String plainEmailText) {
        String splitStoreNameWithKey = plainEmailText.substring(
            plainEmailText.IndexOfIgnoreCase(INBOUND_STORE_NAME),
            plainEmailText.IndexOfIgnoreCase(INBOUND_STORE_ADDRESS)
        );
        String splitStoreName = splitStoreNameWithKey.remove(INBOUND_STORE_NAME_WITH_COLON);
        String splitStoreNameTrimmed = splitStoreName.trim();
        return splitStoreNameTrimmed;
    }

    /**
     * @description It creates Lead record with the passed LeadDetails wrapper.
     * @JIRA# LEM-13420
     * @param leadWrapper
     */
    public void createLead(LeadDetailsWrapper leadWrapper) {
        leadInstance.Company = String.isBlank(leadWrapper.storeName)
            ? UNKNOWN
            : leadWrapper.storeName;
        leadInstance.LeadSource = LEAD_SOURCE;
        leadInstance.FirstName = String.isBlank(leadWrapper.firstName)
            ? UNKNOWN
            : leadWrapper.firstName;
        leadInstance.LastName = String.isBlank(leadWrapper.lastName)
            ? UNKNOWN
            : leadWrapper.lastName;
        leadInstance.Street = leadWrapper.storeAddress;
        leadInstance.Email = String.isBlank(leadWrapper.email) ? '' : leadWrapper.email;
        leadInstance.Phone = String.isBlank(leadWrapper.phone) ? '' : leadWrapper.phone;
        leadInstance.PrimaryVertical__c = LEAD_PRIMARY_VERTICAL;
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(leadInstance);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(ex, LogEntry.SeverityLevel.HIGH);
        }
    }

    /**
     * @description It creates Email Message and
     * Email Message Relation instance with the passed inbound email.
     * @param inboundEmail
     */
    private void createEmailMessageInstance(Messaging.InboundEmail inboundEmail) {
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
            FromAddress = inboundEmail.replyTo,
            ToAddress = inboundEmail.toAddresses != null
                ? String.join(inboundEmail.toAddresses, COMMA_SEPARATOR)
                : null,
            Status = '1',
            Subject = EMAIL_MESSAGE_SUBJECT,
            TextBody = inboundEmail.plainTextBody
        );
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(emailMessageInstance);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(ex, LogEntry.SeverityLevel.HIGH);
        }
        EmailMessageRelation emailMessageRelationInstance = new EmailMessageRelation(
            EmailMessageId = emailMessageInstance.Id,
            RelationId = existingLeadWithAddress.size() == 0
                ? leadInstance.Id
                : existingLeadWithAddress[0].Id,
            RelationAddress = emailMessageInstance.FromAddress,
            RelationType = 'FromAddress'
        );
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
        List<Database.SaveResult> workOrderInsertSaveResults;
        insertUnitOfWorkHelper.registerInsert(emailMessageRelationInstance);
        try {
            unitOfWorkInstance.commitWork();
            workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        } catch (Exception ex) {
            Logger.publish(ex, LogEntry.SeverityLevel.HIGH);
        }
    }

    /**
     * @description It returns the sender's name by formatting From Name value of
     * the received inboud email.
     * @example If a user replies to Merchant Support address then it is forwarded from
     * corresponding google group to salesforce. The From Name received in this scenario appears as
     * "'User_Name' via Group_Name". It needs to be formatted to show the exact sender's name
     * removing the group name.
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
     * @description It is used to create log records for inbound email receieved
     * without email address, phone number, store address and the store name.
     * Not using the GenericLogger framework as this service class involves processing of emails
     * and due to incorrect formatting it can publish high number of platform events.
     * @param errorMessages
     */
    private void createLogEntries(String errorMessages) {
        if (String.isBlank(errorMessages)) {
            return;
        }
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        logEntryInstance = LogEntry.newLog(
            EmailToLeadServiceImpl.class.getName(),
            EMAIL_MESSAGE_METHOD_NAME,
            errorMessages
        );
        if (loggerInstance == null) {
            loggerInstance = Logger.add(logEntryInstance);
        }
        loggerInstance.add(logEntryInstance);
        if (loggerInstance != null) {
            loggerInstance.publish();
        }
    }

    /**
     * @description It is a wrapper class to encapsulate all the details required for creating Lead.
     * @JIRA# LEM-13420
     */
    public class LeadDetailsWrapper {
        public String firstName;
        public String lastName;
        public String phone;
        public String email;
        public String storeAddress;
        public String storeName;
    }
}