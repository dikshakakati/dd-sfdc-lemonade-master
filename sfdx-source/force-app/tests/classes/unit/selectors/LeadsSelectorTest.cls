/**
 * @author Deloitte
 * @date 04/09/2024
 * @description This is test class for LeadsSelector class
 */
@isTest(seeAllData=false)
public class LeadsSelectorTest {
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String LEAD_COMPANY = 'McDonaldsCorp';
    private static final String LEAD_EMAIL_ADDRESS = 'abc@mcdonalds.com';
    private static final String LEAD_FIRST_NAME = 'McDonalds';
    private static final String LEAD_LAST_NAME = 'US';
    private static final String LEAD_STREET = 'Texas 1234 St';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Lead.';
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String UNIQUE_IDENTIFIER2 = '92108a53-e8d9-4a0c-9193-9152aeb86fe5';
    private static final String LEAD_COVERSION_TYPE = 'Auto';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        LeadsSelector leadsSelectorInstance = (LeadsSelector) LeadsSelector.newInstance();
        Schema.SObjectType typeOfObject = leadsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = leadsSelectorInstance.getSObjectFieldList();
        Lead leadInstance = new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = LEAD_COMPANY,
            Email = LEAD_EMAIL_ADDRESS,
            Street = LEAD_STREET,
            IsConverted = false,
            Lead_Conversion_Type__c = LEAD_COVERSION_TYPE,
            SSMO_UUID__c = UNIQUE_IDENTIFIER
        );
        insert leadInstance;
        List<Lead> leads = leadsSelectorInstance.selectById(new Set<Id>{ leadInstance.Id });
        System.assertEquals(leads.size(), 1, EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            Schema.Lead.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Lead.Id,
                Lead.Street,
                Lead.Company,
                Lead.Time_Zone_Backend__c,
                Lead.Address,
                Lead.Count_of_Emails_Sent__c,
                Lead.Count_of_Calls_Outbound_Inbound__c,
                Lead.Store_Id__c,
                Lead.SSMO_UUID__c,
                Lead.Business_ID__c,
                Lead.ConvertedAccountId,
                Lead.IsConverted,
                Lead.Inbound_Ingestion_Log__c,
                Lead.Lead_Conversion_Type__c,
                Lead.Unique_Id__c,
                Lead.Phone,
                Lead.MobilePhone,
                Lead.FirstName,
                Lead.LastName,
                Lead.Email,
                Lead.PreferredLanguage__c,
                Lead.Business_Id__c,
                Lead.City,
                Lead.State,
                Lead.Statecode,
                Lead.Country,
                Lead.CountryCode,
                Lead.PostalCode,
                Lead.Address_Verification_Status__c,
                Lead.Rejected_Reason__c,
                Lead.Address_Verification_Date__c,
                Lead.PrimaryVertical__c,
                Lead.Starting_Point__c,
                Lead.Starting_Point_Id__c,
                Lead.Alcohol_Eligibility__c,
                Lead.Order_Protocol_Phone__c,
                Lead.Order_Protocol__c,
                Lead.Order_Protocol_Email__c,
                Lead.Menu_URL__c,
                Lead.HoursOfOperation__c,
                Lead.Provider_Type__c,
                Lead.Coverage__c,
                Lead.Last_Coverage_Check_Time__c,
                Lead.Self_Serve_Step__c,
                Lead.Coverage_Start_Date__c,
                Lead.EmailVerificationStatus__c,
                Lead.Meeting_Set__c,
                Lead.First_Qualified_Activity__c,
                Lead.Submarket__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description It verifies if the relevant Leads are fetched
     * when email address, company and street are sent.
     */
    @isTest
    private static void testWhenEmailAndCompanyThenMatchingLeadReturned() {
        Lead leadInstance = new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = LEAD_COMPANY,
            Email = LEAD_EMAIL_ADDRESS,
            Street = LEAD_STREET
        );
        insert leadInstance;
        Test.startTest();
        List<Lead> newLeads = LeadsSelector.newInstance()
            .selectLeadsByEmailAndCompany(LEAD_EMAIL_ADDRESS, LEAD_COMPANY);
        Test.stopTest();
        System.assertEquals(1, newLeads.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It verifies if the relevant Leads are fetched
     * when email address, company and street are sent.
     */
    @isTest
    private static void testWhenEmailCompanyAndStreetPassedThenNonMatchingLeadNotReturned() {
        Lead leadInstance = new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = LEAD_COMPANY,
            Email = LEAD_EMAIL_ADDRESS,
            Street = LEAD_STREET
        );

        String emailAddress = 'abcd@mcdonalds.com';
        String company = 'McDonaldsCorp';

        insert leadInstance;
        Test.startTest();
        List<Lead> newLeads = LeadsSelector.newInstance()
            .selectLeadsByEmailAndCompany(emailAddress, company);
        Test.stopTest();
        System.assertEquals(0, newLeads.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that Lead records returned on unique
     * Identifier passed.
     */
    @isTest
    private static void testWhenUUIDPassedThenLeadsReturned() {
        insert new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = LEAD_COMPANY,
            Email = LEAD_EMAIL_ADDRESS,
            SSMO_UUID__c = UNIQUE_IDENTIFIER
        );
        Test.startTest();
        List<Lead> leads = LeadsSelector.newInstance()
            .selectByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER });
        Test.stopTest();
        System.assertEquals(1, leads.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that no Lead returns when different unique
     * Identifier passed.
     */
    @isTest
    private static void testWhenDifferentUUIDPassedThenNoLeadsReturned() {
        insert new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = LEAD_COMPANY,
            Email = LEAD_EMAIL_ADDRESS,
            SSMO_UUID__c = UNIQUE_IDENTIFIER2
        );
        Test.startTest();
        List<Lead> leads = LeadsSelector.newInstance()
            .selectByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER });
        Test.stopTest();
        System.assertEquals(0, leads.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}