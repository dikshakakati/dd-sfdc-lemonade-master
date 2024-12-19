/**
 * @author DoorDash
 * @date 06/21/2022
 * @description LEM-1486 Controller class for displaying atttributes on Quote Line Drawer
 * @description LEM-6458 Refactored the code to make it Product-Package specific
 */
public with sharing class DisplayQuoteLineAttributesController {
    @testVisible
    private static Map<String, List<String>> optionalAttributesMap;
    @testVisible
    private static Map<String, List<String>> requiredAttributesMap;
    private static string prodPackage;
    public static string parentQuoteLineId;
    @testVisible
    private static Map<String, List<String>> activePriceAttributesMap;
    private static List<String> activePriceFieldAPI = new List<String>{
        'Active_Fee__c',
        'Active_Commission__c'
    };
    private final static string DELIVERY_PRODUCT_CODE = '10033';
    private final static string ALCOHOL_DELIVERY_PRODUCT_CODE = '10061';
    private final static string PACKAGE_SOF = 'Small Order Fulfillment (SOF)';
    private final static string PACKAGE_LOF = 'Large Order Fulfillment (LOF)';
    private final static string PACKAGE_MP = 'Marketplace'; //BASD-54374
    private final static string PACKAGE_CAVIAR = 'Caviar';
    private final static string PACKAGE_PREMIER = 'Premier Package';
    private final static string PACKAGE_PLUS = 'Plus Package';
    private final static string PACKAGE_BASIC = 'Basic Package';
    private final static string PACKAGE_SELF_DELIVERY = 'Self Delivery';
    private final static string APPLICABLE_SEGMENT_VALUE_ALL = 'All';
    private static string packageProduct;
    public static string quoteAccountSegment;
    private final static string ACCOUNT_SEGMENT_SMB = 'SMB';
    private final static string ACCOUNT_SEGMENT_MIDMARKET = 'Mid-Market';
    private final static string ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';

    /**
     * @description Return the Map with Key as Product Code + Package Name and Values QuoteLineAttributes
     * @param prodCode
     * @param pkgName
     * @param accountSegment
     * @return QuoteLineAttributesWrapper
     */
    @AuraEnabled(cacheable=true)
    public static QuoteLineAttributesWrapper getQLProductsWithAttributes(
        String prodCode,
        String pkgName,
        String accountSegment
    ) {
        optionalAttributesMap = new Map<String, List<String>>();
        requiredAttributesMap = new Map<String, List<String>>();
        activePriceAttributesMap = new Map<String, List<String>>();
        quoteAccountSegment = (accountSegment == ACCOUNT_SEGMENT_MIDMARKET
            ? ACCOUNT_SEGMENT_ENTERPRISE
            : accountSegment);
        List<Quote_Line_Drawer_Attributes__mdt> quoteLineAttributeList = QuoteLineDrawAttributesSelector.newInstance()
            .selectQLAttributesByProductCode(prodCode);
        try {
            if (!quoteLineAttributeList.isEmpty()) {
                for (
                    Quote_Line_Drawer_Attributes__mdt quoteLineAttribute : quoteLineAttributeList
                ) {
                    prodPackage = returnKey(
                        prodCode,
                        pkgName,
                        quoteLineAttribute.Eligible_Packages__c,
                        quoteLineAttribute.Eligible_For_Product__c
                    );
                    if (
                        String.isBlank(prodPackage) ||
                        String.isBlank(quoteLineAttribute.Field_API_Name__c)
                    ) {
                        continue;
                    }
                    checkEligible(
                        quoteLineAttribute,
                        prodPackage,
                        activePriceAttributesMap,
                        requiredAttributesMap,
                        optionalAttributesMap
                    );
                }
            }
            return new QuoteLineAttributesWrapper(
                optionalAttributesMap,
                requiredAttributesMap,
                activePriceAttributesMap
            );
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @description Return the Map with Key as Product Code + Package Name and Values QuoteLineAttributes

     * @param quoteLineAttribute
     * @param prodPackage
     * @param activePriceAttributesMap
     * @param requiredAttributesMap
     * @param optionalAttributesMap
     */

    public static void checkEligible(
        Quote_Line_Drawer_Attributes__mdt quoteLineAttribute,
        String prodPackage,
        Map<String, List<String>> activePriceAttributesMap,
        Map<String, List<String>> requiredAttributesMap,
        Map<String, List<String>> optionalAttributesMap
    ) {
        Set<String> segmentsToValidate = new Set<String>{ APPLICABLE_SEGMENT_VALUE_ALL };
        segmentsToValidate.add(quoteAccountSegment);
        if (isAttributeApplicableToDisplay(quoteLineAttribute, segmentsToValidate)) {
            if (
                quoteAccountSegment != ACCOUNT_SEGMENT_SMB &&
                activePriceFieldAPI.contains(quoteLineAttribute.Field_API_Name__c)
            ) {
                activePriceAttributesMap.putAll(
                    returnMapValues(
                        activePriceAttributesMap,
                        prodPackage,
                        quoteLineAttribute.Field_API_Name__c
                    )
                );
                activePriceAttributesMap.remove(null);
            } else if (segmentsToValidate.contains(quoteLineAttribute.Required_for_Segment__c)) {
                requiredAttributesMap.putAll(
                    returnMapValues(
                        requiredAttributesMap,
                        prodPackage,
                        quoteLineAttribute.Field_API_Name__c
                    )
                );
                requiredAttributesMap.remove(null);
            } else {
                optionalAttributesMap.putAll(
                    returnMapValues(
                        optionalAttributesMap,
                        prodPackage,
                        quoteLineAttribute.Field_API_Name__c
                    )
                );
                optionalAttributesMap.remove(null);
            }
        }
    }
    /**
     * @description Return the prodPackage key
     * @return String
     * @param prodCode
     * @param pkgName
     * @param eligiblePackages
     * @param eligibleForProduct
     */
    public static String returnKey(
        String prodCode,
        String pkgName,
        String eligiblePackages,
        Boolean eligibleForProduct
    ) {
        if (
            String.isNotBlank(pkgName) &&
            String.isNotBlank(eligiblePackages) &&
            (eligiblePackages.Split('; ')).contains(pkgName)
        ) {
            return prodCode + pkgName;
        } else if (String.isBlank(pkgName) && eligibleForProduct) {
            return prodCode;
        } else {
            return '';
        }
    }
    /**
     * @description Return the Map with Key as Product Code and Values QuoteLineAttributes
     * @return Map<String, List<String>>
     * @param fieldAttributesMap
     * @param prodPackage
     * @param fieldApiName
     */
    public static Map<String, List<String>> returnMapValues(
        Map<String, List<String>> fieldAttributesMap,
        String prodPackage,
        String fieldApiName
    ) {
        if (fieldAttributesMap.containsKey(prodPackage)) {
            fieldAttributesMap.get(prodPackage).add(fieldApiName);
        } else {
            fieldAttributesMap.put(prodPackage, new List<String>{ fieldApiName });
        }
        return fieldAttributesMap;
    }

    /** @author DD
     * @date 07/05/2022
     * @description Parent wrapper for QuoteLineAttributesWrapper lightning web component.
     */
    public class QuoteLineAttributesWrapper {
        @AuraEnabled
        public Map<String, List<String>> optionalFields;
        @AuraEnabled
        public Map<String, List<String>> requiredFields;
        @AuraEnabled
        public Map<String, List<String>> activePrices;

        /**
         * @description Parameterized constructor to assign value to the variables.
         * @param optionalFields
         * @param requiredFields
         * @param activePrices
         */
        public QuoteLineAttributesWrapper(
            Map<String, List<String>> optionalFields,
            Map<String, List<String>> requiredFields,
            Map<String, List<String>> activePrices
        ) {
            this.optionalFields = optionalFields;
            this.requiredFields = requiredFields;
            this.activePrices = activePrices;
        }
    }
    /**
     * @description Return the Map with Key as Product Code and Values QuoteLineAttributes
     * @param quoteId
     * @param parentProductName
     * @param quoteLineId
     * @param lineNumber
     * @param requiredBy
     * @param groupId
     */
    @AuraEnabled
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void insertParentProduct(
        String quoteId,
        String parentProductName,
        String quoteLineId,
        Integer lineNumber,
        String requiredBy,
        String groupId
    ) {
        try {
            List<Product2> product = findParentProduct(parentProductName);
            if (product.isEmpty()) {
                return;
            }
            String parentQuoteLineId = requiredBy == null
                ? insertNewQuoteLine(quoteId, product.get(0).Id, lineNumber, groupId)
                : requiredBy;
            updateQuoteLineWithRequiredBy(quoteLineId, parentQuoteLineId);
        } catch (Exception error) {
            Logger.publish(LogEntry.newExceptionLog(error, LogEntry.SeverityLevel.HIGH));
        }
    }

    private static List<Product2> findParentProduct(String parentProductName) {
        Set<String> productByProductName = new Set<String>{ parentProductName };
        return ProductsSelector.newInstance().selectProductByProductName(productByProductName);
    }

    private static String insertNewQuoteLine(
        String quoteId,
        Id parentProductId,
        Integer lineNumber,
        String groupId
    ) {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quoteId;
        quoteLine.SBQQ__Product__c = parentProductId;
        quoteLine.SBQQ__Number__c = lineNumber - 1;
        quoteLine.SBQQ__Group__c = groupId;
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(quoteLine);
        commitUnitOfWork(uow);
        return quoteLine.Id;
    }
    private static void updateQuoteLineWithRequiredBy(String quoteLineId, String requiredById) {
        SBQQ__QuoteLine__c quoteLinesToUpdate = new SBQQ__QuoteLine__c();
        quoteLinesToUpdate.Id = quoteLineId;
        quoteLinesToUpdate.SBQQ__RequiredBy__c = requiredById;
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerDirty(quoteLinesToUpdate);
        commitUnitOfWork(uow);
    }

    private static void commitUnitOfWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description It is used to check whether an attribute is applicable to be displayed for an
     * input in the magic wand.
     * @param quoteLineAttribute
     * @param segmentsToValidate
     * @return Boolean
     */
    private static Boolean isAttributeApplicableToDisplay(
        Quote_Line_Drawer_Attributes__mdt quoteLineAttribute,
        Set<String> segmentsToValidate
    ) {
        return (String.isNotBlank(quoteLineAttribute.Field_API_Name__c) &&
        (segmentsToValidate.contains(quoteLineAttribute.Applicable_Segment__c)));
    }
}