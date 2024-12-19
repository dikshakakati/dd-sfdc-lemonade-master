/**
 * @description This is integration test class for AccountRollUpServiceImpl
 * @author Deloitte
 * @date 05/04/2022
 */
@isTest(seeAllData=false)
public class AccountRollUpServiceImplIntegrationTest {
    /**
     * @description Integration test for roll up stores calculation
     */
    @IsTest
    private static void testWhenAccountInsertedThenCalculateStoreCount() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        List<Account> grandParentAccounts = new List<Account>{
            new Account(
                Name = 'Grand Parent Account1',
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Grand Franchise Account1',
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            )
        };
        insert grandParentAccounts;

        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                ParentId = grandParentAccounts[0].Id,
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Franchise Account1',
                ParentId = grandParentAccounts[0].Id,
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Parent Account2',
                ParentId = grandParentAccounts[1].Id,
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Franchise Account2',
                ParentId = grandParentAccounts[1].Id,
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            )
        };
        insert parentAccounts;

        Set<Id> parentIds = new Set<Id>{
            parentAccounts[0].Id,
            parentAccounts[1].Id,
            parentAccounts[2].Id,
            parentAccounts[3].Id
        };
        Set<Id> grandParentIds = new Set<Id>{
            grandParentAccounts[0].Id,
            grandParentAccounts[1].Id
        };

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Franchise_Parent__c = parentAccounts[3].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[3].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account3',
                ParentId = parentAccounts[0].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account4',
                ParentId = parentAccounts[3].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account5',
                ParentId = parentAccounts[2].Id,
                Franchise_Parent__c = parentAccounts[1].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account6',
                ParentId = parentAccounts[2].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account7',
                ParentId = parentAccounts[2].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account8',
                ParentId = parentAccounts[1].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            )
        };

        Test.startTest();
        insert storeAccounts;

        Test.getEventBus().deliver();
        Map<Id, Account> updatedParents = new Map<Id, Account>(
            [
                SELECT
                    Id,
                    Name,
                    Corporate_Owned_Store_Count__c,
                    Franchise_Owned_Store_Count__c,
                    Total_Number_Of_Stores__c
                FROM Account
                WHERE Id IN :parentIds
            ]
        );
        System.assertEquals(
            1,
            (Integer) updatedParents.get(parentAccounts[0].Id).Corporate_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            1,
            (Integer) updatedParents.get(parentAccounts[0].Id).Franchise_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            2,
            (Integer) updatedParents.get(parentAccounts[0].Id).Total_Number_Of_Stores__c,
            'Franchise count does not match'
        );

        System.assertEquals(
            1,
            (Integer) updatedParents.get(parentAccounts[1].Id).Corporate_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            1,
            (Integer) updatedParents.get(parentAccounts[1].Id).Franchise_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            2,
            (Integer) updatedParents.get(parentAccounts[1].Id).Total_Number_Of_Stores__c,
            'Franchise count does not match'
        );

        System.assertEquals(
            2,
            (Integer) updatedParents.get(parentAccounts[2].Id).Corporate_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            1,
            (Integer) updatedParents.get(parentAccounts[2].Id).Franchise_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            3,
            (Integer) updatedParents.get(parentAccounts[2].Id).Total_Number_Of_Stores__c,
            'Franchise count does not match'
        );

        System.assertEquals(
            2,
            (Integer) updatedParents.get(parentAccounts[3].Id).Corporate_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            1,
            (Integer) updatedParents.get(parentAccounts[3].Id).Franchise_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            3,
            (Integer) updatedParents.get(parentAccounts[3].Id).Total_Number_Of_Stores__c,
            'Franchise count does not match'
        );

        Test.getEventBus().deliver();
        Map<Id, Account> updatedGrandParents = new Map<Id, Account>(
            [
                SELECT
                    Id,
                    Name,
                    Corporate_Owned_Store_Count__c,
                    Franchise_Owned_Store_Count__c,
                    Total_Number_Of_Stores__c
                FROM Account
                WHERE Id IN :grandParentIds
            ]
        );
        System.assertEquals(
            2,
            (Integer) updatedGrandParents.get(grandParentAccounts[0].Id)
                .Corporate_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            2,
            (Integer) updatedGrandParents.get(grandParentAccounts[0].Id)
                .Franchise_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            4,
            (Integer) updatedGrandParents.get(grandParentAccounts[0].Id).Total_Number_Of_Stores__c,
            'Franchise count does not match'
        );

        System.assertEquals(
            4,
            (Integer) updatedGrandParents.get(grandParentAccounts[1].Id)
                .Corporate_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            2,
            (Integer) updatedGrandParents.get(grandParentAccounts[1].Id)
                .Franchise_Owned_Store_Count__c,
            'Franchise count does not match'
        );
        System.assertEquals(
            6,
            (Integer) updatedGrandParents.get(grandParentAccounts[1].Id).Total_Number_Of_Stores__c,
            'Franchise count does not match'
        );
        Test.stopTest();
    }

    /**
     * @description Integration test for partnership status roll up calculation
     */
    @IsTest
    private static void testWhenAccountInsertedThenUpdateParentPartnershipStatus() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account grandParentAccount = new Account(
            Name = 'Grand Parent Account1',
            RecordTypeId = accRecordTypeBusiness,
            Partnership_Status__c = 'Prospective Partner',
            Primary_Vertical__c = 'Rx',
            BillingStreet = 'abc street',
            BillingCity = 'Missoula',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            BillingState = 'Montana',
            Segment__c = 'Enterprise'
        );
        insert grandParentAccount;

        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                ParentId = grandParentAccount.Id,
                RecordTypeId = accRecordTypeBusiness,
                Partnership_Status__c = 'Former Partner',
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Parent Account2',
                ParentId = grandParentAccount.Id,
                RecordTypeId = accRecordTypeBusiness,
                Partnership_Status__c = 'Former Partner',
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            )
        };
        insert parentAccounts;

        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Partnership_Status__c = 'Prospective Partner',
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[0].Id,
                Partnership_Status__c = 'Former Partner',
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account3',
                ParentId = parentAccounts[0].Id,
                Partnership_Status__c = 'Former Partner',
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account4',
                ParentId = parentAccounts[0].Id,
                Activation_Status__c = 'Active',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account5',
                ParentId = parentAccounts[1].Id,
                Partnership_Status__c = 'Prospective Partner',
                RecordTypeId = accRecordTypeBusiness,
                Primary_Vertical__c = 'Rx',
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account6',
                ParentId = parentAccounts[1].Id,
                Activation_Status__c = 'Deactivated',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account7',
                ParentId = parentAccounts[1].Id,
                Activation_Status__c = 'Inactive',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            ),
            new Account(
                Name = 'Account8',
                ParentId = parentAccounts[1].Id,
                Activation_Status__c = 'Deactivated',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'Enterprise'
            )
        };

        Test.startTest();
        insert storeAccounts;

        Test.getEventBus().deliver();
        Map<Id, Account> updatedParents = new Map<Id, Account>(
            [SELECT Id, Partnership_Status__c FROM Account WHERE Id IN :parentIds]
        );
        System.assertEquals(
            'Existing Partner',
            updatedParents.get(parentAccounts[0].Id).Partnership_Status__c,
            'Status does not match'
        );
        System.assertEquals(
            'Prospective Partner',
            updatedParents.get(parentAccounts[1].Id).Partnership_Status__c,
            'Status does not match'
        );

        Test.getEventBus().deliver();
        Map<Id, Account> updatedGrandParent = new Map<Id, Account>(
            [SELECT Id, Partnership_Status__c FROM Account WHERE Id = :grandParentAccount.Id]
        );
        System.assertEquals(
            'Existing Partner',
            updatedGrandParent.get(grandParentAccount.Id).Partnership_Status__c,
            'Status does not match'
        );
        Test.stopTest();
    }
}