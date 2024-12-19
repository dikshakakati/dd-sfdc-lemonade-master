/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Test class to test pricing program against Merchant Services.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
private class PricingProgramsServiceImplTest {
    /**
     * @description It is used to test the matching between pricing programs and services.
     */
    @isTest
    private static void testWhenServicesAndPricingProgramsSentThenMatchResultReturned() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetPricingPrograms mockPricingProgram = new ActivationChecklistWrapper.GetPricingPrograms();
        ActivationChecklistWrapper.GetProducts mockProducts = new ActivationChecklistWrapper.GetProducts();
        mockProducts.audience = 'ANY_AUDIENCE';
        mockProducts.fulfillmentType = 'DELIVERY';
        ActivationChecklistWrapper.GetPricing mockPricing = new ActivationChecklistWrapper.GetPricing();
        ActivationChecklistWrapper.FeeAttributes mockFeeAtrribute = new ActivationChecklistWrapper.FeeAttributes();
        mockFeeAtrribute.feeRate = 6.00;
        mockFeeAtrribute.feeType = 'COMMISSION';
        mockPricing.feeAttributesInformation = new List<ActivationChecklistWrapper.FeeAttributes>{
            mockFeeAtrribute
        };

        mockPricingProgram.productInformation = mockProducts;
        mockPricingProgram.pricingInformation = mockPricing;
        mockPricingProgram.isActive = true;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        mockActivationChecklistData.pricingPrograms = new List<ActivationChecklistWrapper.GetPricingPrograms>{
            mockPricingProgram
        };

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                'Rx'
            )
            .setField(Account.ParentId, parentAccountId)
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class)
                        .setField(Merchant_Service__c.Name, 'Delivery')
                        .setField(Merchant_Service__c.Final_commission__c, 6)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake serviceInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Name, 'Delivery')
            .setField(Merchant_Service__c.Final_commission__c, 6.00)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setField(Merchant_Service__c.Active__c, 'Yes')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', storeAccountFakeInstance)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class).setField(OrderItem.Fee_Type__c, 'COMMISSION')
            );
        Merchant_Service__c service = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            serviceInstance
        );

        Test.startTest();
        Boolean result = PricingProgramsService.getServiceToPricingProgramMapping(
            new List<Merchant_Service__c>{ service },
            new List<ActivationChecklistWrapper.GetPricingPrograms>{ mockPricingProgram }
        );
        Test.stopTest();
        System.assertEquals(true, result, 'Incorrect Request');
    }

    /**
     * @description It is used to test the matching between pricing programs and services
     */
    @isTest
    private static void testWhenServicesAndPricingProgramsSentThenMatchFailureResultReturned() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id orderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetPricingPrograms mockPricingProgram = new ActivationChecklistWrapper.GetPricingPrograms();
        ActivationChecklistWrapper.GetProducts mockProducts = new ActivationChecklistWrapper.GetProducts();
        mockProducts.audience = 'ANY_AUDIENCE';
        mockProducts.fulfillmentType = 'DELIVERY';
        ActivationChecklistWrapper.GetPricing mockPricing = new ActivationChecklistWrapper.GetPricing();
        ActivationChecklistWrapper.FeeAttributes mockFeeAtrribute = new ActivationChecklistWrapper.FeeAttributes();
        mockFeeAtrribute.feeRate = 9.00;
        mockFeeAtrribute.feeType = 'COMMISSION';
        mockPricing.feeAttributesInformation = new List<ActivationChecklistWrapper.FeeAttributes>{
            mockFeeAtrribute
        };

        mockPricingProgram.productInformation = mockProducts;
        mockPricingProgram.pricingInformation = mockPricing;
        mockPricingProgram.isActive = true;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        mockActivationChecklistData.pricingPrograms = new List<ActivationChecklistWrapper.GetPricingPrograms>{
            mockPricingProgram
        };

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                'Rx'
            )
            .setField(Account.ParentId, parentAccountId)
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class)
                        .setField(Merchant_Service__c.Name, 'Delivery')
                        .setField(Merchant_Service__c.Final_commission__c, 6)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake serviceInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Name, 'Delivery')
            .setField(Merchant_Service__c.Final_commission__c, 10.00)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setField(Merchant_Service__c.Active__c, 'Yes')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setField(Merchant_Service__c.Order_Product__c, orderItemId)
            .setParent('Account__r', storeAccountFakeInstance)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId)
                    .setField(OrderItem.Fee_Type__c, 'COMMISSION')
            );
        Merchant_Service__c service = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            serviceInstance
        );

        Test.startTest();
        Boolean result = PricingProgramsService.getServiceToPricingProgramMapping(
            new List<Merchant_Service__c>{ service },
            new List<ActivationChecklistWrapper.GetPricingPrograms>{ mockPricingProgram }
        );
        Test.stopTest();
        System.assertEquals(false, result, 'Incorrect Request');
    }

    /**
     * @description It is used to test the matching between pricing programs and services.
     */
    @isTest
    private static void testWhenDashPassServicesAndPricingProgramsSentThenMatchResultReturned() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetPricingPrograms mockPricingProgram = new ActivationChecklistWrapper.GetPricingPrograms();
        ActivationChecklistWrapper.GetProducts mockProducts = new ActivationChecklistWrapper.GetProducts();
        mockProducts.audience = 'SUBSCRIBER';
        mockProducts.fulfillmentType = 'DELIVERY';
        ActivationChecklistWrapper.GetPricing mockPricing = new ActivationChecklistWrapper.GetPricing();
        ActivationChecklistWrapper.FeeAttributes mockFeeAtrribute = new ActivationChecklistWrapper.FeeAttributes();
        mockFeeAtrribute.feeRate = 6.00;
        mockFeeAtrribute.feeType = 'FEE';
        mockPricing.feeAttributesInformation = new List<ActivationChecklistWrapper.FeeAttributes>{
            mockFeeAtrribute
        };

        mockPricingProgram.productInformation = mockProducts;
        mockPricingProgram.pricingInformation = mockPricing;
        mockPricingProgram.isActive = true;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        mockActivationChecklistData.pricingPrograms = new List<ActivationChecklistWrapper.GetPricingPrograms>{
            mockPricingProgram
        };

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                'Rx'
            )
            .setField(Account.ParentId, parentAccountId)
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class)
                        .setField(Merchant_Service__c.Name, 'Dashpass')
                        .setField(Merchant_Service__c.Final_commission__c, 6)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake serviceInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Name, 'Dashpass')
            .setField(Merchant_Service__c.Final_commission__c, 6.00)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setField(Merchant_Service__c.Active__c, 'Yes')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', storeAccountFakeInstance)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class).setField(OrderItem.Fee_Type__c, 'FEE')
            );
        Merchant_Service__c service = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            serviceInstance
        );

        Test.startTest();
        Boolean result = PricingProgramsService.getServiceToPricingProgramMapping(
            new List<Merchant_Service__c>{ service },
            new List<ActivationChecklistWrapper.GetPricingPrograms>{ mockPricingProgram }
        );
        Test.stopTest();
        System.assertEquals(true, result, 'Incorrect Request');
    }

    /**
     * @description It is used to test the matching between pricing programs and services.
     */
    @isTest
    private static void testWhenDashPassServicesAndPricingProgramsSentThenMatchFailureResultReturned() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id orderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        ActivationChecklistWrapper mockActivationChecklistData = new ActivationChecklistWrapper(
            123,
            'test',
            'test',
            'test',
            String.valueOf(workStepId)
        );
        ActivationChecklistWrapper.GetPricingPrograms mockPricingProgram = new ActivationChecklistWrapper.GetPricingPrograms();
        ActivationChecklistWrapper.GetBusinessDetails businessProgram = new ActivationChecklistWrapper.GetBusinessDetails(
            'test',
            'test',
            'test',
            'test',
            'test'
        );
        ActivationChecklistWrapper.GetProducts mockProducts = new ActivationChecklistWrapper.GetProducts();
        mockProducts.audience = 'SUBSCRIBER';
        mockProducts.fulfillmentType = 'DELIVERY';
        ActivationChecklistWrapper.GetPricing mockPricing = new ActivationChecklistWrapper.GetPricing();
        ActivationChecklistWrapper.GetStore mockStore = new ActivationChecklistWrapper.GetStore();
        ActivationChecklistWrapper.FeeAttributes mockFeeAtrribute = new ActivationChecklistWrapper.FeeAttributes();
        mockFeeAtrribute.flatFee = 10.00;
        mockFeeAtrribute.feeType = 'FEE';
        mockPricing.feeAttributesInformation = new List<ActivationChecklistWrapper.FeeAttributes>{
            mockFeeAtrribute
        };
        mockActivationChecklistData.businessInformation = businessProgram;
        mockPricingProgram.productInformation = mockProducts;
        mockPricingProgram.pricingInformation = mockPricing;
        mockPricingProgram.isActive = true;
        mockActivationChecklistData.storeInformation = mockStore;
        mockActivationChecklistData.workStepSalesforceId = String.valueOf(workStepId);

        mockActivationChecklistData.pricingPrograms = new List<ActivationChecklistWrapper.GetPricingPrograms>{
            mockPricingProgram
        };

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccountId,
                'Rx'
            )
            .setField(Account.ParentId, parentAccountId)
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class)
                        .setField(Merchant_Service__c.Name, 'Dashpass')
                        .setField(Merchant_Service__c.Final_Fee__c, 6)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake serviceInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Name, 'Dashpass')
            .setField(Merchant_Service__c.Final_Fee__c, 9.00)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setField(Merchant_Service__c.Active__c, 'Yes')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setField(Merchant_Service__c.Order_Product__c, orderItemId)
            .setParent('Account__r', storeAccountFakeInstance)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId)
                    .setField(OrderItem.Fee_Type__c, 'FEE')
            );
        Merchant_Service__c service = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            serviceInstance
        );

        Test.startTest();
        Boolean result = PricingProgramsService.getServiceToPricingProgramMapping(
            new List<Merchant_Service__c>{ service },
            new List<ActivationChecklistWrapper.GetPricingPrograms>{ mockPricingProgram }
        );
        Test.stopTest();
        System.assertEquals(false, result, 'Incorrect Request');
    }
}