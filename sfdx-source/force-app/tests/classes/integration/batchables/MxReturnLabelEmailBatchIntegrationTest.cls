/**
 * @author Deloitte
 * @date 05/22/2024
 * @description Integration Test class for MxReturnLabelEmailBatch.
 */
@isTest(SeeAllData=false)
private class MxReturnLabelEmailBatchIntegrationTest {
    private static final String ACCOUNT_NAME = 'Rx Business';
    private static final String ACCOUNT_ORDER_PROTOCOL = 'Tablet (DoorDash Owns)';
    private static final String ASSERT_MESSAGE_STATUS_NOT_UPDATED = 'Unexpected Result: Return label status not updated.';
    private static final string CONTACT_FIRSTNAME = 'Test';
    private static final string CONTACT_LASTNAME = 'Contact';
    private static final string CONTACT_EMAIL = 'MockEmailAddress@MxReturnLabelEmailBatchIntegrationTest.com';
    private static final String DOCUMENT_CONTENTS = 'Mock Shipping details for Mx Email.';
    private static final String DOCUMENT_PATH = '/';
    private static final String DOCUMENT_TITLE = 'Shipping Label';
    private static final String DOCUMENT_TYPE = '.jpg';
    private static final String MOCK_TEMPLATE_DEVELOPER_NAME = 'ReturnShippingLabel';
    private static final String MOCK_TEMPLATE_NAME = 'Return Shipping Label';
    private static final String RETURN_LABEL_SENT_TO_MX = 'Return Label Sent to Mx';
    private static final String SEGMENT = 'Enterprise';
    private static final String STATUS_RETURN_LABEL_GENERATED = 'Return Label Generated';
    private static final String TABLET_BUNDLE_CAN = 'Tablet Bundle (CAN)';
    private static final String TEMPLATE_TYPE_CUSTOM = 'custom';
    private static final String TEST_USER_ALIAS = 'MockUser';
    private static final String TEST_USER_EMAIL_ID = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com';
    private static final String TEST_USER_NAME = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com.test';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Mock User';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'GMT';

    /**
     * @description It is used to test MxOrder Return label status is updated
     * based on return label email status.
     */
    @isTest
    private static void testWhenMxOrdersWithReturnLabelAttachmentsPassedThenSendEmailToMxAndUpdateReturnLabelStatus() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Contact__c = contact.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Product_Bundle__c = productBundle.Id,
            Return_Label_Status__c = STATUS_RETURN_LABEL_GENERATED
        );
        insert merchantOrder;
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = DOCUMENT_TITLE;
        newContentVersion.PathOnClient = DOCUMENT_PATH + DOCUMENT_TITLE + DOCUMENT_TYPE;
        Blob bodyBlob = Blob.valueOf(DOCUMENT_CONTENTS);
        newContentVersion.VersionData = bodyBlob;
        insert newContentVersion;
        ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
        newContentDocumentLink.LinkedEntityId = merchantOrder.Id;
        newContentDocumentLink.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :newContentVersion.Id
        ]
        .ContentDocumentId;
        insert newContentDocumentLink;
        /** Created mock user to avoid Mixed DML Statements exception for inserting email template*/
        User mockUser = new User(
            Alias = TEST_USER_ALIAS,
            Email = TEST_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = TEST_USER_NAME
        );
        System.runAs(mockUser) {
            EmailTemplate newEmailTemplate = new EmailTemplate(
                Name = MOCK_TEMPLATE_NAME,
                DeveloperName = MOCK_TEMPLATE_DEVELOPER_NAME,
                TemplateType = TEMPLATE_TYPE_CUSTOM,
                FolderId = UserInfo.getUserId()
            );
            insert newEmailTemplate;
        }
        Test.startTest();
        MxReturnLabelEmailBatch batchInstance = new MxReturnLabelEmailBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        Mx_Order__c updatedMxOrder = [
            SELECT Id, Return_Label_Status__c
            FROM Mx_Order__c
            LIMIT 1
        ][0];
        System.assertEquals(
            RETURN_LABEL_SENT_TO_MX,
            updatedMxOrder.Return_Label_Status__c,
            ASSERT_MESSAGE_STATUS_NOT_UPDATED
        );
    }
}