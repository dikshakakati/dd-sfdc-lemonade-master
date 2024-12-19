/**
 * @description This is Integration Test class for OpportunitiesHandler class
 * @author Deloitte
 * @date 24/05/2022
 */
@isTest(SeeAllData=false)
public class OpportunitiesIntegrationTest {
    private static final String ENTERPRISE = 'Enterprise';
    /**
     * @description Test OpportunitiesHandler class on Opportunity Updation
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityUpdatedByBypassUserThenCall() {
        PermissionSet bypassPermissions = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Bypass_Opportunity_Validations'
        ];
        PermissionSetAssignment bypassAssignment = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = bypassPermissions.Id
        );
        insert bypassAssignment;

        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };
        Integer year = System.today().year();
        String month = '6';
        String day = '17';
        String calculatedCloseDate = year + '-' + month + '-' + day;
        Date opportunityCloseDate = Date.valueOf(calculatedCloseDate);
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                AccountId = accountList[0].Id,
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Lite',
                CloseDate = opportunityCloseDate,
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test'
            ),
            new Opportunity(
                Name = 'Test2',
                AccountId = accountList[0].Id,
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Standard',
                CloseDate = opportunityCloseDate,
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test'
            )
        };
        Map<Id, Opportunity> testMap = new Map<Id, Opportunity>(opportunityList);
        testMap.values()[0].Name = 'Test1v2';
        testMap.values()[1].Name = 'Test2v2';

        fflib_SObjectDomain.Test.Database.onUpdate(opportunityList, testMap);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunityList);
        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunityList)).thenReturn(accountList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            opptInstance.validateOpportunityNameChange(testMap);
            opptInstance.assignNameOnInsertOrNameUpdate();
        }
        String last2DigitsOfYear = String.valueOf(opportunityList[0].CloseDate.year()).right(2);
        System.assertEquals(
            'Parent 1 - Q2 ' + last2DigitsOfYear + ' - test: Test1v2',
            opportunityList[0].Name,
            'Unexpected Error: The Opportunity Name has not been updated on direct update to the Name field.'
        );
    }

    /**
     * @description This method is used to test if Apex Error is thrown on insertion of Opportunity of type New
     * on an Account that has an activated contract.
     */
    @isTest
    private static void testWhenNewOpportunityIsInsertedOnAccountWithActivatedContractThenPreventCreation() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = ENTERPRISE),
            new Account(Name = 'Parent 2', Segment__c = ENTERPRISE)
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Type = 'New',
                Pricebook2Id = pricebookId,
                Opportunity_Sub_Type__c = 'Upgrade',
                Deal_Type__c = 'Standard'
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = 'Upgrade',
                Type = 'Existing',
                Pricebook2Id = pricebookId,
                Deal_Type__c = 'Standard'
            )
        };
        insert opportunityList;

        Contract testContract1 = new Contract(
            Name = 'Test Contract1',
            AccountId = accountList[0].Id
        );
        insert testContract1;

        IOpportunities opptInstance = Opportunities.newInstance(opportunityList);
        opptInstance.assignContractAndPreventOpportunityNewTypeCreation();
        System.assertEquals(
            System.Label.New_Opportunity_On_Account_With_Activated_Contract_Error,
            fflib_SObjects.Errors.getAll()[0].message,
            'Unexpected Error: The Opportunity creation was successful and the error was not fired as expected.'
        );
    }
}