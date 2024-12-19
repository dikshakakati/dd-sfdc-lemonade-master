/**
 * @author DoorDash
 * @date 07/09/2023
 * @description Test class for Account contact relationship object.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class AccountContactRelationsServiceImplTest {
    private static final String FIRST_NAME = 'Test FirstName';
    private static final String LAST_NAME = 'Test LastName';
    private static final String EMAIL = 'test.test14@doordash.com';
    private static final String PHONE = '373737923979';
    private static final String NAME = FIRST_NAME + LAST_NAME;
    private static final String ROLE_BUSINESS_ADMIN = 'Business Admin';
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';
    private static final String ACCOUNT_ID = fflib_IDGenerator.generate(Account.getSObjectType());
    private static final String ASSERT_ERROR_MSG_ROLE_NOT_FOUND = 'Role not found in map for this Account';
    private static final String CONTACT_ROLE_DECISION_MAKER = 'Decision Maker';
    private static final String CONTACT_ROLE_BUSINESS_OWNER = 'Business Owner';
    private static final String CONTACT_ROLE_BUSINESS_DIRECTOR = 'Business Director';

    @isTest
    private static void testWhenAccountIdsPassedThenDeactivateAcrs() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        AccountContactRelation acr = new AccountContactRelation(
            Id = fflib_IDGenerator.generate(AccountContactRelation.SObjectType),
            ContactId = contactId,
            AccountId = ACCOUNT_ID,
            roles = ROLE_BUSINESS_ADMIN,
            isActive = true
        );
        Set<Id> accountIds = new Set<Id>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(acrSelectorMock.selectActiveAcrByAccountIds(accountIds))
            .thenReturn(new List<AccountContactRelation>{ acr });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(acrSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        AccountContactRelationsService.deactivateAccountAcrs(accountIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        AccountContactRelation.Roles => '',
                        AccountContactRelation.isActive => false
                    }
                )
            );
    }

    @IsTest
    static void testWhenInputtingContactRelationsThenSortByAccountAndRole() {
        Id accountWithTwoRoles = Fake.generateId(Account.class);
        Id accountWithOneRole = Fake.generateId(Account.class);
        Id accountWithNoRoles = Fake.generateId(Account.class);

        Id contactId1 = Fake.generateId(Contact.class);
        Id contactId2 = Fake.generateId(Contact.class);
        Id contactId3 = Fake.generateId(Contact.class);

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
            new AccountContactRelation(
                AccountId = accountWithTwoRoles,
                ContactId = contactId1,
                Roles = CONTACT_ROLE_DECISION_MAKER + ';' + CONTACT_ROLE_BUSINESS_OWNER
            ),
            new AccountContactRelation(
                AccountId = accountWithOneRole,
                ContactId = contactId2,
                Roles = CONTACT_ROLE_BUSINESS_OWNER
            ),
            new AccountContactRelation(AccountId = accountWithNoRoles, ContactId = contactId3)
        };

        Map<Id, Map<String, AccountContactRelation>> results = AccountContactRelationsService.sortRolesByAccountIdAndRoleName(
            acrs
        );

        System.assertEquals(
            2,
            results.keySet().size(),
            'There should be two Account IDs in this map'
        );
        System.assertEquals(
            2,
            results.get(accountWithTwoRoles).size(),
            'The first Account should have two Roles in the map'
        );
        System.assertEquals(
            1,
            results.get(accountWithOneRole).size(),
            'The second Account should have one Role in the map'
        );
        System.assertNotEquals(
            null,
            results.get(accountWithTwoRoles).get(CONTACT_ROLE_DECISION_MAKER),
            ASSERT_ERROR_MSG_ROLE_NOT_FOUND
        );
        System.assertNotEquals(
            null,
            results.get(accountWithTwoRoles).get(CONTACT_ROLE_BUSINESS_OWNER),
            ASSERT_ERROR_MSG_ROLE_NOT_FOUND
        );
        System.assertNotEquals(
            null,
            results.get(accountWithOneRole).get(CONTACT_ROLE_BUSINESS_OWNER),
            ASSERT_ERROR_MSG_ROLE_NOT_FOUND
        );
    }

    @IsTest
    static void testWhenEvaluatingCanadianMerchantWithContactRolesThenReturnTrue() {
        Map<String, AccountContactRelation> completeRolesMap = new Map<String, AccountContactRelation>{
            CONTACT_ROLE_DECISION_MAKER => new AccountContactRelation(),
            CONTACT_ROLE_BUSINESS_OWNER => new AccountContactRelation(),
            CONTACT_ROLE_BUSINESS_DIRECTOR => new AccountContactRelation()
        };

        Map<String, AccountContactRelation> incompleteRolesMap = new Map<String, AccountContactRelation>{
            CONTACT_ROLE_DECISION_MAKER => new AccountContactRelation(),
            CONTACT_ROLE_BUSINESS_OWNER => new AccountContactRelation()
        };

        Boolean shouldBeTrue = AccountContactRelationsService.hasRequiredCanadianContactRoles(
            completeRolesMap
        );
        Boolean shouldBeFalse = AccountContactRelationsService.hasRequiredCanadianContactRoles(
            incompleteRolesMap
        );
        Boolean shouldBeFalseFromNull = AccountContactRelationsService.hasRequiredCanadianContactRoles(
            null
        );

        System.assert(shouldBeTrue, 'All required Roles should be present in this map');
        System.assert(!shouldBeFalse, 'The required roles are not present in this map');
        System.assert(!shouldBeFalseFromNull, 'This map is missing required roles');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountContactsArePassedThenCheckAcr() {
        Id accountId = Fake.generateId(Account.class);
        Id contactId1 = Fake.generateId(Contact.class);
        Id contactId2 = Fake.generateId(Contact.class);
        Id acrID = Fake.generateId(AccountContactRelation.class);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountContactRelationsSelector acrSelectorMock = (AccountContactRelationsSelector) mocks.mock(
            AccountContactRelationsSelector.class
        );
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Set<Id> accountIdsSet = new Set<Id>{ accountId };
        List<AccountContactRelation> acrList = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = acrID,
                AccountId = accountId,
                ContactId = contactId1,
                Roles = '',
                IsActive = false
            )
        };
        mocks.startStubbing();
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(acrSelectorMock.selectAcrByAccountIds(accountIdsSet)).thenReturn(acrList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(acrSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Map<Id, List<Id>> accountIdsContactIds = new Map<Id, List<Id>>{
            accountId => new List<Id>{ contactId1, contactId2 }
        };
        AccountContactRelationsService.validateAndCreateAcr(accountIdsContactIds, uowMock);
        for (Id contactId : accountIdsContactIds.get(accountId)) {
            ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2))
                .registerDirty(
                    fflib_Match.sObjectWith(
                        new Map<SObjectField, Object>{ AccountContactRelation.IsActive => true }
                    )
                );
        }
    }
}