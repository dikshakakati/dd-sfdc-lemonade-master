/**
 * @author Deloitte
 * @date 2024/04/12
 * @description Test class for CommissionRates
 */
@isTest(SeeAllData = false)
private class CommissionRatesTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';

    /**
     * @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Commission_Rate__c> commissionRateRecords = new List<Commission_Rate__c>();
        CommissionRates.newInstance(commissionRateRecords);
        CommissionRates responsesObject = new CommissionRates(commissionRateRecords);
        CommissionRates.Constructor constructorObject = new CommissionRates.Constructor();
        constructorObject.construct(commissionRateRecords);
        System.assertNotEquals(
            CommissionRates.newInstance(commissionRateRecords),
            responsesObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description Test for Search Key generation
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCommissionRateIsUpdatedThenSearchKeyIsAssigned() {
        Id marketplaceProductId = Fake.generateId(Product2.class);
        Id deliveryProductId = Fake.generateId(Product2.class);
        Id marketplaceCommissionRateId = Fake.generateId(Commission_Rate__c.class);
        List<Commission_Rate__c> commissionRateRecords = new List<Commission_Rate__c>{
            (Commission_Rate__c) new Fake(Commission_Rate__c.class)
                .setField(Commission_Rate__c.Id, marketplaceCommissionRateId)
                .setField(Commission_Rate__c.Start__c, Date.today() - 30)
                .setField(Commission_Rate__c.End__c, System.today() + 40)
                .setField(Commission_Rate__c.Package__c, marketplaceProductId)
                .setField(Commission_Rate__c.Product__c, deliveryProductId)
                .setField(Commission_Rate__c.Account_Primary_Vertical__c, 'Rx')
                .setField(Commission_Rate__c.CurrencyIsoCode, 'USD')
                .toSobject(),
            (Commission_Rate__c) new Fake(Commission_Rate__c.class)
                .setField(Commission_Rate__c.Id, marketplaceCommissionRateId)
                .setField(Commission_Rate__c.Package__c, marketplaceProductId)
                .setField(Commission_Rate__c.Product__c, deliveryProductId)
                .setField(Commission_Rate__c.Account_Primary_Vertical__c, 'Rx')
                .setField(Commission_Rate__c.CurrencyIsoCode, 'USD')
                .toSobject()
        };
        CommissionRates.newInstance(commissionRateRecords).generateSearchKey();
    }

    /**
     * @description Test for not creating Search Key
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCommissionRateIsUpdatedThenSearchKeyIsNotAssigned() {
        Id marketplaceProductId = Fake.generateId(Product2.class);
        Id deliveryProductId = Fake.generateId(Product2.class);
        Id marketplaceCommissionRateId = Fake.generateId(Commission_Rate__c.class);
        Id marketplaceSubmarket = Fake.generateId(Submarket__c.class);
        List<Commission_Rate__c> commissionRateRecords = new List<Commission_Rate__c>{
            (Commission_Rate__c) new Fake(Commission_Rate__c.class)
                .setField(Commission_Rate__c.Id, marketplaceCommissionRateId)
                .setField(Commission_Rate__c.Start__c, Date.today() - 30)
                .setField(Commission_Rate__c.End__c, System.today() + 40)
                .setField(Commission_Rate__c.Package__c, marketplaceProductId)
                .setField(Commission_Rate__c.Product__c, deliveryProductId)
                .setField(Commission_Rate__c.Account_Primary_Vertical__c, null)
                .setField(Commission_Rate__c.Submarket__c, marketplaceSubmarket)
                .setField(Commission_Rate__c.CurrencyIsoCode, 'USD')
                .toSobject()
        };
        CommissionRates.newInstance(commissionRateRecords).generateSearchKey();
    }
}