/**
 * @author Deloitte
 * @date 08/19/2022
 * @description Integration test class for Attachments trigger.
 */
@isTest(SeeAllData=false)
public class AttachmentsIntegrationTest {
    private static final string ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final string ACCOUNT_BILLING_CITY = 'Missoula';
    private static final string ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final string ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final string ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String ATTACHMENT_BODY = 'AttachmentsIntegrationTest Body';
    private static final String ATTACHMENT_DESCRIPTION = 'AttachmentsIntegrationTest Description';
    private static final String ATTACHMENT_NAME = 'AttachmentsIntegrationTest_Menu_Nintex';
    private static final String CONTENT_DOCUMENT_EMPTY_ASSERT_MESSAGE = 'Unexpected result: The list of Content Document Links created is empty';
    private static final String CONTENT_DOCUMENT_SIZE_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: The number of Content Document Links created is not matching';
    private static final String CONTENT_DOCUMENT_TITLE_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: The title of Content Document created did not match with the name of Attachment';
    private static final String NINTEX_USER_ALIAS = 'ninUser';
    private static final String NINTEX_USER_EMAIL_ID = 'nintexUser@testorg.com';
    private static final String NINTEX_USER_USERNAME = System.Label.NintexUsername + '.test';
    private static final string STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Testing';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'America/Los_Angeles';

    /**
     * @description It is used to setup test data.
     */
    @testSetup
    private static void setupData() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Segment__c = 'Enterprise'
        );
        insert storeAccount;
    }

    /**
     * @description To test conversion of Attachments to Files and deletion when
     * uploaded by Nintex integration user.
     */
    @isTest
    private static void testWhenAttachmentsInsertedByNintexIntegrationUserThenAttachmentsConvertedToFilesAndDeleted() {
        Account storeAccount = [SELECT Id FROM Account WHERE Name = :STORE_ACCOUNT_NAME][0];
        Attachment newAttachment = new Attachment(
            Name = ATTACHMENT_NAME,
            Description = ATTACHMENT_DESCRIPTION,
            Body = Blob.valueOf(ATTACHMENT_BODY),
            ParentId = storeAccount.Id
        );
        User nintexUser = new User(
            Alias = NINTEX_USER_ALIAS,
            Email = NINTEX_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = NINTEX_USER_USERNAME
        );
        Test.startTest();
        System.runAs(nintexUser) {
            insert newAttachment;
        }
        Test.stopTest();
        List<ContentDocumentLink> contentDocumentLinksCreated = [
            SELECT Id, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :storeAccount.Id
        ];
        System.assertNotEquals(
            null,
            contentDocumentLinksCreated.size(),
            CONTENT_DOCUMENT_EMPTY_ASSERT_MESSAGE
        );
        System.assertEquals(
            ATTACHMENT_NAME,
            contentDocumentLinksCreated[0].ContentDocument.Title,
            CONTENT_DOCUMENT_TITLE_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test there is no conversion of Attachments to Files when uploaded
     * by any user other than Nintex integration user.
     */
    @isTest
    private static void testWhenAttachmentsInsertedByAnyOtherUserThenAttachmentsNotConvertedToFilesAndDeleted() {
        Account storeAccount = [SELECT Id FROM Account WHERE Name = :STORE_ACCOUNT_NAME][0];
        Attachment newAttachment = new Attachment(
            Name = ATTACHMENT_NAME,
            Description = ATTACHMENT_DESCRIPTION,
            Body = Blob.valueOf(ATTACHMENT_BODY),
            ParentId = storeAccount.Id
        );
        Test.startTest();
        insert newAttachment;
        Test.stopTest();
        List<ContentDocumentLink> contentDocumentLinksCreated = [
            SELECT Id, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :storeAccount.Id
        ];
        System.assertEquals(
            0,
            contentDocumentLinksCreated.size(),
            CONTENT_DOCUMENT_SIZE_MISMATCH_ASSERT_MESSAGE
        );
    }
}