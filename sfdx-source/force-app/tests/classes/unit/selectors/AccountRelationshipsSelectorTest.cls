/**
 * @author Deloitte
 * @date 06/04/2022
 * @description Test class for Account Relationship Selector
 */
@isTest(seeAllData=false)
public class AccountRelationshipsSelectorTest {
    @testSetup
    static void setupAccountRelationshipData() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 3', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 4', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 5', Segment__c = 'Enterprise')
        };
        insert accountList;

        List<Account_Relationship__c> relationshipRec = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Agency',
                End_Date__c = System.today().addDays(-1),
                Account__c = accountList[0].Id,
                Relationship_Status__c = 'Active',
                Related_Account__c = accountList[1].Id
            ),
            new Account_Relationship__c(
                Relationship_Type__c = 'AdTech',
                Inverse_Relationship_Type__c = 'Agency',
                End_Date__c = Date.today().addDays(3),
                Account__c = accountList[0].Id,
                Relationship_Status__c = 'Active',
                Related_Account__c = accountList[1].Id
            ),
            new Account_Relationship__c(
                Relationship_Type__c = 'Franchise',
                Inverse_Relationship_Type__c = 'Franchise',
                End_Date__c = Date.today().addDays(3),
                Account__c = accountList[1].Id,
                Relationship_Status__c = 'Active',
                Related_Account__c = accountList[2].Id
            ),
            new Account_Relationship__c(
                Relationship_Type__c = 'Franchise',
                Inverse_Relationship_Type__c = 'Franchise',
                End_Date__c = Date.today().addDays(3),
                Account__c = accountList[1].Id,
                Relationship_Status__c = 'Active',
                Related_Account__c = accountList[3].Id
            ),
            new Account_Relationship__c(
                Relationship_Type__c = 'Franchise',
                Inverse_Relationship_Type__c = 'Franchise',
                End_Date__c = Date.today().addDays(3),
                Account__c = accountList[1].Id,
                Relationship_Status__c = 'Active',
                Related_Account__c = accountList[4].Id
            )
        };
        insert relationshipRec;
    }

    @isTest
    private static void testWhenExternalIdsAreSentThenRelevantRelationshipRecordsAreFetched() {
        AccountRelationshipsSelector relationshipSelector = new AccountRelationshipsSelector();
        Id accountParent1 = [SELECT Id FROM Account WHERE Name = 'Parent 1'][0].Id;
        Id accountParent2 = [SELECT Id FROM Account WHERE Name = 'Parent 2'][0].Id;

        Test.startTest();
        List<Account_Relationship__c> fetchedRelationships = relationshipSelector.selectRelationshipsWithExternalIds(
            new Set<String>{
                accountParent1 +
                'Agency' +
                accountParent2 +
                'Agency',
                accountParent1 +
                'Agency' +
                accountParent2 +
                'AdTech'
            }
        );
        Test.stopTest();

        System.assertEquals(
            2,
            fetchedRelationships.size(),
            'The expected records were not fetched'
        );
    }

    @isTest
    private static void testWhenRelationshipsHaveExternalIdsThenTheyAreFetched() {
        AccountRelationshipsSelector relationshipSelector = new AccountRelationshipsSelector();

        Test.startTest();
        List<Account_Relationship__c> fetchedRelationships = relationshipSelector.selectAllRelationshipsWithExternalIds();
        Test.stopTest();

        System.assertEquals(
            10,
            fetchedRelationships.size(),
            'The expected records were not fetched'
        );
    }

    @isTest
    private static void testWhenQueryIsRunThenActiveAccountsWithPastEndDatesAreFetched() {
        AccountRelationshipsSelector relationshipSelector = new AccountRelationshipsSelector();

        Test.startTest();
        Database.QueryLocator queryAccount = relationshipSelector.selectActiveRelationshipsWithPastEndDates();
        Test.stopTest();

        Database.QueryLocatorIterator iteratorOnAccountRelationship = queryAccount.iterator();

        List<Account_Relationship__c> fetchedRelationship = new List<Account_Relationship__c>();

        while (iteratorOnAccountRelationship.hasNext()) {
            fetchedRelationship.add((Account_Relationship__c) iteratorOnAccountRelationship.next());
        }

        System.assertEquals(
            'Active',
            fetchedRelationship[0].Relationship_Status__c,
            'The expected Relationship is not Updated to Inactive'
        );

        System.assertEquals(
            2,
            fetchedRelationship.size(),
            'The expected number of Records were not retrieved'
        );
        System.assertEquals(
            System.today().addDays(-1),
            fetchedRelationship[0].End_Date__c,
            'The expected record was not fetched'
        );
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        AccountRelationshipsSelector relationshipSelectorInstance = new AccountRelationshipsSelector();

        Test.startTest();
        Schema.SObjectType typeOfObj = relationshipSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = relationshipSelectorInstance.getSObjectFieldList();

        AccountRelationshipsSelector.newInstance();
        Test.stopTest();

        System.assertEquals(
            Schema.Account_Relationship__c.SObjectType,
            typeOfObj,
            'The object type must be Account Relationship'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Account_Relationship__c.Id,
                Account_Relationship__c.Name,
                Account_Relationship__c.Account__c,
                Account_Relationship__c.Related_Account__c,
                Account_Relationship__c.Relationship_Status__c,
                Account_Relationship__c.End_Date__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }
}