/**
 * @author Deloitte
 * @date 24/03/2022
 * @description This is test class for OpportunityContactRoleSelector class
 */
@isTest
private class OpportunityContactRoleSelectorTest {
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        OpportunityContactRoleSelector contactRoleSelectorInstance = new OpportunityContactRoleSelector();

        Schema.SObjectType typeOfObj = contactRoleSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = contactRoleSelectorInstance.getSObjectFieldList();

        OpportunityContactRoleSelector.newInstance();
        System.assertEquals(
            Schema.OpportunityContactRole.SObjectType,
            typeOfObj,
            'The object type must be OpportunityContactRole'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                OpportunityContactRole.Id,
                OpportunityContactRole.CurrencyIsoCode,
                OpportunityContactRole.ContactId,
                OpportunityContactRole.OpportunityId,
                OpportunityContactRole.Role,
                OpportunityContactRole.Quote__c,
                OpportunityContactRole.IsPrimary
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenIdIsSentThenReturnRecords() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
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
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'UserTest',
                AccountId = accountList[0].Id,
                Email = 'abc1@gmail.com'
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'UserTester',
                AccountId = accountList[0].Id,
                Email = 'abc2@gmail.com'
            )
        };
        insert contactList;

        List<OpportunityContactRole> opportunityContactList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[0].Id
            ),
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[1].Id
            )
        };

        insert opportunityContactList;

        List<OpportunityContactRole> oppContactRole = new OpportunityContactRoleSelector()
            .selectById(new Set<Id>{ opportunityContactList[0].Id, opportunityContactList[1].Id });

        System.assertEquals(
            opportunityList[0].Id,
            oppContactRole[0].OpportunityId,
            'The parent Opportunity is mismatching'
        );
        System.assertEquals(
            2,
            oppContactRole.size(),
            'The retrieved List should contain two records'
        );
    }

    @isTest
    private static void testWhenOpportunityIdIsSentThenCorresponsingContactRolesAreRetrieved() {
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(5)
        );

        OpportunityContactRoleSelector contactRoleSelectorInstance = new OpportunityContactRoleSelector();
        List<OpportunityContactRole> oppContactRole = contactRoleSelectorInstance.selectByOpportunity(
            new Set<Id>{ testOpportunity1.Id }
        );
        OpportunityContactRoleSelector.newInstance();
        System.assertEquals(
            oppContactRole.size() != null,
            true,
            'OpportunityContactRole List Empty'
        );
    }

    @isTest
    private static void testWhenOpportunityIdIsSentThenCorrespondingContactRolesAreRetrieved() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
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
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'UserTest',
                AccountId = accountList[0].Id,
                Email = 'abc1@gmail.com'
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'UserTester',
                AccountId = accountList[0].Id,
                Email = 'abc2@gmail.com'
            )
        };
        insert contactList;

        List<OpportunityContactRole> opportunityContactList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[0].Id,
                Role = 'Contract Signatory',
                IsPrimary = true
            ),
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[1].Id,
                Role = 'Marketing Contact'
            )
        };

        insert opportunityContactList;

        OpportunityContactRoleSelector contactRoleSelectorInstance = new OpportunityContactRoleSelector();
        List<OpportunityContactRole> oppContactRole = contactRoleSelectorInstance.selectPrimaryOrContractSignatoryOpportunityContactRoleByOpportunity(
            new Set<Id>{ opportunityList[0].Id }
        );
        OpportunityContactRoleSelector.newInstance();
        System.assertEquals(oppContactRole.size() == 1, true, 'OpportunityContactRole List Empty');
    }

    @isTest
    private static void testWhenOppIdIsSentThenReturnContractSignatoryContactRoles() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
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
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'UserTest',
                AccountId = accountList[0].Id,
                Email = 'abc1@gmail.com'
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'UserTester',
                AccountId = accountList[0].Id,
                Email = 'abc2@gmail.com'
            )
        };
        insert contactList;

        List<OpportunityContactRole> opportunityContactList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[0].Id,
                Role = 'Contract Signatory'
            ),
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[1].Id,
                Role = 'Marketing Contact'
            )
        };

        insert opportunityContactList;

        OpportunityContactRoleSelector contactRoleSelectorInstance = new OpportunityContactRoleSelector();
        List<OpportunityContactRole> oppContactRoleList = contactRoleSelectorInstance.selectContractSignatoryOppContactRole(
            new Set<Id>{ opportunityList[0].Id }
        );
        OpportunityContactRoleSelector.newInstance();
        System.assertEquals(oppContactRoleList.size(), 1, 'OpportunityContactRole List Empty');
    }

    @isTest
    private static void testWhenQuoteIdIsSentThenReturnContractSignatoryContactRoles() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = Date.newInstance(2024, 5, 17),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opportunityList[0].Id,
                SBQQ__StartDate__c = System.today(),
                SBQQ__Primary__c = true
            )
        };
        insert quoteList;

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'UserTest',
                AccountId = accountList[0].Id,
                Email = 'abc1@gmail.com'
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'UserTester',
                AccountId = accountList[0].Id,
                Email = 'abc2@gmail.com'
            )
        };
        insert contactList;

        List<OpportunityContactRole> opportunityContactList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[0].Id,
                Role = 'Contract Signatory'
            ),
            new OpportunityContactRole(
                OpportunityId = opportunityList[0].Id,
                ContactId = contactList[1].Id,
                Role = 'Marketing Contact'
            )
        };

        insert opportunityContactList;

        OpportunityContactRoleSelector contactRoleSelectorInstance = new OpportunityContactRoleSelector();
        List<OpportunityContactRole> oppContactRoleList = contactRoleSelectorInstance.selectByQuoteIdAndFilterByContractSignatory(
            new Set<Id>{ quoteList[0].Id }
        );
        OpportunityContactRoleSelector.newInstance();
        System.assertEquals(oppContactRoleList.size(), 1, 'OpportunityContactRole List Empty');
    }
}