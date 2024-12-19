/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestorEventBindingsSelector class.
 */
@isTest(SeeAllData=false)
public class InstantIngestorEventBindingsSelectorTest {
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';

    /**
     * @description It is used to test Instant Ingestor event binding custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Instant_Ingestor_Event_Binding__mdt.Topic__c,
            Instant_Ingestor_Event_Binding__mdt.Class_Name__c,
            Instant_Ingestor_Event_Binding__mdt.Scope_Size__c
        };

        Schema.SObjectType typeOfObject = InstantIngestorEventBindingsSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = InstantIngestorEventBindingsSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Instant_Ingestor_Event_Binding__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Notifier Events Binding Metadata'
        );

        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description To test get all values from instant ingestor event metadata.
     */
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        Instant_Ingestor_Event_Binding__mdt[] bindings = new List<Instant_Ingestor_Event_Binding__mdt>{
            new Instant_Ingestor_Event_Binding__mdt(
                Class_Name__c = 'SSMOOnboardingService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        InstantIngestorEventBindingsSelector selectorMock = (InstantIngestorEventBindingsSelector) mocks.mock(
            InstantIngestorEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Bypass_Trigger_Setting__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        List<Instant_Ingestor_Event_Binding__mdt> allEventsData = InstantIngestorEventBindingsSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Instant_Ingestor_Event_Binding__mdt.getAll().values(),
            allEventsData,
            'Unexpected Error: Mismatch in list of Notifier Event Binding Metadata'
        );
    }
}