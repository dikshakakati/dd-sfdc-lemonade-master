/**
 * @author Deloitte
 * @date 10/12/2022
 * @description Payment Account Object Trigger Handler
 */
public class PaymentAccountsHandler extends ApplicationDomainHandler {
    private static final Id INVOICE_RECORD_TYPE_ID;
    static {
        INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Invoice')
            .getRecordTypeId();
    }
    private static final String PERMIT_NETSUITE_SYNC = System.Label.AUTOMATED_SYNC_WITH_NETSUITE;

    /**
     * @description constructor method
     * @param sObjectList - Payment Account record list
     */
    public PaymentAccountsHandler(List<Payment_Account__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Payment_Account__c.SObjectType, PaymentAccountsHandler.class);
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        PaymentAccounts.newInstance(paymentAccountsWithUpdatedBusinessAccount())
            .populateCurrencyByBusinessAccount();
        PaymentAccounts.newInstance(
                new List<Payment_Account__c>(
                    (List<Payment_Account__c>) getChangedRecords(
                        new Set<SObjectField>{Payment_Account__c.Entity_Type__c}
                    )
                )
            )
            .setEntityTypeForPaymentsRecordType();

        PaymentAccountFieldsValidations.validatePaymentAccountFields(
            new List<Payment_Account__c>(
                (List<Payment_Account__c>) getRecords()
            )
        );
    }

    /**
     * @description Called to perform before update processing
     */
    public override void onBeforeInsert() {
        PaymentAccounts.newInstance(this.records).populateCurrencyByBusinessAccount();
        PaymentAccounts.newInstance(this.records).setEntityTypeForPaymentsRecordType();
    }

    /**
     * @description Called to perform before update processing
     */
    public override void onAfterInsert() {
        if (FeatureManagementService.newInstance().checkPermission(PERMIT_NETSUITE_SYNC)) {
            PaymentAccounts.newInstance(this.records).syncWithNetSuite();
        }
    }

    /**
     * @description Called to get the records with updated business accounts
     * @JIRA# LEM-3121
     * @return List<Payment_Account__c>
     */
    public List<Payment_Account__c> paymentAccountsWithUpdatedBusinessAccount() {
        List<Payment_Account__c> changedRecords = new List<Payment_Account__c>(
            (List<Payment_Account__c>) getChangedRecords(
                new Set<SobjectField>{
                    Payment_Account__c.Business_Account__c,
                    Payment_Account__c.Is_Parent_Account_Merged__c,
                    Payment_Account__c.DoorDash_Legal_Entity__c
                }
            )
        );
        return changedRecords;
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return PaymentAccountsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new PaymentAccountsHandler(sObjectList);
        }
    }
}