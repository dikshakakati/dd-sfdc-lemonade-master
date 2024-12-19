/**
 * @author DoorDash
 * @date 24/06/2022
 * @description Test class for DisplayQuoteLineAttributesController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest
public with sharing class DisplayQuoteLineAttributesControllerTest {
    private static final String PARENT_PRODUCT_CODE = '10012';
    private static final Integer DELIVERY_PRODUCT_LINE_NUMBER = 2;
    private static final String PARENT_PRODUCT_NAME = 'Large Order Fulfillment (LOF)';
    private static final String DELIVERY_PRODUCT_NAME = 'Delivery';

    @IsTest
    public static void testWhenProductCodeThenGetQuoteLineAttributes() {
        map<String, List<String>> optionalFields;
        map<String, List<String>> requiredFields;
        map<String, List<String>> activePrices;
        Id parentQLEProdId = fflib_IDGenerator.generate(
            Quote_Line_Drawer_Products__mdt.SObjectType
        );

        List<Quote_Line_Drawer_Attributes__mdt> qleAttributeList = new List<Quote_Line_Drawer_Attributes__mdt>{
            (Quote_Line_Drawer_Attributes__mdt) new Fake(Quote_Line_Drawer_Attributes__mdt.class)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Active__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c, null)
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_For_Product__c, false)
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c, 'Test_API_Name__c')
                .setField(Quote_Line_Drawer_Attributes__mdt.MasterLabel, 'Test_Label')
                .setField(Quote_Line_Drawer_Attributes__mdt.DeveloperName, 'Test_DeveName')
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_Label__c, 'Test_fieldLabel')
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
                    parentQLEProdId
                )
                .setParent(
                    'Quote_Line_Drawer_Products__r',
                    new Fake(Quote_Line_Drawer_Products__mdt.class)
                        .setField(Quote_Line_Drawer_Products__mdt.Id, parentQLEProdId)
                        .setField(Quote_Line_Drawer_Products__mdt.Is_Active__c, true)
                        .setField(Quote_Line_Drawer_Products__mdt.Product_Code__c, '11111')
                )
                .toSObject(),
            (Quote_Line_Drawer_Attributes__mdt) new Fake(Quote_Line_Drawer_Attributes__mdt.class)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Active__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Required__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_Packages__c, 'Package1')
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_For_Product__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c, 'Test_API_Name__c2')
                .setField(Quote_Line_Drawer_Attributes__mdt.MasterLabel, 'Test_Label2')
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_Label__c, 'Test_FieldDeveName_2')
                .setField(Quote_Line_Drawer_Attributes__mdt.DeveloperName, 'Test_DeveName2')
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
                    parentQLEProdId
                )
                .setParent(
                    'Quote_Line_Drawer_Products__r',
                    new Fake(Quote_Line_Drawer_Products__mdt.class)
                        .setField(Quote_Line_Drawer_Products__mdt.Id, parentQLEProdId)
                        .setField(Quote_Line_Drawer_Products__mdt.Is_Active__c, true)
                        .setField(Quote_Line_Drawer_Products__mdt.Product_Code__c, '11111')
                )
                .toSObject()
        };
        DisplayQuoteLineAttributesController.quoteAccountSegment = 'Enterprise';

        DisplayQuoteLineAttributesController.QuoteLineAttributesWrapper wrapVar = new DisplayQuoteLineAttributesController.QuoteLineAttributesWrapper(
            optionalFields,
            requiredFields,
            activePrices
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineDrawAttributesSelector qleAttributesMock = (IQuoteLineDrawAttributesSelector) mocks.mock(
            IQuoteLineDrawAttributesSelector.class
        );
        mocks.startStubbing();
        mocks.when(qleAttributesMock.sObjectType())
            .thenReturn(Quote_Line_Drawer_Attributes__mdt.SObjectType);
        mocks.when(qleAttributesMock.selectQLAttributesByProductCode('11111'))
            .thenReturn(qleAttributeList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(qleAttributesMock);
        Test.startTest();
        wrapVar = DisplayQuoteLineAttributesController.getQLProductsWithAttributes(
            '11111',
            '',
            'Enterprise'
        );
        Test.stopTest();

        System.assertEquals(
            wrapVar.requiredFields != null,
            true,
            'This product has QLE attributes'
        );
        System.assertEquals(
            wrapVar.requiredFields.values().size() > 0,
            true,
            'This product has required QLE attributes'
        );
        System.assertEquals(
            wrapVar.optionalFields.values().size() > 0,
            false,
            'This product has optional QLE attributes'
        );
    }

    @IsTest
    public static void testWhenProductPackageThenGetQuoteLineAttributes() {
        map<String, List<String>> optionalFields;
        map<String, List<String>> requiredFields;
        map<String, List<String>> activePrices;
        Id parentQLEProdId = fflib_IDGenerator.generate(
            Quote_Line_Drawer_Products__mdt.SObjectType
        );

        List<Quote_Line_Drawer_Attributes__mdt> qleAttributeList = new List<Quote_Line_Drawer_Attributes__mdt>{
            (Quote_Line_Drawer_Attributes__mdt) new Fake(Quote_Line_Drawer_Attributes__mdt.class)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Active__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c, null)
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Eligible_Packages__c,
                    'Package1; Package2'
                )
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_For_Product__c, false)
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c, 'Test_API_Name__c')
                .setField(Quote_Line_Drawer_Attributes__mdt.MasterLabel, 'Test_Label')
                .setField(Quote_Line_Drawer_Attributes__mdt.DeveloperName, 'Test_DeveName')
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_Label__c, 'Test_fieldLabel')
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
                    parentQLEProdId
                )
                .setParent(
                    'Quote_Line_Drawer_Products__r',
                    new Fake(Quote_Line_Drawer_Products__mdt.class)
                        .setField(Quote_Line_Drawer_Products__mdt.Id, parentQLEProdId)
                        .setField(Quote_Line_Drawer_Products__mdt.Is_Active__c, true)
                        .setField(Quote_Line_Drawer_Products__mdt.Product_Code__c, '11111')
                )
                .toSObject(),
            (Quote_Line_Drawer_Attributes__mdt) new Fake(Quote_Line_Drawer_Attributes__mdt.class)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Active__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Required__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_Packages__c, 'Package1')
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_For_Product__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c, 'Test_API_Name__c2')
                .setField(Quote_Line_Drawer_Attributes__mdt.MasterLabel, 'Test_Label2')
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_Label__c, 'Test_FieldDeveName_2')
                .setField(Quote_Line_Drawer_Attributes__mdt.DeveloperName, 'Test_DeveName2')
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
                    parentQLEProdId
                )
                .setParent(
                    'Quote_Line_Drawer_Products__r',
                    new Fake(Quote_Line_Drawer_Products__mdt.class)
                        .setField(Quote_Line_Drawer_Products__mdt.Id, parentQLEProdId)
                        .setField(Quote_Line_Drawer_Products__mdt.Is_Active__c, true)
                        .setField(Quote_Line_Drawer_Products__mdt.Product_Code__c, '11111')
                )
                .toSObject(),
            (Quote_Line_Drawer_Attributes__mdt) new Fake(Quote_Line_Drawer_Attributes__mdt.class)
                .setField(Quote_Line_Drawer_Attributes__mdt.Is_Active__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c, 'Enterprise')
                .setField(Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c, null)
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Eligible_Packages__c,
                    'Package1; Package2'
                )
                .setField(Quote_Line_Drawer_Attributes__mdt.Eligible_For_Product__c, true)
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c, 'Active_Fee__c')
                .setField(Quote_Line_Drawer_Attributes__mdt.MasterLabel, 'Test_Label3')
                .setField(Quote_Line_Drawer_Attributes__mdt.Field_Label__c, 'Test_FieldDeveName_3')
                .setField(Quote_Line_Drawer_Attributes__mdt.DeveloperName, 'Test_DeveName3')
                .setField(
                    Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
                    parentQLEProdId
                )
                .setParent(
                    'Quote_Line_Drawer_Products__r',
                    new Fake(Quote_Line_Drawer_Products__mdt.class)
                        .setField(Quote_Line_Drawer_Products__mdt.Id, parentQLEProdId)
                        .setField(Quote_Line_Drawer_Products__mdt.Is_Active__c, true)
                        .setField(Quote_Line_Drawer_Products__mdt.Product_Code__c, '11111')
                )
                .toSObject()
        };
        DisplayQuoteLineAttributesController.quoteAccountSegment = 'Enterprise';
        DisplayQuoteLineAttributesController.QuoteLineAttributesWrapper wrapVar = new DisplayQuoteLineAttributesController.QuoteLineAttributesWrapper(
            optionalFields,
            requiredFields,
            activePrices
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineDrawAttributesSelector qleAttributesMock = (IQuoteLineDrawAttributesSelector) mocks.mock(
            IQuoteLineDrawAttributesSelector.class
        );
        mocks.startStubbing();
        mocks.when(qleAttributesMock.sObjectType())
            .thenReturn(Quote_Line_Drawer_Attributes__mdt.SObjectType);
        mocks.when(qleAttributesMock.selectQLAttributesByProductCode('11111'))
            .thenReturn(qleAttributeList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(qleAttributesMock);
        Test.startTest();
        wrapVar = DisplayQuoteLineAttributesController.getQLProductsWithAttributes(
            '11111',
            'Package1',
            'Enterprise'
        );
        Test.stopTest();

        List<String> requiredfieldList = wrapVar.requiredFields.get('11111Package1');

        System.assertEquals(
            wrapVar.requiredFields != null,
            true,
            'This product has QLE attributes'
        );
        System.assertEquals(
            wrapVar.requiredFields.values().size() > 0,
            true,
            'This product has required QLE attributes'
        );
        System.assertEquals(
            requiredfieldList.size() > 0,
            true,
            'This product has required QLE attributes'
        );
        System.assertEquals(
            wrapVar.optionalFields.values().size() > 0,
            true,
            'This product has optional QLE attributes'
        );
        System.assertEquals(
            wrapVar.activePrices.values().size() > 0,
            true,
            'This product has active price QLE attributes'
        );
    }

    @IsTest
    public static void testWhenParentProductNotNullThenInsertParentProduct() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id productId1 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id quoteLineId1 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id quoteLineId2 = Fake.generateId(SBQQ__QuoteLine__c.class);
        set<string> productCode = new Set<string>();
        List<Product2> productList = new List<Product2>();

        Product2 product1 = (Product2) new Fake(Product2.class)
            .setField(Product2.Id, productId1)
            .setfield(Product2.Name, PARENT_PRODUCT_NAME)
            .setfield(Product2.ProductCode, PARENT_PRODUCT_CODE)
            .toSObject();
        productList.add(product1);

        SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineId1)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Product__c, productId1)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Number__c, 1)
            .setfield(SBQQ__QuoteLine__c.SBQQ__ProductName__c, PARENT_PRODUCT_NAME)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Group__c, groupId)
            .toSObject();

        SBQQ__QuoteLine__c quoteLine2 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineId2)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Product__c, productId1)
            .setfield(
                SBQQ__QuoteLine__c.SBQQ__ProductOption__c,
                Fake.generateId(SBQQ__ProductOption__c.class)
            )
            .setfield(SBQQ__QuoteLine__c.SBQQ__Number__c, DELIVERY_PRODUCT_LINE_NUMBER)
            .setfield(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, null)
            .setfield(SBQQ__QuoteLine__c.SBQQ__ProductName__c, DELIVERY_PRODUCT_NAME)
            .toSObject();

        List<SBQQ__Quoteline__c> listOfQuoteline = new List<SBQQ__Quoteline__c>();
        listOfQuoteline.add(quoteLine1);
        listOfQuoteline.add(quoteLine2);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IProductsSelector productsSelectorMock = (IProductsSelector) mocks.mock(
            IProductsSelector.class
        );
        mocks.startStubbing();
        mocks.when(productsSelectorMock.sObjectType()).thenReturn(Product2.SObjectType);
        mocks.when(
                productsSelectorMock.selectProductByProductName(
                    new Set<String>{ PARENT_PRODUCT_NAME }
                )
            )
            .thenReturn(productList);
        mocks.stopStubbing();
        Application.Selector.setMock(productsSelectorMock);
        DisplayQuoteLineAttributesController.insertParentProduct(
            quoteId,
            PARENT_PRODUCT_NAME,
            quoteLine2.Id,
            DELIVERY_PRODUCT_LINE_NUMBER,
            quoteLine2.SBQQ__RequiredBy__c,
            quoteLine1.SBQQ__Group__c
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        List<Product2> quoteLinesReturned = productsSelectorMock.selectProductByProductName(
            new Set<String>{ PARENT_PRODUCT_NAME }
        );
        System.assertEquals(1, quoteLinesReturned.size(), 'Product Not Available');
    }
}