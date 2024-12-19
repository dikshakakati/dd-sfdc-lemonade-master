/**
 * @author Deloitte
 * @date 17/05/2022
 * @description Domain Class for Merchant service Object
 */
public inherited sharing class MerchantServices extends fflib_SObjects implements IMerchantServices {
    private static final String MERCHANT_SERVICE_CLASS = 'MerchantService';
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';
    private static final String MX_AGREED_TO_PRODUCT_NO = 'No';
    public static final String PRODUCT_NAME_DELIVERY = 'Delivery';
    public static final String PRODUCT_NAME_PICKUP = 'Pickup';
    public static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    public static final String PRODUCT_NAME_ALCOHOL_PICKUP = 'Alcohol Pickup';
    private static final String LOG_SERVICE = 'Quote Changes';
    private static final String LOG_DOMAIN = 'CPQ';
    public static final String PACKAGE_EXCLUSION = System.Label.PackageExclusion;
    private static final String SERVICE_STATUS_DEACTIVATED = 'Deactivated';
    private static final String DELIMITER_COMMA = ',';
    private static final String NO = 'No';

    /**
     * @description This method is used to return the IMerchantServices interface
     * @param recordList - MerchantServices record list
     * @return IAccounts - Returns IAccounts Interface
     */
    public static IMerchantServices newInstance(List<Merchant_Service__c> recordList) {
        return (IMerchantServices) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public MerchantServices(List<Merchant_Service__c> sObjectList) {
        super(sObjectList, Schema.Merchant_Service__c.SObjectType);
    }

    /**
     * @description Filters out records with a given product family value in the set
     * @param strings Product Family name to filter out
     * @return Instance of IMerchantServices with remaining records
     */
    public IMerchantServices filterByProductFamilyNotInSet(Set<String> strings) {
        Merchant_Service__c[] results = new List<Merchant_Service__c>{};
        for (Merchant_Service__c obj : (Merchant_Service__c[]) getRecords()) {
            //Check against the order product or the bundle that the order product is in
            if (
                (strings.contains(obj.Order_Product__r.Product2.Family) == false) &&
                (strings.contains(obj.Order_Product__r.SBQQ__BundleRoot__r.Product2.Family) ==
                false)
            ) {
                results.add(obj);
            }
        }
        return new MerchantServices(results);
    }
    /**
     * @description Filters for records with a given product family value
     * @param strings Product Family name to filter for
     * @return Instance of IMerchantServices with remaining records
     */
    public IMerchantServices filterByProductFamilyInSet(Set<String> strings) {
        Merchant_Service__c[] results = new List<Merchant_Service__c>{};
        for (Merchant_Service__c obj : (Merchant_Service__c[]) getRecords()) {
            //Check against the order product or the bundle that the order product is in
            if (
                (strings.contains(obj.Order_Product__r.Product2.Family) == true) ||
                (strings.contains(obj.Order_Product__r.SBQQ__BundleRoot__r.Product2.Family) == true)
            ) {
                results.add(obj);
            }
        }
        return new MerchantServices(results);
    }
    
    /**
     * @description The method is used to deactivate the existing 
     * Merchant Services for Core Products in SMB when it is 
     * part of package exclusion.
     * @JIRA #LEM-16198
     */
    public void inactivateExistingMxServicesOnCoreProducts() {
    	fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
    	Set<Id> storeAccountIds = new Set<Id>();
    	Set<Id> sourceQuoteIds = new Set<Id>();
    	Set<Id> merchantServiceIds = new Set<Id>();
    	Set<String> packagesToExclude = parsePackagesToExclude();
    	List<Merchant_Service__c> merchantServices = getMerchantServicesToProcess(storeAccountIds, merchantServiceIds, packagesToExclude);

    	if (!merchantServices.isEmpty()) {
        	populateSourceQuoteIds(merchantServices, merchantServiceIds, sourceQuoteIds);
        	updateMerchantServices(uow, merchantServices, sourceQuoteIds);
        	commitUnitOfWork(uow);
    	}
	}

	private Set<String> parsePackagesToExclude() {
    	Set<String> packagesToExclude = new Set<String>();
    	for (String serviceName : Package_Exclusion.split(DELIMITER_COMMA)) {
        	packagesToExclude.add(serviceName.trim());
    	}
    	return packagesToExclude;
	}

	private List<Merchant_Service__c> getMerchantServicesToProcess(Set<Id> storeAccountIds, Set<Id> merchantServiceIds, Set<String> packagesToExclude) {
    	for (Merchant_Service__c eachMxService : (List<Merchant_Service__c>) getRecords()) {
        	if (eachMxService.Account__c != NULL) {
            	if (packagesToExclude.contains(eachMxService.Name)) {
                	storeAccountIds.add(eachMxService.Account__c);
            	}
            	merchantServiceIds.add(eachMxService.Id);
        	}
    	}
    	return MerchantSelector.newInstance().selectExistingMerchantServiceToExcludeByStoreIdsAndPackage(storeAccountIds, merchantServiceIds, packagesToExclude);
	}

	private void populateSourceQuoteIds(List<Merchant_Service__c> merchantServices, Set<Id> merchantServiceIds, Set<Id> sourceQuoteIds) {
    	for (Merchant_Service__c eachMxService : merchantServices) {
        	if (merchantServiceIds.contains(eachMxService.Id)) {
            sourceQuoteIds.add(eachMxService.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c);
        	}
    	}
	}

	private void updateMerchantServices(fflib_ISObjectUnitOfWork uow, List<Merchant_Service__c> merchantServices, Set<Id> sourceQuoteIds) {
    	for (Merchant_Service__c eachMxService : merchantServices) {
        	if (!sourceQuoteIds.contains(eachMxService.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c)) {
            		uow.registerDirty(new Merchant_Service__c(
                		Id = eachMxService.Id,
                		Status__c = SERVICE_STATUS_DEACTIVATED,
                		Mx_Agreed_to_Product__c = NO
            		));
        	}
    	}
	}

	private void commitUnitOfWork(fflib_ISObjectUnitOfWork uow) {
    	try {
        	uow.commitWork();
    	} 	
        catch (Exception uowException) {
        	Logger.publish(
            	LogEntry.newExceptionLog(uowException, LogEntry.SeverityLevel.HIGH)
        	);
    	}
	}
    /**
     * @description Sets the Mx Agreed to Product Field to Yes
     * @param value available Values 'Yes' or 'No'
     * @return Instance of MerchantServices with the updated records
     */
    public IMerchantServices setMxAgreedToProductValue(String value) {
        if ((value == MX_AGREED_TO_PRODUCT_YES) || (value == MX_AGREED_TO_PRODUCT_NO)) {
            setFieldValue(Merchant_Service__c.Mx_Agreed_to_Product__c, value);
            setFieldValue(Merchant_Service__c.Active_Rates_Applied__c, false);
        }
        return this;
    }

    /**
     * @description Filters for records with a given product family value
     * @param accountIdDeselectedServicesMap map of deselected services
     * @param useFranchiseParent determine the account by Franchise parent if true.
     * @return Instance of IMerchantServices with updated MxAgreed records
     * @JIRA# LEM-13995
     */
    public IMerchantServices filterDeselectedServices(
        Map<Id, Map<String, String>> accountIdDeselectedServicesMap,
        Boolean useFranchiseParent
    ) {
        Merchant_Service__c[] results = new List<Merchant_Service__c>{};
        for (Merchant_Service__c obj : (Merchant_Service__c[]) getRecords()) {
            Id accountId = useFranchiseParent ? obj.Account__r.Franchise_Parent__c : obj.Account__c;
            if (!accountIdDeselectedServicesMap.containsKey(accountId)) {
                continue;
            }
            Map<String, String> deselectedServicesMap = accountIdDeselectedServicesMap.get(
                accountId
            );
            String packageName = obj.Order_Product__r.SBQQ__BundleRoot__c == null
                ? obj.Order_Product__r.Product2.Name
                : obj.Order_Product__r.SBQQ__BundleRoot__r.Product2.Name;
            if (deselectedServicesMap.containskey(packageName)) {
                String deselectedServices = deselectedServicesMap.get(packageName);
                if (deselectedServices != null && isServiceDeselected(obj, deselectedServices)) {
                    setMxAgreedToProductVal(obj, MX_AGREED_TO_PRODUCT_NO);
                } else {
                    setMxAgreedToProductVal(obj, MX_AGREED_TO_PRODUCT_YES);
                }
            } else {
                setOtherProducts(obj);
            }
            results.add(obj);
        }
        return new MerchantServices(results);
    }

    /**
     * @description LEM-13995 Setting other products Mx Agreed Product after verifying package with
     * Products
     * @param obj
     */
    private void setOtherProducts(Merchant_Service__c obj) {
        Boolean isEligible = obj.Order_Product__r.SBQQ__BundleRoot__c == null
            ? obj.Order_Product__r.Product2.Package_Eligible_For_Nintex_Options__c
            : obj.Order_Product__r.SBQQ__BundleRoot__r.Product2.Package_Eligible_For_Nintex_Options__c;
        if (isEligible) {
            setMxAgreedToProductVal(obj, MX_AGREED_TO_PRODUCT_NO);
        } else {
            setMxAgreedToProductVal(obj, MX_AGREED_TO_PRODUCT_YES);
        }
    }
    /*
     * @description determines if a service is deselected.
     * @param obj the merchant Service in question
     * @param deselectedServices the of deselected services
     */
    private Boolean isServiceDeselected(Merchant_Service__c obj, String deselectedServices) {
        Boolean deselected = false;
        String shortenedProduct2Name = getShortenedProductName(obj.Order_Product__r.Product2.Name);
        if (
            deselectedServices != null &&
            deselectedServices.containsIgnoreCase(shortenedProduct2Name)
        ) {
            deselected = true;
        }
        return deselected;
    }

    /**
     * @description Gets the account Ids from the map
     * @param productName
     * @return String
     */
    private static String getShortenedProductName(String productName) {
        String shortenedProduct2Name = productName;
        if (shortenedProduct2Name == PRODUCT_NAME_ALCOHOL_DELIVERY) {
            shortenedProduct2Name = PRODUCT_NAME_DELIVERY;
        }
        if (shortenedProduct2Name == PRODUCT_NAME_ALCOHOL_PICKUP) {
            shortenedProduct2Name = PRODUCT_NAME_PICKUP;
        }
        return shortenedProduct2Name;
    }

    /**
     * @description verify whether the process is manage pricing or not
     * @param merchantServicesList
     * @return Boolean
     */
    public static boolean verifyManagePricingProcess(
        List<Merchant_Service__c> merchantServicesList
    ) {
        if (merchantServicesList.isEmpty()) {
            return false;
        }
        return true;
    }

    /**
     * @description Publish Notifier platform event method
     */
    public void publishNotifierEvent() {
        Set<Id> merchantServiceRecordIds = new Set<Id>();
        for (Merchant_Service__c eachMerchantService : (List<Merchant_Service__c>) getRecords()) {
            merchantServiceRecordIds.add(eachMerchantService.Id);
        }
        NotifierEventsService.publishEvents(
            new Map<String, String>{
                'UPDATE_BUSINESS_ID_MERCHANT_SERVICE' => JSON.serialize(merchantServiceRecordIds)
            }
        );
    }

    /**
     * @description sets Mx_Agreed_to_Product__c value on Merchant_Service__c
     * @param obj
     * @param agreedToProductVal
     */
    private void setMxAgreedToProductVal(Merchant_Service__c obj, String agreedToProductVal) {
        obj.Mx_Agreed_to_Product__c = agreedToProductVal;
        obj.Active_Rates_Applied__c = false;
    }
    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return MerchantServices - List of Merchant Services
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (MerchantServices.constructorMock != null) {
                return (fflib_SObjects) MerchantServices.constructorMock.construct(objectList);
            }
            return new MerchantServices((List<SObject>) objectList);
        }
    }
}
