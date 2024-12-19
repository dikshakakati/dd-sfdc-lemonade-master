/**
 * @author DoorDash
 * @date   02/06/2024
 * @description This is the service impl class for matching bizref and xref
 */
public inherited sharing class XrefAndBizRefMatchingServiceImpl implements IXrefAndBizRefMatchingService {
    private static final String BUSINESS_REFERENCE_CORPORATE = 'Corporate';
    private static final String BUSINESS_REFERENCE_FRANCHISE = 'Franchise';
    private static final String CANNOT_FIND_BUS_REF_ERROR_MESSAGE = 'A Business Reference with the following criteria could not be found: ';
    private static final String DASH_STRING = '-'; //Make the matching criteria easier to read for the error message.
    private static final Map<String, String> EXPERIANCE_TO_EXTERNALSOURCE_MAP = new Map<String, String>{
        'DoorDash' => 'MDS',
        'Caviar' => 'MDS',
        'Storefront' => 'MDS'
        //'Drive' => 'DriveDB',
        //'Voice' => 'DriveDB'
    };
    private Set<String> storeCurrencyIsoCodes;
    private Set<String> brandNames;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public XrefAndBizRefMatchingServiceImpl() {
        storeCurrencyIsoCodes = new Set<String>();
        brandNames = new Set<String>();
    }

    /**
     * @description LEM-12595 validate matching business ref exists for readiness check
     * @param accounts
     * @return businessRefMap
     */
    public Map<Id, String> findMatchingBizRefForReadinesCheck(List<Account> accounts) {
        Map<Id, String> accountIdToErrorMessage = new Map<Id, String>();
        Set<String> businessVerticalIds = getBusinessVerticals(accounts);
        Map<String, Business_Reference__c> businessRefMap = getBusinessReferencesByMatchingKey(
            businessVerticalIds
        );
        for (Account storeAccount : accounts) {
            Set<String> externalSources = getExternalSourceFromAccount(storeAccount);
            for (String externalSource : externalSources) {
                if (String.isBlank(externalSource)) {
                    continue;
                }
                Business_Reference__c bizref = matchTheBizRefWithAccountByExternalSource(
                    storeAccount,
                    businessRefMap,
                    externalSource
                );
                if (bizref == null) {
                    accountIdToErrorMessage.put(
                        storeAccount.Id,
                        getBizRefMatchingErrorDisplayMessage(storeAccount, externalSource)
                    );
                }
            }
        }
        return accountIdToErrorMessage;
    }
    /**
     * @description LEM-12595 Get Business References by Matching Business Vertical
     * @param accountBusinessVerticals
     * @return businessRefMap
     */
    @testvisible
    public Map<String, Business_Reference__c> getBusinessReferencesByMatchingKey(
        Set<String> accountBusinessVerticals
    ) {
        Map<String, Business_Reference__c> businessRefMap = new Map<String, Business_Reference__c>();
        for (
            Business_Reference__c businessRefObj : collectBusinessReferencesByStoreDetails(
                accountBusinessVerticals
            )
        ) {
            String matchingKey =
                businessRefObj.CurrencyIsoCode +
                businessRefObj.Business_Vertical__c +
                businessRefObj.External_Id_Source__c +
                businessRefObj.Default_Type__c;
            matchingKey += businessRefObj.Brand__c != null
                ? businessRefObj.Brand__r?.Name?.toUppercase()
                : '';
            businessRefMap.put(matchingKey, businessRefObj);
        }
        return businessRefMap;
    }

    /**
     * @description LEM-17673 Get Business References by Matching External Id.
     * @param businessIds
     * @return businessRefMap
     */
    @testvisible
    public Map<String, Business_Reference__c> getBusinessReferencesByMatchingBusinessId(
        Set<String> businessIds
    ) {
        Map<String, Business_Reference__c> businessRefMap = new Map<String, Business_Reference__c>();
        for (
            Business_Reference__c businessRefObj : BusinessReferencesSelector.newInstance()
                .selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(businessIds)
        ) {
            businessRefMap.put(businessRefObj.External_Id__c, businessRefObj);
        }
        return businessRefMap;
    }

    /**
     * @description It gets Business References by matching Business Vertical Ids, Brand Names
     * and Currency ISO Codes from passed Store accounts.
     * @JIRA# LEM-15747
     * @param storeAccounts
     * @return businessRefMap
     */
    public Map<String, Business_Reference__c> getBusinessReferencesByMatchingKey(
        List<Account> storeAccounts
    ) {
        Map<String, Business_Reference__c> businessRefMap = new Map<String, Business_Reference__c>();
        Set<String> accountBusinessVerticals = getBusinessVerticals(storeAccounts);
        for (
            Business_Reference__c businessRefObj : collectBusinessReferencesByStoreDetails(
                accountBusinessVerticals
            )
        ) {
            String matchingKey =
                businessRefObj.CurrencyIsoCode +
                businessRefObj.Business_Vertical__c +
                businessRefObj.External_Id_Source__c +
                businessRefObj.Default_Type__c;
            matchingKey += businessRefObj.Brand__c != null
                ? businessRefObj.Brand__r?.Name?.toUppercase()
                : '';
            businessRefMap.put(matchingKey, businessRefObj);
        }
        return businessRefMap;
    }

    /**
     * @description LEM-12595 get external source mapping from experiance field use mapping to derive.
     * @param storeAccount
     * @return externalSources
     */
    public Set<String> getExternalSourceFromAccount(Account storeAccount) {
        Set<String> externalSources = new Set<String>();

        if (String.isBlank(storeAccount.Experience__c)) {
            return externalSources;
        }
        for (String experiance : storeAccount.Experience__c.split(';')) {
            if (EXPERIANCE_TO_EXTERNALSOURCE_MAP.containsKey(experiance)) {
                externalSources.add(EXPERIANCE_TO_EXTERNALSOURCE_MAP.get(experiance));
            }
        }
        return externalSources;
    }
    /**
     * @description LEM-12595 Get Business verticals from store account
     * @param storeAccounts
     * @return businessVerticalIds
     */
    public Set<String> getBusinessVerticals(List<Account> storeAccounts) {
        Set<String> businessVerticalIds = new Set<String>();
        for (Account storeAccount : storeAccounts) {
            if (storeAccount.Business_Vertical__c != null) {
                businessVerticalIds.add(storeAccount.Business_Vertical__c);
                storeCurrencyIsoCodes.add(storeAccount.CurrencyISOCode);
                brandNames.add(storeAccount.Brand__r.Name);
            }
        }
        return businessVerticalIds;
    }
    /**
     * @description LEM-12595 run the mathcing logic to find the mathcing ref by key from account and external source
     * @param accObj
     * @param businessRefMap
     * @param eachExternSource
     * @return businessRefMap
     */
    public Business_Reference__c matchTheBizRefWithAccountByExternalSource(
        Account accObj,
        Map<String, Business_Reference__c> businessRefMap,
        String eachExternSource
    ) {
        if (businessRefMap.isEmpty()) {
            return null;
        }
        string defaultType = '';
        if (accObj.Franchise_Parent__c != null) {
            defaultType = BUSINESS_REFERENCE_FRANCHISE;
        } else {
            defaultType = BUSINESS_REFERENCE_CORPORATE;
        }
        String brandName = accObj.Brand__r.Name;
        brandName = brandName == null ? brandName : brandName.toUppercase();
        string matchingKey =
            accObj.CurrencyIsoCode +
            accObj.Business_Vertical__c +
            eachExternSource +
            defaultType +
            brandName;
        Business_Reference__c businessObj = businessRefMap.containsKey(matchingKey)
            ? businessRefMap.get(matchingKey)
            : null;
        return businessObj;
    }
    /**
     * @description LEM-4208, LEM-12595 Display error message when Business Reference not found
     * @param accObj
     * @param eachExternSource
     * @return String
     */
    public String getBizRefMatchingErrorDisplayMessage(Account accObj, String eachExternSource) {
        string defaultType = '';
        if (accObj.Franchise_Parent__c != null) {
            defaultType = BUSINESS_REFERENCE_FRANCHISE;
        } else {
            defaultType = BUSINESS_REFERENCE_CORPORATE;
        }
        String brandName = accObj.Brand__r.Name;
        string errorMessage =
            CANNOT_FIND_BUS_REF_ERROR_MESSAGE +
            accObj.CurrencyIsoCode +
            DASH_STRING +
            accObj.Business_Vertical__r.Name +
            DASH_STRING +
            eachExternSource +
            DASH_STRING +
            defaultType +
            DASH_STRING +
            brandName;

        return errorMessage;
    }

    /**
     * @description It collects Business References by matching Business Vertical Ids, Brand Names
     * and Currency ISO Codes.
     * Added additional filter criteria to reduce retrieved rows maintaining governer limits.
     * @JIRA# LEM-15747
     * @param accountBusinessVerticals
     * @return businessRefMap
     */
    private List<Business_Reference__c> collectBusinessReferencesByStoreDetails(
        Set<String> accountBusinessVerticals
    ) {
        if (!brandNames.isEmpty() && !storeCurrencyIsoCodes.isEmpty()) {
            return BusinessReferencesSelector.newInstance()
                .selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    accountBusinessVerticals,
                    brandNames,
                    storeCurrencyIsoCodes
                );
        }
        return BusinessReferencesSelector.newInstance()
            .selectByBusinessVerticals(accountBusinessVerticals);
    }
}