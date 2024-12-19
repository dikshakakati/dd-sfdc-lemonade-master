/**
 * @author atg
 * @date 05/23/2022
 * @description Selector Class for Agreement__c Object
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class AgreementsSelector extends fflib_SObjectSelector implements IAgreementsSelector {
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = 'COUNT(Id) agreementsCount, Contract__r.AccountId corporateAccountId';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_STATUS_PENDING = 'Pending';
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String AGREEMENT_TYPE_STORE_AGREEMENT = 'Store Agreement';
    private static final String AGREEMENT_TYPE_BUSINESS_AGREEMENT = 'Business Agreement';
    private static final String QUERY_FILTER_CONDITION_AGREEMENT_STATUS_TYPE_AND_CONTRACT_ID = 'Status__c = :AGREEMENT_STATUS_ACTIVE AND Type__c = :AGREEMENT_TYPE_FRANCHISE_AGREEMENT AND Contract__c IN: contractIds';
    private static final String CONTRACT_ACCOUNTID_FIELD = 'Contract__r.AccountId';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String ORDER_BY_CLAUSE = ' ORDER BY ';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String QUERY_FILTER_CONDITION_STATUS_AND_TYPE = 'Status__c = :AGREEMENT_STATUS_ACTIVE AND Type__c = :AGREEMENT_TYPE_FRANCHISE_AGREEMENT AND Account__r.Payment_Method__c != :PAYMENT_METHOD_WITHHOLDING AND Contract__r.AccountId IN: corporateAccountIds';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' FROM Agreement__c WHERE ';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final String QUERY_FILTER_CONDITION_CONTRACT_AND_TYPE = ' Contract__c IN ( SELECT Id FROM Contract where AccountId =: accountID ) and Type__c =: AGREEMENT_TYPE_STORE_AGREEMENT AND (Deactivation_Date__c = NULL OR (Deactivation_Date__c != NULL and Deactivation_Date__c > TODAY)) AND Status__c =:STATUS_ACTIVE ';
    private static final String CONTRACT = 'Contract__c';
    private static final String AGGREGATE_STORE_COUNT_QUERY_FIELDS = 'COUNT(Id) agreementsCount,Contract__c';
    private static final String CORE_CONTRACT = 'Core';
    private static final String ADS_PROMOS_CONTRACT = 'A&P';
    private static final String STORE = 'Store';
    private static final String SEGMENT_SMB = 'SMB';

    /**
     * @description Default Constructor for the Agreements Selector Class
     * @return IAgreementsSelector - Interface of Agreements
     */
    public static IAgreementsSelector newInstance() {
        return (IAgreementsSelector) Application.Selector.newInstance(Agreement__c.SObjectType);
    }

    /**
     * @description This method is used for getting the fields on Agreement__c object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Agreement__c.Id,
            Agreement__c.Account__c,
            Agreement__c.Contract__c,
            Agreement__c.Activation_Order_Created__c,
            Agreement__c.Name,
            Agreement__c.Status__c,
            Agreement__c.Type__c,
            Agreement__c.Deactivation_Date__c,
            Agreement__c.Start_Date__c,
            Agreement__c.Agreed_To_Services__c,
            Agreement__c.Group__c,
            Agreement__c.Serialized_Entitlements_Data__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Agreement__c.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectById(Set<Id> idSet) {
        return (List<Agreement__c>) Database.query(
            newQueryFactory()
                .selectField('Account__r.Franchise_Parent__c')
                .selectField('Contract__r.Franchise_Enrollment_Process__c')
                .selectField(
                    'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Use_Corporate_Cherry_Picking__c'
                )
                .setCondition('Id IN :idSet')
                .toSoql()
        );
    }

    /**
     * @description This method is used to fetch the Agreements with Parent Account Id
     * @param parentAccountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectAgreementsByParentAccounts(Set<Id> parentAccountIds) {
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Account__c IN :parentAccountIds AND Status__c = :AGREEMENT_STATUS_ACTIVE AND Type__c = :AGREEMENT_TYPE_FRANCHISE_AGREEMENT'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Agreements with Account Id
     * @param accountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectAgreementsByAccounts(Set<Id> accountIds) {
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Contract__c');
        query.selectField('Contract__r.Account.Total_Number_Of_Stores__c');
        query.selectField('Contract__r.AccountId');
        query.selectField('Contract__r.Business_Account_Name__c');
        query.selectField('Contract__r.CurrencyIsoCode');
        query.selectField('Contract__r.Nintex_Use_Case__c');
        query.selectField('Contract__r.Contract_Split_Category__c');
        query.selectField('Contract__r.Account.Segment__c');
        query.selectField('Status__c');
        query.setCondition('Account__c IN :accountIds');
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used to fetch the Store Agreements with Account Id
     * @param accountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectStoreAgreementsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account__r.Marketplace_Nintex_Id__c');
        query.selectField('Account__r.Rate_Change_Request__c');
        query.selectField('Group__c');
        query.setCondition(
            'Account__c IN :accountIds AND Status__c = :AGREEMENT_STATUS_ACTIVE AND Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used to fetch the Store Agreements by Contract Id that are not deaactivated
     * @param contractIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAgreementsByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField(
            'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Use_Corporate_Cherry_Picking__c'
        );
        query.selectField('Account__r.Franchise_Parent__c');
        query.selectField('Account__r.Marketplace_Nintex_Id__c');
        query.selectField('Serialized_Entitlements_Data__c');
        query.selectField('Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Segment__c');
        query.selectField('Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Type__c');
        query.selectField('Contract__r.Contract_Split_Category__c');
        query.selectField('Contract__r.Franchise_Enrollment_Process__c');
        query.selectField('Contract__r.Integration_Source__c');
        query.setCondition(
            'Contract__c IN :contractIds AND ((Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT) OR (Type__c = :AGREEMENT_TYPE_BUSINESS_AGREEMENT)) AND ((Deactivation_Date__c = null) OR (Deactivation_Date__c >= TODAY))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used to fetch the Opportunity information for the Store Agreements by Id
     * @param idSet
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectOpportunityInfoByIds(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Opportunity__c');
        query.selectField('Opportunity__r.Deselected_Marketplace_Offerings__c');
        query.selectField('Opportunity__r.Packages_with_Products__c');
        query.setCondition('Id IN :idSet');
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements by Contract Id that are not deaactivated
     * @param storeMarketPlaceNinxtexIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectAgreementsByMarketplaceNintexIds(
        Set<String> storeMarketPlaceNinxtexIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account__r.Franchise_Parent__c');
        query.selectField('Account__r.Marketplace_Nintex_Id__c');
        query.selectField('Account__r.Change_of_Ownership_Effective_Date__c');
        query.setCondition(
            'Account__r.Marketplace_Nintex_Id__c IN :storeMarketPlaceNinxtexIds AND ((Deactivation_Date__c = null) OR (Deactivation_Date__c >= TODAY))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements by Contract Id that are associated to a Account
     * @param contractIds
     * @param accountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectAgreementsByContractAndAccount(
        Set<Id> contractIds,
        Set<Id> accountIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Contract__c IN :contractIds AND Account__c IN :accountIds  AND Status__c = :AGREEMENT_STATUS_ACTIVE AND ((Deactivation_Date__c = null) OR (Deactivation_Date__c >= TODAY))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying count of Franchise Accounts not having Payment Method
     * as 'Withholding' associated with 'Active' Agreement using the passed Corporate Account Ids.
     * @JIRA# LEM-9497
     * @param corporateAccountIds
     * @return Aggregate[]
     */
    public Aggregate[] selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
        Set<Id> corporateAccountIds
    ) {
        String agreementQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            QUERY_FILTER_CONDITION_STATUS_AND_TYPE +
            GROUP_BY_CLAUSE +
            CONTRACT_ACCOUNTID_FIELD +
            ORDER_BY_CLAUSE +
            CONTRACT_ACCOUNTID_FIELD;
        AggregateResult[] agreementAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(agreementQuery)
        );
        return Aggregate.convertResults(agreementAggregateCountQueryResult);
    }

    /**
     * @description It is used for querying 'Active' Franchise Agreements with Franchise Accounts
     * not having Payment Method as 'Withholding' using the passed Corporate Account Ids.
     * @JIRA# LEM-9497
     * @param corporateAccountIds
     * @param queryLimit
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectNonWithholdingFranchiseAccountsByActiveAgreements(
        Set<Id> corporateAccountIds,
        Integer queryLimit
    ) {
        fflib_QueryFactory agreementQuery = newQueryFactory()
            .setCondition(QUERY_FILTER_CONDITION_STATUS_AND_TYPE)
            .setLimit(queryLimit);
        return (List<Agreement__c>) Database.query(agreementQuery.toSOQL());
    }

    /**
     * @description It is used for querying 'Active' Withholding Franchise Agreements with Contracts
     * having Payment Method as 'Withholding' using the passed Corporate Account Ids.
     * @JIRA# LEM-9551, LEM-10499
     * @param corporateAccountIds
     * @param queryLimit
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectWithholdingCorporateAccountsByActiveAgreements(
        Set<Id> corporateAccountIds,
        Integer queryLimit
    ) {
        fflib_QueryFactory agreementQuery = newQueryFactory()
            .selectField('Contract__r.AccountId')
            .setCondition(
                'Status__c = :AGREEMENT_STATUS_ACTIVE' +
                    ' AND Type__c = :AGREEMENT_TYPE_FRANCHISE_AGREEMENT' +
                    ' AND Account__r.Payment_Method__c = :PAYMENT_METHOD_WITHHOLDING' +
                    ' AND Contract__r.Payment_Method__c = :PAYMENT_METHOD_WITHHOLDING' +
                    ' AND Contract__r.AccountId IN: corporateAccountIds'
            )
            .setLimit(queryLimit);
        return (List<Agreement__c>) Database.query(agreementQuery.toSOQL());
    }

    /**
     * @description It is used for querying 'Active' Franchise Agreements
     * using the passed Contract Ids.
     * @JIRA# LEM-11052
     * @param contractIds
     * @param queryLimit
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveFranchiseAgreementsByContractIds(
        Set<Id> contractIds,
        Integer queryLimit
    ) {
        fflib_QueryFactory agreementQuery = newQueryFactory()
            .setCondition(QUERY_FILTER_CONDITION_AGREEMENT_STATUS_TYPE_AND_CONTRACT_ID)
            .setLimit(queryLimit);
        return (List<Agreement__c>) Database.query(agreementQuery.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements with RCR Id
     * @param rcrIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectStoreAgreementsByRcrIds(Set<Id> rcrIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account__r.Rate_Change_Request__c');
        query.selectField('Group__c');
        query.setCondition(
            'Account__r.Rate_Change_Request__c IN :rcrIds AND Status__c = :AGREEMENT_STATUS_ACTIVE AND Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements by Account Id that are not deactivated
     * @param accountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAgreementsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account__r.Franchise_Parent__c');
        query.selectField('Account__r.Marketplace_Nintex_Id__c');
        query.selectField('Serialized_Entitlements_Data__c');
        query.selectField(
            'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner_Full_Name__c'
        );
        query.selectField(
            'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Email'
        );
        query.setCondition(
            'Account__c IN :accountIds AND ((Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT) OR (Type__c = :AGREEMENT_TYPE_BUSINESS_AGREEMENT)) AND ((Deactivation_Date__c = null) OR (Deactivation_Date__c >= TODAY))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements by Agreement Id that are not deactivated
     * @param agreementIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectStoreAgreementsByIds(Set<Id> agreementIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Contract__c');
        query.selectField('Contract__r.Franchise_Enrollment_Process__c');
        query.selectField(
            'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Use_Corporate_Cherry_Picking__c'
        );
        query.setCondition(
            'Id IN :agreementIds AND Status__c = :AGREEMENT_STATUS_ACTIVE AND ((Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT) OR (Type__c = :AGREEMENT_TYPE_BUSINESS_AGREEMENT))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements by account Id that are ACTIVE and CANCELLED
     * @param accountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAndCancelledAgreementsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account__r.Franchise_Parent__c');
        query.selectField('Account__r.Marketplace_Nintex_Id__c');
        query.selectField('Serialized_Entitlements_Data__c');
        query.selectField('Account__r.Id');
        query.selectField(
            'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner_Full_Name__c'
        );
        query.selectField(
            'Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Email'
        );
        query.setCondition(
            'Account__c IN :accountIds AND ((Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT) OR (Type__c = :AGREEMENT_TYPE_BUSINESS_AGREEMENT)) AND ((Status__c = :STATUS_ACTIVE) OR (Status__c = :STATUS_CANCELLED AND (Deactivation_Date__c = NULL OR Deactivation_Date__c <= TODAY)))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for querying count of stores
     * @JIRA# LEM-15403
     * @param accountID
     * @return Aggregate[]
     */
    public Aggregate[] selectCountOfStoresAccountsByStoreAgreements(Id accountID) {
        String agreementQuery =
            SELECT_CLAUSE +
            AGGREGATE_STORE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            QUERY_FILTER_CONDITION_CONTRACT_AND_TYPE +
            GROUP_BY_CLAUSE +
            CONTRACT;
        AggregateResult[] agreementAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(agreementQuery)
        );
        return Aggregate.convertResults(agreementAggregateCountQueryResult);
    }

    /**
     * @description This method is used to fetch the Store Agreements by Account Id and Contract Id that are not deactivated
     * @param accountIds
     * @param contractId
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAgreementsByAccountContractIds(
        Set<Id> accountIds,
        Id contractId
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Account__c IN :accountIds AND Contract__c = :contractId AND ((Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT) OR (Type__c = :AGREEMENT_TYPE_BUSINESS_AGREEMENT)) AND Status__c = :AGREEMENT_STATUS_ACTIVE AND ((Deactivation_Date__c = null) OR (Deactivation_Date__c >= TODAY))'
        );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used to fetch the Store Agreements by Core Contract Id.
     * @param contractIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAgreementsByCoreContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Id')
            .selectField('Account__c')
            .selectField('Account__r.ParentId')
            .selectField('Contract__r.Contract_Split_Category__c')
            .setCondition(
                'Contract__c IN :contractIds AND Contract__r.Contract_Split_Category__c = :CORE_CONTRACT'
            );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements by Ads and Promos Contract Ids.
     * @param contractIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAgreementsByAdsPromosContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Id')
            .selectField('Account__c')
            .selectField('Account__r.ParentId')
            .selectField('Contract__r.Contract_Split_Category__c')
            .setCondition(
                'Contract__c IN :contractIds AND Contract__r.Contract_Split_Category__c = :ADS_PROMOS_CONTRACT'
            );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to fetch the Agreements by Account Ids.
     * @param accountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectAgreementsByAccountsIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false);
        query.selectField('Account__c');
        query.selectField('Contract__c');
        query.selectField('Contract__r.AccountId');
        query.setCondition('Account__c IN :accountIds');
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to fetch the Active Store Agreements based on Contract Ids.
     * @param contractIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveStoreAgreementsByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Contract__c IN :contractIds AND Status__c = :AGREEMENT_STATUS_ACTIVE AND Type__c = :AGREEMENT_TYPE_STORE_AGREEMENT'
            );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to fetch the Store Agreements of type Core by store account Ids for SMB.
     * @param storeAccountIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectActiveAgreementsAndCoreContractsByStoreAccountIds(
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Id')
            .selectField('Account__c')
            .selectField('Contract__c')
            .selectField('Contract__r.ContractNumber')
            .SelectField('Contract__r.Is_This_Ads_Or_Promo__c')
            .SelectField('Contract_Name__c')
            .setCondition(
                'Account__c IN :storeAccountIds AND Contract__r.Contract_Split_Category__c = :CORE_CONTRACT ' +
                'AND Account__r.Record_Type_Name__c = :STORE AND Account__r.Segment__c =: SEGMENT_SMB'
            );
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to fetch the Agreements by the passed churned merchant
     * contract ids.
     * @JIRA #LEM-23780
     * @param contractIds
     * @return List<Agreement__c>
     */
    public List<Agreement__c> selectChurnedMxAgreementsByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Account__c')
            .setCondition('Contract__c IN :contractIds');
        return (List<Agreement__c>) Database.query(query.toSOQL());
    }
}