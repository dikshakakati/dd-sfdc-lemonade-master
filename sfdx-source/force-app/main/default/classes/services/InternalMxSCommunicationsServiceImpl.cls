/**
 * @author Deloitte
 * @date 04/24/2023
 * @description Service implementation class for internal communitcations related logic.
 */
public inherited sharing class InternalMxSCommunicationsServiceImpl implements IInternalMxSCommunicationsService {
    private static final String FIELD_API_NAME_ACCOUNT_ID = 'AccountId';
    private static final String FIELD_API_NAME_OPPORTUNITY_ID = 'OpportunityId';
    private static final String FIELD_API_NAME_USER_ID = 'UserId';
    private static final String FIELD_API_NAME_BUSINESS_ACCOUNT = 'Business_Account__c';
    private static final String FIELD_API_NAME_CORPORATE_ACCOUNT = 'Corporate_Account__c';
    private static final String FIELD_API_NAME_WORKORDERID = 'WorkOrderId';
    private static final String FIRST_NAME_TEMP = 'Temp';
    private static final String LOG_DOMAIN_INTERNAL_MXS_EMAIL = 'Internal Mxs Communication';
    private static final String LOG_SERVICE_INTERNAL_MXS_COMMUNICATION = 'Internal MxS Email Communication';
    private static final String SOBJECT_TYPE_WORK_ORDER = 'WorkOrder';
    private static final String SOBJECT_TYPE_WORK_STEP = 'WorkStep';
    private static final String SOBJECT_TYPE_MX_ONBOARDING_LINK = 'Mx_Onboarding_Link__c';
    private Map<Id, List<Contact>> accountIdToContacts;
    private Map<Id, Set<Id>> accountIdToRecordOwnerIds;
    private String accountOwnerEmailId;
    private Map<Id, AccountTeamMember> accountTeamMembers;
    private List<Contact> existingContacts;
    private Map<Id, Id> opportunityIdToAccountId;
    private Map<Id, OpportunityTeamMember> opportunityTeamMembers;
    private Set<Id> processedUserIds;
    private Map<Id, sObject> sObjects;
    private String sObjectType;
    private List<SObject> teamMembers;
    private Map<Id, User> userInstances;
    private Map<Id, Id> sObjectIdToEmailTemplateId;
    private Map<Id, Id> sObjectIdToOrgWideAddressId;
    private enum ObjectTypes {
        WORK_ORDER,
        WORK_STEP,
        MX_ONBOARDING_LINK
    }
    private static final Map<String, ObjectTypes> OBJECT_NAME_TO_OBJECT_TYPES = new Map<String, ObjectTypes>{
        SOBJECT_TYPE_WORK_ORDER => ObjectTypes.WORK_ORDER,
        SOBJECT_TYPE_WORK_STEP => ObjectTypes.WORK_STEP,
        SOBJECT_TYPE_MX_ONBOARDING_LINK => ObjectTypes.MX_ONBOARDING_LINK
    };
    /**
     * @description Default constructor to initialize class variables.
     */
    public InternalMxSCommunicationsServiceImpl() {
        this.accountIdToContacts = new Map<Id, List<Contact>>();
        this.accountIdToRecordOwnerIds = new Map<Id, Set<Id>>();
        this.accountTeamMembers = new Map<Id, AccountTeamMember>();
        this.existingContacts = new List<Contact>();
        this.opportunityIdToAccountId = new Map<Id, Id>();
        this.opportunityTeamMembers = new Map<Id, OpportunityTeamMember>();
        this.processedUserIds = new Set<Id>();
        this.sObjects = new Map<Id, sObject>();
        this.teamMembers = new List<SObject>();
        this.userInstances = new Map<Id, User>();
        this.sObjectIdToEmailTemplateId = new Map<Id, Id>();
        this.sObjectIdToOrgWideAddressId = new Map<Id, Id>();
    }

    /**
     * @description It is used to send email to Account Team Members based on the flow inputs.
     * @JIRA# LEM-5727, LEM-23432
     * @param flowInputs
     */
    public void sendSingleEmailMessagesToAccountTeamMembers(
        List<InternalMxSCommunicationsFlowInputs> flowInputs
    ) {
        Id accountId;
        Id workOrderId;
        Id mxOnboardingLinkId;
        Set<Id> recordOwnerIds;
        try {
            for (InternalMxSCommunicationsFlowInputs eachFlowInput : flowInputs) {
                sObjectType = eachFlowInput.sObjectType;
                switch on
                    OBJECT_NAME_TO_OBJECT_TYPES.get(sObjectType) {
                    when WORK_ORDER {
                        workOrderId = eachFlowInput.workOrderInstance.Id;
                        accountId = eachFlowInput.workOrderInstance.Corporate_Account__c;
                        accountOwnerEmailId = eachFlowInput.workOrderInstance.Account_Owner_Email_Calculated__c;
                        sObjects.put(
                            eachFlowInput.workOrderInstance.Id,
                            eachFlowInput.workOrderInstance
                        );
                        opportunityIdToAccountId.put(
                            eachFlowInput.workOrderInstance.Opportunity__c,
                            accountId
                        );
                        sObjectIdToEmailTemplateId.put(workOrderId, eachFlowInput.emailTemplateId);
                        sObjectIdToOrgWideAddressId.put(workOrderId, eachFlowInput.orgWideAddressId);
                    }
                    when WORK_STEP {
                        workOrderId = eachFlowInput.workStepInstance.WorkOrderId;
                        accountId = eachFlowInput.workStepInstance.Business_Account__c;
                        sObjects.put(eachFlowInput.workStepInstance.Id, eachFlowInput.workStepInstance);
                        sObjectIdToEmailTemplateId.put(workOrderId, eachFlowInput.emailTemplateId);
                        sObjectIdToOrgWideAddressId.put(workOrderId, eachFlowInput.orgWideAddressId);

                    }
                    when MX_ONBOARDING_LINK {
                        mxOnboardingLinkId = eachFlowInput.mxOnboardingLinkInstance.Id;
                        accountId = eachFlowInput.mxOnboardingLinkInstance.Business_Account__c;
                        sObjects.put(eachFlowInput.mxOnboardingLinkInstance.Id,eachFlowInput.mxOnboardingLinkInstance);
                        opportunityIdToAccountId.put(
                            eachFlowInput.mxOnboardingLinkInstance.Opportunity__c,
                            accountId
                        );
                        sObjectIdToEmailTemplateId.put(mxOnboardingLinkId, eachFlowInput.emailTemplateId);
                        sObjectIdToOrgWideAddressId.put(mxOnboardingLinkId, eachFlowInput.orgWideAddressId);
                    }
                }
                if (eachFlowInput.accountTeamMembers != null) {
                    accountTeamMembers.putAll(eachFlowInput.accountTeamMembers);
                }
                if (eachFlowInput.opportunityTeamMembers != null) {
                    opportunityTeamMembers.putAll(eachFlowInput.opportunityTeamMembers);
                }
                if (eachFlowInput.recordOwnerIds != null) {
                    recordOwnerIds = new Set<Id>(eachFlowInput.recordOwnerIds);
                    recordOwnerIds.remove(null);
                    accountIdToRecordOwnerIds.put(accountId, recordOwnerIds);
                }
                if (eachFlowInput.existingContacts != null) {
                    existingContacts.addAll(eachFlowInput.existingContacts);
                    accountIdToContacts.put(accountId, eachFlowInput.existingContacts);
                } else {
                    accountIdToContacts.put(accountId, new List<Contact>());
                }
                userInstances.putAll(eachFlowInput.userInstances);
            }
            collectUserIds();
            createContactByTeamMembers();
            sendEmail();
        } catch (Exception sendEmailException) {
            Logger.publish(
                LogEntry.newExceptionLog(sendEmailException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_INTERNAL_MXS_COMMUNICATION,
                        LOG_DOMAIN_INTERNAL_MXS_EMAIL,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(sendEmailException)
            );
        }
    }

    /**
     * @description It is used to collect User Id from the exisiting Contacts.
     * @JIRA# LEM-5727
     */
    private void collectUserIds() {
        for (Contact eachContact : existingContacts) {
            processedUserIds.add(eachContact.Account_Team_Member_Id__c);
        }
    }

    /**
     * @description It is used to collect all Team Members from the received
     * Account Team Member' and 'Opportunity Team Member' records.
     * @JIRA# LEM-23432
     */
    private void collectTeamMembers() {
        if (accountTeamMembers != null && !accountTeamMembers.isEmpty()) {
            teamMembers.addAll(accountTeamMembers.values());
        }
        if (opportunityTeamMembers != null && !opportunityTeamMembers.isEmpty()) {
            teamMembers.addAll(opportunityTeamMembers.values());
        }
        if (!accountIdToRecordOwnerIds.isEmpty()) {
            for (Id eachAccountId : accountIdToRecordOwnerIds.keySet()) {
                for (Id eachRecordOwnerId : accountIdToRecordOwnerIds.get(eachAccountId)) {
                    teamMembers.add(
                        new AccountTeamMember(UserId = eachRecordOwnerId, AccountId = eachAccountId)
                    );
                }
            }
        }
    }

    /**
     * @description It is used to create Contact using the details from
     * 'Account Team Member' and 'Opportunity Team Member' records received.
     * @JIRA# LEM-5727, LEM-23432
     */
    private void createContactByTeamMembers() {
        Id accountId;
        Contact newContactInstance;
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        Id userId;
        User userToProcess;
        collectTeamMembers();
        for (SObject eachTeamMember : teamMembers) {
            accountId = eachTeamMember.getSObjectType() == AccountTeamMember.SObjectType
                ? (Id) eachTeamMember.get(FIELD_API_NAME_ACCOUNT_ID)
                : opportunityIdToAccountId.get(
                      (Id) eachTeamMember.get(FIELD_API_NAME_OPPORTUNITY_ID)
                  );
            userId = (Id) eachTeamMember.get(FIELD_API_NAME_USER_ID);
            if (!userInstances.containsKey(userId) || processedUserIds.contains(userId)) {
                continue;
            }
            userToProcess = userInstances.get(userId);
            newContactInstance = new Contact(
                FirstName = String.isBlank(userToProcess.FirstName)
                    ? FIRST_NAME_TEMP
                    : userToProcess.FirstName,
                MiddleName = userToProcess.MiddleName,
                LastName = userToProcess.LastName,
                Email = userToProcess.Email,
                Phone = userToProcess.Phone,
                Account_Team_Member_Id__c = userToProcess.Id
            );
            if (!accountIdToContacts.containsKey(accountId)) {
                accountIdToContacts.put(accountId, new List<Contact>());
            }
            accountIdToContacts.get(accountId).add(newContactInstance);
            processedUserIds.add(userId);
            unitOfWork.registerNew(newContactInstance);
        }
        // Added check to skip commitWork call when Contact instance is null
        if (newContactInstance == null) {
            return;
        }
        unitOfWork.commitWork();
    }

    /**
     * @description It is used to send mail to Account Team Members.
     * @JIRA# LEM-5727
     */
    private void sendEmail() {
        Id accountId;
        List<Contact> contactsToProcess;
        Messaging.SingleEmailMessage singleEmailMessageToProcess;
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        Id workOrderId;
        Id mxOnboardingLinkId;
        for (SObject eachSObject : sObjects.values()) {
            switch on
                OBJECT_NAME_TO_OBJECT_TYPES.get(sObjectType) {
                when WORK_ORDER {
                    workOrderId = (Id) eachSObject.Id;
                    accountId = (Id) eachSObject.get(FIELD_API_NAME_CORPORATE_ACCOUNT);
                }
                when WORK_STEP {
                    workOrderId = (Id) eachSObject.get(FIELD_API_NAME_WORKORDERID);
                    accountId = (Id) eachSObject.get(FIELD_API_NAME_BUSINESS_ACCOUNT);
                }
                when MX_ONBOARDING_LINK {
                    mxOnboardingLinkId = (Id) eachSObject.Id;
                    accountId = (Id) eachSObject.get(FIELD_API_NAME_BUSINESS_ACCOUNT);
                }
            }
            if (!accountIdToContacts.containsKey(accountId)) {
                continue;
            }
            contactsToProcess = accountIdToContacts.get(accountId);
            if (contactsToProcess == null) {
                continue;
            }
            for (Contact eachContact : accountIdToContacts.get(accountId)) {
                if (!(accountOwnerEmailId != null && eachContact.Email == accountOwnerEmailId)) {
                    singleEmailMessageToProcess = new Messaging.SingleEmailMessage();
                    if (sObjectType == SOBJECT_TYPE_WORK_ORDER || sObjectType == SOBJECT_TYPE_WORK_STEP ) {
                        singleEmailMessageToProcess.setOrgWideEmailAddressId(
                        	sObjectIdToOrgWideAddressId.get(workOrderId)
                    	);
                    	singleEmailMessageToProcess.setTemplateId(
                        	sObjectIdToEmailTemplateId.get(workOrderId)
                    	);
                    }
                    else{
                        singleEmailMessageToProcess.setOrgWideEmailAddressId(
                        	sObjectIdToOrgWideAddressId.get(eachSObject.Id)
                    	);
                    	singleEmailMessageToProcess.setTemplateId(
                        	sObjectIdToEmailTemplateId.get(eachSObject.Id)
                    	);
                    }
                    singleEmailMessageToProcess.setSaveAsActivity(false);
                    singleEmailMessageToProcess.setTargetObjectId(eachContact.Id);
                    singleEmailMessageToProcess.setTreatTargetObjectAsRecipient(true);
                    singleEmailMessageToProcess.setWhatId(eachSObject.Id);
                    unitOfWork.registerEmail(singleEmailMessageToProcess);
                }
            }
        }
        unitOfWork.commitWork();
    }
}