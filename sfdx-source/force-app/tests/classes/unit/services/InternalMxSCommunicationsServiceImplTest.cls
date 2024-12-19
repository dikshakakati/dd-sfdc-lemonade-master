/**
 * @author Deloitte
 * @date 04/24/2023
 * @description Test class for InternalMxSCommunicationsServiceImpl class.
 */
@isTest(SeeAllData=false)
private class InternalMxSCommunicationsServiceImplTest {
    private static final String ACCOUNT_TEAM_MEMBER_ROLE_DRIVE_SPECIALIST = 'Drive Specialist';
    private static final String EMAIL_ORG_WIDE_ADDRESS_MISMATCH_ASSERT_MESSAGE = 'Unexpected Result: Org Wide Email Address does not match.';
    private static final String EMAIL_SAVE_AS_ACTIVITY_MISMATCH_ASSERT_MESSAGE = 'Unexpected Result: Save As Activity value does not match.';
    private static final String EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE = 'Unexpected Result: Email Subject does not match.';
    private static final String EMAIL_TARGET_OBJECT_ID_MISMATCH_ASSERT_MESSAGE = 'Unexpected Result: Target Object Id does not match.';
    private static final String EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE = 'Unexpected Result: Email Template Id does not match.';
    private static final String EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE = 'Unexpected Result: What Id does not match.';
    private static final String SOBJECT_TYPE_WORKORDER = 'WorkOrder';
    private static final String SOBJECT_TYPE_WORKSTEP = 'WorkStep';
    private static final String USER_EMAIL = 'internalMxSCommunicationsServiceImplTest@test.com';
    private static final String USER_FIRST_NAME = 'Test';
    private static final String USER_LAST_NAME = 'User';
    private static final String USER_MIDDLE_NAME = 'Mock';
    private static final String USER_PHONE = '0987654321';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_STATUS_PLANNING = 'Planning';
    private static final String WORKORDER_PROVISIONING_STATUS = 'Readiness Check Failed';
    private static final String WORKSTEP_STATUS_BLOCKED = 'Blocked';
    private static final String SOBJECT_TYPE_MX_ONBOARDING_LINK = 'Mx_Onboarding_Link__c';
    private static final String SALES_DEVELOPMENT_REP = 'Sales Development Rep';
    private static final String CREATION_STATUS_SUCCESS = 'Success';

    /**
     * @description To test email notification sent to Drive Specialists when 'Drive' Work Order
     * "Provisioning Status" is updated to 'Readiness Check Failed'.
     */
    @isTest
    private static void testWhenWorkOrderReadinessCheckFailedThenSendEmailToDriveSpecialists() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, mockAccountId)
            .setField(WorkOrder.Corporate_Account__c, mockAccountId)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkOrder.Status, WORKORDER_STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, WORKORDER_PROVISIONING_STATUS)
            .setFakeId()
            .toSObject();
        AccountTeamMember accountTeamMemberInstance = (AccountTeamMember) new Fake(
                AccountTeamMember.class
            )
            .setField(AccountTeamMember.AccountId, mockAccountId)
            .setField(AccountTeamMember.UserId, mockUserId)
            .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_MEMBER_ROLE_DRIVE_SPECIALIST)
            .setFakeId()
            .toSObject();
        Contact contactInstance = (Contact) new Fake(Contact.class)
            .setField(Contact.Account_Team_Member_Id__c, mockUserId)
            .setField(Contact.Email, USER_EMAIL)
            .setFakeId()
            .toSObject();
        User userInstance = (User) new Fake(User.class)
            .setField(User.Id, mockUserId)
            .setField(User.Email, USER_EMAIL)
            .setField(User.FirstName, USER_FIRST_NAME)
            .setField(User.LastName, USER_LAST_NAME)
            .setField(User.MiddleName, USER_MIDDLE_NAME)
            .setField(User.Phone, USER_PHONE)
            .toSObject();
        InternalMxSCommunicationsFlowInputs mockFlowInputsInstance = new InternalMxSCommunicationsFlowInputs();
        mockFlowInputsInstance.accountTeamMembers = new List<AccountTeamMember>{
            accountTeamMemberInstance
        };
        mockFlowInputsInstance.emailTemplateId = mockEmailTemplateId;
        mockFlowInputsInstance.existingContacts = new List<Contact>{ contactInstance };
        mockFlowInputsInstance.orgWideAddressId = mockOrgWideAddressId;
        mockFlowInputsInstance.sObjectType = SOBJECT_TYPE_WORKORDER;
        mockFlowInputsInstance.userInstances = new List<User>{ userInstance };
        mockFlowInputsInstance.workOrderInstance = mockWorkOrder;
        Messaging.SingleEmailMessage mockEmailMessage = new Messaging.SingleEmailMessage();
        mockEmailMessage.setOrgWideEmailAddressId(mockOrgWideAddressId);
        mockEmailMessage.setSaveAsActivity(false);
        mockEmailMessage.setTargetObjectId(contactInstance.Id);
        mockEmailMessage.setTemplateId(mockEmailTemplateId);
        mockEmailMessage.setTreatTargetObjectAsRecipient(true);
        mockEmailMessage.setWhatId(mockWorkOrder.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InternalMxSCommunicationsService.sendSingleEmailMessagesToAccountTeamMembers(
            new List<InternalMxSCommunicationsFlowInputs>{ mockFlowInputsInstance }
        );
        fflib_ArgumentCaptor capturedEmailArguments = fflib_ArgumentCaptor.forClass(
            Messaging.SingleEmailMessage.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
            .registerEmail((Messaging.SingleEmailMessage) capturedEmailArguments.capture());
        Object capturedEmailMessageObject = capturedEmailArguments.getValue();
        Messaging.SingleEmailMessage capturedEmailMessage = (Messaging.SingleEmailMessage) capturedEmailMessageObject;
        System.assertEquals(
            mockEmailMessage.getSubject(),
            capturedEmailMessage.getSubject(),
            EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getOrgWideEmailAddressId(),
            capturedEmailMessage.getOrgWideEmailAddressId(),
            EMAIL_ORG_WIDE_ADDRESS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getSaveAsActivity(),
            capturedEmailMessage.getSaveAsActivity(),
            EMAIL_SAVE_AS_ACTIVITY_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTargetObjectId(),
            capturedEmailMessage.getTargetObjectId(),
            EMAIL_TARGET_OBJECT_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTemplateId(),
            capturedEmailMessage.getTemplateId(),
            EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getWhatId(),
            capturedEmailMessage.getWhatId(),
            EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Contact creation and email notification sent to Drive Specialists
     * when 'Drive' Work Order "Provisioning Status" is updated to 'Readiness Check Failed'
     * and Account Team Member's user does not have existing Contact.
     */
    @isTest
    private static void testWhenNoContactExistForDriveSpecialistAccountTeamMembersThenCreateContactAndSendEmailToDriveSpecialists() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, mockAccountId)
            .setField(WorkOrder.Corporate_Account__c, mockAccountId)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkOrder.Status, WORKORDER_STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, WORKORDER_PROVISIONING_STATUS)
            .setFakeId()
            .toSObject();
        AccountTeamMember accountTeamMemberInstance = (AccountTeamMember) new Fake(
                AccountTeamMember.class
            )
            .setField(AccountTeamMember.AccountId, mockAccountId)
            .setField(AccountTeamMember.UserId, mockUserId)
            .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_MEMBER_ROLE_DRIVE_SPECIALIST)
            .setFakeId()
            .toSObject();
        User userInstance = (User) new Fake(User.class)
            .setField(User.Id, mockUserId)
            .setField(User.Email, USER_EMAIL)
            .setField(User.FirstName, USER_FIRST_NAME)
            .setField(User.LastName, USER_LAST_NAME)
            .setField(User.MiddleName, USER_MIDDLE_NAME)
            .setField(User.Phone, USER_PHONE)
            .toSObject();
        InternalMxSCommunicationsFlowInputs mockFlowInputsInstance = new InternalMxSCommunicationsFlowInputs();
        mockFlowInputsInstance.accountTeamMembers = new List<AccountTeamMember>{
            accountTeamMemberInstance
        };
        mockFlowInputsInstance.emailTemplateId = mockEmailTemplateId;
        mockFlowInputsInstance.orgWideAddressId = mockOrgWideAddressId;
        mockFlowInputsInstance.sObjectType = SOBJECT_TYPE_WORKORDER;
        mockFlowInputsInstance.userInstances = new List<User>{ userInstance };
        mockFlowInputsInstance.workOrderInstance = mockWorkOrder;
        Messaging.SingleEmailMessage mockEmailMessage = new Messaging.SingleEmailMessage();
        mockEmailMessage.setOrgWideEmailAddressId(mockOrgWideAddressId);
        mockEmailMessage.setSaveAsActivity(false);
        mockEmailMessage.setTemplateId(mockEmailTemplateId);
        mockEmailMessage.setTreatTargetObjectAsRecipient(true);
        mockEmailMessage.setWhatId(mockWorkOrder.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InternalMxSCommunicationsService.sendSingleEmailMessagesToAccountTeamMembers(
            new List<InternalMxSCommunicationsFlowInputs>{ mockFlowInputsInstance }
        );
        Contact mockContact = new Contact(
            Account_Team_Member_Id__c = mockUserId,
            Email = USER_EMAIL,
            FirstName = USER_FIRST_NAME,
            LastName = USER_LAST_NAME,
            MiddleName = USER_MIDDLE_NAME,
            Phone = USER_PHONE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerNew(mockContact);
        fflib_ArgumentCaptor capturedEmailArguments = fflib_ArgumentCaptor.forClass(
            Messaging.SingleEmailMessage.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
            .registerEmail((Messaging.SingleEmailMessage) capturedEmailArguments.capture());
        Object capturedEmailMessageObject = capturedEmailArguments.getValue();
        Messaging.SingleEmailMessage capturedEmailMessage = (Messaging.SingleEmailMessage) capturedEmailMessageObject;
        System.assertEquals(
            mockEmailMessage.getSubject(),
            capturedEmailMessage.getSubject(),
            EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getOrgWideEmailAddressId(),
            capturedEmailMessage.getOrgWideEmailAddressId(),
            EMAIL_ORG_WIDE_ADDRESS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getSaveAsActivity(),
            capturedEmailMessage.getSaveAsActivity(),
            EMAIL_SAVE_AS_ACTIVITY_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTemplateId(),
            capturedEmailMessage.getTemplateId(),
            EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getWhatId(),
            capturedEmailMessage.getWhatId(),
            EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test email notification sent to Drive Specialists when 'Drive' Work Order's
     * Work Step "Status" is updated to 'Blocked'.
     */
    @isTest
    private static void testWhenWorkStepBlockedThenSendEmailToDriveSpecialists() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Business_Account__c, mockAccountId)
            .setField(WorkStep.Status, WORKSTEP_STATUS_BLOCKED)
            .setField(WorkStep.WorkOrderId, mockWorkOrderId)
            .setFakeId()
            .toSObject();
        AccountTeamMember accountTeamMemberInstance = (AccountTeamMember) new Fake(
                AccountTeamMember.class
            )
            .setField(AccountTeamMember.AccountId, mockAccountId)
            .setField(AccountTeamMember.UserId, mockUserId)
            .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_MEMBER_ROLE_DRIVE_SPECIALIST)
            .setFakeId()
            .toSObject();
        Contact contactInstance = (Contact) new Fake(Contact.class)
            .setField(Contact.Account_Team_Member_Id__c, mockUserId)
            .setField(Contact.Email, USER_EMAIL)
            .setFakeId()
            .toSObject();
        User userInstance = (User) new Fake(User.class)
            .setField(User.Id, mockUserId)
            .setField(User.Email, USER_EMAIL)
            .setField(User.FirstName, USER_FIRST_NAME)
            .setField(User.LastName, USER_LAST_NAME)
            .setField(User.MiddleName, USER_MIDDLE_NAME)
            .setField(User.Phone, USER_PHONE)
            .toSObject();
        InternalMxSCommunicationsFlowInputs mockFlowInputsInstance = new InternalMxSCommunicationsFlowInputs();
        mockFlowInputsInstance.accountTeamMembers = new List<AccountTeamMember>{
            accountTeamMemberInstance
        };
        mockFlowInputsInstance.emailTemplateId = mockEmailTemplateId;
        mockFlowInputsInstance.existingContacts = new List<Contact>{ contactInstance };
        mockFlowInputsInstance.orgWideAddressId = mockOrgWideAddressId;
        mockFlowInputsInstance.sObjectType = SOBJECT_TYPE_WORKSTEP;
        mockFlowInputsInstance.userInstances = new List<User>{ userInstance };
        mockFlowInputsInstance.workStepInstance = mockWorkStep;
        Messaging.SingleEmailMessage mockEmailMessage = new Messaging.SingleEmailMessage();
        mockEmailMessage.setOrgWideEmailAddressId(mockOrgWideAddressId);
        mockEmailMessage.setSaveAsActivity(false);
        mockEmailMessage.setTargetObjectId(contactInstance.Id);
        mockEmailMessage.setTemplateId(mockEmailTemplateId);
        mockEmailMessage.setTreatTargetObjectAsRecipient(true);
        mockEmailMessage.setWhatId(mockWorkStep.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InternalMxSCommunicationsService.sendSingleEmailMessagesToAccountTeamMembers(
            new List<InternalMxSCommunicationsFlowInputs>{ mockFlowInputsInstance }
        );
        fflib_ArgumentCaptor capturedEmailArguments = fflib_ArgumentCaptor.forClass(
            Messaging.SingleEmailMessage.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
            .registerEmail((Messaging.SingleEmailMessage) capturedEmailArguments.capture());
        Object capturedEmailMessageObject = capturedEmailArguments.getValue();
        Messaging.SingleEmailMessage capturedEmailMessage = (Messaging.SingleEmailMessage) capturedEmailMessageObject;
        System.assertEquals(
            mockEmailMessage.getSubject(),
            capturedEmailMessage.getSubject(),
            EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getOrgWideEmailAddressId(),
            capturedEmailMessage.getOrgWideEmailAddressId(),
            EMAIL_ORG_WIDE_ADDRESS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getSaveAsActivity(),
            capturedEmailMessage.getSaveAsActivity(),
            EMAIL_SAVE_AS_ACTIVITY_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTargetObjectId(),
            capturedEmailMessage.getTargetObjectId(),
            EMAIL_TARGET_OBJECT_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTemplateId(),
            capturedEmailMessage.getTemplateId(),
            EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getWhatId(),
            capturedEmailMessage.getWhatId(),
            EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test email notification sent to Opportunity Team Member when Work Order
     * "Provisioning Status" is updated to 'Readiness Check Failed'.
     */
    @isTest
    private static void testWhenWorkOrderReadinessCheckFailedThenSendEmailToOpportunityTeamMember() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, mockAccountId)
            .setField(WorkOrder.Corporate_Account__c, mockAccountId)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkOrder.Status, WORKORDER_STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, WORKORDER_PROVISIONING_STATUS)
            .setFakeId()
            .toSObject();
        OpportunityTeamMember opportunityTeamMemberInstance = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.OpportunityId, mockOpportunityId)
            .setField(OpportunityTeamMember.UserId, mockUserId)
            .setFakeId()
            .toSObject();
        Contact contactInstance = (Contact) new Fake(Contact.class)
            .setField(Contact.Account_Team_Member_Id__c, mockUserId)
            .setField(Contact.Email, USER_EMAIL)
            .setFakeId()
            .toSObject();
        User userInstance = (User) new Fake(User.class)
            .setField(User.Id, mockUserId)
            .setField(User.Email, USER_EMAIL)
            .setField(User.FirstName, USER_FIRST_NAME)
            .setField(User.LastName, USER_LAST_NAME)
            .setField(User.MiddleName, USER_MIDDLE_NAME)
            .setField(User.Phone, USER_PHONE)
            .toSObject();
        InternalMxSCommunicationsFlowInputs mockFlowInputsInstance = new InternalMxSCommunicationsFlowInputs();
        mockFlowInputsInstance.opportunityTeamMembers = new List<OpportunityTeamMember>{
            opportunityTeamMemberInstance
        };
        mockFlowInputsInstance.emailTemplateId = mockEmailTemplateId;
        mockFlowInputsInstance.existingContacts = new List<Contact>{ contactInstance };
        mockFlowInputsInstance.orgWideAddressId = mockOrgWideAddressId;
        mockFlowInputsInstance.sObjectType = SOBJECT_TYPE_WORKORDER;
        mockFlowInputsInstance.userInstances = new List<User>{ userInstance };
        mockFlowInputsInstance.workOrderInstance = mockWorkOrder;
        Messaging.SingleEmailMessage mockEmailMessage = new Messaging.SingleEmailMessage();
        mockEmailMessage.setOrgWideEmailAddressId(mockOrgWideAddressId);
        mockEmailMessage.setSaveAsActivity(false);
        mockEmailMessage.setTargetObjectId(contactInstance.Id);
        mockEmailMessage.setTemplateId(mockEmailTemplateId);
        mockEmailMessage.setTreatTargetObjectAsRecipient(true);
        mockEmailMessage.setWhatId(mockWorkOrder.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InternalMxSCommunicationsService.sendSingleEmailMessagesToAccountTeamMembers(
            new List<InternalMxSCommunicationsFlowInputs>{ mockFlowInputsInstance }
        );
        fflib_ArgumentCaptor capturedEmailArguments = fflib_ArgumentCaptor.forClass(
            Messaging.SingleEmailMessage.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
            .registerEmail((Messaging.SingleEmailMessage) capturedEmailArguments.capture());
        Object capturedEmailMessageObject = capturedEmailArguments.getValue();
        Messaging.SingleEmailMessage capturedEmailMessage = (Messaging.SingleEmailMessage) capturedEmailMessageObject;
        System.assertEquals(
            mockEmailMessage.getSubject(),
            capturedEmailMessage.getSubject(),
            EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getOrgWideEmailAddressId(),
            capturedEmailMessage.getOrgWideEmailAddressId(),
            EMAIL_ORG_WIDE_ADDRESS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getSaveAsActivity(),
            capturedEmailMessage.getSaveAsActivity(),
            EMAIL_SAVE_AS_ACTIVITY_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTargetObjectId(),
            capturedEmailMessage.getTargetObjectId(),
            EMAIL_TARGET_OBJECT_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTemplateId(),
            capturedEmailMessage.getTemplateId(),
            EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getWhatId(),
            capturedEmailMessage.getWhatId(),
            EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test email notification sent to Mx Onboarding Link Creator when Work Order
     * "Provisioning Status" is updated to 'Readiness Check Failed'.
     */
    @isTest
    private static void testWhenWorkOrderReadinessCheckFailedThenSendEmailToMxOnboardingLinkCreator() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, mockAccountId)
            .setField(WorkOrder.Corporate_Account__c, mockAccountId)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_DRIVE)
            .setField(WorkOrder.Status, WORKORDER_STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, WORKORDER_PROVISIONING_STATUS)
            .setFakeId()
            .toSObject();
        Contact contactInstance = (Contact) new Fake(Contact.class)
            .setField(Contact.Account_Team_Member_Id__c, mockUserId)
            .setField(Contact.Email, USER_EMAIL)
            .setFakeId()
            .toSObject();
        User userInstance = (User) new Fake(User.class)
            .setField(User.Id, mockUserId)
            .setField(User.Email, USER_EMAIL)
            .setField(User.FirstName, USER_FIRST_NAME)
            .setField(User.LastName, USER_LAST_NAME)
            .setField(User.MiddleName, USER_MIDDLE_NAME)
            .setField(User.Phone, USER_PHONE)
            .toSObject();
        InternalMxSCommunicationsFlowInputs mockFlowInputsInstance = new InternalMxSCommunicationsFlowInputs();
        mockFlowInputsInstance.recordOwnerIds = new List<Id>{ mockUserId };
        mockFlowInputsInstance.emailTemplateId = mockEmailTemplateId;
        mockFlowInputsInstance.existingContacts = new List<Contact>{ contactInstance };
        mockFlowInputsInstance.orgWideAddressId = mockOrgWideAddressId;
        mockFlowInputsInstance.sObjectType = SOBJECT_TYPE_WORKORDER;
        mockFlowInputsInstance.userInstances = new List<User>{ userInstance };
        mockFlowInputsInstance.workOrderInstance = mockWorkOrder;
        Messaging.SingleEmailMessage mockEmailMessage = new Messaging.SingleEmailMessage();
        mockEmailMessage.setOrgWideEmailAddressId(mockOrgWideAddressId);
        mockEmailMessage.setSaveAsActivity(false);
        mockEmailMessage.setTargetObjectId(contactInstance.Id);
        mockEmailMessage.setTemplateId(mockEmailTemplateId);
        mockEmailMessage.setTreatTargetObjectAsRecipient(true);
        mockEmailMessage.setWhatId(mockWorkOrder.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InternalMxSCommunicationsService.sendSingleEmailMessagesToAccountTeamMembers(
            new List<InternalMxSCommunicationsFlowInputs>{ mockFlowInputsInstance }
        );
        fflib_ArgumentCaptor capturedEmailArguments = fflib_ArgumentCaptor.forClass(
            Messaging.SingleEmailMessage.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
            .registerEmail((Messaging.SingleEmailMessage) capturedEmailArguments.capture());
        Object capturedEmailMessageObject = capturedEmailArguments.getValue();
        Messaging.SingleEmailMessage capturedEmailMessage = (Messaging.SingleEmailMessage) capturedEmailMessageObject;
        System.assertEquals(
            mockEmailMessage.getSubject(),
            capturedEmailMessage.getSubject(),
            EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getOrgWideEmailAddressId(),
            capturedEmailMessage.getOrgWideEmailAddressId(),
            EMAIL_ORG_WIDE_ADDRESS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getSaveAsActivity(),
            capturedEmailMessage.getSaveAsActivity(),
            EMAIL_SAVE_AS_ACTIVITY_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTargetObjectId(),
            capturedEmailMessage.getTargetObjectId(),
            EMAIL_TARGET_OBJECT_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTemplateId(),
            capturedEmailMessage.getTemplateId(),
            EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getWhatId(),
            capturedEmailMessage.getWhatId(),
            EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

     /**
     * @description To test email notification sent to Record Creator, Opportunity Owner and Opportunity team
     * when Mx Orboarding 'Status' is updated to 'Inactive' and 'Inactive Reason' is updated to 'Submitted'.
     */
    @isTest
    private static void testWhenMxOnboardingInputsSubmittedThenSendEmailToOpportunityTeam() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockEmailTemplateId = fflib_IDGenerator.generate(EmailTemplate.SObjectType);
        Id mockOrgWideAddressId = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);

        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake( Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Opportunity__c, opportunityId)
            .setField(Mx_Onboarding_Link__c.Business_Account__c, mockAccountId)
            .setField(Mx_Onboarding_Link__c.Record_Creation_Status__c, CREATION_STATUS_SUCCESS)
            .setField(Mx_Onboarding_Link__c.Status__c, 'Inactive')
            .setField(Mx_Onboarding_Link__c.Inactive_Reason__c, 'Submitted')
            .toSobject();
         OpportunityTeamMember opportunityTeamMemberInstance = (OpportunityTeamMember) new Fake( OpportunityTeamMember.class)
            .setField(OpportunityTeamMember.Id, opportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, opportunityId)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
            .setField(OpportunityTeamMember.UserId,mockUserId)
            .toSObject();
        Contact contactInstance = (Contact) new Fake(Contact.class)
            .setField(Contact.Account_Team_Member_Id__c, mockUserId)
            .setField(Contact.Email, USER_EMAIL)
            .setFakeId()
            .toSObject();
        User userInstance = (User) new Fake(User.class)
            .setField(User.Id, mockUserId)
            .setField(User.Email, USER_EMAIL)
            .setField(User.FirstName, USER_FIRST_NAME)
            .setField(User.LastName, USER_LAST_NAME)
            .setField(User.MiddleName, USER_MIDDLE_NAME)
            .setField(User.Phone, USER_PHONE)
            .toSObject();
        InternalMxSCommunicationsFlowInputs mockFlowInputsInstance = new InternalMxSCommunicationsFlowInputs();
        mockFlowInputsInstance.opportunityTeamMembers = new List<OpportunityTeamMember>{
            opportunityTeamMemberInstance
        };
        mockFlowInputsInstance.emailTemplateId = mockEmailTemplateId;
        mockFlowInputsInstance.existingContacts = new List<Contact>{ contactInstance };
        mockFlowInputsInstance.orgWideAddressId = mockOrgWideAddressId;
        mockFlowInputsInstance.sObjectType = SOBJECT_TYPE_MX_ONBOARDING_LINK;
        mockFlowInputsInstance.userInstances = new List<User>{ userInstance };
        mockFlowInputsInstance.mxOnboardingLinkInstance = mxOnboardingLinkFake;
        Messaging.SingleEmailMessage mockEmailMessage = new Messaging.SingleEmailMessage();
        mockEmailMessage.setOrgWideEmailAddressId(mockOrgWideAddressId);
        mockEmailMessage.setSaveAsActivity(false);
        mockEmailMessage.setTargetObjectId(contactInstance.Id);
        mockEmailMessage.setTemplateId(mockEmailTemplateId);
        mockEmailMessage.setTreatTargetObjectAsRecipient(true);
        mockEmailMessage.setWhatId(mxOnboardingLinkFake.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InternalMxSCommunicationsService.sendSingleEmailMessagesToAccountTeamMembers(
            new List<InternalMxSCommunicationsFlowInputs>{ mockFlowInputsInstance }
        );
        fflib_ArgumentCaptor capturedEmailArguments = fflib_ArgumentCaptor.forClass(
            Messaging.SingleEmailMessage.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUow, 1))
            .registerEmail((Messaging.SingleEmailMessage) capturedEmailArguments.capture());
        Object capturedEmailMessageObject = capturedEmailArguments.getValue();
        Messaging.SingleEmailMessage capturedEmailMessage = (Messaging.SingleEmailMessage) capturedEmailMessageObject;

        System.assertEquals(
            mockEmailMessage.getSubject(),
            capturedEmailMessage.getSubject(),
            EMAIL_SUBJECT_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTargetObjectId(),
            capturedEmailMessage.getTargetObjectId(),
            EMAIL_TARGET_OBJECT_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getTemplateId(),
            capturedEmailMessage.getTemplateId(),
            EMAIL_TEMPLATE_ID_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockEmailMessage.getWhatId(),
            capturedEmailMessage.getWhatId(),
            EMAIL_WHAT_ID_MISMATCH_ASSERT_MESSAGE
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}