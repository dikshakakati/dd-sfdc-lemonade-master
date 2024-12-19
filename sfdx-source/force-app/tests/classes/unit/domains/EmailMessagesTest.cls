/**
 * @description EmailMessage Object Trigger Domain class Test
 * @author Deloitte
 * @date 04/30/2024
 */
@isTest(SeeAllData=false)
public class EmailMessagesTest {
    private static final String ASSERT_MESSAGE = 'Field value does not match';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity Name';
    private static final String LEAD_NAME = 'Test Lead Name';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String LEAD_STATUS = 'Untouched';
    private static final String LEAD_COMPANY = 'Test Company';
    private static final String EMAIL = 'Test@gmail.com';
    private static final String LEAD_OBJECT_TYPE = 'Lead';

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<EmailMessage> emailMessageInstantiate = new List<EmailMessage>();
        EmailMessages.newInstance(emailMessageInstantiate);
        EmailMessages newEmailMessage = new EmailMessages(emailMessageInstantiate);
        EmailMessages.Constructor constructorObject = new EmailMessages.Constructor();
        constructorObject.construct(emailMessageInstantiate);
        System.assertNotEquals(
            EmailMessages.newInstance(emailMessageInstantiate),
            newEmailMessage,
            'These objects should not be similar'
        );
    }

    /**
     * @description To test whether Email count field is updated on lead when an EmailMessage is inserted
     */
    @isTest
    private static void testWhenEmailMessageInsertedThenUpdateEmailCountOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Lead 1')
            .setField(Lead.Email, 'abc@abc.com')
            .setField(Lead.Company, 'Example')
            .setField(Lead.Count_of_Emails_Sent__c, 1)
            .toSObject();

        Id emailMessageId = Fake.generateId(EmailMessage.class);
        EmailMessage emailMessage = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.Id, emailMessageId)
            .setField(EmailMessage.subject, 'test')
            .toSObject();

        Id emailMessageRelationId = Fake.generateId(EmailMessageRelation.class);
        EmailMessageRelation emailMessageRelation = (EmailMessageRelation) new Fake(
                EmailMessageRelation.class
            )
            .setField(EmailMessageRelation.Id, emailMessageRelationId)
            .setField(EmailMessageRelation.emailMessageId, emailMessageId)
            .setField(EmailMessageRelation.relationId, lead.Id)
            .setField(EmailMessageRelation.relationType, 'ToAddress')
            .toSObject();

        List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
        emailMessageRelations.add(emailMessageRelation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEmailMessageRelationsSelector selectorMock = (IEmailMessageRelationsSelector) mocks.mock(
            IEmailMessageRelationsSelector.class
        );
        ILeadsSelector mocksLeadsselector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);

        mocks.startStubbing();
        mocks.when(mocksLeadsselector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsselector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.EmailMessageRelation.SObjectType);
        mocks.when(selectorMock.selectByEmailMessageIds(new Set<Id>{ emailMessageId }))
            .thenReturn(new List<EmailMessageRelation>{ emailMessageRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksLeadsselector);

        Test.startTest();
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessage })
            .updateEmailCountWhenEmailMessageInserted();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether First & last Qualified Activity is updated on lead when an EmailMessage is inserted
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmailMessageInsertedThenUpdateFirstAndLastActivityOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Lead 1')
            .setField(Lead.Email, 'abc@abc.com')
            .setField(Lead.Company, 'Example')
            .setField(Lead.Count_of_Emails_Sent__c, 1)
            .toSObject();

        Id emailMessageId = Fake.generateId(EmailMessage.class);
        EmailMessage emailMessage = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.Id, emailMessageId)
            .setField(EmailMessage.subject, 'test')
            .toSObject();

        Id emailMessageRelationId = Fake.generateId(EmailMessageRelation.class);
        EmailMessageRelation emailMessageRelation = (EmailMessageRelation) new Fake(
                EmailMessageRelation.class
            )
            .setField(EmailMessageRelation.Id, emailMessageRelationId)
            .setField(EmailMessageRelation.emailMessageId, emailMessageId)
            .setField(EmailMessageRelation.relationId, lead.Id)
            .setField(EmailMessageRelation.relationType, 'ToAddress')
            .toSObject();

        List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
        emailMessageRelations.add(emailMessageRelation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        IEmailMessageRelationsSelector selectorMock = (IEmailMessageRelationsSelector) mocks.mock(
            IEmailMessageRelationsSelector.class
        );
        ILeadsSelector mocksLeadsselector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);

        mocks.startStubbing();
        mocks.when(mocksLeadsselector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsselector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.EmailMessageRelation.SObjectType);
        mocks.when(selectorMock.selectByEmailMessageIds(new Set<Id>{ emailMessageId }))
            .thenReturn(new List<EmailMessageRelation>{ emailMessageRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksLeadsselector);

        Test.startTest();
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessage })
            .updateEmailCountWhenEmailMessageInserted();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
        Test.stopTest();
    }

    /**
     * @description To test whether Email count field is updated on Contact when an EmailMessage is inserted
     */
    @isTest
    private static void testWhenEmailMessageInsertedThenUpdateEmailCountOnContact() {
        Id contactId = Fake.generateId(Contact.class);
        Contact contact = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, contactId)
            .setField(Contact.LastName, 'Contact 1')
            .setField(Contact.Email, 'abc@abc.com')
            .setField(Contact.Count_of_Emails_Sent__c, 1)
            .toSObject();

        Id emailMessageId = Fake.generateId(EmailMessage.class);
        EmailMessage emailMessage = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.Id, emailMessageId)
            .setField(EmailMessage.subject, 'test')
            .toSObject();

        Id emailMessageRelationId = Fake.generateId(EmailMessageRelation.class);
        EmailMessageRelation emailMessageRelation = (EmailMessageRelation) new Fake(
                EmailMessageRelation.class
            )
            .setField(EmailMessageRelation.Id, emailMessageRelationId)
            .setField(EmailMessageRelation.emailMessageId, emailMessageId)
            .setField(EmailMessageRelation.relationId, contact.Id)
            .setField(EmailMessageRelation.relationType, 'ToAddress')
            .toSObject();

        List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
        emailMessageRelations.add(emailMessageRelation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEmailMessageRelationsSelector selectorMock = (IEmailMessageRelationsSelector) mocks.mock(
            IEmailMessageRelationsSelector.class
        );
        IContactsSelector mocksContactsselector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksContactsselector.sObjectType()).thenReturn(Schema.Contact.SObjectType);
        mocks.when(mocksContactsselector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ contact });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.EmailMessageRelation.SObjectType);
        mocks.when(selectorMock.selectByEmailMessageIds(new Set<Id>{ emailMessageId }))
            .thenReturn(new List<EmailMessageRelation>{ emailMessageRelation });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksContactsselector);

        Test.startTest();
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessage })
            .updateEmailCountWhenEmailMessageInserted();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether Email count field is updated on Opportunity when an EmailMessage is inserted
     */
    @isTest
    private static void testWhenEmailMessageInsertedThenUpdateEmailCountOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Name, 'Opportunity 1')
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.CloseDate, Date.today())
            .setField(Opportunity.Count_of_Emails_Sent__c, 1)
            .toSObject();

        Id emailMessageId = Fake.generateId(EmailMessage.class);
        EmailMessage emailMessage = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.Id, emailMessageId)
            .setField(EmailMessage.subject, 'test')
            .setField(EmailMessage.RelatedToId, opportunityId)
            .setField(EmailMessage.Incoming, false)
            .toSObject();

        Id emailMessageRelationId = Fake.generateId(EmailMessageRelation.class);
        EmailMessageRelation emailMessageRelation = (EmailMessageRelation) new Fake(
                EmailMessageRelation.class
            )
            .setField(EmailMessageRelation.Id, emailMessageRelationId)
            .setField(EmailMessageRelation.emailMessageId, emailMessageId)
            .setField(EmailMessageRelation.relationId, opportunityId)
            .setField(EmailMessageRelation.relationType, 'ToAddress')
            .toSObject();

        List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
        emailMessageRelations.add(emailMessageRelation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEmailMessageRelationsSelector selectorMock = (IEmailMessageRelationsSelector) mocks.mock(
            IEmailMessageRelationsSelector.class
        );
        IOpportunitiesSelector mocksopportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksopportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksopportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.EmailMessageRelation.SObjectType);
        mocks.when(selectorMock.selectByEmailMessageIds(new Set<Id>{ emailMessageId }))
            .thenReturn(new List<EmailMessageRelation>{ emailMessageRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksopportunitiesSelector);

        Test.startTest();
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessage })
            .updateEmailCountWhenEmailMessageInserted();

        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether Last Received Email Date field is updated on Opportunity when an EmailMessage is inserted
     */
    @isTest
    private static void testWhenEmailMessageInsertedThenUpdateLastReceivedEmailDateOnOpportunity() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE)
            .setField(Opportunity.CloseDate, System.Today())
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IEmailMessageRelationsSelector selectorMock = (IEmailMessageRelationsSelector) mocks.mock(
            IEmailMessageRelationsSelector.class
        );
        IOpportunitiesSelector mocksopportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        EmailMessage emailMessageRecord = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.FromAddress, EMAIL)
            .setField(EmailMessage.RelatedToId, opportunity.Id)
            .setFakeId()
            .toSObject();
        EmailMessageRelation emailMessageRelation = (EmailMessageRelation) new Fake(
                EmailMessageRelation.class
            )
            .setField(EmailMessageRelation.EmailMessageId, emailMessageRecord.Id)
            .setField(EmailMessageRelation.RelationId, opportunity.Id)
            .setParent(
                'EmailMessage',
                new Fake(EmailMessage.class)
                    .setField(EmailMessage.Id, emailMessageRecord.Id)
                    .setField(EmailMessage.RelatedToId, opportunity.Id)
                    .setField(EmailMessage.Incoming, true)
            )
            .setFakeId()
            .toSObject();
        mocks.startStubbing();
        mocks.when(mocksopportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksopportunitiesSelector.selectById(new Set<Id>{ opportunity.Id }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.EmailMessageRelation.SObjectType);
        mocks.when(selectorMock.selectByEmailMessageIds(new Set<Id>{ emailMessageRecord.Id }))
            .thenReturn(new List<EmailMessageRelation>{ emailMessageRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.Selector.setMock(mocksopportunitiesSelector);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessageRecord })
            .setLastEmailReceivedDate();
        System.assertEquals(Date.today(), opportunity.Last_Email_Received_Date__c, ASSERT_MESSAGE);
    }

    /**
     * @description To test whether Last Received Email Date field is updated on Lead when an EmailMessage is inserted
     */
    @isTest
    private static void testWhenEmailMessageInsertedThenUpdateLastReceivedEmailDateOnLead() {
        Lead leadRecord = (Lead) new Fake(Lead.class)
            .setField(Lead.Name, LEAD_NAME)
            .setField(Lead.Status, LEAD_STATUS)
            .setField(Lead.Email, EMAIL)
            .setField(Lead.Company, LEAD_COMPANY)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IEmailMessageRelationsSelector selectorMock = (IEmailMessageRelationsSelector) mocks.mock(
            IEmailMessageRelationsSelector.class
        );
        ILeadsSelector mockLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        EmailMessage emailMessageRecord = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.FromAddress, EMAIL)
            .setField(EmailMessage.Incoming, true)
            .setField(EmailMessage.RelatedToId, leadRecord.Id)
            .setFakeId()
            .toSObject();
        EmailMessageRelation emailMessageRelation = (EmailMessageRelation) new Fake(
                EmailMessageRelation.class
            )
            .setField(EmailMessageRelation.EmailMessageId, emailMessageRecord.Id)
            .setField(EmailMessageRelation.RelationId, leadRecord.Id)
            .setField(EmailMessageRelation.RelationObjectType, LEAD_OBJECT_TYPE)
            .setParent(
                'EmailMessage',
                new Fake(EmailMessage.class)
                    .setField(EmailMessage.Id, emailMessageRecord.Id)
                    .setField(EmailMessage.Incoming, true)
            )
            .setFakeId()
            .toSObject();
        mocks.startStubbing();
        mocks.when(mockLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mockLeadsSelector.selectById(new Set<Id>{ leadRecord.Id }))
            .thenReturn(new List<Lead>{ leadRecord });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.EmailMessageRelation.SObjectType);
        mocks.when(selectorMock.selectByEmailMessageIds(new Set<Id>{ emailMessageRecord.Id }))
            .thenReturn(new List<EmailMessageRelation>{ emailMessageRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.Selector.setMock(mockLeadsSelector);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessageRecord })
            .setLastEmailReceivedDate();
        System.assertEquals(Date.today(), leadRecord.Last_Email_Received_Date__c, ASSERT_MESSAGE);
    }

    /**
     * @description To test whether Email Message Inserted then update work plan and work order.
     */
    @isTest
    private static void testWhenEmailMessageInsertedThenUpdateWorkPlanStatus() {
        Id emailMessageId = Fake.generateId(EmailMessage.class);
        Id workPlanId = Fake.generateId(WorkPlan.class);
        Id parentWorkPlanId = Fake.generateId(WorkPlan.class);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        EmailMessage emailMessage = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.Id, emailMessageId)
            .setField(EmailMessage.RelatedToId, workPlanId)
            .setField(EmailMessage.Incoming, false)
            .toSObject();

        List<WorkPlan> childWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, workPlanId)
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
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectByWorkPlanIds(new Set<Id>{ workPlanId }))
            .thenReturn(childWorkPlans);
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectByWorkPlanIds(new Set<Id>{ parentWorkPlanId }))
            .thenReturn(parentWorkPlans);
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(Schema.workOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(workOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);

        Test.startTest();
        EmailMessages.newInstance(new List<EmailMessage>{ emailMessage })
            .updateWorkPlanWhenEmailMessageInserted();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description Tests the `hasRelevantObjectTypes()` helper method, which helps prevent unnecessary processing
    **/
    @IsTest
    static void testWhenPassingSetOfIdsThenEnsureItHasCorrectObjectTypes() {
        Set<Id> contactIds = new Set<Id>{
            Fake.generateId(Contact.class),
            Fake.generateId(Contact.class),
            Fake.generateId(Contact.class)
        };

        Set<Id> leadIds = new Set<Id>{ Fake.generateId(Lead.class), Fake.generateId(Lead.class) };

        Set<Id> oppIds = new Set<Id>{
            Fake.generateId(Opportunity.class),
            Fake.generateId(Opportunity.class),
            Fake.generateId(Opportunity.class)
        };

        Set<Id> mixedIds = new Set<Id>{
            Fake.generateId(Opportunity.class),
            Fake.generateId(Contact.class),
            Fake.generateId(Lead.class),
            Fake.generateId(Account.class)
        };

        // Positive test cases -- a relevant ID is present
        String positiveErrorString = 'The passed SObjectType should be present in the Set';

        System.assert(
            EmailMessages.hasRelevantObjectTypes(contactIds, Contact.SObjectType),
            positiveErrorString
        );
        System.assert(
            EmailMessages.hasRelevantObjectTypes(leadIds, Lead.SObjectType),
            positiveErrorString
        );
        System.assert(
            EmailMessages.hasRelevantObjectTypes(oppIds, Opportunity.SObjectType),
            positiveErrorString
        );
        System.assert(
            EmailMessages.hasRelevantObjectTypes(mixedIds, Contact.SObjectType),
            positiveErrorString
        );
        System.assert(
            EmailMessages.hasRelevantObjectTypes(mixedIds, Lead.SObjectType),
            positiveErrorString
        );
        System.assert(
            EmailMessages.hasRelevantObjectTypes(mixedIds, Opportunity.SObjectType),
            positiveErrorString
        );

        // Negative test cases -- a relevant ID is NOT present
        String negativeErrorMessage = 'This ID type should not be in the set';
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(contactIds, Lead.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(contactIds, Opportunity.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(leadIds, Contact.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(leadIds, Opportunity.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(oppIds, Lead.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(oppIds, Contact.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(null, Lead.SObjectType),
            negativeErrorMessage
        );
        System.assert(
            !EmailMessages.hasRelevantObjectTypes(new Set<Id>(), Lead.SObjectType),
            negativeErrorMessage
        );
    }
}