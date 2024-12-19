/**
 * @author Deloitte
 * @date 01/23/2024
 * @description Test class for LogsEmailNotificationServiceImpl class.
 */
@isTest(SeeAllData=false)
private class LogsEmailNotificationServiceImplTest {
    /**
     * @description To test triggering of email flow when eligible Log records found.
     * TODO: Update verify statements to verify flow interview call.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEligibleLogsSentThenEmailNotificationFlowTriggered() {
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id recepientId = fflib_IDGenerator.generate(User.SObjectType);
        Log__c mockLog = new Log__c(
            Id = fflib_IDGenerator.generate(Log__c.SObjectType),
            Send_Notification__c = true,
            Parent_Account_Id_18__c = parentAccountId,
            Franchise_Parent_Account_Id_18__c = null,
            Recipient_Ids_To_Send_Notification__c = recepientId,
            CreatedDate = System.today() + 1
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LogsSelector mockLogsSelector = (LogsSelector) mocks.mock(LogsSelector.class);
        mocks.startStubbing();
        mocks.when(mockLogsSelector.sObjectType()).thenReturn(Log__c.SObjectType);
        mocks.when(
                mockLogsSelector.selectLogsEligibleToSendNotification(
                    parentField,
                    new Set<Id>{ parentAccountId },
                    Log__c.Franchise_Parent_Account_Id_18__c
                )
            )
            .thenReturn(new List<Log__c>{ mockLog });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockLogsSelector);
        LogsEmailNotificationService.initiateEmailNotificationsProcessor(
            parentField,
            new Set<Id>{ parentAccountId }
        );
    }
}