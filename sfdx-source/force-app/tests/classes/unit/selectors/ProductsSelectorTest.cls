/**
 * @author Aethereus
 * @date 03/06/2024
 * @description This is test class for ProductsSelector class
 */
@isTest(seeAllData=false)
public class ProductsSelectorTest {
    private static final String PRODUCT_NAME = 'Marketplace';
   /**
     * @description This is test method fetch product by product Name.
     */
    @isTest
    private static void testWhenProductNamePassedThenFetchProduct() {
        Product2 marketplaceProduct = ServiceIntegrationDataBuilder.createProductInstance(PRODUCT_NAME);
        insert marketplaceProduct;
        Set<string> productNameQueryData = new Set<string>{marketplaceProduct.Name};
        Test.startTest();
        List<Product2> productQueryData = ProductsSelector.newInstance()
            .selectProductByProductName(productNameQueryData);
        Test.stopTest();
        System.assertEquals(
            1,
            productQueryData.size(),
            'No records returned'
        );
    }
}