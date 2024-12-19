/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Test class for EmailOutboundEventBindingSelector class
 */
@isTest(seeAllData=false)
public class EmailOutboundEventBindingSelectorTest {
    private static final String ASSERT_MESSAGE_FIELDS_LIST = 'Unexpected Error: Mismatch in field list';
    private static final String ASSERT_MESSAGE_RECORDS_LIST = 'Unexpected Error: Mismatch in list of Metadata records';
    private static final String ASSERT_MESSAGE_SOBJECT_TYPE = 'Unexpected Error: The object type must be Email outbound integration binding custom metadata';
    private static final String EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String SERVICE_CLASS_NAME = 'IntegrationOutboundService';

    /**
     * @description To test Email outbound integration binding custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Email_Outbound_Events_Binding__mdt.Topic__c,
            Email_Outbound_Events_Binding__mdt.Class_Name__c,
            Email_Outbound_Events_Binding__mdt.Scope_Size__c
        };

        Schema.SObjectType typeOfObject = EmailOutboundEventBindingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = EmailOutboundEventBindingSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Email_Outbound_Events_Binding__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_SOBJECT_TYPE
        );

        System.assertEquals(sObjectFieldsMock, sObjectFields, ASSERT_MESSAGE_FIELDS_LIST);
    }

    /**
     * @description To test get all values from Email outbound integration binding custom metadata.
     */
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        Email_Outbound_Events_Binding__mdt[] bindings = new List<Email_Outbound_Events_Binding__mdt>{
            new Email_Outbound_Events_Binding__mdt(
                Class_Name__c = SERVICE_CLASS_NAME,
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        EmailOutboundEventBindingSelector selectorMock = (EmailOutboundEventBindingSelector) mocks.mock(
            EmailOutboundEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Email_Outbound_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        List<Email_Outbound_Events_Binding__mdt> allEventsData = EmailOutboundEventBindingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Email_Outbound_Events_Binding__mdt.getAll().values(),
            allEventsData,
            ASSERT_MESSAGE_RECORDS_LIST
        );
    }
}