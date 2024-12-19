/**
 * @author Deloitte
 * @date 31/05/2022
 * @description Test class for DecisionMakerCalculationServiceImpl class.
 */
@isTest(seeAllData=false)
private class DecisionMakerCalculationServiceImplTest {
    private static final String ASSERT_MESSAGE_ACCOUNTCONTACTRELATIONSHIP_ID = 'Unexpected result: Account Contact Relationship Id is not matching';
    private static final String ASSERT_MESSAGE_CONTACT_ID = 'Unexpected result: Contact Id is not matching';
    private static final String ASSERT_MESSAGE_OPPORTUNITYCONTACTROLE_ID = 'Unexpected result: Opportunity Contact Role Id is not matching';
    private static final string ROLE = 'Decision Maker';

    /**
     * @description To test Decision Makers when WorkOrders are passed.
     */
    @isTest
    private static void testWhenGetDecisionMakerThenCalculateDecisionMakers() {
        Id accountContactRelationId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        AccountContactRelation mockAccountContactRelation = (AccountContactRelation) new Fake(
                AccountContactRelation.class
            )
            .setField(AccountContactRelation.Id, accountContactRelationId)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.ContactId, contactId)
            .setField(AccountContactRelation.Roles, ROLE)
            .toSObject();
        OpportunityContactRole mockOpportunityContactRole = (OpportunityContactRole) new Fake(
                OpportunityContactRole.class
            )
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.OpportunityId, opportunityId)
            .setField(OpportunityContactRole.ContactId, opportunityContactId)
            .setField(OpportunityContactRole.IsPrimary, true)
            .toSObject();
        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(AccountId = storeAccountId, Opportunity__c = opportunityId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IOpportunityContactRoleSelector opportunityContactRolesSelector = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ mockAccountContactRelation });
        mocks.when(opportunityContactRolesSelector.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                opportunityContactRolesSelector.selectByOpportunity(new Set<Id>{ opportunityId })
            )
            .thenReturn(new List<OpportunityContactRole>{ mockOpportunityContactRole });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(opportunityContactRolesSelector);
        Test.startTest();
        DecisionMakerCalculationService.getDecisionMakers(workOrders);
        Test.stopTest();
        System.assertEquals(
            contactId,
            mockAccountContactRelation.ContactId,
            ASSERT_MESSAGE_CONTACT_ID
        );
        System.assertEquals(
            opportunityContactId,
            mockOpportunityContactRole.ContactId,
            ASSERT_MESSAGE_CONTACT_ID
        );
    }

    /**
     * @description To test getting "Opportunity Contact Role" and "Account Contact Relationship" Ids when WorkOrders are passed.
     */
    @isTest
    private static void testWhenOCRAndACRExistsThenReturnOCRAndACRIds() {
        Id accountContactRelationId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        AccountContactRelation mockAccountContactRelation = (AccountContactRelation) new Fake(
                AccountContactRelation.class
            )
            .setField(AccountContactRelation.Id, accountContactRelationId)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.ContactId, contactId)
            .setField(AccountContactRelation.Roles, ROLE)
            .toSObject();
        OpportunityContactRole mockOpportunityContactRole = (OpportunityContactRole) new Fake(
                OpportunityContactRole.class
            )
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.OpportunityId, opportunityId)
            .setField(OpportunityContactRole.ContactId, opportunityContactId)
            .setField(OpportunityContactRole.IsPrimary, true)
            .toSObject();
        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(AccountId = storeAccountId, Opportunity__c = opportunityId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IOpportunityContactRoleSelector opportunityContactRolesSelector = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ mockAccountContactRelation });
        mocks.when(opportunityContactRolesSelector.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                opportunityContactRolesSelector.selectByOpportunity(new Set<Id>{ opportunityId })
            )
            .thenReturn(new List<OpportunityContactRole>{ mockOpportunityContactRole });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(opportunityContactRolesSelector);
        Test.startTest();
        DecisionMakerCalculationService.getOCRAndACRIds(workOrders);
        Test.stopTest();
        System.assertEquals(
            accountContactRelationId,
            mockAccountContactRelation.Id,
            ASSERT_MESSAGE_ACCOUNTCONTACTRELATIONSHIP_ID
        );
        System.assertEquals(
            opportunityContactRoleId,
            mockOpportunityContactRole.Id,
            ASSERT_MESSAGE_OPPORTUNITYCONTACTROLE_ID
        );
    }

    /**
     * @description To test getting "Opportunity Contact Role" Ids when WorkOrders are passed.
     */
    @isTest
    private static void testWhenOCRExistsThenReturnOCRIds() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        OpportunityContactRole mockOpportunityContactRole = (OpportunityContactRole) new Fake(
                OpportunityContactRole.class
            )
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.OpportunityId, opportunityId)
            .setField(OpportunityContactRole.ContactId, opportunityContactId)
            .setField(OpportunityContactRole.IsPrimary, true)
            .toSObject();
        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(AccountId = storeAccountId, Opportunity__c = opportunityId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector opportunityContactRolesSelector = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunityContactRolesSelector.sObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                opportunityContactRolesSelector.selectByOpportunity(new Set<Id>{ opportunityId })
            )
            .thenReturn(new List<OpportunityContactRole>{ mockOpportunityContactRole });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(opportunityContactRolesSelector);
        Test.startTest();
        DecisionMakerCalculationService.getOCRAndACRIds(workOrders);
        Test.stopTest();
        System.assertEquals(
            opportunityContactRoleId,
            mockOpportunityContactRole.Id,
            ASSERT_MESSAGE_OPPORTUNITYCONTACTROLE_ID
        );
    }

    /**
     * @description To test getting "Account Contact Relationship" Ids when WorkOrders are passed.
     */
    @isTest
    private static void testWhenACRExistsThenReturnACRIds() {
        Id accountContactRelationId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        AccountContactRelation mockAccountContactRelation = (AccountContactRelation) new Fake(
                AccountContactRelation.class
            )
            .setField(AccountContactRelation.Id, accountContactRelationId)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.ContactId, contactId)
            .setField(AccountContactRelation.Roles, ROLE)
            .toSObject();
        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(AccountId = storeAccountId, Opportunity__c = opportunityId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ mockAccountContactRelation });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Test.startTest();
        DecisionMakerCalculationService.getOCRAndACRIds(workOrders);
        Test.stopTest();
        System.assertEquals(
            accountContactRelationId,
            mockAccountContactRelation.Id,
            ASSERT_MESSAGE_ACCOUNTCONTACTRELATIONSHIP_ID
        );
    }
}