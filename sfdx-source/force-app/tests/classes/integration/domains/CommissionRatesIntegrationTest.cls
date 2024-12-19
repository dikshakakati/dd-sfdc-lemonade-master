/**
 * @author Deloitte
 * @date 26/04/2024
 * @description Integration Test for CommissionRates Domain.
 */
@isTest
private class CommissionRatesIntegrationTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_RX = 'Rx';
    private static final String CURRENCY_ISO_CODE_USD = 'USD';
    private static final String CURRENCY_ISO_CODE_CAD = 'CAD';
    private static final String INVALID_ASSERTION = 'Invalid Data';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String PRODUCT_NAME_DELIVERY = 'Delivery';

    /**
     * @description It is used to check whether a search key is generated when commission rates are
     * inserted.
     */
    @isTest
    private static void testWhenCommissionRatesInsertedThenSearchKeyGenerated() {
        Product2 marketplacePackageProduct = CPQTestDataFactory.createProduct(false);
        marketplacePackageProduct.Name = PRODUCT_NAME_MARKETPLACE;
        marketplacePackageProduct.Family = PRODUCT_NAME_MARKETPLACE;
        insert marketplacePackageProduct;

        Product2 deliveryProduct = CPQTestDataFactory.createProduct(false);
        deliveryProduct.Name = PRODUCT_NAME_DELIVERY;
        insert deliveryProduct;

        List<Commission_Rate__c > commissionRateRecords = new List< Commission_Rate__c >{
            new Commission_Rate__c(Start__c = Date.today() - 30,
                End__c = System.today() + 40,
                Package__c = marketplacePackageProduct.Id,
                Product__c = deliveryProduct.Id,
                Account_Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_RX,
                Submarket__c = null,
                CurrencyIsoCode = CURRENCY_ISO_CODE_USD
            ),
            new Commission_Rate__c(Start__c = Date.today() - 30,
                End__c = System.today() + 40,
                Package__c = marketplacePackageProduct.Id,
                Product__c = deliveryProduct.Id,
                Account_Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_RX,
                Submarket__c = null,
                CurrencyIsoCode = CURRENCY_ISO_CODE_CAD
           )
        };
        Test.startTest();
        insert commissionRateRecords;
        Test.stopTest();
        List<Commission_Rate__c> commissionRates = [
            SELECT Id, Name, Search_Key__c
            FROM Commission_Rate__c
            WHERE Id = :commissionRateRecords[0].Id
        ];
        System.assertEquals(
            commissionRateRecords[0].Id,
            commissionRates[0].Id,
            INVALID_ASSERTION
        );
        System.assertEquals(
            commissionRates[0].Search_Key__c,
            deliveryProduct.Id+''+marketplacePackageProduct.Id+''+CURRENCY_ISO_CODE_USD+''+ACCOUNT_PRIMARY_VERTICAL_RX,
            INVALID_ASSERTION
        );
    }
}
