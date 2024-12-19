/**
 * @author Deloitte
 * @date 29/07/2022
 * @description Test class for EncryptedFieldsConfigurationsSelector class.
 */
@isTest(seeAllData=false)
private class EncryptedFieldsConfigurationsSelectTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Encrypted Fields Configuartions Metadata';
    private static final String METADATA_COMPONENT_LOCATION = 'Contact';
    private static final String METADATA_DEV_NAME = 'Contact_Encrypted_Fields';
    private static final String METADATA_FIELD_SET_NAME = 'Encrypted_Fields';
    private static final String METADATA_MASTER_LABEL = 'Contact_Encrypted_Fields';
    private static final String METADATA_OBJECT_NAME = 'Contact';

    /**
     * @description To test query on Encrypted Fields Configurations when component location is passed.
     */
    @isTest
    private static void testWhenSelectByTypeMethodsCalledThenReturnAppropriateValues() {
        List<Encrypted_Fields_Configuration__mdt> customMetadataMocks = new List<Encrypted_Fields_Configuration__mdt>{
            new Encrypted_Fields_Configuration__mdt(
                MasterLabel = METADATA_MASTER_LABEL,
                Component_Location__c = METADATA_COMPONENT_LOCATION,
                DeveloperName = METADATA_DEV_NAME,
                FieldSet_Name__c = METADATA_FIELD_SET_NAME,
                Object_Api_Name__c = METADATA_OBJECT_NAME
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        EncryptedFieldsConfigurationsSelector mockEncryptedFieldsConfiguration = (EncryptedFieldsConfigurationsSelector) mocks.mock(
            EncryptedFieldsConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockEncryptedFieldsConfiguration.getSObjectType())
            .thenReturn(Encrypted_Fields_Configuration__mdt.SObjectType);
        mocks.when(
                mockEncryptedFieldsConfiguration.selectByComponetLocationAndObjectApiName(
                    METADATA_COMPONENT_LOCATION
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockEncryptedFieldsConfiguration);
        Schema.SObjectType typeOfObject = EncryptedFieldsConfigurationsSelector.newInstance()
            .SObjectType();
        List<Encrypted_Fields_Configuration__mdt> encryptedFieldsConfigurations = EncryptedFieldsConfigurationsSelector.newInstance()
            .selectByComponetLocationAndObjectApiName(METADATA_COMPONENT_LOCATION);
        System.assertEquals(
            Encrypted_Fields_Configuration__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            !encryptedFieldsConfigurations.isEmpty(),
            true,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
    }
}