/**
 * @author Deloitte
 * @date 15/07/2022
 * @description Selector class for Payment Account object.
 */
public inherited sharing class PaymentAccountsSelector extends fflib_SObjectSelector implements IPaymentAccountsSelector, IEncryptedDataSelector {
    private static final Id INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Invoice')
        .getRecordTypeId();
    /**
     * @description Default constructor for the PaymentAccountsSelector selector class.
     * @return IPaymentAccountsSelector - instance of IPaymentAccountsSelector
     */
    public static IPaymentAccountsSelector newInstance() {
        return (IPaymentAccountsSelector) Application.Selector.newInstance(
            Payment_Account__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields of Payment_Account__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Payment_Account__c.Id,
            Payment_Account__c.Billing_Contact_Name__c,
            Payment_Account__c.Payment_Terms__c,
            Payment_Account__c.NetSuite_ID__c,
            Payment_Account__c.recordTypeId,
            Payment_Account__c.Bank_Account_Number__c,
            Payment_Account__c.Billing_Contact_Email__c,
            Payment_Account__c.Bill_To_Company_Name__c,
            Payment_Account__c.Country_Code_Alpha_2__c,
            Payment_Account__c.Address_Line_1__c,
            Payment_Account__c.State__c,
            Payment_Account__c.Country__c,
            Payment_Account__c.City__c,
            Payment_Account__c.Postal_Code__c,
            Payment_Account__c.Currency__c,
            Payment_Account__c.CurrencyIsoCode,
            Payment_Account__c.DoorDash_Legal_Entity__c,
            Payment_Account__c.Institution_Number__c,
            Payment_Account__c.NetSuite_Sync_Status__c,
            Payment_Account__c.Netsuite_Sync_Initiator__c,
            Payment_Account__c.NetSuite_Sync_Response__c,
            Payment_Account__c.Business_Unit__c,
            Payment_Account__c.RoutingNumber__c,
            Payment_Account__c.Name
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Payment_Account__c.SObjectType;
    }

    /**
     * @description It is used for getting Payment Accounts by the passed Ids.
     * @param paymentAccountIds
     * @return List<Payment_Account__c>
     */
    public List<Payment_Account__c> selectById(Set<Id> paymentAccountIds) {
        return (List<Payment_Account__c>) selectSObjectsById(paymentAccountIds);
    }

    /**
     * @description It is used to get the encrypted data stored in the passed fields
     * by the passed sObjectIds.
     * @JIRA# LEM-2255
     * @param fieldSet
     * @param sobjectIds
     * @return List<SObject>
     */
    public List<SObject> selectEncryptedData(Schema.FieldSet fieldSet, Set<Id> sobjectIds) {
        fflib_QueryFactory paymentAccountQuery = newQueryFactory()
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :sobjectIds');
        return (List<Payment_Account__c>) Database.query(paymentAccountQuery.toSOQL());
    }
    /**
     * @description Return Payment Account record by Id for Netsuite integration
     * @param paymentAccountId
     * @return List<Payment_Account__c>
     */
    public Payment_Account__c selectPaymentAccountByIdForNetsuiteIntegration(Id paymentAccountId) {
        fflib_QueryFactory paymentAccountQuery = newQueryFactory(false);
        for (
            OAuth_Config__c config : OAuth1ConfigsSelector.newInstance()
                .getNetsuiteIntegrationDatamap()
        ) {
            paymentAccountQuery.selectField(config.Key__c);
        }
        paymentAccountQuery.setCondition('Id = :paymentAccountId');
        paymentAccountQuery.setLimit(1);
        return (Payment_Account__c) Database.query(paymentAccountQuery.toSOQL());
    }

    /**
     * @description It is used to get the related business accounts of the payment accounts
     * @JIRA# LEM-3121
     * @param accountIds
     * @return List<Payment_Account__c>
     */
    public List<Payment_Account__c> selectRelatedBusinessAccounts(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Business_Account__c')
            .selectField('Business_Account__r.CurrencyIsoCode')
            .setCondition(
                'Business_Account__r.Id IN : accountIds AND RecordtypeId = :INVOICE_RECORD_TYPE_ID'
            );
        return (List<Payment_Account__c>) Database.query(query.toSOQL());
    }

    /**
     * @description  It queries Payment Accounts with 'Invoice' record type by passed list of Payment Account Ids
     * @JIRA# LEM-10203
     * @param paymentAccountIds
     * @return List<Payment_Account__c>
     */
    public List<Payment_Account__c> selectInvoicePaymentAccountsByIds(Set<Id> paymentAccountIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .setCondition('RecordtypeId = :INVOICE_RECORD_TYPE_ID AND Id IN :paymentAccountIds');

        return (List<Payment_Account__c>) Database.query(query.toSOQL());
    }
}