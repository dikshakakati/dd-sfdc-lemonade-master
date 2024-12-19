/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Selector class for Xref__c object.
 * Suppressed warnings since selector class contains multiple public methods.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class XrefsSelector extends fflib_SObjectSelector implements IXrefsSelector {
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = 'COUNT(Id) xrefsCount, Salesforce_Account_Name__c accountId';
    static final String BUSINESS = 'Business';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String ORDER_BY_CLAUSE = ' ORDER BY ';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String QUERY_FILTER_CONDITION_STATUS_AND_EXTERNAL_ID_SOURCE = 'Xref_Status__c =: XREF_ACTIVE_STATUS AND Business_Reference__r.External_Id__c NOT IN :mpBzIds AND External_Id_Source__c = :DRIVEDB AND Salesforce_Account_Name__c IN: salesforceAccountIds';
    private static final String SALESFORCE_ACCOUNT_NAME_FIELD = 'Salesforce_Account_Name__c';
    private static final String SELECT_CLAUSE = 'SELECT ';
    static final String STORE = 'Store';
    private static final String SUCCESS = 'Success';
    private static final String WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String WHERE_CLAUSE = ' FROM Xref__c WHERE ';
    static final String XREF_ACTIVE_STATUS = 'Active';
    static final String DRIVEDB = 'DriveDb';
    static final String MDS = 'MDS';
    static final String FAILURE = 'Failure';
    static final String TEXT = 'Text';
    static final String BUSINESS_REFERENCE = 'Business_Reference__c';
    static final String ACTIVE = 'Active';
    static final String CORPORATE = 'Corporate';

    /**
     * @description Default constructor for the Xrefs Selector class.
     * @return IXrefsSelector - instance of IXrefsSelector
     */
    public static IXrefsSelector newInstance() {
        return (IXrefsSelector) Application.Selector.newInstance(Xref__c.SObjectType);
    }

    /**
     * @description It is used for getting the fields on Xref__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Xref__c.Id,
            Xref__c.CurrencyIsoCode,
            Xref__c.Business_GroupID__c,
            Xref__c.BusinessID__c,
            Xref__c.Mint_BusinessPage__c,
            Xref__c.Integration_Status__c,
            Xref__c.Business_Reference__c,
            Xref__c.Salesforce_Account_Name__c,
            Xref__c.External_ID__c,
            Xref__c.External_ID_Source__c,
            Xref__c.Xref_Status__c,
            Xref__c.Account_Record_Type__c,
            Xref__c.Business_Name__c,
            Xref__c.Account_Type__c,
            Xref__c.MINT_Store_Page__c,
            Xref__c.Merchant_Portal__c,
            Xref__c.Createddate,
            Xref__c.COO_Graveyard_Id__c,
            Xref__c.Integration_Message__c,
            Xref__c.Name
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Xref__c.SObjectType;
    }

    /**
     * @description This method is used for getting Xref based on parent account id
     * @param recordId
     * @return List<Xref__c>
     */
    public List<Xref__c> selectAllInAccountHierarchy(Id recordId) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__r.Name')
            .selectField('Mint_Business_Portal_Page__c')
            .selectField('Online_Ordering_Business_Page__c')
            .selectField('Online_Ordering_Store_Page__c')
            .setCondition(
                ' (Salesforce_Account_Name__c =: recordId OR' +
                    ' Salesforce_Account_Name__r.ParentId =: recordId OR Salesforce_Account_Name__r.Parent.ParentId =: recordId OR' +
                    ' Salesforce_Account_Name__r.Parent.Parent.ParentId =: recordId OR Salesforce_Account_Name__r.Parent.Parent.Parent.ParentId =: recordId OR' +
                    ' Salesforce_Account_Name__r.Parent.Parent.Parent.Parent.ParentId =: recordId) AND (Salesforce_Account_Name__r.Record_Type_Name__c =:BUSINESS OR Salesforce_Account_Name__r.Record_Type_Name__c =:STORE) '
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting active Xrefs by account id
     * @param recordId
     * @return List<Xref__c>
     */
    public List<Xref__c> selectActiveXrefsByAccountId(Id recordId) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__r.Name')
            .selectField('Online_Ordering_Business_Page__c')
            .selectField('Online_Ordering_Store_Page__c')
            .setCondition(
                'Salesforce_Account_Name__c =: recordId AND Xref_Status__c =: XREF_ACTIVE_STATUS'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Xref based on Business_Reference__c
     * @param busRefIdSet
     * @return List<Xref__c>
     */
    public List<Xref__c> selectAllMatchingBusinessReference(Set<Id> busRefIdSet) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Salesforce_Account_Name__r.Record_Type_Name__c')
            .selectField('Business_Reference__r.Last_Completed_Step__c')
            .setCondition('Business_Reference__c IN :busRefIdSet');
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting all Xref info needed to send the platform events.
     * @param xRefIdSet
     * @return List<Xref__c>
     */
    public List<Xref__c> selectAllInfoNeededForPlatformEvent(Set<Id> xRefIdSet) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('CreatedById')
            .selectField('CreatedDate')
            .selectField('MS_Sync_Stage__c')
            .selectField('Inactive_Xref__r.External_ID__c')
            .setCondition('Id IN :xRefIdSet');
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Xref based on Business_Reference__c where Account Record type is Business
     * @param busRefIdSet
     * @return List<Xref__c>
     */
    public List<Xref__c> selectAllMatchingBusinessReferenceForDriveDb(Set<Id> busRefIdSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Business_Reference__c IN :busRefIdSet AND Account_Record_Type__c =: BUSINESS'
        );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Xref details based on Xref Ids.
     * @JIRA# LEM-18813
     * @param xrefIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectById(Set<Id> xrefIds) {
        fflib_QueryFactory xrefQuery = newQueryFactory().setCondition('Id IN :xrefIds');
        return (List<Xref__c>) Database.query(xrefQuery.toSOQL());
    }

    /**
     * @description This method is used for getting Xref based on Salesforce Account Name
     * @param sfAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectBySalesforceAccountName(Set<Id> sfAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Xref_Status__c')
            .selectField('Salesforce_Account_Name__r.id')
            .selectField('Business_Reference__c')
            .selectField('Business_Reference__r.External_Id__c')
            .selectField('Business_Reference__r.Business_Vertical__r.id')
            .selectField('Salesforce_Account_Name__r.Record_Type_Name__c')
            .selectField('External_ID__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :sfAccountIds AND Business_Reference__c != null AND Xref_Status__c =: XREF_ACTIVE_STATUS'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting Xref based on Salesforce Account Name
     * @param sfAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectActiveXrefsBySalesforceAccountName(Set<Id> sfAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Name')
            .selectField('External_ID__c')
            .selectField('Figment_ID__c')
            .selectField('Salesforce_Account_Name__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Integration_Status__c')
            .selectField('Associated_Rate_Change_Request__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Xref_Status__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :sfAccountIds AND Xref_Status__c =: XREF_ACTIVE_STATUS'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Drive Xrefs based on Salesforce Account Name And Franchise Account
     * @param sfAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectDriveDbXrefsBySalesforceAccountName(Set<Id> sfAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__r.Id')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Salesforce_Account_Name__r.Franchise_Parent__c')
            .selectField('Salesforce_Account_Name__r.ParentId')
            .setCondition(
                '(Salesforce_Account_Name__c IN :sfAccountIds OR Salesforce_Account_Name__r.Franchise_Parent__c IN: sfAccountIds OR Salesforce_Account_Name__r.ParentId IN: sfAccountIds ) AND External_ID_Source__c =: DRIVEDB'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries MDS Xrefs based on the passed Account Ids and Parent Work Order Ids.
     * @param accountIds
     * @param parentWorkOrderIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
        Set<Id> accountIds,
        Set<String> parentWorkOrderIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__r.Id')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Salesforce_Account_Name__r.Franchise_Parent__c')
            .selectField('Salesforce_Account_Name__r.ParentId')
            .selectField('Salesforce_Account_Name__r.Brand__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :accountIds AND External_ID_Source__c = :MDS AND ' +
                'Business_Reference__r.Created_Source_Parent_Work_Order_Id__c IN :parentWorkOrderIds'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying active Xrefs by matching the passed search key
     * with the External Id field.
     * Suppressed warnings since searchKeyMatcher variable is used to set the condition of dynamic SOQL.
     * @JIRA# LEM-3495
     * @param searchKey
     * @return List<Xref__c>
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Xref__c> selectBySearchKey(String searchKey) {
        String searchKeyMatcher = '%' + String.escapeSingleQuotes(searchKey) + '%';
        fflib_QueryFactory query = newQueryFactory()
            .selectField('External_ID__c')
            .selectField('Salesforce_Account_Name__c')
            .setCondition(
                'Xref_Status__c = :XREF_ACTIVE_STATUS AND ' +
                'External_ID__c LIKE :searchKeyMatcher'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying active Xrefs by matching the External Id's
     * @JIRA# LEM-4723
     * @param externalIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefByExternalId(List<String> externalIds) {
        // LEM-18563 - Bypassed CRUD check for this query only during Trigger execution.
        if (Trigger.isExecuting) {
            ignoreCRUD();
        }
        fflib_QueryFactory xrefQuery = newQueryFactory()
            .selectField('Business_Reference__r.Business_Name__c')
            .selectField('External_ID__c')
            .selectField('Salesforce_Account_Name__r.Account_ID18__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Salesforce_Account_Name__r.BillingStreet')
            .selectField('Salesforce_Account_Name__r.BillingCity')
            .selectField('Salesforce_Account_Name__r.BillingStateCode')
            .selectField('Salesforce_Account_Name__r.BillingCountryCode')
            .selectField('Salesforce_Account_Name__r.BillingPostalCode')
            .selectField('Salesforce_Account_Name__r.Hours_of_Operation__c')
            .selectField('Salesforce_Account_Name__r.Preferred_Language__c')
            .setCondition(
                'External_ID__c IN :externalIds AND Xref_Status__c = :XREF_ACTIVE_STATUS'
            );
        return (List<Xref__c>) Database.query(xrefQuery.toSOQL());
    }

    /**
     * @description It is used for querying active Xrefs by matching the External Ids
     * and the passed primary vertical.
     * @JIRA# LEM-24909
     * @param externalIds
     * @param primaryVertical
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefsByExternalIdsAndPrimaryVertical(
        List<String> externalIds,
        String primaryVertical
    ) {
        // LEM-18563 - Bypassed CRUD check for this query only during Trigger execution.
        if (Trigger.isExecuting) {
            ignoreCRUD();
        }
        fflib_QueryFactory xrefQuery = newQueryFactory(false)
            .selectField('Business_Reference__r.Business_Name__c')
            .selectField('External_ID__c')
            .selectField('Salesforce_Account_Name__r.Account_ID18__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Salesforce_Account_Name__r.BillingStreet')
            .selectField('Salesforce_Account_Name__r.BillingCity')
            .selectField('Salesforce_Account_Name__r.BillingStateCode')
            .selectField('Salesforce_Account_Name__r.BillingCountryCode')
            .selectField('Salesforce_Account_Name__r.BillingPostalCode')
            .selectField('Salesforce_Account_Name__r.Hours_of_Operation__c')
            .selectField('Salesforce_Account_Name__r.Preferred_Language__c')
            .selectField('Salesforce_Account_Name__c')
            .setCondition(
                'External_ID__c IN :externalIds AND External_ID_Source__c = :MDS ' +
                    'AND ((Salesforce_Account_Name__r.Primary_Vertical__c = :primaryVertical OR ' +
                    'Salesforce_Account_Name__r.Primary_Vertical__c = null) OR ' +
                    '((Salesforce_Account_Name__r.Primary_Vertical__c != :primaryVertical AND ' +
                    'Salesforce_Account_Name__r.Primary_Vertical__c != null) ' +
                    'AND Mastered_In_Figment__c = false))'
            );
        return (List<Xref__c>) Database.query(xrefQuery.toSOQL());
    }

    /**
     * @description It is used for querying Xrefs by matching the External Id's
     * @param externalIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefByExternalIdOnly(List<String> externalIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Salesforce_Account_Name__r.ParentId');
        query.selectField('Salesforce_Account_Name__r.Franchise_Parent__c');
        query.selectField('Salesforce_Account_Name__r.Parent.CurrencyIsoCode');
        query.selectField('Salesforce_Account_Name__r.Franchise_Parent__r.CurrencyIsoCode');
        query.selectField('Salesforce_Account_Name__r.Parent.Name');
        query.selectField('Salesforce_Account_Name__r.Franchise_Parent__r.Name');
        query.selectField('Business_Reference__r.Business_Name__c');
        query.setCondition('External_ID__c IN :externalIds');
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying active Xrefs by matching the business reference External Id's
     * @JIRA# LEM-4723
     * @param externalIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefByBusinessReferenceExternalId(List<String> externalIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Salesforce_Account_Name__r.Name');
        query.selectField('Salesforce_Account_Name__r.CurrencyIsoCode');
        query.selectField('Salesforce_Account_Name__r.Parent.Name');
        query.selectField('Salesforce_Account_Name__r.ParentId');
        query.selectField('Salesforce_Account_Name__r.Unique_Identifier__c');
        query.selectField('Salesforce_Account_Name__r.Parent.CurrencyIsoCode');
        query.selectField('Salesforce_Account_Name__r.Is_Additional_Store__c');
        query.setCondition(
            'Business_Reference__r.External_ID__c IN :externalIds AND Xref_Status__c = :XREF_ACTIVE_STATUS'
        );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting Xrefs based on Business Ids and Store Ids.
     * @JIRA# LEM-17497
     * @param externalIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefsByBusinessReferenceExternalIdOrStoreIds(
        Set<String> externalIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('External_ID__c')
            .selectField('Business_Reference__r.External_ID__c')
            .selectField('Salesforce_Account_Name__c.ParentId')
            .selectField('Salesforce_Account_Name__r.POS_Integration_ID__c')
            .setCondition(
                '(External_ID__c IN :externalIds OR Business_Reference__r.External_ID__c IN :externalIds) AND ' +
                    'Xref_Status__c = :XREF_ACTIVE_STATUS AND ' +
                    'Mastered_In_Figment__c = False'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Xrefs based on Mint store Id.
     * @param storeIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefsByStoreIds(Set<String> storeIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('External_ID__c')
            .selectField('Salesforce_Account_Name__c.ParentId')
            .selectField('Salesforce_Account_Name__r.POS_Integration_ID__c')
            .setCondition(
                'External_ID__c IN :storeIds AND ' +
                    'Xref_Status__c = :XREF_ACTIVE_STATUS AND ' +
                    'Mastered_In_Figment__c = False'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Xrefs based on record Id and Coo Process.
     * @param xrefIds
     * @param cooProcessSet
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefsByIdAndCooProcess(Set<Id> xrefIds, Set<String> cooProcessSet) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Coo_Process__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Salesforce_Account_Name__r.ParentId')
            .selectField('Salesforce_Account_Name__r.Parent.Name')
            .selectField('Salesforce_Account_Name__r.CurrencyIsoCode')
            .setCondition(
                'Id IN: xrefIds AND Coo_Process__c IN: cooProcessSet AND' +
                ' External_ID_Source__c =: MDS AND External_ID__c != null'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Xrefs based on record Id and Coo Process.
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectXrefsByCooProcess() {
        String queryCondition = '(Coo_Process__c =\'Process via Batch Mode\' OR Coo_Process__c = \'Failed\') AND External_ID_Source__c = \'MDS\' AND External_ID__c != null';
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Coo_Process__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Salesforce_Account_Name__r.ParentId')
            .selectField('Salesforce_Account_Name__r.Parent.Name')
            .selectField('Salesforce_Account_Name__r.CurrencyIsoCode')
            .setCondition(queryCondition);
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description It queries Active Xrefs associated with StoreAccountIDs.
     * @JIRA#LEM-7366
     * @param storeAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectActiveFailedXrefsBySalesforceAccountName(Set<Id> storeAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Reference__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Business_Reference__r.Last_Completed_Step__c')
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Default_Type__c')
            .selectField('External_ID_Source__c')
            .selectField('Integration_Status__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :storeAccountIds AND Xref_Status__c =: XREF_ACTIVE_STATUS' +
                    ' AND ((Business_Reference__c != null AND' +
                    ' Business_Reference__r.Integration_Status__c = :FAILURE) OR' +
                    ' (Integration_Status__c = :FAILURE OR' +
                    ' (Integration_Status__c = :WAITING_FOR_BUSINESS AND' +
                    ' Business_Reference__r.Integration_Status__c = :SUCCESS)))'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Xrefs based on Mint store Id.
     * @param storeIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectActiveMDSXrefsByStoreIds(Set<Id> storeIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Associated_Rate_Change_Request__c')
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Business_Reference__r.Name')
            .selectField('External_ID__c')
            .selectField('Figment_ID__c')
            .selectField('Salesforce_Account_Name__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .setCondition(
                'Salesforce_Account_Name__c IN :storeIds AND Xref_Status__c =: XREF_ACTIVE_STATUS AND ' +
                ' External_ID_Source__c =: MDS AND External_ID__c != null'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying count of 'DriveDb' Xrefs with Business Reference not having
     * External Id as the passed MP Bz Id using the passed salesforce Account Ids.
     * @JIRA# LEM-9551
     * @param salesforceAccountIds
     * @param mpBzIds
     * @return Aggregate[]
     */
    public Aggregate[] selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
        Set<Id> salesforceAccountIds,
        Set<String> mpBzIds
    ) {
        String xrefQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            QUERY_FILTER_CONDITION_STATUS_AND_EXTERNAL_ID_SOURCE +
            GROUP_BY_CLAUSE +
            SALESFORCE_ACCOUNT_NAME_FIELD +
            ORDER_BY_CLAUSE +
            SALESFORCE_ACCOUNT_NAME_FIELD;
        AggregateResult[] xrefAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(xrefQuery)
        );
        return Aggregate.convertResults(xrefAggregateCountQueryResult);
    }

    /**
     * @description It is used for querying 'DriveDb' Xrefs with Business Reference not having
     * External Id as the passed MP Bz Id using the passed salesforce Account Ids.
     * @JIRA# LEM-9551
     * @param salesforceAccountIds
     * @param mpBzIds
     * @param queryLimit
     * @return List<Xref__c>
     */
    public List<Xref__c> selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
        Set<Id> salesforceAccountIds,
        Set<String> mpBzIds,
        Integer queryLimit
    ) {
        fflib_QueryFactory xrefQuery = newQueryFactory()
            .setCondition(QUERY_FILTER_CONDITION_STATUS_AND_EXTERNAL_ID_SOURCE)
            .setLimit(queryLimit);
        return (List<Xref__c>) Database.query(xrefQuery.toSOQL());
    }

    /**
     * @description It is used for querying Xrefs with Store Accounts under the Account Hierarchy
     * @param storeIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectByStoreAccounts(Set<Id> storeIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Salesforce_Account_Name__r.Type')
            .selectField('Salesforce_Account_Name__r.RecordType.Name')
            .selectField('Salesforce_Account_Name__r.RecordType.DeveloperName')
            .selectField('Salesforce_Account_Name__r.Record_Type_Name__c')
            .selectField('Salesforce_Account_Name__r.Primary_Vertical__c')
            .selectField('Salesforce_Account_Name__r.Owner.Name')
            .selectField('Salesforce_Account_Name__r.Brand__r.Name')
            .selectField('Salesforce_Account_Name__r.ParentId')
            .setCondition(
                'Salesforce_Account_Name__r.ParentId IN :storeIds AND ' +
                    'Xref_Status__c = :XREF_ACTIVE_STATUS AND ' +
                    'Salesforce_Account_Name__r.Activation_Status__c = :XREF_ACTIVE_STATUS'
            )
            .setOrdering('Salesforce_Account_Name__r.Name', fflib_QueryFactory.SortOrder.ASCENDING)
            .addOrdering('External_ID_Source__c', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description
     * @param parentIds
     * @param filterCriteriaAndValues
     * @return List<Account>
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Xref__c> selectByStoreAccountsAndOtherFilters(
        Set<Id> parentIds,
        Map<String, List<String>> filterCriteriaAndValues
    ) {
        List<String> brands = filterCriteriaAndValues.get('brands');
        List<String> verticals = filterCriteriaAndValues.get('verticals');
        List<String> products = filterCriteriaAndValues.get('products');
        String filterCriteriaComplete = String.join(
            filterCriteriaAndValues.get('filterCriteria'),
            ' AND '
        );
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('Salesforce_Account_Name__r.Type')
            .selectField('Salesforce_Account_Name__r.RecordType.Name')
            .selectField('Salesforce_Account_Name__r.RecordType.DeveloperName')
            .selectField('Salesforce_Account_Name__r.Record_Type_Name__c')
            .selectField('Salesforce_Account_Name__r.Primary_Vertical__c')
            .selectField('Salesforce_Account_Name__r.Owner.Name')
            .selectField('Salesforce_Account_Name__r.Brand__r.Name')
            .selectField('Salesforce_Account_Name__r.ParentId')
            .setCondition(
                'Salesforce_Account_Name__r.ParentId IN :parentIds AND ' +
                    'Xref_Status__c = :XREF_ACTIVE_STATUS AND ' +
                    'Salesforce_Account_Name__r.Activation_Status__c = :XREF_ACTIVE_STATUS AND ' +
                    filterCriteriaComplete
            )
            .setOrdering('Salesforce_Account_Name__r.Name', fflib_QueryFactory.SortOrder.ASCENDING)
            .addOrdering('External_ID_Source__c', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Xrefs with Store Accounts related to the Ultimate
     * Parent Account for brand and vertical values.
     * @param ultimateParentAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectByUltimateParentAccountsForBrandsAndVerticals(
        Set<Id> ultimateParentAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Salesforce_Account_Name__r.Primary_Vertical__c')
            .selectField('Salesforce_Account_Name__r.Brand__r.Name')
            .setCondition(
                'Salesforce_Account_Name__r.Ultimate_Parent_Account__c IN :ultimateParentAccountIds ' +
                    'AND Xref_Status__c = :XREF_ACTIVE_STATUS AND ' +
                    'Salesforce_Account_Name__r.Activation_Status__c = :XREF_ACTIVE_STATUS'
            );
        //.setLimit(100);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for querying Xrefs related to the passed Rate Change Request Ids.
     * @param rcrIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectRelatedRateChangeIds(Set<Id> rcrIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Salesforce_Account_Name__r.Rate_Change_Request__c')
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Xref_Status__c')
            .selectField('Integration_Status__c')
            .selectField('Associated_Rate_Change_Request__c')
            .selectField('Business_Reference__r.Name')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .setCondition('Salesforce_Account_Name__r.Rate_Change_Request__c IN: rcrIds');
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Drive Xrefs based on Salesforce Account Name and Integration Status
     * @JIRA#LEM-12654
     * @param accIds
     * @param woCreatedDate
     * @param userIds
     * @param xrefWrapper
     * @return List<Xref__c>
     */
    public List<Xref__c> selectDriveDbXrefsByAccountAndIntegrationStatus(
        Set<Id> accIds,
        DateTime woCreatedDate,
        List<String> userIds,
        NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper xrefWrapper
    ) {
        Set<String> allxrefFieldSet = new Set<String>();
        Set<String> alllookUpXref = new Set<String>();
        Set<String> excludeEntity = new Set<String>();
        allxrefFieldSet = xrefWrapper.allxrefFieldSet;
        alllookUpXref = xrefWrapper.alllookUpXref;
        excludeEntity = xrefWrapper.excludeEntity;
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Salesforce_Account_Name__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('External_ID__c')
            .selectField('MINT_Store_Page__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :accIds AND External_ID_Source__c =: DRIVEDB AND Integration_Status__c =: SUCCESS'
            );
        new XrefsHistorySelector()
            .addQueryFactorySubselect(query, 'Histories')
            .selectField('Id')
            .selectField('Field')
            .selectField('OldValue')
            .selectField('NewValue')
            .selectField('CreatedDate')
            .selectField('ParentId')
            .selectField('Parent.Salesforce_Account_Name__c')
            .selectField('DataType')
            .setCondition(
                '(Field IN : allxrefFieldSet OR (FIELD IN : alllookUpXref)) AND ( DATATYPE !=: TEXT OR Field !=: excludeEntity) AND CreatedById IN :UserIds AND CreatedDate >= :woCreatedDate'
            );
        return Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting MDS Xrefs based on Salesforce Account Name and Integration Status
     * @JIRA#LEM-12654
     * @param accIds
     * @param woCreatedDate
     * @param userIds
     * @param xrefWrapper
     * @return List<Xref__c>
     */
    public List<Xref__c> selectMDSXrefsByAccountAndIntegrationStatus(
        Set<Id> accIds,
        DateTime woCreatedDate,
        List<String> userIds,
        NonContractualUpdatesWorkOrderMINTCtrl.XrefHistoryFilterWrapper xrefWrapper
    ) {
        Set<String> allxrefFieldSet = new Set<String>();
        Set<String> alllookUpXref = new Set<String>();
        Set<String> excludeEntity = new Set<String>();
        allxrefFieldSet = xrefWrapper.allxrefFieldSet;
        alllookUpXref = xrefWrapper.alllookUpXref;
        excludeEntity = xrefWrapper.excludeEntity;
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Salesforce_Account_Name__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .selectField('External_ID__c')
            .selectField('MINT_Store_Page__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :accIds AND External_ID_Source__c =: MDS AND Integration_Status__c =: SUCCESS'
            );
        new XrefsHistorySelector()
            .addQueryFactorySubselect(query, 'Histories')
            .selectField('Id')
            .selectField('Field')
            .selectField('OldValue')
            .selectField('NewValue')
            .selectField('CreatedDate')
            .selectField('ParentId')
            .selectField('Parent.Salesforce_Account_Name__c')
            .selectField('DataType')
            .setCondition(
                '(Field IN : allxrefFieldSet OR (FIELD IN : alllookUpXref)) AND ( DataType !=: TEXT OR Field !=: excludeEntity) AND CreatedById IN :UserIds AND CreatedDate >= :woCreatedDate'
            );
        return Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Xref details by store Id & business Id
     * @param storeId
     * @param businessId
     * @return List<Xref__c>
     */
    public List<Xref__c> selectByStoreIdAndBusinessId(string storeId, string businessId) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Salesforce_Account_Name__r.MDS_Last_Synced__c')
            .selectField('Salesforce_Account_Name__r.Order_Protocol__c')
            .selectField('Salesforce_Account_Name__r.Franchise_Parent__c')
            .selectField('MDS_Last_Synced__c')
            .setCondition(
                'External_Id__c = :storeId AND Business_Reference__r.External_Id__c = :businessId'
            )
            .setOrdering('xref_status__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Xrefs with Store Accounts related to the Ultimate
     * Parent Account for brand and vertical values.
     * @param ultimateParentAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectByUltimateParentAccountsforActivationValidation(
        Set<Id> ultimateParentAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('BusinessID__c')
            .selectField('Salesforce_Account_ID__c')
            .setCondition(
                'Salesforce_Account_ID__c IN :ultimateParentAccountIds AND External_ID_Source__c = :MDS' +
                ' AND Xref_Status__c = :XREF_ACTIVE_STATUS AND Integration_Status__c = :SUCCESS'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        //.setLimit(100);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Xrefs by matching the External Ids and External Id Source as MDS
     * @param externalIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectXrefByExternalIdsAndExternalSourceMDS(Set<String> externalIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('External_ID__c IN :externalIds AND External_ID_Source__c = :MDS');
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Active Xrefs by matching the External Ids and External Id Source as MDS
     * @param externalIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectActiveXrefByExternalIdsAndExternalSourceMDSAndStoreRecordType(
        Set<String> externalIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Salesforce_Account_Name__c');
        query.selectField('Salesforce_Account_Name__r.Order_Protocol__c');
        query.selectField('Salesforce_Account_Name__r.Mx_Onboarding_Link_Id__c');
        query.selectField('Salesforce_Account_Name__r.Activated_Centrally_AC__c');
        query.selectField('Salesforce_Account_Name__r.Menu_Setup_Method__c');
        query.selectField('Salesforce_Account_Name__r.Menu_to_be_Completed_By__c');
        query.selectField('Salesforce_Account_Name__r.Sales_Notes_for_Menu_Team__c');
        query.selectField('Salesforce_Account_Name__r.Unique_Identifier__c');
        query.selectField('Salesforce_Account_Name__r.POS_Integration_Type__c');
        query.setCondition(
            'External_ID__c IN :externalIds AND External_ID_Source__c = :MDS AND Xref_Status__c = :XREF_ACTIVE_STATUS AND Account_Record_Type__c=:STORE'
        );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Xrefs with Account and Business Reference having brands.
     * @param accountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Salesforce_Account_Name__r.Brand__c')
            .selectField('Business_Reference__r.Brand__c')
            .selectField('Business_Reference__c')
            .selectField('Salesforce_Account_Name__c')
            .setCondition(
                'Salesforce_Account_Name__c IN :accountIds AND Business_Reference__c != null AND Salesforce_Account_Name__r.Brand__c != null'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description
     * @author Pankaj | 09-09-2024
     * @param businessId
     * @param businessVertical
     * @param currencyCodes
     * @return List<Xref__c>
     **/
    public List<Xref__c> selectByBusinessAccountId(
        Set<String> businessId,
        Set<String> businessVertical,
        Set<String> currencyCodes
    ) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Business_Reference__c')
            .selectField('Business_Reference__r.Id')
            .selectField('Business_Reference__r.External_Id__c')
            .setCondition(
                'Salesforce_Account_Name__r.ParentId IN: businessId' +
                    ' AND Business_Reference__r.Business_Vertical__r.Name IN : businessVertical AND Business_Reference__r.CurrencyIsoCode IN: currencyCodes' +
                    ' AND Business_Reference__r.External_Id_Source__c =: MDS AND Business_Reference__r.Default_Type__c =: CORPORATE '
            )
            .setLimit(1);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries 'MDS' Xrefs (both, Active & Inactive) based on the passed Salesforce Account's Ids.
     * @param salesforceAccountIds
     * @return List<Xref__c>
     */
    public List<Xref__c> selectMDSXrefsBySalesforceAccountIds(Set<Id> salesforceAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Associated_Rate_Change_Request__c')
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Business_Reference__r.Name')
            .selectField('External_ID__c')
            .selectField('Figment_ID__c')
            .selectField('Salesforce_Account_Name__c')
            .selectField('Salesforce_Account_Name__r.Name')
            .setCondition(
                'Salesforce_Account_Name__c IN :salesforceAccountIds AND ' +
                'External_ID_Source__c =: MDS AND External_ID__c != null'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Xref__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves a list of Xref records based on the provided business reference IDs.
     * @param businessReferenceIds The list of business reference IDs.
     * @return List<Xref__c> The list of Xref records.
     */
    public List<Xref__c> selectActiveXrefByBusinessReferenceId(Set<Id> businessReferenceIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Salesforce_Account_Name__r')
            .selectField('Business_Reference__c')
            .setCondition(
                'Business_Reference__c IN :businessReferenceIds AND Xref_Status__c = :ACTIVE'
            );
        return (List<Xref__c>) Database.query(query.toSOQL());
    }
}