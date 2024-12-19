/**
 * @author Deloitte
 * @date 04/08/2024
 * @description Test class for OpportunityContactRoles class.
 */
@isTest(seeAllData=false)
private class OpportunityContactRolesTest {
    private static final String CONTACT_ROLE_CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String CONTACT_ROLE_MARKETING_CONTACT = 'Marketing Contact';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: the objects are matching';
    private static final String INCORRECT_CONTACT_ADDED_DATE_ASSERT_MESSAGE = 'Unexpected result: incorrect Contact added date populated';
    private static final String INCORRECT_PRIMARY_CONTACT_CONFIRMED_DATE_ASSERT_MESSAGE = 'Unexpected result: incorrect primary Contact confirmed date populated';
    private static final String MISMATCH_QUOTE_ASSERT_MESSAGE = 'Unexpected result: mismatch in quote Id';
    private static final String OPPORTUNITY_NAME = 'Test 1';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String OPPORTUNITY_TYPE = 'New';
    private static final String OPPORTUNITY_DEAL_TYPE = 'Standard';
    private static final String OPPORTUNITY_FORECAST_CATEGORY = 'Pipeline';

    /**
     * @description It is used to test instantiation of class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
        OpportunityContactRoles.newInstance(oppContactRoles);
        OpportunityContactRoles oppContactRolesObject = new OpportunityContactRoles(
            oppContactRoles
        );
        OpportunityContactRoles.Constructor constructorObject = new OpportunityContactRoles.Constructor();
        constructorObject.construct(oppContactRoles);
        System.assertNotEquals(
            OpportunityContactRoles.newInstance(oppContactRoles),
            oppContactRolesObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when a OpportunityContactRole inserted then 'Contact Role Added Date'
     * updated to today's date.
     */
    @isTest
    private static void testWhenOpportunityContactRoleIsInsertedThenPopulateDate() {
        Id opportunityContactRole1Id = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id opportunityContactRole2Id = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        List<OpportunityContactRole> mockOpportunityContactRoles = new List<OpportunityContactRole>{
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
        OpportunityContactRoles.newInstance(mockOpportunityContactRoles)
            .populateFieldsWhenOpportunityContactRoleCreated();
        System.assertEquals(
            System.today(),
            mockOpportunityContactRoles[0].Primary_Contact_Confirmed_Date__c,
            INCORRECT_CONTACT_ADDED_DATE_ASSERT_MESSAGE
        );
        System.assertEquals(
            System.today(),
            mockOpportunityContactRoles[1].Contact_Role_Added_Date__c,
            INCORRECT_CONTACT_ADDED_DATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when a OpportunityContactRole is marked primary then
     * 'Primary Contact Confirmed Date' is updated to current date.
     */
    @isTest
    private static void testWhenOpportunityContactRoleMarkedPrimaryThenPopulatePrimaryContactConfirmedDate() {
        Id opportunityContactRole1Id = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id opportunityContactRole2Id = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        List<OpportunityContactRole> mockOpportunityContactRoles = new List<OpportunityContactRole>{
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
        OpportunityContactRoles.newInstance(mockOpportunityContactRoles)
            .populateDateWhenOpportunityContactRoleMarkedPrimary(
                new Map<Id, OpportunityContactRole>(oldOpportunityContactRoles)
            );
        System.assertEquals(
            System.today(),
            mockOpportunityContactRoles[0].Primary_Contact_Confirmed_Date__c,
            INCORRECT_PRIMARY_CONTACT_CONFIRMED_DATE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            mockOpportunityContactRoles[1].Primary_Contact_Confirmed_Date__c,
            INCORRECT_PRIMARY_CONTACT_CONFIRMED_DATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test execute method of OpportunityContactRoleHandler class
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOppContactRoleIsInsertedThenPopulateQuote() {
        Id opportunityContactRole1Id = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id opportunityContactRole2Id = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Opportunity relatedOpportunity = new Opportunity(
            Id = opportunityId,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Type = OPPORTUNITY_TYPE,
            AccountId = fflib_IDGenerator.generate(Account.SObjectType),
            Probability = 30,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE,
            ForecastCategoryName = OPPORTUNITY_FORECAST_CATEGORY,
            CloseDate = System.today().addMonths(3),
            SBQQ__PrimaryQuote__c = quoteId
        );
        List<OpportunityContactRole> mockOpportunityContactRoles = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = opportunityContactRole1Id,
                OpportunityId = relatedOpportunity.Id,
                Role = CONTACT_ROLE_CONTRACT_SIGNATORY
            ),
            new OpportunityContactRole(
                Id = opportunityContactRole2Id,
                OpportunityId = relatedOpportunity.Id,
                Role = CONTACT_ROLE_MARKETING_CONTACT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitiesSelectorMock.selectOpportunitiesWithQuotes(
                    new Set<Id>{ relatedOpportunity.Id }
                )
            )
            .thenReturn(new List<Opportunity>{ relatedOpportunity });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        OpportunityContactRoles.newInstance(mockOpportunityContactRoles)
            .populateQuoteOnOpportunityContactRole();
        System.assertEquals(
            quoteId,
            mockOpportunityContactRoles[0].Quote__c,
            MISMATCH_QUOTE_ASSERT_MESSAGE
        );
        System.assertNotEquals(
            quoteId,
            mockOpportunityContactRoles[1].Quote__c,
            MISMATCH_QUOTE_ASSERT_MESSAGE
        );
    }
}