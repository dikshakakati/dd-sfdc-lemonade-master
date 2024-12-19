/**
 * @author Deloitte
 * @date 11/08/2022
 * @description Selector class for SBQQ__QuoteLine__c Object.
 */
public inherited sharing class QuoteLineItemsSelector extends fflib_SObjectSelector implements IQuoteLineItemsSelector {
    private static final List<String> PRODUCT_FAMILY = new List<String>{
        'Marketplace Promotion',
        'Advertisement'
    };
    private static final List<String> PRODUCT_NAME = new List<String>{
        'Sponsored Products',
        'Marketing Commitment'
    };
    private static final String ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final String QUOTE_STATUS_CONTRACT_SIGNED = 'Contract Signed';
    private static final String AMENDMENT = 'Amendment';
    private static final String ALCOHOLDELIVERY_PRODUCT_CODE = '10061';
    private static final String MARKETPLACE_PRODUCT_CODE = '10017';
    private static final String LOF_PACKAGE = 'Large Order Fulfillment (LOF)';
    private static final String DELIVERY_PRODUCT = 'Delivery';
    private static final String ALCOHOL_DELIVERY_PRODUCT = 'Alcohol Delivery';
    private static final String COMMISSION_FEE_TYPE = 'Commission';
    private static final String SEGMENT = 'SMB';
    private static final String SOF_PACKAGE = 'Small Order Fulfillment (SOF)';
    private static final String DISTANCE_BASED = 'Distance Based (incl. tiered)';
    private static final String MARKETPLACE_PROMOTION = 'Marketplace Promotion';
    private static final String ADVERTISEMENT = 'Advertisement';
    private static final String SPONSORED_LISTINGS = 'Sponsored Listings';
    private static final String OPPTY_TYPE_PRESALE = 'New';
    private static final String OPPTY_TYPE_POSTSALE = 'Existing';
    private static final String SOURCE_SSMO = 'SSMO';
    private static final List<String> PRODUCT_NAME_AP = new List<String>{
        'Custom Marketing Promotion',
        'Spend X, Get Y',
        'Order Again',
        'Buy Item, Get $X or Y% Off'
    };
    private static final String PROCESS_AUTOMATION_USER = System.Label.Automated_Process_User_Full_Name;

    /**
     * @description Default Constructor for the Quote Line Items Selector Class
     * @return IQuoteLineItemsSelector - Interface of Quote Line Items
     */
    public static IQuoteLineItemsSelector newInstance() {
        return (IQuoteLineItemsSelector) Application.Selector.newInstance(
            SBQQ__QuoteLine__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on SBQQ__QuoteLine__c object
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SBQQ__QuoteLine__c.Id,
            SBQQ__QuoteLine__c.Name,
            SBQQ__QuoteLine__c.Campaign_Name__c,
            SBQQ__QuoteLine__c.SBQQ__Quote__c,
            SBQQ__QuoteLine__c.Custom_Creative_Required__c,
            SBQQ__QuoteLine__c.SBQQ__SpecialPrice__c,
            SBQQ__QuoteLine__c.SBQQ__Quantity__c,
            SBQQ__QuoteLine__c.Program_Type__c
        };
    }

    /**
     * @description It is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__QuoteLine__c.SObjectType;
    }
    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quote Line Ids.
     * @param quoteLineIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectById(Set<Id> quoteLineIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory().setCondition('Id IN :quoteLineIds');
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quote Line Ids.
     * @param quoteLineIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLineGroupFields(Set<Id> quoteLineIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('SBQQ__Group__c')
            .selectField('SBQQ__Group__r.CCP_Unique_Group_Id__c')
            .setCondition('Id IN :quoteLineIds ' + 'AND SBQQ__Group__c != NULL');
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quotes.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectDrawerFieldByQuotes(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('SBQQ__Quote__c')
            .selectField('SBQQ__ProductCode__c')
            .selectField('SBQQ__ProductName__c')
            .selectField('Package__c')
            .selectField('SBQQ__Bundle__c')
            .selectField('SBQQ__Quote__r.Custom_Partnership_Type__c')
            .selectField('SBQQ__Quantity__c')
            .selectField('SBQQ__Quote__r.Opportunity_Deal_Type__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__c')
            .selectField('SBQQ__Quote__r.Self_Serve_Status__c')
            .selectFieldSet(
                SObjectType.SBQQ__QuoteLine__c.FieldSets.Quote_Line_Drawer_Required_Fields
            )
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds AND ((SBQQ__Existing__c = false AND SBQQ__Quote__r.Segment__c = :SEGMENT ) OR SBQQ__Quote__r.Segment__c  != :SEGMENT )'
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of AccountIds
     * @param newQuotesSet
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLineswithMissingGroups(Set<Id> newQuotesSet) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('SBQQ__Group__c')
            .selectField('SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c')
            .selectField('SBQQ__UpgradedSubscription__c')
            .setCondition(
                'SBQQ__Quote__c IN :newQuotesSet ' +
                    'AND SBQQ__Quote__r.SBQQ__Type__c = :AMENDMENT ' +
                    'AND SBQQ__Group__c = NULL ' +
                    'AND SBQQ__UpgradedSubscription__c != NULL ' +
                    'AND SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c != NULL'
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Line Items with groups related to the passed set of quoteIds.
     * @param newQuotesSet
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLinesFromQuoteIds(Set<Id> newQuotesSet) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('SBQQ__Group__c')
            .selectField('SBQQ__UpgradedSubscription__c')
            .setCondition('SBQQ__Quote__c IN :newQuotesSet ' + 'AND SBQQ__Group__c != NULL');
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Marketplace Promotion/Advertisement Family Quote Line Items related to the passed set of quoteIds
     * with 'Number of Stores' blank or 0 and less.
     * @param quoteIds Set<Id>
     * @return Boolean
     */
    public List<SBQQ__QuoteLine__c> selectAdsMarketplacePromotionQuotesWithInvalidStores(
        Set<Id> quoteIds
    ) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('SBQQ__Product__r.Family')
            .selectField('SBQQ__Quote__r.Number_of_Stores__c')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds ' +
                    'AND SBQQ__Product__r.Family IN :PRODUCT_FAMILY ' +
                    'AND (SBQQ__Quote__r.Number_of_Stores__c <= 0 OR SBQQ__Quote__r.Number_of_Stores__c = null)'
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of AccountIds.
     * @param businessAccountIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectAlcoholDeliveryQuoteLineItemByAccounts(
        Set<Id> businessAccountIds
    ) {
        ignoreCRUD();
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('SBQQ__Quote__r.SBQQ__Status__c')
            .selectField('SBQQ__Quote__r.SBQQ__Account__c')
            .selectField('SBQQ__Quote__r.SBQQ__Primary__c')
            .selectField('SBQQ__ProductName__c')
            .setCondition(
                'SBQQ__Quote__r.SBQQ__Account__c IN :businessAccountIds AND SBQQ__Quote__r.SBQQ__Primary__c = TRUE AND SBQQ__Quote__r.SBQQ__Status__c =: QUOTE_STATUS_CONTRACT_SIGNED AND SBQQ__ProductName__c =: ALCOHOL_DELIVERY'
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Marketplace Alcohol Delivery Quote Line Items related to the passed set of quoteIds.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectMarketplaceAlcoholDeliveryQuoteLinesFromQuoteIds(
        Set<Id> quoteIds
    ) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('SBQQ__Group__c')
            .selectField('SBQQ__Quantity__c')
            .selectField('SBQQ__UpgradedSubscription__c')
            .setCondition(
                'SBQQ__Quote__c IN: quoteIds ' +
                    'AND SBQQ__Quote__r.SBQQ__Type__c =: AMENDMENT ' +
                    'AND SBQQ__UpgradedSubscription__c != NULL ' +
                    'AND SBQQ__Quantity__c = 0 ' +
                    'AND Package_Code__c =: MARKETPLACE_PRODUCT_CODE ' +
                    'AND SBQQ__ProductCode__c =: ALCOHOLDELIVERY_PRODUCT_CODE'
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of quoteIds.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLineItemsFromQuoteIds(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('Package_Code__c')
            .selectField('Package__c')
            .selectField('SBQQ__Quantity__c')
            .selectField('SBQQ__Product__r.Name')
            .selectField('SBQQ__ProductCode__c')
            .setCondition('SBQQ__Quote__c IN: quoteIds ');
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description fetch quotelines by Ids with Brief Items
     * @param quoteLineIds
     * @return Map<Id,SBQQ__QuoteLine__c>
     */
    public Map<Id, SBQQ__QuoteLine__c> selectQuoteLinesFromIdsWithBriefItems(Set<Id> quoteLineIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('Brief_Item__c')
            .setCondition('Id IN :quoteLineIds');
        return new Map<Id, SBQQ__QuoteLine__c>(
            (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL())
        );
    }

    /**
     * @description select original quote lines from original quote
     * @param quoteIds
     * @return Map<Id,SBQQ__QuoteLine__c>
     */
    public Map<Id, SBQQ__QuoteLine__c> selectQuoteLinesWithUpgradedSubscriptions(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('Brief_Item__c')
            .selectField('Bid__c')
            .selectField('Budget__c')
            .selectField('SBQQ__Source__c')
            .selectField('SBQQ__Source__r.Brief_Item__c')
            .selectField('SBQQ__Source__r.Has_Brief_Item__c')
            .selectField('Has_Brief_Item__c')
            .selectField('SBQQ__ProductName__c')
            .selectField('Payment_Method__c')
            .selectField('Package__c')
            .selectField('Banner_Dates__c')
            .selectField('Banner_Type__c')
            .selectField('SBQQ__Quote__r.CurrencyIsoCode')
            .selectField('SBQQ__Quote__c')
            .selectField('Pricing_Type__c')
            .selectField('User_Communication_Type__c')
            .selectField('Minimum_Banner_Fee__c')
            .selectField('Day_Time_of_Week__c')
            .selectField('Max_Number_of_Redemptions__c')
            .selectField('Order_Cart_Minimum__c')
            .selectField('Keywords__c')
            .selectField('SBQQ__Product__r.Name')
            .selectField('Flat_Discount_Amount_for_Consumer__c')
            .selectField('Max_Discount_Amount_for_Consumer__c')
            .selectField('Discount_Percentage_for_Consumer__c')
            .selectField('Affinity_Target_Audience__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId')
            .selectField('End_Date__c')
            .selectField('Offer_detailed_description__c')
            .selectField('Auto_Bidding__c')
            .selectField('Term_Specific_Bidding__c')
            .selectField('Menu_Item_Minimum_Quantity__c')
            .selectField('Discounted_Delivery_Fee__c')
            .selectField('Start_Date__c')
            .selectField('End_Date__c')
            .selectField('Brands__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__c')
            .selectField('SBQQ__Quote__c.SBQQ__Notes__c')
            .selectField('Estimated_Average_Daily_Budget__c')
            .selectField('Priority_UPCs__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.Agency__c')
            .selectField('SBQQ__Quote__r.Signed_Contract_link__c')
            .selectField('SBQQ__ProductName__c')
            .selectField('SBQQ__RequiredBy__r.Campaign_Name__c')
            .selectField('SBQQ__Quote__r.SBQQ__Account__c')
            .selectField('SBQQ__Source__r.Brief_Item__r.Brief__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId')
            .selectField('SBQQ__Quote__r.Payment_Account__r.NetSuite_ID__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.Purchase_Order__c')
            .selectField('SBQQ__UpgradedSubscription__c')
            .selectField('SBQQ__UpgradedSubscription__r.SBQQ__OriginalQuoteLine__r.Id')
            .selectField('SBQQ__UpgradedSubscription__r.SBQQ__OriginalQuoteLine__r.Brief_Item__c')
            .selectField('SBQQ__Quote__r.SBQQ__Status__c')
            .selectField('SBQQ__Quantity__c')
            .selectField('SBQQ__Quote__r.Invoicing_Payment_Account__r.Business_Account_Type__c')
            .selectField('SBQQ__RequiredBy__r.Has_Brief_Item__c')
            .selectField('SBQQ__Quote__r.SBQQ__Type__c')
            .selectField('SBQQ__Quote__r.Invoicing_Payment_Account__r.NetSuite_ID__c')
            .selectField('Estimated_Total_Investment__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.Campaign_Program__c')
            .selectField('SBQQ__ProductFamily__c')
            .selectField('Create_Brief_Item__c')
            .selectField('Custom_Creative_Required__c')
            .selectField('SBQQ__Quote__r.Segment__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.Deal_Type__c')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds AND SBQQ__ProductFamily__c IN :PRODUCT_FAMILY'
            );
        Set<Schema.SOBjectField> fieldSet = QuoteLineBriefItemMappingSelector.newInstance()
            .getQuoteLineFieldSet();
        for (Schema.SObjectField field : fieldSet) {
            quoteLineQuery.selectField(field);
        }
        return new Map<Id, SBQQ__QuoteLine__c>(
            (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL())
        );
    }

    /**
     * @description It is used to select quote lines by the passed unique identifiers.
     * @JIRA LEM-14588
     * @param uniqueIdentifiers
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectQuoteLinesbyUniqueIdentifiers(
        Set<String> uniqueIdentifiers
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('SBQQ__ProductName__c')
            .selectField('Unique_Identifier__c')
            .selectField('SBQQ__Number__c')
            .selectField('SBQQ__Group__c')
            .selectField('SBQQ__Quote__c')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiers')
            .setOrdering('SBQQ__Number__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<SBQQ__QuoteLine__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to fetch Quote Lines Active Price Fields related to the passed set of Quotes.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectActivePriceFieldsByQuotes(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('Requested_Commission__c')
            .selectField('Active_Commission__c')
            .selectField('SBQQ__SpecialPrice__c')
            .selectField('Active_Fee__c')
            .selectField('Rate_Change__c')
            .selectField('Type__c')
            .selectField('SBQQ__Source__c')
            .selectField('SBQQ__Source__r.Active_Commission__c')
            .selectField('SBQQ__Source__r.Active_Fee__c')
            .selectField('SBQQ__ProductOption__c')
            .selectField('SBQQ__ProductOption__r.Active_Rate_Eligible__c')
            .selectField('SBQQ__Quote__r.SBQQ__Type__c')
            .setCondition('SBQQ__Quote__c IN :quoteIds AND SBQQ__ProductOption__c != NULL');
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Alcohol Delivery/Delivery Quote Lines under LOF Package with
     * Fee Type as 'Commission' or 'Fee' with Min/Max delivery fee blank.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectLOFProductswithCommissionForValidation(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory(false)
            .selectField('Id')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds ' +
                    'AND Package__c = :LOF_PACKAGE AND Fee_Type__c = :COMMISSION_FEE_TYPE ' +
                    'AND (SBQQ__Product__r.name = :DELIVERY_PRODUCT OR SBQQ__Product__r.name = :ALCOHOL_DELIVERY_PRODUCT) ' +
                    'AND Min__c = null AND Max__c = null AND Segment__c = :SEGMENT '
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Delivery Quote Lines under LOF/SOF Package with
     * Delivery Type as 'Distance Based (incl. tiered)'.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectNewDriveDeliveryProductswithDeliveyTypeAsDistanceBased(
        Set<Id> quoteIds
    ) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory(false)
            .selectField('Id')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds ' +
                    'AND (Package__c =:LOF_PACKAGE OR Package__c =:SOF_PACKAGE)  ' +
                    'AND SBQQ__Product__r.name =:DELIVERY_PRODUCT ' +
                    'AND Delivery_Type__c =:DISTANCE_BASED AND SBQQ__Existing__c = false AND Segment__c = :SEGMENT '
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }
    /**
     * @description It is used to fetch Marketplace Promotion/Advertisement Product Family Quote Lines with
     * Length of Term as blank.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectLengthOfTermwithProductsForValidation(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory(false)
            .selectField('Id')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds ' +
                    'AND (SBQQ__ProductFamily__c = :MARKETPLACE_PROMOTION OR SBQQ__ProductFamily__c = :ADVERTISEMENT) ' +
                    'AND ((Length_of_Term__c = null AND SBQQ__Quote__r.Opportunity_Type__c =:OPPTY_TYPE_PRESALE) OR ' +
                    '(Length_of_Term__c <> null AND SBQQ__Quote__r.Opportunity_Type__c =:OPPTY_TYPE_POSTSALE)) ' +
                    'AND SBQQ__Quote__r.Segment__c = :SEGMENT AND SBQQ__Existing__c = false '
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch Marketplace Promotion/Advertisement Product Family Quote Lines for SMB Segment
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectAdsAndPromosProductsForValidation(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('SBQQ__ProductName__c')
            .selectField('Discount_Percentage_for_Consumer__c')
            .selectField('Flat_Discount_Amount_for_Consumer__c')
            .selectField('Bid__c')
            .selectField('Auto_Bidding__c')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds ' +
                    'AND (SBQQ__ProductFamily__c = :MARKETPLACE_PROMOTION OR SBQQ__ProductFamily__c = :ADVERTISEMENT) ' +
                    'AND SBQQ__Quote__r.Segment__c = :SEGMENT AND SBQQ__Existing__c = false '
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to fetch quotelines created via self serve payload where trial period is blank.
     * @param uuids
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> selectSelfServeQuoteLineItemsWithBlankTrialPeriodByUUIDs(
        Set<String> uuids
    ) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Trial_Commission__c')
            .selectField('Trial_Period__c')
            .selectField('Unique_Identifier__c')
            .selectField('Package__c')
            .selectField('SBQQ__ProductName__c')
            .selectField('SBQQ__Quote__r.Segment__c')
            .setCondition(
                'Unique_Identifier__c IN :uuids AND Package__c != null AND Trial_Period__c = null ' +
                'AND SBQQ__Quote__r.Opportunity_Source__c =:SOURCE_SSMO AND CreatedBy.Name =: PROCESS_AUTOMATION_USER'
            );
        return (List<SBQQ__QuoteLine__c>) Database.query(quoteLineQuery.toSOQL());
    }
}