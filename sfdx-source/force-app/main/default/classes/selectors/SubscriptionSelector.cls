/**
 * @author Deloitte
 * @date 09/05/2022
 * @description Selector Class for SBQQ__Subscription__c Object
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class SubscriptionSelector extends fflib_SObjectSelector implements ISubscriptionSelector {
    private static final String CASH_ON_DELIVERY_PRODUCT = 'Cash on Delivery';
    private static final String DRIVE_PRODUCT = 'Drive';
    private static final String CORPORATE_TYPE = 'Corporate';
    private static final String AMENDMENT = 'AMENDMENT';
    private static final String FRANCHISEE_TYPE = 'Franchisee';
    private static final String SMB_SEGMENT = 'SMB';
    private static final List<String> PRODUCT_LIST = new List<String>{
        'DashPass',
        'Pickup',
        'Delivery'
    };
    private static final List<String> ALCOHOL_PRODUCT_NAMES = new List<String>{
        'Alcohol Delivery',
        'Alcohol Pickup'
    };
    static final Set<String> PRODUCT_FAMILY_DRIVE_SET = new Set<String>{
        'Drive',
        'Drive Promotion',
        'Voice Ordering'
    };

    /**
     * @description New instance method to call application selector
     * @param SBQQ__Subscription__c.SObjectType - SBQQ__Subscription__c object type
     * @return ISubscriptionSelector - interface of ISubscriptionSelector
     */
    public static ISubscriptionSelector newInstance() {
        return (ISubscriptionSelector) Application.Selector.newInstance(
            SBQQ__Subscription__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on SBQQ__Subscription__c object
     * @return SBQQ__Subscription object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SBQQ__Subscription__c.Id,
            SBQQ__Subscription__c.SBQQ__Account__c,
            SBQQ__Subscription__c.Business_Account_Id__c,
            SBQQ__Subscription__c.SBQQ__Contract__c,
            SBQQ__Subscription__c.SBQQ__OrderProduct__c,
            SBQQ__Subscription__c.SBQQ__TerminatedDate__c,
            SBQQ__Subscription__c.SBQQ__SubscriptionEndDate__c,
            SBQQ__Subscription__c.Affinity_Target_Audience__c,
            SBQQ__Subscription__c.Banner_Dates__c,
            SBQQ__Subscription__c.Banner_Type__c,
            SBQQ__Subscription__c.Bid__c,
            SBQQ__Subscription__c.Brands__c,
            SBQQ__Subscription__c.Campaign_Name__c,
            SBQQ__Subscription__c.Day_Time_of_Week__c,
            SBQQ__Subscription__c.Discount_Percentage_for_Consumer__c,
            SBQQ__Subscription__c.End_Date__c,
            SBQQ__Subscription__c.Flat_Discount_Amount_for_Consumer__c,
            SBQQ__Subscription__c.Keywords__c,
            SBQQ__Subscription__c.Max_Discount_Amount_for_Consumer__c,
            SBQQ__Subscription__c.Max_Number_of_Redemptions__c,
            SBQQ__Subscription__c.Order_Cart_Minimum__c,
            SBQQ__Subscription__c.Payment_Method__c,
            SBQQ__Subscription__c.Pricing_Type__c,
            SBQQ__Subscription__c.Start_Date__c,
            SBQQ__Subscription__c.Auto_Bidding__c,
            SBQQ__Subscription__c.Offer_detailed_description__c,
            SBQQ__Subscription__c.Term_Specific_Bidding__c,
            SBQQ__Subscription__c.Priority_UPCs__c,
            SBQQ__Subscription__c.User_Communication_Type__c,
            SBQQ__Subscription__c.Discounted_Delivery_Fee__c,
            SBQQ__Subscription__c.Menu_Item_Minimum_Quantity__c,
            SBQQ__Subscription__c.SBQQ__QuoteLine__c,
            SBQQ__Subscription__c.Quote_Line_Group__c,
            SBQQ__Subscription__c.SBQQ__RequiredById__c,
            SBQQ__Subscription__c.Integration_Source__c,
            SBQQ__Subscription__c.Package__c,
            SBQQ__Subscription__c.SBQQ__ProductName__c,
            SBQQ__Subscription__c.Unique_Identifier__c
        };
    }
    /**
     * @description This method is for getting Subscription based on the provided list of ids
     * @return Database.QueryLocator- DML operation result
     * @param subsciptionRecIds - SBQQ__Subscription__c Record Ids
     */
    public List<SBQQ__Subscription__c> querySubscriptionRecords(Set<Id> subsciptionRecIds) {
        return Database.query(
            newQueryFactory()
                .selectField('Active_fee__c')
                .selectField('Active_Commission__c')
                .selectField('Subscription_Rate_Change__c')
                .selectField('SBQQ__Account__r.ParentId')
                .selectField('SBQQ__ProductName__c')
                .setCondition('Id IN: subsciptionRecIds')
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription based on the provided list of ids
     * @return List<SBQQ__Subscription__c> - DML operation result
     * @param accountRecordIds - SBQQ__Subscription__c Record Ids
     */
    public List<SBQQ__Subscription__c> querySubscriptionRecordsWithAccountIds(
        Set<Id> accountRecordIds
    ) {
        return Database.query(
            newQueryFactory()
                .selectField('Package__c')
                .selectField('SBQQ__QuoteLine__r.Package_Product__c')
                .selectField('Final_Fee__c')
                .selectField('Final_Commission__c')
                .selectField('Trial_Commission__c')
                .selectField('Trial_Fee__c')
                .selectField('SBQQ__ProductName__c')
                .selectField('SBQQ__Contract__c')
                .selectField('SBQQ__Account__r.ParentId')
                .selectField('SBQQ__TerminatedDate__c')
                .setCondition('SBQQ__Account__c IN: accountRecordIds')
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription based on the parent Contract and CoD product
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectByContractAndCoDProduct(Set<String> contractIds) {
        /**
         * LEM-4765: It is used to enable Nintex form generation for personas like Strategy and Operations
         * which do not have permissions to access CPQ objects like Subscription.
         * Nintex form generation is associated with querying Subscriptions.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .setCondition(
                    'SBQQ__Contract__c IN: contractIds AND SBQQ__ProductName__c = :CASH_ON_DELIVERY_PRODUCT'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription based on the parent Contract and Alcohol products
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
        Set<String> contractIds
    ) {
        /**
         * LEM-4765: It is used to enable Nintex form generation for personas like Strategy and Operations
         * which do not have permissions to access CPQ objects like Subscription.
         * Nintex form generation is associated with querying Subscriptions.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .selectField('SBQQ__ProductName__c')
                .setCondition(
                    'SBQQ__Contract__c IN :contractIds AND ' +
                        'SBQQ__ProductName__c IN :ALCOHOL_PRODUCT_NAMES AND ' +
                        'SBQQ__Account__r.Type = :CORPORATE_TYPE'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription based on the parent Contract and Drive product
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectByContractAndDriveProduct(Set<String> contractIds) {
        /**
         * LEM-4765: It is used to enable Nintex form generation for personas like Strategy and Operations
         * which do not have permissions to access CPQ objects like Subscription.
         * Nintex form generation is associated with querying Subscriptions.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .setCondition(
                    'SBQQ__Contract__c IN: contractIds AND SBQQ__Product__r.Family = :DRIVE_PRODUCT AND SBQQ__Account__r.Type = :CORPORATE_TYPE'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method id for getting object type
     * @return SBQQ__Subscription__c Object type
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__Subscription__c.SObjectType;
    }

    /**
     * @description This method is used for getting a map of Order Item Ids to Active Subscription Ids
     * @param contractIds
     * @param driveProductsOnly
     * @return Map<Id, Id>
     */
    public Map<Id, Id> selectOrderItemActiveSubscriptionMap(
        Set<Id> contractIds,
        Boolean driveProductsOnly
    ) {
        Map<Id, Id> orderItemIdSubscriptionIdMap = new Map<Id, Id>();

        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__OrderProduct__r.OrderId');
        query.selectField('SBQQ__OrderProduct__r.Product2.Family');
        query.selectField('SBQQ__OrderProduct__r.SBQQ__BundleRoot__r.Product2.Family');

        String condition = '(SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY)';
        if (driveProductsOnly) {
            condition += ' AND ((SBQQ__OrderProduct__r.Product2.Family IN :PRODUCT_FAMILY_DRIVE_SET) OR (SBQQ__OrderProduct__r.SBQQ__BundleRoot__r.Product2.Family IN :PRODUCT_FAMILY_DRIVE_SET))';
        }
        condition += ' AND SBQQ__Contract__c IN :contractIds';
        query.setCondition(condition);

        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        for (SBQQ__Subscription__c sub : subscriptionList) {
            if (
                (sub.SBQQ__OrderProduct__c != null) && (sub.SBQQ__OrderProduct__r.OrderId != null)
            ) {
                orderItemIdSubscriptionIdMap.put(sub.SBQQ__OrderProduct__c, sub.Id);
            }
        }
        return orderItemIdSubscriptionIdMap;
    }

    /**
     * @description This method is used for getting a List of Active Subscription for Contracts
     * @param contractIds
     * @param driveProductsOnly
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectActiveSubscriptionsList(
        Set<Id> contractIds,
        Boolean driveProductsOnly
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__RequiredById__c');
        query.selectField('SBQQ__RootId__c');
        query.selectField('CreatedDate');
        query.selectField('SBQQ__OrderProduct__r.OrderId');
        query.selectField('SBQQ__ACCOUNT__R.SEGMENT__C');
        query.selectField('SBQQ__ACCOUNT__R.BillingState');
        query.selectField('SBQQ__OrderProduct__r.Product2.ProductCode');
        query.selectField('SBQQ__OrderProduct__r.Product2.Family');
        query.selectField('SBQQ__Product__r.Name');
        query.selectField('SBQQ__Product__r.Work_Order_Type__c');
        query.selectField('SBQQ__OrderProduct__r.SBQQ__BundleRoot__r.Product2.Family');
        query.selectField('SBQQ__Contract__r.Integration_Source__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Opportunity_Source__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c');

        String condition = '(SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY)';
        if (driveProductsOnly) {
            condition += ' AND ((SBQQ__OrderProduct__r.Product2.Family IN :PRODUCT_FAMILY_DRIVE_SET) OR (SBQQ__OrderProduct__r.SBQQ__BundleRoot__r.Product2.Family IN :PRODUCT_FAMILY_DRIVE_SET))';
        }
        condition += ' AND SBQQ__Contract__c IN :contractIds';
        query.setCondition(condition);

        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }

    /**
     * @description This method is used for getting a List of Active Subscription for Contracts and given Product Code
     * @param contractId
     * @param productCodes
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectActiveSubscriptionListBasedOnProductCode(
        Id contractId,
        Set<String> productCodes
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__Product__r.ProductCode');

        String condition = '(SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY) AND SBQQ__Contract__c = :contractId AND SBQQ__Product__r.ProductCode IN :productCodes';
        query.setCondition(condition);

        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }

    /**
     * @description This method is for getting Subscription based on the parent Contract and if any product name with following values (Delivery, Pickup, DashPass)
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectByContractAndProducts(Set<String> contractIds) {
        /**
         * LEM-4765: It is used to enable Nintex form generation for personas like Strategy and Operations
         * which do not have permissions to access CPQ objects like Subscription.
         * Nintex form generation is associated with querying Subscriptions.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .selectField('SBQQ__ProductName__c')
                .setCondition(
                    'SBQQ__Contract__c IN: contractIds AND SBQQ__ProductName__c IN: PRODUCT_LIST AND SBQQ__Account__r.Type = :CORPORATE_TYPE'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription based on the parent Contract and if any package name with following values (Storefront)
     * @JIRA# LEM-13995
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectByContractAndPackages(Set<String> contractIds) {
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .selectField('Package__c')
                .setCondition(
                    'SBQQ__Contract__c IN: contractIds AND (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c > TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c > TODAY) AND SBQQ__Account__r.Type = :CORPORATE_TYPE'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription based on the parent Account
     * and if any product name with following values (Alcohol Delivery and Alcohol Pickup)
     * @param accountIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectSubscriptionsWithAlcoholProductsByAccountIds(
        Set<Id> accountIds
    ) {
        /**
         * LEM-4677: It is used to enable Contact creation for personas like Strategy and Operations
         * which do not have permissions to access CPQ objects like Subscription.
         * Contact creation is associated with querying Subscriptions.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .setCondition(
                    'SBQQ__Account__c IN: accountIds AND SBQQ__ProductName__c IN: ALCOHOL_PRODUCT_NAMES'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting Subscription with Merchant services
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectSubsriptionsWithServices(Set<Id> subscriptionIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN : subscriptionIds');
        MerchantSelector msSelector = new MerchantSelector();
        msSelector.addQueryFactorySubselect(query, 'Merchant_Services__r')
            .selectField('Account__c');
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting Subscriptions by the passed List of Quoteline Ids
     * @param quoteLinesWithBriefItems
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectSubscriptionsWithFieldsToSyncWithBriefItems(
        List<String> quoteLinesWithBriefItems
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('SBQQ__QuoteLine__c IN :quoteLinesWithBriefItems');
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It queries Subscription by set of Subscription Ids.
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectBySubscriptionIds(Set<Id> subscriptionIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Package__c')
            .selectField('Integration_Source__c')
            .selectField('Is_It_A_New_Product__c')
            .selectField('SBQQ__Contract__r.Account.Segment__c')
            .selectField('SBQQ__Product__r.Name')
            .selectField('SBQQ__Product__r.Family')
            .selectField('SBQQ__RequiredByProduct__r.Family')
            .selectField('SBQQ__Contract__r.SBQQ__Opportunity__c')
            .selectField('SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Sub_Type__c')
            .selectField('SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type')
            .selectField('SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c')
            .selectField('SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c')
            .setCondition('Id IN: subscriptionIds');
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting Subscription based on the provided list of ids
     * @return List<SBQQ__Subscription__c> - DML operation result
     * @param groupIds - SBQQ__Subscription__c Record Ids
     */
    public List<SBQQ__Subscription__c> selectSubscriptionRecordsByGroup(List<Id> groupIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Package__c');
        query.selectField('SBQQ__RootId__c');
        query.selectField('SBQQ__ProductName__c');
        /* NOTE: DO NOT DELETE: Will be added as part of ARP
        query.selectField('Active_Commission__c');
        query.selectField('Active_Fee__c');*/
        query.selectField('Quote_Line_Group__c');
        query.selectField('SBQQ__RequiredById__c');
        query.selectField('SBQQ__Product__r.Package_Eligible_For_Entitlement__c');
        query.selectField('SBQQ__ProductOption__r.Product_Eligible_For_Entitlement__c');
        query.selectField('SBQQ__Product__r.Family');
        String condition =
            '(SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY) ' +
            'AND Quote_Line_Group__c IN :groupIds';
        query.setCondition(condition);
        query.setOrdering(
            'SBQQ__Product__r.Package_Eligible_For_Entitlement__c',
            fflib_QueryFactory.SortOrder.DESCENDING
        );
        query.setOrdering('SBQQ__ProductName__c', fflib_QueryFactory.SortOrder.ASCENDING);
        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }

    /**
     * @description This method is for getting group Id from given contract Id
     * @return Id - DML operation result
     * @param contractId - SBQQ__Subscription__c Record Ids
     */
    public Id selectQuoteLineGroupOnSubscription(Id contractId) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Quote_Line_Group__c');

        String condition =
            '(SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY)' +
            'AND SBQQ__Contract__c = :contractId';
        query.setCondition(condition);

        List<SBQQ__Subscription__c> subscriptionList = Database.query(query.toSOQL());

        if (!subscriptionList.isEmpty()) {
            Id groupId = subscriptionList[0].Quote_Line_Group__c;
            return groupId;
        } else {
            return null;
        }
    }
    /**
     * @description it is used for getting Subscriptions by passing in the parent subscriptions
     * @param parentSubscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectChildSubscriptions(Set<String> parentSubscriptionIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__ProductName__c');
        query.setCondition('SBQQ__RequiredById__c IN :parentSubscriptionIds');
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting subscription records by Id which are
     * SMB Type and Unique Indentifier is not null.
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> getSubscriptionsForWorkOrderCreation(
        Set<Id> subscriptionIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Id');
        query.selectField('SBQQ__Account__c');
        query.selectField('SBQQ__Account__r.Creation_Source__c');
        query.selectField('SBQQ__Account__r.Order_Protocol__c');
        query.selectField('SBQQ__Contract__c');
        query.selectField('SBQQ__Contract__r.Unique_Identifier__c');
        query.selectField('SBQQ__Contract__c.SBQQ__Opportunity__c');
        query.selectField('SBQQ__Product__r.Platform__c');
        query.selectField('SBQQ__Product__r.Family');
        query.selectField('SBQQ__Product__r.Work_Order_Type__c');
        query.selectField('SBQQ__Contract__r.Account.Marketplace_Nintex_Id__c');
        query.selectField('SBQQ__Contract__r.Account.Nintex_Photoshoot_Text_Value__c');
        query.selectField('SBQQ__Contract__r.Account.Nintex_Mx_Requested_Photoshoot__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Quote__r.RESSMO_Payload__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Order__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Unique_Identifier__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c');
        query.selectField('SBQQ__Contract__r.SBQQ__Quote__r.SBQQ__SalesRep__c');
        query.setCondition(
            'Id IN :subscriptionIds AND SBQQ__Account__r.Segment__c = :SMB_SEGMENT AND ( SBQQ__Contract__r.Unique_Identifier__c != null OR SBQQ__Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Unique_Identifier__c != null )'
        );
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting Subscription based on the provided list of order Item ids
     * @return List<SBQQ__Subscription__c> - DML operation result
     * @param orderItemIds Record Ids
     */
    public List<SBQQ__Subscription__c> selectSubscriptionRecordsByPrimaryOrderProduct(
        Set<Id> orderItemIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Active_Commission__c');
        query.selectField('Active_Fee__c');
        query.selectField('Quote_Line_Group__c');
        query.selectField('SBQQ__OrderProduct__c');
        query.selectField('SBQQ__OrderProduct__r.Quote_Line_Group__c');
        query.selectField('SBQQ__OrderProduct__r.Active_Commission__c');
        query.selectField('SBQQ__OrderProduct__r.Active_Fee__c');
        query.selectField('Subscription_Rate_Change__c');
        query.setCondition('SBQQ__OrderProduct__c IN: orderItemIds');
        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }

    /**
     * @description This method is for getting Subscription based on the provided list of ids
     * @return List<SBQQ__Subscription__c> - DML operation result
     * @param contractIds - SBQQ__Subscription__c Record Ids
     */
    public List<SBQQ__Subscription__c> selectSubscriptionRecordsByContract(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Package__c');
        query.selectField('SBQQ__ProductName__c');
        query.selectField('Active_Commission__c');
        query.selectField('Active_Fee__c');
        query.selectField('Quote_Line_Group__r.Name');
        query.selectField('Quote_Line_Group__c');
        query.selectField('Fee_Type__c');
        query.selectField('SBQQ__ProductOption__r.Active_Rate_Eligible__c');

        query.setCondition(
            'SBQQ__Contract__c IN: contractIds AND SBQQ__ProductOption__r.Active_Rate_Eligible__c = true AND (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c > TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c > TODAY)'
        );

        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }

    /**
     * @description it is used for getting Subscriptions by passing in contract Id
     * @param contractId
     * @param subscriptionsFields
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectActiveSubscriptionsByContractIdwithDynamicFields(
        Set<Id> contractId,
        Set<String> subscriptionsFields
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(subscriptionsFields);
        String condition =
            '(SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY)' +
            'AND SBQQ__Contract__c = :contractId AND  SBQQ__Quantity__c > 0 ';
        query.selectField('Id');
        query.setCondition(condition);
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description it is used for getting Subscriptions by passing in the contract Id.
     * LEM-15902
     * @param contractId
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectByContractId(String contractId) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Package__c');
        query.selectField('SBQQ__Product__r.Name');
        query.selectField('SBQQ__Product__r.Fee_Type__c');
        query.selectField('Final_Commission__c');
        query.selectField('Final_Fee__c');
        query.selectField('SBQQ__TerminatedDate__c');
        query.selectField('SBQQ__StartDate__c');
        query.selectField('SBQQ__EndDate__c');
        query.selectField('CurrencyIsoCode');
        query.setCondition('SBQQ__Contract__c =:contractId');
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting subscriptions that were Amended.
     * @param contractIds
     * @param productNames
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectAmendedSubscriptions(
        Set<Id> contractIds,
        Set<String> productNames,
        Set<Id> subscriptionIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__Product__r.Family');
        query.selectField('SBQQ__Product__r.Name');
        query.selectField('SBQQ__RequiredByProduct__r.Family');
        query.selectField('Package__c');
        query.setCondition(
            'SBQQ__Contract__c IN: contractIds AND ' +
                'Id NOT IN :subscriptionIds AND ' +
                '(SBQQ__Product__r.Name IN :productNames OR ' +
                '(SBQQ__Product__r.Family IN :productNames AND Package__c = null)) '
        );
        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }

    /**
     * @description LEM-17960 It is used to obtain alcohol-related subscriptions by providing the account IDs.
     * @param accountIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> selectAlcoholSubscriptionByAccount(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__Product__r.Name');
        query.selectField('SBQQ__Account__c');
        query.setCondition(
            'SBQQ__Account__c IN: accountIds AND SBQQ__Product__r.Name IN: ALCOHOL_PRODUCT_NAMES AND (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c >= TODAY) AND (SBQQ__SubscriptionEndDate__c = null OR SBQQ__SubscriptionEndDate__c >= TODAY)'
        );
        return (List<SBQQ__Subscription__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Contract's active Subscriptions' Product Families.
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> getSubscriptionsByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__Product__r.Family');
        query.setCondition(
            'SBQQ__Contract__c IN: contractIds AND (SBQQ__TerminatedDate__c = null OR SBQQ__TerminatedDate__c > TODAY) AND SBQQ__Quantity__c > 0 AND SBQQ__QuoteLine__r.SBQQ__Quote__r.Segment__c = :SMB_SEGMENT'
        );

        List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) Database.query(
            query.toSOQL()
        );
        return subscriptionList;
    }
}