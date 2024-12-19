/**
 * @author Deloitte
 * @date 11/15/2022
 * @description Test class to check if Opportunity Line Items are queried appropriately.
 */
@isTest(SeeAllData=false)
private class OpportunityLineItemsSelectorTest {
    private static final String ASSERT_MESSAGE_AGGREGATE_SIZE = 'Unexpected result: size of aggregate returned does not match';
    private static final String CURRENCY_USD = 'USD';
    private static final String OPPORTUNITY_NAME = 'Opportunity Test';
    private static final String OPPORTUNITY_STAGE_NEEDS_ANALYSIS = 'Needs Analysis';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String PRODUCT_FAMILY_ADVERTISEMENT = 'Advertisement';
    private static final String PRODUCT_NAME_DRIVE = 'Drive';
    private static final String PRODUCT_NAME_DRIVE_PROMOTIONS = 'Drive Promotions';
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        OpportunityLineItemsSelector lineItemSelectorInstance = new OpportunityLineItemsSelector();

        Schema.SObjectType typeOfObj = lineItemSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = lineItemSelectorInstance.getSObjectFieldList();

        OpportunityContactRoleSelector.newInstance();
        System.assertEquals(
            Schema.OpportunityLineItem.SObjectType,
            typeOfObj,
            'The object type must be OpportunityLineItem'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ OpportunityLineItem.Id, OpportunityLineItem.Product2Id },
            fieldList,
            'Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenOppIdIsSentThenReturnContractSignatoryContactRoles() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2',Segment__c = 'Enterprise')
        };
        insert accountList;

        Product2 newProduct = new Product2(Name = 'Drive Promotions', Family = 'Advertisement');
        insert newProduct;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(newProduct, 'USD', true);

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Deal_Type__c= 'Standard',
                Opportunity_Sub_Type__c= 'Former Partner',
                Pricebook2Id = pricebookId
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Deal_Type__c= 'Standard',
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        OpportunityLineItem newLineItem = new OpportunityLineItem();
        newLineItem.OpportunityId = opportunityList[0].Id;
        newLineItem.PricebookEntryId = pbe.Id;
        newLineItem.Product2Id = newProduct.Id;
        newLineItem.Quantity = 1;
        newLineItem.UnitPrice = 1;
        insert newLineItem;

        OpportunityLineItemsSelector lineItemSelectorInstance = new OpportunityLineItemsSelector();
        List<OpportunityLineItem> lineItemList = lineItemSelectorInstance.selectByOpportunities(
            new Set<Id>{ opportunityList[0].Id }
        );
        OpportunityLineItemsSelector.newInstance();
        System.assertEquals(lineItemList.size(), 1, 'OpportunityLineItem List Empty');
    }

    /**
     * @description To test aggregate selection of Opportunity Products grouped by Opportunity Id
     * and Product Family based on the passed Opportunity Ids.
     */
    @isTest
    private static void testWhenOpportunityIdsPassedThenReturnOpportunityProductGroupedByOpportunityIdAndProductFamily() {
        Account account = new Account(Name = PARENT_ACCOUNT_NAME, Segment__c = 'Enterprise');
        insert account;
        List<Product2> products = new List<Product2>{
            new Product2(
                Name = PRODUCT_NAME_DRIVE_PROMOTIONS,
                Family = PRODUCT_FAMILY_ADVERTISEMENT
            ),
            new Product2(Name = PRODUCT_NAME_DRIVE, Family = PRODUCT_NAME_DRIVE)
        };
        insert products;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;
        PricebookEntry advertisementProductEntry = CPQTestDataFactory.createPriceBookEntry(
            products[0],
            CURRENCY_USD,
            true
        );
        PricebookEntry driveProductEntry = CPQTestDataFactory.createPriceBookEntry(
            products[1],
            CURRENCY_USD,
            true
        );
        Opportunity opportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE_NEEDS_ANALYSIS,
            CloseDate = System.today().addDays(5),
            AccountId = account.Id,
            Deal_Type__c= 'Standard',
            Opportunity_Sub_Type__c= 'Former Partner',
            Pricebook2Id = pricebookId
        );
        insert opportunity;
        OpportunityLineItem advertisementLineItem = new OpportunityLineItem();
        advertisementLineItem.OpportunityId = opportunity.Id;
        advertisementLineItem.PricebookEntryId = advertisementProductEntry.Id;
        advertisementLineItem.Product2Id = products[0].Id;
        advertisementLineItem.Quantity = 1;
        advertisementLineItem.UnitPrice = 1;
        insert advertisementLineItem;
        OpportunityLineItem driveLineItem = new OpportunityLineItem();
        driveLineItem.OpportunityId = opportunity.Id;
        driveLineItem.PricebookEntryId = driveProductEntry.Id;
        driveLineItem.Product2Id = products[1].Id;
        driveLineItem.Quantity = 1;
        driveLineItem.UnitPrice = 1;
        insert driveLineItem;
        Aggregate[] lineItemAggregate = OpportunityLineItemsSelector.newInstance()
            .getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
                new Set<Id>{ opportunity.Id }
            );
        System.assertEquals(lineItemAggregate.size(), 2, ASSERT_MESSAGE_AGGREGATE_SIZE);
    }
}