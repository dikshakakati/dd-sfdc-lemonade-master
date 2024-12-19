/**
 * @author DoorDash
 * @date 07/22/2022
 * @description Test class for OpportunityContactRoleHandler class.
 * Suppressed Warnings since mock verify method does not require System assert statements.
 */
@isTest
public class OpportunityContactRoleHandlerTest {
    private static final String CONTACT_ROLE_MARKETING_CONTACT = 'Marketing Contact';
    /**
     * @description To test execute method of OpportunityContactRoleHandler class
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOppContactRoleIsInsertedThenPopulateQuoteAndDate() {
        Id oppContactRole1 = Fake.generateId(OpportunityContactRole.class);
        Id oppContactRole2 = Fake.generateId(OpportunityContactRole.class);
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(Id = oppContactRole1, Role = 'Contract Signatory'),
            new OpportunityContactRole(Id = oppContactRole2, Role = CONTACT_ROLE_MARKETING_CONTACT)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IOpportunityContactRoles oppContactRoleMock = (IOpportunityContactRoles) mocks.mock(
            IOpportunityContactRoles.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleMock.getType())
            .thenReturn(Schema.OpportunityContactRole.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(oppContactRoleMock);
        OpportunityContactRoles.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onInsert(oppContactRoleList);
        fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);

        ((IOpportunityContactRoles) mocks.verify(oppContactRoleMock, 1))
            .populateQuoteOnOpportunityContactRole();
        ((IOpportunityContactRoles) mocks.verify(oppContactRoleMock, 1))
            .populateFieldsWhenOpportunityContactRoleCreated();
    }
    /**
     * @description To test execute method of OpportunityContactRoleHandler class
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOppContactRoleIsUpdatedThenPopulateOppQuote() {
        Id oppContactRole1 = Fake.generateId(OpportunityContactRole.class);
        Id oppContactRole2 = Fake.generateId(OpportunityContactRole.class);

        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(Id = oppContactRole1, Role = 'Contract Signatory'),
            new OpportunityContactRole(Id = oppContactRole2, Role = 'Marketing Signatory')
        };
        List<OpportunityContactRole> oldOppContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(Id = oppContactRole1, Role = CONTACT_ROLE_MARKETING_CONTACT),
            new OpportunityContactRole(Id = oppContactRole2, Role = CONTACT_ROLE_MARKETING_CONTACT)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoles oppContactRoleMock = (IOpportunityContactRoles) mocks.mock(
            IOpportunityContactRoles.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleMock.getType())
            .thenReturn(Schema.OpportunityContactRole.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(oppContactRoleMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            oppContactRoleList,
            new Map<Id, OpportunityContactRole>(oldOppContactRoleList)
        );
        fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);

        ((IOpportunityContactRoles) mocks.verify(oppContactRoleMock, 1))
            .populateQuoteOnOpportunityContactRole();
    }

    /**
     * @description To test calling of domain class method to populate date when Opportunity
     * Contact Role is marked primary.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityContactRoleMarkedPrimaryThenPopulateDate() {
        Id opportunityContactRole1Id = Fake.generateId(OpportunityContactRole.class);
        Id opportunityContactRole2Id = Fake.generateId(OpportunityContactRole.class);
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole1Id,
                IsPrimary = true,
                Role = CONTACT_ROLE_MARKETING_CONTACT
            ),
            new OpportunityContactRole(
                Id = opportunityContactRole2Id,
                IsPrimary = false,
                Role = CONTACT_ROLE_MARKETING_CONTACT
            )
        };
        List<OpportunityContactRole> oldOpportunityContactRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole1Id,
                IsPrimary = false,
                Role = CONTACT_ROLE_MARKETING_CONTACT
            ),
            new OpportunityContactRole(
                Id = opportunityContactRole2Id,
                IsPrimary = true,
                Role = CONTACT_ROLE_MARKETING_CONTACT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoles opportunityContactRoleMock = (IOpportunityContactRoles) mocks.mock(
            IOpportunityContactRoles.class
        );
        mocks.startStubbing();
        mocks.when(opportunityContactRoleMock.getType())
            .thenReturn(Schema.OpportunityContactRole.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(opportunityContactRoleMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            opportunityContactRoles,
            new Map<Id, OpportunityContactRole>(oldOpportunityContactRoles)
        );
        fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);
        ((IOpportunityContactRoles) mocks.verify(opportunityContactRoleMock, 1))
            .populateDateWhenOpportunityContactRoleMarkedPrimary(
                new Map<Id, OpportunityContactRole>(oldOpportunityContactRoles)
            );
    }
    /**
     * @description To test if updatePrimaryContactOnOpportunities is called when Opportunity Contact
     * Role is updated to Primary.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityContactRoleUpdatedAsPrimaryThenPopulatePrimaryContactOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id opportunityContactRole = Fake.generateId(OpportunityContactRole.class);
        List<OpportunityContactRole> oldOpportunityContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole,
                Role = 'Contract Signatory',
                IsPrimary = false,
                OpportunityId = opportunityId
            )
        };
        List<OpportunityContactRole> newOpportunityContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole,
                Role = 'Contract Signatory',
                IsPrimary = true,
                OpportunityId = opportunityId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IOpportunityContactRoles opportunityContactRoleMock = (IOpportunityContactRoles) mocks.mock(
            IOpportunityContactRoles.class
        );
        mocks.startStubbing();
        mocks.when(opportunityContactRoleMock.getType())
            .thenReturn(Schema.OpportunityContactRole.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(opportunityContactRoleMock);
        OpportunityContactRoles.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newOpportunityContactRoleList,
            new Map<Id, OpportunityContactRole>(oldOpportunityContactRoleList)
        );
        fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);

        ((IOpportunityContactRoles) mocks.verify(opportunityContactRoleMock, 1))
            .updatePrimaryContactOnOpportunities();
    }
    /**
     * @description To test if updatePrimaryContactOnOpportunities is called when Opportunity Contact
     * Role is inserted as non Primary.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityContactRoleInsertedAsNonPrimaryThenUpdatePrimaryContactOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id opportunityContactRole = Fake.generateId(OpportunityContactRole.class);
        List<OpportunityContactRole> newOpportunityContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole,
                Role = 'Contract Signatory',
                IsPrimary = false,
                OpportunityId = opportunityId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IOpportunityContactRoles opportunityContactRoleMock = (IOpportunityContactRoles) mocks.mock(
            IOpportunityContactRoles.class
        );
        mocks.startStubbing();
        mocks.when(opportunityContactRoleMock.getType())
            .thenReturn(Schema.OpportunityContactRole.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(opportunityContactRoleMock);
        OpportunityContactRoles.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onInsert(
            newOpportunityContactRoleList
        );
        fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);

        ((IOpportunityContactRoles) mocks.verify(opportunityContactRoleMock, 1))
            .updatePrimaryContactOnOpportunities();
    }
    /**
     * @description To test if updatePrimaryContactOnOpportunities is called when Opportunity Contact
     * Role is inserted as Primary.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityContactRoleInsertedAsPrimaryThenUpdatePrimaryContactOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id opportunityContactRole = Fake.generateId(OpportunityContactRole.class);
        List<OpportunityContactRole> newOpportunityContactRoleList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole,
                Role = 'Contract Signatory',
                IsPrimary = true,
                OpportunityId = opportunityId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IOpportunityContactRoles opportunityContactRoleMock = (IOpportunityContactRoles) mocks.mock(
            IOpportunityContactRoles.class
        );
        mocks.startStubbing();
        mocks.when(opportunityContactRoleMock.getType())
            .thenReturn(Schema.OpportunityContactRole.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(opportunityContactRoleMock);
        OpportunityContactRoles.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onInsert(
            newOpportunityContactRoleList
        );
        fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);

        ((IOpportunityContactRoles) mocks.verify(opportunityContactRoleMock, 1))
            .updatePrimaryContactOnOpportunities();
    }
}