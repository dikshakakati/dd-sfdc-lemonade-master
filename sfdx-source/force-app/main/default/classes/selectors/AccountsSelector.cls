/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Selector Class for Account Object
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ExcessiveClassLength,PMD.CyclomaticComplexity')
public inherited sharing class AccountsSelector extends fflib_SObjectSelector implements IAccountsSelector, IEncryptedDataSelector {
    static final String FRANCHISEE = 'Franchisee';
    static final String STORE = 'Store';
    static final String BUSINESS = 'Business';
    static final String IN_PURSUIT = 'In Pursuit';
    static final String NDA_STATUS_ACTIVE = 'Active';
    private static final String IS_SERVICE_ACTIVE = 'Yes';
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = ' Id, COUNT(ID) accountIdCount';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD = ' parentId';
    private static final String TOPMX = 'Top MX';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' Id IN :accountIdSet AND RecordtypeId = :BUSINESS_RECORD_TYPE_ID';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Activation_Order')
        .getRecordTypeId();
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement';
    private static final Set<String> ONBOARDING_DETAILS_ELIGIBILE_AGREEMENT_TYPES = new Set<String>{
        AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
        AGREEMENT_TYPE_STORE
    };
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String CONTRACT_SIGNATORY_ACCOUNT_CONTACT_RELATION_ROLE = 'Contract Signatory';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE = 'Decision Maker';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final Set<String> INELIGIBLE_WORK_ORDER_STATUSES = new Set<String>{
        'Dead',
        'Onboarding Complete'
    };
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_TYPE_NET_NEW = 'Net-New';
    private static final String STORES_ROW_LIMIT_ON_ADD_STORES_QUICK_ACTION_STATIC_CONFIG = 'Stores_RowLimit_On_AddStores_QuickAction';
    private static final String PAYMENT_RECORD_TYPE_NAME = 'Payments';
    private static final String VERIFIED_STATUS = 'Verified';
    private static final String XREF_EXTERNALID_SOURCE_DRIVE = 'DriveDb';
    @testvisible
    private static final String XREF_EXTERNALID_SOURCE_MDS = 'MDS';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String SERVICE_STATUS_ACTIVE = 'Active';
    @testvisible
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String CORPORATE = 'Corporate';
    private static final String COO_WORK_ORDER_TYPE = 'COO';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final List<String> STATUSES_TO_TRIGGER_PROVISIONING = new List<String>{
        'Ready for Provisioning',
        'Provisioning Failed'
    };
    private static final String WHERE_CLAUSE = ' FROM Account WHERE ';
    private static final String AGGREGATE_QUERY_ACCOUNT_FIELDS = 'ParentId parentId, COUNT(Id) countIds';
    private static final String AGGREGATE_QUERY_ELIGIBLE_ACCOUNTS_TO_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_FILTER_CONDITION = System.label.Parent_Account_Fields_Trickle_Down_Filter_Condition;
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_PARENTACCOUNTID = 'ParentId';
    private static final Set<String> ALCOHOL_PRODUCTS = new Set<String>{
        'Alcohol Pickup',
        'Alcohol Delivery'
    };
    private static final Set<String> ACCOUNT_TYPES = new Set<String>{
        'Holding Group',
        'Corporate'
    };
    private static final Set<String> EXTERNAL_SOURCE = new Set<String>{ 'MDS', 'DriveDB' };
    private Integer storesRowLimitOnAddStoresQuickAction = Integer.valueOf(
        StaticConfigurationsSelector.newInstance()
            .getInstanceValue(STORES_ROW_LIMIT_ON_ADD_STORES_QUICK_ACTION_STATIC_CONFIG)
            .Configuration_Value__c
    );
    private static final string FRANCHISE_REP_ROLE = 'Franchise Representative';
    static final String DEAD_STATUS = 'Dead';
    static final String ONBOARD_COMPLETE_STATUS = 'Onboarding Complete';
    private static final Id INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Invoice')
        .getRecordTypeId();
    private static final String ADDRESS_IN_COVERAGE = 'In Coverage';
    private static final String ADDRESS_VERIFIED = 'Verified';
    private static final String PHOTOSHOOT_ACCOUNT_CONTACT_RELATION_ROLE = 'Photoshoot Contact';

    /**
     * @description default constructor for the Account Selector class
     * @return IAccountsSelector - interface of IaccountsSelector
     */
    public static IAccountsSelector newInstance() {
        return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }

    /**
     * @description This method is for getting the fields on account object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account.Id,
            Account.Name,
            Account.Account_Lifecycle_Status__c,
            Account.Activated_Centrally_AC__c,
            Account.Activation_Status__c,
            Account.AccountSource,
            Account.BillingCountryCode,
            Account.BillingStateCode,
            Account.BillingStreet,
            Account.BillingCity,
            Account.BillingPostalCode,
            Account.BillingCountry,
            Account.BillingState,
            Account.Brand__c,
            Account.Converted_Lead_Id__c,
            Account.Change_of_Ownership_Effective_Date__c,
            Account.CurrencyIsoCode,
            Account.Deck_Rank__c,
            Account.Description,
            Account.Disallow_PDOA_Override__c,
            Account.Drive_Nintex_Id__c,
            Account.Encrypted_Tax_Id__c,
            Account.Franchise_Parent__c,
            Account.Marketplace_Nintex_Id__c,
            Account.Menu_Setup_Method__c,
            Account.Menu_to_be_Completed_By__c,
            Account.Merchant_Supplied_ID__c,
            Account.Most_Recent_Nintex_Use_Case__c,
            Account.NDA_Expiration_Date__c,
            Account.NDA_Status__c,
            Account.Order_Protocol__c,
            Account.OwnerId,
            Account.ParentId,
            Account.Partnership_Status__c,
            Account.Primary_Vertical__c,
            Account.Proposed_Date_of_Activation__c,
            Account.Proposed_Date_of_Menu__c,
            Account.Proposed_Date_of_Tablet__c,
            Account.Proposed_Date_of_Implementation__c,
            Account.RecordTypeId,
            Account.Starting_Point_ID__c,
            Account.Sales_Notes_for_Menu_Team__c,
            Account.Segment__c,
            Account.SubMarket__c,
            Account.TaxID__c,
            Account.Type,
            Account.Ultimate_Parent_Account__c,
            Account.User_Sets_PDOM_Value__c,
            Account.User_Sets_PDOT_Value__c,
            Account.Is_MDS_Activated__c,
            Account.Is_Lead_Converted_To_Existing_Account__c,
            Account.Integration_Go_Live__c,
            Account.POS_Integration_Type__c,
            Account.POS_Integration_ID__c,
            Account.Control_of_Price__c,
            Account.Experience__c,
            Account.Show_MP_Bz_Id_Update_Banner__c,
            Account.Business_Vertical__c,
            Account.RecordType.Name,
            Account.Record_Type_Name__c,
            Account.Owner.Name,
            Account.Owner.Id,
            Account.Brand__r.Name,
            Account.Brand__r.Id,
            Account.Total_Number_Of_Stores__c,
            Account.Franchise_Parent__r.Additional_Verticals__c,
            Account.Alcohol_Addendum_Signed__c,
            Account.Time_Zone_Backend__c,
            Account.Services_Fees__c,
            Account.SubMarket__r.Name,
            Account.Unique_Identifier__c,
            Account.Legal_Business_Name__c,
            Account.Is_Additional_Store__c,
            Account.Price_Range__c,
            Account.Phone,
            Account.Order_Protocol_Email__c,
            Account.POS_System__c,
            Account.Menu_URL__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Account>
     */
    public List<Account> selectById(Set<Id> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
    }

    /**
     * @description This method is used for getting Accounts by Id And non-activated MDS
     * @param idSet
     * @param mdsActivation
     * @return List<Account>
     */
    public List<Account> selectById(Set<Id> idSet, Boolean mdsActivation) {
        fflib_QueryFactory query = newQueryFactory(false)
            .setCondition('Id IN :idSet AND Is_MDS_Activated__c != :mdsActivation');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Accounts by Id And non-activated MDS
     * @param idSet
     * @return List<Account>
     */
    public List<Account> getStoreAccounts(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Name')
            .selectField('ParentId')
            .selectField('SubMarket__r.Name')
            .selectField('Brand__r.Name')
            .setCondition('Id IN :idSet');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param recordIds
     * @return List<Account>
     */
    public List<Account> selectById(Set<String> recordIds) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Owner.Name')
            .selectField('Legal_Business_Name__c')
            .selectField('Business_Vertical__r.Name')
            .selectField('Parent.Legal_Business_Name__c')
            .selectField('Brand__r.Name')
            .selectField('Submarket__r.Submarket_Id__c')
            .selectField('Is_Lead_Converted_To_Existing_Account__c')
            .setCondition('Id IN :recordIds');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting store account with parent corporate.
     * @param accountIds
     * @return List<Account> accounts
     */
    public List<Account> getStoreAccountsWithParentCorporate(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Parent.Type = :CORPORATE AND ' + 'Id IN :accountIds AND ' + 'RecordType.Name = :STORE'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method id for getting child opportunities
     * @param childOpportunities
     * @return Map<Id, Account> - List of Accounts
     */
    public List<Account> selectByOpportunity(List<Opportunity> childOpportunities) {
        // Related Accounts
        Set<Id> parentAccountIds = new Set<Id>();
        for (Opportunity childOpportunity : (List<Opportunity>) childOpportunities) {
            if (childOpportunity.AccountId != null) {
                parentAccountIds.add(childOpportunity.AccountId);
            }
        }
        return selectById(parentAccountIds);
    }

    /**
     * @description This method querying account with Bussiness record type and Account life cycle status not equal to In Pursuit.
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectUnverifiedBusinessAccountsById(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Id IN :accountIds AND Account_Lifecycle_Status__c != :IN_PURSUIT AND RecordtypeId = :BUSINESS_RECORD_TYPE_ID'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method querying account with Bussiness record type and Account life cycle status is equal to In Pursuit.
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectInPursuitBusinessAccountsById(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Id IN :accountIds AND Account_Lifecycle_Status__c = :IN_PURSUIT AND RecordtypeId = :BUSINESS_RECORD_TYPE_ID'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting child Accounts on deletion of parent
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectChildAccounts(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ParentId IN: accountRecordIds');
        query.selectField('ParentId');
        query.selectField('Parent.OwnerId');
        query.selectField('Parent.Control_of_Price__c');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting child Accounts on deletion of parent
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectChildAccountsByCorporateOrFranchiseParent(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'ParentId IN: accountRecordIds OR Franchise_Parent__c  IN :accountRecordIds'
        );
        query.selectField('ParentId');
        query.selectField('Franchise_Parent__c');
        query.selectField('Parent.OwnerId');
        query.selectField('Parent.Control_of_Price__c');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying child accounts of corporate Business accounts
     * @JIRA# LEM-11918
     * @param corporateAccountIds
     * @param queryLimit
     * @return List<Account>
     */
    public List<Account> selectChildAccountsForAccountFieldsTrickleDown(
        Set<Id> corporateAccountIds,
        Integer queryLimit
    ) {
        fflib_QueryFactory accountQuery = newQueryFactory()
            .setCondition('ParentId IN: corporateAccountIds')
            .selectField('ParentId')
            .selectField('Parent.OwnerId')
            .selectField('Parent.Control_of_Price__c')
            .selectField('Parent.Deck_Rank__c')
            .setLimit(queryLimit);
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description It is used to get the count of accounts for which the account owner is
     * not matching with parent account's owner.
     * @JIRA# LEM-11918
     * @param accountIds
     * @return Aggregate[]
     */
    public Aggregate[] selectCountOfNonMatchingParentAccountFieldsAccounts(Set<Id> accountIds) {
        String accountQuery =
            SELECT_CLAUSE +
            AGGREGATE_QUERY_ACCOUNT_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_QUERY_ELIGIBLE_ACCOUNTS_TO_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_PARENTACCOUNTID;
        AggregateResult[] accountAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(accountQuery)
        );
        return Aggregate.convertResults(accountAggregateCountQueryResult);
    }

    /**
     * @description This method is used for getting non franchisee accounts
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectNonFranchiseeAccountsById(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: accountRecordIds AND Type != :FRANCHISEE');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Accounts based on ID
     * @param accountRecordIds
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectAllParents(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Id IN: accountRecordIds OR' +
                ' ParentId IN: accountRecordIds OR Parent.ParentId IN: accountRecordIds OR' +
                ' Parent.Parent.ParentId IN: accountRecordIds OR Parent.Parent.Parent.ParentId IN: accountRecordIds'
        );
        query.selectField('Ultimate_Parent_Account__c');
        query.selectField('ParentId');
        query.selectField('Parent.ParentId');
        query.selectField('Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.ParentId');
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description This method is used for getting all accounts with past NDA Dates
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectAccountsWithExpiredNda() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('NDA_Expiration_Date__c < TODAY AND NDA_Status__c = :NDA_STATUS_ACTIVE');

        return Database.getQueryLocator(query.toSOQL());
    }
    /**
     * @description This method is used for getting Accounts based on ID
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectAllAccountsWithParent(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Id IN: accountRecordIds OR' +
                ' ParentId IN: accountRecordIds OR Parent.ParentId IN: accountRecordIds OR' +
                ' Parent.Parent.ParentId IN: accountRecordIds OR Parent.Parent.Parent.ParentId IN: accountRecordIds'
        );
        query.selectField('Id');
        query.selectField('ParentId');
        query.selectField('Parent.ParentId');
        query.selectField('Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.ParentId');
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting child records to update Merchant Verticals of Parent
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectChildMerchantVerticals(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'ParentId IN: accountRecordIds And RecordType.Name =: BUSINESS And Additional_Verticals__c !=null'
        );
        query.selectField('Additional_Verticals__c');
        query.selectField('Parent.Primary_Vertical__c');
        query.selectField('Parent.Additional_Verticals__c');
        query.selectField('ParentId');
        query.setLimit(45000);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Store records to update Additional Verticals of
     * Business Parent.
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsWithPrimaryVerticalByParentAccount(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'ParentId IN: accountIds And RecordType.Name =: STORE And Primary_Vertical__c !=null'
            )
            .selectField('Parent.Additional_Verticals__c')
            .selectField('Franchise_Parent__r.Additional_Verticals__c')
            .selectField('Franchise_Parent__r.Primary_Vertical__c')
            .selectField('Franchise_Parent__c')
            .selectField('Parent.Primary_Vertical__c')
            .selectField('ParentId')
            .selectField('Primary_Vertical__c');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting sum of all child store count
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectSumOfChildStoreCount(Set<Id> accountsIds) {
        List<AggregateResult> queryResult = [
            SELECT
                ParentId Id,
                SUM(Franchise_Owned_Store_Count__c) franchiseCount,
                SUM(Corporate_Owned_Store_Count__c) corporateCount,
                SUM(Total_Number_Of_Active_Stores_Calculate__c) activeStores,
                SUM(NumberOfMxStoresNotonDoorDashCalculate__c) inactiveStores,
                SUM(TotalNoOfActiveMarketplaceStoreCalculate__c) MDXStores,
                SUM(TotalNoOfActiveDriveStoresCalculate__c) DriveStores
            FROM ACCOUNT
            WHERE ParentId IN :accountsIds
            GROUP BY ParentId
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used for getting count of franchise owned via parent
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectFranchiseOwnedViaParentCount(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, COUNT(Id) countIds
            FROM ACCOUNT
            WHERE
                RecordType.DeveloperName = :STORE
                AND Franchise_Parent__c != NULL
                AND ParentId IN :accountsIds
            GROUP BY ParentId
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used for getting count of franchise owner via franchise parent
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectFranchiseOwnedViaFranchiseCount(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT Franchise_Parent__c Id, COUNT(Id) countIds
            FROM ACCOUNT
            WHERE RecordType.DeveloperName = :STORE AND Franchise_Parent__c IN :accountsIds
            GROUP BY Franchise_Parent__c
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used for getting count of corporate accounts
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectCorporateCount(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, COUNT(Id) countIds
            FROM ACCOUNT
            WHERE
                RecordType.DeveloperName = :STORE
                AND Franchise_Parent__c = NULL
                AND ParentId IN :accountsIds
            GROUP BY ParentId
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used for getting count of child business account with partnership status
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings(
        'PMD.ApexCRUDViolation'
    ) // As we have provided FLS/CRUD access to queried fields/object, we don't need to check CRUD Access.
    public Aggregate[] selectCountOfChildrenBusinessAccountsByPartnershipStatus(
        Set<Id> accountsIds
    ) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, Partnership_Status__c status, COUNT(Id) countIds
            FROM Account
            WHERE RecordType.DeveloperName = :BUSINESS AND ParentId IN :accountsIds
            GROUP BY ParentId, Partnership_Status__c
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used for getting count of child store account with activation status
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings(
        'PMD.ApexCRUDViolation'
    ) // As we have provided FLS/CRUD access to queried fields/object, we don't need to check CRUD Access.
    public Aggregate[] selectCountOfChildrenStoreAccountsByActivationStatus(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, Activation_Status__c status, COUNT(Id) countIds
            FROM Account
            WHERE RecordType.DeveloperName = :STORE AND ParentId IN :accountsIds
            GROUP BY ParentId, Activation_Status__c
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used to query accounts for account hierarchy component
     * @param fieldsToQuery
     * @param recordIds
     * @return List<Account>
     */
    public List<Account> selectFilteredAccount(Set<String> fieldsToQuery, List<Id> recordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: recordIds');
        query.selectFields(fieldsToQuery);
        query.setLimit(50000);
        new ContractsSelector()
            .addQueryFactorySubselect(query, 'Contracts')
            .selectField('ContractNumber')
            .selectField('Is_This_Ads_Or_Promo__c')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit((Integer.valueOf(System.Label.Contract_Minimum_Length_On_AHV) + 1));
        new PaymentAccountsSelector()
            .addQueryFactorySubselect(query, 'Payment_Accounts__r')
            .setCondition('RecordtypeId = :INVOICE_RECORD_TYPE_ID');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to query child accounts for account hierarchy component
     * @param fieldsToQuery
     * @param filteredField
     * @param recordIds
     * @return List<Account>
     */
    public List<Account> selectHierachyChildAccounts(
        Set<String> fieldsToQuery,
        SObjectField filteredField,
        List<Id> recordIds
    ) {
        // LEM-4044 - Added false to prevent querying all fields to save heap size.
        fflib_QueryFactory query = newQueryFactory(false);
        query.setCondition(
            '(RecordType.DeveloperName = :' +
                Accounts.BUSINESS +
                ' AND ParentId IN :recordIds) OR (RecordType.DeveloperName = :' +
                Accounts.STORE +
                ' AND ' +
                filteredField +
                ' IN: recordIds)'
        );
        query.selectFields(fieldsToQuery);
        query.setLimit(50000);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Account details and related records
     * (AccountPaymentAccountRelations, Agreements and Xrefs) filtered by Account Ids.
     * AccountPaymentAccountRelations of Payment Account record type, active Store Agreements
     * and active Xrefs.
     * @JIRA# LEM-2198, LEM-3997
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectRelatedChildsById(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Address_Id__c')
            .selectField('Alcohol_Addendum_Signed__c')
            .selectField('Alcohol_Eligibility__c')
            .selectField('Alcohol_Product_Eligibility__c')
            .selectField('Brand__r.Name')
            .selectField('Franchise_Parent__r.Name')
            .selectField('Franchise_Parent__r.Type')
            .selectField('Legal_Business_Name__c')
            .selectField('Menu_UI_Type__c')
            .selectField('Parent.Name')
            .selectField('Parent.Type')
            .selectField('Primary_Vertical__c')
            .selectField('Ultimate_Parent_Account__r.Name')
            .selectField('Ultimate_Parent_Account__r.Type')
            .setCondition('Id IN :accountIds')
            // It ensures business Account is retrieved first.
            .setOrdering('Record_Type_Name__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        //LEM-2328: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Account_Payment_Account_Relation__c.isAccessible()) {
            new AccountPaymentAccountRelationsSelector()
                .addQueryFactorySubselect(query, 'Account_Payment_Account_Relations__r')
                .selectField('Record_Type__c')
                .selectField('Payment_Account__r.Billing_Contact_Name__c')
                .setOrdering(
                    'Payment_Account__r.CreatedDate',
                    fflib_QueryFactory.SortOrder.DESCENDING
                );
        }
        //LEM-2328: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Agreement__c.isAccessible()) {
            new AgreementsSelector()
                .addQueryFactorySubselect(query, 'Agreements__r')
                .selectField('Contract__r.Account.Name')
                .selectField('Contract__r.Contract_Type__c')
                .selectField('Contract__r.Franchise_Supplemental_Agreement_URL__c')
                .selectField('Contract__r.Master_Supplemental_Agreement_URL__c')
                .selectField('Contract__r.Pricing_Summary_URL__c')
                .selectField('Contract__r.StartDate')
                .selectField('Contract__r.Status')
                .setCondition(
                    'Type__c IN :ONBOARDING_DETAILS_ELIGIBILE_AGREEMENT_TYPES' +
                        ' AND Status__c = :AGREEMENT_STATUS_ACTIVE' +
                        ' AND Deactivation_Date__c = null'
                )
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        //LEM-2516: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Contract.isAccessible()) {
            new ContractsSelector()
                .addQueryFactorySubselect(query, 'Contracts')
                .selectField('Account.Name')
                .selectField('Contract_Type__c')
                .selectField('Franchise_Supplemental_Agreement_URL__c')
                .selectField('Master_Supplemental_Agreement_URL__c')
                .selectField('Pricing_Summary_URL__c')
                .selectField('StartDate')
                .selectField('Status')
                .setCondition('Status = :CONTRACT_STATUS_ACTIVATED')
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        //LEM-2328: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Xref__c.isAccessible()) {
            new XrefsSelector()
                .addQueryFactorySubselect(query, 'Xrefs__r')
                .selectField('Unified_Store_ID__c')
                .selectField('Business_Reference__r.Business_Group_Id__c')
                .selectField('Business_Reference__r.External_Id__c')
                .selectField('Business_Reference__r.Unified_Business_ID__c')
                .selectField('Business_Reference__r.Business_Name__c')
                .selectField('Business_Reference__r.Default_Type__c')
                .setCondition('Xref_Status__c = :XREF_STATUS_ACTIVE')
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        if (Schema.sObjectType.Merchant_Service__c.isAccessible()) {
            new MerchantSelector()
                .addQueryFactorySubselect(query, 'Services__r')
                .selectField('Final_Commission__c')
                .selectField('Final_Fee__c')
                .selectField('Order_Product__r.Package__c')
                .selectField('Order_Product__r.Product_Code__c')
                .selectField('Order_Product__r.Product2.Name')
                .selectField('Status__c')
                .selectField('Trial_Commission__c')
                .selectField('Trial_Fee__c')
                .selectField('Active__c')
                .setCondition('Status__c = :SERVICE_STATUS_ACTIVE')
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        if (Schema.sObjectType.AccountContactRelation.isAccessible()) {
            new AccountContactRelationsSelector()
                .addQueryFactorySubselect(query, 'AccountContactRelations')
                .selectField('Contact.FirstName')
                .selectField('Contact.LastName')
                .selectField('Contact.Email')
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        if (Schema.sObjectType.Integration_Request__c.isAccessible()) {
            new IntegrationRequestsSelector()
                .addQueryFactorySubselect(query, 'Integration_Requests__r')
                .setCondition(
                    'Parent_Integration_request__c = null AND ' +
                        ' Stage__c NOT IN (\'Completed\',\'Cancelled\') AND ' +
                        ' Sfdc_Org__c = \'Lemonade\' AND ' +
                        ' Integration_Type__c = \'COO Same Store\''
                );
        }
        if (Schema.sObjectType.WorkOrder.isAccessible()) {
            new WorkOrdersSelector()
                .addQueryFactorySubselect(query, 'WorkOrders')
                .selectField('Account.Change_of_Ownership_Effective_Date__c')
                .setCondition(
                    'Type__c = \'COO\' AND ' +
                        ' Status NOT IN (\'Onboarding Complete\', \'Dead\') AND ' +
                        ' Sub_Type__c != \'COO Same Store\''
                );
        }
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to get the account attributes for Tops Down Automation
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectAccountAttributesForTopDownAutomationBatch() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('RecordType.Name = :BUSINESS OR RecordType.Name = :STORE');
        query.selectField('Primary_Vertical__c');
        query.selectField('Parent.Primary_Vertical__c');
        query.selectField('Segment__c');
        query.selectField('Ultimate_Parent_Account__r.Segment__c');
        query.selectField('Control_of_Price__c');
        query.selectField('Parent.Control_of_Price__c');
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description This method is used for getting store accounts
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsById(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('BillingCity');
        query.selectField('BillingPostalCode');
        query.setCondition('Id IN: accountRecordIds AND RecordtypeId = :STORE_RECORD_TYPE_ID');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for fetching store Accounts having associated
     * franchise parent for the provided corporate Accounts with appropriate Xrefs and franchise parent must have a Franchise Agreement with the Contract.
     * @param accountRecordIds
     * @param externalIdSource
     * @param contractId
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByParentIds(
        Set<String> accountRecordIds,
        String externalIdSource,
        String contractId
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'ParentId IN: accountRecordIds AND ' +
                    'RecordtypeId = :STORE_RECORD_TYPE_ID AND Franchise_Parent__c != null AND ' +
                    'Id IN (SELECT Salesforce_Account_Name__c FROM Xref__c WHERE External_ID_Source__c = :externalIdSource AND Xref_Status__c = :XREF_STATUS_ACTIVE AND External_ID__c != null AND BusinessID__c != null) AND ' +
                    'Franchise_Parent__c IN (SELECT Account__c FROM Agreement__c WHERE Contract__c = :contractId AND Status__c = :AGREEMENT_STATUS_ACTIVE  AND Type__c = :AGREEMENT_TYPE_FRANCHISE_AGREEMENT)'
            )
            .selectField('Franchise_Parent__r.Name')
            .selectField('Franchise_Parent__c')
            .setOrdering('Franchise_Parent__r.Name', fflib_QueryFactory.SortOrder.ASCENDING, true);

        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for fetching store Accounts having associated
     * franchise parent for the provided corporate Accounts with appropriate Xrefs and franchise parent must have a Franchise Agreement with the Contract.
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByParentIdsAndExternalSource(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('ParentId')
            .setCondition(
                'ParentId IN: accountRecordIds AND ' +
                    'RecordtypeId = :STORE_RECORD_TYPE_ID AND ' +
                    'Id IN (SELECT Salesforce_Account_Name__c FROM Xref__c WHERE ' +
                    'External_ID_Source__c IN :EXTERNAL_SOURCE AND ' +
                    'External_ID__c != null)'
            );

        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Get all the Store Accounts where Markeplace Nintext Id equals the Opportunity
     * Nintext Id.
     * @JIRA# LEM-2352
     * @param nintextIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByMarketplaceNintextIds(Set<String> nintextIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Marketplace_Nintex_Id__c')
            .selectField('Drive_Nintex_Id__c')
            .setCondition(
                'Marketplace_Nintex_Id__c IN: nintextIds AND ' +
                'RecordtypeId = :STORE_RECORD_TYPE_ID'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Get all the Store Accounts where Drive Nintext Id equals the Opportunity
     * Nintext Id.
     * @JIRA# LEM-2352
     * @param nintextIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByDriveNintextIds(Set<String> nintextIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Marketplace_Nintex_Id__c')
            .selectField('Drive_Nintex_Id__c')
            .setCondition(
                'Drive_Nintex_Id__c IN: nintextIds AND ' + 'RecordtypeId = :STORE_RECORD_TYPE_ID'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get store Account details
     * by the passed Marketplace or Drive Nintex Id.
     * @param nintexIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByMarketplaceOrDriveNintexIds(Set<String> nintexIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Activated_Centrally_AC__c')
            .selectField('Change_of_Ownership_Effective_Date__c')
            .selectField('Drive_Nintex_Id__c')
            .selectField('Marketplace_Nintex_Id__c')
            .selectField('Menu_to_be_Completed_By__c')
            .selectField('Menu_Setup_Method__c')
            .selectField('Order_Protocol__c')
            .selectField('Proposed_Date_of_Activation__c')
            .selectField('BillingCountryCode')
            .selectField('Nintex_Mx_Requested_Photoshoot__c')
            .selectField('Nintex_Photoshoot_Date__c')
            .selectField('Nintex_Photoshoot_Time__c')
            .setCondition(
                '(Drive_Nintex_Id__c IN :nintexIds OR Marketplace_Nintex_Id__c IN :nintexIds) AND ' +
                'RecordtypeId = :STORE_RECORD_TYPE_ID'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get the encrypted data stored in the passed fields
     * by the passed sObjectIds.
     * @JIRA# LEM-2966
     * @param fieldSet
     * @param sobjectIds
     * @return List<SObject>
     */
    public List<SObject> selectEncryptedData(Schema.FieldSet fieldSet, Set<Id> sobjectIds) {
        fflib_QueryFactory accountQuery = newQueryFactory()
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :sobjectIds');
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description It is used to get store Account With Brand
     * @param accountIdSet
     * @return List<Account>
     */
    public List<Account> selectAccountsWithBrandName(Set<Id> accountIdSet) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Brand__r.Name')
            .selectField('Parent.CurrencyIsoCode')
            .selectField('CurrencyIsoCode')
            .selectField('Legal_Business_Name__c')
            .setCondition('Id IN :accountIdSet');
        //LEM-19461: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Xref__c.isAccessible()) {
            new XrefsSelector()
                .addQueryFactorySubselect(query, 'Xrefs__r')
                .selectField('Record_Source__c')
                .selectField('Business_Reference__r.Id')
                .selectField('Business_Reference__r.External_Id_Source__c')
                .selectField('Business_Reference__r.Integration_Status__c')
                .selectField('Business_Reference__r.Business_Vertical__r.Id')
                .selectField('Salesforce_Account_Name__r.Franchise_Parent__c')
                .selectField('Salesforce_Account_Name__r.ParentId')
                .selectField('Salesforce_Account_Name__r.Brand__c')
                .setCondition('External_ID_Source__c != :XREF_EXTERNALID_SOURCE_DRIVE')
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        if (Schema.sObjectType.WorkOrder.isAccessible()) {
            new WorkOrdersSelector()
                .addQueryFactorySubselect(query, 'WorkOrders')
                .selectField('ParentWorkOrder.Business_Id__c')
                .selectField('ParentWorkOrder.Provisioning_Status__c')
                .setCondition(
                    'ParentWorkOrder.Provisioning_Status__c IN :STATUSES_TO_TRIGGER_PROVISIONING AND ' +
                    'Status NOT IN :INELIGIBLE_WORK_ORDER_STATUSES'
                );
        }
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to select accounts by the given fieldset and Ids.
     * @param fieldSet
     * @param accountsIds
     * @return List<Account>
     */
    public List<Account> selectAccountsByIdAndFieldSet(
        Schema.FieldSet fieldSet,
        Set<Id> accountsIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :accountsIds');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Get the Accounts with Xrefs for given Account Ids
     * @param accountIdSet
     * @return List<Account>
     */
    public List<Account> selectAccountsWithXrefs(Set<Id> accountIdSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Activation_Status__c');
        query.selectField('Brand__r.Name');
        query.selectField('CurrencyIsoCode');
        query.selectField('Franchise_Parent__c');
        query.selectField('Franchise_Parent__r.Brand__r.Name');
        query.selectField('Franchise_Parent__r.Primary_Vertical__c');
        query.selectField('Business_Vertical__c');
        query.selectField('Business_Vertical__r.Name');
        query.selectField('Franchise_Parent__r.Business_Vertical__c');
        query.selectField('Franchise_Parent__r.CurrencyIsoCode');
        query.selectField('Franchise_Parent__r.Legal_Business_Name__c');
        query.selectField('Most_Recent_Activation_Date__c');
        query.selectField('Most_Recent_Deactivation_Date__c');
        query.selectField('Parent.Brand__r.Name');
        query.selectField('Parent.Primary_Vertical__c');
        query.selectField('Parent.Business_Vertical__c');
        query.selectField('Parent.CurrencyIsoCode');
        query.selectField('Parent.Legal_Business_Name__c');
        query.selectField('Parent.Name');
        query.setCondition('Id IN :accountIdSet');
        query.addOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        //LEM-2306: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Xref__c.isAccessible()) {
            new XrefsSelector()
                .addQueryFactorySubselect(query, 'Xrefs__r')
                .selectField('Business_Reference__r.External_Id_Source__c')
                .selectField('Business_Reference__r.Integration_Status__c')
                .selectField('Business_Reference__r.Business_Vertical__r.Id')
                .setCondition(
                    'Xref_Status__c = :XREF_STATUS_ACTIVE' +
                    ' AND External_ID_Source__c != :XREF_EXTERNALID_SOURCE_DRIVE'
                )
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        new WorkOrdersSelector()
            .addQueryFactorySubselect(query, 'WorkOrders')
            .selectField('ParentWorkOrder.Business_Id__c')
            .setCondition(
                'Type__c = :COO_WORK_ORDER_TYPE AND ' +
                //'ParentWorkOrder.Provisioning_Status__c IN :STATUSES_TO_TRIGGER_PROVISIONING AND ' +
                'Status NOT IN :INELIGIBLE_WORK_ORDER_STATUSES'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Get the Accounts with Xrefs for given Account Ids
     * @param accountIdSet
     * @return List<Account>
     */
    public List<Account> selectAccountsWithInActiveXrefs(Set<Id> accountIdSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Brand__r.Name');
        query.selectField('Franchise_Parent__c');
        query.selectField('Franchise_Parent__r.Brand__r.Name');
        query.selectField('Franchise_Parent__r.Primary_Vertical__c');
        query.selectField('Franchise_Parent__r.CurrencyIsoCode');
        query.selectField('Franchise_Parent__r.Legal_Business_Name__c');
        query.selectField('Franchise_Parent__r.Business_Vertical__c');
        query.selectField('Business_Vertical__c');
        query.selectField('Business_Vertical__r.Name');
        query.selectField('Parent.Brand__r.Name');
        query.selectField('Parent.Primary_Vertical__c');
        query.selectField('Parent.CurrencyIsoCode');
        query.selectField('Parent.Legal_Business_Name__c');
        query.selectField('Parent.Business_Vertical__c');
        query.selectField('Parent.Name');
        query.setCondition('Id IN :accountIdSet');
        query.addOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        //LEM-2306: Adding check for object permissions before querying the records
        if (Schema.sObjectType.Xref__c.isAccessible()) {
            new XrefsSelector()
                .addQueryFactorySubselect(query, 'Xrefs__r')
                .selectField('Business_Reference__r.External_Id_Source__c')
                .selectField('Business_Reference__r.Integration_Status__c')
                .selectField('Business_Reference__r.Business_Vertical__r.Id')
                .setCondition(
                    'Xref_Status__c = :XREF_STATUS_INACTIVE' +
                        ' AND External_ID_Source__c = :XREF_EXTERNALID_SOURCE_MDS' +
                        ' AND External_ID__c <> null'
                )
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .setLimit(1);
        }
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order on matching
     * search key and doesn't have any child WorkOrders filtered by parentIds, parentWorkOrderId,
     * parentField, searchKey & storeIds by matching the passed search key with the Account's Name
     * or Address.
     * Suppressed warnings since searchKeyMatcher variable is used to set the condition
     * of dynamic SOQL.
     * @JIRA# LEM-3495
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @param searchKey
     * @param storeIds
     * @return List<Account>
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Account> selectVerifiedStoreAccountsByBusinessIdAndSearchKey(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField,
        String searchKey,
        Set<Id> storeIds
    ) {
        String searchKeyMatcher = '%' + String.escapeSingleQuotes(searchKey) + '%';
        fflib_QueryFactory accountQuery = newQueryFactory()
            .selectField('Address_Verification_Status__c')
            .selectField('Account_Address__c')
            .selectField('CreatedDate')
            .setCondition(
                'RecordtypeId = :STORE_RECORD_TYPE_ID AND' +
                    ' Coverage__c = :IN_COVERAGE AND' +
                    ' Address_Verification_Status__c = :VERIFIED_STATUS AND ' +
                    parentField +
                    ' IN :parentIds' +
                    ' AND ' +
                    ' Id NOT IN' +
                    ' (SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderId AND Status != :DEAD_STATUS) AND' +
                    ' ((Name LIKE :searchKeyMatcher OR' +
                    ' Account_Address__c LIKE :searchKeyMatcher) OR' +
                    ' Id IN :storeIds)'
            );
        new XrefsSelector()
            .addQueryFactorySubselect(accountQuery, 'Xrefs__r')
            .selectField('External_ID__c')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setCondition('Xref_Status__c = :XREF_STATUS_ACTIVE');
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description It is used for querying in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child WorkOrders filtered by parentIds, parentWorkOrderId and parentField.
     * @JIRA# LEM-3495
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @return List<Account>
     */
    public List<Account> selectVerifiedStoreAccountsByBusinessId(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField
    ) {
        return (List<Account>) Database.query(
            getVerifiedStoreAccountsQuery(parentIds, parentWorkOrderId, parentField).toSOQL()
        );
    }

    /**
     * @description It is used for querying in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child WorkOrders filtered by parentIds, parentWorkOrderId,
     * parentField and lastReturnedId.
     * @JIRA# LEM-3495
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @param lastReturnedId
     * @return List<Account>
     */
    public List<Account> selectVerifiedStoreAccountsById(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField,
        Id lastReturnedId
    ) {
        fflib_QueryFactory accountQuery = getVerifiedStoreAccountsQuery(
            parentIds,
            parentWorkOrderId,
            parentField
        );
        String conditionExpression = accountQuery.getCondition() + ' AND Id < :lastReturnedId';
        accountQuery.setCondition(conditionExpression);
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description It is used for forming the querying to retrieve in-coverage verified
     * store Accounts and associated Xrefs which are related to the business Account attached
     * to parent Work Order and doesn't have any child WorkOrders filtered by parentIds,
     * parentWorkOrderId and parentField.
     * @JIRA# LEM-2013, LEM-3218, LEM-3495
     * @param parentIds
     * @param parentWorkOrderId
     * @param parentField
     * @return fflib_QueryFactory
     */
    private fflib_QueryFactory getVerifiedStoreAccountsQuery(
        Set<Id> parentIds,
        Id parentWorkOrderId,
        SObjectField parentField
    ) {
        fflib_QueryFactory accountQuery = newQueryFactory()
            .selectField('Address_Verification_Status__c')
            .selectField('Account_Address__c')
            .selectField('Disallow_PDOA_Override__c')
            .setLimit(storesRowLimitOnAddStoresQuickAction)
            .setOrdering('Id', fflib_QueryFactory.SortOrder.DESCENDING)
            .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
            .setCondition(
                'RecordtypeId = :STORE_RECORD_TYPE_ID AND' +
                    ' Coverage__c = :IN_COVERAGE AND' +
                    ' Address_Verification_Status__c = :VERIFIED_STATUS AND ' +
                    parentField +
                    ' IN :parentIds' +
                    ' AND ' +
                    ' Id NOT IN' +
                    ' (SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderId AND Status != :DEAD_STATUS)'
            );
        new XrefsSelector()
            .addQueryFactorySubselect(accountQuery, 'Xrefs__r')
            .selectField('External_ID__c')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setCondition('Xref_Status__c = :XREF_STATUS_ACTIVE');
        return accountQuery;
    }

    /**
     * @description This method is used for getting child object records related to account
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectRelatedChildRecordsByAccountsWithIsMergedEnabled() {
        fflib_QueryFactory query = newQueryFactory().setCondition('Is_Merged__c = true');
        new AccountsSelector().addQueryFactorySubselect(query, 'ChildAccounts');
        new OpportunitiesSelector().addQueryFactorySubselect(query, 'Opportunities');
        new InitiativesSelector().addQueryFactorySubselect(query, 'Initiatives__r');
        new PaymentAccountsSelector()
            .addQueryFactorySubselect(query, 'Payment_Accounts__r')
            .selectField('Business_Account__r.CurrencyIsoCode');
        new WorkOrdersSelector().addQueryFactorySubselect(query, 'WorkOrders');
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description It is used for querying store Accounts related to the
     * passed franchise Accounts.
     * @param franchiseAccountIds
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectStoreAccountsByFranchiseParentIds(
        Set<Id> franchiseAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Address_Verification_Status__c')
            .selectField('Coverage__c')
            .selectField('Franchise_Parent__r.OwnerId')
            .selectField('Franchise_Parent__r.Owner.Email')
            .selectField('Parent.OwnerId')
            .selectField('Parent.Owner.Email')
            .setCondition(
                'RecordtypeId = :STORE_RECORD_TYPE_ID AND ' +
                'Franchise_Parent__c IN :franchiseAccountIds'
            );
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description It is used for querying the Accounts with its parents details upto 5 levels and
     * used it in validating accounts hierarchy with its contracting account in the Manage Stores
     * functionality on Contract object.
     * @JIRA# LEM-3684, LEM-3495
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectAccountsWithParentDetailsById(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Franchise_Parent__r.OwnerId');
        query.selectField('Franchise_Parent__r.Owner.Email');
        query.selectField('RecordType.Name');
        query.selectField('ParentId');
        query.selectField('Parent.OwnerId');
        query.selectField('Parent.Owner.Email');
        query.selectField('Coverage__c');
        query.selectField('Segment__c');
        query.selectField('Address_Verification_Status__c');
        query.selectField('Parent.ParentId');
        query.selectField('Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.Parent.Parent.ParentId');
        query.setCondition('Id IN: accountIds');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying business Accounts filtered by the passed parent field
     * and parent Ids.
     * @JIRA# LEM-3672
     * @param parentField
     * @param parentIds
     * @return List<Account>
     */
    public List<Account> selectBusinessAccountsByParentIds(
        SObjectField parentField,
        Set<Id> parentIds
    ) {
        fflib_QueryFactory accountQuery = newQueryFactory(false)
            .setCondition(
                'RecordTypeId = :BUSINESS_RECORD_TYPE_ID AND ' + parentField + ' IN :parentIds'
            );
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description This method is used for getting child corporate accounts based on account Id.
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectAllChildCorporateAccountsWithParent(Set<String> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Type IN: ACCOUNT_TYPES AND ( Id IN: accountRecordIds OR' +
                ' ParentId IN: accountRecordIds OR Parent.ParentId IN: accountRecordIds OR' +
                ' Parent.Parent.ParentId IN: accountRecordIds OR Parent.Parent.Parent.ParentId IN: accountRecordIds OR' +
                ' Parent.Parent.Parent.Parent.ParentId IN: accountRecordIds OR Parent.Parent.Parent.Parent.Parent.ParentId IN: accountRecordIds)'
        );
        query.selectField('Id');
        query.selectField('ParentId');
        query.selectField('Parent.ParentId');
        query.selectField('Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.Parent.ParentId');
        query.selectField('Parent.Parent.Parent.Parent.Parent.ParentId');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @return List<Account>
     */
    public List<Account> selectRelatedStoreAccounts(Id parentWorkOrderId) {
        return (List<Account>) Database.query(
            selectRelatedStoreAccountsQuery(parentWorkOrderId).toSOQL()
        );
    }

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @param lastReturnedId
     * @return List<Account>
     */
    public List<Account> selectRelatedStoreAccountsChunk(Id parentWorkOrderId, Id lastReturnedId) {
        fflib_QueryFactory accountQuery = selectRelatedStoreAccountsQuery(parentWorkOrderId);
        String conditionExpression = accountQuery.getCondition() + ' AND Id < :lastReturnedId';
        accountQuery.setCondition(conditionExpression);
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @return fflib_QueryFactory
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    private fflib_QueryFactory selectRelatedStoreAccountsQuery(Id parentWorkOrderId) {
        fflib_QueryFactory accountQuery = newQueryFactory()
            .selectField('Address_Verification_Status__c')
            .selectField('Account_Address__c')
            .selectField('CreatedDate')
            .setLimit(storesRowLimitOnAddStoresQuickAction)
            .setOrdering('Id', fflib_QueryFactory.SortOrder.DESCENDING)
            .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
            .setCondition(
                ' Id IN' +
                ' (SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderId AND Status != :DEAD_STATUS AND Status != :ONBOARD_COMPLETE_STATUS)'
            );

        new XrefsSelector()
            .addQueryFactorySubselect(accountQuery, 'Xrefs__r')
            .selectField('External_ID__c')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setCondition('Xref_Status__c = :XREF_STATUS_ACTIVE');

        return accountQuery;
    }

    /**
     * @description This method is used for getting Stores added to a Parent WorkOrder.
     * @param parentWorkOrderIds
     * @return List<Account>
     */
    public List<Account> selectRelatedStoreAccountsQuery(Set<Id> parentWorkOrderIds) {
        fflib_QueryFactory accountQuery = newQueryFactory(false)
            .selectField('ParentId')
            .selectField('Address_Verification_Status__c')
            .selectField('Account_Address__c')
            .selectField('CreatedDate')
            .setCondition(
                ' Id IN' +
                ' (SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderIds)'
            );
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description It is used for getting related Store Accounts information based on the passed
     * Work Order Ids.
     * @param fieldSet
     * @param parentWorkOrderIds
     * @return List<Account>
     */
    public List<Account> selectRelatedStoreAccountsInformation(
        Schema.FieldSet fieldSet,
        Set<Id> parentWorkOrderIds
    ) {
        //the condition is updated to accommodate the tablet related changes to display tablet work
        //orders related to Store.
        fflib_QueryFactory accountQuery = newQueryFactory(false)
            .selectFieldSet(fieldSet)
            .selectField('SubMarket__r.Name')
            .setCondition(
                ' Id IN' +
                ' (SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderIds AND Status != :DEAD_STATUS)'
            );
        if (Schema.sObjectType.Xref__c.isAccessible()) {
            new XrefsSelector()
                .addQueryFactorySubselect(accountQuery, 'Xrefs__r')
                .selectField('MINT_Store_Page__c')
                .selectField('Mint_BusinessPage__c')
                .selectField('POS_Page__c')
                .setCondition(
                    'Xref_Status__c = :XREF_STATUS_ACTIVE' /*AND Salesforce_Account_Name__c IN' +
                     '(SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderIds )'*/
                )
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        }
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description This method is used for getting Stores added to a Parent Workorder.
     * @param parentWorkOrderId
     * @param searchKey
     * @param storeIds
     * @return List<Account>
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Account> selectRelatedStoreAccountsBySearchKey(
        Id parentWorkOrderId,
        String searchKey,
        Set<Id> storeIds
    ) {
        fflib_QueryFactory accountQuery = newQueryFactory()
            .selectField('Address_Verification_Status__c')
            .selectField('Account_Address__c')
            .selectField('CreatedDate')
            .setCondition(
                ' Id IN' +
                    ' (SELECT AccountId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrderId AND Status != :DEAD_STATUS AND Status != :ONBOARD_COMPLETE_STATUS) AND ' +
                    ' ((Name LIKE :searchKeyMatcher OR' +
                    ' Account_Address__c LIKE :searchKeyMatcher) OR' +
                    ' Id IN :storeIds)'
            );

        new XrefsSelector()
            .addQueryFactorySubselect(accountQuery, 'Xrefs__r')
            .selectField('External_ID__c')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setCondition('Xref_Status__c = :XREF_STATUS_ACTIVE');

        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description This method is used for getting business Account with Account names and address Ids.
     * @param accountNames
     * @param addressIds
     * @return List<Account>
     */
    public List<Account> selectBusinessAccountsWithNameAndAddressId(
        Set<String> accountNames,
        Set<String> addressIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Address_ID__c');
        query.setCondition(
            'RecordTypeId = :BUSINESS_RECORD_TYPE_ID AND ' +
                '( Name IN: accountNames OR ' +
                'Address_ID__c IN: addressIds )'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Accounts by AccountIds
     * @param accountIds
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectByIdsForBatchProcess(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: accountIds');
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description This method is used for getting child merchant services with Accounts by AccountIds
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectAccountsWithActiveServices(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: accountIds');
        MerchantSelector msSelector = new MerchantSelector();
        msSelector.addQueryFactorySubselect(query, 'Services__r')
            .selectField('Product__r.Platform__c')
            .setCondition('Active__c = :IS_SERVICE_ACTIVE');
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting child merchant services with Accounts by AccountIds
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectAccountsWithServices(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: accountIds');
        MerchantSelector msSelector = new MerchantSelector();
        msSelector.addQueryFactorySubselect(query, 'Services__r')
            .selectField('Name')
            .selectField('Mx_Agreed_to_Product__c')
            .selectField('Active__c')
            .setCondition(
                'Mx_Agreed_to_Product__c = :IS_SERVICE_ACTIVE AND Active__c = :IS_SERVICE_ACTIVE'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting accounts along with its franchise role
     * accountteam members based on account Id.
     * @param recordIds
     * @return List<Account>
     */
    public List<Account> selectAccountWithAccTeamMembers(Set<Id> recordIds) {
        fflib_QueryFactory accountQuery = newQueryFactory(true)
            .setCondition(
                'Id IN :recordIds AND RecordType.DeveloperName =:BUSINESS AND Type =:CORPORATE'
            );
        new AccountTeamMembersSelector()
            .addQueryFactorySubselect(accountQuery, 'AccountTeamMembers')
            .setCondition('TeamMemberRole =: FRANCHISE_REP_ROLE');
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description This method is used for getting Corporate Account Ids
     * from Store account for a Franchise account.
     * @param accountsIds
     * @return List<Account>
     */
    public List<Account> getCorporateAccountIdsByFranchiseAccount(Set<Id> accountsIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Franchise_Parent__r.Primary_Vertical__c')
            .setCondition(
                'RecordtypeId = :STORE_RECORD_TYPE_ID AND ' + 'Franchise_Parent__c IN :accountsIds'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Selects Stores made in a given Bulk Stores Onboarding transaction By Process Flow Request.
     * @param flowRequestId
     * @return List<Account>
     **/
    public List<Account> getStoresByBulkOnboardingRequestId(Id flowRequestId) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Coverage__c');
        query.selectField('Address_Verification_Status__c');
        query.selectField('Accessibilities__c');
        query.selectField('BillingPostalCode');
        query.setCondition(
            'RecordtypeId = :STORE_RECORD_TYPE_ID AND ' +
            'Bulk_Corporate_Onboarding_Request__c = :flowRequestId'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Select the entire Corporate hierarchy.
     * @param fieldsToQuery
     * @param recordIds
     * @return List<Account>
     */
    public List<Account> getCorporateAccountHierarchyByUltimateParentAccount(
        Set<String> fieldsToQuery,
        List<Id> recordIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('RecordType.Name')
            .selectField('Owner.Name')
            .selectField('Owner.Id')
            .selectField('Brand__r.Name')
            .selectField('Brand__r.Id')
            .selectField('ParentId')
            .selectField('Type')
            .selectField('Total_Number_Of_Stores__c')
            .selectField('RecordType.DeveloperName')
            .selectField('RecordType.Name')
            .selectField('Brand__r.Id')
            .selectField('Record_Type_Name__c')
            .selectField('Owner.Name')
            .selectField('Owner.Id')
            .selectField('Brand__r.Name')
            .selectField('Name')
            .selectFields(fieldsToQuery)
            .setCondition(
                '(RecordType.DeveloperName = :' + Accounts.BUSINESS + ' AND ParentId IN :recordIds)'
            )
            .setOrdering('RecordType.Name', fflib_QueryFactory.SortOrder.ASCENDING)
            .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
            .setLimit(Integer.valueOf(System.Label.Account_Hierarchy_Query_Limit));
        new ContractsSelector()
            .addQueryFactorySubselect(query, 'Contracts')
            .selectField('ContractNumber')
            .selectField('Is_This_Ads_Or_Promo__c')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit((Integer.valueOf(System.Label.Contract_Minimum_Length_On_AHV) + 1));
        new PaymentAccountsSelector()
            .addQueryFactorySubselect(query, 'Payment_Accounts__r')
            .setCondition('RecordtypeId = :INVOICE_RECORD_TYPE_ID');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Select the entire Corporate hierarchy.
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> getUltimateParentAccount(Set<String> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Coverage__c')
            .selectField('RecordType.Name')
            .selectField('Owner.Name')
            .selectField('Owner.Id')
            .selectField('Brand__r.Name')
            .selectField('Brand__r.Id')
            .selectField('ParentId')
            .selectField('Total_Number_Of_Stores__c')
            .setCondition('Id IN :accountIds');
        new ContractsSelector()
            .addQueryFactorySubselect(query, 'Contracts')
            .selectField('ContractNumber')
            .selectField('Is_This_Ads_Or_Promo__c')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit((Integer.valueOf(System.Label.Contract_Minimum_Length_On_AHV) + 1));
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Store Accounts
     * for passed list of ids.
     * @param accountsIds
     * @return List<Account>
     */
    public Database.QueryLocator getStoreAccountsById(Set<Id> accountsIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Rate_Change_Request__c')
            .setCondition('RecordtypeId = :STORE_RECORD_TYPE_ID AND ' + 'Id IN :accountsIds');
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description Select the Franchise Accounts For Corporate Accounts
     * @param corporateAccountIds
     * @return List<Account>
     */
    public List<Account> selectFranchiseAccountsForCorporateAccounts(Set<Id> corporateAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('OwnerId')
            .selectField('Name')
            .selectField('ParentId')
            .setCondition(
                'ParentId IN :corporateAccountIds AND ' +
                    ' ((RecordtypeId = :STORE_RECORD_TYPE_ID AND Franchise_Parent__c != null) ' +
                    ' OR (RecordTypeId = :BUSINESS_RECORD_TYPE_ID AND Type = :FRANCHISEE) )'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description Retrieves a list of Account records without applying any filters, using the specified set of fields and record IDs.
     * @param fieldsToQuery A set of field names to include in the query.
     * @param recordIds A set of record IDs to retrieve.
     * @return A list of Account records matching the specified criteria.
     */
    public List<Account> selectAccountWithOutFilterswithSetOfFieldsPassed(
        Set<String> fieldsToQuery,
        Set<Id> recordIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectFields(fieldsToQuery)
            .setCondition('Id IN: recordIds');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting sum of all business accounts
     * @param accountIdSet
     * @return Aggregate[]
     */
    public Aggregate[] selectCountOfAccounts(Set<Id> accountIdSet) {
        String accountsQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD;
        AggregateResult[] queryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(accountsQuery)
        );
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description This method is used for getting franchisee store accounts
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectFranchiseeStoreAccountsById(Set<Id> accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: accountRecordIds AND Franchise_Parent__c != null');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description retrive the store accounts along with their active and valid Xrefs
     * @param storeAccountdIds
     * @return List<Account>
     */
    public List<Account> getStoreAccountsWithValidActiveXrefs(Set<Id> storeAccountdIds) {
        fflib_QueryFactory accountQuery = newQueryFactory().setCondition('Id IN :storeAccountdIds');
        new XrefsSelector()
            .addQueryFactorySubselect(accountQuery, 'Xrefs__r')
            .setCondition(
                'Xref_Status__c = :XREF_STATUS_ACTIVE AND External_ID__c <> null and External_ID_Source__c <> null and Business_Reference__c <> null'
            );
        return (List<Account>) Database.query(accountQuery.toSOQL());
    }

    /**
     * @description It is used to get the count of child store account with medal rank.
     * As we have provided FLS/CRUD access to queried fields/object, we don't need to check CRUD Access.
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectCountOfStoreAccountsByMedalRank(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, Medal_Rank__c medalRank, COUNT(Id) countIds
            FROM Account
            WHERE RecordType.DeveloperName = :STORE AND ParentId IN :accountsIds
            GROUP BY ParentId, Medal_Rank__c
        ];
        return Aggregate.convertResults(queryResult);
    }

    /**
     * @description It is used for getting Accounts by uniqueIdentifiers And recordType.
     * @param uniqueIdentifiers
     * @param recordTypeId
     * @return List<Account>
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public List<Account> selectAccountsByUniqueIdentifiersAndRecordType(
        Set<String> uniqueIdentifiers,
        Id recordTypeId
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Name')
            .selectField('CurrencyIsoCode')
            .selectField('Unique_Identifier__c')
            .selectField('ParentId')
            .selectField('POS_Integration_Type__c')
            .selectField('Sales_Notes_for_Menu_Team__c')
            .setCondition(
                'Unique_Identifier__c IN :uniqueIdentifiers AND RecordtypeId = :recordTypeId'
            )
            .setOrdering('Unique_Identifier__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting the Account which has MX tag Association named as TOPMX by AccountIds.
     * @JIRA LEM-14284
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectAccountsWithMxTagAssociation(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :accountIds');
        new MxTagAssociationsSelector()
            .addQueryFactorySubselect(query, 'Mx_Tags_Association__r')
            .selectField('Id')
            .selectField('MxTagName__c')
            .selectField('Name')
            .setCondition('MxTag__r.Name = :TOPMX OR MxTagName__c =:TOPMX');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to Query accounts with associated opportunities and account contact relations
     * by passing account ids and contact ids.
     * @param accountIds
     * @param contactIds
     * @return List<Account>
     */
    public List<Account> selectAccountAndRelatedContactRelationsByAccountAndContactIds(
        Set<Id> accountIds,
        List<Id> contactIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Partnership_Status__c')
            .selectField('OwnerId')
            .selectField('Owner.IsActive')
            .selectField('Ultimate_Parent_Account__c')
            .setCondition('Id IN :accountIds');
        new AccountContactRelationsSelector()
            .addQueryFactorySubselect(query, 'AccountContactRelations')
            .selectField('ContactId')
            .selectField('AccountId')
            .selectField('Roles')
            .setCondition(
                'AccountId IN :accountIds AND ContactId IN :contactIds AND IsActive = true'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to Query accounts where the account ultimate parent
     * is in the passed set of ultimateParentAccountIds.
     * @param ultimateParentAccountIds
     * @param contactIds
     * @return List<Account>
     */
    public List<Account> selectAccountsByUltimateParentAccountIds(
        Set<Id> ultimateParentAccountIds,
        List<Id> contactIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Partnership_Status__c')
            .selectField('OwnerId')
            .selectField('Owner.IsActive')
            .selectField('Ultimate_Parent_Account__c')
            .setCondition('Ultimate_Parent_Account__c IN :ultimateParentAccountIds');
        new AccountContactRelationsSelector()
            .addQueryFactorySubselect(query, 'AccountContactRelations')
            .selectField('ContactId')
            .selectField('AccountID')
            .selectField('Roles')
            .selectField('Account.Ultimate_Parent_Account__c')
            .setCondition(
                'Account.Ultimate_Parent_Account__c IN :ultimateParentAccountIds AND ContactId IN :contactIds AND IsActive = true'
            );
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to Query accounts with associated opportunities
     * by passing account ids.
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectAccountAndRelatedOpportunitiesByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Ultimate_Parent_Account__c')
            .selectField('ParentId')
            .selectField('Partnership_Status__c')
            .selectField('OwnerId')
            .selectField('Owner.IsActive')
            .setCondition('Id IN :accountIds');
        new OpportunitiesSelector()
            .addQueryFactorySubselect(query, 'Opportunities')
            .setCondition('AccountId IN :accountIds AND IsClosed = false')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting Store Accounts based on
     * Parent Account Id and UUID.
     * @JIRA LEM-15363
     * @param accountIds
     * @param uuids
     * @return List<Account>
     */
    public List<Account> selectByUniqueIdentifiers(Set<Id> accountIds, Set<String> uuids) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Order_Protocol__c')
            .selectField('Menu_to_be_Completed_By__c')
            .setCondition('ParentId IN :accountIds AND Unique_Identifier__c IN :uuids');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves a list of Account records based on the specified IDs and a map of fields to include.
     *
     * @param accountId The set of parent IDs to filter the Account records.
     * @param sobjectToSetOfField A map of String to a set of fields to include in the query.
     * @return A list of Account records that match the specified criteria.
     */
    public List<Account> selectAccountByIdWithXrefPaymentAccount(
        Set<Id> accountId,
        Map<String, Set<String>> sobjectToSetOfField
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectFields(sobjectToSetOfField.get('Account'))
            .selectField('BillingCountry')
            .selectField('Segment__c')
            .selectField('Primary_Vertical__c')
            .selectField('Experience__c')
            .selectField('Proposed_Date_of_Activation__c')
            .selectField('Deck_Rank__c')
            .selectField('Legal_Business_Name__c')
            .selectField('POS_System__c')
            .selectField('Alternative_Store_Name__c')
            .setCondition('Id IN :accountId');
        new XrefsSelector()
            .addQueryFactorySubselect(query, 'Xrefs__r')
            .selectField('Business_Reference__r.Id')
            .selectFields(sobjectToSetOfField.get('Xref'))
            .setCondition(
                'Xref_Status__c = :XREF_STATUS_INACTIVE' +
                ' AND External_ID_Source__c = :XREF_EXTERNALID_SOURCE_MDS'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        new AccountPaymentAccountRelationsSelector()
            .addQueryFactorySubselect(query, 'Account_Payment_Account_Relations__r')
            .selectFields(sobjectToSetOfField.get('Account_Payment_Account_Relation'))
            .selectField('Payment_Account__r.Id')
            .setCondition('Payment_Account__r.RecordType.DeveloperName = \'Payments\'')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description - select by business account and return store info along with its payament account
     * @author Soumya Dash | 07-30-2024
     * @param bussinessAccountId
     * @param objectTosObjectField
     * @return List<Account>
     **/
    public List<Account> selectByBusinessAccountIdAndgetStoreDetails(
        Id bussinessAccountId,
        Map<String, Set<String>> objectTosObjectField
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectFields(objectTosObjectField.get('Account'))
            .selectField('Name')
            .selectField('BillingCountry')
            .selectField('ParentId')
            .selectField('Hours_of_Operation__c')
            .selectField('RecordTypeId')
            .selectField('BillingCountry')
            .selectField('Legal_Business_Name__c')
            .setCondition(
                '(ParentId = :bussinessAccountId OR Ultimate_Parent_Account__c = :bussinessAccountId) AND Address_Verification_Status__c  = :ADDRESS_VERIFIED  AND Coverage__c = :ADDRESS_IN_COVERAGE'
            )
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);

        new XrefsSelector()
            .addQueryFactorySubselect(query, 'Xrefs__r')
            .setCondition(
                'Xref_Status__c = :XREF_STATUS_ACTIVE' +
                ' AND External_ID_Source__c = :XREF_EXTERNALID_SOURCE_MDS'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        new AccountContactRelationsSelector()
            .addQueryFactorySubselect(query, 'AccountContactRelations')
            .selectFields(objectTosObjectField.get('Contact'))
            .setCondition('Roles INCLUDES (:PHOTOSHOOT_ACCOUNT_CONTACT_RELATION_ROLE)')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);

        new AccountPaymentAccountRelationsSelector()
            .addQueryFactorySubselect(query, 'Account_Payment_Account_Relations__r')
            .selectField('Payment_Account__r.Id')
            .selectField('Payment_Account__r.Name')
            .selectField('Payment_Account__r.RoutingNumber__c')
            .selectField('Payment_Account__r.Bank_Account_Number__c')
            .selectField('Payment_Account__r.Institution_Number__c')
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true)
            .setLimit(1);

        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Store Accounts along with Tablet MxOrders
     * and Decision Maker Contact details based on passed Store Account Ids.
     * @JIRA# LEM-16642
     * @param storeAccountIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsAndRelatedEntitiesByAccountIds(
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Menu_URL__c')
            .selectField('Order_Protocol__c')
            .selectField('Tablet_Delivery_Method__c')
            .selectField('Proposed_Date_of_Activation__c')
            .selectField('Proposed_Date_of_Menu__c')
            .setCondition('Id IN :storeAccountIds');
        new AccountContactRelationsSelector()
            .addQueryFactorySubselect(query, 'AccountContactRelations')
            .selectField('Contact.Email')
            .selectField('Contact.Phone')
            .setCondition(
                'Roles includes (:DECISION_MAKER_ACCOUNT_CONTACT_RELATION_ROLE) AND IsActive = true'
            )
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true)
            .setLimit(1);
        new MerchantOrdersSelector()
            .addQueryFactorySubselect(query, 'MX_Order_Account__r')
            .selectField('Contact__r.FirstName')
            .selectField('Contact__r.LastName')
            .selectField('Tracking_Number__c')
            .selectField('Shipping_Carrier__c')
            .selectField('Shipment_Status__c')
            .selectField('Merchant_Address__c')
            .setCondition(
                'Type__c = :MX_ORDER_TYPE_TABLET AND Type_Of_Request__c = :MX_ORDER_TYPE_NET_NEW'
            )
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true)
            .setLimit(1);
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to Query accounts with brand associations
     * by passing account ids.
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> getAccountsWithBrandAssociationsbyAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Name')
            .selectField('BillingCountryCode')
            .selectField('Record_Type_Name__c')
            .selectField('ParentId')
            .setCondition('Id IN :accountIds');
        new BrandAssociationsSelector()
            .addQueryFactorySubselect(query, 'Brand_Associations__r')
            .selectField('Brand_Name__c')
            .setCondition('Business_Account_Name__c IN :accountIds');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Store Accounts based on passed Parent Ids and Experience.
     * @JIRA# LEM-15585
     * @param parentIds
     * @param experienceValue
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByParentIdsAndExperience(
        Set<Id> parentIds,
        String experienceValue
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ParentId IN: parentIds AND Experience__c INCLUDES (:experienceValue)');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to Query accounts with partnership expiration date in next 90 days
     * and having renewal opportunity as null by passing account ids.
     * @return List<Account>
     */
    public Database.QueryLocator getAccountsForRunningRenewalBatch() {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('CurrencyIsoCode')
            .selectField('Partnership_Expiration_Date__c')
            .selectField('Total_Number_Of_Active_Stores_Calculate__c')
            .selectField('OwnerId')
            .selectField('Partnership_Level__c')
            .setCondition(
                'Partnership_Expiration_Date__c <= NEXT_N_DAYS:90 AND Renewal_Opportunity__c = null AND RecordtypeId = :BUSINESS_RECORD_TYPE_ID AND Total_Number_Of_Active_Stores_Calculate__c != null'
            );
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description - select by store account id and get its details along with payament account
     * @author Soumya Dash | 07-30-2024
     * @param storeAccountId
     * @param businessAccountId
     * @param objectTosObjectField
     * @return List<Account>
     **/
    public List<Account> selectByStoreAccountIdAndgetStoreDetails(
        Id storeAccountId,
        Id businessAccountId,
        Map<String, Set<String>> objectTosObjectField
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectFields(objectTosObjectField.get('Account'))
            .selectField('Name')
            .selectField('ParentId')
            .selectField('BillingCountry')
            .selectField('Hours_of_Operation__c')
            .selectField('BillingCountry')
            .selectField('Legal_Business_Name__c')
            .selectField('Parent.Legal_Business_Name__c')
            .selectField('RecordTypeId')
            .setCondition(
                'Id = :storeAccountId AND (ParentId = :businessAccountId OR Ultimate_Parent_Account__c = :businessAccountId) AND Address_Verification_Status__c  = :ADDRESS_VERIFIED  AND Coverage__c = :ADDRESS_IN_COVERAGE'
            )
            .setLimit(1);

        new AccountContactRelationsSelector()
            .addQueryFactorySubselect(query, 'AccountContactRelations')
            .selectFields(objectTosObjectField.get('Contact'))
            .setCondition('Roles INCLUDES (:PHOTOSHOOT_ACCOUNT_CONTACT_RELATION_ROLE)')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);

        new AccountPaymentAccountRelationsSelector()
            .addQueryFactorySubselect(query, 'Account_Payment_Account_Relations__r')
            .selectField('Payment_Account__r.Id')
            .selectField('Payment_Account__r.Name')
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true)
            .setLimit(1);

        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description selecting accountId with Xref fields
     * @author SamikshaDD | 07-12-2024
     * @param accountId
     * @param sobjectToSetOfField
     * @return List<Account>
     **/
    public List<Account> selectAccountByIdWithXref(
        Set<Id> accountId,
        Map<String, Set<String>> sobjectToSetOfField
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectFields(sobjectToSetOfField.get('Account'))
            .selectField('BillingCountry')
            .selectField('Segment__c')
            .setCondition('Id IN :accountId');
        new XrefsSelector()
            .addQueryFactorySubselect(query, 'Xrefs__r')
            .selectFields(sobjectToSetOfField.get('Xref'))
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting count of Active corporate accounts
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectActiveCorporateCount(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, COUNT(Id) countIds
            FROM ACCOUNT
            WHERE
                RecordType.DeveloperName = :STORE
                AND Activation_Status__c = :XREF_STATUS_ACTIVE
                AND ParentId IN :accountsIds
            GROUP BY ParentId
        ];
        return Aggregate.convertResults(queryResult);
    }
    /**
     * @description This method is used for getting count of Inactive corporate accounts
     * @param accountsIds
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Aggregate[] selectInActiveCorporateCount(Set<Id> accountsIds) {
        AggregateResult[] queryResult = [
            SELECT ParentId Id, COUNT(Id) countIds
            FROM ACCOUNT
            WHERE
                RecordType.DeveloperName = :STORE
                AND Activation_Status__c != :XREF_STATUS_ACTIVE
                AND ParentId IN :accountsIds
            GROUP BY ParentId
        ];
        return Aggregate.convertResults(queryResult);
    }
    /**
     * @description This method is used for getting count of store account with MDS Xrefs
     * @param accountIdSet
     * @return  List<Account>
     */
    public List<Account> selectAccountsWithMDSXrefs(Set<Id> accountIdSet) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'ParentId IN: accountIdSet AND ' +
                    'RecordtypeId = :STORE_RECORD_TYPE_ID AND' +
                    ' Activation_Status__c = :XREF_STATUS_ACTIVE AND' +
                    ' Id IN (SELECT Salesforce_Account_Name__c FROM Xref__c WHERE External_ID_Source__c = :XREF_EXTERNALID_SOURCE_MDS AND Xref_Status__c = :XREF_STATUS_ACTIVE)'
            )
            .selectField('Id');
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting count of store account with non MDS Xrefs
     * @param accountIdSet
     * @return  List<Account>
     */
    public List<Account> selectAccountsWithNonMDSXrefs(Set<Id> accountIdSet) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'ParentId IN: accountIdSet AND ' +
                    'RecordtypeId = :STORE_RECORD_TYPE_ID AND' +
                    ' Activation_Status__c = :XREF_STATUS_ACTIVE AND' +
                    ' Id IN (SELECT Salesforce_Account_Name__c FROM Xref__c WHERE External_ID_Source__c = :XREF_EXTERNALID_SOURCE_DRIVE AND Xref_Status__c = :XREF_STATUS_ACTIVE)'
            )
            .selectField('Id');
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for querying parent business Accounts filtered by the Store AccountIds
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectBusinessAccountIdsFromStoreAccountId(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('ParentId');
        query.setCondition(
            'Id IN: accountIds AND' +
                ' RecordtypeId = :STORE_RECORD_TYPE_ID AND' +
                ' Activation_Status__c = :XREF_STATUS_ACTIVE'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to query Accounts based on Mx Onboarding Link Ids.
     * @JIRA# LEM-15113
     * @param mxOnboardingLinkIds
     * @return List<Account>
     */
    public List<Account> selectAccountsByMxOnboardingLinkIds(Set<String> mxOnboardingLinkIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Address_Verification_Status__c');
        query.selectField('Coverage__c');
        query.selectField('Mx_Onboarding_Link_Id__c');
        query.selectField('Store_Details__c');
        query.setCondition('Mx_Onboarding_Link_Id__c IN :mxOnboardingLinkIds');
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves a list of Account records based on the provided accountIds and bizIds.
     *
     * @param uuids A set of Account record uuids to filter the query.
     * @param bizIds A set of business reference external Ids to filter xrefs in the query.
     * @return A list of Account records that match the specified criteria.
     */
    public List<Account> selectStoreAccountByUUIDWithXrefs(Set<String> uuids, Set<String> bizIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Unique_Identifier__c')
            .setCondition(
                'Unique_Identifier__c IN :uuids AND RecordtypeId = :STORE_RECORD_TYPE_ID'
            );
        new XrefsSelector()
            .addQueryFactorySubselect(query, 'Xrefs__r')
            .selectField('Business_Reference__r.External_Id__c')
            .setCondition('Business_Reference__r.External_Id__c IN : bizIds')
            .setLimit(1);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description Store Account by Id with MDS Xref
     * @author VenkateshDD | 08-05-2024
     * @param uuids
     * @return List<Account>
     **/
    public List<Account> selectStoreAccountByUUIDWithXrefs(Set<String> uuids) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Unique_Identifier__c')
            .selectField('Order_Protocol__c')
            .selectField('Menu_UI_Type__c')
            .selectField('ParentId')
            .selectField('Parent.CurrencyIsoCode')
            .setCondition(
                'Unique_Identifier__c IN :uuids AND RecordtypeId = :STORE_RECORD_TYPE_ID'
            );
        new XrefsSelector()
            .addQueryFactorySubselect(query, 'Xrefs__r')
            .selectField('Business_Reference__r.External_Id__c')
            .setCondition('External_ID_Source__c = :XREF_EXTERNALID_SOURCE_MDS')
            .setLimit(1);
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting store accounts based on parent account id.
     * @param accountRecordIds
     * @return List<Account>
     */
    public List<Account> selectStoreAccountsByParentId(Id accountRecordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('BillingCity');
        query.selectField('BillingPostalCode');
        query.setCondition(
            '(ParentId =: accountRecordIds OR Franchise_Parent__c =: accountRecordIds) AND RecordtypeId = :STORE_RECORD_TYPE_ID'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to query store accounts and corresponding xRef record for account dedupe logic.
     * @param fieldSetToQuery
     * @param accountType
     * @param brandIds
     * @param accountIds
     * @return List<Account>
     */
    public List<Account> selectMatchingAccounts(
        Schema.FieldSet fieldSetToQuery,
        Set<String> accountType,
        Set<Id> brandIds,
        Set<Id> accountIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectFieldSet(fieldSetToQuery)
            .setCondition(
                'RecordType.DeveloperName = :' +
                    Accounts.STORE +
                    ' AND Type IN :accountType' +
                    ' AND Brand__c IN :brandIds' +
                    ' AND ParentId IN :accountIds'
            );
        new XrefsSelector()
            .addQueryFactorySubselect(query, 'Xrefs__r')
            .setCondition(
                'Xref_Status__c = :XREF_STATUS_ACTIVE' +
                ' AND External_ID_Source__c =:XREF_EXTERNALID_SOURCE_MDS'
            );
        query.setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Account>) Database.query(query.toSOQL());
    }
    /**
     * @description Retrieves store accounts based on the provided business account ID.
     * @param businessAccountId The ID of the business account.
     * @return A list of store accounts associated with the given business account ID.
     */
    public List<Account> getStoreAccountbyBusinessAccountId(Id businessAccountId) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Name')
            .selectField('Hours_of_Operation__c')
            .selectField('RecordTypeId')
            .selectField('BillingCountry')
            .selectField('Legal_Business_Name__c')
            .setCondition(
                '(ParentId = :businessAccountId OR Ultimate_Parent_Account__c = :businessAccountId) AND Address_Verification_Status__c  = :ADDRESS_VERIFIED  AND Coverage__c = :ADDRESS_IN_COVERAGE'
            )
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
        return (List<Account>) Database.query(query.toSOQL());
    }
}