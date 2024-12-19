/**
 * @author Deloitte
 * @date 2024-07-22
 * @description This is test class for CassieIdEncryptionServiceImpl class
 */
@isTest
public with sharing class CassieIdEncryptionServiceImplTest {
    private static final String EMAIL_PREFERENCES_ENCRYPTION_KEY = 'Email_Preferences_Encryption_Key';
    private static final String EMAIL_PREFERENCES_PERSONA = 'Email_Preferences_Persona';
    private static final String ENCRYPTION_KEY_METADATA_VALUE = '1c5ayepuCXJYOQJYw+KhnxJcgWqm2tukVOHksu9K+rg=';
    private static final String PERSONA_METADATA_VALUE = 'Mx';
    private static final String ASSERT_MESSAGE = 'Unexpected Result : Mimatch in field value';
    private static final String PHONE = '123456789';
    private static final String EMAIL = 'randomJoe@domain.com';
    private static final String SECONDARY_EMAIL = 'randomJoeSecondary@domain.com';
    /**
     * @description To test the encryption of cassie id of contact.
     */
    @IsTest
    private static void testWhenEncryptCassieIdCalledThenContactEmailCassieIdUpdated() {
        Contact contactRecord = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            Email = EMAIL,
            Secondary_Email__c = SECONDARY_EMAIL
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_PREFERENCES_ENCRYPTION_KEY))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PREFERENCES_ENCRYPTION_KEY,
                    Configuration_Value__c = ENCRYPTION_KEY_METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_PREFERENCES_PERSONA))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PREFERENCES_PERSONA,
                    Configuration_Value__c = PERSONA_METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        CassieIdEncryptionService.encryptCassieId(
            new List<Contact>{ contactRecord },
            'Email',
            'Email_Cassie_ID__c'
        );
        CassieIdEncryptionService.encryptCassieId(
            new List<Contact>{ contactRecord },
            'Secondary_Email__c',
            'Secondary_Email_Cassie_ID__c'
        );
        System.assertNotEquals(null, contactRecord.Email_Cassie_ID__c, ASSERT_MESSAGE);
        System.assertNotEquals(null, contactRecord.Secondary_Email_Cassie_ID__c, ASSERT_MESSAGE);
    }
    /**
     * @description To test the encryption of cassie id of lead.
     */
    @IsTest
    private static void testWhenEncryptCassieIdCalledThenLeadEmailCassieIdUpdated() {
        Lead leadRecord = new Lead(
            Id = fflib_IDGenerator.generate(Lead.SObjectType),
            Email = EMAIL
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_PREFERENCES_ENCRYPTION_KEY))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PREFERENCES_ENCRYPTION_KEY,
                    Configuration_Value__c = ENCRYPTION_KEY_METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_PREFERENCES_PERSONA))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PREFERENCES_PERSONA,
                    Configuration_Value__c = PERSONA_METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        CassieIdEncryptionService.encryptCassieId(
            new List<Lead>{ leadRecord },
            'Email',
            'Email_Cassie_ID__c'
        );
        System.assertNotEquals(null, leadRecord.Email_Cassie_ID__c, ASSERT_MESSAGE);
    }
}