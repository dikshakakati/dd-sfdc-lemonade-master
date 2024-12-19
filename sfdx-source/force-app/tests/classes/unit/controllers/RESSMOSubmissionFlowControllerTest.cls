/**
 * @description       : Test class for RESSMOSubmissionFlowController
 * @author            : VenkateshDD
 * @group             : Aethereus
 * @last modified on  : 12-14-2024
 * @last modified by  : VenkateshDD
**/
@isTest
public class RESSMOSubmissionFlowControllerTest {

    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CONTRACT_STATUS = 'Draft';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String NO = 'No';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Mx Onboarding Link';
    private static final String ONBOARDING_SCENARIO = 'Net-New';
    private static final String ONBOARDING_SCENARIO_NSE = 'NSE';
    private static final String QUERY_RETURN_NO_MX_ONBOARDING_LINKS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any Mx_Onboarding_Link__c';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String YES = 'Yes';

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenSendEmailsThenSendEmail() {

        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Contract contractInstance = new Contract(
            AccountId = businessAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Mx_Onboarding_Link__c mxOnboardingLink = new Mx_Onboarding_Link__c(
            Business_Account__c = businessAccount.Id,
            Contract__c = contractInstance.Id,
            Onboarding_Scenario__c = ONBOARDING_SCENARIO,
            Rep_Collecting_On_Mx_Behalf__c = NO,
            Expiration_Date_Time__c = System.today().addDays(10),
            Status__c = STATUS_ACTIVE,
            Record_Creation_Status__c = STATUS_SUCCESS
        );
        insert mxOnboardingLink;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IsObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        APPLICATION.UNITOFWORK.setMock(mockUOW);

        // Setup test data
        String emailTemplateDeveloperName = System.Label.NSE_Submission_Flow_Completed;
        List<RESSMOSubmissionFlowController.EmailInput> emailInputs = new List<RESSMOSubmissionFlowController.EmailInput>();
        RESSMOSubmissionFlowController.EmailInput ei = new RESSMOSubmissionFlowController.EmailInput();
        ei.templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateDeveloperName].Id;
        ei.orgWideAddress = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        ei.emailAddresses = new List<String>{'venkatesh.r+email@ext.doordash.com'};
            ei.whatId = mxOnboardingLink.Id;

        emailInputs.add(ei);

		RESSMOSubmissionFlowController.sendEmails(emailInputs);

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,1)).commitwork();
    }
}
