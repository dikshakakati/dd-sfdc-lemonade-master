/**
 * @author Deloitte
 * @date 2024-07-23
 * @description This is test class for OptOutOfCommunicationsServiceImpl class
 */
@isTest
public with sharing class OptOutOfCommunicationsServiceImplTest {
    private static final String ASSERT_MESSAGE = 'Unexpected Result : Mimatch in field value';
    private static final String PHONE = '123456789';
    private static final String EMAIL = 'randomJoe@domain.com';
    private static final String SECONDARY_EMAIL = 'randomJoeSecondary@domain.com';
    /**
     * @description To test the update of DoNotCall and SMS Opted out fields for Contact
     */
    @IsTest
    private static void testWhenUpdateDoNotCallAndSMSOptedOutCalledThenContactUpdated() {
        Contact contactRecord = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            Email = EMAIL,
            Secondary_Email__c = SECONDARY_EMAIL,
            Phone = PHONE,
            Opt_Out_of_Marketing__c = false,
            DoNotCall = true,
            SMS_Opted_Out__c = true
        );
        OptOutOfCommunicationsService.updateDoNotCallAndSMSOptedOut(
            new List<Contact>{ contactRecord }
        );
        System.assertEquals(false, contactRecord.DoNotCall, ASSERT_MESSAGE);
        System.assertEquals(false, contactRecord.SMS_Opted_Out__c, ASSERT_MESSAGE);
    }

    /**
     * @description To test the update of DoNotCall and SMS Opted out fields for Lead
     */
    @IsTest
    private static void testWhenUpdateDoNotCallAndSMSOptedOutCalledThenLeadUpdated() {
        Lead leadRecord = new Lead(
            Id = fflib_IDGenerator.generate(Lead.SObjectType),
            Email = EMAIL,
            Phone = PHONE,
            Opt_Out_of_Marketing__c = false,
            DoNotCall = true,
            SMS_Opted_Out__c = true
        );
        OptOutOfCommunicationsService.updateDoNotCallAndSMSOptedOut(new List<Lead>{ leadRecord });
        System.assertEquals(false, leadRecord.DoNotCall, ASSERT_MESSAGE);
        System.assertEquals(false, leadRecord.SMS_Opted_Out__c, ASSERT_MESSAGE);
    }

    /**
     * @description To test the update of SMS_Opted_Out__c then update Date_SMS_Opted_Out_In__c on Lead/Contact.
     */
    @IsTest
    private static void testWhenUpdateDateSMSOptedOutOrInCalledThenLeadUpdated() {
        Lead leadRecord = new Lead(
            Id = fflib_IDGenerator.generate(Lead.SObjectType),
            Email = EMAIL,
            Phone = PHONE,
            Opt_Out_of_Marketing__c = false,
            DoNotCall = true,
            SMS_Opted_Out__c = true
        );
        OptOutOfCommunicationsService.updateDateSMSOptedOutOrIn(new List<Lead>{ leadRecord });
        System.assertEquals(system.today(), leadRecord.Date_SMS_Opted_Out_In__c, ASSERT_MESSAGE);
    }
}