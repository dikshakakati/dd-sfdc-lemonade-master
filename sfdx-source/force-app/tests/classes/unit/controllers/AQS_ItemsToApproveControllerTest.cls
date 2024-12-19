/**
 * @author ATG
 * @date 2022-04-20
 * @description This is test class for AQS_ItemsToApproveController class
 */
@isTest
private class AQS_ItemsToApproveControllerTest
{
    /**
	* @description To test AQS_ItemsToApproveController
	*/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenDataInitThenReturn()
    {
        /*
        SBAA__Approval__c testQuoteApproval = new SBAA__Approval__c(SBAA__Status__c = REQUESTED,
        SBAA__RecordField__c = 'AQS_Quote__c',
        SBAA__ApprovalStep__c = 10,
        SBAA__Rule__c = testApprovalRuleQuote.Id,
        SBAA__AssignedTo__c = testUser.Id,
        AQS_Quote__c = testQuote.Id );
        insert testQuoteApproval;

        SBAA__Approval__c testQuoteApproval2 = new SBAA__Approval__c(SBAA__Status__c = APPROVED,
        SBAA__RecordField__c = 'AQS_Quote__c',
        SBAA__ApprovalStep__c = 10,
        SBAA__Rule__c = testApprovalRuleQuote.Id,
        SBAA__AssignedTo__c = testUser.Id,
        AQS_Quote__c = testQuote2.Id );
*/
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = new User(Alias = 'test',
                                Email='testUser1@test.com',
                                EmailEncodingKey='UTF-8',
                                LastName='TestLastName',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                ProfileId = testProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles',
                                UserName='userEmail4306@test.com');
        insert testUser;
        System.runAs(testUser)
        {
            SBAA__Approval__c fakeRequestedApproval = (SBAA__Approval__c) new Fake(SBAA__Approval__c.class)
            .setField(SBAA__Approval__c.SBAA__Status__c, 'Requested')
            .setField(SBAA__Approval__c.CreatedDate, System.Date.today())
            .setField(SBAA__Approval__c.SBAA__AssignedTo__c, testUser.Id)
            .toSObject();

            SBAA__Approval__c fakeApprovedApproval = (SBAA__Approval__c) new Fake(SBAA__Approval__c.class)
            .setField(SBAA__Approval__c.SBAA__Status__c, 'Approved')
            .setField(SBAA__Approval__c.SBAA__AssignedTo__c, testUser.Id)
            .toSObject();

            fflib_ApexMocks mocks = new fflib_ApexMocks();
            IGroupMembersSelector groupMemberSelectorMock = (IGroupMembersSelector) mocks.mock(
                IGroupMembersSelector.class
            );
            IAQS_AAApprovalSelector approvalSelectorMock = (IAQS_AAApprovalSelector) mocks.mock(
                IAQS_AAApprovalSelector.class
            );

            mocks.startStubbing();
            mocks.when(groupMemberSelectorMock.sObjectType()).thenReturn(GroupMember.SObjectType);
            mocks.when(groupMemberSelectorMock.selectGroupMembersByUserId(new Set<Id>{testUser.Id})).thenReturn(new List<GroupMember>());
            mocks.when(approvalSelectorMock.sObjectType()).thenReturn(SBAA__Approval__c.SObjectType);
            mocks.when(approvalSelectorMock.selectRequestedForUserIds(new Set<Id>{testUser.Id})).thenReturn(new List<SBAA__Approval__c>{fakeRequestedApproval});
            mocks.when(approvalSelectorMock.selectApprovedOrderedByLastModifiedDate()).thenReturn(new List<SBAA__Approval__c>{fakeApprovedApproval});
            mocks.stopStubbing();
            Application.SELECTOR.setMock(groupMemberSelectorMock);
            Application.SELECTOR.setMock(approvalSelectorMock);

            AQS_ItemsToApproveController controller = new AQS_ItemsToApproveController();
            System.assert(controller.approvalListSize > 0, 'Controller should have Approvals');
        }
    }
}