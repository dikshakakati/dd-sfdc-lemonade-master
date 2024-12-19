/**
 * @author Deloitte
 * @date 11/24/2022
 * @description Test class for MerchantSupportInboundEmailServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class MerchantSupportInboundEmailSrvcImplTest {
    private static final String EMAIL_MESSAGE_METHOD_NAME = 'createEmailMessagesOnWorkOrders';
    private static final String EMAIL_MESSAGE_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to register expected email message';
    private static final String EMAIL_MESSAGE_FROM_NAME_NOT_FORMATTED_ASSERT_MESSAGE = 'Unexpected result: failed to format From Name in email message';
    private static final String EMAIL_MESSAGE_RELATED_TO_ID = 'RelatedToId';
    private static final String EMAIL_MESSAGE_FROM_NAME_FIELD = 'FromName';
    private static final String INBOUND_EMAIL_CC_ADDRESS = 'MerchantSupportInboundEmailSrvcImplTest_cc@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_ADDRESS = 'MerchantSupportInboundEmailSrvcImplTest_from@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_NAME = 'MerchantSupportInboundEmailSrvcImplTest_From_Name';
    private static final String INBOUND_EMAIL_FROM_NAME_VIA_GROUP = '\'MerchantSupportInboundEmailSrvcImplTest_From_Name\' via Email Group';
    private static final String INBOUND_EMAIL_HTML_BODY = '<html><head></head><body></body></html>';
    private static final String INBOUND_EMAIL_MESSAGE_ID = '<MerchantSupportInboundEmailSrvcImplTest-Message_Id@sfdc.net>';
    private static final String INBOUND_EMAIL_PLAIN_TEXT_BODY = 'MerchantSupportInboundEmailSrvcImpl-Plain_Text_Body';
    private static final String INBOUND_EMAIL_SUBJECT = 'MerchantSupportInboundEmailSrvcImplTest-Subject ref:00D30kOo.0WO30QvdP:ref';
    private static final String INBOUND_EMAIL_SUBJECT_INVALID_REFERENCE_ID = 'MerchantSupportInboundEmailSrvcImpl-Invalid_Subject';
    private static final String INBOUND_EMAIL_TO_ADDRESS = 'MerchantSupportInboundEmailSrvcImplTest_to@ext.doordash.com';
    private static final String INVALID_REFERENCE_ID_ERROR = 'Inbound Email is received with invalid Reference Id in subject: ';
    private static final String WORK_ORDER_EMAIL_REFERENCE_ID = 'ref:00D30kOo.0WO30QvdP:ref';
    private static final String INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID = 'Hey there! We just wanted to reach out to let you know that DoorDash/FedEx has sent you an electronic return shipping label at no charge to you. Please print this label and tape it onto a box with the DoorDash owned tablet you will be returning, and drop the package off at your nearest FedEx location. If you have the original box it came in or received a replacement DoorDash owned tablet, you may use that box for shipping Please return the products below. Merchant_Order_Items_For_Return_PlaceHolder Best, DoorDash | Tablet Support ref:00DOnXrB.0gqO01TmU:ref';
    private static final String INBOUND_WORK_PLAN_EMAIL_SUBJECT = 'Check Inbound Email Subject';
    private static final String WORK_PLAN_EMAIL_REFERENCE_ID = 'ref:00DOnXrB.0gqO01TmU:ref';
    private static final String FIRST_NAME = 'No Reply';
    private static final String LAST_NAME = 'Test Contact';
    /**
     * @description To test Email Message creation when inbound email is received with valid
     * reference Id in email subject.
     */
    @isTest
    private static void testWhenInboundEmailReceivedWithValidReferenceIdThenCreateEmailMessageOnWorkOrder() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY;
        inboundEmailInstance.subject = INBOUND_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        inboundEmails.add(inboundEmailInstance);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Email_Reference_Id__c, WORK_ORDER_EMAIL_REFERENCE_ID)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectByEmailReferenceIds(
                    new Set<String>{ WORK_ORDER_EMAIL_REFERENCE_ID }
                )
            )
            .thenReturn(new List<WorkOrder>{ mockWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(inboundEmails);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasEmailMessageRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(EMAIL_MESSAGE_RELATED_TO_ID) == mockWorkOrder.Id;
        System.assertEquals(
            true,
            hasEmailMessageRegistered,
            EMAIL_MESSAGE_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Log (Log__c) creation when inbound email is received with invalid
     * reference Id in email subject.
     */
    @isTest
    private static void testWhenInboundEmailReceivedWithInvalidReferenceIdThenCreateExceptionLog() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID;
        inboundEmailInstance.subject = INBOUND_EMAIL_SUBJECT_INVALID_REFERENCE_ID;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        inboundEmails.add(inboundEmailInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(inboundEmails);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test 'From Name' is formatted on Email Message creation when inbound email
     * is received via google group.
     */
    @isTest
    private static void testWhenInboundEmailReceivedViaGoogleGroupThenCreateEmailMessageWithFormattedFromName() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME_VIA_GROUP;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY;
        inboundEmailInstance.subject = INBOUND_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        inboundEmails.add(inboundEmailInstance);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Email_Reference_Id__c, WORK_ORDER_EMAIL_REFERENCE_ID)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectByEmailReferenceIds(
                    new Set<String>{ WORK_ORDER_EMAIL_REFERENCE_ID }
                )
            )
            .thenReturn(new List<WorkOrder>{ mockWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(inboundEmails);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasEmailMessageRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(EMAIL_MESSAGE_RELATED_TO_ID) == mockWorkOrder.Id;
        Boolean hasFormattedFromName =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(EMAIL_MESSAGE_FROM_NAME_FIELD) == INBOUND_EMAIL_FROM_NAME;
        System.assertEquals(
            true,
            hasEmailMessageRegistered,
            EMAIL_MESSAGE_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            hasFormattedFromName,
            EMAIL_MESSAGE_FROM_NAME_NOT_FORMATTED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Update Work plan status when inbound email
     * is received via External email.
     */
    @isTest
    private static void testWhenInboundEmailReceivedViaExternalEmailThenUpdateWorkOrderStatus() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME_VIA_GROUP;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID;
        inboundEmailInstance.subject = INBOUND_WORK_PLAN_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        inboundEmails.add(inboundEmailInstance);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workStepsId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        String onboardingWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkPlan> workPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, onboardingWorkPlanId)
                .setField(WorkPlan.WorkOrderId, workOrderId)
                .setField(WorkPlan.status__c, 'Blocked')
                .setField(workPlan.Email_Reference_Id__c, WORK_PLAN_EMAIL_REFERENCE_ID)
                .toSObject()
        };

        List<WorkStep> workSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.Id, workStepsId)
                .setField(WorkStep.WorkOrderId, workOrderId)
                .setField(WorkStep.Status, 'Blocked')
                .toSObject()
        };

        List<contact> contacts = new List<contact>{
            (contact) new Fake(contact.class)
                .setField(contact.Id, contactId)
                .setField(contact.Email, INBOUND_EMAIL_FROM_ADDRESS)
                .setField(contact.LastName, FIRST_NAME)
                .setField(contact.Firstname, LAST_NAME)
                .toSObject()
        };
        Set<String> workPlanEmailRefIds = new Set<String>{ WORK_PLAN_EMAIL_REFERENCE_ID };
        Set<Id> workPlanIds = new Set<Id>{ onboardingWorkPlanId };
        Set<Id> contactIds = new Set<Id>{ contacts[0].Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );

        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );

        IContactsSelector contactsSelectorMock = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansByEmailRefId(workPlanEmailRefIds))
            .thenReturn(workPlans);
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectEscalatedOrBlockedByWorkPlanIds(workPlanIds))
            .thenReturn(workSteps);
        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelectorMock.selectDummyContactByRecordId(contactIds))
            .thenReturn(contacts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SELECTOR.setMock(contactsSelectorMock);
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(inboundEmails);
        System.assertEquals(
            true,
            INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID.contains(WORK_PLAN_EMAIL_REFERENCE_ID),
            EMAIL_MESSAGE_FROM_NAME_NOT_FORMATTED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test create attachment Email Message when inbound email
     * is received via external source.
     */
    @isTest
    private static void testWhenInboundEmailReceivedViaExternalEmailThenCreateAttachments() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('New Attachment');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME_VIA_GROUP;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID;
        inboundEmailInstance.subject = INBOUND_WORK_PLAN_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        inboundEmailInstance.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{
            attachment
        };
        inboundEmails.add(inboundEmailInstance);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workStepsId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        String onboardingWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkPlan> workPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, onboardingWorkPlanId)
                .setField(WorkPlan.WorkOrderId, workOrderId)
                .setField(WorkPlan.status__c, 'Blocked')
                .setField(workPlan.Email_Reference_Id__c, WORK_PLAN_EMAIL_REFERENCE_ID)
                .toSObject()
        };

        List<WorkStep> workSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.Id, workStepsId)
                .setField(WorkStep.WorkOrderId, workOrderId)
                .setField(WorkStep.Status, 'Blocked')
                .toSObject()
        };

        Set<String> workPlanEmailRefIds = new Set<String>{ WORK_PLAN_EMAIL_REFERENCE_ID };
        Set<Id> workPlanIds = new Set<Id>{ onboardingWorkPlanId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );

        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansByEmailRefId(workPlanEmailRefIds))
            .thenReturn(workPlans);
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectEscalatedOrBlockedByWorkPlanIds(workPlanIds))
            .thenReturn(workSteps);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(inboundEmails);
        System.assertEquals(
            true,
            INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID.contains(WORK_PLAN_EMAIL_REFERENCE_ID),
            EMAIL_MESSAGE_FROM_NAME_NOT_FORMATTED_ASSERT_MESSAGE
        );
    }
    @isTest
    private static void testWhenInboundEmailReceivedViaExternalEmailThenUpdateWorkPlanAndWorkOrderStatus() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{INBOUND_EMAIL_CC_ADDRESS};
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME_VIA_GROUP;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID;
        inboundEmailInstance.subject = INBOUND_WORK_PLAN_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{INBOUND_EMAIL_TO_ADDRESS};
        inboundEmails.add(inboundEmailInstance);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        List<WorkPlan> childWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, workPlanId)
                .setField(WorkPlan.WorkOrderId, childWorkOrderId)
                .setField(workPlan.Email_Reference_Id__c, WORK_PLAN_EMAIL_REFERENCE_ID)
                .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
                .setField(WorkPlan.Type__c, 'Onboarding')
                .toSObject()
        };

         List<WorkPlan> parentWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, parentWorkPlanId)
                .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
                .setField(WorkPlan.Parent_Work_Plan__c, null)
                .setField(WorkPlan.Type__c, 'Onboarding')
                .setFakeId()
                .toSObject()
        };

        List<WorkOrder> workOrders = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, parentWorkOrderId)
                .setField(WorkOrder.Email_Reference_Id__c, WORK_PLAN_EMAIL_REFERENCE_ID)
                .toSObject()
        };

        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Email_Reference_Id__c, WORK_PLAN_EMAIL_REFERENCE_ID)
            .setFakeId()
            .toSObject();

        Set<String> workPlanEmailRefIds = new Set<String>{ WORK_PLAN_EMAIL_REFERENCE_ID };
        Set<Id> workPlanIds = new Set<Id>{ parentWorkPlanId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansByEmailRefId(workPlanEmailRefIds))
            .thenReturn(childWorkPlans);
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectByWorkPlanIds(workPlanIds))
            .thenReturn(parentWorkPlans);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(workOrders);


        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectByEmailReferenceIds(workPlanEmailRefIds)
            )
            .thenReturn(new List<WorkOrder>{ mockWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(inboundEmails);
        System.assertEquals(
            true,
            INBOUND_EMAIL_PLAIN_TEXT_BODY_WITH_REF_ID.contains(WORK_PLAN_EMAIL_REFERENCE_ID),
            EMAIL_MESSAGE_FROM_NAME_NOT_FORMATTED_ASSERT_MESSAGE
        );
    }
}