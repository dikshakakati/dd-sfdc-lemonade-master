/*
 * @description This is test class for GetBusinessFriendlyMessageService class.
 */
@isTest
public class GetBusinessFriendlyMessageServiceTest {
    @isTest
    private static void testWhenGetDetailsInvokedThenReturnBusinessFriendlyMessage() {
        string integrationType = 'Test Type';
        string integrationMessage = 'Test Integration Message';
        string expectedBusinessFriendlyMessage = 'Test Business Friendly Message';
        string expectedMessageCategory = 'Test Category';
        Test.startTest();
        Business_Friendly_Mapping__mdt businessFriendlyMapping = GetBusinessFriendlyMessageService.getMessageDetails(
            integrationMessage,
            integrationType
        );
        Test.stopTest();
        Assert.areEqual(
            expectedMessageCategory,
            businessFriendlyMapping.Message_Category__c,
            'Message Category is not returned as expected'
        );
        Assert.areEqual(
            expectedBusinessFriendlyMessage,
            businessFriendlyMapping.Business_Friendly_Message__c,
            'Business Friendly Message is not returned as expected'
        );
    }
}