/**
 * @author atg
 * @date 05/09/2022
 * @description Selector Class for Contract Object
 */
public inherited sharing class ContractsSelector extends fflib_SObjectSelector implements IContractsSelector {
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final Boolean BUNDLE_LINE = true;
    private static final String PACKAGE_LINE = null;
    private static final String MX_ONBOARDING_LINK_STATUS_ACTIVE = 'Active';
    private static final String MX_ONBOARDING_INACTIVE_REASON_BLANK = '';
    private static final String CONTRACT_SPLIT_CATEGORY = 'A&P';
    private static final String CONTRACT_SPLIT_CATEGORY_CORE = 'Core';
    private static final String CONTRACT_SPLIT_CATEGORY_A_AND_P = 'A&P';
    private static final String BRAND_ASSOCIATION_ACTIVE = 'Active';
    private static final String CONTRACT_SPLIT_CATEGORY_MIDDLEWARE_PROVIDER = 'Middleware Provider';
    private static final List<String> ADS_PROMO_PRODUCT_FAMILY_SET = new List<String>{
        'Advertisement',
        'Marketplace Promotion',
        'Drive Promotion'
    };
    private static final List<String> CONTRACT_SPLIT_CATEGORIES = new List<String>{ 'A&P', 'Core' };
    private static final List<String> CONTRACT_SPLIT_CATEGORIES_NOT_RESTRICTED = new List<String>{
        'Middleware Provider',
        'Churned Merchant'
    };
    private static final String CHURNED_MERCHANT = 'Churned Merchant';
    private static final Schema.Fieldset OI_SECTION_BUSINESS_ACCOUNT_FIELDSET = SObjectType.Contract.FieldSets.OI_Section_Business_Account_Fields;
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String NINTEXUSECASE_MIDDLEWAREPRODIVDED = 'Middleware Provider';
    private static final String ACCOUNTSEGEMENT_SMB = 'SMB';
    private static final String MX_ONBOARDING_LINK_STATUS_INACTIVE = 'Inactive';
    private static final String MX_ONBOARDING_SOURCE_RESSMO = 'RESSMO';
    private static final String MX_ONBOARDING_LINK_RECORD_CREATION_SUCCESS = 'Success';
    private static final String MX_ONBOARDING_LINK_RECORD_CREATION_BLANK = '';

    /**
     * @description default constructor for the Contracts Selector class
     * @return IContractsSelector - interface of IContractsSelector
     */
    public static IContractsSelector newInstance() {
        return (IContractsSelector) Application.Selector.newInstance(Contract.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Contract object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contract.Id,
            Contract.Name,
            Contract.Associated_Account_Ids__c,
            Contract.CurrencyIsoCode,
            Contract.SBQQ__Opportunity__c,
            Contract.SBQQ__Order__c,
            Contract.AccountId,
            Contract.MP_Bz_Id__c,
            Contract.Payment_Method__c,
            Contract.Is_This_Ads_Or_Promo__c,
            Contract.SBQQ__Quote__c,
            Contract.Contract_Split_Category__c,
            Contract.Integration_Source__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contract.SObjectType;
    }

    /**
     * @description This method is used for getting object list based on Id
     * @param idSet
     * @return List<Contract>
     */
    public List<Contract> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: idSet');
        query.selectField('Contract_Split_Category__c');
        query.selectField('Pricing_Variation_Type__c');
        query.selectField('SBQQ__Order__r.Id');
        query.selectField('SBQQ__Order__r.SBQQ__PriceCalcStatus__c');
        query.selectField('SBQQ__Order__r.EffectiveDate');
        query.selectField('SBQQ__Order__r.Type');
        query.selectField('SBQQ__Order__r.OwnerId');
        query.selectField('SBQQ__Order__r.SBQQ__PaymentTerm__c');
        query.selectField('SBQQ__Order__r.Pricebook2Id');
        query.selectField('SBQQ__Order__r.Unique_Identifier__c');
        query.selectField('Account.Id');
        query.selectField('Account.Segment__c');
        query.selectField('Account.BillingCountry');
        query.selectField('Account.BillingCountryCode');
        query.selectField('Account.ShippingCountry');
        query.selectField('Account.ShippingCountryCode');
        query.selectField('Account.Record_Type_Name__c');
        query.selectField('Associated_Account_Ids__c');
        query.selectField('SBQQ__Quote__c');
        query.selectField('Account.OwnerId');
        query.selectField('Contract_Name__c');
        query.selectField('Contract_Type__c');
        query.SelectField('SBQQ__Opportunity__r.Agency__c');
        query.selectField('SBQQ__Order__c');
        query.selectField('Franchise_Supplemental_Agreement_URL__c');
        query.selectField('Master_Supplemental_Agreement_URL__c');
        query.selectField('SBQQ__Order__r.SBQQ__Quote__c');
        query.selectField('SBQQ__Order__r.SBQQ__Quote__r.Franchise_Supplemental_Agreement_Link__c');
        query.selectField('SBQQ__Order__r.SBQQ__Quote__r.Signed_Contract_link__c');
        query.selectField('SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c');
        query.selectField('SBQQ__Opportunity__c');
        query.selectField('Number_Of_Stores_Count__c');
        query.selectField('RESSMO_Store_Account_id__c');
        query.selectField('AccountId');
        query.selectField('Payment_Method__c');
        query.selectField('SBQQ__Evergreen__c');
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Contracts based on AccountId
     * @param parentAccountIds
     * @return List<Contract>
     */
    public List<Contract> selectByParentAccountId(Set<Id> parentAccountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account.ParentId');
        query.selectField('Integration_Source__c');
        query.selectField('Account.Is_Lead_Converted_To_Existing_Account__c');
        query.setCondition('AccountId IN :parentAccountIds AND Status = :STATUS_ACTIVATED');
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Contracts by Parent Account Ids.
     * @JIRA# LEM-23361
     * @param parentAccountIds
     * @return List<Contract>
     */
    public List<Contract> selectContractSplitCategoryByParentAccountIds(Set<Id> parentAccountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account.ParentId');
        query.selectField('Account.Is_Lead_Converted_To_Existing_Account__c');
        query.setCondition(
            'AccountId IN :parentAccountIds AND Contract_Split_Category__c IN :CONTRACT_SPLIT_CATEGORIES_NOT_RESTRICTED'
        );
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Contracts with Ads and Promo Subscriptions
     * @param contractIds
     * @return List<Contract>
     */
    public List<Contract> selectContractsWithAdsAndPromoSubscriptions(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Contract_Name__c');
        query.setCondition('Id IN: contractIds');
        SubscriptionSelector subSelector = new SubscriptionSelector();
        subSelector.addQueryFactorySubselect(query, 'SBQQ__Subscriptions__r')
            .selectField('SBQQ__Product__r.Family')
            .setCondition('SBQQ__Product__r.Family IN: ADS_PROMO_PRODUCT_FAMILY_SET ');
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying 'Activated' Contracts having Payment Method
     * as 'Withholding' using the passed accountIds.
     * @JIRA# LEM-9551
     * @param accountIds
     * @return List<Contract>
     */
    public List<Contract> selectActivatedWithholdingContractsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory contractQuery = newQueryFactory()
            .setCondition(
                'Status = :STATUS_ACTIVATED' +
                    ' AND Payment_Method__c = :PAYMENT_METHOD_WITHHOLDING' +
                    ' AND AccountId IN :accountIds'
            )
            .addOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Contract>) Database.query(contractQuery.toSOQL());
    }

    /**
     * @description This method used for querying Contracts by opportunityId.
     * @param opportunityId
     * @return List<Contract>
     */
    public List<Contract> selectContractsByOpportunityId(Id opportunityId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('SBQQ__Opportunity__c =:opportunityId');
        return (List<Contract>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for querying Contracts by account Id filtered with dynamic fields.
     * @param fieldsToQuery
     * @param parentAccountId
     * @return List<Contract>
     */
    public List<Contract> selectContractsWithDynamicFields(
        Set<String> fieldsToQuery,
        Id parentAccountId
    ) {
        fflib_QueryFactory contractQuery = newQueryFactory();
        contractQuery.selectFields(fieldsToQuery);
        contractQuery.selectField('Is_This_Ads_Or_Promo__c');
        contractQuery.setCondition(
            '(AccountId =:parentAccountId AND Status = :STATUS_ACTIVATED AND ' +
                '(Account.Segment__c != :ACCOUNTSEGEMENT_SMB OR ' +
                '(Account.Segment__c = :ACCOUNTSEGEMENT_SMB AND ' +
                'Contract_Split_Category__c IN :CONTRACT_SPLIT_CATEGORIES AND ' +
                'Nintex_Use_Case__c != :NINTEXUSECASE_MIDDLEWAREPRODIVDED)))'
        );
        contractQuery.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract>) Database.query(contractQuery.toSOQL());
    }

    /**
     * @description This method is used for getting Contracts with Subscriptions
     * @JIRA# LEM-15116
     * @param contractIds
     * @return List<Contract>
     */
    public List<Contract> selectContractsWithSubscriptions(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectFieldSet(OI_SECTION_BUSINESS_ACCOUNT_FIELDSET)
            .selectField('Account.BillingState')
            .selectField('Account.Order_Protocol__c')
            .selectField('Payment_Method__c')
            .selectField('SBQQ__Opportunity__c')
            .setCondition('Id IN: contractIds');
        SubscriptionSelector subSelector = new SubscriptionSelector();
        subSelector.addQueryFactorySubselect(query, 'SBQQ__Subscriptions__r')
            .selectField('Package__c')
            .selectField('SBQQ__Product__c')
            .selectField('Is_It_A_New_Product__c')
            .selectField('SBQQ__OriginalQuoteLine__c')
            .selectField('SBQQ__Product__r.Alcohol_Product__c');
        new BrandAssociationsSelector()
            .addQueryFactorySubselect(query, 'Contract_Brand_Associations__r', false)
            .selectField('Brand__c')
            .selectField('Brand_Name__c');
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Contracts by account Id and Split Category.
     * @JIRA# LEM-16431
     * @param accountIds
     * @return List<Contract>
     */
    public List<Contract> selectCoreContractsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory contractQuery = newQueryFactory(true)
            .selectField('Id')
            .selectField('Contract_Split_Category__c')
            .selectField('AccountId')
            .setCondition(
                'Contract_Split_Category__c =: CONTRACT_SPLIT_CATEGORY_CORE' +
                ' AND AccountId IN :accountIds'
            );
        return (List<Contract>) Database.query(contractQuery.toSOQL());
    }

    /**
     * @description It is used to get Ads and Promo Contracts by Account Ids.
     * @param accountIds
     * @return List<Contract>
     */
    public List<Contract> selectAdsAndPromosContractsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory contractQuery = newQueryFactory(true)
            .selectField('Contract_Split_Category__c')
            .selectField('SBQQ__Quote__c')
            .selectField('Integration_Source__c')
            .selectField('AccountId')
            .setCondition(
                'Contract_Split_Category__c = :CONTRACT_SPLIT_CATEGORY_A_AND_P' +
                ' AND AccountId IN :accountIds AND Status = :STATUS_ACTIVATED'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract>) Database.query(contractQuery.toSOQL());
    }
    /**
     * @description It is used for querying quoteIds by quote Ids and Split Category.
     * @JIRA# LEM-16431
     * @param quoteIds
     * @return List<Contract>
     */
    public List<Contract> selectAdsAndPromosContractsByQuoteIds(Set<Id> quoteIds) {
        fflib_QueryFactory contractQuery = newQueryFactory(true)
            .selectField('Id')
            .selectField('Contract_Split_Category__c')
            .selectField('SBQQ__Quote__c')
            .selectField('AccountId')
            .setCondition(
                'SBQQ__Quote__c IN :quoteIds AND Contract_Split_Category__c =: CONTRACT_SPLIT_CATEGORY'
            );
        return (List<Contract>) Database.query(contractQuery.toSOQL());
    }

    /**
     * @description Select contract account and Active subscription products
     * @author Pankaj | 07-17-2024
     * @param contractIds
     * @return List<Contract>
     **/
    public List<Contract> selectContractsWithActiveSubscriptionsProducts(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SSMO_Validation__c');
        query.selectField('RESSMO_Store_Account_Id__c');
        query.selectField('Contract_Name__c');
        query.selectField('Account.Segment__c');
        query.selectField('Account.Primary_Vertical__c');
        query.selectField('RESSMO_Eligible__c');
        query.setCondition('Id IN: contractIds');
        SubscriptionSelector subSelector = new SubscriptionSelector();
        subSelector.addQueryFactorySubselect(query, 'SBQQ__Subscriptions__r')
            .selectField('SBQQ__Product__r.Name')
            .selectField('SBQQ__Product__r.ProductCode')
            .selectField('SBQQ__Product__r.SSMO_Eligible__c')
            .setCondition('SBQQ__TerminatedDate__c = NULL OR SBQQ__TerminatedDate__c > TODAY');
        MxOnboardingLinksSelector subMxSelector = new MxOnboardingLinksSelector();
        subMxSelector.addQueryFactorySubselect(query, 'Mx_Onboarding_Links__r')
            .selectField('Status__c')
            .selectField('One_Time_Mx_Link__c')
            .setCondition(
                'Status__c = :MX_ONBOARDING_LINK_STATUS_ACTIVE AND Source__c = :MX_ONBOARDING_SOURCE_RESSMO'
            )
            .setOrdering('createdDate', fflib_QueryFactory.SortOrder.DESCENDING);

        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description - select fields for RESSMO elligible check from contract
     * @author Soumya Dash | 07-18-2024
     * @param contractId
     * @return Contract
     **/
    public Contract selectByIdWithMxActiveOnboarding(Id contractId) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Contract_Name__c')
            .selectField('Account.Segment__c')
            .selectField('Account.Primary_Vertical__c')
            .selectField('SBQQ__Quote__r.RESSMO_Eligible__c')
            .selectField('SBQQ__Quote__c')
            .selectField('AccountId')
            .selectField('Payment_Method__c')
            .setCondition('Id = :contractId')
            .setLimit(1);

        SubscriptionSelector subSelector = new SubscriptionSelector();
        subSelector.addQueryFactorySubselect(query, 'SBQQ__Subscriptions__r')
            .selectField('SBQQ__Product__r.Name')
            .selectField('SBQQ__Product__r.ProductCode')
            .selectField('SBQQ__Product__r.SSMO_Eligible__c')
            .setCondition('SBQQ__TerminatedDate__c = NULL OR SBQQ__TerminatedDate__c > TODAY');

        MxOnboardingLinksSelector subMxSelector = new MxOnboardingLinksSelector();
        subMxSelector.addQueryFactorySubselect(query, 'Mx_Onboarding_Links__r')
            .selectField('Id')
            .selectField('Status__c')
            .setCondition(
                'Status__c = :MX_ONBOARDING_LINK_STATUS_ACTIVE AND Source__c = :MX_ONBOARDING_SOURCE_RESSMO AND Record_Creation_Status__c = :MX_ONBOARDING_LINK_RECORD_CREATION_BLANK'
            )
            .setOrdering('createdDate', fflib_QueryFactory.SortOrder.DESCENDING);

        return (Contract) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Contracts based on passed Contract Ids.
     * @JIRA# LEM-16431
     * @param contractIds
     * @return List<Contract>
     */
    public List<Contract> selectContractsWithSubscriptionsAddScenario(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFieldSet(OI_SECTION_BUSINESS_ACCOUNT_FIELDSET);
        query.selectField('Account.BillingState');
        query.selectField('Account.Order_Protocol__c');
        query.selectField('Payment_Method__c');
        query.setCondition('Id IN: contractIds');
        SubscriptionSelector subSelector = new SubscriptionSelector();
        subSelector.addQueryFactorySubselect(query, 'SBQQ__Subscriptions__r')
            .selectField('Package__c')
            .selectField('CreatedDate')
            .selectField('SBQQ__Product__c')
            .selectField('SBQQ__OriginalQuoteLine__c')
            .selectField('Is_It_A_New_Product__c')
            .selectField('SBQQ__Product__r.Alcohol_Product__c')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        new BrandAssociationsSelector()
            .addQueryFactorySubselect(query, 'Contract_Brand_Associations__r', false)
            .selectField('Brand__c')
            .selectField('Brand_Name__c');
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description
     * @jira LEM-17697
     * @param contractIds
     * @param sobjectToSetOfField
     * @return List<Contract>
     **/
    public List<Contract> selectContractsandRelatedRecords(
        Set<Id> contractIds,
        Map<String, Set<String>> sobjectToSetOfField
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(sobjectToSetOfField.get('Account'));
        query.selectFields(sobjectToSetOfField.get('SBQQ__Opportunity__r'));
        query.selectFields(sobjectToSetOfField.get('Contract'));
        query.selectFields(sobjectToSetOfField.get('Owner'));
        query.selectField('Account');
        query.selectField('Account.Id');
        query.selectField('Account.Brand__c');
        query.selectField('Account.Business_Vertical__c');
        query.selectField('Account.CurrencyIsoCode');
        query.selectField('Account.Business_Vertical__c');
        query.selectField('Account.Segment__c');
        query.selectField('Account.Primary_Vertical__c');
        query.selectField('Account.BillingCountry');
        query.selectField('SBQQ__Opportunity__c');
        query.selectField('SBQQ__Opportunity__r.Id');
        query.selectField('RESSMO_Store_Account_Id__c');
        query.selectField('SSMO_Validation__c');
        query.selectField('Pricing_Variation_Type__c');
        query.setCondition('Id IN: contractIds');
        query.setLimit(1);
        SubscriptionSelector subSelector = new SubscriptionSelector();
        subSelector.addQueryFactorySubselect(query, 'SBQQ__Subscriptions__r')
            .selectFields(sobjectToSetOfField.get('SBQQ__Subscription__c'))
            .selectField('SBQQ__Product__r.Name')
            .selectField('SBQQ__Product__r.SSMO_Eligible__c')
            .selectField('SBQQ__Product__r.ProductCode')
            .setCondition('SBQQ__TerminatedDate__c = NULL OR SBQQ__TerminatedDate__c > TODAY');
        MxOnboardingLinksSelector subMxSelector = new MxOnboardingLinksSelector();
        subMxSelector.addQueryFactorySubselect(query, 'Mx_Onboarding_Links__r')
            .selectField('Id')
            .selectField('Status__c')
            .selectField('Payload__c')
            .setCondition(
                'Status__c = :MX_ONBOARDING_LINK_STATUS_INACTIVE AND Source__c = :MX_ONBOARDING_SOURCE_RESSMO AND Inactive_Reason__c = :MX_ONBOARDING_INACTIVE_REASON_BLANK'
            )
            .setOrdering('createdDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description - select Contrat related fields and its mc onboarding records
     * @author Soumya Dash | 08-08-2024
     * @param contractId
     * @return Contract
     **/
    public Contract selectByIdWithRESSMOSourceMxOnboarding(Id contractId) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('SBQQ__Quote__c')
            .selectField('AccountId')
            .selectField('Account.Legal_Business_Name__c')
            .selectField('RESSMO_Store_Account_id__c')
            .selectField('SBQQ__Opportunity__c')
            .selectField('Payment_Method__c')
            .selectField('Number_of_Stores__c')
            .setCondition('Id = :contractId')
            .setLimit(1);

        new ContractBrandAssociationsSelector()
            .addQueryFactorySubselect(query, 'Contract_Brand_Associations__r')
            .selectField('Brand__r.Name')
            .setCondition('Status__c = :BRAND_ASSOCIATION_ACTIVE');

        MxOnboardingLinksSelector subMxSelector = new MxOnboardingLinksSelector();
        subMxSelector.addQueryFactorySubselect(query, 'Mx_Onboarding_Links__r')
            .selectField('Status__c')
            .selectField('Source__c')
            .selectField('Payload__c')
            .setCondition(
                'Status__c = :MX_ONBOARDING_LINK_STATUS_INACTIVE AND Source__c = :MX_ONBOARDING_SOURCE_RESSMO AND Inactive_Reason__c = :MX_ONBOARDING_INACTIVE_REASON_BLANK'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        return (Contract) Database.query(query.toSOQL());
    }

    /**
     * @description
     * @author SamikshaDD | 08-12-2024
     * @param contractIds
     * @param fieldSet
     * @return List<Contract>
     **/
    public List<Contract> selectContractByIdWithGivenFields(
        Set<Id> contractIds,
        Set<String> fieldSet
    ) {
        fflib_QueryFactory quoteQuery = newQueryFactory()
            .selectFields(fieldSet)
            .setCondition('Id IN :contractIds');
        MxOnboardingLinksSelector subMxSelector = new MxOnboardingLinksSelector();
        subMxSelector.addQueryFactorySubselect(quoteQuery, 'Mx_Onboarding_Links__r')
            .selectField('Id')
            .selectField('Status__c')
            .selectField('Expiration_Date_Time__c')
            .selectField('Inactive_Reason__c')
            .setCondition(
                'Status__c = :MX_ONBOARDING_LINK_STATUS_ACTIVE  AND Source__c = :MX_ONBOARDING_SOURCE_RESSMO AND Contract__c IN : contractIds'
            );

        return (List<Contract>) Database.query(quoteQuery.toSOQL());
    }

    /**
     * @description Select Contract based on the Contract Number
     * @param contractNumbers
     * @return List<Contract>
     **/
    public List<Contract> selectByContractNumber(Set<String> contractNumbers) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('ContractNumber')
            .selectField('Payment_Method__c')
            .setCondition('ContractNumber IN :contractNumbers');
        return (List<Contract>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to fetch the Contract where 'Contract Type' is "Churned Merchant".
     * @JIRA #LEM-23780
     * @return Database.QueryLocator
     **/
    public Database.QueryLocator selectChurnedMxContracts() {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('AccountId')
            .setCondition(
                'Contract_Split_Category__c = :CHURNED_MERCHANT' +
                    ' AND Account.Segment__c = :ACCOUNTSEGEMENT_SMB' +
                    ' AND Is_Churned_Mx_Contract_Processed__c = false'
            );
        return Database.getQueryLocator(query.toSOQL());
    }
}