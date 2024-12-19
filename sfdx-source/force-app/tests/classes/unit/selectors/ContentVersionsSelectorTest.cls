/**
 * @author DoorDash
 * @description Test class for ContentVersion Selector class.
 **/
@IsTest
private class ContentVersionsSelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ASSERT_MESSAGE_CONTENT_VERSION_NOT_RETURNED = 'Unexpected Result: Content Versions not retrieved.';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String DOCUMENT_STATUS = 'Approved';
    private static final String DOCUMENT_TYPE_PASSPORT = 'Passport';
    private static final String MX_COUNTRY_US = 'US';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String RECORD_TYPE_BUSINESS = 'Business';
    private static final String RECORD_TYPE_STORE = 'Store';
    private static final String CONTENT_VERSION_TITLE = 'Test McDonald Document';
    private static final String CONTENT_VERSION_PATH_ON_CLIENT = 'TestDocument1.txt';
    @TestSetup
    static void setupTestData() {
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Test Document 1',
            PathOnClient = 'TestDocument1.txt',
            VersionData = Blob.valueOf('Test content 1'),
            IsMajorVersion = true
        );
        insert contentVersion1;

        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test Document 2',
            PathOnClient = 'TestDocument2.txt',
            VersionData = Blob.valueOf('Test content 2'),
            IsMajorVersion = true
        );
        insert contentVersion2;
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ContentVersionsSelector selectorInstance = new ContentVersionsSelector();
        Schema.SObjectType typeOfObj = selectorInstance.getSObjectType();

        System.assertEquals(
            ContentVersion.SObjectType,
            typeOfObj,
            'The object type must match ContentVersion'
        );

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();

        System.assertEquals(
            new List<Schema.SObjectField>{
                ContentVersion.Id,
                ContentVersion.CreatedById,
                ContentVersion.CreatedDate,
                ContentVersion.FileType,
                ContentVersion.LastModifiedDate,
                ContentVersion.LastModifiedById,
                ContentVersion.ContentDocumentId,
                ContentVersion.Description,
                ContentVersion.IsLatest,
                ContentVersion.Title,
                ContentVersion.VersionNumber,
                ContentVersion.VersionData
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenVersionIdsAreProvidedThenVersionsAreReceived() {
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        Set<Id> idSet = new Set<Id>();
        for (ContentVersion cv : contentVersions) {
            idSet.add(cv.Id);
        }

        List<ContentVersion> results = ContentVersionsSelector.newInstance().selectById(idSet);

        System.assertNotEquals(null, results, 'Should not return null');
        System.assertEquals(
            idSet.size(),
            results.size(),
            'Should return the same number of records'
        );
    }

    @isTest
    private static void testWhenDocumentIdsAreProvidedThenRetrieveVersions() {
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion];
        Set<Id> documentIds = new Set<Id>();
        for (ContentVersion cv : contentVersions) {
            documentIds.add(cv.ContentDocumentId);
        }

        List<ContentVersion> results = ContentVersionsSelector.newInstance()
            .selectByContentDocumentIds(documentIds);

        System.assertNotEquals(null, results, 'Should not return null');
        System.assertEquals(
            documentIds.size(),
            results.size(),
            'Should return the same number of records'
        );
    }

    @isTest
    private static void testWhenDocumentIdsAreProvidedThenRetrieveLatestVersions() {
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE IsLatest = TRUE
        ];
        Set<Id> documentIds = new Set<Id>();
        for (ContentVersion cv : contentVersions) {
            documentIds.add(cv.ContentDocumentId);
        }

        List<ContentVersion> results = ContentVersionsSelector.newInstance()
            .selectLatestByContentDocumentIds(documentIds);

        System.assertNotEquals(null, results, 'Should not return null');
        System.assertEquals(
            documentIds.size(),
            results.size(),
            'Should return the same number of records'
        );
    }

    /**
     * @description To validate Content Version details along with Fraud Document details are returned
     * based on passed Store Account Ids.
     **/
    @isTest
    private static void testWhenRelatedToIdPassedThenReturnContentVersionDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE_BUSINESS)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE_STORE)
            .getRecordTypeId();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = STORE_ACCOUNT_NAME,
                ParentId = parentAccounts[0].Id,
                RecordTypeId = storeRecordTypeId,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;

        Mx_Fraud_Document__c mxFraudDocument = new Mx_Fraud_Document__c(
            Mx_Country__c = MX_COUNTRY_US,
            Mx_Document_Type__c = DOCUMENT_TYPE_PASSPORT,
            Mx_Document_Verification_Status__c = DOCUMENT_STATUS,
            Mx_Document_Verification_Notes__c = CONTENT_VERSION_TITLE,
            Mx_Store_Id__c = storeAccounts[0].Id
        );
        insert mxFraudDocument;

        ContentVersion newContentVersion = new ContentVersion(
            IsMajorVersion = true,
            PathOnClient = CONTENT_VERSION_PATH_ON_CLIENT,
            Mx_Fraud_Document__c = mxFraudDocument.Id,
            Related_To_Id__c = storeAccounts[0].Id,
            Title = CONTENT_VERSION_TITLE,
            VersionData = Blob.valueOf(CONTENT_VERSION_TITLE)
        );
        insert newContentVersion;

        Test.startTest();
        List<ContentVersion> results = ContentVersionsSelector.newInstance()
            .selectByRelatedStoreIds(new Set<Id>{ storeAccounts[0].Id });
        Test.stopTest();

        System.assertEquals(1, results.size(), ASSERT_MESSAGE_CONTENT_VERSION_NOT_RETURNED);
    }
}