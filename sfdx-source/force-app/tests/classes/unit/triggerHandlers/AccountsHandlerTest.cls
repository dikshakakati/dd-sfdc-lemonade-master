/**
 * @description This is test class for AccountsHandler Account Trigger handler class
 * @author Deloitte
 * @date 28/02/2022
 */
@isTest(seeAllData=false)
public class AccountsHandlerTest {
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Deactivated';
    private static final String ACCOUNT_ACTIVATION_STATUS_INACTIVE = 'Inactive';
    private static final String ACCOUNT_CONTROL_OF_PRICE = 'DoorDash';
    private static final String ACCOUNT_MEDAL_RANK_PLATINUM = 'Platinum';
    private static final String ACCOUNT_MEDAL_RANK_SILVER = 'Silver';
    private static final String ACCOUNT_MEDAL_RANK_GOLD = 'Gold';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String ACCOUNT_NAME_STORE_WITH_RELATED_RECORDS = 'Store Account With Related Records';
    private static final String ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS = 'Store Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final string ACCOUNT_LIFECYCLE_STATUS_CHURNED = 'Churned';
    private static final string ACCOUNT_LIFECYCLE_STATUS_NURTURE = 'Nurture';
    private static final string ACCOUNT_LIFECYCLE_STATUS_UNVETTED = 'Unvetted';
    private static final string ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR = 'Account lifecycle status was not updated correctly.';
    private static final string ASSERT_MESSAGE_LIFECYCLE_STATUS_UPDATE_ERROR = 'Lifecycle status should not change when Activation Status is not modified';
    private static final string OPPORTUNITY_NAME = 'Test Opportunity';
    private static final string OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Deactivated';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE = 'Inactive';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKSTEP_TYPE_ACTIVATE_STORE = 'Activate Store';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String TIME_ZONE_BACKEND_AMERICA_LOSANGELES = 'America/Los_Angeles';
    private static final String TIME_ZONE_BACKEND_AMERICA_NEWYORK = 'America/New_York';
    private static final String TEST_ACCOUNT_NAME = 'Test Account Name ';
    private static final string UPDATED_ACCOUNT_NAME = 'Updated Name';
    private static final String CREATE_EVENT = 'CREATE';
    private static final String UPDATE_EVENT = 'UPDATE';

    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<Account> accountList = new List<Account>();
        AccountsHandler accountHandlerObject = new AccountsHandler(accountList);
        //Inner Class Constructor Call
        AccountsHandler.Constructor objConstructor = new AccountsHandler.Constructor();
        objConstructor.construct(accountList);
        System.assertNotEquals(
            accountHandlerObject,
            objConstructor.construct(accountList),
            'The two constructs should not be similar'
        );
    }

    /**
     * @description To test method call on account update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUpdatedThenCall() {
        Id accountIdHK = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountIdUS = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountIdHK,
                Name = 'Test HK Account',
                Phone = '839393',
                Control_of_Price__c = ACCOUNT_CONTROL_OF_PRICE,
                CurrencyIsoCode = 'HKT',
                TaxID__c = '167790800',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                BillingCountryCode = 'AU'
            ),
            new Account(
                Id = accountIdUS,
                Name = 'Test US Account',
                Phone = '739393',
                Control_of_Price__c = ACCOUNT_CONTROL_OF_PRICE,
                CurrencyIsoCode = 'USD',
                Menu_UI_Type__c = null,
                TaxID__c = '167790900',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                BillingCountryCode = 'AU'
            )
        };
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountIdHK,
                Name = 'Test HK Account',
                Phone = '839393',
                CurrencyIsoCode = 'USD',
                Primary_Vertical__c = 'Alcohol',
                TaxID__c = '167790809',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                BillingCountryCode = 'US'
            ),
            new Account(
                Id = accountIdUS,
                Name = 'Test 2',
                Phone = '739393',
                CurrencyIsoCode = 'USD',
                Primary_Vertical__c = 'Goods',
                Menu_UI_Type__c = 'Restaurant',
                TaxID__c = '167790909',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                BillingCountryCode = 'US'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).associateBrandToStoreAccounts();
        ((IAccounts) mocks.verify(accountsMock, 1))
            .validateROEFieldsChangedByOwnerOrOwnersManager();
        ((IAccounts) mocks.verify(accountsMock, 1)).calculateTotalNumberOfStores();
        ((IAccounts) mocks.verify(accountsMock, 1)).resetAddressAttributes();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateAddressVerificationDate();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateFranchiseParentSubtype();
        ((IAccounts) mocks.verify(accountsMock, 1)).initiateTaxIdEncryption(newAccounts);
        ((IAccounts) mocks.verify(accountsMock, 1)).validateAndNormalizePhoneNumberFormat();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateMostRecentDateForStoreAccount();
        ((IAccounts) mocks.verify(accountsMock, 2))
            .publishNotifierEvent((String) fflib_Match.anyObject());
        ((IAccounts) mocks.verify(accountsMock, 1)).publishDuplicateStatusNotifierEvent();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateDoordashLegalEntityAndControlOfPrice(UPDATE_EVENT);
        ((IAccounts) mocks.verify(accountsMock, 1))
            .updateDeveloperIDOrDeveloperIDBackend(new Map<Id, SObject>(oldAccounts));
        ((IAccounts) mocks.verify(accountsMock, 1))
            .enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateCurrencyOfPaymentAccount();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateAlcoholProductEligibility();
        ((IAccounts) mocks.verify(accountsMock, 1))
            .updateStoreLevelPDOxIndicatorOnParentWorkOrder();
        ((IAccounts) mocks.verify(accountsMock, 1)).initiateTrickleDownOnChildAccounts();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateDataVerificationStatus();
        ((IAccounts) mocks.verify(accountsMock, 1)).setAccountLifecycleStatusOnSMBStoreAccounts();
    }

    /**
     * @description To test method call on account undelete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUndeletedThenCall() {
        Account[] newAccounts = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test 2')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountsMock);

        fflib_SObjectDomain.Test.Database.onUndelete(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccounts) mocks.verify(accountsMock, 1)).updateFranchiseParentSubtype();
    }

    /**
     * @description To test update address verification status and date
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountFranchiseUpdatedThenCall() {
        Id storeAccountId1 = Fake.generateId(Account.class);
        Id storeAccountId2 = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Account[] oldAccounts = new List<Account>{
            new Account(Id = storeAccountId1, Name = 'Test 1'),
            new Account(Id = storeAccountId2, Name = 'Test 2')
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                Franchise_Parent__c = franchiseAccountId
            ),
            new Account(Id = storeAccountId2, Name = 'Test 2')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Account>{ newAccounts[0] });
    }

    /**
     * @description To test update address verification status and date
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountAddressUpdatedThenCall() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] oldAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test', BillingCity = '123 Existing Street'),
            new Account(Id = account2Id, Name = 'Test', BillingCity = '987 Existing Street')
        };
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test', BillingCity = '123 New Street'),
            new Account(Id = account2Id, Name = 'Test', BillingCity = '987 Existing Street')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 2))
            .construct(new List<Account>{ newAccounts[0] });
    }

    /**
     * @description To test update total number of stores on franchise accounts.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTotalNumberOfStoresUpdatedThenCall() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test',
                Total_Number_Of_Stores__c = 0,
                RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID
            ),
            new Account(
                Id = account2Id,
                Name = 'Test',
                Total_Number_Of_Stores__c = 0,
                RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test',
                Total_Number_Of_Stores__c = 1,
                RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID
            ),
            new Account(
                Id = account2Id,
                Name = 'Test',
                Total_Number_Of_Stores__c = 1,
                RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccounts) mocks.verify(accountsMock, 1)).updateCorporateAccountOnFranchise();
    }

    /**
     * @description To test update address verification date
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountStatusUpdatedThenCall() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test1',
                Address_Verification_Status__c = 'Unverified'
            ),
            new Account(
                Id = account2Id,
                Name = 'Test2',
                Address_Verification_Status__c = 'Unverified'
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test1',
                Address_Verification_Status__c = 'Verified'
            ),
            new Account(
                Id = account2Id,
                Name = 'Test2',
                Address_Verification_Status__c = 'Unverified'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Account>{ newAccounts[0] });
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenOnAfterInsertThenItShouldPopulateUltimateParent() {
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.getTriggerEvent(Account.class).disableAll();
        fflib_SObjectDomain.getTriggerEvent(Account.class).enableAfterInsert(); // limiting the handler to just exercising the after insert behavior

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAsyncBatchRunner runnerMock = (IAsyncBatchRunner) mocks.mock(IAsyncBatchRunner.class);
        mocks.startStubbing();
        mocks.when(runnerMock.executeBatch(fflib_Match.anyObject())).thenReturn(null);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAsyncBatchRunner.class, runnerMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        // Assert
        ((IAsyncBatchRunner) mocks.verify(runnerMock, 1)).executeBatch(fflib_Match.anyObject());
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenOnAfterUpdateThenItShouldPopulateUltimateParent() {
        // Arrange
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test 1',
                ParentId = fflib_IDGenerator.generate(Account.SObjectType)
            ),
            new Account(
                Id = account2Id,
                Name = 'Test 2',
                ParentId = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1', ParentId = oldAccounts[0].ParentId),
            new Account(
                Id = account2Id,
                Name = 'Test 2',
                ParentId = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, Account>(oldAccounts));
        fflib_SObjectDomain.getTriggerEvent(Account.class).disableAll();
        fflib_SObjectDomain.getTriggerEvent(Account.class).enableAfterUpdate(); // limiting the handler to just exercising the after insert behavior

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAsyncBatchRunner runnerMock = (IAsyncBatchRunner) mocks.mock(IAsyncBatchRunner.class);
        mocks.startStubbing();
        mocks.when(runnerMock.executeBatch(fflib_Match.anyObject())).thenReturn(null);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAsyncBatchRunner.class, runnerMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        // Assert
        ((IAsyncBatchRunner) mocks.verify(runnerMock, 1)).executeBatch(fflib_Match.anyObject());
    }

    @isTest
    static void testWhenBypassReturnsTrueThenItShouldDisableBeforeInsertTriggerContext() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1'),
            new Account(Id = account2Id, Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_INSERT;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Account', System.TriggerOperation.BEFORE_INSERT))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    @isTest
    static void testWhenBypassReturnsTrueThenItShouldDisableAfterInsertTriggerContext() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1'),
            new Account(Id = account2Id, Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_INSERT;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Account', System.TriggerOperation.AFTER_INSERT))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    @isTest
    static void testWhenBypassReturnsTrueThenItShouldDisableBeforeUpdateTriggerContext() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1'),
            new Account(Id = account2Id, Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_UPDATE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Account', System.TriggerOperation.BEFORE_UPDATE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    @isTest
    static void testWhenBypassReturnsTrueThenItShouldDisableAfterUpdateTriggerContext() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1'),
            new Account(Id = account2Id, Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_UPDATE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Account', System.TriggerOperation.AFTER_UPDATE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    @isTest
    static void testWhenBypassReturnsTrueThenItShouldDisableBeforeDeleteTriggerContext() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1'),
            new Account(Id = account2Id, Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_DELETE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Account', System.TriggerOperation.BEFORE_DELETE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    @isTest
    static void testWhenBypassReturnsTrueThenItShouldDisableAfterDeleteTriggerContext() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = account1Id, Name = 'Test 1'),
            new Account(Id = account2Id, Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_DELETE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Account', System.TriggerOperation.AFTER_DELETE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(AccountsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description To test Accounts Trigger
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenOnAfterUndeleteThenItShouldPopulateUltimateParent() {
        // Arrange
        Account[] newAccounts = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onUndelete(newAccounts);
        fflib_SObjectDomain.getTriggerEvent(Account.class).disableAll();
        fflib_SObjectDomain.getTriggerEvent(Account.class).enableAfterUndelete(); // limiting the handler to just exercising the after insert behavior

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAsyncBatchRunner runnerMock = (IAsyncBatchRunner) mocks.mock(IAsyncBatchRunner.class);
        mocks.startStubbing();
        mocks.when(runnerMock.executeBatch(fflib_Match.anyObject())).thenReturn(null);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAsyncBatchRunner.class, runnerMock);
        // Act
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        // Assert
        ((IAsyncBatchRunner) mocks.verify(runnerMock, 1)).executeBatch(fflib_Match.anyObject());
    }

    /**
     * @description To test method call on account insert
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenCall() {
        Id accountIdUS = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountIdAU = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountIdUS,
                Name = 'Test 1',
                Phone = '839393',
                TaxID__c = '167790800',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                CurrencyIsoCode = 'USD'
            ),
            new Account(
                Id = accountIdAU,
                Name = 'Test 2',
                Phone = '739393',
                TaxID__c = '167790900',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                CurrencyIsoCode = 'AUD'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountsMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccounts) mocks.verify(accountsMock, 1)).associateBrandToStoreAccounts();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateFranchiseParentSubtype();
        ((IAccounts) mocks.verify(accountsMock, 1)).initiateTaxIdEncryption(newAccounts);
        ((IAccounts) mocks.verify(accountsMock, 1)).validateAndNormalizePhoneNumberFormat();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateMostRecentDateForStoreAccount();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateDoordashLegalEntityAndControlOfPrice(CREATE_EVENT);
        ((IAccounts) mocks.verify(accountsMock, 1))
            .updateDeveloperIDOrDeveloperIDBackend(new Map<Id, SObject>());
        ((IAccounts) mocks.verify(accountsMock, 1)).updateAlcoholProductEligibility();
        ((IAccounts) mocks.verify(accountsMock, 1)).publishDuplicateStatusNotifierEvent();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateRelatedDuplicateStatusFields();
        ((IAccounts) mocks.verify(accountsMock, 1)).updateDataVerificationStatus();
    }

    /**
     * @description To test method call roll up service on account insert
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenCallRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id accParentId = fflib_IDGenerator.generate(Account.SObjectType);
        Id accFranchiseParentId = fflib_IDGenerator.generate(Account.SObjectType);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = accParentId,
                Franchise_Parent__c = accFranchiseParentId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = accParentId,
                Franchise_Parent__c = accFranchiseParentId
            )
        };

        Set<Id> parentIds = new Set<Id>{ accParentId, accFranchiseParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To test method call roll up service on account update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUpdatedThenCallRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id storeAccountId1 = Fake.generateId(Account.class);
        Id storeAccountId2 = Fake.generateId(Account.class);
        Id oldParentId = Fake.generateId(Account.class);
        Id newParentId = Fake.generateId(Account.class);
        Id oldFranchiseParentId = Fake.generateId(Account.class);
        Id newFranchiseParentId = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = oldParentId,
                Franchise_Parent__c = oldFranchiseParentId
            ),
            new Account(
                Id = storeAccountId2,
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = oldParentId,
                Franchise_Parent__c = oldFranchiseParentId
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = newParentId,
                Franchise_Parent__c = newFranchiseParentId
            ),
            new Account(
                Id = storeAccountId2,
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = newParentId,
                Franchise_Parent__c = newFranchiseParentId
            )
        };

        Set<Id> parentIds = new Set<Id>{
            newParentId,
            newFranchiseParentId,
            oldParentId,
            oldFranchiseParentId
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To test method call roll up service on account delete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountDeletedThenCallRollUpService() {
        Id accParentId = Fake.generateId(Account.class);
        Id accFranchiseParentId = Fake.generateId(Account.class);

        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            ParentId = accParentId,
            Franchise_Parent__c = accFranchiseParentId
        );

        Set<Id> parentIds = new Set<Id>{ accParentId, accFranchiseParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onDelete(
            new Map<Id, Account>{ newAccount.Id => newAccount }
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To test method call roll up service on account undelete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUndeletedThenCallRollUpService() {
        Id accParentId = Fake.generateId(Account.class);
        Id accFranchiseParentId = Fake.generateId(Account.class);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                ParentId = accParentId,
                Franchise_Parent__c = accFranchiseParentId
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                ParentId = accParentId,
                Franchise_Parent__c = accFranchiseParentId
            )
        };

        Set<Id> parentIds = new Set<Id>{ accParentId, accFranchiseParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUndelete(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishStoreRollUpEvents(parentIds);
    }

    /**
     * @description To test update Vertical for Business Account Insert on parent
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessAccountInsertedThenVerticalUpdated() {
        // Arrange
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accParentId = fflib_IDGenerator.generate(Account.SObjectType);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = accParentId,
                Primary_Vertical__c = 'Alcohol',
                Additional_Verticals__c = 'Convenience;Floral;Gifts'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = accParentId,
                Primary_Vertical__c = 'Alcohol',
                Additional_Verticals__c = 'Dashmart;Beauty'
            )
        };

        Set<Id> parentIds = new Set<Id>{ accParentId };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpserviceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishVerticalRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account insert
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenCallPartnershipRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accParentId = fflib_IDGenerator.generate(Account.SObjectType);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = accParentId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = accParentId
            )
        };

        Set<Id> parentIds = new Set<Id>{ accParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account parent update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountParentUpdatedThenCallPartnershipRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id storeAccountId1 = Fake.generateId(Account.class);
        Id storeAccountId2 = Fake.generateId(Account.class);
        Id newParentId = Fake.generateId(Account.class);
        Id oldParentId = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = oldParentId
            ),
            new Account(
                Id = storeAccountId2,
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = oldParentId
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = newParentId
            ),
            new Account(
                Id = storeAccountId2,
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = newParentId
            )
        };

        Set<Id> parentIds = new Set<Id>{ newParentId, oldParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account partnership status update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountPartnershipStatusUpdatedThenCallPartnershipRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id businessAccountId1 = Fake.generateId(Account.class);
        Id parentId = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = businessAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = parentId,
                Partnership_Status__c = 'Former Partner'
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = businessAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = parentId,
                Partnership_Status__c = 'Existing Partner'
            )
        };

        Set<Id> parentIds = new Set<Id>{ parentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account partnership status update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountActivationStatusUpdatedThenCallPartnershipRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id storeAccountId1 = Fake.generateId(Account.class);
        Id parentId = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = parentId,
                Activation_Status__c = 'Inactive'
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = parentId,
                Activation_Status__c = 'Active'
            )
        };

        Set<Id> parentIds = new Set<Id>{ parentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account record type update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountRecordTypeUpdatedThenDontCallPartnershipRollUpService() {
        Id storeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeAccountId1 = Fake.generateId(Account.class);
        Id parentId = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = storeRecordType,
                ParentId = parentId
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = 'Test 1',
                RecordTypeId = businessRecordType,
                ParentId = parentId
            )
        };

        Set<Id> parentIds = new Set<Id>{ parentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, mocks.never()))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account delete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountDeletedThenCallPartnershipRollUpService() {
        Id businessRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accParentId = fflib_IDGenerator.generate(Account.SObjectType);

        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            ParentId = accParentId,
            RecordTypeId = businessRecordType
        );

        Set<Id> parentIds = new Set<Id>{ accParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onDelete(
            new Map<Id, Account>{ newAccount.Id => newAccount }
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test method call partnership roll up service on account undelete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUndeleteThenCallPartnershipRollUpService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accParentId = fflib_IDGenerator.generate(Account.SObjectType);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                ParentId = accParentId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordType,
                ParentId = accParentId
            )
        };

        Set<Id> parentIds = new Set<Id>{ accParentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        fflib_SObjectDomain.Test.Database.onUndelete(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
    }

    /**
     * @description To test updation on WorkPlans and WorkStep
     *  when Activation Status is changed to Active on Store Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountActivationStatusUpdatedToActiveThenUpdateRelatedWorkPlansAndWorkSteps() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        Account storeAccountWithoutRelatedRecords = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_INACTIVE)
            .setFakeId()
            .toSObject();
        Opportunity parentOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.CloseDate, System.today().addDays(5))
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setFakeId()
            .toSObject();
        Account storeAccountWithRelatedRecords = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, ACCOUNT_NAME_STORE_WITH_RELATED_RECORDS)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_INACTIVE)
            .setField(Account.id, storeAccountId)
            .setChildren(
                'WorkOrders',
                new List<Fake>{
                    new Fake(WorkOrder.class)
                        .setField(WorkOrder.Id, workOrderId)
                        .setField(WorkOrder.AccountId, storeAccountId)
                        .setField(
                            WorkOrder.Activated_Centrally_AC__c,
                            ACCOUNT_ACTIVATED_CENTRALLY_YES
                        )
                        .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
                        .setField(WorkOrder.Proposed_Date_of_Activation__c, System.Today())
                        .setField(WorkOrder.Status, STATUS_IN_PROGRESS)
                        .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
                        .setChildren(
                            'WorkPlans',
                            new List<Fake>{
                                new Fake(WorkPlan.class)
                                    .setField(WorkPlan.Id, workPlanId)
                                    .setField(WorkPlan.Name, WORKORDER_TYPE_STOREFRONT)
                                    .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
                                    .setField(WorkPlan.WorkOrderId, workOrderId)
                                    .setChildren(
                                        'WorkSteps',
                                        new List<Fake>{
                                            new Fake(WorkStep.class)
                                                .setField(WorkStep.Id, workStepId)
                                                .setField(
                                                    WorkStep.Name,
                                                    WORKSTEP_TYPE_ACTIVATE_STORE
                                                )
                                                .setField(WorkStep.Status, STATUS_NOT_WORKABLE)
                                                .setField(WorkStep.WorkPlanId, workPlanId)
                                        }
                                    )
                            }
                        )
                }
            )
            .toSObject();
        List<Account> oldAccounts = new List<Account>{
            storeAccountWithoutRelatedRecords,
            storeAccountWithRelatedRecords
        };
        List<Account> newAccounts = new List<Account>{
            new Account(
                Id = storeAccountWithoutRelatedRecords.Id,
                Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED
            ),
            new Account(
                Id = storeAccountWithRelatedRecords.Id,
                Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_ACTIVE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1))
            .collectActivatedStoreAccountsAndTriggerUpdateOnRelatedWorkPlansAndWorkSteps();
    }

    /**
     * @description To test calling address verification service on account insert
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenCallAddressVerificationService() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Test Street1',
                Address_Verification_Status__c = 'Unverified'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Test Street2',
                Address_Verification_Status__c = 'Unverified'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddressVerificationService accountAddressVerificationServiceMock = (IAddressVerificationService) mocks.mock(
            IAddressVerificationService.class
        );
        Application.SERVICE.setMock(
            IAddressVerificationService.class,
            accountAddressVerificationServiceMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAddressVerificationService) mocks.verify(accountAddressVerificationServiceMock, 1))
            .publishAddressVerificationEvent(newAccounts);
    }

    /**
     * @description To test method call address verification service on account update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUpdatedThenCallAddressVerificationService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
        Id accountId = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                BillingStreet = 'Test Street2',
                Address_Verification_Status__c = 'Verified'
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = 'Test 1',
                RecordTypeId = accRecordType,
                BillingStreet = 'Test Street3',
                Address_Verification_Status__c = 'Unverified'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddressVerificationService accountAddressVerificationServiceMock = (IAddressVerificationService) mocks.mock(
            IAddressVerificationService.class
        );
        Application.SERVICE.setMock(
            IAddressVerificationService.class,
            accountAddressVerificationServiceMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAddressVerificationService) mocks.verify(accountAddressVerificationServiceMock, 1))
            .publishAddressVerificationEvent(newAccounts);
    }

    /**
     * @description To test method call roll up service on account undelete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUndeletedThenCallAddressVerificationService() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id accRecordTypeBus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Test Street1',
                Address_Verification_Status__c = 'Unverified'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordTypeBus,
                BillingStreet = 'Test Street2',
                Address_Verification_Status__c = 'Unverified'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddressVerificationService accountAddressVerificationServiceMock = (IAddressVerificationService) mocks.mock(
            IAddressVerificationService.class
        );
        Application.SERVICE.setMock(
            IAddressVerificationService.class,
            accountAddressVerificationServiceMock
        );

        fflib_SObjectDomain.Test.Database.onUndelete(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAddressVerificationService) mocks.verify(accountAddressVerificationServiceMock, 1))
            .publishAddressVerificationEvent(newAccounts);
    }

    /**
     * @description To test Accounts Trigger
     */
    @isTest
    private static void testWhenAccountsTriggerIsCalledThenAccountIsInserted() {
        Account acc = new Account(Name = 'Test 1', Segment__c = 'SMB');
        insert acc;
        System.assertNotEquals(null, acc.Id, 'Id is null');
    }

    /**
     * @description To test batch classusing AsyncBatchService to mock the batch methods
     */
    public class AsyncBatchService {
        /**
         * @description Mock the batch execute methods
         * @param batchClass
         * @param scope
         * @return Database.executeBatch
         */
        public Id executeBatch(Database.Batchable<SObject> batchClass, Integer scope) {
            return Database.executeBatch(batchClass, scope);
        }
    }

    /**
     * @description When billing country code, billing state code, primary vertical is updated, then update legal entity name
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountBillingCountryCodeThenCallUpdateLegalEntityName() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(Id = accountId1, Name = 'Test 1', BillingCountryCode = 'US'),
            new Account(Id = accountId2, Name = 'Test 2', BillingStateCode = 'AB'),
            new Account(Id = accountId3, Name = 'Test 3', Primary_Vertical__c = 'Alcohol'),
            new Account(Id = accountId4, Name = 'Test 4', BillingStreet = 'Old Street')
        };

        Account[] newAccounts = new List<Account>{
            new Account(Id = accountId1, Name = 'Test 1', BillingCountryCode = 'NZ'),
            new Account(Id = accountId2, Name = 'Test 2', BillingStateCode = 'CD'),
            new Account(Id = accountId3, Name = 'Test 3', Primary_Vertical__c = 'Gifts'),
            new Account(Id = accountId4, Name = 'Test 4', BillingStreet = 'New Street')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Account>{ newAccounts[0], newAccounts[1], newAccounts[2] });
    }

    /**
     * @description To check method call when Developer ID and Developer ID Backend is changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountDeveloperIdUpdatedThenCallUpdateDeveloperIDBackend() {
        Id accRecordTypeChannelPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
        Id accRecordTypeBussiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordTypeChannelPartner,
                Developer_ID__c = 'Walgreens - 196662068'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = accRecordTypeBussiness,
                Developer_ID_Backend__c = '746479370'
            ),
            new Account(
                Id = accountId3,
                Name = 'Test 3',
                RecordTypeId = accRecordTypeBussiness,
                Developer_ID__c = 'CardFree - 421608987'
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = accRecordTypeChannelPartner,
                Developer_ID__c = 'Burger King - 174365952'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = accRecordTypeBussiness,
                Developer_ID_Backend__c = '135151260'
            ),
            new Account(
                Id = accountId3,
                Name = 'Test 3',
                RecordTypeId = accRecordTypeBussiness,
                Developer_ID__c = 'CardFree - 421608987'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Account>{ newAccounts[0], newAccounts[1] });
    }

    /**
     * @description To test calling of BrandAssociationsService on store Account insertion.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountInsertedThenBrandAssociationsServiceCalled() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        List<Account> newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Test Street1',
                Address_Verification_Status__c = 'Unverified'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Test Street2',
                Address_Verification_Status__c = 'Unverified'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsService brandAssociationsMock = (IBrandAssociationsService) mocks.mock(
            IBrandAssociationsService.class
        );
        Application.SERVICE.setMock(IBrandAssociationsService.class, brandAssociationsMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IBrandAssociationsService) mocks.verify(brandAssociationsMock, 1))
            .associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(newAccounts);
    }

    /**
     * @description To test calling on BrandAssociationsService on Brand update on store Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandValueUdpatedOnStoreAccountThenBrandAssociationsServiceCalled() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id accountRecordId = fflib_IDGenerator.generate(Account.SObjectType);

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setFakeId()
            .toSObject();

        List<Account> oldAccounts = new List<Account>{
            new Account(
                Id = accountRecordId,
                Name = 'Mcdonald USA',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Texas Street',
                Address_Verification_Status__c = 'Verified'
            )
        };
        List<Account> newAccounts = new List<Account>{
            new Account(
                Id = accountRecordId,
                Name = 'McDonalds USA',
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'Texas Street',
                Address_Verification_Status__c = 'Unverified',
                Brand__c = brand.id
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsService brandAssociationsMock = (IBrandAssociationsService) mocks.mock(
            IBrandAssociationsService.class
        );
        Application.SERVICE.setMock(IBrandAssociationsService.class, brandAssociationsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IBrandAssociationsService) mocks.verify(brandAssociationsMock, 1))
            .associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(newAccounts);
    }
    /**
     * @description To test method call Notifier events service on account delete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountDeletedThenCallGetAllWinningAccountRecords() {
        Id masterRecordId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test')
            .setField(Account.MasterRecordId, masterRecordId)
            .setFakeId()
            .toSObject();

        Set<Id> winningAccountIds = new Set<Id>{ masterRecordId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventsServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventsServiceMock);

        fflib_SObjectDomain.Test.Database.onDelete(
            new Map<Id, Account>{ newAccount.Id => newAccount }
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((INotifierEventsService) mocks.verify(notifierEventsServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    'UPDATE_ACCOUNT_ISMERGED_FLAG' => JSON.serialize(winningAccountIds)
                }
            );
    }

    /**
     * @description To test method call on Is_Parent_Account_Merged Field updation.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIsParentAccountMergedFieldChangedThenCall() {
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                Is_Parent_Account_Merged__c = false
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                Is_Parent_Account_Merged__c = false
            )
        };

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Is_Parent_Account_Merged__c = true
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                Is_Parent_Account_Merged__c = true
            )
        };
        //  Set<Id> accountIdSet = new Set<Id>{ oldAccounts[0].Id, oldAccounts[1].Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccounts) mocks.verify(accountsMock, 1)).populateStoreName();
        ((IAccounts) mocks.verify(accountsMock, 1)).populateFieldsOnChildAccountsByParent();
    }
    /**
     * @description To test update of Tax ID for Business Account Insertion
     * @JIRA# LEM-3846
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessAccountInsertedThenFieldsPopulatedByParent() {
        Id accountId = Fake.generateId(Account.class);
        // Arrange

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                TaxID__c = '12345',
                ParentId = accountId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Name = 'Test 2',
                ParentId = accountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).populateFieldsOnChildAccountsByParent();
    }
    /**
     * @description To test update of Tax ID for Business Account Update
     * @JIRA# LEM-3846
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessAccountUpdatedThenFieldsPopulatedByParent() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id oldParentId1 = Fake.generateId(Account.class);
        Id oldParentId2 = Fake.generateId(Account.class);
        Id newParentId1 = Fake.generateId(Account.class);
        Id newParentId2 = Fake.generateId(Account.class);
        // Arrange
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                TaxID__c = '12345',
                ParentId = oldParentId1
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                TaxID__c = '123',
                ParentId = oldParentId2
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                ParentId = newParentId1
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                TaxID__c = '123',
                ParentId = newParentId2
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).populateFieldsOnChildAccountsByParent();
    }

    /**
     * @description To test the update of Control of Price on Parent Account
     * @JIRA# LEM-12375
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenControlOfPriceIsUpdatedOnParentThenInitiateTrickleDownOnChildAccounts() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Account[] oldBusinessAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Control_of_Price__c = 'Merchant'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Control_of_Price__c = 'Merchant'
            )
        };
        Account[] newBusinessAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Control_of_Price__c = 'Doordash'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Control_of_Price__c = 'Doordash'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newBusinessAccounts,
            new Map<Id, SObject>(oldBusinessAccounts)
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccounts) mocks.verify(accountsMock, 1)).initiateTrickleDownOnChildAccounts();
    }

    /**
     * @description To test if populateBVIDonStoreAccounts method is called when Business
     * Vertical is updated on Store Account record.
     * @JIRA# LEM-12375
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessVerticalOnStoreAccountUpdatedThenCallPopulateBVIDOnStoreAccounts() {
        Id accountId = Fake.generateId(Account.class);
        Id oldBusinessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id newBusinessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        // Arrange
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = 'Store Account',
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Business_Vertical__c = oldBusinessVerticalId
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = 'Store Account',
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Business_Vertical__c = newBusinessVerticalId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).populateBVIDonStoreAccounts();
    }

    /**
     * @description To update Order Protocol on related WOs
     * @JIRA# LEM-12911
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderProtocolUpdateThenUpdatesOnStoreAccount() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);

        Account[] oldStoreAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Order_Protocol__c = 'Email',
                MDS_Last_Synced__c = 'MSD1-OLD'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Order_Protocol__c = 'Email',
                MDS_Last_Synced__c = 'MSD2-OLD'
            )
        };
        Account[] newStoreAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Order_Protocol__c = 'POS',
                MDS_Last_Synced__c = 'MSD1-NEW'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Order_Protocol__c = 'POS',
                MDS_Last_Synced__c = 'MSD2-NEW'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);

        IOrderProtocolUpdatesService opServiceMock = (IOrderProtocolUpdatesService) mocks.mock(
            IOrderProtocolUpdatesService.class
        );
        Application.SERVICE.setMock(IOrderProtocolUpdatesService.class, opServiceMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            newStoreAccounts,
            new Map<Id, SObject>(oldStoreAccounts)
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IOrderProtocolUpdatesService) mocks.verify(opServiceMock, 1))
            .processOrderProtocolUpdatesOnStoreAccounts(
                new Map<Id, Account>{
                    accountId1 => newStoreAccounts[0],
                    accountId2 => newStoreAccounts[1]
                }
            );
    }

    /**
     * @description To test method call time zone calculation service on Account insert.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenCallTimeZoneCalculationService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = ACCOUNT_NAME,
                RecordTypeId = accRecordType,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_AMERICA_NEWYORK
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITimeZoneCalculationService timeZoneCalculationServiceMock = (ITimeZoneCalculationService) mocks.mock(
            ITimeZoneCalculationService.class
        );
        Application.SERVICE.setMock(
            ITimeZoneCalculationService.class,
            timeZoneCalculationServiceMock
        );
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((ITimeZoneCalculationService) mocks.verify(timeZoneCalculationServiceMock, 1))
            .calculateTimeZone(newAccounts);
    }

    /**
     * @description To test method call time zone calculation service on Account update.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUpdatedThenCallTimeZoneCalculationService() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id accountIdToBeUpdated = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountIdToBeUpdated,
                Name = ACCOUNT_NAME,
                RecordTypeId = accRecordType,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_AMERICA_NEWYORK
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountIdToBeUpdated,
                Name = ACCOUNT_NAME,
                RecordTypeId = accRecordType,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_AMERICA_LOSANGELES
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITimeZoneCalculationService timeZoneCalculationServiceMock = (ITimeZoneCalculationService) mocks.mock(
            ITimeZoneCalculationService.class
        );
        Application.SERVICE.setMock(
            ITimeZoneCalculationService.class,
            timeZoneCalculationServiceMock
        );
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((ITimeZoneCalculationService) mocks.verify(timeZoneCalculationServiceMock, 1))
            .calculateTimeZone(newAccounts);
    }

    /**
     * @description To test method call roll up service on account for Medal Rank on insert.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenCallRollUpServiceForMedalRank() {
        Id accParentId = Fake.generateId(Account.class);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                ParentId = accParentId,
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                ParentId = accParentId,
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM
            )
        };
        Set<Id> parentIds = new Set<Id>{ accParentId };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);
        fflib_SObjectDomain.Test.Database.onInsert(newAccounts);
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishMedalRankRollUpEvents(parentIds);
    }

    /**
     * @description To test method call roll up service on account for Medal Rank on update.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountUpdatedThenCallRollUpServiceForMedalRank() {
        Id accParentId = Fake.generateId(Account.class);
        Id storeAccountId1 = Fake.generateId(Account.class);
        Id storeAccountId2 = Fake.generateId(Account.class);
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                ParentId = accParentId,
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM
            ),
            new Account(
                Id = storeAccountId2,
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                ParentId = accParentId,
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId1,
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                ParentId = accParentId,
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_GOLD
            ),
            new Account(
                Id = storeAccountId2,
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                ParentId = accParentId,
                RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_SILVER
            )
        };
        Set<Id> parentIds = new Set<Id>{ accParentId };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishMedalRankRollUpEvents(parentIds);
    }

    /**
     * @description To test when Mx Onbarding Link UUID is changed then populate Store
     * Account Name.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOnboardingLinkUUIDChangedThenPopulateStoreName() {
        String storeName1 = 'Store 1';
        String storeName2 = 'Store 2';
        String uuid1 = '75bd2a61-316e-76f4-b5fa-59fb043e860c';
        String uuid2 = '75bd2a61-316e-76f4-b5fa-59fb043e860d';
        String uuid3 = '75bd2a61-316e-76f4-b5fa-59fb043e860e';
        String uuid4 = '75bd2a61-316e-76f4-b5fa-59fb043e860f';
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = storeName1,
                Mx_Onboarding_Link_Id__c = uuid1
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = storeName2,
                Mx_Onboarding_Link_Id__c = uuid2
            )
        };
        Account[] oldAccounts = new List<Account>{
            new Account(
                Name = storeName1,
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Mx_Onboarding_Link_Id__c = uuid3
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = storeName2,
                Mx_Onboarding_Link_Id__c = uuid4
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).populateStoreName();
    }

    /**
     * @description Test for onBeforeInsert method when activation status is set during insert.
    */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountActivationStatusUpdatedThenCallSetAccountLifecycleStatusOnSMBStoreAccounts() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = storeRecordTypeId,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE
            ),
            new Account(
                Id = account2Id,
                Name = 'Test',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = storeRecordTypeId,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = storeRecordTypeId,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
            ),
            new Account(
                Id = account2Id,
                Name = 'Test',
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = storeRecordTypeId,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVATED
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccounts accountsMock = (IAccounts) mocks.mock(IAccounts.class);
        mocks.startStubbing();
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(accountsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newAccounts, new Map<Id, SObject>(oldAccounts));
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

        ((IAccounts) mocks.verify(accountsMock, 1)).setAccountLifecycleStatusOnSMBStoreAccounts();
    }
    /**
    * @description Test if it invokes 'Experience' field update on Store Accounts.
    * @JIRA# LEM-25063
    */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelfDeliveryFieldUpdatedThenInvokeExperienceFieldUpdateOnStoreAccounts() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = businessAccountId,
                Name = ACCOUNT_NAME_BUSINESS,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE
            ),
            new Account(
                Id = storeAccountId,
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = businessAccountId,
                Name = ACCOUNT_NAME_BUSINESS,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
            ),
            new Account(
                Id = storeAccountId,
                Name = ACCOUNT_NAME_STORE_WITHOUT_RELATED_RECORDS,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID,
                Self_Delivery__c = ACCOUNT_ACTIVATED_CENTRALLY_YES,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVATED
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList()))
            .thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newAccounts,
            new Map<Id, SObject>(oldAccounts)
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).invokeExperienceFieldUpdateOnStoreAccounts();
    }
    /**
   * @description Test if no 'Experience' field update is invoked for Business Accounts.
   * @JIRA# LEM-25063
   */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActivationFieldUpdatedThenDoNotInvokeExperienceFieldUpdateOnStoreAccount() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Account[] oldAccounts = new List<Account>{
        new Account(
            Id = businessAccountId,
            Name = ACCOUNT_NAME_BUSINESS,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            RecordTypeID = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE
        )
        };
        Account[] newAccounts = new List<Account>{
        new Account(
            Id = businessAccountId,
            Name = ACCOUNT_NAME_BUSINESS,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID,
            Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
        )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Accounts accountsMock = (Accounts) mocks.mock(Accounts.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList()))
            .thenReturn(accountsMock);
        mocks.when(accountsMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.stopStubbing();
        Accounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newAccounts,
            new Map<Id, SObject>(oldAccounts)
        );
        fflib_SObjectDomain.triggerHandler(AccountsHandler.class);
        ((IAccounts) mocks.verify(accountsMock, 1)).invokeExperienceFieldUpdateOnStoreAccounts();
    }
}