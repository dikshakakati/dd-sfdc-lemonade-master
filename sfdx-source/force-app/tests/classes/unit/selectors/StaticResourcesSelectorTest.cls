/**
 * @author Deloitte
 * @date 05/03/2024
 * @description This is test class for StaticResourcesSelector class.
 */
@isTest(SeeAllData=false)
private class StaticResourcesSelectorTest {
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String STATIC_RESOURCE_NAME = 'McDonalds';
    private static final String FIELD_MAPPING = 'LeadToStoreAccountConversionMapping';
    private static final String INCORRECT_FIELD_MAPPING = 'LeadToBusinessAccountConversionMapping';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Static Resource.';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        StaticResourcesSelector staticResourceSelectorInstance = (StaticResourcesSelector) StaticResourcesSelector.newInstance();
        Schema.SObjectType typeOfObject = staticResourceSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = staticResourceSelectorInstance.getSObjectFieldList();
        StaticResource staticResourceInstance = [
            SELECT Id
            FROM StaticResource
            WHERE Name = :FIELD_MAPPING
        ];
        List<StaticResource> staticResources = new List<StaticResource>{ staticResourceInstance };
        System.assertEquals(staticResources.size(), 1, EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            Schema.StaticResource.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                StaticResource.Id,
                StaticResource.Body,
                StaticResource.Name
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Correct StaticResource is returned when queried by Name.
     */
    @isTest
    private static void testWhenNameMatchingThenReturnStaticResource() {
        Test.startTest();
        List<StaticResource> staticResources = StaticResourcesSelector.newInstance()
            .selectByName(FIELD_MAPPING);
        Test.stopTest();
        System.assertEquals(staticResources.size(), 1, EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test no StaticResource is returned when queried by incorrect Name.
     */
    @isTest
    private static void testWhenNameNotMatchingThenStaticResourceNotReturned() {
        Test.startTest();
        List<StaticResource> staticResources = StaticResourcesSelector.newInstance()
            .selectByName(INCORRECT_FIELD_MAPPING);
        Test.stopTest();
        System.assertEquals(staticResources.size(), 0, EMPTY_LIST_ASSERT_MESSAGE);
    }
}