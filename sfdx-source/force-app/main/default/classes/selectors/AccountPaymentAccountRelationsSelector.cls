/**
 * @author Deloitte
 * @date 10/07/2022
 * @description Selector class for Account_Payment_Account_Relation__c object.
 */
public inherited sharing class AccountPaymentAccountRelationsSelector extends fflib_SObjectSelector implements IAccountPaymentAccountRelationsSelector {
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = ' COUNT(Id) accountPaymentAccountRelationsCount, Payment_Account__c paymentAccountId, Account__r.BillingCountryCode accountBillingCountryCode';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY';
    private static final String GROUP_BY_FIELDS = ' Payment_Account__c,Account__r.BillingCountryCode';
    private static final String SELECT_CLAUSE = 'SELECT';
    private static final String WHERE_CLAUSE = ' FROM Account_Payment_Account_Relation__c WHERE';
    private static final String QUERY_FILTER_CONDITION = ' Payment_Account__c IN :paymentAccountIds';

    /**
     * @description Default constructor for the AccountPaymentAccountRelations selector class.
     * @return IAccountPaymentAccountRelationsSelector - instance of IAccountPaymentAccountRelationsSelector
     */
    public static IAccountPaymentAccountRelationsSelector newInstance() {
        return (IAccountPaymentAccountRelationsSelector) Application.Selector.newInstance(
            Account_Payment_Account_Relation__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields of Account_Payment_Account_Relation__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Payment_Account_Relation__c.Id,
            Account_Payment_Account_Relation__c.Account__c,
            Account_Payment_Account_Relation__c.Payment_Account__c,
            Account_Payment_Account_Relation__c.Payment_Terms__c
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Account_Payment_Account_Relation__c.SObjectType;
    }

    /**
     * @description select account to payment account relation
     * @param accountToPaymentRelationIds
     * @return List<Account_Payment_Account_Relation__c>
     */
    public List<Account_Payment_Account_Relation__c> selectById(
        Set<Id> accountToPaymentRelationIds
    ) {
        return (List<Account_Payment_Account_Relation__c>) Database.query(
            newQueryFactory()
                .selectField('Payment_Account__r.Payment_Terms__c')
                .setCondition('Id IN :accountToPaymentRelationIds')
                .toSOQL()
        );
    }

    /**
     * @description It queries Account To Payment Account Relations associated with the passed
     * Account Ids and Payment Account Record Types.
     * @param accountIds
     * @param paymentAccountRecordTypes
     * @return List<Account_Payment_Account_Relation__c>
     */
    public List<Account_Payment_Account_Relation__c> selectByAccountIdsAndPaymentAccountRecordTypes(
        Set<Id> accountIds,
        Set<String> paymentAccountRecordTypes
    ) {
        /* It allows running store readiness check on Payment Accounts and
         * and related Account & Contact relations associated with store Accounts of
         * child Work Orders. Store readiness can be run by any user which may not have access to
         * the objects used in the query.
         * Store readiness check runs in the background and does not expose any
         * encrypted/confidential data on UI.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        return (List<Account_Payment_Account_Relation__c>) Database.query(
            newQueryFactory()
                .selectField('Account__c')
                .selectField('Payment_Account__r.Billing_Contact_Name__c')
                .selectField('Payment_Account__r.Billing_Contact_Name__r.BirthDate')
                .selectField('Payment_Account__r.Billing_Contact_Name__r.SSN_Last_4Digits__c')
                .selectField('Payment_Account__r.Institution_Number__c')
                .selectField('Payment_Account__r.RecordTypeId')
                .selectField('Payment_Account__r.NetSuite_ID__c')
                .selectField('Record_Type__c')
                .setCondition(
                    'Account__c IN :accountIds AND Record_Type__c IN :paymentAccountRecordTypes'
                )
                .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
     * @description It is used to select the aggregate count of account to payment account relations
     * with account's billing country code by the passed payment account ids.
     * @JIRA# LEM-10692
     * @param paymentAccountIds
     * @return Aggregate[]
     */
    public Aggregate[] selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
        Set<Id> paymentAccountIds
    ) {
        String accountPaymentAccountRelationsQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            GROUP_BY_FIELDS;
        AggregateResult[] accountPaymentAccountRelationsQueryAggregateResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(accountPaymentAccountRelationsQuery)
        );
        return Aggregate.convertResults(accountPaymentAccountRelationsQueryAggregateResult);
    }
}