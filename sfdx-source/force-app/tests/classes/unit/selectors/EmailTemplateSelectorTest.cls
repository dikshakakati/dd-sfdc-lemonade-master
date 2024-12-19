/**
 * @author atg
 * @date 05/11/2022
 * @description This is test class for EmailTemplateSelector class
 */
@isTest(SeeAllData=false)
private class EmailTemplateSelectorTest {
    private static final String ASSERT_MESSAGE_RECORDS_NOT_RETURNED = 'Unexpected Result: Email Templates not returned.';
    private static final String MOCK_TEMPLATE_DEVELOPER_NAME = 'MockTemplate';
    private static final String MOCK_TEMPLATE_NAME = 'Mock Template';
    private static final String TEMPLATE_TYPE_CUSTOM = 'custom';

    /**
     * @description This is method used to test EmailTemplateSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenVerifyType() {
        EmailTemplateSelector templatesInstance = new EmailTemplateSelector();
        Schema.SObjectType typeOfObj = templatesInstance.getSObjectType();
        System.assertEquals(
            Schema.EmailTemplate.SObjectType,
            typeOfObj,
            'The object type must be EmailTemplate'
        );

        List<Schema.SObjectField> fieldList = templatesInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                EmailTemplate.Id,
                EmailTemplate.Name,
                EmailTemplate.Folder.Name
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This is method used to test EmailTemplateSelector SelectByFolderName
     */
    @isTest
    private static void testWhenSelectByFolderNameThenReturnRecords() {
        //You cannot create Folders to insert EmailTemplates into in a unit test, they should already be existing in the org.
        List<EmailTemplate> emailTemplates = EmailTemplateSelector.newInstance()
            .selectByFolderName('AQS AA Email Templates');

        System.assertNotEquals(emailTemplates.size(), 0, 'Folder should be set up with Records');

        List<EmailTemplate> templatesById = EmailTemplateSelector.newInstance()
            .selectById(new Set<Id>{ emailTemplates[0].Id });
        System.assertNotEquals(templatesById.size(), 0, 'selectById should return with Records');
    }

    /**
     * @description This method is used to test Email templates are selected by template names.
     */
    @isTest
    private static void testWhenTemplateNamesReceivedThenReturnEmailTemplates() {
        EmailTemplate newEmailTemplate = new EmailTemplate(
            Name = MOCK_TEMPLATE_NAME,
            DeveloperName = MOCK_TEMPLATE_DEVELOPER_NAME,
            TemplateType = TEMPLATE_TYPE_CUSTOM,
            FolderId = UserInfo.getUserId()
        );
        insert newEmailTemplate;

        List<EmailTemplate> emailTemplates = EmailTemplateSelector.newInstance()
            .selectByTemplateNames(new Set<String>{ newEmailTemplate.Name });
        System.assertEquals(1, emailTemplates.size(), ASSERT_MESSAGE_RECORDS_NOT_RETURNED);
    }
}