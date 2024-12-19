/**
 * @author Deloitte
 * @date 05/31/2024
 * @description Test class for LeadConversionMappingServiceImpl class.
 */
@isTest(SeeAllData=false)
private class LeadConversionMappingServiceImplTest {
    private static final String ASSERT_MESSAGE = 'Unexpected Result: Mismatch in the size of the result';
    private static final String STATIC_RESOURCE_TEST_CSV = 'LeadConversionMappings';
    private static final String SOBJECT_ACCOUNT = 'Account';

    /**
     * @description This method is used to test if the fields for lead conversion is returned.
     */
    @isTest
    private static void testWhenCollectFieldsCalledThenReturnFields() {
        List<StaticResource> staticResourceList = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        Blob blobJSON = staticResourceList[0].Body;
        String[] fieldMappings = LeadConversionMappingService.collectFields(blobJSON);
        System.assertNotEquals(0, fieldMappings.size(), ASSERT_MESSAGE);
    }

    /**
     * @description This method is used to test if the fields for lead conversion is returned.
     */
    @isTest
    private static void testWhenCollectFieldsCalledThenDoNotReturnFields() {
        Blob blobJSON = null;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        String[] fieldMappings = LeadConversionMappingService.collectFields(blobJSON);
        System.assertEquals(null, fieldMappings, ASSERT_MESSAGE);
    }

    /**
     * @description This method is used to test if the field mapping for lead conversion is returned.
     */
    @isTest
    private static void testWhenCollectFieldValueMappingsCalledThenReturnConversionMappings() {
        List<StaticResource> staticResourceList = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        Blob blobJSON = staticResourceList[0].Body;
        String[] fieldMappings = LeadConversionMappingService.collectFields(blobJSON);
        Map<String, String> accountFieldToIsUpdatable = LeadConversionMappingService.collectFieldValueMappings(
            fieldMappings,
            SOBJECT_ACCOUNT
        );
        System.assertNotEquals(0, accountFieldToIsUpdatable.size(), ASSERT_MESSAGE);
    }
}