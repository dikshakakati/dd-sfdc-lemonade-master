/**
 * @author Deloitte
 * @date 25/05/2022
 * @description Integration Test class for AccountRelationships
 */
@isTest
public class AccountRelationshipsIntegrationTest {
    @testSetup
    static void setupRelationshipData() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Account_Relationship__c accountRelationship = new Account_Relationship__c(
            Relationship_Type__c = 'Agency',
            Inverse_Relationship_Type__c = 'Measurement Partner',
            Account__c = accountList[0].Id,
            Relationship_Status__c = 'Active',
            Related_Account__c = accountList[1].Id
        );
        insert accountRelationship;
    }

    @isTest
    private static void testWhenRelationshipsAreInsertedThenReciprocalRelationshipsAreCreated() {
        List<Account_Relationship__c> insertedRelationship = [
            SELECT
                Id,
                Name,
                Relationship_Type__c,
                Relationship_Status__c,
                Inverse_Relationship_Type__c,
                Account__c,
                Related_Account__c,
                External_Id__c
            FROM Account_Relationship__c
            WHERE Relationship_Type__c = 'Agency'
        ];
        List<Account_Relationship__c> allRelationships = [
            SELECT
                Id,
                Name,
                Relationship_Type__c,
                Relationship_Status__c,
                Inverse_Relationship_Type__c,
                Account__c,
                Related_Account__c,
                External_Id__c
            FROM Account_Relationship__c
            ORDER BY Name
        ];
        System.assertEquals(
            insertedRelationship[0].Account__c +
            insertedRelationship[0].Inverse_Relationship_Type__c +
            insertedRelationship[0].Related_Account__c +
            insertedRelationship[0].Relationship_Type__c,
            allRelationships[0].External_Id__c,
            'The External Id was not autopopulated as expected'
        );
        System.assertEquals(2, allRelationships.size(), 'The reciprocal record was not generated.');
        System.assertEquals(
            insertedRelationship[0].Related_Account__c +
            insertedRelationship[0].Relationship_Type__c +
            insertedRelationship[0].Account__c +
            insertedRelationship[0].Inverse_Relationship_Type__c,
            allRelationships[1].External_Id__c,
            'The External Id of the reciprocal relationship was not autopopulated appropriately.'
        );
    }

    @isTest
    private static void testWhenRelationshipsAreUpdatedThenReciprocalRelationshipsAreUpdated() {
        List<Account_Relationship__c> insertedRelationship = [
            SELECT
                Id,
                Name,
                Relationship_Type__c,
                Relationship_Status__c,
                Inverse_Relationship_Type__c,
                Account__c,
                Related_Account__c
            FROM Account_Relationship__c
            WHERE Relationship_Type__c = 'Agency'
        ];
        List<Account_Relationship__c> reciprocalRelationship = [
            SELECT
                Id,
                Name,
                Relationship_Type__c,
                Relationship_Status__c,
                Inverse_Relationship_Type__c,
                Account__c,
                Related_Account__c
            FROM Account_Relationship__c
            WHERE Inverse_Relationship_Type__c = 'Agency'
        ];
        //Before Update Assertions
        System.assertNotEquals(
            null,
            reciprocalRelationship[0],
            'Unexpected Error: The expected reciprocal Account Relationship record was not created/fetched correctly.'
        );
        System.assertEquals(
            'Agency',
            reciprocalRelationship[0].Inverse_Relationship_Type__c,
            'Unexpected Error: The reciprocal Relationship was not created appropriately'
        );

        insertedRelationship[0].Relationship_Type__c = 'AdTech';

        Test.startTest();
        update insertedRelationship;
        Test.stopTest();

        //Fetch New Records
        Map<Id, Account_Relationship__c> afterUpdateStateOfRelationships = new Map<Id, Account_Relationship__c>(
            [
                SELECT
                    Id,
                    Name,
                    External_Id__c,
                    Relationship_Type__c,
                    Relationship_Status__c,
                    Inverse_Relationship_Type__c,
                    Account__c,
                    Related_Account__c
                FROM Account_Relationship__c
            ]
        );

        System.assertEquals(
            'AdTech',
            afterUpdateStateOfRelationships.get(insertedRelationship[0].Id).Relationship_Type__c,
            'Unexpected Error: The updates were not appropriately performed.'
        );
        System.assertEquals(
            'AdTech',
            afterUpdateStateOfRelationships.get(reciprocalRelationship[0].Id)
                .Inverse_Relationship_Type__c,
            'Unexpected Error: The updates were not properly mapped to the Reciprocal Relationship.'
        );
        System.assertEquals(
            reciprocalRelationship[0].Account__c +
            'AdTech' +
            reciprocalRelationship[0].Related_Account__c +
            'Measurement Partner',
            afterUpdateStateOfRelationships.get(reciprocalRelationship[0].Id).External_Id__c,
            'Unexpected Error: The External unique Id was not populated appropriately.'
        );
    }

    @isTest
    private static void testWhenRelationshipIsDeletedThenReciprocalIsDeleted() {
        List<Account_Relationship__c> allRelationships = [
            SELECT
                Id,
                Name,
                Relationship_Type__c,
                Relationship_Status__c,
                Inverse_Relationship_Type__c,
                Account__c,
                Related_Account__c,
                External_Id__c
            FROM Account_Relationship__c
            ORDER BY Name
        ];
        //Before Delete check
        System.assertEquals(
            2,
            allRelationships.size(),
            'The system must contain an account Relationship along with its Reciprocal. The records are not available as expected.'
        );

        Test.startTest();
        //Delete only inserted record
        delete allRelationships[0];
        Test.stopTest();

        List<Account_Relationship__c> allRelationshipsAfterDelete = [
            SELECT
                Id,
                Name,
                Relationship_Type__c,
                Relationship_Status__c,
                Inverse_Relationship_Type__c,
                Account__c,
                Related_Account__c,
                External_Id__c
            FROM Account_Relationship__c
            ORDER BY Name
        ];
        System.assertEquals(
            0,
            allRelationshipsAfterDelete.size(),
            'The reciprocal record was not deleted on deletion of the account relationship.'
        );
    }
}