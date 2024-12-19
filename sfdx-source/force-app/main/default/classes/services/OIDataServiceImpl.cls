/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Service implementation class for OIDataController related logic.
 */
@SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.NcssMethodCount, PMD.CyclomaticComplexity, PMD.ApexCRUDViolation, PMD.ExcessiveClassLength, PMD.NcssTypeCount, PMD.TooManyFields, PMD.AvoidDeeplyNestedIfStmts'
)
public inherited sharing class OIDataServiceImpl implements IOIDataService {
    private static final String BACKSLASH_SEPARATOR = '/';
    private static final String CLOSED_WON = 'Closed Won';
    private static final String COLON_SEPARATOR = ':';
    private static final String COUNTRY_CODE_US = 'US';
    private static final String COUNTRY_CODE_CA = 'CA';
    private static final String COUNTRY_CODE_AU = 'AU';
    private static final String COUNTRY_CODE_NZ = 'NZ';
    private static final String COUNTRY_US = 'United States';
    private static final String COUNTRY_CA = 'Canada';
    private static final String COUNTRY_AU = 'Australia';
    private static final String COUNTRY_NZ = 'New Zealand';
    private static final String DASH_SPLIT = '-';
    private static final String DRIVE_PRODUCT_ON_CONTRACT = 'Drive';
    private static final String EMPTY_STRING = '';
    private static final String EVENT_TOPIC_OI_DATA_CREATION = 'OI_DATA_PROCESSING';
    private static final String FIELD_TYPE_DATE = 'Date';
    private static final String FIELD_TYPE_NUMBER = 'Number';
    private static final String FIELD_TYPE_TIME = 'Time';
    private static final String FIELD_TYPE_CHECKBOX = 'Checkbox';
    private static final String FIELD_TYPE_ADDRESSSTATE = 'AddressState';
    private static final String FIELD_TYPE_ADDRESSCOUNTRY = 'AddressCountry';
    private static final String FORM_LANGUAGE_ENGLISH = 'en';
    private static final String FORM_TYPE_MX_FORM = 'Mx FORM';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static final String FORMIDPARAM = '?formId=';
    private static final String LOG_SERVICE_OI_DATA = 'Onboarding Inputs Data Service';
    private static final String LOG_DOMAIN_OI_DATA_CREATION = 'Onboarding Inputs Records Creation';
    private static final String MX_ONBOARDING_LINK_FIELD = 'Mx_Onboarding_Link__c';
    private static final String MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG = 'MxStateToMxFormLanguageMapping';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String OI_ATTRIBUTE_MX_FORM_PREFIX = 'Mx_Form_';
    private static final String OI_ATTRIBUTE_FIELD_HELP_TEXT_SUFFIX = '_Field_Help_Text';
    private static final String OI_ATTRIBUTE_FIELD_LABEL_SUFFIX = '_Field_Label';
    private static final String OI_SECTION_NAME_SUFFIX = '_Section_Name';
    private static final String ONBOARDING_SCENARIO_NSE = 'NSE';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String ONE_TIME_MX_LINK_STATIC_CONFIG = 'One_Time_Mx_Link';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String ORDER_PROTOCOL_TABLET = 'Tablet';
    private static final String DUPLICATE_PROCESSED = 'Duplicate Processed';
    private static final String DUPLICATE_NOT_PROCESSED = 'Duplicate Not Processed';
    private static final String NOT_APPLICABLE = 'Not Applicable';
    private static final String NEW_LINE = '\\n';
    private static final String PACKAGE_DRIVE = 'Drive';
    private static final String PACKAGE_MARKETPLACE = 'Marketplace';
    private static final String PACKAGE_SELF_DELIVERY = 'Self-Delivery';
    private static final String PACKAGE_STOREFRONT = 'Storefront';
    private static final String PRIMARY_VERTICAL = 'Restaurant';
    private static final String PROVINCE_QUEBEC = 'Quebec';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_IN_ACTIVE = 'Inactive';
    private static final String ROLE_REPRESENTATIVE = 'Representative';
    private static final String ROLE_BUSINESS_ADMIN = 'Business Admin';
    private static final String ROLE_BUSINESS_OWNER = 'Business Owner';
    private static final String ROLE_BUSINESS_DIRECTOR = 'Business Director';
    private static final String ROLE_DECISION_MAKER = 'Decision Maker';
    private static final String DM_ROLE_BUSINESSACCOUNT_PLACEHOLDER = 'BusinessAccount_DM';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String UNDERSCORE_SEPARATOR = '_';
    private static final String ROLE_PHOTOSHOOT_CONTACT = 'Photoshoot Contact';
    private static final String STATUS_INTERFACE_TRANSACTION_FAILURE = 'Failure';
    private static final String STATUS_INTERFACE_TRANSACTION_SUCCESS = 'Success';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String SEMI_COLON_SEPARATOR = ';';
    private static final String PLUS_SEPARATOR = '+';
    private static final String BLANK_SPACE = ' ';
    private static final String SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String VERIFIED = 'Verified';
    private static final String NON_DUPLICATE = 'Non-Duplicate';
    private static final String IS_SELF_DELIVERY = 'isSelfDelivery';
    private static final Id STORE_ACCOUNT_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String USECASE_NAME_OI_RECORD_CREATION = 'OI_RECORD_CREATION';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.Account.FieldSets.Address_Matching_Criteria;
    private String businessBrandName;
    private String mxFormLanguage;
    Boolean isSalesForm;
    List<OIFieldWrapper> businessInfoWrapper;
    sObject businessOnboardingDetail;
    private Map<Id, Contact> businessOnboardingDetailToBillingContact;
    private Map<Id, Account> businessOnboardingIdToBusinessAccount;
    private Map<Id, Mx_Onboarding_Link__c> businessOnboardingIdToMxOnboardingLink;
    ContractInfoWrapper contractWrapper;
    private Map<Id, Business_Onboarding_Detail__c> idToBusinessOnboardingLink;
    Mx_Onboarding_Link__c mxOnboardingLink;
    private List<Mx_Onboarding_Link__c> mxOnboardingLinks;
    private String mxStateToMxFormLanguageConfigUnParsed;
    private Map<String, String> mxStateToOneTimeMxLinkLanguage;
    private String oneTimeMxLink;
    Map<String, String> packageToProductCategory;
    List<StoreDataWrapper> storeDataWrappers;
    sObject storeDetail;
    private Map<Id, Account> storeDetailIdToStoreAccount;
    List<SObject> storeDetails;
    private fflib_ISObjectUnitOfWork unitOfWork;
    private fflib_ISObjectUnitOfWork unitOfWorkBusinessAccount;
    private fflib_ISObjectUnitOfWork unitOfWorkStoreDetail;
    Set<String> contactName = new Set<String>();
    Set<String> contactEmail = new Set<String>();
    Set<String> contactPhone = new Set<String>();
    Set<Id> parentIds = new Set<Id>();
    private Integer queriesAllowedLimit;
    private Integer queryRowsAllowedLimit;
    String packageName = '';
    List<String> packageNameList = new List<String>();
    Id businessVertical;
    Map<Id, String> associatedBrandName = new Map<Id, String>();
    Map<String, List<ContactInfoWrapper>> contactInfoWrap = new Map<String, List<ContactInfoWrapper>>();
    Boolean skipRecordProcessing;

    private enum CountryNames {
        UNITEDSTATES,
        CANADA,
        AUSTRALIA,
        NEWZEALAND
    }
    private static final Map<String, CountryNames> COUNTRYMAPPINGS = new Map<String, CountryNames>{
        COUNTRY_CODE_CA => CountryNames.CANADA,
        COUNTRY_CODE_US => CountryNames.UNITEDSTATES,
        COUNTRY_CODE_AU => CountryNames.AUSTRALIA,
        COUNTRY_CODE_NZ => CountryNames.NEWZEALAND
    };
    private enum CountryCodes {
        US,
        CA,
        AU,
        NZ
    }
    private static final Map<String, CountryCodes> COUNTRYCODEMAPPINGS = new Map<String, CountryCodes>{
        COUNTRY_CA => CountryCodes.CA,
        COUNTRY_US => CountryCodes.US,
        COUNTRY_AU => CountryCodes.AU,
        COUNTRY_NZ => CountryCodes.NZ
    };

    private enum IntegrationUseCase {
        USECASE_OI_DATA_CREATION
    }
    private static final Map<String, IntegrationUseCase> USECASE_MAPPINGS = new Map<String, IntegrationUseCase>{
        USECASE_NAME_OI_RECORD_CREATION => IntegrationUseCase.USECASE_OI_DATA_CREATION
    };

    private enum EventTopics {
        EVENT_TOPIC_OI_DATA_CREATION_HANDLER
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_OI_DATA_CREATION => EventTopics.EVENT_TOPIC_OI_DATA_CREATION_HANDLER
    };
    private enum OrderProtocols {
        EMAIL,
        POS,
        TABLET
    }
    private static final Map<String, CountryNames> ORDERPROTOCOLMAPPINGS = new Map<String, CountryNames>{
        COUNTRY_CODE_CA => CountryNames.CANADA,
        COUNTRY_CODE_US => CountryNames.UNITEDSTATES,
        COUNTRY_CODE_AU => CountryNames.AUSTRALIA,
        COUNTRY_CODE_NZ => CountryNames.NEWZEALAND
    };

    private enum ProductCategory {
        PACKAGE_DRIVE,
        PACKAGE_MARKETPLACE,
        PACKAGE_SELF_DELIVERY,
        PACKAGE_STOREFRONT
    }
    private static final Map<String, ProductCategory> PRODUCTTOPRODUCTCATEGORY = new Map<String, ProductCategory>{
        PACKAGE_DRIVE => ProductCategory.PACKAGE_DRIVE,
        PACKAGE_MARKETPLACE => ProductCategory.PACKAGE_MARKETPLACE,
        PACKAGE_SELF_DELIVERY => ProductCategory.PACKAGE_SELF_DELIVERY,
        PACKAGE_STOREFRONT => ProductCategory.PACKAGE_STOREFRONT
    };
    private Map<Id, BusinessAccountWrapper> businessAccountDetails;
    private Map<Id, StoreDetailsWrapper> storeMap;
    private Map<String, ContactDto.contactInfo> contactIdentifierToContactInfo;
    private Map<String, String> contactIdentifierToRoles;
    private Map<String, ContactDto.contactInfo> contactIdentifierToRepresentativeContactInfo;
    private static final Set<String> ROLES_TO_BE_ADDED_ON_STORE_ACCOUNT = new Set<String>{
        ROLE_PHOTOSHOOT_CONTACT
    };
    private Map<Id, ContactDto.contactInfo> storeIdToDecisionMakerContacts;
    private enum OnboardingScenarios {
        NEW_STORE_EXPANSION,
        PRODUCT_ADDITION
    }
    private static final Map<String, OnboardingScenarios> ONBOARDINGSCENARIOSMAPPINGS = new Map<String, OnboardingScenarios>{
        ONBOARDING_SCENARIO_NSE => OnboardingScenarios.NEW_STORE_EXPANSION,
        ONBOARDING_SCENARIO_PRODUCT_ADDITION => OnboardingScenarios.PRODUCT_ADDITION
    };

    /**
     * @description Default constructor to instantiate variables.
     */
    public OIDataServiceImpl() {
        businessInfoWrapper = new List<OIFieldWrapper>();
        storeMap = new Map<Id, StoreDetailsWrapper>();
        businessAccountDetails = new Map<Id, BusinessAccountWrapper>();
        businessOnboardingIdToBusinessAccount = new Map<Id, Account>();
        businessOnboardingIdToMxOnboardingLink = new Map<Id, Mx_Onboarding_Link__c>();
        contractWrapper = new ContractInfoWrapper();
        idToBusinessOnboardingLink = new Map<Id, Business_Onboarding_Detail__c>();
        mxOnboardingLink = new Mx_Onboarding_Link__c();
        mxOnboardingLinks = new List<Mx_Onboarding_Link__c>();
        packageToProductCategory = new Map<String, String>();
        storeDataWrappers = new List<StoreDataWrapper>();
        storeDetails = new List<SObject>();
        storeDetailIdToStoreAccount = new Map<Id, Account>();
        contactIdentifierToContactInfo = new Map<String, ContactDto.contactInfo>();
        contactIdentifierToRoles = new Map<String, String>();
        contactIdentifierToRepresentativeContactInfo = new Map<String, ContactDto.contactInfo>();
        storeIdToDecisionMakerContacts = new Map<Id, ContactDto.contactInfo>();
        associatedBrandName = new Map<Id, String>();
        unitOfWork = Application.UNITOFWORK.newInstance();
        unitOfWorkBusinessAccount = Application.UNITOFWORK.newInstance();
        unitOfWorkStoreDetail = Application.UNITOFWORK.newInstance();
        skipRecordProcessing = true;
        collectStaticConfigurations();
        collectOIPackageProductMappings();
        collectMxStateToMxFormLanguageMappings();
    }

    /**
     * @description It is used to get active Mx Onboarding link record.
     * @JIRA# LEM-15116
     * @param contractId
     * @return Mx_Onboarding_Link__c
     */
    public Mx_Onboarding_Link__c getActiveMxOnboardingLink(Id contractId) {
        Mx_Onboarding_Link__c mxOnboardingLinkToReturn = new Mx_Onboarding_Link__c();
        List<Mx_Onboarding_Link__c> mxOnboardingLinks = MxOnboardingLinksSelector.newInstance()
            .selectByContractIds(new Set<Id>{ contractId });
        if (mxOnboardingLinks.size() > 0) {
            mxOnboardingLinkToReturn = mxOnboardingLinks[0];
        }
        return mxOnboardingLinkToReturn;
    }

    /**
     * @description It fetches the Contract Info.
     * @JIRA# LEM-15116
     * @param contractId
     * @param onboardingScenario
     * @return ContractInfoWrapper
     */
    public ContractInfoWrapper fetchContractDetails(String contractId, String onboardingScenario) {
        List<String> brands = new List<String>();
        OIFormPayloadWrapper oiFormPayload = new OIFormPayloadWrapper(contractId);
        contractWrapper.isMxOrRepForm = isCommunity();
        Set<Id> businessAccountIds = new Set<Id>();
        List<Contract> existingContract = new List<Contract>();
        if (onboardingScenario.contains(ONBOARDING_SCENARIO_PRODUCT_ADDITION)) {
            existingContract = ContractsSelector.newInstance()
                .selectContractsWithSubscriptionsAddScenario(new Set<Id>{ contractId });
        } else {
            existingContract = ContractsSelector.newInstance()
                .selectContractsWithSubscriptions(new Set<Id>{ contractId });
        }
        if (!existingContract.isEmpty()) {
            for (Contract eachContract : existingContract) {
                if (eachContract.Account.Order_Protocol__c != null) {
                    setOrderProtocolVariables(eachContract.Account.Order_Protocol__c);
                }
                contractWrapper.newProductsAddedSet = new Set<String>();
                for (SBQQ__Subscription__c eachSubscription : eachContract.SBQQ__Subscriptions__r) {
                    if (eachSubscription.Package__c == null) {
                        continue;
                    }
                    setPackageVariables(eachSubscription);
                    if (
                        contractWrapper.isMarketPlace &&
                        eachSubscription.SBQQ__Product__r.Alcohol_Product__c
                    ) {
                        contractWrapper.hasAlcoholPackage = true;
                    }
                }
                for (
                    Contract_Brand_Association__c eachBrand : eachContract.Contract_Brand_Associations__r
                ) {
                    associatedBrandName.put(eachBrand.Brand__c, eachBrand.Brand_Name__c);
                    brands.add(eachBrand.Brand_Name__c + SEPARATOR + eachBrand.Brand__c);
                }
                string brandNames = string.join(brands, SEMI_COLON_SEPARATOR);
                oiFormPayload.accountName = eachContract.Account.Name;
                oiFormPayload.accountId = eachContract.AccountId;
                oiFormPayload.billingCountry = eachContract.Account.BillingCountry;
                oiFormPayload.billingState = eachContract.Account.BillingState;
                oiFormPayload.paymentMethod = eachContract.Payment_Method__c;
                oiFormPayload.primaryVertical = isEmptyOrNull(
                        eachContract.Account.Primary_Vertical__c
                    )
                    ? ''
                    : eachContract.Account.Primary_Vertical__c;
                String productsOnContract = setPackagesOnContract(
                    contractWrapper,
                    onboardingScenario
                );
                oiFormPayload.packageName = productsOnContract;
                contractWrapper.productsOnContract = productsOnContract;
                oiFormPayload.isSelfDelivery = contractWrapper.isSelfDelivery;
                oiFormPayload.hasAlcoholPackage = contractWrapper.hasAlcoholPackage;
                contractWrapper.businessAccountId = eachContract.AccountId;
                contractWrapper.businessAccountInstance = eachContract.Account;
                contractWrapper.associatedBrands = brandNames;
                contractWrapper.billingCountry = eachContract.Account.BillingCountry;
                contractWrapper.billingState = eachContract.Account.BillingState;
                contractWrapper.city = eachContract.Account.BillingCity;
                contractWrapper.zipCode = eachContract.Account.BillingPostalCode;
                businessAccountIds.add(eachContract.AccountId);
                contractWrapper.payload = oiFormPayload;
            }
        }
        return contractWrapper;
    }

    /**
     * @description It fetches the OI Metadata record Info.
     * @param productsOnContract - products on contract's subscription semicolon seperated
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales form, Mx Form
     * @return OISectionAttributeWrapper
     */
    public OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType
    ) {
        List<OISectionCondition__mdt> oISectionConditionsToPass = new List<OISectionCondition__mdt>();
        OISectionAttributeWrapper sectionAttWrapper = new OISectionAttributeWrapper();
        for (
            OISectionCondition__mdt eachSectionCondition : OISectionConditionsSelector.newInstance()
                .fetchOIMetadataRecords(
                    productsOnContract,
                    onboardingScenario,
                    repCollectingOnMxBehalf,
                    formType
                )
        ) {
            if (formType == FORM_TYPE_MX_FORM && mxFormLanguage != FORM_LANGUAGE_ENGLISH) {
                collectTranslatedCustomMetadataValues(eachSectionCondition);
            }
            List<OIAttributesConfig__mdt> attrConfigList = eachSectionCondition.OIAttributesConfigs__r;
            String sectionJson = JSON.serialize(eachSectionCondition);
            String childrenJson =
                '"    ": {' +
                '"totalSize": ' +
                eachSectionCondition.OIAttributesConfigs__r.size() +
                ', ' +
                '"done": true,' +
                '"records": ' +
                JSON.serialize(attrConfigList) +
                '}';
            sectionJson =
                sectionJson.substring(0, sectionJson.length() - 1) +
                ',' +
                childrenJson +
                '}';
            if (
                eachSectionCondition.Products_on_Contract__c
                    ?.split(System.Label.Separator)
                    .contains(productsOnContract)
            ) {
                oISectionConditionsToPass.add(eachSectionCondition);
            }
        }
        sectionAttWrapper.oISectionConditions = oISectionConditionsToPass;
        return sectionAttWrapper;
    }

    /**
     * @description It fetches the translated OI Metadata record Info based on Mx Form Language.
     * @JIRA# LEM-24213
     * @param productsOnContract - Products on contract's subscription
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales Form, Mx Form
     * @param formLanguage - Mx Form Language
     * @return OISectionAttributeWrapper
     */
    public OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType,
        String formLanguage
    ) {
        mxFormLanguage = formLanguage;
        return fetchOIMetadataRecords(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            formType
        );
    }

    /**
     * @description It fetches State and Country picklist values with dependencies.
     * @return Map<String, List<String>> - Country to List of States
     */
    public Map<String, List<String>> fetchCountryStatePicklistValues() {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        //Get the type being dealt with
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Store_Detail__c');
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        //Get controlling field values
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
            .get('Address__CountryCode__s')
            .getDescribe();
        //Get dependent field values
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap()
            .get('Address__StateCode__s')
            .getDescribe();
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        //Get the label for controlling picklist value set
        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            //get the valid
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(
                jsonString,
                MyPickListInfo.class
            );
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor))
                .toUpperCase();
            Integer baseCount = 0;
            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }
                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel())
                        .add(currDependentValue.getLabel());
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel())
                        .add(currDependentValue.getLabel());
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel())
                        .add(currDependentValue.getLabel());
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel())
                        .add(currDependentValue.getLabel());
                }
                baseCount += 4;
            }
        }
        return controllingInfo;
    }

    /**
     * @description It fetches the metadata for country attributes
     * @JIRA# LEM-18246
     * @return Map<String, Country_Attributes_Mapping__mdt>
     */
    public static Map<String, Country_Attributes_Mapping__mdt> fetchCountryAttributesMetadata() {
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (
            Country_Attributes_Mapping__mdt countryAttribute : CountryAttributesMappingSelector.newInstance()
                .getAllValues()
        ) {
            countryToCountryAttributes.put(countryAttribute.Country__c, countryAttribute);
        }
        return countryToCountryAttributes;
    }

    /**
     * @description It saves Mx Onboarding link records.
     * @JIRA# LEM-15116
     * @param oiMainDataWrapperJSON
     * @return Mx_Onboarding_Link__c
     */
    public Mx_Onboarding_Link__c saveMxOnboardingLinkRecord(String oiMainDataWrapperJSON) {
        List<OIMainDataWrapper> oiMainDataWrapper = (List<OIMainDataWrapper>) JSON.deserialize(
            oiMainDataWrapperJSON,
            List<OIMainDataWrapper>.class
        );
        businessInfoWrapper = oiMainDataWrapper[0].businessInfoWrappers;
        storeDataWrappers = oiMainDataWrapper[0].storeDataWrappers;
        createMxOnboardingLinkRecord(oiMainDataWrapper[0]);
        isSalesForm = true;
        if (!isNullOrBlank(oiMainDataWrapper[0].payload.brandName)) {
            businessBrandName = BrandsSelector.newInstance()
                    .selectById(new Set<Id>{ oiMainDataWrapper[0].payload.brandName })[0]
                .Name;
        }
        createRelatedRecords();
        return mxOnboardingLink;
    }

    /**
     * @description It converts the passed JSON data into different sObject records.
     * @JIRA# LEM-15116
     * @param oiMainDataWrapperJSON
     * @param mxOnboardingLinkId
     * @return Boolean
     */
    public Boolean saveMxFormDetails(String oiMainDataWrapperJSON, Id mxOnboardingLinkId) {
        List<OIMainDataWrapper> oiMainDataWrapper = (List<OIMainDataWrapper>) JSON.deserialize(
            oiMainDataWrapperJSON,
            List<OIMainDataWrapper>.class
        );
        Boolean recordSave = false;
        mxOnboardingLink = new Mx_Onboarding_Link__c(Id = mxOnboardingLinkId);
        businessInfoWrapper = oiMainDataWrapper[0].businessInfoWrappers;
        storeDataWrappers = oiMainDataWrapper[0].storeDataWrappers;
        isSalesForm = false;
        try {
            createRelatedRecords();
            recordSave = true;
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
        return recordSave;
    }

    /**
     * @description It collects the Mx Form Language by Mx State mappings based on static config.
     * @JIRA# LEM-24213
     */
    private void collectMxStateToMxFormLanguageMappings() {
        if (this.mxStateToMxFormLanguageConfigUnParsed != null) {
            this.mxStateToOneTimeMxLinkLanguage = (Map<String, String>) (JSON.deserialize(
                mxStateToMxFormLanguageConfigUnParsed,
                Map<String, String>.class
            ));
        } else {
            this.mxStateToOneTimeMxLinkLanguage = new Map<String, String>();
        }
    }

    /**
     * @description It is used to collect the translated values of the Fields and Section
     * Custom Metadata records based on selected Language.
     * @param oISectionConditionMetaData
     */
    private void collectTranslatedCustomMetadataValues(
        OISectionCondition__mdt oISectionConditionMetaData
    ) {
        if (
            oISectionConditionMetaData.Section__c != null &&
            String.isNotBlank(oISectionConditionMetaData.Section__c)
        ) {
            oISectionConditionMetaData.Section__c = translatedValueBySelectedLanguage(
                EMPTY_STRING,
                OI_ATTRIBUTE_MX_FORM_PREFIX +
                    (oISectionConditionMetaData.Section__c.contains(COLON_SEPARATOR)
                        ? oISectionConditionMetaData.Section__c.replaceAll(
                                  BLANK_SPACE,
                                  UNDERSCORE_SEPARATOR
                              )
                              .remove(COLON_SEPARATOR)
                        : oISectionConditionMetaData.Section__c.replaceAll(
                              BLANK_SPACE,
                              UNDERSCORE_SEPARATOR
                          )) +
                    OI_SECTION_NAME_SUFFIX,
                mxFormLanguage
            );
        }
        for (
            OIAttributesConfig__mdt eachAttributeConfig : oISectionConditionMetaData.OIAttributesConfigs__r
        ) {
            eachAttributeConfig.OIAttribute__r.Field_Name__c = translatedValueBySelectedLanguage(
                EMPTY_STRING,
                OI_ATTRIBUTE_MX_FORM_PREFIX +
                    eachAttributeConfig.OIAttribute__r.DeveloperName +
                    OI_ATTRIBUTE_FIELD_LABEL_SUFFIX,
                mxFormLanguage
            );
            if (
                eachAttributeConfig.Attribute_HelpText__c != null &&
                String.isNotBlank(eachAttributeConfig.Attribute_HelpText__c)
            ) {
                eachAttributeConfig.Attribute_HelpText__c = translatedValueBySelectedLanguage(
                    EMPTY_STRING,
                    OI_ATTRIBUTE_MX_FORM_PREFIX +
                        eachAttributeConfig.OIAttribute__r.DeveloperName +
                        OI_ATTRIBUTE_FIELD_HELP_TEXT_SUFFIX,
                    mxFormLanguage
                );
            }
        }
    }

    /**
     * @description It is used to collect all package product mappings.
     */
    private void collectOIPackageProductMappings() {
        for (
            OIPackageProductMapping__mdt eachPackageProductMapping : OIPackageProductMappingsSelector.newInstance()
                .getAllMappings()
        ) {
            packageToProductCategory.put(
                eachPackageProductMapping.Package__c,
                eachPackageProductMapping.Product_Category__c
            );
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.oneTimeMxLink = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(ONE_TIME_MX_LINK_STATIC_CONFIG)
            .Configuration_Value__c;
        this.mxStateToMxFormLanguageConfigUnParsed = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG)
            ?.Configuration_Value__c;
        this.queriesAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.queryRowsAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It generates a sequence of alpha-numeric ID used as unique identifier
     * for outbound integration payload.
     * @return String
     */
    private String getUUID() {
        Blob blbKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blbKey);
        String uuid =
            hexKey.SubString(0, 8) +
            DASH_SPLIT +
            hexKey.SubString(8, 12) +
            DASH_SPLIT +
            hexKey.SubString(12, 16) +
            DASH_SPLIT +
            hexKey.SubString(16, 20) +
            DASH_SPLIT +
            hexKey.substring(20);
        return uuid;
    }

    /**
     * @description To create Mx onboarding link record.
     * @param oiMainDataWrapper
     */
    private void createMxOnboardingLinkRecord(OIMainDataWrapper oiMainDataWrapper) {
        String strUuid = getUUID();
        String addDays = System.label.Expiration_Date_Value;
        OIFormPayloadWrapper payLoadData = (OIFormPayloadWrapper) JSON.deserialize(
            JSON.serialize(oiMainDataWrapper.payload),
            OIFormPayloadWrapper.class
        );
        String brandName = payLoadData.brandName;
        List<Brand__c> selectedBrandsList = BrandsSelector.newInstance()
            .getBrandsByBrandName(new List<String>{ brandName });
        if (selectedBrandsList != null && selectedBrandsList.size() > 0) {
            payLoadData.brandName = selectedBrandsList[0].Id;
        }
        mxOnboardingLink = new Mx_Onboarding_Link__c(
            Business_Account__c = oiMainDataWrapper.businessAccountId,
            Contract__c = oiMainDataWrapper.contractId,
            Opportunity__c = oiMainDataWrapper.opportunityId,
            Expiration_Date_Time__c = System.now() + Integer.valueOf(addDays),
            Generated_By__c = UserInfo.getUserID(),
            UUID__c = strUuid,
            Onboarding_Scenario__c = oiMainDataWrapper.onboardingScenario,
            One_Time_Mx_Link__c = oiMainDataWrapper.isMxInputRequired
                ? oneTimeMxLink +
                  (mxStateToOneTimeMxLinkLanguage.containsKey(payLoadData.billingState)
                      ? BACKSLASH_SEPARATOR +
                        mxStateToOneTimeMxLinkLanguage.get(payLoadData.billingState) +
                        BACKSLASH_SEPARATOR
                      : '') +
                  FORMIDPARAM +
                  strUuid
                : '',
            Payload__c = JSON.serialize(payLoadData),
            Rep_Collecting_On_Mx_Behalf__c = oiMainDataWrapper.repCollectingOnMxBehalf,
            Status__c = oiMainDataWrapper.isMxInputRequired ? STATUS_ACTIVE : STATUS_IN_ACTIVE,
            Product_on_Contract__c = payLoadData.packageName,
            Payment_Method__c = payLoadData.paymentMethod,
            Mx_Email__c = oiMainDataWrapper.emailRecipient <> null
                ? oiMainDataWrapper.emailRecipient
                : ''
        );
        fireRecordsInsertion(new List<SObject>{ mxOnboardingLink });
    }

    /**
     * @description To create Mx onboarding link related records.
     */
    private void createRelatedRecords() {
        createBusinessOnboardingDetails();
        createStoreDetails();
    }

    private String getCodeValue(String fieldName, String objName, String key) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        //Get controlling field values
        Schema.DescribeFieldResult fieldInfo = describeResult.fields.getMap()
            .get(fieldName)
            .getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldInfo.getPicklistValues();
        for (Schema.PicklistEntry currControllingValue : picklistValues) {
            if (currControllingValue.getLabel() == key) {
                return currControllingValue.getValue();
            }
        }
        return null;
    }

    /**
     * @description It is used to get business onboarding instance.
     * @JIRA# LEM-15116
     */
    private void createBusinessOnboardingDetails() {
        String phoneNumber;
        Schema.SObjectType businessOnboardingDetailType = Schema.getGlobalDescribe()
            .get('Business_Onboarding_Detail__c');
        businessOnboardingDetail = businessOnboardingDetailType.newSObject();
        businessOnboardingDetail.put(MX_ONBOARDING_LINK_FIELD, mxOnboardingLink.Id);
        for (OIFieldWrapper eachWrapper : businessInfoWrapper) {
            if (eachWrapper.fieldType == FIELD_TYPE_DATE) {
                businessOnboardingDetail.put(
                    eachWrapper.fieldApiName,
                    Date.valueOf(eachWrapper.fieldValue)
                );
            } else if (eachWrapper.fieldType == FIELD_TYPE_NUMBER) {
                phoneNumber = (eachWrapper.fieldValue).remove('-');
                businessOnboardingDetail.put(
                    eachWrapper.fieldApiName,
                    Decimal.valueOf(eachWrapper.fieldValue)
                );
            } else if (eachWrapper.fieldType == FIELD_TYPE_TIME) {
                List<String> timeStrings = eachWrapper.fieldValue.split(':');
                Integer hours = 12;
                businessOnboardingDetail.put(
                    eachWrapper.fieldApiName,
                    Time.newInstance(
                        hours + Integer.valueOf(timeStrings[0]),
                        Integer.valueOf(timeStrings[1]),
                        0,
                        0
                    )
                );
            } else if (
                eachWrapper.fieldType == FIELD_TYPE_ADDRESSSTATE ||
                eachWrapper.fieldType == FIELD_TYPE_ADDRESSCOUNTRY
            ) {
                businessOnboardingDetail.put(
                    eachWrapper.fieldApiName,
                    getCodeValue(
                        eachWrapper.fieldApiName,
                        'Business_Onboarding_Detail__c',
                        eachWrapper.fieldValue
                    )
                );
            } else {
                if (
                    eachWrapper.fieldApiName == 'Brand__c' && !isNullOrBlank(eachWrapper.fieldValue)
                ) {
                    businessOnboardingDetail.put(eachWrapper.fieldApiName, eachWrapper.fieldValue);
                } else {
                    if (eachWrapper.fieldApiName == 'Mx_Requested_Photoshoot__c') {
                        eachWrapper.fieldValue = eachWrapper.fieldValue ==
                            'Submit your own professional photos'
                            ? 'No'
                            : (eachWrapper.fieldValue == 'Schedule a FREE professional photoshoot'
                                  ? 'Yes'
                                  : eachWrapper.fieldValue);
                    }
                    businessOnboardingDetail.put(eachWrapper.fieldApiName, eachWrapper.fieldValue);
                }
            }
        }
        if (businessInfoWrapper.size() != 0) {
            fireRecordsInsertion(new List<SObject>{ businessOnboardingDetail });
        } else {
            if (!isSalesForm) {
                fireRecordsInsertion(new List<SObject>{ businessOnboardingDetail });
            }
        }
    }

    /**
     * @description It is used to get store details instance.
     * @JIRA# LEM-15116
     */
    private void createStoreDetails() {
        String phoneNumber;
        String addVerification;
        Schema.SObjectType storeDetailType = Schema.getGlobalDescribe().get('Store_Detail__c');
        Integer counter = 0;
        for (StoreDataWrapper eachWrapper : storeDataWrappers) {
            sObject storeDetail = storeDetailType.newSObject();
            storeDetail.put(MX_ONBOARDING_LINK_FIELD, mxOnboardingLink.Id);
            storeDetail.put('Store_Name__c', businessBrandName);
            storeDetail.put('Store_Detail__c', eachWrapper.parentStoreId);
            storeDetail.put(
                'Is_Store_For_No_Rep_Scenario__c',
                eachWrapper.isStoreForNoRepScenario == 'true' ? true : false
            );

            Accessibilities accessibilityWrapper = new Accessibilities();
            for (OIFieldWrapper eachFieldWrapper : eachWrapper.oiFieldWrappers) {
                if (eachFieldWrapper.fieldType == FIELD_TYPE_DATE) {
                    storeDetail.put(
                        eachFieldWrapper.fieldApiName,
                        Date.valueOf(eachFieldWrapper.fieldValue)
                    );
                } else if (eachFieldWrapper.fieldType == FIELD_TYPE_NUMBER) {
                    phoneNumber = (eachFieldWrapper.fieldValue).remove('-');
                    storeDetail.put(eachFieldWrapper.fieldApiName, Decimal.valueOf(phoneNumber));
                } else if (eachFieldWrapper.fieldType == FIELD_TYPE_TIME) {
                    List<String> timeStrings = eachFieldWrapper.fieldValue.split(':');
                    Integer hours = Integer.valueOf(timeStrings[0]);
                    if (Integer.valueOf(timeStrings[0]) == 0) {
                        hours = 12 + Integer.valueOf(timeStrings[0]);
                    }
                    storeDetail.put(
                        eachFieldWrapper.fieldApiName,
                        Time.newInstance(hours, Integer.valueOf(timeStrings[1]), 0, 0)
                    );
                } else if (eachFieldWrapper.fieldType == FIELD_TYPE_CHECKBOX) {
                    storeDetail.put(
                        eachFieldWrapper.fieldApiName,
                        Boolean.valueOf(eachFieldWrapper.fieldValue)
                    );
                } else if (eachFieldWrapper.fieldType == 'Percent') {
                    storeDetail.put(
                        eachFieldWrapper.fieldApiName,
                        Decimal.valueOf(eachFieldWrapper.fieldValue)
                    );
                } else if (
                    eachFieldWrapper.fieldType == FIELD_TYPE_ADDRESSSTATE ||
                    eachFieldWrapper.fieldType == FIELD_TYPE_ADDRESSCOUNTRY
                ) {
                    storeDetail.put(
                        eachFieldWrapper.fieldApiName,
                        getCodeValue(
                            eachFieldWrapper.fieldApiName,
                            'Store_Detail__c',
                            eachFieldWrapper.fieldValue
                        )
                    );
                } else {
                    if (eachFieldWrapper.fieldApiName == 'Address__Street__s') {
                        storeDetail.put(
                            'Store_Name__c',
                            businessBrandName + ' ' + eachFieldWrapper.fieldValue
                        );
                        addVerification = 'Unverified';
                        storeDetail.put('Address_Verification_Status__c', addVerification);
                    }
                    if (eachFieldWrapper.fieldApiName == 'Need_to_Climb_Stairs__c') {
                        accessibilityWrapper.needToClimb = eachFieldWrapper.fieldValue == 'Yes'
                            ? true
                            : false;
                    } else if (eachFieldWrapper.fieldApiName == 'Has_Elevators_Ramps__c') {
                        accessibilityWrapper.hasElevatorsOrRamps = eachFieldWrapper.fieldValue ==
                            'Yes'
                            ? true
                            : false;
                    }
                    storeDetail.put(eachFieldWrapper.fieldApiName, eachFieldWrapper.fieldValue);
                }
            }
            if (addVerification == null || String.isBlank(addVerification)) {
                storeDetail.put('Address_Verification_Status__c', 'Not Applicable');
            }
            storeDetail.put('Accessibilities__c', JSON.serialize(accessibilityWrapper));
            storeDetails.add(storeDetail);
            counter++;
        }
        if (storeDataWrappers.size() != 0 && !storeDetails.isEmpty()) {
            fireRecordsInsertion(storeDetails);
        }
    }

    /**
     * @description It trigger UOW commitWork on the passed records.
     * @JIRA# LEM-15116
     * @param sObjectsToInsert
     */
    private void fireRecordsInsertion(List<SObject> sObjectsToInsert) {
        if (isEmptyOrNull(sObjectsToInsert)) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsInsertion = Application.UnitOfWork.newInstance();
        uowRecordsInsertion.registerNew(sObjectsToInsert);
        try {
            uowRecordsInsertion.commitWork();
        } catch (Exception recordsInsertionException) {
            Logger.publish(
                LogEntry.newExceptionLog(recordsInsertionException, LogEntry.SeverityLevel.HIGH)
            );
            throw new AuraHandledException(recordsInsertionException.getMessage());
        }
    }

    /**
     * @description It validates whether it is community.
     * @JIRA# LEM-15116
     * @return Boolean
     */
    private Boolean isCommunity() {
        Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
        if (siteId != null) {
            return true;
        }
        return false;
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It is used to set Order Protocol values.
     * @JIRA# LEM-15116
     * @param strOrderProtocol
     */
    private void setOrderProtocolVariables(String strOrderProtocol) {
        if (strOrderProtocol.containsIgnoreCase(ORDER_PROTOCOL_EMAIL)) {
            contractWrapper.isEmail = true;
        }
        if (strOrderProtocol.containsIgnoreCase(ORDER_PROTOCOL_POS)) {
            contractWrapper.isPOS = true;
        }
        if (strOrderProtocol.containsIgnoreCase(ORDER_PROTOCOL_TABLET)) {
            contractWrapper.isTablet = true;
        }
    }

    /**
     * @description It is used to set packages on Contract.
     * @JIRA# LEM-15116
     * @param contractWrapper
     * @param onboardingScenario
     * @return String
     */
    private String setPackagesOnContract(
        ContractInfoWrapper contractWrapper,
        String onboardingScenario
    ) {
        String returnValue = '';
        String seperator = SEMI_COLON_SEPARATOR + BLANK_SPACE;
        Boolean isProductAdditionScenario = false;
        if (onboardingScenario.contains(ONBOARDING_SCENARIO_PRODUCT_ADDITION)) {
            seperator = PLUS_SEPARATOR + BLANK_SPACE;
            isProductAdditionScenario = true;
        }
        if (
            contractWrapper.isDrive &&
            (!isProductAdditionScenario ||
            (isProductAdditionScenario &&
            contractWrapper.newProductsAddedSet.contains(PACKAGE_DRIVE)))
        ) {
            returnValue = returnValue + PACKAGE_DRIVE + seperator;
        }
        if (
            contractWrapper.isMarketPlace &&
            (!isProductAdditionScenario ||
            (isProductAdditionScenario &&
            contractWrapper.newProductsAddedSet.contains(PACKAGE_MARKETPLACE)))
        ) {
            returnValue = returnValue + PACKAGE_MARKETPLACE + seperator;
        }
        if (
            contractWrapper.isStoreFront &&
            (!isProductAdditionScenario ||
            (isProductAdditionScenario &&
            contractWrapper.newProductsAddedSet.contains(PACKAGE_STOREFRONT)))
        ) {
            returnValue = returnValue + PACKAGE_STOREFRONT + seperator;
        }
        returnValue = returnValue.trim();
        returnValue = returnValue.removeEnd(SEMI_COLON_SEPARATOR);
        returnValue = returnValue.removeEnd(PLUS_SEPARATOR);
        return returnValue;
    }

    /**
     * @description It is used to set package variables.
     * @JIRA# LEM-15116
     * @param eachSubscription
     */
    private void setPackageVariables(SBQQ__Subscription__c eachSubscription) {
        String packageValue = eachSubscription.Package__c;
        Boolean isNewProduct = eachSubscription.Is_It_A_New_Product__c;
        if (!contractWrapper.isSelfDelivery && packageValue.contains('Self-Delivery')) {
            contractWrapper.isSelfDelivery = true;
        }

        switch on PRODUCTTOPRODUCTCATEGORY.get(packageToProductCategory.get(packageValue)) {
            when PACKAGE_DRIVE {
                contractWrapper.isDrive = true;
                if (isNewProduct) {
                    contractWrapper.newProductsAddedSet.add(PACKAGE_DRIVE);
                }
            }
            when PACKAGE_MARKETPLACE {
                contractWrapper.isMarketPlace = true;
                if (isNewProduct) {
                    contractWrapper.newProductsAddedSet.add(PACKAGE_MARKETPLACE);
                }
            }
            when PACKAGE_STOREFRONT {
                contractWrapper.isStoreFront = true;
                if (isNewProduct) {
                    contractWrapper.newProductsAddedSet.add(PACKAGE_STOREFRONT);
                }
            }
        }
    }

    /**
     * @description It translates the passed Custom Label based on language received.
     * @param namespacePrefix
     * @param customLabelName
     * @param translationLanguage
     * @return String
     */
    private String translatedValueBySelectedLanguage(
        String namespacePrefix,
        String customLabelName,
        String translationLanguage
    ) {
        return System.Label.get(namespacePrefix, customLabelName, translationLanguage);
    }

    /**
     * @description It is used to handle and route the published OnboardingActivationsEvents.
     * @JIRA# LEM-15362
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> sobjectIds;
        Set<Id> recordIdsByPayload;

        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_OI_DATA_CREATION_HANDLER {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    sobjectIds = new Set<Id>();
                    sobjectIds.addAll(recordIdsByPayload);
                }
            }
        }
        getMxOnboardingLinksAndRelatedRecords(sobjectIds);
    }

    private Set<Id> fetchAssociatedStoreAccount(Id contractId) {
        Set<Id> existingStoreAccountIds = new Set<Id>();
        for (
            Agreement__c existingStoreAgreement : AgreementsSelector.newInstance()
                .selectActiveStoreAgreementsByContractIds(new Set<Id>{ contractId })
        ) {
            existingStoreAccountIds.add(existingStoreAgreement.Account__c);
        }
        return existingStoreAccountIds;
    }
    /**
     * @description It is used to create Account, Contact, Payment account records
     * based on Mx Onboaridng Links and related Business Onboarding Detail and Store details.
     * @param mxOnboardingLinkIds
     */
    private void initiateRecordsCreationByMxOnboardingLinks(Set<Id> mxOnboardingLinkIds) {
        for (
            Mx_Onboarding_Link__c eachLink : MxOnboardingLinksSelector.newInstance()
                .selectByMxOnboardingLinkIds(mxOnboardingLinkIds)
        ) {
            mxOnboardingLinks.add(eachLink);
        }
        businessVertical = BusinessVerticalsSelector.newInstance()
                .selectBusinessVerticalByName(PRIMARY_VERTICAL)[0]
            .Id;
        //Data Creation & Updates
        businessAccountUpdateService();
        if (mxOnboardingLinks[0].One_Time_Mx_Link__c <> null) {
            if (mxOnboardingLinks[0].Store_Details__r.isEmpty()) {
                skipRecordProcessing = false;
            } else {
                storeAccountCreateAndUpdateService();
            }
        } else {
            skipRecordProcessing = false;
            Set<Id> existingStoreAccountIds = fetchAssociatedStoreAccount(
                mxOnboardingLinks[0].Contract__c
            );
            if (
                existingStoreAccountIds <> null &&
                mxOnboardingLinks[0].Store_Details__r <> null &&
                !mxOnboardingLinks[0].Store_Details__r.isEmpty()
            ) {
                for (Id accountId : existingStoreAccountIds) {
                    Account storeAccount = new Account();
                    storeAccount.id = accountId;
                    storeAccount.Mx_Onboarding_Link_Id__c = mxOnboardingLinks[0].UUID__c;
                    storeAccount.Website_Creation_Needed_for_Storefront__c = mxOnboardingLinks[0]
                        .Store_Details__r[0]
                        .Website_Creation_Needed_for_Storefront__c;
                    if (
                        !isNullOrBlank(
                            mxOnboardingLinks[0].Store_Details__r[0].Storefront_Website__c
                        )
                    ) {
                        storeAccount.Storefront_Website__c = mxOnboardingLinks[0]
                            .Store_Details__r[0]
                            .Storefront_Website__c;
                    }
                    storeAccount.Storefront_Mx_Has_Website__c = mxOnboardingLinks[0]
                        .Store_Details__r[0]
                        .Storefront_Mx_Has_Website__c;
                    storeAccount.Storefront_Match_Branded_Website__c = mxOnboardingLinks[0]
                        .Store_Details__r[0]
                        .Storefront_Match_Branded_Website__c;
                    storeAccount.Proposed_Date_of_Implementation__c = mxOnboardingLinks[0]
                        .Store_Details__r[0]
                        .Storefront_Proposed_Date_of_Impl__c;
                    unitOfWork.registerDirty(storeAccount);
                }
            }
        }
        if (!skipRecordProcessing) {
            unitOfWorkBusinessAccount.commitWork();
            updateOpportunity();
            //Commit unit of work
            unitOfWork.commitWork();
            unitOfWork = Application.UNITOFWORK.newInstance();
            createContactsAndAccountContactRelations(mxOnboardingLinks[0]);
            //Commit unit of work
            unitOfWork.commitWork();
            PaymentAccountsService.createPaymentAccountsByMxOnboardingLinks(
                mxOnboardingLinks,
                businessAccountDetails,
                storeMap
            );
        }
    }

    /**
     * @description It is used to fetch all the Mx Onboaridng Links and related Business
     * Onboarding Detail and Store details.
     * @param mxOnboardingLinkIds
     */
    public void getMxOnboardingLinksAndRelatedRecords(Set<Id> mxOnboardingLinkIds) {
        if (mxOnboardingLinkIds.isEmpty()) {
            return;
        }
        try {
            initiateRecordsCreationByMxOnboardingLinks(mxOnboardingLinkIds);
            updateMxOnBoardingLinkRecordCreationStatus(mxOnboardingLinkIds, STATUS_SUCCESS);
            InterfaceTransactionsService.updateInterfaceTransactionStatusByResponse(
                new Set<String>(),
                new Set<String>((List<String>) new List<Id>(mxOnboardingLinkIds))
            );
        } catch (Exception unitOfWorkException) {
            updateMxOnBoardingLinkRecordCreationStatus(mxOnboardingLinkIds, STATUS_FAILURE);
            InterfaceTransactionsService.updateInterfaceTransactionStatusByResponse(
                new Set<String>((List<String>) new List<Id>(mxOnboardingLinkIds)),
                new Set<String>()
            );
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_OI_DATA,
                        LOG_DOMAIN_OI_DATA_CREATION,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
                    .logSFRecordId(
                        (Set<String>) JSON.deserialize(
                            JSON.serialize(mxOnboardingLinkIds),
                            Set<String>.class
                        )
                    )
            );
        }
    }

    /**
     * @description It is used to update Record Creation status based on form submission results.
     * @param mxOnboardingLinkIds
     * @param status
     */

    private void updateMxOnBoardingLinkRecordCreationStatus(
        Set<Id> mxOnboardingLinkIds,
        String status
    ) {
        if (!skipRecordProcessing) {
            unitOfWork = Application.UNITOFWORK.newInstance();
            for (Id eachLinkId : mxOnboardingLinkIds) {
                Mx_Onboarding_Link__c mxOnBoardinglink = new Mx_Onboarding_Link__c(
                    Id = eachLinkId,
                    Record_Creation_Status__c = status
                );
                unitOfWork.registerDirty(mxOnBoardinglink);
            }
            unitOfWork.commitWork();
        }
    }
    /**
     * @description It is used to initialize Business Accounts from onboarding inputs.
     */
    private void businessAccountUpdateService() {
        Business_Onboarding_Detail__c businessDetail;
        Account businessAccount;

        for (Mx_Onboarding_Link__c eachLink : mxOnboardingLinks) {
            BusinessAccountWrapper businessAccountWrap = new BusinessAccountWrapper();
            if (
                eachLink.Business_Onboarding_Details__r != null &&
                !eachLink.Business_Onboarding_Details__r.isEmpty()
            ) {
                businessAccount = new Account();
                for (
                    Business_Onboarding_Detail__c eachBusinessDetail : eachLink.Business_Onboarding_Details__r
                ) {
                    businessDetail = eachBusinessDetail;
                    //Check duplicate ??
                    if (!isNullOrBlank(businessDetail.Legal_Business_Name__c)) {
                        businessAccountWrap.legalBusinessName = businessDetail
                            ?.Legal_Business_Name__c;
                    }
                    if (!isNullOrBlank(businessDetail.Address__Street__s)) {
                        businessAccountWrap.billingStreet = businessDetail?.Address__Street__s;
                    }
                    if (!isNullOrBlank(businessDetail.Brand__c)) {
                        businessAccountWrap.brand = businessDetail?.Brand__c;
                    }
                    if (!isNullOrBlank(businessDetail.Address__City__s)) {
                        businessAccountWrap.billingCity = businessDetail?.Address__City__s;
                    }
                    if (!isNullOrBlank(businessDetail.Address__StateCode__s)) {
                        businessAccountWrap.billingStateCode = businessDetail
                            ?.Address__StateCode__s;
                    }
                    if (!isNullOrBlank(businessDetail.Address__CountryCode__s)) {
                        businessAccountWrap.billingCountryCode = businessDetail
                            ?.Address__CountryCode__s;
                    }
                    if (!isNullOrBlank(businessDetail.Address__PostalCode__s)) {
                        businessAccountWrap.billingPostalCode = businessDetail
                            ?.Address__PostalCode__s;
                    }
                    if (!isNullOrBlank(businessDetail.Tax_ID__c)) {
                        businessAccountWrap.taxId = businessDetail.Tax_ID__c;
                    }
                    if (!isNullOrBlank(businessDetail.Billing_Contact_Email__c)) {
                        businessAccountWrap.billingContactEmail = businessDetail.Billing_Contact_Email__c;
                    }
                    if (!isNullOrBlank(businessDetail.Billing_Contact_First_Name__c)) {
                        businessAccountWrap.billingContactFirstName = businessDetail.Billing_Contact_First_Name__c;
                    }
                    if (!isNullOrBlank(businessDetail.Billing_Contact_Last_Name__c)) {
                        businessAccountWrap.billingContactLastName = businessDetail.Billing_Contact_Last_Name__c;
                    }
                    if (!isNullOrBlank(businessDetail.Billing_Contact_Phone__c)) {
                        businessAccountWrap.billingContactPhone = businessDetail.Billing_Contact_Phone__c;
                    }
                    if (!isNullOrBlank(businessDetail.Representative_Email__c)) {
                        businessAccountWrap.representativeEmail = businessDetail.Representative_Email__c;
                        contactEmail.add(businessDetail.Representative_Email__c);
                    }
                    if (!isNullOrBlank(businessDetail.Representative_Phone__c)) {
                        businessAccountWrap.representativePhone = businessDetail.Representative_Phone__c;
                        contactPhone.add(businessDetail.Representative_Phone__c);
                    }
                    if (!isNullOrBlank(businessDetail.Representative_First_Name__c)) {
                        businessAccountWrap.representativeFirstName = businessDetail.Representative_First_Name__c;
                    }
                    if (!isNullOrBlank(businessDetail.Representative_Last_Name__c)) {
                        businessAccountWrap.representativeLastName = businessDetail.Representative_Last_Name__c;
                    }
                    if (!isNullOrBlank(businessDetail.Representative_Date_of_Birth__c)) {
                        businessAccountWrap.representativeDateOfBirth = businessDetail.Representative_Date_of_Birth__c;
                    }
                    if (!isNullOrBlank(businessDetail.Bank_Account_Number__c)) {
                        businessAccountWrap.bankAccountNumber = businessDetail.Bank_Account_Number__c;
                    }
                    if (!isNullOrBlank(businessDetail.Routing_Number__c)) {
                        businessAccountWrap.routingNumber = businessDetail.Routing_Number__c;
                    }
                    if (!isNullOrBlank(businessDetail.Institution_Number__c)) {
                        businessAccountWrap.institutionNumber = businessDetail.Institution_Number__c;
                    }
                    if (!isNullOrBlank(businessDetail.Payment_Descriptor__c)) {
                        businessAccountWrap.paymentDescriptor = businessDetail.Payment_Descriptor__c;
                    }
                    if (!isNullOrBlank(businessDetail.Payment_Address__Street__s)) {
                        businessAccountWrap.paymentStreet = businessDetail
                            ?.Payment_Address__Street__s;
                    }
                    if (!isNullOrBlank(businessDetail.Payment_Address__City__s)) {
                        businessAccountWrap.paymentCity = businessDetail?.Payment_Address__City__s;
                    }
                    if (!isNullOrBlank(businessDetail.Payment_Address__StateCode__s)) {
                        if (businessDetail.Payment_Address__StateCode__s != null) {
                            businessAccountWrap.paymentStateCode = businessDetail.Payment_Address__StateCode__s;
                        }
                    }
                    if (!isNullOrBlank(businessDetail.Payment_Address__CountryCode__s)) {
                        if (businessDetail.Payment_Address__CountryCode__s != null) {
                            businessAccountWrap.paymentCountryCode = getCodeValue(
                                'Payment_Address__CountryCode__s',
                                'Business_Onboarding_Detail__c',
                                businessDetail.Payment_Address__CountryCode__s
                            );
                            businessAccountWrap.paymentCountry = getCountry(
                                businessDetail.Payment_Address__CountryCode__s
                            );
                        }
                    }
                    if (!isNullOrBlank(businessDetail.Payment_Address__PostalCode__s)) {
                        businessAccountWrap.paymentZipPostalCode = businessDetail
                            ?.Payment_Address__PostalCode__s;
                    }
                    if (businessDetail.Provincial_Tax_ID__c <> null) {
                        businessAccountWrap.provisionalTax = String.valueof(
                            businessDetail.Provincial_Tax_ID__c
                        );
                    }
                    if (!isNullOrBlank(eachLink.Business_Account__r.Name)) {
                        businessAccountWrap.Name = eachLink?.Business_Account__r.Name;
                    }
                    if (businessDetail.Photoshoot_Contact_Email__c <> null) {
                        businessAccountWrap.photoShootName = businessDetail.Photoshoot_Contact_First_Name__c;
                        businessAccountWrap.photoShootLastName = businessDetail.Photoshoot_Contact_Last_Name__c;
                        contactName.add(
                            businessDetail.Photoshoot_Contact_First_Name__c +
                                ' ' +
                                businessDetail.Photoshoot_Contact_Last_Name__c
                        );
                        businessAccountWrap.photoShootEmail = businessDetail.Photoshoot_Contact_Email__c;
                        contactEmail.add(businessDetail.Photoshoot_Contact_Email__c);
                        businessAccountWrap.photoShootPhone = businessDetail.Photoshoot_Contact_Phone__c;
                        contactPhone.add(businessDetail.Photoshoot_Contact_Phone__c);
                        businessAccountWrap.photoShootMobile = businessDetail.Photoshoot_Contact_Mobile_Phone__c;
                    }
                    if (businessDetail.Business_Owner_Email__c <> null) {
                        businessAccountWrap.businessName = businessDetail.Business_Owner_First_Name__c;
                        businessAccountWrap.businessLastName = businessDetail.Business_Owner_Last_Name__c;
                        businessAccountWrap.businessOwnerDOB = businessDetail.Business_Owner_DOB__c;
                        contactName.add(
                            businessDetail.Business_Owner_First_Name__c +
                                ' ' +
                                businessDetail.Business_Owner_Last_Name__c
                        );
                        businessAccountWrap.businessEmail = businessDetail.Business_Owner_Email__c;
                        businessAccountWrap.businessOwnerCountry = businessDetail.Business_Owner_Address__CountryCode__s;
                        businessAccountWrap.businessOwnerState = businessDetail.Business_Owner_Address__StateCode__s;
                        businessAccountWrap.businessOwnerStreet = businessDetail.Business_Owner_Address__Street__s;
                        businessAccountWrap.businessOwnerCity = businessDetail.Business_Owner_Address__City__s;
                        businessAccountWrap.businessOwnerZip = businessDetail.Business_Owner_Address__PostalCode__s;
                        contactEmail.add(businessDetail.Business_Owner_Email__c);
                        businessAccountWrap.businessPhone = businessDetail.Billing_Contact_Phone__c;
                        contactPhone.add(businessDetail.Billing_Contact_Phone__c);
                    }
                    if (businessDetail.Business_Director_Email__c <> null) {
                        businessAccountWrap.businessDirectorName = businessDetail.Business_Director_First_Name__c;
                        businessAccountWrap.businessDirectorLastName = businessDetail.Business_Director_Last_Name__c;
                        contactName.add(
                            businessDetail.Business_Director_First_Name__c +
                                ' ' +
                                businessDetail.Business_Director_Last_Name__c
                        );
                        businessAccountWrap.businessDirectorEmail = businessDetail.Business_Director_Email__c;
                        contactEmail.add(businessDetail.Business_Director_Email__c);
                        businessAccountWrap.businessDirectorPhone = businessDetail.Representative_Phone__c;
                        contactPhone.add(businessDetail.Representative_Phone__c);
                    }
                    businessAccountDetails.put(businessDetail.Id, businessAccountWrap);
                }
                if (businessAccountWrap.businessEmail <> null) {
                    ContactDto.Address contactAddress = setAddressWrapper(
                        businessAccountWrap.businessOwnerCountry,
                        businessAccountWrap.businessOwnerStreet,
                        businessAccountWrap.businessOwnerCity,
                        businessAccountWrap.businessOwnerState,
                        businessAccountWrap.businessOwnerZip
                    );
                    setContactInfoWrapper(
                        businessAccountWrap.businessName,
                        businessAccountWrap.businessLastName,
                        businessAccountWrap.businessEmail,
                        businessAccountWrap.businessPhone,
                        ROLE_BUSINESS_OWNER,
                        EMPTY_STRING,
                        businessAccountWrap.businessOwnerDOB,
                        EMPTY_STRING,
                        contactAddress
                    );
                }
                //contact for billing contact
                if (businessAccountWrap.billingContactEmail <> null) {
                    setContactInfoWrapper(
                        businessAccountWrap.billingContactFirstName,
                        businessAccountWrap.billingContactLastName,
                        businessAccountWrap.billingContactEmail,
                        businessAccountWrap.billingContactPhone,
                        ROLE_BUSINESS_ADMIN,
                        EMPTY_STRING,
                        null,
                        EMPTY_STRING,
                        new ContactDto.Address()
                    );
                    //Rep Contact creation for Decision Maker
                    setContactInfoWrapper(
                        businessAccountWrap.billingContactFirstName,
                        businessAccountWrap.billingContactLastName,
                        businessAccountWrap.billingContactEmail,
                        businessAccountWrap.billingContactPhone,
                        ROLE_DECISION_MAKER + DM_ROLE_BUSINESSACCOUNT_PLACEHOLDER,
                        EMPTY_STRING,
                        null,
                        EMPTY_STRING,
                        new ContactDto.Address()
                    );
                }
                if (businessAccountWrap.businessDirectorEmail <> null) {
                    setContactInfoWrapper(
                        businessAccountWrap.businessDirectorName,
                        businessAccountWrap.businessDirectorLastName,
                        businessAccountWrap.businessDirectorEmail,
                        businessAccountWrap.businessDirectorPhone,
                        ROLE_BUSINESS_DIRECTOR,
                        EMPTY_STRING,
                        null,
                        EMPTY_STRING,
                        new ContactDto.Address()
                    );
                }
                if (businessAccountWrap.photoShootEmail <> null) {
                    setContactInfoWrapper(
                        businessAccountWrap.photoShootName,
                        businessAccountWrap.photoShootLastName,
                        businessAccountWrap.photoShootEmail,
                        businessAccountWrap.photoShootPhone,
                        ROLE_PHOTOSHOOT_CONTACT,
                        EMPTY_STRING,
                        null,
                        businessAccountWrap.photoShootMobile,
                        new ContactDto.Address()
                    );
                }
                //Rep Contact creation for Payment Account
                if (businessAccountWrap.representativeEmail != null) {
                    setContactInfoWrapper(
                        businessAccountWrap.representativeFirstName,
                        businessAccountWrap.representativeLastName,
                        businessAccountWrap.representativeEmail,
                        businessAccountWrap.representativePhone,
                        ROLE_REPRESENTATIVE,
                        EMPTY_STRING,
                        businessAccountWrap.representativeDateOfBirth,
                        EMPTY_STRING,
                        new ContactDto.Address()
                    );
                }

                businessOnboardingIdToBusinessAccount.put(eachLink.Id, businessAccount);
                idToBusinessOnboardingLink.put(businessDetail.Id, businessDetail);
                businessOnboardingIdToMxOnboardingLink.put(businessDetail.Id, eachLink);

                businessAccount.Id = eachLink.Business_Account__c;
                if (!isNullOrBlank(businessAccountWrap.legalBusinessName)) {
                    businessAccount.Legal_Business_Name__c = businessAccountWrap.legalBusinessName;
                }
                if (!isNullOrBlank(businessAccountWrap.billingCountryCode)) {
                    businessAccount.BillingCountry = getCountry(
                        businessAccountWrap.billingCountryCode
                    );
                }
                if (!isNullOrBlank(businessAccountWrap.brand)) {
                    businessAccount.Brand__c = businessAccountWrap.brand;
                }
                if (!isNullOrBlank(businessAccountWrap.billingStreet)) {
                    businessAccount.BillingStreet = businessAccountWrap.billingStreet;
                }
                if (!isNullOrBlank(businessAccountWrap.billingCity)) {
                    businessAccount.BillingCity = businessAccountWrap.billingCity;
                }
                if (!isNullOrBlank(businessAccountWrap.billingStateCode)) {
                    businessAccount.BillingStateCode = businessAccountWrap.billingStateCode;
                }
                if (!isNullOrBlank(businessAccountWrap.billingCountryCode)) {
                    businessAccount.BillingCountryCode = businessAccountWrap.billingCountryCode;
                }
                if (!isNullOrBlank(businessAccountWrap.billingPostalCode)) {
                    businessAccount.BillingPostalCode = businessAccountWrap.billingPostalCode;
                }
                if (!isNullOrBlank(businessAccountWrap.taxId)) {
                    businessAccount.TaxID__c = businessAccountWrap.taxId;
                }
                businessAccount.Mx_Onboarding_Link_Id__c = mxOnboardingLinks[0].UUID__c;
                businessAccount.Segment__c = 'SMB';
                if (!isNullOrBlank(businessAccountWrap.provisionalTax)) {
                    businessAccount.Provincial_Tax_ID__c = Decimal.valueOf(
                        businessAccountWrap.provisionalTax
                    );
                }
                unitOfWorkBusinessAccount.registerDirty(businessAccount);
            }
        }
    }

    /**
     * @description It evaluates whether the received value is Null or Blank.
     * @JIRA# LEM-15113
     * @param valueToEvaluate
     * @return Boolean
     */
    private Boolean isNullOrBlank(Object valueToEvaluate) {
        return valueToEvaluate == null || String.isBlank(String.valueOf(valueToEvaluate));
    }

    /**
     * @description It is used to create and update Store Accounts based on Onboarding Inputs.
     */
    private void storeAccountCreateAndUpdateService() {
        Business_Onboarding_Detail__c businessDetail;
        Account storeAccount;
        List<String> seattleZipcodesList = System.Label.Seattle_Zipcodes.split(',');
        Set<String> seattleZipcodesSet = new Set<String>(seattleZipcodesList);
        //LEM-18245
        Schema.SObjectField parentField = Account.ParentId;
        List<Account> existingStoreAccounts = new List<Account>();
        Set<String> accStoreType = new Set<String>(); //'Brick and Mortar';
        Set<Id> accBrand = new Set<Id>();
        Set<String> accMsid = new Set<String>();

        //Iterate on the mx onboarding link record
        for (Mx_Onboarding_Link__c eachLink : mxOnboardingLinks) {
            Map<String, Object> payLoadData = (Map<String, Object>) JSON.deserializeUntyped(
                eachLink.Payload__c
            );
            parentIds.add(eachLink.Business_Account__c);
            //Create a map of store detail records for which store account details and other related records needs to be created
            storeMap = new Map<Id, StoreDetailsWrapper>();
            Map<Id, StoreDetailsWrapper> parentStoreDataMap = new Map<Id, StoreDetailsWrapper>();
            Map<Id, StoreDetailsWrapper> childStoreDataMap = new Map<Id, StoreDetailsWrapper>();

            //Get the details of business detail entered by the Sales Rep
            if (
                eachLink.Business_Onboarding_Details__r != null &&
                !eachLink.Business_Onboarding_Details__r.isEmpty()
            ) {
                businessDetail = eachLink.Business_Onboarding_Details__r[0];
                if (!isNullOrBlank(businessDetail.Brand__c)) {
                    accBrand.add(businessDetail.Brand__c);
                }
            }
            //Iterate on all the store detail records created
            for (Store_Detail__c eachStoreDetail : checkForStoreDetails(eachLink)) {
                if (eachStoreDetail.Store_Detail__c == null) {
                    StoreDetailsWrapper parentStoreWrapper = new StoreDetailsWrapper();
                    parentStoreWrapper.accessibilities = '{"needToClimb":false,"hasElevatorsOrRamps":false}';
                    parentStoreWrapper = createStoreWrapper(
                        parentStoreWrapper,
                        businessDetail,
                        payLoadData,
                        eachStoreDetail,
                        null,
                        eachLink
                    );
                    parentStoreDataMap.put(eachStoreDetail.Id, parentStoreWrapper);
                } else {
                    StoreDetailsWrapper childStoreWrapper = new StoreDetailsWrapper();
                    childStoreWrapper.accessibilities = '{"needToClimb":false,"hasElevatorsOrRamps":false}';
                    childStoreWrapper = createStoreWrapper(
                        childStoreWrapper,
                        businessDetail,
                        payLoadData,
                        eachStoreDetail,
                        parentStoreDataMap.get(eachStoreDetail.Store_Detail__c),
                        eachLink
                    );
                    childStoreDataMap.put(eachStoreDetail.id, childStoreWrapper);
                }
                if (!isNullOrBlank(eachStoreDetail.Merchant_Supplied_ID__c)) {
                    accMsid.add(eachStoreDetail.Merchant_Supplied_ID__c);
                }
                if (!isNullOrBlank(eachStoreDetail.Account_Type__c)) {
                    accStoreType.add(eachStoreDetail.Account_Type__c);
                }
            }
            storeMap = childStoreDataMap.size() > 0 ? childStoreDataMap : parentStoreDataMap;
        }

        //LEM-18245 : Query to fetch all business Account in the hierarchy
        fetchParentAccountsHierarchy(parentField, parentIds);
        // Query to fetch All store accounts with matching criteria
        existingStoreAccounts = AccountsSelector.newInstance()
            .selectMatchingAccounts(FIELDS_TO_QUERY, accStoreType, accBrand, parentIds);
        for (Id storeId : storeMap.KeySet()) {
            Store_Detail__c storeDetail;
            Id accountId;
            Boolean skipStoreDetailProcessing = false;
            Boolean matchingAddressFound = false;
            String msidStoreDetailKey;
            String addressVerifiedKey = generateAddressKey(
                storeMap.get(storeId).storeType,
                storeMap.get(storeId).Street,
                storeMap.get(storeId).City,
                storeMap.get(storeId).stateCode,
                getCountry(storeMap.get(storeId).countryCode),
                storeMap.get(storeId).postalCode
            );
            String addressUnverifiedKey = generateAddressKey(
                storeMap.get(storeId).storeType,
                storeMap.get(storeId).userEnteredStreet,
                storeMap.get(storeId).userEnteredCity,
                storeMap.get(storeId).userEnteredStateCode,
                getCountry(storeMap.get(storeId).userEnteredCountryCode),
                storeMap.get(storeId).userEnteredPostalCode
            );
            if (storeMap.get(storeId).merchantId <> null) {
                msidStoreDetailKey = generateMSIDKey(
                    storeMap.get(storeId).storeType,
                    businessVertical,
                    storeMap.get(storeId).merchantId
                );
            }
            if (!existingStoreAccounts.isEmpty()) {
                for (Account acc : existingStoreAccounts) {
                    Boolean hasActiveXref = acc.Xrefs__r.size() > 0 ? true : false;
                    String msidStoreKey;
                    String accountKey = generateAddressKey(
                        acc.Type,
                        acc.BillingStreet,
                        acc.BillingCity,
                        acc.BillingStateCode,
                        acc.BillingCountry,
                        acc.BillingPostalCode
                    );
                    if (String.isNotBlank(acc.Merchant_Supplied_ID__c)) {
                        msidStoreKey = generateMSIDKey(
                            acc.Type,
                            businessVertical,
                            acc.Merchant_Supplied_ID__c
                        );
                    }

                    if (
                        accountKey.equalsIgnoreCase(addressVerifiedKey) ||
                        accountKey.equalsIgnoreCase(addressUnverifiedKey)
                    ) {
                        storeDetail = new Store_Detail__c(Id = storeId);
                        matchingAddressFound = true;
                        if (hasActiveXref) {
                            skipStoreDetailProcessing = true;
                            storeDetail.Duplicate_Check_Status__c = DUPLICATE_NOT_PROCESSED;
                        } else {
                            accountId = acc.Id;
                            storeDetail.Duplicate_Check_Status__c = DUPLICATE_PROCESSED;
                        }
                        break;
                    } else if (
                        String.isNotBlank(msidStoreDetailKey) &&
                        String.isNotBlank(msidStoreKey) &&
                        msidStoreKey.equalsIgnoreCase(msidStoreDetailKey)
                    ) {
                        storeDetail = new Store_Detail__c(Id = storeId);
                        if (hasActiveXref) {
                            skipStoreDetailProcessing = true;
                            storeDetail.Duplicate_Check_Status__c = DUPLICATE_NOT_PROCESSED;
                        } else {
                            matchingAddressFound = true;
                            accountId = acc.Id;
                            storeDetail.Duplicate_Check_Status__c = DUPLICATE_PROCESSED;
                        }
                        break;
                    }
                    storeDetailIdToStoreAccount.put(storeId, storeAccount);
                }
                if (!skipStoreDetailProcessing) {
                    storeAccount = mapStoreAccountData(
                        storeAccount,
                        storeMap.get(storeId),
                        storeId,
                        matchingAddressFound,
                        seattleZipcodesSet,
                        accountId
                    );
                    storeContactWrapperCreation(storeMap, storeId);
                    unitOfWork.registerUpsert(storeAccount);
                }
                if (storeDetail != null) {
                    unitOfWorkStoreDetail.registerDirty(storeDetail);
                }
            } else {
                storeAccount = mapStoreAccountData(
                    storeAccount,
                    storeMap.get(storeId),
                    storeId,
                    false,
                    seattleZipcodesSet,
                    accountId
                );
                storeContactWrapperCreation(storeMap, storeId);
                unitOfWork.registerUpsert(storeAccount);
                storeDetailIdToStoreAccount.put(storeId, storeAccount);
            }
        }
        unitOfWorkStoreDetail.commitWork();
    }

    /**
     * @description It creates wrapper of Store Detail record values to create Store Account.
     * @JIRA# LEM-15113
     * @param storeDataWrap
     * @param businessDetail
     * @param payLoadData
     * @param eachStoreDetail
     * @param parentStoreDataWrap
     * @param eachLink
     * @return StoreDetailsWrapper
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private StoreDetailsWrapper createStoreWrapper(
        StoreDetailsWrapper storeDataWrap,
        Business_Onboarding_Detail__c businessDetail,
        Map<String, Object> payLoadData,
        Store_Detail__c eachStoreDetail,
        StoreDetailsWrapper parentStoreDataWrap,
        Mx_Onboarding_Link__c eachLink
    ) {
        if (!isNullOrBlank(businessDetail?.Legal_Business_Name__c)) {
            storeDataWrap.legalBusinessName = businessDetail.Legal_Business_Name__c;
        } else if (
            !isNullOrBlank(eachStoreDetail?.Legal_Business_Name__c) ||
            (parentStoreDataWrap != null &&
            parentStoreDataWrap.legalBusinessName != null)
        ) {
            storeDataWrap.legalBusinessName = !isNullOrBlank(eachStoreDetail.Legal_Business_Name__c)
                ? eachStoreDetail.Legal_Business_Name__c
                : (parentStoreDataWrap != null ? parentStoreDataWrap.legalBusinessName : '');
        } else if (!isNullOrBlank(eachLink.Business_Account__r?.Legal_Business_Name__c)) {
            storeDataWrap.legalBusinessName = eachLink.Business_Account__r.Legal_Business_Name__c;
        }
        if (!isNullOrBlank(businessDetail?.Activated_Centrally_AC__c)) {
            storeDataWrap.activatedCentrally = businessDetail.Activated_Centrally_AC__c;
        }
        if (!isNullOrBlank(businessDetail?.Proposed_Date_of_Activation__c)) {
            storeDataWrap.proposedDateOfActivation = businessDetail.Proposed_Date_of_Activation__c;
        }
        if (!isNullOrBlank(businessDetail?.Order_Protocol__c)) {
            storeDataWrap.orderProtocol = businessDetail.Order_Protocol__c;
        }
        if (!isNullOrBlank(payLoadData.get('brandName'))) {
            storeDataWrap.businessBrand = (String) payLoadData.get('brandName');
        }
        storeDataWrap.selfDelivery = (Boolean) payLoadData.get(IS_SELF_DELIVERY) ? 'Yes' : 'No';
        storeDataWrap.Street = !isNullOrBlank(eachStoreDetail.Address__Street__s)
            ? eachStoreDetail.Address__Street__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.Street : '');
        storeDataWrap.City = !isNullOrBlank(eachStoreDetail.Address__City__s)
            ? eachStoreDetail.Address__City__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.City : '');
        storeDataWrap.stateCode = !isNullOrBlank(eachStoreDetail.Address__StateCode__s)
            ? eachStoreDetail.Address__StateCode__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.stateCode : '');
        storeDataWrap.countryCode = !isNullOrBlank(eachStoreDetail.Address__CountryCode__s)
            ? eachStoreDetail.Address__CountryCode__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.countryCode : '');
        storeDataWrap.postalCode = !isNullOrBlank(eachStoreDetail.Address__PostalCode__s)
            ? eachStoreDetail.Address__PostalCode__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.postalCode : '');
        storeDataWrap.userEnteredStreet = !isNullOrBlank(
                eachStoreDetail.User_Entered_Address__Street__s
            )
            ? eachStoreDetail.User_Entered_Address__Street__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.userEnteredStreet : '');
        storeDataWrap.userEnteredCity = !isNullOrBlank(
                eachStoreDetail.User_Entered_Address__City__s
            )
            ? eachStoreDetail.User_Entered_Address__City__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.userEnteredCity : '');
        storeDataWrap.userEnteredStateCode = !isNullOrBlank(
                eachStoreDetail.User_Entered_Address__StateCode__s
            )
            ? eachStoreDetail.User_Entered_Address__StateCode__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.userEnteredStateCode : '');
        storeDataWrap.userEnteredCountryCode = !isNullOrBlank(
                eachStoreDetail.User_Entered_Address__CountryCode__s
            )
            ? eachStoreDetail.User_Entered_Address__CountryCode__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.userEnteredCountryCode : '');
        storeDataWrap.userEnteredPostalCode = !isNullOrBlank(
                eachStoreDetail.User_Entered_Address__PostalCode__s
            )
            ? eachStoreDetail.User_Entered_Address__PostalCode__s
            : (parentStoreDataWrap != null ? parentStoreDataWrap.userEnteredPostalCode : '');
        storeDataWrap.alternativeStoreName = !isNullOrBlank(
                eachStoreDetail.Alternative_Store_Name_Mx_Portal__c
            )
            ? eachStoreDetail.Alternative_Store_Name_Mx_Portal__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.alternativeStoreName : '');
        storeDataWrap.merchantId = !isNullOrBlank(eachStoreDetail.Merchant_Supplied_ID__c)
            ? eachStoreDetail.Merchant_Supplied_ID__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.merchantId : '');
        storeDataWrap.phone = !isNullOrBlank(eachStoreDetail.Phone__c)
            ? eachStoreDetail.Phone__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.phone : '');
        storeDataWrap.hoursOfOperation = !isNullOrBlank(eachStoreDetail.Hours_of_Operation__c)
            ? eachStoreDetail.Hours_of_Operation__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.hoursOfOperation : '');
        storeDataWrap.institutionNumber = !isNullOrBlank(eachStoreDetail.Institution_Number__c)
            ? eachStoreDetail.Institution_Number__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.institutionNumber : '');
        storeDataWrap.menuURL = !isNullOrBlank(eachStoreDetail.Menu_URL__c)
            ? eachStoreDetail.Menu_URL__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.menuURL : '');
        storeDataWrap.menuSetupMethod = !isNullOrBlank(eachStoreDetail.Menu_Setup_Method__c)
            ? eachStoreDetail.Menu_Setup_Method__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.menuSetupMethod : '');
        storeDataWrap.menuToBeCompletedBy = !isNullOrBlank(
                eachStoreDetail.Menu_to_be_Completed_By__c
            )
            ? eachStoreDetail.Menu_to_be_Completed_By__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.menuToBeCompletedBy : '');
        storeDataWrap.salesNotes = !isNullOrBlank(eachStoreDetail.Sales_Notes_for_Menu_Team__c)
            ? eachStoreDetail.Sales_Notes_for_Menu_Team__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.salesNotes : '');
        storeDataWrap.Inflation = !isNullOrBlank(eachStoreDetail.Inflation__c)
            ? eachStoreDetail.Inflation__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.Inflation : null);
        storeDataWrap.taxCategory = !isNullOrBlank(
                eachStoreDetail.Item_Level_Tax_Categories_Rates__c
            )
            ? eachStoreDetail.Item_Level_Tax_Categories_Rates__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.taxCategory : '');
        storeDataWrap.inflationRoundUnit = !isNullOrBlank(
                eachStoreDetail.Inflation_Rounding_Unit__c
            )
            ? eachStoreDetail.Inflation_Rounding_Unit__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.inflationRoundUnit : null);
        storeDataWrap.taxOverrideRate = !isNullOrBlank(eachStoreDetail.Tax_Override_Rate__c)
            ? eachStoreDetail.Tax_Override_Rate__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.taxOverrideRate : null);
        storeDataWrap.pickupInstructions = !isNullOrBlank(
                eachStoreDetail.In_Store_Pickup_Instructions__c
            )
            ? eachStoreDetail.In_Store_Pickup_Instructions__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.pickupInstructions : '');
        storeDataWrap.arrivalInstructions = !isNullOrBlank(
                eachStoreDetail.Parking_Arrival_Instructions__c
            )
            ? eachStoreDetail.Parking_Arrival_Instructions__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.arrivalInstructions : '');
        storeDataWrap.dmEmail = !isNullOrBlank(eachStoreDetail.DM_Email__c)
            ? eachStoreDetail.DM_Email__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.dmEmail : '');
        storeDataWrap.dmName = !isNullOrBlank(eachStoreDetail.DM_First_Name__c)
            ? eachStoreDetail.DM_First_Name__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.dmName : '');
        storeDataWrap.dmLastName = !isNullOrBlank(eachStoreDetail.DM_Last_Name__c)
            ? eachStoreDetail.DM_Last_Name__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.dmLastName : '');
        storeDataWrap.dmPhone = !isNullOrBlank(eachStoreDetail.DM_Phone__c)
            ? eachStoreDetail.DM_Phone__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.dmPhone : '');
        storeDataWrap.representativeEmail = !isNullOrBlank(eachStoreDetail.Representative_Email__c)
            ? eachStoreDetail.Representative_Email__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.representativeEmail : '');
        storeDataWrap.representativePhone = !isNullOrBlank(eachStoreDetail.Representative_Phone__c)
            ? eachStoreDetail.Representative_Phone__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.representativePhone : '');
        storeDataWrap.representativeFirstName = !isNullOrBlank(
                eachStoreDetail.Representative_First_Name__c
            )
            ? eachStoreDetail.Representative_First_Name__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.representativeFirstName : '');
        storeDataWrap.representativeLastName = !isNullOrBlank(
                eachStoreDetail.Representative_Last_Name__c
            )
            ? eachStoreDetail.Representative_Last_Name__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.representativeLastName : '');
        storeDataWrap.representativeDateOfBirth = !isNullOrBlank(
                eachStoreDetail.Representative_Date_of_Birth__c
            )
            ? eachStoreDetail.Representative_Date_of_Birth__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.representativeDateOfBirth : null);
        storeDataWrap.bankAccountNumber = !isNullOrBlank(eachStoreDetail.Bank_Account_Number__c)
            ? eachStoreDetail.Bank_Account_Number__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.bankAccountNumber : '');
        storeDataWrap.routingNumber = !isNullOrBlank(eachStoreDetail.Routing_Number__c)
            ? eachStoreDetail.Routing_Number__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.routingNumber : '');
        storeDataWrap.institutionNumber = !isNullOrBlank(eachStoreDetail.Institution_Number__c)
            ? eachStoreDetail.Institution_Number__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.institutionNumber : '');
        storeDataWrap.paymentDescriptor = !isNullOrBlank(eachStoreDetail.Payment_Descriptor__c)
            ? eachStoreDetail.Payment_Descriptor__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.paymentDescriptor : '');
        storeDataWrap.businessWebSite = !isNullOrBlank(eachStoreDetail.Storefront_Website__c)
            ? eachStoreDetail.Storefront_Website__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.businessWebSite : '');
        storeDataWrap.matchBrandedWebSite = !isNullOrBlank(
                eachStoreDetail.Storefront_Match_Branded_Website__c
            )
            ? eachStoreDetail.Storefront_Match_Branded_Website__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.matchBrandedWebSite : '');
        storeDataWrap.ssn = !isNullOrBlank(eachStoreDetail.SSN_Last_4Digits__c)
            ? eachStoreDetail.SSN_Last_4Digits__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.ssn : '');
        storeDataWrap.mxHasSite = !isNullOrBlank(eachStoreDetail.Storefront_Mx_Has_Website__c)
            ? eachStoreDetail.Storefront_Mx_Has_Website__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.mxHasSite : '');
        storeDataWrap.webSiteCreationNeeded = !isNullOrBlank(
                eachStoreDetail.Website_Creation_Needed_for_Storefront__c
            )
            ? eachStoreDetail.Website_Creation_Needed_for_Storefront__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.webSiteCreationNeeded : '');
        storeDataWrap.storeType = !isNullOrBlank(eachStoreDetail.Account_Type__c)
            ? eachStoreDetail.Account_Type__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.storeType : '');
        storeDataWrap.orderProtocolEmail = !isNullOrBlank(eachStoreDetail.Order_Protocol_Email__c)
            ? eachStoreDetail.Order_Protocol_Email__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.orderProtocolEmail : '');
        storeDataWrap.aorEnabled = !isNullOrBlank(eachStoreDetail.AOR_Enabled__c)
            ? eachStoreDetail.AOR_Enabled__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.aorEnabled : '');
        storeDataWrap.storeCoverage = !isNullOrBlank(eachStoreDetail.Coverage__c)
            ? eachStoreDetail.Coverage__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.storeCoverage : '');
        storeDataWrap.aorDistance = !isNullOrBlank(eachStoreDetail.AOR_Distance__c)
            ? eachStoreDetail.AOR_Distance__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.aorDistance : null);
        storeDataWrap.posIntegrationType = !isNullOrBlank(eachStoreDetail.POS_Integration_Type__c)
            ? eachStoreDetail.POS_Integration_Type__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.posIntegrationType : '');
        storeDataWrap.posIntegrationId = !isNullOrBlank(eachStoreDetail.POS_Integration_ID__c)
            ? eachStoreDetail.POS_Integration_ID__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.posIntegrationId : '');
        storeDataWrap.posIntegrationSystem = !isNullOrBlank(eachStoreDetail.POS_System__c)
            ? eachStoreDetail.POS_System__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.posIntegrationSystem : '');
        storeDataWrap.posFallBackProtocol = !isNullOrBlank(eachStoreDetail.POS_Fallback_Protocol__c)
            ? eachStoreDetail.POS_Fallback_Protocol__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.posFallBackProtocol : '');
        storeDataWrap.customDeliveryFee = !isNullOrBlank(eachStoreDetail.Custom_Delivery_Fee__c)
            ? eachStoreDetail.Custom_Delivery_Fee__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.customDeliveryFee : null);
        storeDataWrap.customDeliveryRadius = !isNullOrBlank(
                eachStoreDetail.Custom_Delivery_Radius__c
            )
            ? eachStoreDetail.Custom_Delivery_Radius__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.customDeliveryRadius : null);
        storeDataWrap.maxDeliveryRadius = !isNullOrBlank(eachStoreDetail.Max_Delivery_Radius_KM__c)
            ? eachStoreDetail.Max_Delivery_Radius_KM__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.maxDeliveryRadius : null);
        storeDataWrap.tabletDeliveryMethod = !isNullOrBlank(
                eachStoreDetail.Tablet_Delivery_Method__c
            )
            ? eachStoreDetail.Tablet_Delivery_Method__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.tabletDeliveryMethod : '');
        storeDataWrap.proposedDateOfTablet = !isNullOrBlank(
                eachStoreDetail.Proposed_Date_of_Tablet__c
            )
            ? eachStoreDetail.Proposed_Date_of_Tablet__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.proposedDateOfTablet : null);
        storeDataWrap.delayTabletShipment = !isNullOrBlank(eachStoreDetail.Delay_Tablet_Shipment__c)
            ? eachStoreDetail.Delay_Tablet_Shipment__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.delayTabletShipment : null);
        storeDataWrap.birthDate = !isNullOrBlank(eachStoreDetail.Birthdate__c)
            ? eachStoreDetail.Birthdate__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.birthDate : null);
        storeDataWrap.proposedStateOfImpl = !isNullOrBlank(
                eachStoreDetail.Storefront_Proposed_Date_of_Impl__c
            )
            ? eachStoreDetail.Storefront_Proposed_Date_of_Impl__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.proposedStateOfImpl : null);
        storeDataWrap.storeCoverage = !isNullOrBlank(eachStoreDetail.Coverage__c)
            ? eachStoreDetail.Coverage__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.storeCoverage : '');
        storeDataWrap.addressId = !isNullOrBlank(eachStoreDetail.Address_ID__c)
            ? eachStoreDetail.Address_ID__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.addressId : '');
        storeDataWrap.rejectedReason = !isNullOrBlank(eachStoreDetail.Rejected_Reason__c)
            ? eachStoreDetail.Rejected_Reason__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.rejectedReason : '');
        storeDataWrap.addressVerificationDate = !isNullOrBlank(
                eachStoreDetail.Address_Verification_Date__c
            )
            ? eachStoreDetail.Address_Verification_Date__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.addressVerificationDate : null);
        storeDataWrap.lastCoverageCheckTime = !isNullOrBlank(
                eachStoreDetail.Last_Coverage_Check_Time__c
            )
            ? eachStoreDetail.Last_Coverage_Check_Time__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.lastCoverageCheckTime : null);
        storeDataWrap.startingPoint = !isNullOrBlank(eachStoreDetail.Starting_Point__c)
            ? eachStoreDetail.Starting_Point__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.startingPoint : '');
        storeDataWrap.startingPointId = !isNullOrBlank(eachStoreDetail.Starting_Point_ID__c)
            ? eachStoreDetail.Starting_Point_ID__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.startingPointId : null);
        storeDataWrap.alcoholEligibility = !isNullOrBlank(eachStoreDetail.Alcohol_Eligibility__c)
            ? eachStoreDetail.Alcohol_Eligibility__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.alcoholEligibility : '');
        storeDataWrap.submarketId = !isNullOrBlank(eachStoreDetail.Submarket__c)
            ? eachStoreDetail.Submarket__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.submarketId : null);
        storeDataWrap.timeZoneBackend = !isNullOrBlank(eachStoreDetail.Time_Zone_Backend__c)
            ? eachStoreDetail.Time_Zone_Backend__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.timeZoneBackend : '');
        storeDataWrap.taxId = !isNullOrBlank(eachStoreDetail.Tax_ID__c)
            ? eachStoreDetail.Tax_ID__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.taxId : '');
        storeDataWrap.provisionalTax = !isNullOrBlank(eachStoreDetail.Provincial_Tax_Id__c)
            ? eachStoreDetail.Provincial_Tax_Id__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.provisionalTax : '');
        storeDataWrap.addressVerification = eachStoreDetail.Address_Verification_Status__c !=
            NOT_APPLICABLE
            ? eachStoreDetail.Address_Verification_Status__c
            : (parentStoreDataWrap != null ? parentStoreDataWrap.addressVerification : '');
        Map<String, Object> accessibilitiesMap = (Map<String, Object>) JSON.deserializeUntyped(
            eachStoreDetail.Accessibilities__c
        );
        if (
            (Boolean) accessibilitiesMap.get('needToClimb') ||
            (Boolean) accessibilitiesMap.get('hasElevatorsOrRamps')
        ) {
            storeDataWrap.accessibilities = eachStoreDetail.Accessibilities__c;
        } else if (
            parentStoreDataWrap != null && !isEmptyOrNull(parentStoreDataWrap.accessibilities)
        ) {
            accessibilitiesMap = (Map<String, Object>) JSON.deserializeUntyped(
                parentStoreDataWrap.accessibilities
            );
            if (
                (Boolean) accessibilitiesMap.get('needToClimb') ||
                (Boolean) accessibilitiesMap.get('hasElevatorsOrRamps')
            ) {
                storeDataWrap.accessibilities = parentStoreDataWrap.accessibilities;
            }
        }

        return storeDataWrap;
    }

    /**
     * @description Contact data mapping for Store Accounts
     * @JIRA# LEM-18245
     * @param storeMap
     * @param storeId
     */
    private void storeContactWrapperCreation(Map<Id, StoreDetailsWrapper> storeMap, Id storeId) {
        if (storeMap.get(storeId).dmEmail <> null) {
            setContactInfoWrapper(
                storeMap.get(storeId).dmName,
                storeMap.get(storeId).dmLastName,
                storeMap.get(storeId).dmEmail,
                storeMap.get(storeId).dmPhone,
                ROLE_DECISION_MAKER,
                EMPTY_STRING,
                null,
                EMPTY_STRING,
                new ContactDto.Address()
            );
            String key =
                storeMap.get(storeId).dmEmail +
                SEPARATOR +
                storeMap.get(storeId).dmName +
                SEPARATOR +
                storeMap.get(storeId).dmLastName;
            storeIdToDecisionMakerContacts.put(storeId, contactIdentifierToContactInfo.get(key));
        }
        //Rep Contact creation for Payment Account
        if (storeMap.get(storeId).representativeEmail != null) {
            setContactInfoWrapper(
                storeMap.get(storeId).representativeFirstName,
                storeMap.get(storeId).representativeLastName,
                storeMap.get(storeId).representativeEmail,
                storeMap.get(storeId).representativePhone,
                ROLE_REPRESENTATIVE,
                storeMap.get(storeId).ssn,
                isNullOrBlank(storeMap.get(storeId).birthDate)
                    ? storeMap.get(storeId).representativeDateOfBirth
                    : storeMap.get(storeId).birthDate,
                EMPTY_STRING,
                new ContactDto.Address()
            );
        }
    }

    /**
     * @description Generate mapping key to establish relation between Store and Store Detail
     * @JIRA# LEM-18245
     * @param accountType
     * @param street
     * @param city
     * @param stateCode
     * @param country
     * @param postalCode
     * @return String
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private String generateAddressKey(
        String accountType,
        String street,
        String city,
        String stateCode,
        String country,
        String postalCode
    ) {
        accountType = String.isNotBlank(accountType) ? accountType : '';
        city = String.isNotBlank(city) ? city : '';
        country = String.isNotBlank(country) ? country : '';
        postalCode = String.isNotBlank(postalCode) ? postalCode : '';
        stateCode = String.isNotBlank(stateCode) ? stateCode : '';
        street = String.isNotBlank(street) ? street.replaceAll(NEW_LINE, '') : '';
        return accountType +
            UNDERSCORE_SEPARATOR +
            street +
            UNDERSCORE_SEPARATOR +
            city +
            UNDERSCORE_SEPARATOR +
            stateCode +
            UNDERSCORE_SEPARATOR +
            country +
            UNDERSCORE_SEPARATOR +
            postalCode;
    }

    /**
     * @description Generate mapping key to establish relation between Store and Store Detail
     * @JIRA# LEM-18245
     * @param accountType
     * @param businessVertical
     * @param merchantSuppliedId
     * @return String
     */
    private String generateMSIDKey(
        String accountType,
        String businessVertical,
        String merchantSuppliedId
    ) {
        return accountType +
            UNDERSCORE_SEPARATOR +
            businessVertical +
            UNDERSCORE_SEPARATOR +
            merchantSuppliedId;
    }

    /**
     * @description To map data from Store detail to Store
     * @JIRA# LEM-18245
     * @param storeAccount
     * @param storeDetails
     * @param storeId
     * @param matchingAddressFound
     * @param seattleZipcodesSet
     * @param accountId
     * @return Account
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private Account mapStoreAccountData(
        Account storeAccount,
        StoreDetailsWrapper storeDetails,
        Id storeId,
        Boolean matchingAddressFound,
        Set<String> seattleZipcodesSet,
        Id accountId
    ) {
        skipRecordProcessing = false;
        storeAccount = new Account();
        if (accountId != null) {
            storeAccount.Id = accountId;
        }
        storeAccount.Legal_Business_Name__c = storeDetails.legalBusinessName;
        if (!matchingAddressFound) {
            storeAccount.BillingStreet = storeDetails.Street;
            storeAccount.BillingCity = storeDetails.City;
            storeAccount.BillingStateCode = storeDetails.stateCode;
            storeAccount.BillingCountry = getCountry(storeDetails.countryCode);
            storeAccount.BillingCountryCode = storeDetails.countryCode;
            storeAccount.BillingPostalCode = storeDetails.postalCode;
            if (storeDetails.addressVerification == VERIFIED) {
                storeAccount.Duplicate_Status__c = NON_DUPLICATE;
            }
            storeAccount.Address_Verification_Status__c = storeDetails.addressVerification;
            storeAccount.Address_ID__c = storeDetails.addressId;
            storeAccount.Rejected_Reason__c = storeDetails.rejectedReason;
            storeAccount.Address_Verification_Date__c = storeDetails.addressVerificationDate;
        }
        storeAccount.Alternative_Store_Name__c = storeDetails.alternativeStoreName;
        storeAccount.Type = storeDetails.storeType; //the picklist values do no matchstoreDataWrap.
        storeAccount.Merchant_Supplied_ID__c = storeDetails.merchantId;
        storeAccount.Phone = storeDetails.phone;
        storeAccount.Hours_of_Operation__c = storeDetails.hoursOfOperation;
        storeAccount.Menu_URL__c = storeDetails.menuURL;
        storeAccount.Proposed_Date_of_Implementation__c = storeDetails.proposedStateOfImpl;
        storeAccount.Menu_Setup_Method__c = storeDetails.menuSetupMethod;
        storeAccount.Menu_to_be_Completed_By__c = storeDetails.menuToBeCompletedBy;
        storeAccount.Sales_Notes_for_Menu_Team__c = storeDetails.salesNotes;
        storeAccount.Inflation__c = storeDetails.Inflation;
        storeAccount.Item_Level_Tax_Categories_Rates__c = storeDetails.taxCategory;
        storeAccount.Inflation_Rounding_Unit__c = storeDetails.inflationRoundUnit;
        storeAccount.Tax_Override_Rate__c = storeDetails.taxOverrideRate;
        storeAccount.In_Store_Pickup_Instructions__c = storeDetails.pickupInstructions;
        storeAccount.Parking_Arrival_Instructions__c = storeDetails.arrivalInstructions;
        storeAccount.Mx_Onboarding_Link_Id__c = mxOnboardingLinks[0].UUID__c;
        storeAccount.recordTypeId = STORE_ACCOUNT_RECORD_TYPE;
        storeAccount.Storefront_Website__c = storeDetails.businessWebSite;
        storeAccount.Storefront_Match_Branded_Website__c = storeDetails.matchBrandedWebSite;
        storeAccount.Storefront_Mx_Has_Website__c = storeDetails.mxHasSite;
        storeAccount.Website_Creation_Needed_for_Storefront__c = storeDetails.webSiteCreationNeeded;
        storeAccount.Order_Protocol_Email__c = storeDetails.orderProtocolEmail;
        storeAccount.AOR_Distance__c = storeDetails.aorDistance;
        storeAccount.AOR_Enabled__c = storeDetails.aorEnabled;
        storeAccount.POS_Integration_Type__c = storeDetails.posIntegrationType;
        storeAccount.POS_Integration_ID__c = storeDetails.posIntegrationId;
        storeAccount.POS_System__c = storeDetails.posIntegrationSystem;
        storeAccount.POS_Fallback_Protocol__c = storeDetails.posFallBackProtocol;
        storeAccount.Custom_Delivery_Fee__c = storeDetails.customDeliveryFee;
        storeAccount.Custom_Delivery_Radius__c = storeDetails.customDeliveryRadius;
        storeAccount.Max_Delivery_Radius_KM__c = storeDetails.maxDeliveryRadius;
        storeAccount.Delay_Tablet_Shipment__c = storeDetails.delayTabletShipment;
        storeAccount.Proposed_Date_of_Tablet__c = storeDetails.proposedDateOfTablet;
        storeAccount.Tablet_Delivery_Method__c = storeDetails.tabletDeliveryMethod;
        storeAccount.Coverage__c = storeDetails.storeCoverage;
        storeAccount.Segment__c = 'SMB';
        storeAccount.ParentId = mxOnboardingLinks[0].Business_Account__c;
        storeAccount.Proposed_Date_of_Activation__c = storeDetails.proposedDateOfActivation;
        storeAccount.Order_Protocol__c = storeDetails.orderProtocol;
        storeAccount.Activated_Centrally_AC__c = storeDetails.activatedCentrally;
        storeAccount.Business_Vertical__c = businessVertical;
        storeAccount.Brand__c = storeDetails.businessBrand;
        storeAccount.Accessibilities__c = (storeDetails.postalCode != null &&
            seattleZipcodesSet.contains(storeDetails.postalCode))
            ? '{"accessibilities":' + storeDetails.accessibilities + '}'
            : '';
        storeAccount.Store_Details__c = storeId;
        storeAccount.Last_Coverage_Check_Time__c = storeDetails.lastCoverageCheckTime;
        storeAccount.Starting_Point__c = storeDetails.startingPoint;
        storeAccount.Starting_Point_ID__c = storeDetails.startingPointId;
        storeAccount.Alcohol_Eligibility__c = storeDetails.alcoholEligibility;
        storeAccount.SubMarket__c = storeDetails.submarketId;
        storeAccount.Time_Zone_Backend__c = storeDetails.timeZoneBackend;
        storeAccount.Self_Delivery__c = storeDetails.selfDelivery;
        storeAccount.TaxID__c = storeDetails.taxId;
        storeAccount.Provincial_Tax_ID__c = String.isNotBlank(storeDetails.provisionalTax)
            ? Decimal.valueOf(storeDetails.provisionalTax)
            : null;
        return storeAccount;
    }

    /**
     * @description It fetches verified stores on basis of the passed lastReturnedId and
     * parentField on Work Order.
     * @param parentField
     * @param topParentIds
     */
    private void fetchParentAccountsHierarchy(
        Schema.SObjectField parentField,
        Set<Id> topParentIds
    ) {
        Boolean fetchRecursively = true;
        Set<Id> currentParentIds = topParentIds;
        do {
            currentParentIds = new Set<Id>(getChildParentAccountIds(parentField, currentParentIds));
            currentParentIds.remove(null);
            parentIds.addAll(currentParentIds);
            if (currentParentIds.isEmpty()) {
                fetchRecursively = false;
            } else if (isLimitExceeded()) {
                fetchRecursively = false;
            }
        } while (fetchRecursively);
    }

    /**
     * @description It fetches business Account Ids from the passed set of Ids
     * @JIRA# LEM-18245
     * @param parentField
     * @param parentIds
     * @return Set<Id>
     */
    private Set<Id> getChildParentAccountIds(Schema.SObjectField parentField, Set<Id> parentIds) {
        Map<Id, Account> childParentAccounts = new Map<Id, Account>(
            AccountsSelector.newInstance().selectBusinessAccountsByParentIds(parentField, parentIds)
        );
        return childParentAccounts.keySet();
    }

    /**
     * @description It checks whether Query rows & SOQL limits exceeded.
     * @JIRA# LEM-18245
     * @return Boolean
     */
    private Boolean isLimitExceeded() {
        return (Limits.getLimitQueries() - Limits.getQueries()) < queriesAllowedLimit ||
            (Limits.getLimitQueryRows() - Limits.getQueryRows()) < queryRowsAllowedLimit ||
            (Limits.getLimitCpuTime() - Limits.getCpuTime()) < 500;
    }

    private String getCountry(String countryCode) {
        switch on COUNTRYMAPPINGS.get(countryCode) {
            when UNITEDSTATES {
                return COUNTRY_US;
            }
            when CANADA {
                return COUNTRY_CA;
            }
            when AUSTRALIA {
                return COUNTRY_AU;
            }
            when NEWZEALAND {
                return COUNTRY_NZ;
            }
        }
        return null;
    }

    /*  private String getCountryCode(String country) {
    switch on COUNTRYCODEMAPPINGS.get(country) {
      when US {
        return COUNTRY_CODE_US;
      }
      when CA {
        return COUNTRY_CODE_CA;
      }
      when AU {
        return COUNTRY_CODE_AU;
      }
      when NZ {
        return COUNTRY_CODE_NZ;
      }
    }
    return null;
  }
*/
    private List<Store_Detail__c> checkForStoreDetails(Mx_Onboarding_Link__c onboardingLink) {
        List<Store_Detail__c> storeDetails = new List<Store_Detail__c>();
        if (onboardingLink.Store_Details__r == null || onboardingLink.Store_Details__r.isEmpty()) {
            return storeDetails;
        }
        for (Store_Detail__c eachStoreDetail : onboardingLink.Store_Details__r) {
            storeDetails.add(eachStoreDetail);
        }

        return storeDetails;
    }

    /**
     * @description Updating opportunity stage to Closed Won in case of NSE scenarios.
     */
    private void updateOpportunity() {
        Set<Id> accountIds = new Set<Id>();
        for (Mx_Onboarding_Link__c eachLink : mxOnboardingLinks) {
            if (eachLink.Onboarding_Scenario__c == ONBOARDING_SCENARIO_NSE) {
                accountIds.add(eachLink.Contract__r.AccountId);
            }
        }
        if (!accountIds.isEmpty()) {
            for (
                Opportunity eachOpportunityToBeUpdated : OpportunitiesSelector.newInstance()
                    .selectBySubTypeAndAccount(accountIds)
            ) {
                unitOfWork.registerDirty(
                    new Opportunity(
                        Id = eachOpportunityToBeUpdated.Id,
                        StageName = CLOSED_WON,
                        Is_Updated_By_Onboarding_Inputs__c = true
                    )
                );
            }
        }
    }

    /**
     * @description It is used to retry Onboarding Inputs data creation
     * based on passed Interface Transaction Id.
     * @JIRA# LEM-15182
     * @param interfaceTransactionId - Interface_Transaction__c record Id
     */
    public void retry(String interfaceTransactionId) {
        retry(
            InterfaceTransactionSelector.newInstance()
                .selectById(new Set<Id>{ interfaceTransactionId })
        );
    }

    /**
     * @description It is used to retry Onboarding Inputs data creation
     * based on passed Interface Transaction records.
     * @JIRA# LEM-15182
     * @param interfaceTransactionsForRetry - Interface_Transaction__c records for retry.
     */
    public void retry(List<Interface_Transaction__c> interfaceTransactionsForRetry) {
        if (interfaceTransactionsForRetry.isEmpty()) {
            return;
        }
        Set<Id> mxOnboardingLinkIds = new Set<Id>();
        for (Interface_Transaction__c eachTransaction : interfaceTransactionsForRetry) {
            mxOnboardingLinkIds.add((Id) eachTransaction.Payload__c);
        }
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_OI_DATA_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    mxOnboardingLinkIds,
                    5
                )
            }
        );
    }

    /**
     * @description Wrapper Class to store Picklist Information.
     */
    public class MyPickListInfo {
        public String validFor;
    }

    /**
     * @description Wrapper Class to store Accessibility details.
     */
    private class Accessibilities {
        Boolean needToClimb;
        Boolean hasElevatorsOrRamps;
        Accessibilities() {
            needToClimb = false;
            hasElevatorsOrRamps = false;
        }
    }

    /**
     * @description It is used to set Contact Info Wrapper.
     * @JIRA# LEM-18245
     * @param firstName
     * @param lastName
     * @param email
     * @param phone
     * @param role
     * @param ssnValue
     * @param dateOfBirth
     * @param mobilePhone
     * @param contactAddress
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private void setContactInfoWrapper(
        String firstName,
        String lastName,
        String email,
        String phone,
        String role,
        String ssnValue,
        Date dateOfBirth,
        String mobilePhone,
        ContactDto.Address contactAddress
    ) {
        String key = email + SEPARATOR + firstName + SEPARATOR + lastName;
        ContactDto.contactInfo contactInfo = contactIdentifierToContactInfo.containsKey(key)
            ? contactIdentifierToContactInfo.get(key)
            : new ContactDto.contactInfo();
        contactInfo.firstName = firstName;
        contactInfo.lastName = lastName;
        contactInfo.email = email;
        contactInfo.phone = isNullOrBlank(contactInfo.phone) ? phone : contactInfo.phone;
        contactInfo.ssn = isNullOrBlank(contactInfo.ssn) ? ssnValue : contactInfo.ssn;
        contactInfo.dateOfBirth = isNullOrBlank(contactInfo.dateOfBirth)
            ? dateOfBirth
            : contactInfo.dateOfBirth;
        contactInfo.mobilePhone = isNullOrBlank(contactInfo.mobilePhone)
            ? mobilePhone
            : contactInfo.mobilePhone;
        contactInfo.address = isNullOrBlank(contactInfo.address)
            ? contactAddress
            : contactInfo.address;
        contactInfo.source = SOURCE_ONBOARDING_INPUTS;
        if (
            contactIdentifierToContactInfo.containsKey(key) &&
            !contactIdentifierToRoles.get(key).contains(role)
        ) {
            String existingRoles = contactIdentifierToRoles.get(key);
            contactIdentifierToRoles.put(key, existingRoles + SEMI_COLON_SEPARATOR + role);
            return;
        }
        if (contactIdentifierToContactInfo.containsKey(key)) {
            return;
        }
        contactIdentifierToContactInfo.put(key, contactInfo);
        contactIdentifierToRoles.put(key, role);
    }

    /**
     * @description It is used to create Contacts and Account Contact Relations.
     * @JIRA# LEM-18245
     * @param mxOnboardingLink
     */
    private void createContactsAndAccountContactRelations(Mx_Onboarding_Link__c mxOnboardingLink) {
        //For Business Account.
        for (String contactIdentifierKey : contactIdentifierToRoles.keySet()) {
            String eligibleRoles = getEligibleRoles(
                contactIdentifierToRoles.get(contactIdentifierKey)
            );
            contactIdentifierToContactInfo.get(contactIdentifierKey)
                .accountIdToRoles = new Map<String, String>{
                mxOnboardingLink.Business_Account__c => eligibleRoles
            };
        }
        //For Store Account.
        createAccountContactRelationsForStore(mxOnboardingLink);
        List<String> contactInfos = serializeContactInfoWrapper();
        ContactAndAcrCreateService.processContactsPayloadSync(contactInfos);
    }

    /**
     * @description It is used to create Account Contact Relation for Store Accounts.
     * @JIRA# LEM-18245
     * @param mxOnboardingLink
     */
    private void createAccountContactRelationsForStore(Mx_Onboarding_Link__c mxOnboardingLink) {
        List<Account> accountsCreated = AccountsSelector.newInstance()
            .selectAccountsByMxOnboardingLinkIds(new Set<String>{ mxOnboardingLink.UUID__c });
        for (String contactIdentifierKey : contactIdentifierToRoles.keySet()) {
            for (Account eachAccount : accountsCreated) {
                if (eachAccount.RecordTypeId != STORE_ACCOUNT_RECORD_TYPE) {
                    continue;
                }
                String rolesToBeAdded = '';
                if (
                    contactIdentifierToRoles.get(contactIdentifierKey)
                        .contains(ROLE_PHOTOSHOOT_CONTACT)
                ) {
                    rolesToBeAdded += ROLE_PHOTOSHOOT_CONTACT + SEMI_COLON_SEPARATOR;
                }
                if (!String.isBlank(rolesToBeAdded)) {
                    rolesToBeAdded = rolesToBeAdded.removeEnd(SEMI_COLON_SEPARATOR);
                    contactIdentifierToContactInfo.get(contactIdentifierKey)
                        .accountIdToRoles.put(eachAccount.Id, rolesToBeAdded);
                }
            }
        }
        createAccountContactRelationsForDecisonMaker(accountsCreated);
    }

    /**
     * @description It is used to create Account Contact Relation for Store Account.
     * @JIRA# LEM-18245
     * @param accountsCreated
     */
    private void createAccountContactRelationsForDecisonMaker(List<Account> accountsCreated) {
        String existingRoles;
        Map<string, String> accountIdToRoles;
        for (Account eachAccount : accountsCreated) {
            if (
                eachAccount.RecordTypeId != STORE_ACCOUNT_RECORD_TYPE ||
                !storeIdToDecisionMakerContacts.containsKey(eachAccount.Store_Details__c)
            ) {
                continue;
            }
            accountIdToRoles = storeIdToDecisionMakerContacts.get(eachAccount.Store_Details__c)
                ?.accountIdToRoles;
            existingRoles = '';
            if (accountIdToRoles.containsKey(eachAccount.Id)) {
                existingRoles = accountIdToRoles.get(eachAccount.Id);
            }
            existingRoles += SEMI_COLON_SEPARATOR + ROLE_DECISION_MAKER;
            accountIdToRoles.put(eachAccount.Id, existingRoles);
        }
    }

    /**
     * @description It is used to get only non representative roles from passed string of roles.
     * @JIRA# LEM-18245
     * @param roles
     * @return String
     */
    private String getEligibleRoles(String roles) {
        String eligibleRoles = '';
        for (String role : roles.split(SEMI_COLON_SEPARATOR)) {
            if (
                role != ROLE_REPRESENTATIVE &&
                role != ROLE_PHOTOSHOOT_CONTACT &&
                role != ROLE_DECISION_MAKER
            ) {
                //Check added for DM contact to be created for Business Account, remove the extra text added in the role
                if (role.contains(DM_ROLE_BUSINESSACCOUNT_PLACEHOLDER)) {
                    role = role.replace(DM_ROLE_BUSINESSACCOUNT_PLACEHOLDER, EMPTY_STRING);
                }
                eligibleRoles += role + SEMI_COLON_SEPARATOR;
            }
        }
        return String.isBlank(eligibleRoles)
            ? eligibleRoles
            : eligibleRoles.removeEnd(SEMI_COLON_SEPARATOR);
    }

    /**
     * @description It is used to serialize contact Info Wrapper.
     * @JIRA# LEM-18245
     * @return List<String>
     */
    private List<String> serializeContactInfoWrapper() {
        List<String> contactInfos = new List<String>();
        for (String contactIdentifierKey : contactIdentifierToContactInfo.keySet()) {
            contactInfos.add(
                JSON.serialize(contactIdentifierToContactInfo.get(contactIdentifierKey))
            );
        }
        return contactInfos;
    }

    /**
     * @description It is used to set Address Wrapper.
     * @JIRA# LEM-18245
     * @param countryCode
     * @param street
     * @param city
     * @param stateCode
     * @param zipCode
     * @return ContactDto.Address
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private ContactDto.Address setAddressWrapper(
        String countryCode,
        String street,
        String city,
        String stateCode,
        String zipCode
    ) {
        ContactDto.Address contactAddress = new ContactDto.Address();
        contactAddress.country = countryCode;
        contactAddress.street = street;
        contactAddress.city = city;
        contactAddress.state = stateCode;
        contactAddress.postalCode = zipCode;
        return contactAddress;
    }

    /**
     * @description It fetches the Opportunity based on Onboarding Scenario.
     * @JIRA# LEM-24785
     * @param contractId
     * @param accountId
     * @param onboardingScenario
     * @return String
     */
    public String fetchOpportunityBasedOnOnboardingScenario(
        String contractId,
        String accountId,
        String onboardingScenario
    ) {
        String opportunityId;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectById(new Set<Id>{ contractId });

        switch on ONBOARDINGSCENARIOSMAPPINGS.get(onboardingScenario) {
            when PRODUCT_ADDITION {
                opportunityId = contracts[0].SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c;
            }
            when NEW_STORE_EXPANSION {
                if (accountId != null) {
                    List<Opportunity> opportunities = OpportunitiesSelector.newInstance()
                        .selectBySubTypeAndAccount(new Set<Id>{ accountId });
                    if (!opportunities.isEmpty()) {
                        opportunityId = opportunities[0].Id;
                    } else {
                        opportunityId = contracts[0].SBQQ__Opportunity__c;
                    }
                }
            }
        }
        return opportunityId;
    }
}