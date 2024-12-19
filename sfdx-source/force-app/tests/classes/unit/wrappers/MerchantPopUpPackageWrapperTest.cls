/**
 * @author Deloitte
 * @description Test Class For MerchantPopUpPackageWrapper
 * Date 05/08/2024
 */
@IsTest
private class MerchantPopUpPackageWrapperTest {
    @isTest
    static void testWhenStringIsPassedThenReturnDeserializedValues() {
        String jsonString = '{"packageDetails":[{"packageName":"Marketplace","products":"Dashpass,Delivery"},{"packageName":"Storefront","products":""}]}';
        MerchantPopUpPackageWrapper wrappers = (MerchantPopUpPackageWrapper) JSON.deserialize(
            jsonString,
            MerchantPopUpPackageWrapper.class
        );

        System.assertEquals(2, wrappers.packageDetails.size(), 'deserialized as expected');
    }
}