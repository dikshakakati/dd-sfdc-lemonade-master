/**
 * @author Deloitte
 * @date 04/28/2024
 * @description Service Implementation for Merchant Order Items Service.
 */
public inherited sharing class MerchantOrderItemsServiceImpl implements IMerchantOrderItemsService {
    private static final String MARKETING_KIT_PRODUCT_FAMILY = 'Marketing Kit';
    private static final String TABLET_PRODUCT_FAMILY = 'Tablet';
    private static final String PRINTER_PRODUCT_FAMILY = 'Printer';
    private static final String BILLING_COUNTRY_CODE_CANADA = 'CA';
    private static final String BILLING_STATE_CODE_QUEBEC = 'QC';
    private static final String ENGLISH_LANGUAGE = 'English';
    private static final String FRENCH_LANGUAGE = 'French';
    private static final String LOG_CREATE_MX_ORDER_ITEMS_FAILED = 'Creation of Mx Orders Failed';
    private static final String LOG_DOMAIN = 'Onboarding';
    private static final String TYPE_RETURN = 'Return';
    private static final String TYPE_REPLACEMENT = 'Replacement';
    private static final String TYPE_NET_NEW = 'Net-New';
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';

    private enum ProductFamily {
        MARKETING_KIT_PRODUCT_FAMILY,
        TABLET_PRODUCT_FAMILY,
        PRINTER_PRODUCT_FAMILY
    }
    private static final Map<String, ProductFamily> PRODUCT_FAMILY_MAPPINGS = new Map<String, productFamily>{
        MARKETING_KIT_PRODUCT_FAMILY => ProductFamily.MARKETING_KIT_PRODUCT_FAMILY,
        TABLET_PRODUCT_FAMILY => ProductFamily.TABLET_PRODUCT_FAMILY,
        PRINTER_PRODUCT_FAMILY => ProductFamily.PRINTER_PRODUCT_FAMILY
    };

    /**
     * @description It is used to create Mx Order Items
     * @param merchantOrders
     */
    public void createMxOrderItems(List<MX_Order__c> merchantOrders) {
        Set<Id> productBundleSetIds = new Set<Id>();
        Set<String> identifiers = new Set<String> ();
        Map<String, Id> productFamilyToProductId = new Map<String, Id>();
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, List<Mx_Order_Product_Option__c>> productBundleIdtoProductOptions = new Map<Id, List<Mx_Order_Product_Option__c>>();

        for (Mx_Order__c eachMxOrder : merchantOrders) {
            productBundleSetIds.add(eachMxOrder.Product_Bundle__c);
            if(String.isNotEmpty(eachMxOrder.Printer_IMEI__c)){
                identifiers.add(eachMxOrder.Printer_IMEI__c);
            }
            if(String.isNotEmpty(eachMxOrder.Tablet_IMEI__c)){
                identifiers.add(eachMxOrder.Tablet_IMEI__c);
            }
        }
        if(!identifiers.isempty()){
            productFamilyToProductId = getExistingOrderItems(identifiers);
        }
        productBundleIdtoProductOptions = getProductBundleIdToProductOptionsMap(
            productBundleSetIds
        );
        for (MX_Order__c eachMxOrder : merchantOrders) {
            List<Mx_Order_Product_Option__c> productOptions = productBundleIdtoProductOptions.get(
                eachMxOrder.Product_Bundle__c
            );
            if (productOptions != null) {
                generateMxOrderItems(eachMxOrder, productOptions, uow, productFamilyToProductId);
            }
        }
        commitWork(uow);
    }
    private Map<String, Id> getExistingOrderItems(Set<String> identifiers){
        List<Mx_Order_Item__c> existingOrderItems = new List<Mx_Order_Item__c>();
        Map<String, Id> productFamilyToProductId = new Map<String, Id>();
        existingOrderItems = MerchantOrderItemsSelector.newInstance().selectMxOrderItemWithIdentifiersAndTypes(identifiers, new Set<String> { TYPE_REPLACEMENT, TYPE_NET_NEW });
        for(Mx_Order_Item__c ordrItem : existingOrderItems){
            productFamilyToProductId.put(ordrItem.Product__r.Family, ordrItem.Product__c);
        }
        return productFamilyToProductId;
    }
    /**
     * @description It is used to generate Mx Order Items based on passed Mx Order
     * and Mx Order Product Option.
     * @param merchantOrder
     * @param productOptions
     * @param uow
     * @param productFamilyToProductId
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    private void generateMxOrderItems(
        MX_Order__c merchantOrder,
        List<Mx_Order_Product_Option__c> productOptions,
        fflib_ISobjectUnitOfWork uow,
        Map<String, Id> productFamilyToProductId
    ) {
        for (Mx_Order_Product_Option__c eachProductOption : productOptions) {

            MX_Order_Item__c newMxOrderItem = new MX_Order_Item__c();
            //LEM-16551 - Defaulting quantity to 1.
            newMxOrderItem.Quantity__c = 1;
            newMxOrderItem.CurrencyIsoCode = eachProductOption.Product__r.CurrencyIsoCode;
            newMxOrderItem.Product__c = eachProductOption.Product__c;
            newMxOrderItem.Mx_Order__c = merchantOrder.Id;

            if(merchantOrder?.Type__c != null && merchantOrder?.Type__c?.equalsIgnoreCase(MX_ORDER_TYPE_TABLET) && (eachProductOption?.Assigned_Vendor__c != null && !eachProductOption?.Assigned_Vendor__c?.contains(merchantOrder?.vendor__c))){
                continue;
            }
            switch on PRODUCT_FAMILY_MAPPINGS.get(eachProductOption.Product__r.Family) {
                when PRINTER_PRODUCT_FAMILY {
                    // if return order and user didn't give printer IMEI, that means no need to add printer order item.
                    if(merchantOrder.Type_Of_Request__c == TYPE_RETURN && String.isEmpty(merchantOrder.Printer_IMEI__c)){
                        continue;
                    }
                    addMxOrderItemsForPrinter(merchantOrder, productFamilyToProductId, newMxOrderItem);
                }
                when TABLET_PRODUCT_FAMILY {
                    // if return order and user didn't give tablet IMEI, that means no need to add tablet order item.
                    if(merchantOrder.Type_Of_Request__c == TYPE_RETURN && String.isEmpty(merchantOrder.Tablet_IMEI__c)){
                        continue;
                    }
                    addMxOrderItemsForTablet(merchantOrder, productFamilyToProductId, newMxOrderItem);
                }
                when MARKETING_KIT_PRODUCT_FAMILY {
                    // if the mx order language is french then only add french marketing else skip the order item creation.
                    if(merchantOrder.Type__c == MX_ORDER_TYPE_TABLET && merchantOrder.preferred_language__c != eachProductOption.product__r.Language__c){
                        continue;
                    }
                }
            }
            uow.registerNew(newMxOrderItem);
        }
    }

    /**
     * @description It is used to add Mx Order Line Items for Printer Product Family.
     * @param merchantOrder
     * @param productFamilyToProductId
     * @param newMxOrderItem
     */
    private void addMxOrderItemsForPrinter(
        MX_Order__c merchantOrder,
        Map<String, Id> productFamilyToProductId,
        MX_Order_Item__c newMxOrderItem
    ) {
        // if return order get the original product, that we shipped to the mx. if not use default product from bundle
        if(merchantOrder.Type_Of_Request__c == TYPE_RETURN && productFamilyToProductId.containsKey(PRINTER_PRODUCT_FAMILY)){
            newMxOrderItem.Product__c = productFamilyToProductId.get(PRINTER_PRODUCT_FAMILY);
        }
        if (String.isNotBlank(merchantOrder?.Printer_IMEI__c)) {
            newMxOrderItem.Identifier__c = merchantOrder?.Printer_IMEI__c;
        }
    }

    /**
     * @description It is used to add Mx Order Line Items for Tablet Product Family.
     * @param merchantOrder
     * @param productFamilyToProductId
     * @param newMxOrderItem
     */
    private void addMxOrderItemsForTablet(
        MX_Order__c merchantOrder,
        Map<String, Id> productFamilyToProductId,
        MX_Order_Item__c newMxOrderItem
    ) {
         // if return order get the original product, that we shipped to the mx. if not use default product from bundle
        if(merchantOrder.Type_Of_Request__c == TYPE_RETURN && productFamilyToProductId.containsKey(TABLET_PRODUCT_FAMILY)){
            newMxOrderItem.Product__c = productFamilyToProductId.get(TABLET_PRODUCT_FAMILY);
        }
        if (String.isNotBlank(merchantOrder?.Tablet_IMEI__c)) {
            newMxOrderItem.Identifier__c = merchantOrder?.Tablet_IMEI__c;
        }
    }

    /**
     * @description It is used to commit records to the database.
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_CREATE_MX_ORDER_ITEMS_FAILED,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to get the mapping between Product Bundle Id and Product Options.
     * @param productBundles
     * @return Map<Id, List<Mx_Order_Product_Option__c>>
     */
    private Map<Id, List<Mx_Order_Product_Option__c>> getProductBundleIdToProductOptionsMap(
        Set<Id> productBundles
    ) {
        Map<Id, List<Mx_Order_Product_Option__c>> productBundleIdtoProductOptions = new Map<Id, List<Mx_Order_Product_Option__c>>();
        for (
            Mx_Order_Product_Option__c eachProductOption : ProductOptionsSelector.newInstance()
                .selectProductOptionsByProductBundle(productBundles)
        ) {
            if (
                !productBundleIdtoProductOptions.containsKey(
                    eachProductOption.Mx_Order_Product_Bundle__c
                )
            ) {
                productBundleIdtoProductOptions.put(
                    eachProductOption.Mx_Order_Product_Bundle__c,
                    new List<Mx_Order_Product_Option__c>()
                );
            }
            productBundleIdtoProductOptions.get(eachProductOption.Mx_Order_Product_Bundle__c)
                .add(eachProductOption);
        }
        return productBundleIdtoProductOptions;
    }
}
