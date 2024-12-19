/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Selector class for Merchant Orders object.
 */
public inherited sharing class MerchantOrdersSelector extends fflib_SObjectSelector implements IMerchantOrdersSelector {
    private static final String PRODUCT_FAMILY_TABLET = 'Tablet';

    /**
     * @description Default constructor for the class
     * @return IMerchantOrdersSelector
     */
    public static IMerchantOrdersSelector newInstance() {
        return (IMerchantOrdersSelector) Application.Selector.newInstance(MX_Order__c.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return MX_Order__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Merchant Order
     * @JIRA# LEM-13506
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            MX_Order__c.Account__c,
            MX_Order__c.Merchant_Address__c,
            MX_Order__c.Contact__c,
            MX_Order__c.Internal_Deployment__c,
            MX_Order__c.Last_Tracked_Update_Time__c,
            MX_Order__c.Legacy_ID__c,
            MX_Order__c.Name,
            MX_Order__c.Printer_IMEI__c,
            MX_Order__c.Product_Bundle__c,
            MX_Order__c.Reason_for_Replacement__c,
            MX_Order__c.Replacement_Reason_Other__c,
            MX_Order__c.Shipment_Status__c,
            MX_Order__c.Shipment_Status_Description__c,
            MX_Order__c.Shipping_Carrier__c,
            MX_Order__c.Shipping_Type__c,
            MX_Order__c.Status__c,
            MX_Order__c.Store_Order_Protocol__c,
            MX_Order__c.Tablet_IMEI__c,
            MX_Order__c.Tracking_Number__c,
            MX_Order__c.Type__c,
            MX_Order__c.Type_Of_Request__c,
            MX_Order__c.Vendor__c,
            MX_Order__c.Work_Order__c,
            MX_Order__c.Work_Order_Type__c,
            MX_Order__c.Work_Plan__c
        };
    }

    /**
     * @description It is used to query the list of Mx Orders based on passed Ids.
     * @JIRA# LEM-13497
     * @param mxOrderIds
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectById(Set<Id> mxOrderIds) {
        fflib_QueryFactory merchantOrderQuery = newQueryFactory().setCondition('Id IN :mxOrderIds');
        return (List<Mx_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }

    /**
     * @description It queries Merchant Orders with related details
     * based on passed Merchant Order Ids.
     * @JIRA# LEM-13506
     * @param merchantOrderIds
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectMerchantOrderRelatedDetailsById(Set<Id> merchantOrderIds) {
        fflib_QueryFactory merchantOrderQuery = newQueryFactory()
            .selectField('Account__r.Name')
            .selectField('Account__c')
            .selectField('Type__c')
            .selectField('Type_Of_Request__c')
            .selectField('Name')
            .selectField('Vendor__c')
            .selectField('Reason_for_Replacement__c')
            .selectField('Replacement_Reason_Other__c')
            .selectField('Account__r.Deck_Rank__c')
            .selectField('Product_Bundle__r.Name')
            .selectField('Contact__r.Email')
            .selectField('Contact__r.FirstName')
            .selectField('Contact__r.LastName')
            .selectField('Contact__r.MobilePhone')
            .selectField('Contact__r.Phone')
            .selectField('Shipping_Address__c')
            .selectField('Shipping_Address__City__s')
            .selectField('Shipping_Address__PostalCode__s')
            .selectField('Shipping_Address__StateCode__s')
            .selectField('Shipping_Address__CountryCode__s')
            .selectField('Tracking_Number__c')
            .selectField('Shipping_Carrier__c')
            .selectField('Shipping_Type__c')
            .selectField('Work_Order_Sub_Type__c')
            .setCondition('Id IN :merchantOrderIds');
        new MerchantOrderItemsSelector()
            .addQueryFactorySubselect(merchantOrderQuery, 'Merchant_Order_Items__r')
            .selectField('Product__r.Language__c')
            .selectField('Product__r.StockKeepingUnit')
            .selectField('Identifier__c')
            .selectField('Quantity__c')
            .selectField('Language__c')
            .selectField('Password__c')
            .selectField('Product__r.Family')
            .selectField('Username__c')
            .selectField('Product__r.Name')
            .selectField('Id');
        return (List<MX_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }

    /**
     * @description It is used to query the list of Mx Orders when related Work Order Ids are passed.
     * @param workOrderIds
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectByWorkOrderIds(Set<Id> workOrderIds) {
        /* It is used to query the list of Merchant Orders tagged to the Work Order Ids passed.
         * It can be run by any user which may not have access to the objects used in the query.
         */
        ignoreCRUD();
        fflib_QueryFactory merchantOrderQuery = newQueryFactory()
            .setCondition('Work_Order__c IN :workOrderIds');
        return (List<Mx_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }

    /**
     * @description It queries Merchant Orders with photoshoot details
     * based on passed Merchant Order Ids.
     * @JIRA# LEM-13499
     * @param merchantOrderIds
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectPhotoshootDetailsByMxOrderIds(Set<Id> merchantOrderIds) {
        fflib_QueryFactory merchantOrderQuery = newQueryFactory()
            .selectField('Account__c')
            .selectField('Menu_Source_for_Photoshoot__c')
            .selectField('Name')
            .selectField('Photoshoot_Review_Notes_Tags__c')
            .selectField('Vendor__c')
            .selectField('Product_Bundle__r.Name')
            .selectField('Work_Order__r.Store_Location_for_Photoshoot__r.Name')
            .selectField('Work_Order__r.Photoshoot_Date__c')
            .selectField('Work_Order__r.Photoshoot_Time__c')
            .selectField('Work_Order__r.Duration')
            .selectField('Work_Order__r.Creation_Source__c')
            .selectField('Contact__r.Email')
            .selectField('Contact__r.FirstName')
            .selectField('Contact__r.LastName')
            .selectField('Contact__r.MobilePhone')
            .selectField('Contact__r.Phone')
            .selectField('Merchant_Address__c')
            .selectField('Account__r.Time_Zone__c')
            .selectField('Account__r.Time_Zone_Backend__c')
            .setCondition('Id IN :merchantOrderIds');
        return (List<MX_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }

    /**
     * @description It returns the query locator to fetch the Merchant Orders
     * with latest return label attachments.
     * @JIRA# LEM-14703
     * @param bindingVariables
     * @return Database.QueryLocator
     */
    public Database.QueryLocator queryLocatorMxOrdersWithReturnLabels(
        Map<String, Object> bindingVariables
    ) {
        fflib_QueryFactory merchantOrderQuery = newQueryFactory(false)
            .selectField('Return_Label_Status__c')
            .selectField('Contact__c')
            .selectField('Contact__r.Email')
            .selectField('Contact__r.Name')
            .selectField('Vendor__c')
            .setCondition('Return_Label_Status__c IN :returnLabelStatus');
        new MerchantOrderItemsSelector()
            .addQueryFactorySubselect(merchantOrderQuery, 'Merchant_Order_Items__r', false)
            .selectField('Product__r.Name');
        new ContentDocumentLinkSelector()
            .addQueryFactorySubselect(merchantOrderQuery, 'ContentDocumentLinks')
            .selectField('ContentDocumentId')
            .selectField('LinkedEntityId')
            .selectField('ContentDocument.FileType')
            .selectField('ContentDocument.Title')
            .selectField('SystemModstamp')
            .setOrdering('SystemModstamp', fflib_QueryFactory.SortOrder.DESCENDING);
        return Database.getQueryLocatorWithBinds(
            merchantOrderQuery.toSOQL(),
            bindingVariables,
            AccessLevel.USER_MODE
        );
    }

    /**
     * @description It is used to query Merchant orders using the passed Work Plan Ids.
     * @param workPlanIds
     * @JIRA# LEM-13492
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectByWorkPlanIds(Set<Id> workPlanIds) {
        fflib_QueryFactory merchantOrderQuery = newQueryFactory(false)
            .selectField('Photoshoot_Assignment_ID__c')
            .selectField('Photoshoot_Date__c')
            .selectField('Photoshoot_Pictures_URL__c')
            .selectField('Photoshoot_Time__c')
            .selectField('Photoshoot_URL__c')
            .selectField('Order_Status_Description__c')
            .setCondition('Work_Plan__c IN :workPlanIds');
        return (List<MX_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }

    /**
     * @description It is used to query Merchant orders using the passed Work Step Ids.
     * @param workStepIds
     * @param sObjectFields
     * @JIRA# LEM-15573
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectByWorkStepIds(Set<Id> workStepIds, Set<String> sObjectFields) {
        fflib_QueryFactory merchantOrderQuery = newQueryFactory()
            .selectField('Work_Step__c')
            .selectFields(sObjectFields)
            .setCondition('Work_Step__c IN :workStepIds');
        return (List<MX_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }

    /**
     * @description It is used to query Merchant orders using the passed Merchant Order Names.
     * @param mxOrderNames
     * @JIRA# LEM-17073
     * @return List<MX_Order__c>
     */
    public List<MX_Order__c> selectByName(Set<String> mxOrderNames) {
        // LEM-18563 - Bypassed CRUD check for this query only during Trigger execution.
        if (Trigger.isExecuting) {
            ignoreCRUD();
        }
        fflib_QueryFactory merchantOrderQuery = newQueryFactory()
            .setCondition('Name IN :mxOrderNames');
        return (List<MX_Order__c>) Database.query(merchantOrderQuery.toSOQL());
    }
}
