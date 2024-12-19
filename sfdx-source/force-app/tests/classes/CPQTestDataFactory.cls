/**
 * @author atg
 * @date 05/23/2022
 * @description This is test class for creating CPQ objects that will be used in tests.
 */
@isTest
@SuppressWarnings(
    'PMD.ClassNamingConventions'
) // PMD rules are requiring test classes to end in 'Test'
public class CPQTestDataFactory {
    public static final String STATUS_DRAFT = 'Draft';
    public static final String OPPORTUNITY_STAGE_CW = 'Closed Won';
    public static final String PROCESS_AUTOMATION_USER = 'Process Automation User';

    /**
     * @description Use this Process Automation User to bypass validations in data setup.
     *              If we do not bypass validations, due to the volume of data required
     *              and the sequence in which its required, we come close to exceeding
     *              governor limits on the data setup alone.
     * @return User
    **/
    public static User processAutomationUser { get {
        if(processAutomationUser == null) {
            processAutomationUser = [SELECT Id FROM User WHERE Name = :PROCESS_AUTOMATION_USER LIMIT 1];
        }
        return processAutomationUser;
    } set;}

    /**
     * @description Creates a Contract record for test purposes using the default values
     * @param accountId
     * @param doInsert (Boolean)
     * @return Contract
     */
    public static Contract createContract(Id accountId, Boolean doInsert) {
        Contract newContract = new Contract(
            AccountId = accountId,
            StartDate = system.today(),
            ContractTerm = 12
        );
        if (doInsert) {
            insert newContract;
        }
        return newContract;
    }

    /**
     * @description Creates a Quote Line Group record for test purposes using the default values
     * @param quoteId
     * @param doInsert (Boolean)
     * @return SBQQ__QuoteLineGroup__c
     */
    public static SBQQ__QuoteLineGroup__c createGroup(Id quoteId, Boolean doInsert) {
        SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quoteId);
        if (doInsert) {
            insert newGroup;
        }
        return newGroup;
    }

    /**
     * @description Creates a PricebookEntry record for test purposes using the default values
     * @param product
     * @param currencyCode
     * @param doInsert (Boolean)
     * @return PricebookEntry
     */
    public static PricebookEntry createPriceBookEntry(
        Product2 product,
        String currencyCode,
        Boolean doInsert
    ) {
        return createPriceBookEntry(
            product,
            new Pricebook2(Id = Test.getStandardPricebookId()),
            currencyCode,
            doInsert
        );
    }

    /**
     * @description Creates a PricebookEntry record for test purposes using the default values
     * @param product
     * @param pricebook
     * @param currencyCode
     * @param doInsert (Boolean)
     * @return PricebookEntry
     */
    public static PricebookEntry createPriceBookEntry(
        Product2 product,
        Pricebook2 pricebook,
        String currencyCode,
        Boolean doInsert
    ) {
        //pricebook entry
        PricebookEntry testPbEntry = new PricebookEntry();
        testPbEntry.Pricebook2Id = pricebook.Id;
        testPbEntry.Product2Id = product.Id;
        testPbEntry.UnitPrice = 0;
        testPbEntry.IsActive = true;
        testPbEntry.CurrencyIsoCode = currencyCode;
        if (doInsert) {
            insert testPbEntry;
        }
        return testPbEntry;
    }

    /**
     * @description Creates a Product2 record for test purposes using the default values
     * @param doInsert (Boolean)
     * @return SBQQ__QuoteLine__c
     */
    public static Product2 createProduct(Boolean doInsert) {
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.Description = 'Product';
        product.IsActive = true;
        product.ProductCode = 'ProductCode';
        product.SBQQ__AssetAmendmentBehavior__c = 'Default';
        product.SBQQ__AssetConversion__c = 'One per quote line';
        product.SBQQ__BillingFrequency__c = 'Monthly';
        product.SBQQ__BillingType__c = 'Advance';
        product.SBQQ__ChargeType__c = 'Recurring';
        product.SBQQ__ConfigurationEvent__c = 'Always';
        product.SBQQ__ConfigurationType__c = 'Allowed';
        product.SBQQ__DefaultQuantity__c = 1;
        product.SBQQ__PriceEditable__c = true;
        product.SBQQ__PricingMethod__c = 'List';
        product.SBQQ__SubscriptionBase__c = 'List';
        product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        product.SBQQ__SubscriptionTerm__c = 1;
        product.SBQQ__SubscriptionType__c = 'Renewable';
        if (doInsert) {
            insert product;
        }
        return product;
    }

    /**
     * @description Creates a Product2 record for CoD purposes using the default values
     * @param doInsert (Boolean)
     * @return SBQQ__QuoteLine__c
     */
    public static Product2 createCoDProduct(Boolean doInsert) {
        Product2 product = new Product2();
        product.Name = 'Cash On Delivery';
        product.Description = 'Product';
        product.IsActive = true;
        product.Family = 'Drive';
        product.ProductCode = 'ProductCode';
        product.SBQQ__AssetAmendmentBehavior__c = 'Default';
        product.SBQQ__AssetConversion__c = 'One per quote line';
        product.SBQQ__BillingFrequency__c = 'Monthly';
        product.SBQQ__BillingType__c = 'Advance';
        product.SBQQ__ChargeType__c = 'Recurring';
        product.SBQQ__ConfigurationEvent__c = 'Always';
        product.SBQQ__ConfigurationType__c = 'Allowed';
        product.SBQQ__DefaultQuantity__c = 1;
        product.SBQQ__PriceEditable__c = true;
        product.SBQQ__PricingMethod__c = 'List';
        product.SBQQ__SubscriptionBase__c = 'List';
        product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        product.SBQQ__SubscriptionTerm__c = 1;
        product.SBQQ__SubscriptionType__c = 'Renewable';
        if (doInsert) {
            insert product;
        }
        return product;
    }

    /**
     * @description Creates an Opportunity record using as many default values as possible.
     *  defaults contactId to null.
     * @param accountId (Id)
     * @param doInsert (Boolean)
     * @return Opportunity
     */
    public static Opportunity createOpportunity(Id accountId, Boolean doInsert) {
        Opportunity newOpportunity = new Opportunity(
            AccountId = accountId,
            Name = 'Test Opportunity',
            CloseDate = System.today(),
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner'
        );
        if (doInsert) {
            insert newOpportunity;
        }
        return newOpportunity;
    }

    /**
     * @description Creates an Opportunity in C/W Stage without needing to satisfy the numerous validations.
     * @param accountId (Id)
     * @param doInsert (Boolean)
     * @return Opportunity
    **/
    public static Opportunity createClosedWonOpportunityWithBypassedValidations(Id accountId, Boolean doInsert) {
        Opportunity newOpportunity = new Opportunity();

        System.runAs(processAutomationUser) {
            newOpportunity = new Opportunity(
                AccountId = accountId,
                Name = 'Test Opportunity',
                CloseDate = System.today(),
                StageName = OPPORTUNITY_STAGE_CW,
                Deal_Type__c = 'Self-Serve',
                Opportunity_Sub_Type__c= 'Ads & Promos',
                Drive_Nintex_Id__c = 'x1234',
                Campaign_Program_is_N_A__c = 'No',
                Nintex_Signed_Date__c = System.today().addDays(30)
            );

            if(doInsert) {
                insert newOpportunity;
            }
        }

        return newOpportunity;
    }

    /**
    * @description Creates a SBQQ__QuoteLine__c record for test purposes using the default values
    * @param oppId
    * @param productId
    * @param pricebookEntryId
    * @param doInsert (Boolean)
    * @return SBQQ__QuoteLine__c
    */
    public static OpportunityLineItem createOpportunityLineItem(Id oppId, Id productId, Id pricebookEntryId, boolean doInsert){
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppId;
        oppLineItem.PricebookEntryId = pricebookEntryId;
        oppLineItem.Product2Id = productId;
        oppLineItem.Quantity = 1;
        oppLineItem.UnitPrice = 1;

        if (doInsert) {
            insert oppLineItem;
        }
        return oppLineItem;
    }

    /**
     * @description Creates a SBQQ__Quote__c record for testing. Defaults it to be a primary quote.
     *
     * @param oppty (Opportunity)
     * @param account (Account)
     * @param contact (Contact)
     * @param doInsert (Boolean)
     * @return (SBQQ__Quote__c)
     */
    public static SBQQ__Quote__c createQuote(
        Opportunity oppty,
        Account account,
        Contact contact,
        Boolean doInsert
    ) {
        return createQuote(oppty, account, contact, true, doInsert);
    }

    /**
     * @description Creates a SBQQ__Quote__c record for testing.
     *
     * @param oppty (Opportunity)
     * @param account (Account)
     * @param contact (Contact)
     * @param isPrimary (Boolean)
     * @param doInsert (Boolean)
     * @return (SBQQ__Quote__c)
     */
    public static SBQQ__Quote__c createQuote(
        Opportunity oppty,
        Account account,
        Contact contact,
        Boolean isPrimary,
        Boolean doInsert
    ) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Primary__c = isPrimary;
        quote.SBQQ__Type__c = 'Quote';
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__ExpirationDate__c = oppty == null ? null : oppty.CloseDate;
        quote.SBQQ__BillingCity__c = 'Grand Rapids';
        quote.SBQQ__BillingCountry__c = 'US';
        quote.SBQQ__BillingName__c = 'Billing Name';
        quote.SBQQ__BillingPostalCode__c = '49506';
        quote.SBQQ__BillingState__c = 'MI';
        quote.SBQQ__BillingStreet__c = '1234 Main';
        quote.SBQQ__Opportunity2__c = oppty == null ? null : oppty.Id;
        quote.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        quote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        quote.SBQQ__PrimaryContact__c = contact == null ? null : contact.Id;
        quote.SBQQ__ShippingCity__c = 'Grand Rapids';
        quote.SBQQ__ShippingCountry__c = 'US';
        quote.SBQQ__ShippingName__c = 'Shipping Name';
        quote.SBQQ__ShippingPostalCode__c = '49506';
        quote.SBQQ__ShippingState__c = 'MI';
        quote.SBQQ__ShippingStreet__c = '1234 Main St';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
        if (doInsert) {
            insert quote;
        }
        return quote;
    }

    /**
     * @description Creates a SBQQ__QuoteLine__c record for test purposes using the default values
     * @param product
     * @param quote
     * @param doInsert (Boolean)
     * @return SBQQ__QuoteLine__c
     */
    public static SBQQ__QuoteLine__c createQuoteLine(
        Product2 product,
        SBQQ__Quote__c quote,
        Boolean doInsert
    ) {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__BillingFrequency__c = 'Monthly';
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = 1;
        quoteLine.SBQQ__Number__c = 1; // might need to set
        quoteLine.SBQQ__Product__c = product.Id;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__NetPrice__c = 100;
        if (doInsert) {
            insert quoteLine;
        }
        return quoteLine;
    }

    /**
     * @description Creates a Order record for test purposes using the default values
     * @param account
     * @param opp
     * @param quote
     * @param doInsert (Boolean)
     * @return Order
     */
    public static Order createOrder(
        Account account,
        Opportunity opp,
        SBQQ__Quote__c quote,
        Boolean doInsert
    ) {
        Id primaryRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Order order = new Order();
        order.AccountId = account.Id;
        order.EffectiveDate = Date.today();
        order.EndDate = Date.today().addMonths(12);
        order.OpportunityId = opp.Id;
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.SBQQ__ContractingMethod__c = 'By Subscription End Date';
        order.SBQQ__PaymentTerm__c = 'Net 30';
        order.SBQQ__PriceCalcStatus__c = 'Not Started';
        order.SBQQ__Quote__c = quote.Id;
        order.SBQQ__RenewalTerm__c = 1;
        order.Status = 'Draft';
        order.Type = 'New';
        order.recordTypeId = primaryRecordTypeId;
        if (doInsert) {
            insert order;
        }
        return order;
    }

    /**
     * @description Creates a OrderItem record for test purposes using the default values
     * @param order
     * @param quoteLine
     * @param priceBookEntryId
     * @param doInsert (Boolean)
     * @return OrderItem
     */
    public static OrderItem createOrderItem(
        Order order,
        SBQQ__QuoteLine__c quoteLine,
        Id priceBookEntryId,
        Boolean doInsert
    ) {
        OrderItem oi = new OrderItem();
        oi.EndDate = Date.today().addMonths(12);
        oi.OrderId = order.Id;
        oi.Quantity = 1;
        oi.SBQQ__Activated__c = false;
        oi.SBQQ__BillingFrequency__c = quoteLine.SBQQ__BillingFrequency__c;
        oi.SBQQ__BillingType__c = quoteLine.SBQQ__BillingType__c;
        oi.SBQQ__BookingsIndicator__c = 'Include';
        oi.SBQQ__ChargeType__c = quoteLine.SBQQ__ChargeType__c;
        oi.SBQQ__ContractAction__c = 'New';
        oi.SBQQ__ContractingMethod__c = 'Inherit';
        oi.SBQQ__DefaultSubscriptionTerm__c = 1;
        oi.SBQQ__OrderedQuantity__c = quoteLine.SBQQ__Quantity__c;
        oi.SBQQ__ProrateMultiplier__c = 1;
        oi.SBQQ__QuoteLine__c = quoteLine.Id;
        oi.SBQQ__QuotedListPrice__c = quoteLine.SBQQ__ListPrice__c;
        oi.SBQQ__QuotedQuantity__c = quoteLine.SBQQ__Quantity__c;
        oi.SBQQ__Status__c = 'Draft';
        oi.SBQQ__SubscriptionPricing__c = quoteLine.SBQQ__SubscriptionPricing__c;
        oi.SBQQ__SubscriptionTerm__c = quoteLine.SBQQ__SubscriptionTerm__c;
        oi.ServiceDate = Date.today();
        oi.UnitPrice = quoteLine.SBQQ__NetPrice__c;
        oi.PricebookEntryId = priceBookEntryId;
        if (doInsert) {
            insert oi;
        }
        return oi;
    }

    /**
     * @description Creates a Product Option record
     * @param optionalSKU (Product2)
     * @param configuredSKU (Product2)
     * @param doInsert (Boolean)
     * @return SBQQ__ProductOption__c
     */
    public static SBQQ__ProductOption__c createProductOption(Product2 optionalSKU, Product2 configuredSKU, Boolean doInsert) {
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c();
        productOption.SBQQ__OptionalSKU__c = optionalSKU.Id;
        productOption.SBQQ__ConfiguredSKU__c = configuredSKU.Id;
        productOption.SBQQ__Number__c = 1;
        if (doInsert) {
            insert productOption;
        }
        return productOption;
    }
}