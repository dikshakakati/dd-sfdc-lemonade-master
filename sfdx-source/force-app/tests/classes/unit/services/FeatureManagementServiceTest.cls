@isTest
private class FeatureManagementServiceTest {
    @isTest
    private static void testWhenAllServiceClassMethodsCalledThenReturnAppropriateValues() {
        String customPermissionName = 'Bypass_Trigger';

        IFeatureManagementService featureInstance = FeatureManagementService.newInstance();
        Test.startTest();
        Boolean hasPermission = featureInstance.checkPermission(customPermissionName);
        Test.stopTest();

        System.assertEquals(
            false,
            hasPermission,
            'Unexpected Error: Mismatch of custom permission'
        );
    }
}