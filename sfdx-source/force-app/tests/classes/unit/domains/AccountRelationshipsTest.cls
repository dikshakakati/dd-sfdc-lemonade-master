/**
 * @author Deloitte
 * @date 25/05/2022
 * @description This is the test class for Account Relationship domain class
 */
@isTest(seeAllData=false)
public class AccountRelationshipsTest {
    @isTest
    private static void testWhenRelationshipIsCreatedThenExternalIdIsAutoPopulated() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Account_Relationship__c> relationshipRecords = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement_Partner',
                Relationship_Status__c = 'Active'
            )
        };

        IAccountRelationships relationshipInstance = AccountRelationships.newInstance(
            relationshipRecords
        );

        relationshipInstance.defaultOperationsOnInsertion();
        System.assertEquals(
            accountList[0].Id +
            relationshipRecords[0].Inverse_Relationship_Type__c +
            accountList[1].Id +
            relationshipRecords[0].Relationship_Type__c,
            relationshipRecords[0].External_Id__c,
            'Unexpected Error: The External Id was not autopopulated as expected.'
        );
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenRelationshipRecordsAreInsertedThenReciprocalsAreGenerated() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Account_Relationship__c> relationshipRecords = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement Partner',
                Relationship_Status__c = 'Active',
                External_Id__c = accountList[0].Id +
                    'Measurement Partner' +
                    accountList[1].Id +
                    'Agency'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(relationshipUnitOfWork);
        AccountRelationships.newInstance(relationshipRecords).generateReciprocalRelationship();

        ((fflib_ISObjectUnitOfWork) mocks.verify(relationshipUnitOfWork, 1)).commitWork();
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenRelationshipRecordsAreDeletedThenReciprocalsAreDeleted() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Account_Relationship__c> relationshipRecords = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement Partner',
                Relationship_Status__c = 'Active',
                External_Id__c = accountList[0].Id +
                    'Measurement Partner' +
                    accountList[1].Id +
                    'Agency'
            ),
            new Account_Relationship__c(
                Account__c = accountList[1].Id,
                Related_Account__c = accountList[0].Id,
                Relationship_Type__c = 'Measurement Partner',
                Inverse_Relationship_Type__c = 'Agency',
                Relationship_Status__c = 'Active',
                External_Id__c = accountList[1].Id +
                    'Agency' +
                    accountList[0].Id +
                    'Measurement Partner'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRelationshipsSelector selectorMock = (IAccountRelationshipsSelector) mocks.mock(
            IAccountRelationshipsSelector.class
        );
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account_Relationship__c.SObjectType);
        mocks.when(
                selectorMock.selectRelationshipsWithExternalIds(
                    new Set<String>{
                        accountList[1].Id +
                        'Agency' +
                        accountList[0].Id +
                        'Measurement Partner'
                    }
                )
            )
            .thenReturn(new List<Account_Relationship__c>{ relationshipRecords[1] });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(relationshipUnitOfWork);
        AccountRelationships.newInstance(
                new List<Account_Relationship__c>{ relationshipRecords[0] }
            )
            .deleteReciprocalRelationships();

        ((fflib_ISObjectUnitOfWork) mocks.verify(relationshipUnitOfWork, 1)).commitWork();
    }

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Account_Relationship__c> relationshipsList = new List<Account_Relationship__c>();
        //IAccountRelationships Instance Creation Call
        AccountRelationships.newInstance(relationshipsList);
        //Default Constructor Call
        AccountRelationships relationshipsObject = new AccountRelationships(relationshipsList);
        //fflib_IDomainConstructor call
        AccountRelationships.Constructor constructorObject = new AccountRelationships.Constructor();
        constructorObject.construct(relationshipsList);
        System.assertNotEquals(
            AccountRelationships.newInstance(relationshipsList),
            relationshipsObject,
            'These objects should not be similar'
        );
    }
}