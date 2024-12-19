/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for Accounts class
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.NcssTypeCount')
public class AccountsTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ASSERT_MESSAGE_TABLET_CASE_CREATION_INDICATOR_NOT_UPDATED = 'Unexpected result: failed to update Tablet Case creation indicator';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_TAXID = '12345';
    private static final String ACCOUNT_CONTROL_OF_PRICE = 'DoorDash';
    private static final String ACCOUNT_DECK_RANK = 'Jack';
    private static final String ACCOUNT_INVALID_FIELD_POPULATION_ASSERT = 'The fields on child account did not get associated correctly';
    private static final string ACCOUNT_LIFECYCLE_STATUS_CHURNED = 'Churned';
    private static final string ACCOUNT_LIFECYCLE_STATUS_NURTURE = 'Nurture';
    private static final string ACCOUNT_LIFECYCLE_STATUS_UNVETTED = 'Unvetted';
    private static final String AGGREGATE_BUSINESSACCOUNTNAME_FIELD_ALIAS = 'businessAccountName';
    private static final String AGGREGATE_BRANDNAME_FIELD_ALIAS = 'brandName';
    private static final String AGGREGATE_BRANDASSOCIATION_COUNT_ALIAS = 'brandAssociationsCount';
    private static final String ASSERT_MESSAGE_BRAND_ASSOCIATION_ERROR = 'Unexpected result: brand association did not occur on store Account.';
    private static final String ASSERT_MESSAGE_BRAND_ASSOCIATION_NULL_ERROR = 'Unexpected result: brand association incorrectly done on store Account.';
    private static final String ASSERT_MESSAGE_DECK_RANK_NOT_MATCHING = 'Unexpected result: Deck Rank is incorrectly stamped on business Account.';
    private static final String ASSERT_MESSAGE_DATA_VERIFICATION_STATUS_NOT_MATCHING = 'Unexpected result: Data Verification Status is not updated correctly on business Account.';
    private static final string ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR = 'Account lifecycle status was not updated correctly.';
    private static final String BILLING_COUNTRY_CODE_AU = 'AU';
    private static final String BRAND_NAME = 'KFC';
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical 1';
    private static final String CORPORATE = 'Corporate';
    static final String DEACTIVATED = 'Deactivated';
    private static final String DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE = 'Duplicate_Check_Payload_Chunk_Size';
    private static final String EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS = 'TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS';
    private static final String EVENT_TOPIC_UPDATE_DUPLICATE_STATUS = 'UPDATE_ACCOUNT_DUPLICATE_STATUS';
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC = 'TABLET_CASE_INSERT';
    private static final String EXTERNAL_ID_SOURCE_DRIVE_DB = 'DriveDb';
    private static final String KING_OF_SPADES_DECK_RANK = 'King of Spades';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_VALUE = '10';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String TABLET_DELIVERY_METHOD_DROP_SHIP = 'Drop-ship';
    private static final String TABLET_USERNAME = 'AccountsTest Username';
    private static final String TABLET_PASSWORD = 'AccountsTest Password';
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS';
    private static final String TABLET_USERNAME_UPDATED = 'AccountsTest Username Updated';
    private static final String TABLET_PASSWORD_UPDATED = 'AccountsTest Password Updated';
    private static final String TRIGGER_CONTEXT_AFTER = 'After';
    private static final String UNEXPECTED_ERROR = 'Unexpected Error: No Errors found.';
    private static final String UNVERIFIED = 'Unverified';
    private static final String VERIFIED = 'Verified';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String XREF_ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String XREF_ACTIVE_STATUS = 'Active';
    private static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    private static final String STORE_ACCOUNT_RECORD_TYPE_NAME = 'Store';
    private static final String CHANNEL_PARTNER_ACCOUNT_RECORD_TYPE_NAME = 'Channel_Partner';
    private static final String MX_CONTACT_STATUS2 = 'Can Contact - SM Will Review Before Outreach';
    private static final String MANAGED = 'OAM Managed';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Deactivated';
    private static final string STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE = 'Inactive';
    private static final String TEST_USER_ALIAS = 'MockUser';
    private static final String TEST_USER_EMAIL_ID = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com';
    private static final String TEST_USER_NAME = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com.test';
    private static final String TEST_ACCOUNT_NAME = 'Test Account ';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Mock User';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'GMT';
    private static final String ROE_NO_ACCESS_ERROR = 'You do not have access to change Rules of Engagement';
    private static final String ASSERTION_FAILED_ROE = 'Assertion failed due to Unexpected result.';
    private static final String ASSERTION_FAILED = 'Unexpected result: Segment is incorrectly updated on Account.';
    private static final String MX_PORTAL = 'Mx Portal';
    private static final String MANUAL = 'Manual';
    private static final String ACCOUNT_NAME = 'ACCOUNT 1';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Pets';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Invoice')
        .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Payments')
        .getRecordTypeId();
    private static final String LEGAL_BUSINESS_NAME = 'Legal Business Name';
    private static final String MX_ONBOARDING_LINK_ID = '84f37407-0a06-173c-fa24-b6708e2a091e';
    private static final String ASSERT_MESSAGE_TOTAL_NUMBER_OF_STORES_ERROR = 'Unexpected result: Total store count does not match.';
    private static final String SELF_DELIVERY_YES = 'Yes';
    private static final String CREATE_EVENT = 'CREATE';
    private static final String UPDATE_EVENT = 'UPDATE';

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Account> accountsList = new List<Account>();
        //IAccounts Instance Creation Call
        Accounts.newInstance(accountsList);
        //Default Constructor Call
        Accounts accountsObject = new Accounts(accountsList);
        //fflib_IDomainConstructor call
        Accounts.Constructor constructorObject = new Accounts.Constructor();
        constructorObject.construct(accountsList);
        System.assertNotEquals(
            Accounts.newInstance(accountsList),
            accountsObject,
            'These objects should not be similar'
        );
    }

    /**
     * @description to test when there is an update on Primary Vertical on Account then Update Mastered In Figment on Business Reference
     *Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountVerticalIsUpdatedThenMasterInFigmentOnBizRefShouldBeUpdated() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setFakeId()
            .toSObject();
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Brand_Owner__c, account.Id)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, brand.Id)
            .setField(Business_Reference__c.Mastered_In_Figment__c, true)
            .setFakeId()
            .toSObject();
        List<Account> smbAccounts = new List<Account>{ account };
        List<Business_Reference__c> bizRefs = new List<Business_Reference__c>{ businessReference };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IBusinessReferences businessReferencesMock = BusinessReferences.newInstance(
            new List<Business_Reference__c>{}
        );
        businessReferencesMock.updateMasteredInFigment(TRIGGER_CONTEXT_AFTER);
        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectByBrandOwnerId(new Set<Id>{ account.Id }))
            .thenReturn(bizRefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Test.startTest();
        Accounts.newInstance(smbAccounts)
            .initiateUpdateOnBusinessReferenceOnPrimaryVerticalChange();
        Test.stopTest();
        ((IBusinessReferences) mocks.verify(businessReferencesMock, 1))
            .updateMasteredInFigment(TRIGGER_CONTEXT_AFTER);
    }

    /**
     * @description To test franchise parent subtype updated to Franchisee.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountInsertedThenSetFranchiseParentAccountSubTypeToFranchisee() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id franchiseAccountId1 = Fake.generateId(Account.class);
        Id franchiseAccountId2 = Fake.generateId(Account.class);

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                Franchise_Parent__c = franchiseAccountId1,
                RecordTypeId = accRecordType
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                Franchise_Parent__c = franchiseAccountId2,
                RecordTypeId = accRecordType
            )
        };

        List<Account> franchiseAccounts = new List<Account>{
            new Account(Id = franchiseAccountId1, Name = 'Test franchise 1', Type = 'test'),
            new Account(Id = franchiseAccountId2, Name = 'Test franchise 2', Type = 'test')
        };

        Set<Id> accountIds = new Map<Id, SObject>(franchiseAccounts).keySet();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IAccounts accInstance = Accounts.newInstance(storeAccounts);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectNonFranchiseeAccountsById(accountIds))
            .thenReturn(franchiseAccounts);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        accInstance.updateFranchiseParentSubtype();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => franchiseAccountId1,
                        Account.Type => 'Franchisee'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => franchiseAccountId2,
                        Account.Type => 'Franchisee'
                    }
                )
            );
    }

    /**
     * @description To test franchise parent subtype updated to franchisee and not direct parent subtype value
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountsInsertedThenOnlyFranchiseParentAccountsHaveSubTypeChangedToFranchisee() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id franchiseAccountId1 = Fake.generateId(Account.class);
        Id franchiseAccountId2 = Fake.generateId(Account.class);

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                Franchise_Parent__c = franchiseAccountId1,
                RecordTypeId = accRecordType
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                ParentId = franchiseAccountId2,
                RecordTypeId = accRecordType
            )
        };

        List<Account> franchiseAccounts = new List<Account>{
            new Account(Id = franchiseAccountId1, Name = 'Test franchise 1', Type = 'test'),
            new Account(Id = franchiseAccountId2, Name = 'Test franchise 2', Type = 'test')
        };

        Set<Id> accountIds = new Set<Id>{ franchiseAccountId1 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IAccounts accInstance = Accounts.newInstance(storeAccounts);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectNonFranchiseeAccountsById(accountIds))
            .thenReturn(new List<Account>{ franchiseAccounts[0] });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        accInstance.updateFranchiseParentSubtype();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => franchiseAccountId1,
                        Account.Type => 'Franchisee'
                    }
                )
            );
    }

    /**
     * @description Tests that the Sub_Type value is only updated on the Franchise Parent
     * of Store accounts.  Business Accounts should be ignored.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessAccountInsertedThenFranchiseParentSubTypeIsNotChanged() {
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id franchiseAccountId1 = Fake.generateId(Account.class);
        Id franchiseAccountId2 = Fake.generateId(Account.class);

        List<Account> businessAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                Franchise_Parent__c = franchiseAccountId1,
                RecordTypeId = accRecordType
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                ParentId = franchiseAccountId2,
                RecordTypeId = accRecordType
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectNonFranchiseeAccountsById(new Set<Id>()))
            .thenReturn(new List<Account>());
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        Accounts.newInstance(businessAccounts).updateFranchiseParentSubtype();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test update address verification status and date
     * This address attributes reset has been bypassed for automated process user.
     */
    @isTest
    private static void testWhenAccAddressUpdatedThenStatusChanged() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test 1',
                BillingStreet = '123 New Street',
                Address_Verification_Status__c = 'Verified'
            ),
            new Account(
                Id = account2Id,
                Name = 'Test 2',
                BillingStreet = '987 New Street',
                Address_Verification_Status__c = 'Verified'
            )
        };

        Accounts.newInstance(newAccounts).resetAddressAttributes();
        System.assertEquals(
            'Unverified',
            newAccounts[0].Address_Verification_Status__c,
            'Status not changed'
        );
        System.assertEquals(
            'Unverified',
            newAccounts[1].Address_Verification_Status__c,
            'Status not changed'
        );
        System.assertEquals(null, newAccounts[0].Coverage__c, 'Coverage not changed');
        System.assertEquals(null, newAccounts[1].Coverage__c, 'Status not changed');
        System.assertEquals(null, newAccounts[0].SubMarket__c, 'Sub-Market ID not changed');
        System.assertEquals(null, newAccounts[1].SubMarket__c, 'Sub-Market ID not changed');
        System.assertEquals(null, newAccounts[0].Starting_Point__c, 'Starting Point not changed');
        System.assertEquals(null, newAccounts[1].Starting_Point__c, 'Starting Point not changed');
        System.assertEquals(
            null,
            newAccounts[0].Starting_Point_ID__c,
            'Starting Point ID not changed'
        );
        System.assertEquals(
            null,
            newAccounts[1].Starting_Point_ID__c,
            'Starting Point ID not changed'
        );
    }

    /**
     * @description To test update address verification date
     */
    @isTest
    private static void testWhenAccStatusUpdateThenDateChanged() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test 1',
                Address_Verification_Status__c = 'Verified'
            ),
            new Account(
                Id = account2Id,
                Name = 'Test 2',
                Address_Verification_Status__c = 'Verified'
            )
        };

        Accounts.newInstance(newAccounts).updateAddressVerificationDate();
        System.assertNotEquals(null, newAccounts[0].Address_Verification_Date__c, 'Date is null');
        System.assertNotEquals(null, newAccounts[1].Address_Verification_Date__c, 'Date is null');
    }

    /**
     * @description To test update address verification date
     */
    @isTest
    private static void testWhenAccStatusUpdateToRejectedThenDateChanged() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test 1',
                Address_Verification_Status__c = 'Rejected'
            ),
            new Account(
                Id = account2Id,
                Name = 'Test 2',
                Address_Verification_Status__c = 'Verified'
            )
        };

        Accounts.newInstance(newAccounts).updateAddressVerificationDate();
        System.assertNotEquals(null, newAccounts[0].Address_Verification_Date__c, 'Date is null');
        System.assertNotEquals(null, newAccounts[1].Address_Verification_Date__c, 'Date is null');
    }

    /**
     * @description It is used to test whether the defined fields on the child (Business/Store)
     * accounts are copied from the associated parent account.
     */
    @isTest
    private static void testWhenChildAccountInsertedThenDefinedFieldsPopulatedByParent() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id businessOwner = fflib_IDGenerator.generate(User.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.TaxID__c, ACCOUNT_TAXID)
            .setField(Account.OwnerId, businessOwner)
            .setField(Account.Control_of_Price__c, ACCOUNT_CONTROL_OF_PRICE)
            .setField(Account.Legal_Business_Name__c, 'Test Legal Business Name')
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Test.startTest();
        Accounts.newInstance(childAccounts).populateFieldsOnChildAccountsByParent();
        Test.stopTest();
        //Assert
        System.assertEquals(
            childAccount.Segment__c,
            ACCOUNT_SEGMENT_SMB,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(childAccount.TaxID__c, null, ACCOUNT_INVALID_FIELD_POPULATION_ASSERT);
        System.assertEquals(
            childAccount.OwnerId,
            businessOwner,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            childAccount.Control_of_Price__c,
            ACCOUNT_CONTROL_OF_PRICE,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            childAccount.Legal_Business_Name__c,
            'Test Legal Business Name',
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
    }

    /**
     * @description It is used to test whether the tax id on the child
     * accounts of business record type are copied from the associated parent account.
     */
    @isTest
    private static void testWhenBusinessChildAccountUpdatedThenTaxIdPopulatedByParent() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id businessOwner = fflib_IDGenerator.generate(User.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.Type, CORPORATE)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.TaxID__c, ACCOUNT_TAXID)
            .setField(Account.OwnerId, businessOwner)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.Type, CORPORATE)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Test.startTest();
        Accounts.newInstance(childAccounts).populateFieldsOnChildAccountsByParent();
        Test.stopTest();
        //Assert
        System.assertEquals(
            childAccount.Segment__c,
            ACCOUNT_SEGMENT_SMB,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            childAccount.TaxID__c,
            parentAccount.TaxID__c,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            childAccount.OwnerId,
            businessOwner,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
    }

    /**
     * @description To test update of segment,control of price and deck rank
     * for Business Account Insert
     */
    @isTest
    private static void testWhenBusinessAccountInsertedThenSegmentControlOfPriceAndDeckRankUpdated() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account ultimateBusinessAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Ultimate Business')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Control_of_Price__c, ACCOUNT_CONTROL_OF_PRICE)
            .setFakeId()
            .toSObject();
        Account parentBusinessAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, ultimateBusinessAccount.Id)
            .setField(Account.Name, 'Parent Business')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Control_of_Price__c, ACCOUNT_CONTROL_OF_PRICE)
            .setField(Account.Deck_Rank__c, ACCOUNT_DECK_RANK)
            .setFakeId()
            .toSObject();
        Account childStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentBusinessAccount.Id)
            .setField(Account.Name, 'Child Store')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childStoreAccount, parentBusinessAccount };
        List<Account> parentAccounts = new List<Account>{
            ultimateBusinessAccount,
            parentBusinessAccount
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        List<String> payloads = new List<String>{
            JSON.serialize(ultimateBusinessAccount.Id),
            JSON.serialize(parentBusinessAccount.Id)
        };
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ ultimateBusinessAccount.Id, parentBusinessAccount.Id }
                )
            )
            .thenReturn(parentAccounts);
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);

        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_VALUE
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ ultimateBusinessAccount.Id, parentBusinessAccount.Id },
                    Integer.valueOf(TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_VALUE)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        //Act
        Test.startTest();
        Accounts.newInstance(childAccounts).populateFieldsOnChildAccountsByParent();
        Test.stopTest();
        //Assert
        System.assertEquals(childStoreAccount.Segment__c, 'SMB', 'Invalid segment stamped');
        System.assertEquals(parentBusinessAccount.Segment__c, 'SMB', 'Invalid segment stamped');
        System.assertEquals(
            childStoreAccount.Control_of_Price__c,
            ACCOUNT_CONTROL_OF_PRICE,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            parentBusinessAccount.Control_of_Price__c,
            ACCOUNT_CONTROL_OF_PRICE,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            childStoreAccount.Deck_Rank__c,
            ACCOUNT_DECK_RANK,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
    }

    /**
     * @description To test concatenate merchant vertical with Primary vertical for Business Accounts
     */
    @isTest
    private static void testWhenAccountInsertedThenVerticalConcatenated() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Primary_Vertical__c, 'Alcohol')
            .setField(Account.Additional_Verticals__c, 'Gifts')
            .setFakeId()
            .toSObject();
        List<Account> parentAccounts = new List<Account>{ parentAccount };

        //Act
        Accounts.newInstance(parentAccounts).stampPrimaryVerticalOnMerchantVertical();

        //Assert
        System.assertEquals(
            parentAccount.Additional_Verticals__c,
            'Gifts;Alcohol',
            'Invalid merchant vertical concatenated'
        );
    }

    /**
     * @description To test concatenate merchant vertical with Primary vertical as null for Business Accounts
     */
    @isTest
    private static void testWhenPrimaryVerticalBlankThenNoConcatenation() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Business Account')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Primary_Vertical__c, '')
            .setField(Account.Additional_Verticals__c, 'Gifts')
            .setFakeId()
            .toSObject();
        List<Account> parentAccounts = new List<Account>{ parentAccount };

        //Act
        Accounts.newInstance(parentAccounts).stampPrimaryVerticalOnMerchantVertical();

        //Assert
        System.assertEquals(
            parentAccount.Additional_Verticals__c,
            'Gifts',
            'Invalid merchant vertical concatenated'
        );
    }

    /**
     * @description To test concatenate multiple merchant vertical with Primary vertical for Business Accounts
     */
    @isTest
    private static void testWhenAccountInsertedThenMultipleVerticalsConcatenated() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Primary_Vertical__c, 'Alcohol')
            .setField(Account.Additional_Verticals__c, 'Gifts;Floral')
            .setFakeId()
            .toSObject();
        List<Account> parentAccounts = new List<Account>{ parentAccount };

        //Act
        Accounts.newInstance(parentAccounts).stampPrimaryVerticalOnMerchantVertical();

        //Assert
        System.assertEquals(
            parentAccount.Additional_Verticals__c,
            'Gifts;Floral;Alcohol',
            'Invalid merchant vertical concatenated'
        );
    }

    /**
     * @description To test calculate total number of stores
     */
    @isTest
    private static void testWhenAccountStoreCountUpdatedThenCalculateTotalStoreCount() {
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                Corporate_Owned_Store_Count__c = 1,
                Franchise_Owned_Store_Count__c = null
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                Corporate_Owned_Store_Count__c = null,
                Franchise_Owned_Store_Count__c = 2
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 3',
                Corporate_Owned_Store_Count__c = 2,
                Franchise_Owned_Store_Count__c = 3
            )
        };

        Accounts.newInstance(newAccounts).calculateTotalNumberOfStores();

        System.assertEquals(
            1,
            newAccounts[0].Total_Number_Of_Stores__c,
            'Total store count does not match'
        );
        System.assertEquals(
            2,
            newAccounts[1].Total_Number_Of_Stores__c,
            'Total store count does not match'
        );
        System.assertEquals(
            5,
            newAccounts[2].Total_Number_Of_Stores__c,
            'Total store count does not match'
        );
    }

    /**
     * @description To test store name of updated/created store when both Merchant Id and Billing Street fields are blank
     */
    @isTest
    private static void testWhenBothMrechantIdAndBillingStreerAreBlankForStoreThenStoreNameShouldBeUpdated() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        //Act
        Accounts.newInstance(childAccounts).populateStoreName();

        //Assert
        System.assertEquals(childAccount.Name, 'Parent', 'Invalid name stamped');
    }

    /**
     * @description To test store name of updated/created store when Merchant Id is blank and BillingStreet have value.
     */
    @isTest
    private static void testWhenBillingStreetNotBlankAndMechantIdBlankForStoreThenStoreNameShouldBeUpdated() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.BillingStreet, 'New Street')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        //Act
        Accounts.newInstance(childAccounts).populateStoreName();

        //Assert
        System.assertEquals(childAccount.Name, 'Parent - New Street', 'Invalid name stamped');
    }

    /**
     * @description To test store name of updated/created store when Merchant Id have value.
     */
    @isTest
    private static void testWhenMerchantIdHaveValueForStoreThenStoreNameShouldBeUpdated() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.Merchant_Supplied_ID__c, 12345)
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        //Act
        Accounts.newInstance(childAccounts).populateStoreName();

        //Assert
        System.assertEquals(childAccount.Name, 'Parent - 12345', 'Invalid name stamped');
    }

    /**
     * @description To test store name of updated/created store when Merchant Id and Brand have value.
     */
    @isTest
    private static void testWhenBrandHasValueForStoreThenStoreNameShouldBeUpdated() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Brand__c brandRec = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.Merchant_Supplied_ID__c, 12345)
            .setField(Account.Brand__c, brandRec.Id)
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        List<Brand__c> brands = new List<Brand__c>{ brandRec };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBrandsSelector brandsSelectorMock = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.when(brandsSelectorMock.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(brandsSelectorMock.selectById(new Set<Id>{ brandRec.Id })).thenReturn(brands);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(brandsSelectorMock);

        //Act
        Accounts.newInstance(childAccounts).populateStoreName();

        //Assert
        System.assertEquals(childAccounts[0].Name, 'KFC - 12345', 'Invalid name stamped');
    }

    /**
     * @description To test currency when the country is updated.
     */
    @isTest
    private static void testWhenAccountInsertedThenCurrencyShouldBeUpdated() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id accountIdAZ = Fake.generateId(Account.class);
        Id accountIdCA = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountIdAZ,
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 1',
                BillingCountryCode = 'AZ'
            ),
            new Account(
                Id = accountIdCA,
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 2',
                BillingCountry = 'Canada'
            )
        };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountIdAZ,
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 1',
                BillingCountryCode = 'CA'
            ),
            new Account(
                Id = accountIdCA,
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 2',
                BillingCountry = 'United States'
            )
        };
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Azerbaijan',
                DeveloperName = 'Azerbaijan',
                Country__c = 'Azerbaijan',
                Currency__c = 'Azerbaijan Manat',
                Currency_Code__c = 'AZN',
                Country_Code__c = 'AZ'
            ),
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Canada',
                DeveloperName = 'Canada',
                Country__c = 'Canada',
                Currency__c = 'Canadian Dollar',
                Currency_Code__c = 'CAD',
                Country_Code__c = 'CA'
            ),
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'United States',
                DeveloperName = 'United States',
                Country__c = 'United States',
                Currency__c = 'United States dollar',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICountryAttributesMappingSelector selectorMock = (ICountryAttributesMappingSelector) mocks.mock(
            ICountryAttributesMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(testData);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(newAccounts).populateCurrency(new Map<Id, SObject>(oldAccounts));

        //Assert
        System.assertEquals(newAccounts[0].CurrencyIsoCode, 'CAD', 'Invalid Currency');
        System.assertEquals(newAccounts[1].CurrencyIsoCode, 'USD', 'Invalid Currency');
    }

    /**
     * @description To test the format of the phone number when validation error is thrown for other countries.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenValidateBasedOnCountryLimitForOtherCountries() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 2',
                Phone = '123456789123453456',
                BillingCountry = 'Finland',
                BillingCountryCode = 'FI'
            )
        };
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Finland',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'FI',
                Phone_Maximum_Digits__c = 15,
                Phone_Country_Code__c = '358'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICountryAttributesMappingSelector selectorMock = (ICountryAttributesMappingSelector) mocks.mock(
            ICountryAttributesMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(testData);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(newAccounts).validateAndNormalizePhoneNumberFormat();
        //Assert
        System.assertEquals(
            newAccounts[0].getErrors()[0].getMessage(),
            'The maximum number of digits allowed in your country is 15 digits for a phone number, Please re-enter the phone number',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test partnership status and date calculation
     */
    @isTest
    private static void testWhenAccountActivationStatusUpdatedThenUpdateMostRecentDate() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id channelPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = storeRecordTypeId,
                Activation_Status__c = 'Active'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                RecordTypeId = storeRecordTypeId,
                Activation_Status__c = 'Deactivated'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 3',
                RecordTypeId = storeRecordTypeId,
                Activation_Status__c = 'Inactive'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 4',
                RecordTypeId = channelPartnerRecordTypeId,
                Activation_Status__c = 'Active'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 5',
                RecordTypeId = businessRecordTypeId,
                Activation_Status__c = 'Deactivated'
            )
        };

        Accounts.newInstance(newAccounts).updateMostRecentDateForStoreAccount();
        System.assertEquals(
            System.now(),
            newAccounts[0].Most_Recent_Activation_Date__c,
            'Activation date does not match'
        );
        System.assertEquals(
            System.now(),
            newAccounts[1].Most_Recent_Deactivation_Date__c,
            'Deactivation date does not match'
        );
        System.assertEquals(
            null,
            newAccounts[2].Most_Recent_Activation_Date__c,
            'Activation date does not match'
        );
        System.assertEquals(
            null,
            newAccounts[2].Most_Recent_Deactivation_Date__c,
            'Deactivation date does not match'
        );
        System.assertEquals(
            null,
            newAccounts[3].Most_Recent_Activation_Date__c,
            'Activation date does not match'
        );
        System.assertEquals(
            null,
            newAccounts[4].Most_Recent_Deactivation_Date__c,
            'Deactivation date does not match'
        );
    }

    /**
     * @description To test when business account inserted but there is metadata record then do not update update legal entity name
     */
    @isTest
    private static void testWhenBusinessAccountUpdatedThenDoNotUpdateLegalEntityName() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 2')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'US')
            .setField(Account.BillingStateCode, 'PR')
            .setFakeId()
            .toSObject();
        Account[] newAccounts = new List<Account>{ account1 };
        List<Legal_Entity_Mapping__mdt> metaDataRecord = new List<Legal_Entity_Mapping__mdt>{
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Channel_Partner_1',
                Legal_Entity_Name__c = 'DoorDash Technologies Puerto Rico, LLC',
                Billing_State_Code__c = 'PR',
                Record_Type_Name__c = 'Channel_Partner'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILegalEntityMappingSelector selectorMock = (ILegalEntityMappingSelector) mocks.mock(
            ILegalEntityMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Legal_Entity_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(metaDataRecord);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(newAccounts).updateDoordashLegalEntityAndControlOfPrice(UPDATE_EVENT);
        //Assert
        System.assertEquals(
            newAccounts[0].DoorDash_Legal_Entity__c,
            null,
            'Legal entity name does not match'
        );
    }
    /**
     * @description To test when business account inserted then update legal entity name
     */
    @isTest
    private static void testWhenPuertoRicoBusinessAccountThenUpdateLegalEntityName() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 1')
            .setField(Account.Record_Type_Name__c, STORE_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'US')
            .setField(Account.BillingStateCode, 'PR')
            .setFakeId()
            .toSObject();
        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 2')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'US')
            .setField(Account.BillingStateCode, 'PR')
            .setFakeId()
            .toSObject();
        Account account3 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 3')
            .setField(Account.Record_Type_Name__c, CHANNEL_PARTNER_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'US')
            .setField(Account.BillingStateCode, 'PR')
            .setFakeId()
            .toSObject();
        Account[] newAccounts = new List<Account>{ account1, account2, account3 };
        List<Legal_Entity_Mapping__mdt> metaDataRecord = new List<Legal_Entity_Mapping__mdt>{
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Business_1',
                Legal_Entity_Name__c = 'DoorDash Technologies Puerto Rico, LLC',
                Billing_State_Code__c = 'PR',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Channel_Partner_1',
                Legal_Entity_Name__c = 'DoorDash Technologies Puerto Rico, LLC',
                Billing_State_Code__c = 'PR',
                Record_Type_Name__c = 'Channel_Partner'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILegalEntityMappingSelector selectorMock = (ILegalEntityMappingSelector) mocks.mock(
            ILegalEntityMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Legal_Entity_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(metaDataRecord);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(newAccounts).updateDoordashLegalEntityAndControlOfPrice(CREATE_EVENT);
        //Assert
        System.assertEquals(
            newAccounts[0].DoorDash_Legal_Entity__c,
            null,
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[1].DoorDash_Legal_Entity__c,
            'DoorDash Technologies Puerto Rico, LLC',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[2].DoorDash_Legal_Entity__c,
            'DoorDash Technologies Puerto Rico, LLC',
            'Legal entity name does not match'
        );
    }
    /**
     * @description To test when business account inserted and the country code is AU then update legal entity name
     */
    @isTest
    private static void testWhenCountryCodeIsAustraliaThenUpdateLegalEntityName() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 1')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'AU')
            .setFakeId()
            .toSObject();

        Account[] newAccounts = new List<Account>{ account1 };
        List<Legal_Entity_Mapping__mdt> metaDataRecord = new List<Legal_Entity_Mapping__mdt>{
            new Legal_Entity_Mapping__mdt(
                Label = 'AU',
                DeveloperName = 'Australia_Business_2',
                Legal_Entity_Name__c = 'DoorDash Technologies Australia Pty Ltd',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Channel_Partner_1',
                Legal_Entity_Name__c = 'DoorDash Technologies Puerto Rico, LLC',
                Billing_State_Code__c = 'PR',
                Record_Type_Name__c = 'Channel_Partner'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILegalEntityMappingSelector selectorMock = (ILegalEntityMappingSelector) mocks.mock(
            ILegalEntityMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Legal_Entity_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(metaDataRecord);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(newAccounts).updateDoordashLegalEntityAndControlOfPrice(CREATE_EVENT);
        //Assert
        System.assertEquals(
            newAccounts[0].DoorDash_Legal_Entity__c,
            'DoorDash Technologies Australia Pty Ltd',
            'Legal entity name is matching'
        );
    }

    /**
     * @description To test when primary vertical updated then update legal entity name
     */
    @isTest
    private static void testWhenBusinessAccountPrimaryVerticalCountryCodeSetThenUpdateLegalEntityName() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 1')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'US')
            .setField(Account.Primary_Vertical__c, 'Alcohol')
            .setFakeId()
            .toSObject();
        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 2')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'NZ')
            .setFakeId()
            .toSObject();
        Account account3 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 3')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'IN')
            .setFakeId()
            .toSObject();
        Account account4 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 4')
            .setField(Account.Record_Type_Name__c, CHANNEL_PARTNER_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'NZ')
            .setFakeId()
            .toSObject();
        Account account5 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 5')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'US')
            .setField(Account.Primary_Vertical__c, 'Rx')
            .setFakeId()
            .toSObject();
        Account account6 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 6')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'CA')
            .setField(Account.Primary_Vertical__c, 'Baby')
            .setFakeId()
            .toSObject();
        Account account7 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 7')
            .setField(Account.Record_Type_Name__c, CHANNEL_PARTNER_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'CA')
            .setFakeId()
            .toSObject();
        Account account8 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 8')
            .setField(Account.Record_Type_Name__c, CHANNEL_PARTNER_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'AU')
            .setFakeId()
            .toSObject();
        Account account9 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 9')
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'CA')
            .setField(Account.Primary_Vertical__c, 'Dashmart')
            .setFakeId()
            .toSObject();
        Account[] newAccounts = new List<Account>{
            account1,
            account2,
            account3,
            account4,
            account5,
            account6,
            account7,
            account8,
            account9
        };
        List<Legal_Entity_Mapping__mdt> metaDataRecord = new List<Legal_Entity_Mapping__mdt>{
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Business_1',
                Legal_Entity_Name__c = 'DoorDash Technologies Puerto Rico, LLC',
                Billing_State_Code__c = 'PR',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Business_3',
                Legal_Entity_Name__c = 'DoorDash Inc.',
                Primary_Vertical__c = 'Rx',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'NZ',
                DeveloperName = 'New_Zealand_Business_1',
                Legal_Entity_Name__c = 'DoorDash Technologies New Zealand',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'NZ',
                DeveloperName = 'New_Zealand_Channel_Partner_1',
                Legal_Entity_Name__c = 'DoorDash Technologies New Zealand',
                Record_Type_Name__c = 'Channel_Partner'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United_States_Business_2',
                Legal_Entity_Name__c = 'DoorDash G&C, LLC',
                Primary_Vertical__c = 'Alcohol',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'CA',
                DeveloperName = 'Canada_Business_2',
                Legal_Entity_Name__c = 'DoorDash Technologies Canada, Inc.',
                Primary_Vertical__c = 'Baby',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'CA',
                DeveloperName = 'Canada_Business_1',
                Legal_Entity_Name__c = 'Rapid Retail Canada Inc.',
                Primary_Vertical__c = 'Dashmart',
                Record_Type_Name__c = 'Business'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'CA',
                DeveloperName = 'Canada_Channel_Partner_1',
                Legal_Entity_Name__c = 'DoorDash Technologies Canada, Inc.',
                Record_Type_Name__c = 'Channel_Partner'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'AU',
                DeveloperName = 'Australia_Channel_Partner',
                Legal_Entity_Name__c = 'DoorDash Technologies Australia Pty Ltd',
                Record_Type_Name__c = 'Channel_Partner'
            ),
            new Legal_Entity_Mapping__mdt(
                Label = 'AU',
                DeveloperName = 'Australia_Business_2',
                Legal_Entity_Name__c = 'DoorDash Technologies Australia Pty Ltd',
                Record_Type_Name__c = 'Business'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILegalEntityMappingSelector selectorMock = (ILegalEntityMappingSelector) mocks.mock(
            ILegalEntityMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Legal_Entity_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(metaDataRecord);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(newAccounts).updateDoordashLegalEntityAndControlOfPrice(UPDATE_EVENT);
        //Assert
        System.assertEquals(
            newAccounts[0].DoorDash_Legal_Entity__c,
            'DoorDash G&C, LLC',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[1].DoorDash_Legal_Entity__c,
            'DoorDash Technologies New Zealand',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[2].DoorDash_Legal_Entity__c,
            null,
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[3].DoorDash_Legal_Entity__c,
            'DoorDash Technologies New Zealand',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[4].DoorDash_Legal_Entity__c,
            'DoorDash Inc.',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[5].DoorDash_Legal_Entity__c,
            'DoorDash Technologies Canada, Inc.',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[6].DoorDash_Legal_Entity__c,
            'DoorDash Technologies Canada, Inc.',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[7].DoorDash_Legal_Entity__c,
            'DoorDash Technologies Australia Pty Ltd',
            'Legal entity name does not match'
        );
        System.assertEquals(
            newAccounts[8].DoorDash_Legal_Entity__c,
            'Rapid Retail Canada Inc.',
            'Legal entity name does not match'
        );
    }

    /**
     * @description To test when store Account is updated with POS_Integration_Type__c
     * or Tablet_Delivery_Method__c field then WorkOrders domain is called.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountUpdatedThenStoreLevelWorkPlanIndicatorsOnParentWorkOrderEnabled() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account mockAccount = new Account(
            Id = storeAccountId,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            Name = ACCOUNT_NAME_STORE,
            Tablet_Delivery_Method__c = TABLET_DELIVERY_METHOD_DROP_SHIP
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IParentWorkOrderSyncService parentWorkOrderSyncServiceMock = (IParentWorkOrderSyncService) mocks.mock(
            IParentWorkOrderSyncService.class
        );
        Application.SERVICE.setMock(
            IParentWorkOrderSyncService.class,
            parentWorkOrderSyncServiceMock
        );
        Accounts.newInstance(new List<Account>{ mockAccount })
            .enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder();
        ((IParentWorkOrderSyncService) mocks.verify(parentWorkOrderSyncServiceMock, 1))
            .enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
                new Set<Id>{ storeAccountId }
            );
    }

    /**
     * @description To test update Developer ID and Developer ID Backend
     */
    @isTest
    private static void testWhenAccountUpdatedThenDeveloperIDAndDeveloperIDBackendChanged() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                Developer_ID__c = 'Canadian Tire - 746479370',
                Developer_ID_Backend__c = '746479370'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                Developer_ID__c = 'Canadian Tire - 746479370',
                Developer_ID_Backend__c = null
            ),
            new Account(
                Id = accountId3,
                Name = 'Test 3',
                Developer_ID__c = 'Canadian Tire - 746479370',
                Developer_ID_Backend__c = '123812638'
            ),
            new Account(
                Id = accountId4,
                Name = 'Test 4',
                Developer_ID__c = 'Canadian Tire - 746479370',
                Developer_ID_Backend__c = '746479370'
            )
        };

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                Developer_ID__c = 'Canadian Tire - 746479370',
                Developer_ID_Backend__c = '918557861'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                Developer_ID__c = 'CaptainAI (US) - 918557861',
                Developer_ID_Backend__c = null
            ),
            new Account(
                Id = accountId3,
                Name = 'Test 3',
                Developer_ID__c = null,
                Developer_ID_Backend__c = '918557861'
            ),
            new Account(
                Id = accountId4,
                Name = 'Test 4',
                Developer_ID__c = 'Papa Johns (PJI) - CAN - 236312114',
                Developer_ID_Backend__c = null
            )
        };

        Accounts.newInstance(newAccounts)
            .updateDeveloperIDOrDeveloperIDBackend(new Map<Id, SObject>(oldAccounts));
        System.assertEquals(
            'CaptainAI (US) - 918557861',
            newAccounts[0].Developer_ID__c,
            'Developer ID is not updated'
        );
        System.assertEquals(
            '918557861',
            newAccounts[1].Developer_ID_Backend__c,
            'Developer ID Backend is not updated'
        );
        System.assertEquals(
            'CaptainAI (US) - 918557861',
            newAccounts[2].Developer_ID__c,
            'Developer ID is not updated'
        );
        System.assertEquals(
            '236312114',
            newAccounts[3].Developer_ID_Backend__c,
            'Developer ID Backend is not updated'
        );
    }

    /**
     * @description To test update of currency of the payment account when account currency is updated
     * @JIRA# LEM-3121
     */
    @isTest
    private static void testWhenAccountCurrencyUpdatedThenUpdatePaymentAccountCurrency() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 1')
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, 'USD')
            .setFakeId()
            .toSObject();
        Payment_Account__c paymentAccount1 = (Payment_Account__c) new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Business_Account__c, account1.Id)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID)
            .setParent(
                'Business_Account__r',
                new Fake(Account.class)
                    .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.CurrencyIsoCode, 'USD')
            )
            .setFakeId()
            .toSObject();
        Payment_Account__c paymentAccount2 = (Payment_Account__c) new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Business_Account__c, account1.Id)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID)
            .setParent(
                'Business_Account__r',
                new Fake(Account.class)
                    .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.CurrencyIsoCode, 'USD')
            )
            .setFakeId()
            .toSObject();
        List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{
            paymentAccount1
        };
        List<Account> accountList = new List<Account>{ account1 };

        Set<Id> accountIdSet = new Set<Id>{ account1.Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccountsSelector selectorMock = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Payment_Account__c.SObjectType);
        mocks.when(selectorMock.selectRelatedBusinessAccounts(accountIdSet))
            .thenReturn(paymentAccountList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Accounts.newInstance(accountList).updateCurrencyOfPaymentAccount();
        //Assert
        System.assertEquals(
            paymentAccountList[0].CurrencyIsoCode,
            'USD',
            'Currency does not match'
        );
        System.assertNotEquals(paymentAccount2.CurrencyIsoCode, 'USD', 'Currency does not match');
    }

    /**
     * @description To test update of Alcohol Product Eligibility for Australia and NewZealand Countries
     */
    @isTest
    private static void testWhenCountryIsAustraliaOrNewZealandThenPopulateAlcoholProductEligibility() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id accountId5 = Fake.generateId(Account.class);
        Id accountId6 = Fake.generateId(Account.class);

        Account[] accountRecords = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                Primary_Vertical__c = 'Alcohol',
                BillingCountryCode = 'AU'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                Primary_Vertical__c = 'Alcohol',
                BillingCountryCode = 'AU',
                Alcohol_Eligibility__c = 'Dry'
            ),
            new Account(
                Id = accountId3,
                Name = 'Test 3',
                Primary_Vertical__c = 'Beauty',
                BillingCountryCode = 'AU',
                Alcohol_Eligibility__c = 'Dry'
            ),
            new Account(
                Id = accountId4,
                Name = 'Test 4',
                Primary_Vertical__c = 'Beauty',
                BillingCountryCode = 'NZ',
                Alcohol_Eligibility__c = 'Moist'
            ),
            new Account(
                Id = accountId5,
                Name = 'Test 5',
                Primary_Vertical__c = 'Grocery',
                BillingCountryCode = 'NZ',
                Alcohol_Eligibility__c = 'Moist'
            ),
            new Account(
                Id = accountId6,
                Name = 'Test 6',
                Primary_Vertical__c = 'Convenience',
                BillingCountryCode = 'NZ'
            )
        };
        Accounts.newInstance(accountRecords).updateAlcoholProductEligibility();

        System.assertEquals(
            'Delivery;Pickup',
            accountRecords[0].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup',
            accountRecords[1].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Not Eligible',
            accountRecords[2].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup',
            accountRecords[3].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup',
            accountRecords[4].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup',
            accountRecords[5].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
    }
    /**
     * @description To test update of Alcohol Product Eligibility for countries other than Australia and NewZealand
     */
    @isTest
    private static void testWhenCountryIsNotAustraliaOrNewZealandThenPopulateAlcoholProductEligibility() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id accountId5 = Fake.generateId(Account.class);

        Account[] accountRecords = new List<Account>{
            new Account(
                Id = accountId1,
                Name = 'Test 1',
                Primary_Vertical__c = 'Alcohol',
                BillingCountryCode = 'US'
            ),
            new Account(
                Id = accountId2,
                Name = 'Test 2',
                Primary_Vertical__c = 'Alcohol',
                BillingCountryCode = 'AZ',
                Alcohol_Eligibility__c = 'Dry'
            ),
            new Account(
                Id = accountId3,
                Name = 'Test 3',
                Primary_Vertical__c = 'Beauty',
                BillingCountryCode = 'CA',
                Alcohol_Eligibility__c = 'Dry'
            ),
            new Account(
                Id = accountId4,
                Name = 'Test 4',
                Primary_Vertical__c = 'Beauty',
                BillingCountryCode = 'GE',
                Alcohol_Eligibility__c = 'Moist'
            ),
            new Account(
                Id = accountId5,
                Name = 'Test 5',
                Primary_Vertical__c = 'Grocery',
                BillingCountryCode = 'JP',
                Alcohol_Eligibility__c = 'Moist'
            )
        };
        Accounts.newInstance(accountRecords).updateAlcoholProductEligibility();

        System.assertEquals(
            'Delivery;Pickup;Self-Delivery',
            accountRecords[0].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup;Self-Delivery',
            accountRecords[1].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Not Eligible',
            accountRecords[2].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup;Self-Delivery',
            accountRecords[3].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
        System.assertEquals(
            'Delivery;Pickup;Self-Delivery',
            accountRecords[4].Alcohol_Product_Eligibility__c,
            'Alcohol Product Eligibility Does not match'
        );
    }

    /**
     * @description To test population of duplicate status modified by and duplicate status modified at
     *  * @JIRA# LEM-3846
     */
    @isTest
    private static void testWhenMethodCalledThenRelatedDuplicateStatusFieldsAreUpdated() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        List<Account> businessAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = businessRecordTypeId
            )
        };

        //Act
        Accounts.newInstance(businessAccounts).updateRelatedDuplicateStatusFields();

        //Assert
        System.assertNotEquals(
            businessAccounts[0].Duplicate_Status_Modified_At__c,
            null,
            'Duplicate status modified by is null'
        );
        System.assertEquals(
            businessAccounts[0].Duplicate_Status_Modified_By__c,
            businessAccountS[0].LastModifiedById,
            'Duplicate status modified at does not match'
        );
    }

    /**
     * @description To test when account Tax Id field is updated on Account then corresponding value is encrpyted and stored in Encrypted_Tax_Id__c.
     */
    @isTest
    private static void testWhenAccountUpdateWithTaxIdThenPopulateEncryptedTaxId() {
        Encrypted_Value__c encryptedValueRecord = (Encrypted_Value__c) new Fake(
                Encrypted_Value__c.class
            )
            .setField(Encrypted_Value__c.Name, 'AES-256')
            .setField(Encrypted_Value__c.Value__c, 'mqKfRqLRpDDzMXa0JGFPqyb4xZxY+lPAdhXOa8LaroQ=')
            .setField(
                Encrypted_Value__c.Description__c,
                'Encrypted value in EncryptedValuesSelectorTest.'
            )
            .setFakeId()
            .toSObject();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        List<Account> businessAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = businessRecordTypeId,
                TaxID__c = '167790902'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = businessRecordTypeId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccounts accountInstance = Accounts.newInstance(businessAccounts);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IEncryptedValuesSelector encyrptedSelectorMock = (IEncryptedValuesSelector) mocks.mock(
            IEncryptedValuesSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectById(
                    new Set<Id>{ businessAccounts[0].Id, businessAccounts[1].Id }
                )
            )
            .thenReturn(businessAccounts);
        mocks.when(encyrptedSelectorMock.sObjectType()).thenReturn(Encrypted_Value__c.SObjectType);
        mocks.when(encyrptedSelectorMock.selectByName(encryptedValueRecord.Name))
            .thenReturn(new List<Encrypted_Value__c>{ encryptedValueRecord });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(encyrptedSelectorMock);
        Test.startTest();
        accountInstance.initiateTaxIdEncryption(businessAccounts);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        //Assert
        System.assertNotEquals(
            businessAccounts[0].Encrypted_Tax_Id__c,
            null,
            'Encrypted Tax Id id null'
        );
        System.assertEquals(
            businessAccounts[1].Encrypted_Tax_Id__c,
            null,
            'Encrypted Tax Id id null not null'
        );
    }

    /**
     * @description To test when store Account is updated for PDOx fields
     * update the Parent Work Order
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPDOXUpdateOnStoreThenInitaiteParentWorkOrderUpdate() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account mockAccount = new Account(
            Id = storeAccountId,
            parentId = parentAccountId,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            Name = ACCOUNT_NAME_STORE,
            Tablet_Delivery_Method__c = TABLET_DELIVERY_METHOD_DROP_SHIP
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IParentWorkOrderSyncService parentWorkOrderSyncServiceMock = (IParentWorkOrderSyncService) mocks.mock(
            IParentWorkOrderSyncService.class
        );
        Application.SERVICE.setMock(
            IParentWorkOrderSyncService.class,
            parentWorkOrderSyncServiceMock
        );
        Accounts.newInstance(new List<Account>{ mockAccount })
            .updateStoreLevelPDOxIndicatorOnParentWorkOrder();
        ((IParentWorkOrderSyncService) mocks.verify(parentWorkOrderSyncServiceMock, 1))
            .updateStoreLevelPDOxIndicatorOnParentWorkOrder(new Set<Id>{ storeAccountId });
    }

    /**
     * @description To test when Corporate Account Id field is updated on Franchise Account when a new store is added.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMethodCalledThenUpdateCorporateAccountOnFranchise() {
        Id accStoreRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id accCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id franchiseAccountId1 = Fake.generateId(Account.class);
        Id franchiseAccountId2 = Fake.generateId(Account.class);
        Id corporateAccountId = Fake.generateId(Account.class);

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                Franchise_Parent__c = franchiseAccountId1,
                ParentId = corporateAccountId,
                RecordTypeId = accStoreRecordType
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                Franchise_Parent__c = franchiseAccountId2,
                ParentId = corporateAccountId,
                RecordTypeId = accStoreRecordType
            )
        };

        List<Account> franchiseAccountsAfterUpdate = new List<Account>{
            new Account(
                Id = franchiseAccountId1,
                Total_Number_Of_Stores__c = 1,
                Name = 'Test franchise 1',
                Type = 'Franchisee',
                RecordTypeId = accCorporateRecordType,
                Corporate_Account_Ids__c = null
            ),
            new Account(
                Id = franchiseAccountId2,
                Total_Number_Of_Stores__c = 1,
                Name = 'Test franchise 2',
                Type = 'Franchisee',
                RecordTypeId = accCorporateRecordType,
                Corporate_Account_Ids__c = null
            )
        };

        Set<Id> accountIds = new Map<Id, SObject>(franchiseAccountsAfterUpdate).keySet();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.getCorporateAccountIdsByFranchiseAccount(accountIds))
            .thenReturn(storeAccounts);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        Accounts.newInstance(franchiseAccountsAfterUpdate).updateCorporateAccountOnFranchise();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Account.Corporate_Account_Ids__c => corporateAccountId
                        },
                        new Map<SObjectField, Object>{
                            Account.Corporate_Account_Ids__c => corporateAccountId
                        }
                    }
                )
            );
    }

    /**
     * @description To test if the Business Vertical Service class called when populateBVIDonStoreAccounts method
     * is called.
     * @JIRA# LEM-11073
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPopulateBVIDonStoreAccountsMethodCalledThenServiceClassCalled() {
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Business_Vertical__c, businessVertical.Id)
            .setFakeId()
            .toSObject();

        List<Account> storeAccounts = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessVerticalsService mockBusinessVerticalService = (IBusinessVerticalsService) mocks.mock(
            IBusinessVerticalsService.class
        );
        Application.Service.setMock(IBusinessVerticalsService.class, mockBusinessVerticalService);

        Accounts.newInstance(storeAccounts).populateBVIDonStoreAccounts();
        ((IBusinessVerticalsService) mocks.verify(mockBusinessVerticalService, 1))
            .populateBusinessVerticalDetails(storeAccounts);
    }

    /**
     * @description To test if error is thrown when Business Vertical on Store Account does not match with associated
     * Xref's Biz Ref's Business Vertical.
     * is called.
     * @JIRA# LEM-11073
     */
    @isTest
    private static void testWhenMismatchBetweenBizVerticalOnAccountAndBizRefThenErrorThrown() {
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();
        Business_Vertical__c businessVerticalMismatched = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessRef = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Id, businessReferenceId1)
            .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_ID_SOURCE_DRIVE_DB)
            .setField(Business_Reference__c.Business_Vertical__c, businessVertical.Id)
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Business_Vertical__c, businessVerticalMismatched.Id)
            .setFakeId()
            .toSObject();

        Xref__c xrefRec = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Account_Record_Type__c, XREF_ACCOUNT_RECORD_TYPE_STORE)
            .setField(Xref__c.Business_Reference__c, businessRef.Id)
            .setField(Xref__c.Integration_Status__c, STATUS_READY_FOR_INTEGRATION)
            .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_DRIVE_DB)
            .setField(Xref__c.Xref_Status__c, XREF_ACTIVE_STATUS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccount.Id)
            .setParent(
                'Business_Reference__r',
                new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.Business_Vertical__c, businessVertical.Id)
                    .setField(Business_Reference__c.Id, businessReferenceId1)
            )
            .setFakeId()
            .toSObject();

        List<Account> storeAccounts = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Xref__c>{ xrefRec });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Accounts.newInstance(storeAccounts).checkForMatchingBusinessReferenceRecords();
        System.assertEquals(1, ApexPages.getMessages().size(), UNEXPECTED_ERROR);
    }
    /**
     * @description To test if error is thrown error when Store Account Accessibilities field format did not match
     * @JIRA# LEM-12908.
     */
    @isTest
    private static void testWhenAccountAccessibilitiesInsertUpdateThenCheckFieldFormat() {
        Id account1Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account2Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account3Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account4Id = fflib_IDGenerator.generate(Account.SObjectType);
        Id account5Id = fflib_IDGenerator.generate(Account.SObjectType);
        String errMessage = System.Label.Seattle_Accessibilities_Validation_Message;
        String errMessageNonSeattle = System.Label.Non_Seattle_Accessibilities_Validation_Message;
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = account1Id,
                Name = 'Test Account 0',
                BillingPostalCode = '98170',
                Accessibilities__c = ''
            ),
            new Account(
                Id = account1Id,
                Name = 'Test Account 1',
                BillingPostalCode = '98170',
                Accessibilities__c = null
            ),
            new Account(
                Id = account2Id,
                Name = 'Test Account 2',
                BillingPostalCode = '98170',
                Accessibilities__c = 'not provided'
            ),
            new Account(
                Id = account3Id,
                Name = 'Test Account 3',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities":{"needToClimb":null,"hasElevatorsOrRamps":null}}'
            ),
            new Account(
                Id = account4Id,
                Name = 'Test Account 4',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities":{"needToClimb":TRUE,"hasElevatorsOrRamps":null}}'
            ),
            new Account(
                Id = account4Id,
                Name = 'Test Account 5',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities":{"needToClimb":null,"hasElevatorsOrRamps":null}}'
            ),
            new Account(
                Id = account4Id,
                Name = 'Test Account 6',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities":{"needToClimb":true,"hasElevatorsOrRamps":false}}'
            ),
            new Account(
                Id = account5Id,
                Name = 'Test Account 7',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities  ":{"needToClimb":"Testing1","hasElevatorsOrRamps":"Testing1"}}'
            ),
            new Account(
                Id = account5Id,
                Name = 'Test Account 8',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities":{"needToClimb":"","hasElevatorsOrRamps":TRUE}}'
            ),
            new Account(
                Id = account4Id,
                Name = 'Test Account 9',
                BillingPostalCode = '98165',
                Accessibilities__c = '{"accessibilities":{"hasElevatorsOrRampsFail":true,"hasElevatorsOrRampsFail":TRUE}}'
            ),
            new Account(
                Id = account4Id,
                Name = 'Test Account 9',
                BillingPostalCode = '848758',
                Accessibilities__c = '{"accessibilities":{"hasElevatorsOrRampsFail":true,"hasElevatorsOrRampsFail":TRUE}}'
            )
        };
        Accounts.newInstance(newAccounts).validateAccessibilities(newAccounts);
        System.assertEquals('', newAccounts[0].Accessibilities__c, '');
        System.assertEquals(null, newAccounts[1].Accessibilities__c, '');
        System.assertEquals('not provided', newAccounts[2].Accessibilities__c, '');
        System.assertEquals(
            '{"accessibilities":{"needToClimb":null,"hasElevatorsOrRamps":null}}',
            newAccounts[3].Accessibilities__c,
            errMessage
        );
        System.assertEquals(
            '{"accessibilities":{"needToClimb":true,"hasElevatorsOrRamps":null}}',
            newAccounts[4].Accessibilities__c,
            errMessage
        );
        System.assertEquals(
            '{"accessibilities":{"needToClimb":null,"hasElevatorsOrRamps":null}}',
            newAccounts[5].Accessibilities__c,
            errMessage
        );
        System.assertEquals(
            '{"accessibilities":{"needToClimb":true,"hasElevatorsOrRamps":false}}',
            newAccounts[6].Accessibilities__c,
            ''
        );
        System.assertEquals(
            '{"accessibilities  ":{"needToClimb":"Testing1","hasElevatorsOrRamps":"Testing1"}}',
            newAccounts[7].Accessibilities__c,
            errMessage
        );
        System.assertEquals(
            '{"accessibilities":{"needToClimb":"","hasElevatorsOrRamps":true}}',
            newAccounts[8].Accessibilities__c,
            errMessage
        );
        System.assertEquals(
            '{"accessibilities":{"hasElevatorsOrRampsFail":true,"hasElevatorsOrRampsFail":true}}',
            newAccounts[9].Accessibilities__c,
            ''
        );
        System.assertEquals(
            '{"accessibilities":{"hasElevatorsOrRampsFail":true,"hasElevatorsOrRampsFail":true}}',
            newAccounts[9].Accessibilities__c,
            errMessageNonSeattle
        );
    }

    /**
     * @description To test Last Updated By Mint stamping on Parent Work Order when stampLastUpdatedByMintOnParentWorkOrder
     * method is called.
     * @JIRA# LEM-12654
     */
    @isTest
    private static void testWhenLastUpdatedByMintOnParentWorkOrderThenStamp() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account mockAccount = new Account(
            Id = storeAccountId,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            Name = ACCOUNT_NAME_STORE,
            Tablet_Delivery_Method__c = TABLET_DELIVERY_METHOD_DROP_SHIP
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IParentWorkOrderSyncService parentWorkOrderSyncServiceMock = (IParentWorkOrderSyncService) mocks.mock(
            IParentWorkOrderSyncService.class
        );
        Application.SERVICE.setMock(
            IParentWorkOrderSyncService.class,
            parentWorkOrderSyncServiceMock
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = workOrderId,
            AccountId = storeAccountId,
            ParentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType)
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                workOrdersSelectorMock.selectWorkOrdersWithParentWorkOrderIdByAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<WorkOrder>{ mockWorkOrder });
        mocks.stopStubbing();

        Accounts.newInstance(new List<Account>{ mockAccount })
            .stampLastUpdatedByMintOnParentWorkOrder();

        System.assertNotEquals(
            true,
            mockWorkOrder.Last_Updated_By_Mint__c != null,
            'Last Updated By Mint is not stamped'
        );
    }

    /**
     * @description populateOwnerOnFranchiseAccount
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPopulateOwnerOnFranchiseAccountIsCalledThenPopulateOwner() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id businessOwner = fflib_IDGenerator.generate(User.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.TaxID__c, ACCOUNT_TAXID)
            .setField(Account.OwnerId, businessOwner)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Franchise_Parent__c, parentAccount.Id)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        Accounts.newInstance(childAccounts).populateOwnerOnFranchiseAccount();
    }

    /**
     * @description To test association of Brand for store Accounts with 'SMB' parent Account.
     * @JIRA# LEM-13447
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountHasSMBParentThenPopulateBrandOnStoreAccount() {
        Id brandId = Fake.generateId(Brand__c.class);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = Fake.generateId(Account.class);
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setChildren(
                'Brand_Associations__r',
                new List<Fake>{
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Business_Account_Name__c, parentAccountId)
                        .setField(Brand_Association__c.Brand_Name__c, brandId)
                        .setParent(
                            'Business_Account_Name__r',
                            new Fake(Account.class).setField(Account.Id, parentAccountId)
                        )
                }
            )
            .toSObject();
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
                    .setField(Account.Id, parentAccount.Id)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                acountsSelectorMock.getAccountsWithBrandAssociationsbyAccountIds(
                    new Set<Id>{ parentAccountId }
                )
            )
            .thenReturn(new List<Account>{ parentAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(acountsSelectorMock);

        Accounts.newInstance(new List<Account>{ storeAccount }).associateBrandToStoreAccounts();
        //Assert
        System.assertEquals(brandId, storeAccount.Brand__c, ASSERT_MESSAGE_BRAND_ASSOCIATION_ERROR);
    }

    /**
     * @description To test association of Brand for store Accounts with 'Enterprise' parent Account.
     * @JIRA# LEM-13447
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountHasEnterpriseParentThenPopulateBrandOnStoreAccount() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = Fake.generateId(Account.class);
        Id storeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .toSObject();
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeAccountRecordType)
            .setField(Account.ParentId, parentAccount.Id)
            .setFakeId()
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
                    .setField(Account.Id, parentAccount.Id)
            )
            .toSObject();
        Accounts.newInstance(new List<Account>{ storeAccount }).associateBrandToStoreAccounts();
        //Assert
        System.assertEquals(
            null,
            storeAccount.Brand__c,
            ASSERT_MESSAGE_BRAND_ASSOCIATION_NULL_ERROR
        );
    }
    /**
     * @description To test ROE fields updated by Account Owner or Account Owner's Manager.
     * @JIRA# LEM-14107
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenROEFieldsChangedByOwnerOrOwnersManager() {
        Id currentUserID = UserInfo.getUserID();
        Id currentUserProfileID = UserInfo.getProfileId();
        Id userID1 = fake.generateId(User.class);

        User managerUser = new User(
            Alias = TEST_USER_ALIAS,
            Email = TEST_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = currentUserProfileID,
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = TEST_USER_NAME,
            isActive = true
        );
        User mockUser1 = new User(
            Alias = TEST_USER_ALIAS,
            Email = TEST_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = currentUserProfileID,
            TimeZoneSidKey = USER_TIMEZONE,
            ManagerID = managerUser.id,
            UserName = TEST_USER_NAME
        );
        User mockUser2 = new User(
            Id = userID1,
            Alias = TEST_USER_ALIAS,
            Email = TEST_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = currentUserProfileID,
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = TEST_USER_NAME,
            ManagerID = managerUser.id
        );

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();

        Id testAccountId1 = Fake.generateId(Account.class);
        Id testAccountId2 = Fake.generateId(Account.class);

        Account newAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Managed_Status__c, MANAGED)
            .setField(Account.Mx_Contact_Status__c, MX_CONTACT_STATUS2)
            .setField(Account.OwnerId, currentUserID)
            .toSObject();

        Account newAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId2)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Managed_Status__c, MANAGED)
            .setField(Account.Mx_Contact_Status__c, MX_CONTACT_STATUS2)
            .setField(Account.OwnerId, userID1)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUsersSelector selectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(selectorMock.selectUsersById(new Set<Id>{ currentUserID, userID1 }))
            .thenReturn(new List<User>{ mockUser1, mockUser2 });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        System.runAs(mockUser1) {
            try {
                List<Account> newAccounts = new List<Account>{ newAccount1, newAccount2 };
                Accounts.newInstance(newAccounts).validateROEFieldsChangedByOwnerOrOwnersManager();
                System.assertEquals(
                    MX_CONTACT_STATUS2,
                    newAccount1.Mx_Contact_Status__c,
                    ASSERTION_FAILED_ROE
                );
            } catch (Exception e) {
                system.assertEquals(ROE_NO_ACCESS_ERROR, e.getMessage(), ASSERTION_FAILED_ROE);
            }
        }
    }

    /**
     * @description It validates the defaulting of Deck Rank as King of Spades
     * if no value is selected when an Account with Enterprise segment is inserted.
     * @JIRA# LEM-14098
     */
    @isTest
    private static void testWhenEnterpriseAccountInsertedThenDefaultDeckRank() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .toSObject();
        Test.startTest();
        Accounts.newInstance(new List<Account>{ parentAccount })
            .initiateDefaultOfDeckRankForEnterpriseAndMidmarket(new List<Account>{ parentAccount });
        Test.stopTest();
        //Assert
        System.assertEquals(
            KING_OF_SPADES_DECK_RANK,
            parentAccount.Deck_Rank__c,
            ASSERT_MESSAGE_DECK_RANK_NOT_MATCHING
        );
    }

    /**
     * @description It validates the defaulting of Deck Rank as King of Spades
     * if no value is selected when an Account with SMB segment is inserted.
     * @JIRA# LEM-14098
     */
    @isTest
    private static void testWhenSMBAccountInsertedThenDeckRankNotDefaulted() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();
        Test.startTest();
        Accounts.newInstance(new List<Account>{ parentAccount })
            .initiateDefaultOfDeckRankForEnterpriseAndMidmarket(new List<Account>{ parentAccount });
        Test.stopTest();
        //Assert
        System.assertNotEquals(
            KING_OF_SPADES_DECK_RANK,
            parentAccount.Deck_Rank__c,
            ASSERT_MESSAGE_DECK_RANK_NOT_MATCHING
        );
    }
    /**
     * @description To test update Segment value on Account when Creation Source is Mx Portal
     * and Unlitmate Parent Account is blank.
     */
    @isTest
    private static void testWhenSMBAccountInsertedThenPopulateSegmentPass() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Ultimate_Parent_Account__c, null)
            .setField(Account.Creation_Source__c, MX_PORTAL)
            .setFakeId()
            .toSObject();

        List<Account> newAccounts = new List<Account>{ businessAccount };

        Test.startTest();
        Accounts.newInstance(newAccounts).populateSegmentOnAccount();
        Test.stopTest();

        System.assertEquals(ACCOUNT_SEGMENT_SMB, businessAccount.Segment__c, ASSERTION_FAILED);
    }
    /**
     * @description To test no update of Segment value on Account when Creation Source is not Mx Portal
     * and Unlitmate Parent Account is blank.
     */
    @isTest
    private static void testWhenSMBAccountInsertedThenPopulateSegmentFail() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Ultimate_Parent_Account__c, null)
            .setField(Account.Creation_Source__c, MANUAL)
            .setFakeId()
            .toSObject();
        List<Account> newAccounts = new List<Account>{ businessAccount };

        Test.startTest();
        Accounts.newInstance(newAccounts).populateSegmentOnAccount();
        Test.stopTest();

        System.assertEquals(null, businessAccount.Segment__c, ASSERTION_FAILED);
    }

    /**
     * @description To validate that "Duplicate Status" is not updated
     * systematically for SMB Accounts.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSMBAccountInsertedThenDuplicateStatusUpdateNotifierEventsNotInvoked() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account smbAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'SMB Account')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        List<String> payloads = new List<String>{};
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);

        mocks.when(mockStaticConfigurations.getInstanceValue(DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE,
                    Configuration_Value__c = String.valueOf(200)
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{},
                    Integer.valueOf(200)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        //Act
        Test.startTest();
        Accounts.newInstance(new List<Account>{ smbAccount }).publishDuplicateStatusNotifierEvent();
        Test.stopTest();
        //Assert
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 0))
            .publishBulkEvents((Map<String, List<String>>) fflib_Match.anyObject());
    }

    /**
     * @description To validate that "Duplicate Status" is updated
     * systematically for ENT Accounts.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenENTAccountInsertedThenDuplicateStatusUpdateNotifierEventsInvoked() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account entAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'ENT Account')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        List<String> payloads = new List<String>{};
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);

        mocks.when(mockStaticConfigurations.getInstanceValue(DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE,
                    Configuration_Value__c = String.valueOf(200)
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ entAccount.Id },
                    Integer.valueOf(200)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        //Act
        Test.startTest();
        Accounts.newInstance(new List<Account>{ entAccount }).publishDuplicateStatusNotifierEvent();
        Test.stopTest();
        //Assert
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 1))
            .publishBulkEvents((Map<String, List<String>>) fflib_Match.anyObject());
    }

    /**
     * @description To test the update of Data Verification Status
     */
    @isTest
    private static void testWhenBusinessAccountUpdatedThenDataVerificationStatusChanged() {
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, BILLING_COUNTRY_CODE_AU)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Creation_Source__c, MANUAL)
            .setField(Account.Address_Verification_Status__c, VERIFIED)
            .setFakeId()
            .toSObject();
        Accounts.newInstance(new List<Account>{ account }).updateDataVerificationStatus();
        System.assertEquals(
            VERIFIED,
            account.Data_Verification_Status__c,
            ASSERT_MESSAGE_DATA_VERIFICATION_STATUS_NOT_MATCHING
        );
    }

    /**
     * @description To test the update of Data Verification Status for Enterprise account.
     */
    @isTest
    private static void testWhenEnterpriseBusinessAccountUpdatedThenDataVerificationStatusNotChanged() {
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.BillingCountryCode, 'SK')
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setField(Account.Creation_Source__c, MANUAL)
            .setField(Account.Address_Verification_Status__c, VERIFIED)
            .setField(Account.Data_Verification_Status__c, UNVERIFIED)
            .setFakeId()
            .toSObject();
        Accounts.newInstance(new List<Account>{ account }).updateDataVerificationStatus();
        System.assertEquals(
            UNVERIFIED,
            account.Data_Verification_Status__c,
            ASSERT_MESSAGE_DATA_VERIFICATION_STATUS_NOT_MATCHING
        );
    }

    /**
     * @description To test if data verification status field is getting populated if data is correct
     * @JIRA# LEM-15901
     */
    @isTest
    private static void testWhenAccountIsGettingInsertWithAllDataThenCheckIfDataVerificationStatusIsVerified() {
        Id franchiseAccountId1 = Fake.generateId(Account.class);
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Brand__c brandRec = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Type, 'Corporate')
            .setField(Account.Brand__c, brandRec.Id)
            .setField(Account.BillingPostalCode, '11223')
            .setField(Account.BillingCountry, 'United States')
            .setField(Account.BillingStreet, '1987 East 9th Street')
            .setField(Account.BillingState, 'New York')
            .setField(Account.BillingCity, 'Brooklyn')
            .setFakeId()
            .toSObject();

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Type, 'Franchisee')
            .setField(Account.DoorDash_Legal_Entity__c, 'DoorDash G&C, LLC')
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Legal_Business_Name__c, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Commission_Calculation_Methodology__c, 'DoorDash Platform Price')
            .setField(Account.Franchise_Parent__c, franchiseAccountId1)
            .setField(Account.Primary_Vertical__c, 'Grocery')
            .setField(Account.BillingCountry, 'United States')
            .setField(Account.Control_of_Price__c, ACCOUNT_CONTROL_OF_PRICE)
            .setFakeId()
            .toSObject();

        List<Account> accountsList = new List<Account>{ storeAccount, businessAccount };
        Accounts.newInstance(accountsList).populateDataVerificationStatus();
        System.assertEquals(VERIFIED, accountsList[0].Data_Verification_Status__c, 'Data Verified');
        System.assertEquals(VERIFIED, accountsList[1].Data_Verification_Status__c, 'Data Verified');
    }

    /**
     * @description Test to process accounts post lead conversion.
     */
    @isTest
    private static void testWhenLeadConvertedThenProcessAccounts() {
        Id accountId = Fake.generateId(Account.class);
        Id leadId = Fake.generateId(Lead.class);
        Id leadId1 = Fake.generateId(Lead.class);
        Account[] newAccounts = new List<Account>{
            new Account(Id = accountId, Name = ACCOUNT_NAME_BUSINESS, Converted_Lead_Id__c = leadId)
        };

        Account[] oldAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = ACCOUNT_NAME_BUSINESS,
                Converted_Lead_Id__c = leadId1
            )
        };
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>();
        oldAccountsMap.put(oldAccounts[0].Id, oldAccounts[0]);
        Test.startTest();
        Accounts.newInstance(newAccounts).processAccountsOnLeadConversion(oldAccountsMap);
        Test.stopTest();
        System.assertEquals(
            leadId,
            newAccounts[0].Converted_Lead_Id__c,
            'LeadId should be populated'
        );
    }

    /**
     * @description LEM-17671: To validate that "Duplicate Status" is updated
     * systematically for SMB Nintex Accounts.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSMBNintexAccountInsertedThenDuplicateStatusUpdateNotifierEventsInvoked() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account entAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'SMB Account')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        List<String> payloads = new List<String>{};
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);

        mocks.when(mockStaticConfigurations.getInstanceValue(DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = DUPLICATE_CHECK_PAYLOAD_CHUNK_SIZE,
                    Configuration_Value__c = String.valueOf(200)
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ entAccount.Id },
                    Integer.valueOf(200)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        //Act
        Test.startTest();
        Accounts.newInstance(new List<Account>{ entAccount }).publishDuplicateStatusNotifierEvent();
        Test.stopTest();
        //Assert
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 0))
            .publishBulkEvents((Map<String, List<String>>) fflib_Match.anyObject());
    }

    /**
     * @description It is used to test whether the defined fields on the child (Business/Store)
     * accounts are copied from the associated parent account.
     */
    @isTest
    private static void testWhenChildAccountInsertedThenLegalBusinessNamePopulatedByFranchiseParent() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Legal_Business_Name__c, 'Test Legal Business Name 1')
            .setFakeId()
            .toSObject();
        Account franchiseParentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Franchise Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Legal_Business_Name__c, 'Test Legal Business Name 2')
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Franchise_Parent__c, franchiseParentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Segment__c, 'SMB')
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        List<Account> franchiseParentAccounts = new List<Account>{ franchiseParentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.when(selectorMock.selectById(new Set<Id>{ franchiseParentAccount.Id }))
            .thenReturn(franchiseParentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Test.startTest();
        Accounts.newInstance(childAccounts).populateFieldsOnChildAccountsByParent();
        Test.stopTest();
        //Assert
        System.assertEquals(
            childAccount.Segment__c,
            ACCOUNT_SEGMENT_SMB,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
        System.assertEquals(
            childAccount.Legal_Business_Name__c,
            'Test Legal Business Name 2',
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
    }
    /**
     * @description To test calculate total number of stores
     */
    @isTest
    private static void testWhenAccountStoreCountIsUpdatedThenCalculateTotalNoOfStores() {
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = ACCOUNT_NAME_BUSINESS,
                Corporate_Owned_Store_Count__c = 1,
                Franchise_Owned_Store_Count__c = 3
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = ACCOUNT_NAME_BUSINESS,
                Corporate_Owned_Store_Count__c = 2,
                Franchise_Owned_Store_Count__c = 3,
                Total_Number_Of_Stores__c = 6
            )
        };
        Accounts.newInstance(newAccounts).calculateTotalNumberOfStores();

        System.assertEquals(
            4,
            newAccounts[0].Total_Number_Of_Stores__c,
            ASSERT_MESSAGE_TOTAL_NUMBER_OF_STORES_ERROR
        );
        System.assertEquals(
            5,
            newAccounts[1].Total_Number_Of_Stores__c,
            ASSERT_MESSAGE_TOTAL_NUMBER_OF_STORES_ERROR
        );
    }

    /**
     * @description test case when activation status is updated, lifecycle status should be updated correctly.
     */
    @IsTest
    private static void testWhenActivationStatusUpdatedThenLifecycleStatusUpdated() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Account activeAccount = (Account) new Fake(Account.class)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Activation_Status__c, STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setField(Account.Name, ACCOUNT_NAME)
            .setFakeId()
            .toSObject();
        Account deactivatedAccount = (Account) new Fake(Account.class)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Activation_Status__c, STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVATED)
            .setField(Account.Name, TEST_ACCOUNT_NAME)
            .setFakeId()
            .toSObject();
        Account inactiveAccount = (Account) new Fake(Account.class)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Activation_Status__c, STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setFakeId()
            .toSObject();
        List<Account> testAccounts = new List<Account>{
            activeAccount,
            deactivatedAccount,
            inactiveAccount
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ activeAccount.Id, deactivatedAccount.Id, inactiveAccount.Id }
                )
            )
            .thenReturn(testAccounts);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Test.startTest();
        Accounts.newInstance(testAccounts).setAccountLifecycleStatusOnSMBStoreAccounts();
        Test.stopTest();
        System.assertEquals(
            ACCOUNT_LIFECYCLE_STATUS_NURTURE,
            activeAccount.Account_Lifecycle_Status__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
        System.assertEquals(
            ACCOUNT_LIFECYCLE_STATUS_CHURNED,
            deactivatedAccount.Account_Lifecycle_Status__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
        System.assertEquals(
            ACCOUNT_LIFECYCLE_STATUS_UNVETTED,
            inactiveAccount.Account_Lifecycle_Status__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
    }

    /**
     * @description test case when Account segment isn't SMB , lifecycle status shouldn't be updated.
     */
    @IsTest
    private static void testWhenNonSMBAccountsProvidedThenLifecycleStatusUnchanged() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();
        Account enterpriseAccount = (Account) new Fake(Account.class)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setField(Account.Activation_Status__c, STORE_ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS_NURTURE)
            .setField(Account.Name, TEST_ACCOUNT_NAME)
            .setFakeId()
            .toSObject();
        Account account = (Account) new Fake(Account.class)
            .setField(Account.RecordTypeId, fflib_IDGenerator.generate(Schema.Account.SObjectType))
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setField(Account.Activation_Status__c, STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS_UNVETTED)
            .setField(Account.Name, ACCOUNT_NAME_STORE)
            .setFakeId()
            .toSObject();
        List<Account> testAccounts = new List<Account>{ enterpriseAccount, account };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ enterpriseAccount.Id, account.Id }))
            .thenReturn(testAccounts);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Test.startTest();
        Accounts.newInstance(testAccounts).setAccountLifecycleStatusOnSMBStoreAccounts();
        Test.stopTest();
        System.assertEquals(
            ACCOUNT_LIFECYCLE_STATUS_NURTURE,
            enterpriseAccount.Account_Lifecycle_Status__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
        System.assertEquals(
            ACCOUNT_LIFECYCLE_STATUS_UNVETTED,
            account.Account_Lifecycle_Status__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
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
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = businessAccountId,
                Name = ACCOUNT_NAME_BUSINESS,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
            ),
            new Account(
                Id = storeAccountId,
                Name = ACCOUNT_NAME_STORE,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID,
                Self_Delivery__c = SELF_DELIVERY_YES,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_DEACTIVATED
            )
        };
        Test.startTest();
        Accounts.newInstance(newAccounts).invokeExperienceFieldUpdateOnStoreAccounts();
        Test.stopTest();
        System.assertEquals(
            null,
            newAccounts[1].Experience__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
    }
    /**
     * @description Test if no 'Experience' field update is invoked for Business Accounts.
     * @JIRA# LEM-25063
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActivationFieldUpdatedThenDoNotInvokeExperienceFieldUpdateOnStoreAccount() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = businessAccountId,
                Name = ACCOUNT_NAME_BUSINESS,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID,
                Activation_Status__c = STORE_ACCOUNT_ACTIVATION_STATUS_INACTIVE
            )
        };
        Test.startTest();
        Accounts.newInstance(newAccounts).invokeExperienceFieldUpdateOnStoreAccounts();
        Test.stopTest();
        System.assertEquals(
            null,
            newAccounts[0].Experience__c,
            ASSERT_MESSAGE_LIFECYCLE_STATUS_ERROR
        );
    }
    /**
     * @description It is used to test Legal Business Name field is not copied from parent when child
     * accounts are created by OI.
     */
    @isTest
    private static void testWhenChildAccountInsertedThroughOIThenDoNotUpdateLegalBusinessNameOnChildFromParent() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id businessOwner = fflib_IDGenerator.generate(User.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.TaxID__c, ACCOUNT_TAXID)
            .setField(Account.OwnerId, businessOwner)
            .setField(Account.Control_of_Price__c, ACCOUNT_CONTROL_OF_PRICE)
            .setField(Account.Legal_Business_Name__c, 'Test Legal Business Name')
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, 'Child')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Legal_Business_Name__c, LEGAL_BUSINESS_NAME)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Mx_Onboarding_Link_Id__c, MX_ONBOARDING_LINK_ID)
            .setFakeId()
            .toSObject();
        List<Account> childAccounts = new List<Account>{ childAccount };
        List<Account> parentAccounts = new List<Account>{ parentAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(parentAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        Test.startTest();
        Accounts.newInstance(childAccounts).populateFieldsOnChildAccountsByParent();
        Test.stopTest();
        System.assertEquals(
            childAccount.Legal_Business_Name__c,
            LEGAL_BUSINESS_NAME,
            ACCOUNT_INVALID_FIELD_POPULATION_ASSERT
        );
    }
}