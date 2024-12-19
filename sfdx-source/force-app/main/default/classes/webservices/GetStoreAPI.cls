/**
 * @date 06/05/2023
 * @description Webservice to return store details based on store Id
 * Suppressing FieldNamingConventions PMD warnings because the variables created are part of a defined JSON
 * https://docs.google.com/document/d/1LY-3C3_VZT355r6iz7UW1IuLpVbVMCTDHigUvhh9J38/edit
 */
@SuppressWarnings('PMD.FieldNamingConventions')
@RestResource(urlMapping='/GetStores')
global with sharing class GetStoreAPI {

    static StoreRequestWrapper storeList = new StoreRequestWrapper();
    static Map<String, String> xRefToStoreIdMap = new Map<String, String>();
    static Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes =
        new Map<String, Country_Attributes_Mapping__mdt>();
    private static String defaultCorporateBusinessId = '';
    private static String defaultFranchiseBusinessId = '';
    private static String COO_GET_STORE_API_MAX_STORE_NUMBER = 'COO_Get_Store_API_Max_Store_Number';
    private static final String TYPE_CORPORATE = 'Corporate';
    private static final String TYPE_FRANCHISE = 'Franchise';
    private static final String STATUS_SUCCESS = 'Success';
    private static Map<String, Account> storeMap = new Map<String, Account>();
    private static Static_Configurations__mdt storeMaxStoreNumber;
    private static final String GENERIC_LOG_SERVICE = 'GetStoreAPI';
    private static final String GENERIC_LOG_DOMAIN = 'Onboarding';
    private static final String GENERIC_LOG_LOGLEVEL = 'Information';
    private static final String GENERIC_LOG_CATEGORY = 'Information';
    private static Map<String, Map<String, Business_Reference__c>> businessReferenceMap = new Map<String, Map<String, Business_Reference__c>>();

    static Set<String> alcoholProductCodes =  new Set<String>();
    static{
        for(Product2 prod: [SELECT Id, ProductCode FROM Product2 WHERE NAME like '%alcohol%' AND IsActive = true WITH SECURITY_ENFORCED]){
            alcoholProductCodes.add(prod.ProductCode);
        }
    }

    /**
     * @description Entry point for the external endpoint to call this class
     * @param storeIds Takes an input of a list of storeIds, finds the XRef__c records for them
     *       as well as Account and related records, and returns a response that will be serialized
     * @return String serialized JSON response
     */
    @HttpPost
    global static String getRecords(String storeIds) {
        List<String> storeIdList = new List<String>();
        Set<Id> storeSFDCIds = new Set<Id>();
        storeMap = new Map<String, Account>();
        List<Account> accountList = new List<Account>();
        String payload = '';

        if (storeIds == null || storeIds == '') {
            return 'BLANK STRING NOT ACCEPTED';
        }
        storeIds= storeIds.replaceAll( '\\s+', '');
        storeIdList = storeIds.split(',');

        if (areThereTooManyStores(storeIdList.size())) {
            return 'SERVICE DOES NOT ACCEPT MORE THAN ' + Integer.valueOf(storeMaxStoreNumber.Configuration_Value__c) + ' STORE IDS';
        }

        initializeStoreToAccountMap(storeIdList);
        try {
            List<Xref__c> xrefs = XrefsSelector.newInstance().selectXrefByExternalIdOnly(storeIdList);
            for (XRef__c xRef : xrefs) {
                storeSFDCIds.add(xRef.Salesforce_Account_Name__c);
                xRefToStoreIdMap.put(xRef.External_Id__c, xRef.Salesforce_Account_Name__c);
            }
        } catch (QueryException queryException) {
            // Log error in Logger object
            Logger.publish(
                LogEntry.newExceptionLog(queryException, LogEntry.SeverityLevel.HIGH)
            );
            return getErrorMessages(queryException);
        }
        accountList = AccountsSelector.newInstance().selectRelatedChildsById(storeSFDCIds);
        initiatlizeCountryAttributeMap();

        createResponseList();

        populateStoreMap(accountList);
        populateBusinessReferenceMap();
        payload = createJsonPayload(xRefToStoreIdMap, storeMap);
        createLog(storeIds);
        return payload;
    }

    /**
     * @description Initializes the map such that if no Account record is found in the SOQL
     *         query, there is still an entry in this map, which can be iterated over for
     *         error handling purposes
     * @param storeIds contains the List of store Ids in the Map as placeholder
     */
    static void initializeStoreToAccountMap(List<String> storeIds) {
        for (String storeId: storeIds) {
            xRefToStoreIdMap.put(storeId, '');
        }
    }

    /**
     * @description Initializes the map containing Country_Attributes_Mapping__mdt records
     */
    static void initiatlizeCountryAttributeMap() {
        List<Country_Attributes_Mapping__mdt> countryAttributes = CountryAttributesMappingSelector.newInstance()
            .getAllValues();
        for (Country_Attributes_Mapping__mdt countryAttribute : countryAttributes) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
        }
    }

    /**
     * @description Creates the response, with one entry per storeId provided - if none found,
     *         an error will be filled in
     */
    static void createResponseList() {
        List<StoreWrapper> stores = new List<StoreWrapper>();
        StoreWrapper storeWrapper;
        for (String xRefId: xRefToStoreIdMap.keySet()) {
            storeWrapper = new StoreWrapper();
            storeWrapper.store_id = xRefId;
            storeWrapper.details = new StoreDetailWrapper();
            if (xRefToStoreIdMap.get(xRefId) == null || xRefToStoreIdMap.get(xRefId) == '') {
                storeWrapper.error = 'Store not found';
            } else {
                storeWrapper.error = '';
            }
            stores.add(storeWrapper);
        }
        storeList.store_list = stores;
    }

    /**
     * @description Fills out the response
     * @param xRefToStoreIdMap contains store Account Id for storeId requested
     * @param storeMap contains Store Account details and related records
     * @return String
     */
    static String createJsonPayload(Map<String, String> xRefToStoreIdMap, Map<String, Account> storeMap) {
        String payload = '';
        try {
            for (StoreWrapper storeWrapper: storeList.store_list) {
                String xRefId = storeWrapper.store_id;
                defaultCorporateBusinessId = '';
                defaultFranchiseBusinessId = '';
                Account acc = null;
                if (storeMap.get(xRefToStoreIdMap.get(xRefId)) != null) {
                    acc = storeMap.get(xRefToStoreIdMap.get(xRefId));
                } else {
                    continue;
                }

                StoreDetailWrapper storeDetailWrapper = new StoreDetailWrapper();
                storeDetailWrapper.xrefs = new List<XRefWrapper>();
                storeDetailWrapper.contacts = new List<ContactWrapper>();
                storeDetailWrapper.contracts = new List<ContractWrapper>();
                storeDetailWrapper.services = new List<ServiceWrapper>();
                storeDetailWrapper.coos = new List<COOWrapper>();

                storeDetailWrapper.record_id                = getValue(acc.Id);
                storeDetailWrapper.name                     = getValue(acc.Name);
                storeDetailWrapper.legal_business_name      = getValue(acc.Legal_Business_Name__c);
                storeDetailWrapper.merchant_supplied_id     = getValue(acc.Merchant_Supplied_ID__c);
                storeDetailWrapper.merchant_segment         = getValue(acc.Segment__c);
                storeDetailWrapper.alcohol_activated        = isAlcoholActivated(acc.Services__r);
                storeDetailWrapper.primary_vertical         = getValue(acc.Primary_Vertical__c);
                storeDetailWrapper.type                     = getValue(acc.Type);
                storeDetailWrapper.address_id               = getValue(acc.Address_Id__c);
                storeDetailWrapper.alcohol_addendum_signed  = acc.Alcohol_Addendum_Signed__c == true ? 'true':'false';
                storeDetailWrapper.alcohol_eligibility      = getValue(acc.Alcohol_Eligibility__c);
                storeDetailWrapper.alcohol_product_eligibility = getValue(acc.Alcohol_Product_Eligibility__c);
                storeDetailWrapper.menu_ui_type             = getValue(acc.Menu_UI_Type__c);

                storeDetailWrapper.brand = new BrandWrapper();
                storeDetailWrapper.brand.record_id          = getValue(acc.Brand__c);
                storeDetailWrapper.brand.name               = getValue(acc.Brand__r?.Name);

                storeDetailWrapper.franchise_parent = new AccountWrapper();
                storeDetailWrapper.franchise_parent.record_id = getValue(acc.Franchise_Parent__c);
                storeDetailWrapper.franchise_parent.name    = getValue(acc.Franchise_Parent__r?.Name);
                storeDetailWrapper.franchise_parent.type    = getValue(acc.Franchise_Parent__r?.Type);

                storeDetailWrapper.parent = new AccountWrapper();
                storeDetailWrapper.parent.record_id         = getValue(acc.ParentId);
                storeDetailWrapper.parent.name              = getValue(acc.Parent?.Name);
                storeDetailWrapper.parent.type              = getValue(acc.Parent?.Type);

                storeDetailWrapper.ultimate_parent = new AccountWrapper();
                storeDetailWrapper.ultimate_parent.record_id = getValue(acc.Ultimate_Parent_Account__c);
                storeDetailWrapper.ultimate_parent.name     = getValue(acc.Ultimate_Parent_Account__r?.Name);
                storeDetailWrapper.ultimate_parent.type     = getValue(acc.Ultimate_Parent_Account__r?.Type);

                storeDetailWrapper.xrefs.addAll(populateXrefs(acc.XRefs__r, acc));
                storeDetailWrapper.coos.addAll(getCOOs(acc.WorkOrders, 'WorkOrder'));
                storeDetailWrapper.coos.addAll(getCOOs(acc.Integration_Requests__r, 'Integration_Request__c'));
                storeDetailWrapper.brand.default_corporate_business_id = getValue(defaultCorporateBusinessId);
                storeDetailWrapper.brand.default_franchise_business_id = getValue(defaultFranchiseBusinessId);

                if (acc.AccountContactRelations != null) {
                    storeDetailWrapper.contacts.addAll(populateACR(acc.AccountContactRelations));
                }
                if (acc.Agreements__r != null) {
                    storeDetailWrapper.contracts.addAll(populateContracts(acc.Agreements__r));
                }
                storeDetailWrapper.services.addAll(populateServices(acc.Services__r));

                storeWrapper.details = storeDetailWrapper;
            }

            payload = JSON.serializePretty(storeList, true);
        } catch (Exception e) {
            Logger.publish(
                LogEntry.newExceptionLog(e, LogEntry.SeverityLevel.HIGH)
            );
        }
        return payload;
    }

    /**
     * @description Creates Log__c record for successful request completion
     * @param storeIds List of store ids as passed to the service
     * @date 2023-10-04
     * @author Nathalie Mendezona
     */
    static void createLog(String storeIds) {

        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                GENERIC_LOG_SERVICE,
                GENERIC_LOG_DOMAIN,
                GenericLogEntry.SeverityLevel.HIGH
            ).logException(
                new DmlException( 'Request was successful for stores: ' + storeIds )
            )
            .setCategory(GENERIC_LOG_CATEGORY)
            .setLogLevel(GENERIC_LOG_LOGLEVEL)
        );
    }

    /**
     * @description populates payload with XRef__c data
     * @param xRefs List of XRef__c records for the given Account
     * @param store Account going through iteration
     * @return List<XRefWrapper>
     */
    private static List<XRefWrapper> populateXrefs(List<XRef__c> xRefs, Account store) {
        List<XRefWrapper> xRefWrapperList = new List<XRefWrapper>();
        String brand = store.Brand__r?.Name;
        //LEM-16588
        String extIdSrc = '';
        for (XRef__c xref: xRefs) {
            XRefWrapper xrefWrapper         = new XRefWrapper();
            xrefWrapper.record_id           = getValue(xref.Id);
            extIdSrc = getValue(xref.External_ID_Source__c);
            xrefWrapper.source              = extIdSrc;
            xrefWrapper.store_id            = getValue(xref.External_ID__c);
            xrefWrapper.unified_store_id    = getValue(xref.Unified_Store_ID__c);
            BusinessReferenceWrapper businessRef = new BusinessReferenceWrapper();
            businessRef.business_id         = getValue(xref.Business_Reference__r?.External_Id__c);
            businessRef.business_group_id   = getValue(xref.Business_Reference__r?.Business_Group_Id__c);
            businessRef.unified_business_id = getValue(xref.Business_Reference__r?.Unified_Business_ID__c);
            businessRef.business_name       = getValue(xref.Business_Reference__r?.Business_Name__c);
            businessRef.default_type        = getValue(xref.Business_Reference__r?.Default_Type__c);
            xrefWrapper.business_reference  = businessRef;

            if (businessReferenceMap.get(brand) != null) {
                Map<String, Business_Reference__c> busRefEntry = businessReferenceMap.get(brand);
                String currencyCode = getCurrencyCode(store.BillingCountryCode);
                //LEM-16588 - Added External_Id_Source__c of store
                String key = generateKey(TYPE_CORPORATE, store.Menu_UI_Type__c, store.Primary_Vertical__c, currencyCode, extIdSrc);
                if (busRefEntry.keySet().contains(key)) {
                    defaultCorporateBusinessId = busRefEntry.get(key).External_Id__c;
                }
                key = generateKey(TYPE_FRANCHISE, store.Menu_UI_Type__c, store.Primary_Vertical__c, currencyCode, extIdSrc);
                if (busRefEntry.keySet().contains(key)) {
                    defaultFranchiseBusinessId = busRefEntry.get(key).External_Id__c;
                }

            }
            xRefWrapperList.add(xrefWrapper);
        }
        return xRefWrapperList;
    }

    static List<COOWrapper> getCOOs(List<SObject> objs, String objType){
        List<COOWrapper> coos = new List<COOWrapper>();
        COOWrapper tmp;
        switch on objType{
            when  'WorkOrder' {
                for(Sobject obj: objs){
                    tmp = new COOWrapper();
                    tmp.coo_effective_date = obj.getSObject('Account').get('Change_of_Ownership_Effective_Date__c');
                    tmp.record_id = (String) obj.get('Id');
                    coos.add(tmp);
                }
                return coos;
            }
            when  'Integration_Request__c' {
                for(Sobject obj: objs){
                    tmp = new COOWrapper();
                    tmp.coo_effective_date = obj.get('Activation_Date__c');
                    tmp.record_id = (String) obj.get('Id');
                    coos.add(tmp);
                }
                return coos;
            }
        }
        return coos;
    }

    /**
     * @description populates payload with AccountContactRelation data
     * @param acrs List of AccountContactRelation records for the given Account
     * @return List<ContactWrapper>
     */
    private static List<ContactWrapper> populateACR(List<AccountContactRelation> acrs) {
        List<ContactWrapper> contactWrapperList = new List<ContactWrapper>();
        for (AccountContactRelation acr: acrs) {
            ContactWrapper contactWrapper = new ContactWrapper();
            contactWrapper.record_id    = getValue(acr.ContactId);
            contactWrapper.first_name   = getValue(acr.Contact?.FirstName);
            contactWrapper.last_name    = getValue(acr.Contact?.LastName);
            contactWrapper.email        = getValue(acr.Contact?.Email);
            contactWrapper.role         = getValue(acr.Roles);
            contactWrapperList.add(contactWrapper);
        }
        return contactWrapperList;
    }

    /**
     * @description populates payload with Contract data
     * @param agreements List of Agreement__c records for the given Account
     * @return List<ContractWrapper>
     */
    private static List<ContractWrapper> populateContracts(List<Agreement__c> agreements) {
        List<ContractWrapper> contractWrapperList = new List<ContractWrapper>();
        for (Agreement__c ag: agreements) {
            ContractWrapper contractWrapper         = new ContractWrapper();
            contractWrapper.record_id               = getValue(ag.contract__c);
            contractWrapper.account_name            = getValue(ag.contract__r?.Account?.Name);
            contractWrapper.status                  = getValue(ag.contract__r.Status);
            contractWrapper.type                    = getValue(ag.contract__r.Contract_Type__c);
            if (ag.contract__r.StartDate != null) {
                contractWrapper.start_date          = ag.contract__r.StartDate.Year() + '-'
                                                    + ag.contract__r.StartDate.Month() + '-'
                                                    + ag.contract__r.StartDate.Day();
            } else {
                contractWrapper.start_date = '';
            }
            contractWrapper.master_service_agreement_url = getValue(ag.contract__r.Master_Supplemental_Agreement_URL__c);
            contractWrapper.franchise_suppliemental_agreement_url = getValue(ag.contract__r.Franchise_Supplemental_Agreement_URL__c);
            contractWrapper.pricing_summary_url     = getValue(ag.contract__r.Pricing_Summary_URL__c);
            contractWrapperList.add(contractWrapper);
        }
        return contractWrapperList;
    }

    /**
     * @description populates payload with Merchant_Service__c data
     * @param services List of Merchant_Service__c records for the given Account
     * @return List<ServiceWrapper>
     */
    private static List<ServiceWrapper> populateServices(List<Merchant_Service__c> services) {
        List<ServiceWrapper> serviceWrapperList = new List<ServiceWrapper>();
        for (Merchant_Service__c  service: services) {
            ServiceWrapper serviceWrapper       =  new ServiceWrapper();
            serviceWrapper.product_name         = getValue(service.Order_Product__r?.Product2?.Name);
            serviceWrapper.package_name         = getValue(service.Order_Product__r?.Package__c);
            serviceWrapper.status               = getValue(service.Status__c);
            serviceWrapper.mx_agreed_to_product = getValue(service.Mx_Agreed_to_Product__c);
            serviceWrapper.trial_commission     = String.valueOf(service.Trial_Commission__c);
            serviceWrapper.trial_fee            = String.valueOf(service.Trial_Fee__c);
            serviceWrapper.final_commission     = String.valueOf(service.Final_Commission__c);
            serviceWrapper.final_fee            = String.valueOf(service.Final_Fee__c);
            serviceWrapperList.add(serviceWrapper);
        }
        return serviceWrapperList;
    }

    static Boolean isAlcoholActivated(List<Merchant_Service__c> services){
        String pc;
        for(Merchant_Service__c service: services){
            pc = service.Order_Product__r.Product_Code__c;
            if(String.isNotBlank(pc) && alcoholProductCodes.contains(pc.right(5)) && service.Active__c == 'yes'){
                return true;
            }
        }
        return false;
    }

    /**
     * @description Populates store Accounts map
     * @param accountList List of Accounts
     */
    static void populateStoreMap(List<Account> accountList) {
        for (Account acc: accountList) {
            storeMap.put(acc.Id, acc);
        }
    }

    /**
     * @description Populates the Business References map
     */
    static void populateBusinessReferenceMap() {
        Set<String> businessReferenceNames = new Set<String>();
        for (Account acct: storeMap.values()) {
            businessReferenceNames.add(acct.Brand__r.Name);
        }

        List<Business_Reference__c> businessReferenceList = BusinessReferencesSelector.newInstance()
                                .selectByBusRefNameAndIntegrationStatusAndDefaultType(
                                    businessReferenceNames,
                                    new Set<String>{STATUS_SUCCESS},
                                    new Set<String>{TYPE_CORPORATE, TYPE_FRANCHISE});

        if (businessReferenceList == null) {
            return;
        }
        for (Business_Reference__c businessReference: businessReferenceList) {
            if (businessReferenceMap.get(businessReference.Brand__r.Name) == null) {
                businessReferenceMap.put(businessReference.Brand__r.Name, new Map<String, Business_Reference__c>{});
            }
            businessReferenceMap.get(businessReference.Brand__r.Name).put(
                //LEM-16588
                generateKey(businessReference.Default_Type__c, businessReference.Menu_UI_Type__c,
                            businessReference.Primary_Vertical__c, businessReference.CurrencyIsoCode, businessReference.External_Id_Source__c),
                businessReference);
        }
    }

        /**
     * @description Checks Custom Metadata to see if there are more stores to retrieve
     *              than is set as the maximum
     * @param storeIdListSize the size of list of store ids
     * @return Boolean
     */
    static Boolean areThereTooManyStores(Integer storeIdListSize) {
        storeMaxStoreNumber = StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(COO_GET_STORE_API_MAX_STORE_NUMBER);
        return storeIdListSize > Integer.valueOf(storeMaxStoreNumber.Configuration_Value__c) ? true : false;
    }

    /**
     * @description Generates a string that can be used as a key in a map
     * TODO Consider a configuration-based setting to easily increase key size
     * @param string1 First string
     * @param string2 Second string
     * @param string3 Third string
     * @param string4 Fourth string
     * @param string5 Fifth string - Added as a part of @jira #LEM-16588
     * @return String
     */
    static String generateKey(String string1, String string2, String string3, String string4, String string5) {
        return string1 + '-' + string2 + '-' + string3 + '-' + string4 + '-' + string5;
    }

    /**
     * @description returns the CurrencyIsoCode mapped to a given country code in the CMT
     * @date 2023-09-08
     * @param countryCode String value of the country code
     * @return String currencyIsoCode value
     */
    static String getCurrencyCode(String countryCode) {
        String currencyCode = '';
        Country_Attributes_Mapping__mdt mapping = countryToCountryAttributes.get(countryCode);
        if (mapping != null) {
            currencyCode = mapping.Currency_Code__c;
        }
        return currencyCode == null ? '' : currencyCode;
    }

    /**
     * @description Gathers the string errors and formats in a easy to read String
     * @param queryException errors from running the query
     * @return String
     */
    static String getErrorMessages(QueryException queryException) {
        String errorMessage = 'Errors with SOQL query:\n';
        for (Integer i = 0; i < queryException.getNumDml(); i++) {
            errorMessage += queryException.getDmlMessage(i) + '\n';
        }
        return errorMessage;
    }

    /**
     * @description returns an empty string if the value is null
     * @param value a data point
     * @return String
     */
    private static String getValue(String value) {
        if (value == null) {
            return '';
        }
        return value;
    }

    /**
     * @description retrieves a custom metadata type entry
     * @param metadataName the settings entry
     * @return Static_Configurations__mdt
     */
    public static Static_Configurations__mdt getMetadataRecord(String metadataName) {
        List<Static_Configurations__mdt> staticConfiguration = StaticConfigurationsSelector.newInstance()
            .selectByDeveloperName(metadataName);

        if (!staticConfiguration.isEmpty()) {
            return staticConfiguration[0];
        }
        return null;
    }

    /**
     * @description Holds the response
     */
    global class StoreRequestWrapper {
        List<StoreWrapper> store_list;
    }

    /**
     * @description Holds an entry for a given store
     */
    public class StoreWrapper {
        String store_id;
        String error;
        StoreDetailWrapper details;
    }

    /**
     * @description Holds Account specific details
     */
    @SuppressWarnings('PMD.TooManyFields')
    class StoreDetailWrapper {
        String record_id;
        String name;
        String legal_business_name;
        String merchant_supplied_id;
        String merchant_segment;
        Boolean alcohol_activated;
        String primary_vertical;
        String type;
        String address_id;
        String alcohol_addendum_signed;
        String alcohol_eligibility;
        String alcohol_product_eligibility;
        String menu_ui_type;
        BrandWrapper brand;
        AccountWrapper franchise_parent;
        AccountWrapper parent;
        AccountWrapper ultimate_parent;
        List<XRefWrapper> xrefs;
        List<ContactWrapper> contacts;
        List<ContractWrapper> contracts;
        List<ServiceWrapper> services;
        List<COOWrapper> coos;
    }

  /**
     * @description Holds XRef__c details
     */
    class XRefWrapper {
        String record_id;
        String source;
        String store_id;
        String unified_store_id;
        BusinessReferenceWrapper business_reference;
    }

  /**
     * @description Holds Business_Reference__c details
     */
    class BusinessReferenceWrapper {
        String business_id;
        String business_group_id;
        String unified_business_id;
        String business_name;
        String default_type;
    }

    /**
     * @description Holds Contact details
     */
    class ContactWrapper {
        String record_id;
        String first_name;
        String last_name;
        String email;
        String role;
    }

    /**
     * @description Holds Contract details
     */
    class ContractWrapper {
        String record_id;
        String account_name;
        String status;
        String type;
        String start_date;
        String master_service_agreement_url;
        String franchise_suppliemental_agreement_url;
        String pricing_summary_url;
    }

    /**
     * @description Holds Merchant_Service__c details
     */
    class ServiceWrapper {
        String product_name;
        String package_name;
        String status;
        String mx_agreed_to_product;
        String trial_commission;
        String trial_fee;
        String final_commission;
        String final_fee;
    }

    /**
     * @description Holds Brand__c details
     */
    class BrandWrapper {
        String record_id;
        String name;
        String default_corporate_business_id;
        String default_franchise_business_id;
    }

    /**
     * @description Holds Account details
     *         For this response, this wrapper can hold a Store's Franchise, Parent,
     *         or Ultimate Parent details
     */
    class AccountWrapper {
        String record_id;
        String name;
        String type;
    }
    /**
     * @description same store coo detail or nintex coo details
     */
    class COOWrapper {
        String record_id;
        Object coo_effective_date;
    }

}