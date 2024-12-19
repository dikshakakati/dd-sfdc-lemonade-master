/**
 * @author Deloitte
 * @date 08/22/2024
 * @description Test class for InstantIngestionFieldMappingSelector class.
 */
@isTest(SeeAllData=false)
public class InstantIngestionFieldMappingSelectorTest {
    /**
     * @description It is used to test Instant Ingestor field mapping custom metadata fields.
     */
    @isTest
    private static void testWhenGetSObjectFieldListMethodCalledThenReturnFields() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
           Inbound_Ingestion_Payload_Mapping__mdt.Integration_Type__c,
            Inbound_Ingestion_Payload_Mapping__mdt.Object__c,
            Inbound_Ingestion_Payload_Mapping__mdt.Default_Value__c,
			Inbound_Ingestion_Payload_Mapping__mdt.Field_Name__c,
			Inbound_Ingestion_Payload_Mapping__mdt.Payload_Attribute__c , 
			Inbound_Ingestion_Payload_Mapping__mdt.Payload_Type__c,
			Inbound_Ingestion_Payload_Mapping__mdt.Attribute_Key__c
        };

        Schema.SObjectType typeOfObject = InstantIngestionFieldMappingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = InstantIngestionFieldMappingSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Inbound_Ingestion_Payload_Mapping__mdt.SObjectType,
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
     * @description To test get all values from instant ingestion field mapping metadata.
     */
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        Inbound_Ingestion_Payload_Mapping__mdt[] bindings = new List<Inbound_Ingestion_Payload_Mapping__mdt>{
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c  = 'Name' ,
                Integration_Type__c  = 'SSOB',
                Object__c   = 'Account' ,
				Payload_Attribute__c = 'name', 
				Payload_Type__c = 'String',
				Default_Value__c = '',
				Attribute_Key__c = ''
            ),
			new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c  = 'Segment__c' ,
                Integration_Type__c  = 'SSOB',
                Object__c   = 'Account' ,
				Default_Value__c  = 'SMB',
				Payload_Type__c = 'String',
				Attribute_Key__c = '',
				Payload_Attribute__c = ''
            ),
                new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c  = 'BillingCity' ,
                Integration_Type__c  = 'SSOB',
                Object__c   = 'Account' ,
				Payload_Attribute__c = 'city', 
				Payload_Type__c = 'String',
                Attribute_Key__c = 'Address',
				Default_Value__c = ''
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        InstantIngestionFieldMappingSelector selectorMock = (InstantIngestionFieldMappingSelector) mocks.mock(
            InstantIngestionFieldMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Inbound_Ingestion_Payload_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        List<Inbound_Ingestion_Payload_Mapping__mdt> allEventsData = InstantIngestionFieldMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Inbound_Ingestion_Payload_Mapping__mdt.getAll().values(),
            allEventsData,
            'Unexpected Error: Mismatch in list of Notifier Event Binding Metadata'
        );
    }
}