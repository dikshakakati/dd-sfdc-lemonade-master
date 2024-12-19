/**
 * @author ATG
 * @date 2022-04-20
 * @description This is test class for AQS_AAEnablementHomeController class
 */
//We use See all data = true, because we want to test the email templates that are installed in this org with the Advanced Approvals package.
@isTest
private class AQS_AAEnablementHomeControllerTest {

    /**
	* @description To test AQS_AAEnablementHomeController
	*/
    @istest
    static void testWhenUpdateCustomSettingThenCustomSettingsSet() {
        AQS_AAEnablementHomeController aaHomePage = new AQS_AAEnablementHomeController();
        aaHomePage.updateCustomSetting();

        AQS_AA_Enablement_IDs__c recordTypeCustomSetting = AQS_AA_Enablement_IDs__c.getOrgDefaults();
        System.assert(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('AQS Approved Quote').getRecordTypeId() == recordTypeCustomSetting.AQS_Approved_Quote_RT__c, 'Email templates record types should be set up correctly');
    }

    @istest
    static void testWhenUpdateEmailLogoIdThenIdSet() {
        AQS_AAEnablementHomeController aaHomePage = new AQS_AAEnablementHomeController();
        //We just need a 18 digit ID, it doesn't matter what type.
        Id emailTemplateId1 = Fake.generateId( EmailTemplate.class );
        aaHomePage.recordTypeSetting.AQS_Approval_Email_Logo_ID__c = emailTemplateId1;
        aaHomePage.updateEmailLogoId();

        AQS_AA_Enablement_IDs__c recordTypeCustomSetting = AQS_AA_Enablement_IDs__c.getOrgDefaults();
        System.assert(recordTypeCustomSetting.AQS_Approval_Email_Logo_ID__c == String.valueOf(emailTemplateId1), 'Email templates Logo Id should be set up correctly');
    }

    @istest
    static void testWhenInvalidEmailLogoIdThenIdSet() {
        AQS_AAEnablementHomeController aaHomePage = new AQS_AAEnablementHomeController();
        //Not a 15 or 18 digit ID
        aaHomePage.recordTypeSetting.AQS_Approval_Email_Logo_ID__c = '001';
        aaHomePage.updateEmailLogoId();

        AQS_AA_Enablement_IDs__c recordTypeCustomSetting = AQS_AA_Enablement_IDs__c.getOrgDefaults();
        System.assert(recordTypeCustomSetting.AQS_Approval_Email_Logo_ID__c == '001', 'Email templates Logo Id should be set up correctly');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCreateTemplatesThenCallService() {
        Id emailTemplateId1 = Fake.generateId( EmailTemplate.class );
        Id emailTemplateId2 = Fake.generateId( EmailTemplate.class );

        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>{
			new EmailTemplate(Id = emailTemplateId1, Name = 'emailTemplateId1'),
			new EmailTemplate(Id = emailTemplateId2, Name = 'emailTemplateId2')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEmailTemplateSelector emailTemplateSelectorMock = (IEmailTemplateSelector) mocks.mock(
            IEmailTemplateSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = ( fflib_ISObjectUnitOfWork ) mocks.mock( fflib_ISObjectUnitOfWork.class );

        mocks.startStubbing();
        mocks.when(emailTemplateSelectorMock.sObjectType()).thenReturn(EmailTemplate.SObjectType);
        mocks.when(emailTemplateSelectorMock.selectByFolderName('AQS AA Email Templates')).thenReturn(emailTemplateList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(emailTemplateSelectorMock);
        Application.UNITOFWORK.setMock( mockUOW );

        AQS_AAEnablementHomeController controller = new AQS_AAEnablementHomeController();
        controller.createTemplates();

        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                sbaa__EmailTemplate__c.Name => 'emailTemplateId1',
                sbaa__EmailTemplate__c.sbaa__templateID__c => emailTemplateId1
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                sbaa__EmailTemplate__c.Name => 'emailTemplateId2',
                sbaa__EmailTemplate__c.sbaa__templateID__c => emailTemplateId2
            }
        ) );
    }
}