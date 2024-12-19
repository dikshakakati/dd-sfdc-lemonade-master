/**
 * @author Deloitte
 * @date 02/05/2022
 * @description Test class for XrefsSelector class
 */
@isTest(seeAllData=false)
private class XrefsSelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String AGGREGATE_XREFSCOUNT_FIELD_ALIAS = 'xrefsCount';
    private static final String ASSERT_MISMATCH_FOR_ACCOUNT = 'Unexpected Result: Account id on xref does not match the expected outcome';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_EXTERNAL_ID = 'Unexpected result: External Id does not match';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_LIST_SIZE = 'Unexpected result: There is a mismatch in list size';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Xref__c';
    private static final String BRAND_NAME = 'McDonalds';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final String EXTERNAL_ID = '12345';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String STORE_ID = '2480';
    private static final String POS_INTEGRATION_ID = '1122334455';
    private static final String SUCCESS = 'Success';
    private static final String WAITING_FOR_BUSINESS = 'Waiting for Business';
    static final String MDS = 'MDS';
    static final String FAILURE = 'Failure';
    static final String INTEGRATION_SUCCESS = 'Success';
    static final String PARENT_WORK_ORDER_ID = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    static final String VERTICAL_RX = 'Rx';
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        XrefsSelector xrefInstance = new XrefsSelector();
        Schema.SObjectType typeOfObject = xrefInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = xrefInstance.getSObjectFieldList();
        XrefsSelector.newInstance();
        System.assertEquals(
            Schema.Xref__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Xref__c.Id,
                Xref__c.CurrencyIsoCode,
                Xref__c.Business_GroupID__c,
                Xref__c.BusinessID__c,
                Xref__c.Mint_BusinessPage__c,
                Xref__c.Integration_Status__c,
                Xref__c.Business_Reference__c,
                Xref__c.Salesforce_Account_Name__c,
                Xref__c.External_ID__c,
                Xref__c.External_ID_Source__c,
                Xref__c.Xref_Status__c,
                Xref__c.Account_Record_Type__c,
                Xref__c.Business_Name__c,
                Xref__c.Account_Type__c,
                Xref__c.MINT_Store_Page__c,
                Xref__c.Merchant_Portal__c,
                Xref__c.Createddate,
                Xref__c.COO_Graveyard_Id__c,
                Xref__c.Integration_Message__c,
                Xref__c.Name
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description This test class querying Xrefs when passing an account Ids.
     */
    @isTest
    private static void testWhenSelectAnyBusinessAccountInHierarchyThenReturnXrefsRecords() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account parentAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeBusiness,
            BillingCountry = 'United States',
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert parentAccount;
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = parentAccount.Id,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(External_ID__c = '123', Business_Group_ID__c = '98123'),
            new Business_Reference__c(External_ID__c = '121234', Business_Group_ID__c = '981124')
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = '123'
            ),
            new Xref__c(
                Business_Reference__c = businessReferences[1].Id,
                Salesforce_Account_Name__c = parentAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = '223'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectAllInAccountHierarchy(parentAccount.Id);
        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Business_GroupID__c,
            '98123',
            'The Busniess Id  does not match'
        );
        System.assertEquals(
            xrefRecords[0].BusinessID__c,
            '123',
            'The Business Group Id does not match'
        );
        System.assertEquals(
            xrefRecords[1].Business_GroupID__c,
            '981124',
            'The Busniess Id  does not match'
        );
        System.assertEquals(
            xrefRecords[1].BusinessID__c,
            '121234',
            'The Business Group Id does not match'
        );

        //test for selectXrefByBusinessReferenceExternalId method in XrefsSelectorTest class
        List<Xref__c> xrefRecordsByBusinessExternalIds = xrefsInstance.selectXrefByBusinessReferenceExternalId(
            new List<String>{ '123', '121234' }
        );
        System.assertEquals(
            2,
            xrefRecordsByBusinessExternalIds.size(),
            'Xref list doesnt returned as expected'
        );
        List<Id> accountIds = new List<Id>{ parentAccount.Id, storeAccount.id };
        for (Xref__c xref : xrefRecordsByBusinessExternalIds) {
            System.assert(
                accountIds.contains(xref.Salesforce_Account_Name__c),
                'Account Id is not expected'
            );
        }
    }

    /**
     * @description This test class querying active Xrefs when passing an account Id.
     */
    @isTest
    private static void testWhenSelectActiveXrefThenReturnXrefsRecords() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(External_ID__c = '123', Business_Group_ID__c = '98123'),
            new Business_Reference__c(External_ID__c = '121234', Business_Group_ID__c = '981124')
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = 'Active',
                External_ID__c = '123'
            ),
            new Xref__c(
                Business_Reference__c = businessReferences[1].Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = 'InActive',
                External_ID__c = '223'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectActiveXrefsByAccountId(storeAccount.Id);
        System.assertEquals(1, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Xref_Status__c,
            'Active',
            'The Busniess Id  does not match'
        );
        System.assertEquals(
            xrefRecords[0].BusinessID__c,
            '123',
            'The Business Group Id does not match'
        );
    }

    /**
     * @description This test class querying Xrefs when passing an account Id.
     */
    @isTest
    private static void testWhenSelectAllMatchingBusinessReferenceThenReturnXrefsRecords() {
        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = '12366',
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference1;
        Business_Reference__c businessReference2 = new Business_Reference__c(
            External_ID__c = '12456',
            Business_Group_ID__c = '98124',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference2;
        Business_Reference__c businessReference3 = new Business_Reference__c(
            External_ID__c = '13125',
            Business_Group_ID__c = '980123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference3;

        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = null,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref1'
            ),
            new Xref__c(
                Business_Reference__c = businessReference2.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref2'
            ),
            new Xref__c(
                Business_Reference__c = businessReference3.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref3'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectAllMatchingBusinessReference(
            new Set<Id>{ businessReference1.Id, businessReference2.Id }
        );

        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Business_Reference__c,
            businessReference1.Id,
            'The Business_Reference__c does not match'
        );
        System.assertEquals(
            xrefRecords[1].Business_Reference__c,
            businessReference2.Id,
            'The Business_Reference__c does not match'
        );
        List<Xref__c> xrefRecordsForPlatformEvent = xrefsInstance.selectAllInfoNeededForPlatformEvent(
            new Set<Id>{ xrefs[0].Id }
        );
        System.assertNotEquals(
            xrefRecordsForPlatformEvent[0].CreatedDate,
            null,
            'Created Date should be set'
        );
    }
    /**
     * @description This test class querying Xrefs when passing an Business Reference Id.
     */
    @isTest
    private static void testWhenSelectAllMatchingBusinessReferenceThenReturnXrefsTypeBusinessRecords() {
        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = '12366',
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference1;
        Business_Reference__c businessReference2 = new Business_Reference__c(
            External_ID__c = '12456',
            Business_Group_ID__c = '98124',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference2;
        Business_Reference__c businessReference3 = new Business_Reference__c(
            External_ID__c = '13125',
            Business_Group_ID__c = '980123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference3;

        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeBusiness,
            ParentId = null,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref1'
            ),
            new Xref__c(
                Business_Reference__c = businessReference2.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                External_ID__c = 'xref2'
            ),
            new Xref__c(
                Business_Reference__c = businessReference3.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                External_ID__c = 'xref3'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectAllMatchingBusinessReferenceForDriveDb(
            new Set<Id>{ businessReference1.Id, businessReference2.Id }
        );
        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Business_Reference__c,
            businessReference1.Id,
            'The Business_Reference__c does not match'
        );
        System.assertEquals(
            xrefRecords[1].Business_Reference__c,
            businessReference2.Id,
            'The Business_Reference__c does not match'
        );
    }

    /**
     * @description This test class querying Xrefs when passing an account Id.
     */
    @isTest
    private static void testWhenSalesforceAccountNamesThenReturnXrefsRecords() {
        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = '123112',
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference1;
        Business_Reference__c businessReference2 = new Business_Reference__c(
            External_ID__c = '12402',
            Business_Group_ID__c = '98124',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS
        );
        insert businessReference2;

        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = null,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = businessAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref1',
                Xref_Status__c = XREF_STATUS_ACTIVE
            ),
            new Xref__c(
                Business_Reference__c = businessReference2.Id,
                Salesforce_Account_Name__c = businessAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref2',
                Xref_Status__c = XREF_STATUS_ACTIVE
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectBySalesforceAccountName(
            new Set<Id>{ businessAccount.Id }
        );
        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Business_Reference__c,
            businessReference1.Id,
            'The Business_Reference__c does not match'
        );
        System.assertEquals(
            xrefRecords[1].Business_Reference__c,
            businessReference2.Id,
            'The Business_Reference__c does not match'
        );
    }

    /**
     * @description This test class querying Xrefs when passing an account Id.
     */
    @isTest
    private static void testWhenSalesforceAccountNamesThenReturnActiveXrefsRecords() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = null,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Salesforce_Account_Name__c = businessAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = 'xref1'
            ),
            new Xref__c(
                Salesforce_Account_Name__c = businessAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = 'xref2'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectActiveXrefsBySalesforceAccountName(
            new Set<Id>{ businessAccount.Id }
        );
        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
    }

    /**
     * @description Test class for querying Drive Xrefs based on Salesforce Account Name And Franchise Account.
     */
    @isTest
    private static void testWhenSalesforceAccountNamesThenReturnDriveXrefsRecords() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account franchiseAccount = new Account(
            name = 'Franchise Account',
            RecordtypeId = accRecordTypeBusiness,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert franchiseAccount;

        Account[] storeAccounts = new List<Account>{
            new Account(
                name = 'Store 1',
                RecordtypeId = accRecordTypeStore,
                ParentId = franchiseAccount.Id,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                name = 'Store 2',
                RecordtypeId = accRecordTypeStore,
                ParentId = franchiseAccount.Id,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                Segment__c = ACCOUNT_SEGMENT
            )
        };
        insert storeAccounts;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Salesforce_Account_Name__c = storeAccounts[0].Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = 'xref1'
            ),
            new Xref__c(
                Salesforce_Account_Name__c = storeAccounts[1].Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = 'xref2'
            ),
            new Xref__c(
                Salesforce_Account_Name__c = franchiseAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = 'xref3'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectDriveDbXrefsBySalesforceAccountName(
            new Set<Id>{ storeAccounts[0].Id, storeAccounts[1].Id, franchiseAccount.Id }
        );
        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
    }
    /**
     * @description To test Xrefs are returned by matching the passed search key with the
     * External Id field.
     */
    @isTest
    private static void testWhenSelectBySearchKeyWithMDSCalledThenReturnMatchedXrefs() {
        String searchKey = '123'; // Sub string of Xref's External Id
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = VERTICAL_RX
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectBySearchKey(searchKey);
        System.assertEquals(
            EXTERNAL_ID,
            xrefRecords[0].External_ID__c,
            ASSERT_MESSAGE_MISMATCH_IN_EXTERNAL_ID
        );

        //test for the selectXrefByExternalId method in xrefselector class
        List<Xref__c> xrefRecordsByExternalId = xrefsInstance.selectXrefsByExternalIdsAndPrimaryVertical(
            new List<String>{ EXTERNAL_ID },
            VERTICAL_RX
        );
        System.assertEquals(
            1,
            xrefRecordsByExternalId.size(),
            ASSERT_MESSAGE_MISMATCH_IN_LIST_SIZE
        );
        System.assertEquals(
            businessAccount.Id,
            xrefRecordsByExternalId[0].Salesforce_Account_Name__c,
            ASSERT_MISMATCH_FOR_ACCOUNT
        );

        //test for the selectXrefByExternalIdOnly method in xrefselector class
        List<Xref__c> xrefRecordsByExternalIdOnly = xrefsInstance.selectXrefByExternalIdOnly(
            new List<String>{ EXTERNAL_ID }
        );
        System.assertEquals(
            1,
            xrefRecordsByExternalIdOnly.size(),
            ASSERT_MESSAGE_MISMATCH_IN_LIST_SIZE
        );
        System.assertEquals(
            businessAccount.Id,
            xrefRecordsByExternalId[0].Salesforce_Account_Name__c,
            ASSERT_MISMATCH_FOR_ACCOUNT
        );
    }

    /**
     * @description To test Xrefs are returned by matching the passed search key with the
     * External Id field.
     */
    @isTest
    private static void testWhenSelectBySearchKeyCalledThenReturnMatchedXrefs() {
        String searchKey = '123'; // Sub string of Xref's External Id
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectBySearchKey(searchKey);
        System.assertEquals(
            EXTERNAL_ID,
            xrefRecords[0].External_ID__c,
            ASSERT_MESSAGE_MISMATCH_IN_EXTERNAL_ID
        );

        //test for the selectXrefByExternalId method in xrefselector class
        List<Xref__c> xrefRecordsByExternalId = xrefsInstance.selectXrefByExternalId(
            new List<String>{ EXTERNAL_ID }
        );
        System.assertEquals(1, xrefRecordsByExternalId.size(), 'Xref List size does not match');
        System.assertEquals(
            businessAccount.Id,
            xrefRecordsByExternalId[0].Salesforce_Account_Name__c,
            'Accounts doesnt match'
        );

        //test for the selectXrefByExternalIdOnly method in xrefselector class
        List<Xref__c> xrefRecordsByExternalIdOnly = xrefsInstance.selectXrefByExternalIdOnly(
            new List<String>{ EXTERNAL_ID }
        );
        System.assertEquals(1, xrefRecordsByExternalIdOnly.size(), 'Xref List size does not match');
        System.assertEquals(
            businessAccount.Id,
            xrefRecordsByExternalId[0].Salesforce_Account_Name__c,
            'Accounts doesnt match'
        );
    }

    /**
     * @description To test Xrefs are returned by matching the passed search key with the
     * External Id field.
     */
    @isTest
    private static void testWhenSearchKeyNotMatchedWithExternalIdThenNoXrefsReturned() {
        String searchKey = '100';
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectBySearchKey(searchKey);
        System.assertEquals(0, xrefRecords.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description To test Xrefs are returned by matching the passed store Ids
     */
    @isTest
    private static void testWhenSelectXrefsByStoreIdsThenReturnActiveXrefRecords() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            POS_Integration_ID__c = POS_INTEGRATION_ID,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX
        );
        insert storeAccount;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(External_ID__c = '123', Business_Group_ID__c = '98123'),
            new Business_Reference__c(External_ID__c = '121234', Business_Group_ID__c = '981124')
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = STORE_ID,
                Unified_Store_ID__c = STORE_ID,
                Xref_Status__c = XREF_STATUS_ACTIVE
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectXrefsByStoreIds(
            new Set<String>{ STORE_ID }
        );
        System.assertEquals(1, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Salesforce_Account_Name__r.POS_Integration_ID__c,
            POS_INTEGRATION_ID,
            'Integration Id Does not match'
        );
    }

    @isTest
    static void testWhenSerachingByCooProcessThenReturnMatchingXrefs() {
        Map<String, Schema.RecordTypeInfo> accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();

        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = accountRecordTypes.get('Business').getRecordTypeId(),
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );

        insert businessAccount;

        Account storeAccount = new Account(
            name = 'Test Store',
            RecordtypeId = accountRecordTypes.get('Store').getRecordTypeId(),
            ParentId = businessAccount.Id,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );

        Account otherBusinessAccount = new Account(
            name = 'Test - Other Business',
            RecordtypeId = accountRecordTypes.get('Business').getRecordTypeId(),
            ParentId = businessAccount.Id,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );

        insert new List<Account>{ storeAccount, otherBusinessAccount };

        Xref__c xref1 = new Xref__c(
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID,
            Coo_process__c = 'Process via Batch Mode'
        );
        Xref__c xref2 = new Xref__c(
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID + '2',
            Coo_process__c = 'Process via Async Mode'
        );
        Xref__c xref3 = new Xref__c(
            Salesforce_Account_Name__c = otherBusinessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID + '3',
            Coo_process__c = 'Process via Async Mode'
        );

        insert new List<Xref__c>{ xref1, xref2, xref3 };

        Test.startTest();
        Map<Id, Xref__c> resultXrefs = new Map<Id, Xref__c>(
            XrefsSelector.newInstance()
                .selectXrefsByIdAndCooProcess(
                    new Set<Id>{ xref1.Id, xref2.Id, xref3.Id },
                    new Set<String>{ 'Process via Async Mode' }
                )
        );
        Database.QueryLocator queryLocator = XrefsSelector.newInstance().selectXrefsByCooProcess();
        List<Xref__c> xrefListForBatch = Database.query(queryLocator.getQuery());
        Map<Id, Xref__c> resultXrefsForBatchMode = new Map<Id, Xref__c>(xrefListForBatch);
        Test.stopTest();
        System.assertEquals(
            2,
            resultXrefs.size(),
            '2 Xrefs are expected to be returned for the given criteria'
        );
        System.assert(!resultXrefs.containsKey(xref1.Id), 'This Xref shoudl not be returned');
        System.assert(resultXrefs.containsKey(xref2.Id), 'This Xref should be returned');
        System.assert(resultXrefs.containsKey(xref3.Id), 'This Xref should be returned');
        System.assertEquals(
            1,
            resultXrefsForBatchMode.size(),
            'Only 1 Xref should be retuned in batch mode query'
        );
        System.assert(
            resultXrefsForBatchMode.containsKey(xref1.Id),
            'This Xref should  be returned'
        );
    }
    /**
     * @description To test Xrefs are returned by matching the passed search key with the
     * store AccountIds.
     */
    @isTest
    private static void testWhenStoreIdsArePassedThenReturnXrefs() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account parentAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeBusiness,
            BillingCountry = 'United States',
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert parentAccount;
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = parentAccount.Id,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Account storeAccount2 = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = parentAccount.Id,
            BillingStreet = '321 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount2;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(External_ID__c = '123', Business_Group_ID__c = '98123'),
            new Business_Reference__c(External_ID__c = '121234', Business_Group_ID__c = '981124')
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = '123',
                Xref_Status__c = 'Active'
            ),
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccount2.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = '123',
                Xref_Status__c = 'Active'
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectActiveMDSXrefsByStoreIds(
            new Set<Id>{ storeAccount.Id, storeAccount2.Id }
        );
        System.assertEquals(2, xrefRecords.size(), 'The list size does not match');
    }

    /**
     * @description This test class querying Xrefs when passing an account Id.
     */
    @isTest
    private static void testWhenSelectActiveFailedXrefsBySalesforceAccountNameThenReturnXrefsRecords() {
        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = '12366',
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference1;
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = null,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref1',
                Xref_Status__c = XREF_STATUS_ACTIVE
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectActiveFailedXrefsBySalesforceAccountName(
            new Set<Id>{ storeAccount.Id }
        );

        System.assertEquals(1, xrefRecords.size(), 'The list size does not match');
        System.assertEquals(
            xrefRecords[0].Business_Reference__c,
            businessReference1.Id,
            'The Business_Reference__c does not match'
        );
    }

    /**
     * @description It is used to check whether the Xref with “Integration Status” as
     * ‘Waiting for Business’and Business Reference with “Integration Status” as ‘Success’
     * returned on passing store account Ids.
     */
    @isTest
    private static void testWhenStoreAccountIdsPassedThenXrefWithWaitingForBusinessIntegrationStatusAndBizRefWithSuccessIntegrationStatusReturned() {
        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = SUCCESS
        );
        insert businessReference1;
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account storeAccount = new Account(
            name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = accRecordTypeStore,
            ParentId = null,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = EXTERNAL_ID,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                Integration_Status__c = WAITING_FOR_BUSINESS
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectActiveFailedXrefsBySalesforceAccountName(
            new Set<Id>{ storeAccount.Id }
        );

        System.assertEquals(1, xrefRecords.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            xrefRecords[0].Business_Reference__c,
            businessReference1.Id,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test count of 'DriveDb' Xrefs returned with Business Reference not having
     * External Id as the passes MP Bz Id when salesforce Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenCountOfDriveDBXrefNotHavingExternalIdAsPassedMPBzId() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        for (
            Aggregate eachAggregate : XrefsSelector.newInstance()
                .selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ businessAccount.Id },
                    new Set<String>{ '2233' }
                )
        ) {
            System.assertEquals(
                1,
                (Integer) eachAggregate.get(AGGREGATE_XREFSCOUNT_FIELD_ALIAS),
                EMPTY_LIST_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description To test no count of 'DriveDb' Xrefs returned with Business Reference not having
     * External Id as the passes MP Bz Id when salesforce Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenNoCountOfDriveDBXrefNotHavingExternalIdAsPassedMPBzId() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        List<Aggregate> aggregateQueryResult = XrefsSelector.newInstance()
            .selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
                new Set<Id>{ businessAccount.Id },
                new Set<String>{ '12345' }
            );
        System.assertEquals(0, aggregateQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To fetch 'DriveDb' Xrefs with Business Reference not having
     * External Id as the passes MP Bz Id when salesforce Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDriveDBXrefNotHavingExternalIdAsPassedMPBzIdReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
                new Set<Id>{ businessAccount.Id },
                new Set<String>{ '2233' },
                10
            );
        System.assertEquals(1, xrefs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test no 'DriveDb' Xrefs returned with Business Reference not having
     * External Id as the passes MP Bz Id when salesforce Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDriveDBXrefNotHavingExternalIdAsPassedMPBzIdNotReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
                new Set<Id>{ businessAccount.Id },
                new Set<String>{ '12345' },
                10
            );
        System.assertEquals(0, xrefs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    @isTest
    private static void testWhenSelectByStoreAccountsThenReturnXrefs() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account parentAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeBusiness,
            BillingCountry = 'United States',
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert parentAccount;
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = parentAccount.Id,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Integration_Status__c = INTEGRATION_SUCCESS,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;

        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectByStoreAccounts(new Set<Id>{ storeAccount.Id });
        System.assertNotEquals(1, xrefs.size(), 'Incorrect number of Xrefs returned');
    }

    /**
     * @description To test no 'DriveDb' Xrefs returned with Business Reference not having
     * External Id as the passes MP Bz Id when salesforce Account Ids are passed.
     */
    @isTest
    private static void testWhenDriveDbXrefsByAccountAndIntegrationStatusThenReturnedXrefWithStatusSuccess() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Integration_Status__c = INTEGRATION_SUCCESS,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper xrefWrapper = new NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper();
        xrefWrapper.allxrefFieldSet = new Set<String>{ 'Field' };
        xrefWrapper.alllookUpXref = new Set<String>{ 'Field' };
        xrefWrapper.excludeEntity = new Set<String>{ 'Field' };

        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectDriveDbXrefsByAccountAndIntegrationStatus(
                new Set<Id>{ businessAccount.Id },
                DateTime.now().addDays(-1),
                new List<String>{ UserInfo.getUserId() },
                xrefWrapper
            );
        System.assertEquals(1, xrefs.size(), 'The list size does not match');
    }

    /**
     * @description To test no 'MDS' Xrefs returned with Business Reference not having
     * External Id as the passes MP Bz Id when salesforce Account Ids are passed.
     */
    @isTest
    private static void testWhenMDSXrefsByAccountAndIntegrationStatusThenReturnedXrefWithStatusSuccess() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Integration_Status__c = INTEGRATION_SUCCESS,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper xrefWrapper = new NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper();
        xrefWrapper.allxrefFieldSet = new Set<String>{ 'Field' };
        xrefWrapper.alllookUpXref = new Set<String>{ 'Field' };
        xrefWrapper.excludeEntity = new Set<String>{ 'Field' };
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectMDSXrefsByAccountAndIntegrationStatus(
                new Set<Id>{ businessAccount.Id },
                DateTime.now().addDays(-1),
                new List<String>{ UserInfo.getUserId() },
                xrefWrapper
            );
        System.assertEquals(1, xrefs.size(), 'The list size does not match');
    }

    /**
     * @description It is used for querying Xref details by store Id & business Id
     * @jira# LEM-12911
     */
    @isTest
    private static void testWhenSelectByStoreIdAndBusinessIdThenReturnActiveXrefRecords() {
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            POS_Integration_ID__c = POS_INTEGRATION_ID,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(External_ID__c = '123', Business_Group_ID__c = '98123'),
            new Business_Reference__c(External_ID__c = '121234', Business_Group_ID__c = '981124')
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = STORE_ID,
                Unified_Store_ID__c = STORE_ID,
                Xref_Status__c = XREF_STATUS_ACTIVE
            )
        };
        insert xrefs;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectByStoreIdAndBusinessId(
            STORE_ID,
            businessReferences[0].External_ID__c
        );
        System.assertEquals(1, xrefRecords.size(), 'The list size does not match');
    }

    /**
     * @description To test Xrefs returned when ultimate account Ids are passed.
     */
    @isTest
    private static void testWhenUltimateParentAccountIdsArePassedThenReturnXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Integration_Status__c = INTEGRATION_SUCCESS,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectByUltimateParentAccountsforActivationValidation(
                new Set<Id>{ businessAccount.Id }
            );
        System.assertEquals(1, xrefs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description To test Xrefs are returned by using passed External Ids.
     */
    @isTest
    private static void testWhenExternalIdsPassedThenReturnMatchedXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecordsByExternalId = xrefsInstance.selectXrefByExternalIdsAndExternalSourceMDS(
            new Set<String>{ EXTERNAL_ID }
        );
        System.assertEquals(1, xrefRecordsByExternalId.size(), 'Xref List size does not match');
        System.assertEquals(
            businessAccount.Id,
            xrefRecordsByExternalId[0].Salesforce_Account_Name__c,
            'Accounts doesnt match'
        );
    }
    /**
     * @description To test No Xrefs are returned by using passed External Ids.
     */
    @isTest
    private static void testWhenExternalIdsPassedThenDontReturnMatchedXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecordsByExternalId = xrefsInstance.selectXrefByExternalIdsAndExternalSourceMDS(
            new Set<String>{ EXTERNAL_ID }
        );
        System.assertEquals(0, xrefRecordsByExternalId.size(), 'Xref List size does not match');
    }
    /**
     * @description To test when account ids are passed then related Xrefs are returned.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenXrefsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account dominos = new Account(
            name = 'TestAccount1',
            RecordtypeId = businessRecordTypeId,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            POS_Integration_ID__c = POS_INTEGRATION_ID,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert dominos;
        Brand__c brandKFC = new Brand__c(Name = 'KFC', Brand_Owner__c = dominos.Id);
        insert brandKFC;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE,
            Brand__c = null
        );
        insert businessReference;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Brand__c = brandKFC.Id,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectByAccountIds(new Set<Id>{ businessAccount.Id });
        Test.stopTest();
        System.assertEquals(false, xrefs.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            businessAccount.Id,
            xrefs[0].Salesforce_Account_Name__c,
            ASSERT_MISMATCH_FOR_ACCOUNT
        );
    }

    /**
     * @description To test when account ids are not passed then related Xrefs are not returned.
     */
    @isTest
    private static void testWhenEmptyAccountIdsPassedThenNoXrefsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account dominos = new Account(
            name = 'TestAccount1',
            RecordtypeId = businessRecordTypeId,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            POS_Integration_ID__c = POS_INTEGRATION_ID,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert dominos;
        Brand__c brandKFC = new Brand__c(Name = 'KFC', Brand_Owner__c = dominos.Id);
        insert brandKFC;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE,
            Brand__c = null
        );
        insert businessReference;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Brand__c = brandKFC.Id,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance().selectByAccountIds(new Set<Id>{});
        Test.stopTest();
        System.assertEquals(true, xrefs.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Account Ids are passed then related 'MDS' Xrefs are returned.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenMDSXrefsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE,
            Brand__c = null,
            Created_Source_Parent_Work_Order_Id__c = PARENT_WORK_ORDER_ID
        );
        insert businessReference;
        Account corporateAccountWithBrand = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert corporateAccountWithBrand;
        Brand__c brandMcDonalds = new Brand__c(
            Name = BRAND_NAME,
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandMcDonalds;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Brand__c = brandMcDonalds.Id,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
                new Set<Id>{ businessAccount.Id },
                new Set<String>{ PARENT_WORK_ORDER_ID }
            );
        Test.stopTest();
        System.assertEquals(false, xrefs.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Account Ids are not passed then related 'MDS' Xrefs are not returned.
     */
    @isTest
    private static void testWhenAccountIdsNotPassedThenMDSXrefsNotReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE,
            Brand__c = null
        );
        insert businessReference;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
                new Set<Id>{},
                new Set<String>{ PARENT_WORK_ORDER_ID }
            );
        Test.stopTest();
        System.assertEquals(true, xrefs.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Business Id passed then return Xref details.
     */
    @isTest
    private static void testWhenBusinessIdsPassedThenReturnXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE,
            Brand__c = null
        );
        insert businessReference;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = STORE_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectXrefsByBusinessReferenceExternalIdOrStoreIds(new Set<String>{ EXTERNAL_ID });
        Test.stopTest();
        System.assertEquals(1, xrefs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Store Id passed then return Xref details.
     */
    @isTest
    private static void testWhenStoreIdsPassedThenReturnXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_STORE)
            .getRecordTypeId();
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE,
            Brand__c = null
        );
        insert businessReference;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Account storeAccount = new Account(
            name = STORE_ACCOUNT_NAME,
            RecordtypeId = accRecordTypeStore,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            POS_Integration_ID__c = POS_INTEGRATION_ID,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = STORE_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectXrefsByBusinessReferenceExternalIdOrStoreIds(new Set<String>{ STORE_ID });
        Test.stopTest();
        System.assertEquals(1, xrefs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test Xrefs are returned by using passed External Ids.
     */
    @isTest
    private static void testWhenExternalIdsPassedThenReturnMatchedActiveMDSXrefs() {
        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = '12366',
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS
        );
        insert businessReference1;

        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account storeAccount = new Account(
            name = 'TestAccount1',
            RecordtypeId = accRecordTypeStore,
            ParentId = null,
            BillingStreet = '123 Test Street',
            BillingCity = 'Missoula',
            BillingState = 'Montana',
            BillingPostalCode = '59801',
            BillingCountry = 'United States',
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = storeAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Xref_Status__c = XREF_STATUS_ACTIVE,
                External_ID__c = EXTERNAL_ID
            )
        };
        insert xrefs;
        Test.startTest();
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecordsByExternalId = xrefsInstance.selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
            new Set<String>{ EXTERNAL_ID }
        );
        Test.stopTest();
        System.assertEquals(1, xrefRecordsByExternalId.size(), 'Xref List size does not match');
        System.assertEquals(
            storeAccount.Id,
            xrefRecordsByExternalId[0].Salesforce_Account_Name__c,
            'Accounts doesnt match'
        );
    }

    /**
     * @description To test when Xref Ids passed then return Xref details.
     */
    @isTest
    private static void testWhenXrefIdsPassedThenReturnXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_STORE)
            .getRecordTypeId();
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Integration_Status__c = FAILURE,
            Brand__c = null
        );
        insert businessReference;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Account storeAccount = new Account(
            name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = accRecordTypeStore,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            POS_Integration_ID__c = POS_INTEGRATION_ID,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert storeAccount;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = STORE_ID
        );
        insert xref;
        Test.startTest();
        List<Xref__c> xrefs = XrefsSelector.newInstance().selectById(new Set<Id>{ xref.Id });
        Test.stopTest();
        System.assertEquals(1, xrefs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test Xrefs returned when Business Ids are passed.
     */
    @isTest
    private static void testWhenBusinessAccountIdsArePassedThenReturnXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT,
            RecordtypeId = businessRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            CurrencyIsoCode = 'USD'
        );
        insert businessAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            External_ID__c = EXTERNAL_ID,
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Integration_Status__c = FAILURE
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            Business_Reference__c = businessReference.Id,
            Salesforce_Account_Name__c = businessAccount.Id,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            External_ID__c = EXTERNAL_ID
        );
        insert xref;
        List<Xref__c> xrefs = XrefsSelector.newInstance()
            .selectByBusinessAccountId(
                new Set<String>{ businessAccount.Id },
                new Set<String>(),
                new Set<String>{ businessAccount.CurrencyIsoCode }
            );
        System.assertEquals(0, xrefs.size(), 'No Record');
    }

    /**
     * @description To test MDS Xrefs are returned when Store Account Ids are passed irrespective of the
     * Xrefs Status.
     */
    @isTest
    private static void testWhenStoreAccountIdsPassedThenReturnMDSXrefsWithBothStatusValues() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_STORE)
            .getRecordTypeId();
        String businessGroupId1 = '98123';
        String businessGroupId2 = '981124';
        String externalId1 = '123';
        String externalId2 = '121234';
        Account parentAccount = new Account(
            name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = accRecordTypeBusiness,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert parentAccount;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                name = STORE_ACCOUNT_NAME,
                RecordtypeId = accRecordTypeStore,
                ParentId = parentAccount.Id,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingState = ACCOUNT_BILLING_STATE,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                name = STORE_ACCOUNT_NAME,
                RecordtypeId = accRecordTypeStore,
                ParentId = parentAccount.Id,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingState = ACCOUNT_BILLING_STATE,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                Segment__c = ACCOUNT_SEGMENT
            )
        };
        insert storeAccounts;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                External_ID__c = externalId1,
                Business_Group_ID__c = businessGroupId1
            ),
            new Business_Reference__c(
                External_ID__c = externalId2,
                Business_Group_ID__c = businessGroupId2
            )
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccounts[0].Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = externalId1,
                Xref_Status__c = XREF_STATUS_ACTIVE
            ),
            new Xref__c(
                Business_Reference__c = businessReferences[1].Id,
                Salesforce_Account_Name__c = storeAccounts[1].Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = externalId2,
                Xref_Status__c = XREF_STATUS_INACTIVE
            )
        };
        insert xrefs;
        Test.startTest();
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectMDSXrefsBySalesforceAccountIds(
            new Set<Id>{ storeAccounts[0].Id, storeAccounts[1].Id }
        );
        Test.stopTest();
        System.assertEquals(2, xrefRecords.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test DriveDB Xrefs are not returned when Store Account IDs are passed.
     */
    @isTest
    private static void testWhenStoreAccountIdsPassedThenDoNotReturnDriveDBXrefs() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_STORE)
            .getRecordTypeId();
        String businessGroupId1 = '98123';
        String businessGroupId2 = '981124';
        String externalId1 = '123';
        String externalId2 = '121234';
        Account parentAccount = new Account(
            name = BUSINESS_ACCOUNT_NAME,
            RecordtypeId = accRecordTypeBusiness,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert parentAccount;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                name = STORE_ACCOUNT_NAME,
                RecordtypeId = accRecordTypeStore,
                ParentId = parentAccount.Id,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingState = ACCOUNT_BILLING_STATE,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                name = STORE_ACCOUNT_NAME,
                RecordtypeId = accRecordTypeStore,
                ParentId = parentAccount.Id,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingState = ACCOUNT_BILLING_STATE,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                Segment__c = ACCOUNT_SEGMENT
            )
        };
        insert storeAccounts;

        Business_Reference__c[] businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                External_ID__c = externalId1,
                Business_Group_ID__c = businessGroupId1
            ),
            new Business_Reference__c(
                External_ID__c = externalId2,
                Business_Group_ID__c = businessGroupId2
            )
        };
        insert businessReferences;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReferences[0].Id,
                Salesforce_Account_Name__c = storeAccounts[0].Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                External_ID__c = externalId1,
                Xref_Status__c = XREF_STATUS_ACTIVE
            ),
            new Xref__c(
                Business_Reference__c = businessReferences[1].Id,
                Salesforce_Account_Name__c = storeAccounts[1].Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                External_ID__c = externalId2,
                Xref_Status__c = XREF_STATUS_INACTIVE
            )
        };
        insert xrefs;
        Test.startTest();
        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectMDSXrefsBySalesforceAccountIds(
            new Set<Id>{ storeAccounts[0].Id, storeAccounts[1].Id }
        );
        Test.stopTest();
        System.assertEquals(0, xrefRecords.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description To test Xrefs are returned by related rate change.
     */
    @isTest
    private static void testWhenBusinessReferenceThenReturnActiveXrefsRecords() {
        Account testAccount = TestDataFactory.createAccount(true);

        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_ID__c = '12366',
            Business_Group_ID__c = '98123',
            System_Created__c = true,
            External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE
        );
        insert businessReference1;

        Xref__c[] xrefs = new List<Xref__c>{
            new Xref__c(
                Business_Reference__c = businessReference1.Id,
                Salesforce_Account_Name__c = testAccount.Id,
                External_ID_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_ID__c = 'xref1',
                Xref_Status__c = XREF_STATUS_ACTIVE,
                Integration_Status__c = FAILURE
            )
        };
        insert xrefs;

        XrefsSelector xrefsInstance = new XrefsSelector();
        List<Xref__c> xrefRecords = xrefsInstance.selectActiveXrefByBusinessReferenceId(
            new Set<Id>{ businessReference1.Id }
        );
        System.assertEquals(1, xrefRecords.size(), 'The list size does not match');
    }
}