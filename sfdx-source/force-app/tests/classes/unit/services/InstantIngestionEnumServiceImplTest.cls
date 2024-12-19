/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestionEnumMappingsServiceImpl.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InstantIngestionEnumServiceImplTest {
    private static final String EMAIL = 'Email';
    private static final String FAX = 'Fax';
    private static final String LOCATIONS_TWENTY_THREE = '23';
    private static final String LOCATIONS_TEN = '10';
    private static final String FOODTRUCK = 'Food Truck';
    private static final String INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final String LOCATIONS_ONE = '1';
    private static final String MERCHANT_TYPE_BRICK_MORTAR = 'Brick and Mortar';
    private static final String MERCHANT_TYPE_FOODTRUCK = 'MERCHANT_TYPE_FOODTRUCK';
    private static final String MERCHANT_TYPE_LOCAL = 'MERCHANT_TYPE_LOCAL';
    private static final String MERCHANT_TYPE_VIRTUAL = 'MERCHANT_TYPE_VIRTUAL';
    private static final String MERCHANTTYPE_VIRTUAL = 'Virtual';
    private static final String NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY = 'NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY';
    private static final String NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN = 'NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN';
    private static final String NUMBER_OF_LOCATIONS_ONE = 'NUMBER_OF_LOCATIONS_ONE';
    private static final String NUMBER_OF_LOCATIONS_ONE_TO_FIVE = 'NUMBER_OF_LOCATIONS_ONE_TO_FIVE';
    private static final String NUMBER_OF_LOCATIONS_THIRTY_PLUS = 'NUMBER_OF_LOCATIONS_THIRTY_PLUS';
    private static final String NUMBER_OF_LOCATIONS_TWO_TO_FIVE = 'NUMBER_OF_LOCATIONS_TWO_TO_FIVE';
    private static final String NUMBER_OF_LOCATIONS_UNSPECIFIED = 'NUMBER_OF_LOCATIONS_UNSPECIFIED';
    private static final String TWO = '2';
    private static final String OPTIONAL_BANKING = 'OPTIONAL_BANKING';
    private static final String ORDER_PROTOCOL_EMAIL = 'ORDER_PROTOCOL_EMAIL';
    private static final String ORDER_PROTOCOL_FAX = 'ORDER_PROTOCOL_FAX';
    private static final String ORDER_PROTOCOL_INDICATOR_UNSPECIFIED = 'ORDER_PROTOCOL_INDICATOR_UNSPECIFIED';
    private static final String ORDER_PROTOCOL_TABLET = 'ORDER_PROTOCOL_TABLET';
    private static final String ORDER_PROTOCOL_TABLET_PRINTER = 'ORDER_PROTOCOL_TABLET_PRINTER';
    private static final String OTHER = 'Other';
    private static final String PRIMARY_VERTICAL_FLORAL = 'Floral';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String SINGULARITY = 'SINGULARITY';
    private static final String LOCATIONS_THIRTY_PLUS = '30';
    private static final String TABLET = 'Tablet (DoorDash Owns)';
    private static final String TABLET_PRINTER = 'Tablet and Printer (DoorDash Owns)';
    private static final String TREATMENT_GROUP_STRIPE_FC = 'Stripe FC';
    private static final String TREATMENT_GROUP_AUTO_RUN_ADS = 'Auto Run Ads';
    private static final String TREATMENT_GROUP_OPTIONAL_BANKING = 'Optional Banking Enabled';
    private static final String TREATMENT_GROUP_SINGULARITY = 'Singularity';
    private static final String TREATMENT_GROUP_SINGULARITY_2 = 'Singularity_2';
    private static final String TREATMENT_GROUP_TYPE_AUTO_RUN = 'AUTO_RUN_ADS';
    private static final String TREATMENT_GROUP_TYPE_SINGULARITY_2 = 'SINGULARITY_2';
    private static final String TREATMENT_GROUP_TYPE_STRIPE_FC = 'STRIPE_FC';
    private static final String UNSPECIFIED = '0';
    private static final String VERTICAL_TYPE_FLOWERS = 'VERTICAL_TYPE_FLOWERS';
    private static final String VERTICAL_TYPE_UNSPECIFIED = 'VERTICAL_TYPE_UNSPECIFIED';
    private static final String LOCATIONS_THREE = '3';

    /**
     * @description It is used to test when Primary Vertical received from the payload then it
     * get Primary Vertical Value.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPrimaryVerticalReceivedInPayloadThenReturnCorrespondingPrimaryVerticalValue() {
        Test.startTest();
        String returnPrimaryVerticalRx = InstantIngestionEnumMappingsService.getPrimaryVertical(
            VERTICAL_TYPE_UNSPECIFIED
        );
        String returnPrimaryVerticalFloral = InstantIngestionEnumMappingsService.getPrimaryVertical(
            VERTICAL_TYPE_FLOWERS
        );
        Test.stopTest();
        System.assertEquals(returnPrimaryVerticalRx, PRIMARY_VERTICAL_RX, INVALID_ASSERT_MESSAGE);
        System.assertEquals(
            returnPrimaryVerticalFloral,
            PRIMARY_VERTICAL_FLORAL,
            INVALID_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used to test when Order Protocol received from the payload then it get Order Protocol Value.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderProtocolReceivedInPayloadThenReturnCorrespondingOrderProtocolValue() {
        Test.startTest();
        String returnOrderProtocolother = InstantIngestionEnumMappingsService.getOrderProtocol(
            ORDER_PROTOCOL_INDICATOR_UNSPECIFIED
        );
        String returnOrderProtocolTablet = InstantIngestionEnumMappingsService.getOrderProtocol(
            ORDER_PROTOCOL_TABLET
        );
        String returnOrderProtocolPrinter = InstantIngestionEnumMappingsService.getOrderProtocol(
            ORDER_PROTOCOL_TABLET_PRINTER
        );
        String returnOrderProtocolEmail = InstantIngestionEnumMappingsService.getOrderProtocol(
            ORDER_PROTOCOL_EMAIL
        );
        String returnOrderProtocolFax = InstantIngestionEnumMappingsService.getOrderProtocol(
            ORDER_PROTOCOL_FAX
        );
        Test.stopTest();
        System.assertEquals(returnOrderProtocolother, OTHER, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnOrderProtocolTablet, TABLET, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnOrderProtocolPrinter, TABLET_PRINTER, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnOrderProtocolEmail, EMAIL, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnOrderProtocolFax, FAX, INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test when Store Type received from the payload then it get Store Type Value.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreTypeReceivedInPayloadThenReturnCorrespondingStoreTypeValue() {
        Test.startTest();
        String returnStoreTypeBrick = InstantIngestionEnumMappingsService.getStoreType(
            MERCHANT_TYPE_LOCAL
        );
        String returnStoreTypeVirtual = InstantIngestionEnumMappingsService.getStoreType(
            MERCHANT_TYPE_VIRTUAL
        );
        String returnStoreTypeFoodTruck = InstantIngestionEnumMappingsService.getStoreType(
            MERCHANT_TYPE_FOODTRUCK
        );
        Test.stopTest();
        System.assertEquals(
            returnStoreTypeBrick,
            MERCHANT_TYPE_BRICK_MORTAR,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(returnStoreTypeVirtual, MERCHANTTYPE_VIRTUAL, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnStoreTypeFoodTruck, FOODTRUCK, INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test when Treatment Group received from the payload then it get Treatment Group Details.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTreatmentGroupReceivedInPayloadThenReturnCorrespondingTreatmentGroupValue() {
        Test.startTest();
        String returnTreatmentGroupSingularity = InstantIngestionEnumMappingsService.getTreatmentGroup(
            SINGULARITY
        );
        String returnTreatmentGroupSingularityDetail = InstantIngestionEnumMappingsService.getTreatmentGroup(
            TREATMENT_GROUP_TYPE_SINGULARITY_2
        );
        String returnTreatmentGroupOptional = InstantIngestionEnumMappingsService.getTreatmentGroup(
            OPTIONAL_BANKING
        );
        String returnTreatmentGroupAuto = InstantIngestionEnumMappingsService.getTreatmentGroup(
            TREATMENT_GROUP_TYPE_AUTO_RUN
        );
        String returnTreatmentGroupStripe = InstantIngestionEnumMappingsService.getTreatmentGroup(
            TREATMENT_GROUP_TYPE_STRIPE_FC
        );
        Test.stopTest();
        System.assertEquals(
            returnTreatmentGroupSingularity,
            TREATMENT_GROUP_SINGULARITY,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(
            returnTreatmentGroupSingularityDetail,
            TREATMENT_GROUP_SINGULARITY_2,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(
            returnTreatmentGroupOptional,
            TREATMENT_GROUP_OPTIONAL_BANKING,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(
            returnTreatmentGroupAuto,
            TREATMENT_GROUP_AUTO_RUN_ADS,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(
            returnTreatmentGroupStripe,
            TREATMENT_GROUP_STRIPE_FC,
            INVALID_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used to test when Estimated Store received from the payload then it get Estimated Store Value.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEstimatedStoreReceivedInPayloadThenReturnCorrespondingEstimatedStoreValue() {
        Test.startTest();
        String returnEstimatedStoreUnspecified = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_UNSPECIFIED
        );
        String returnEstimatedStoreOne = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_ONE
        );
        String returnEstimatedStoreOneToFive = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_ONE_TO_FIVE
        );
        String returnEstimatedStoretwo = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_TWO_TO_FIVE
        );
        String returnEstimatedStoreFive = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_FIVE_TO_FIFTEEN
        );
        String returnEstimatedStoreFifteen = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_FIFTEEN_TO_THIRTY
        );
        String returnEstimatedStoreThirty = InstantIngestionEnumMappingsService.getEstimatedStore(
            NUMBER_OF_LOCATIONS_THIRTY_PLUS
        );
        Test.stopTest();
        System.assertEquals(returnEstimatedStoreUnspecified, UNSPECIFIED, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnEstimatedStoreOne, LOCATIONS_ONE, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnEstimatedStoreOneToFive, TWO, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnEstimatedStoretwo, LOCATIONS_THREE, INVALID_ASSERT_MESSAGE);
        System.assertEquals(returnEstimatedStoreFive, LOCATIONS_TEN, INVALID_ASSERT_MESSAGE);
        System.assertEquals(
            returnEstimatedStoreFifteen,
            LOCATIONS_TWENTY_THREE,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(
            returnEstimatedStoreThirty,
            LOCATIONS_THIRTY_PLUS,
            INVALID_ASSERT_MESSAGE
        );
    }
}