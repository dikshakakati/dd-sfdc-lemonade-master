/**
 * @author Deloitte
 * @date 10/26/2023
 * @description Account to Payment Account Relations Trigger handler class.
 */
public class AccountPaymentAccountRelationsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate AccountPaymentAccountRelationsHandler.
     * @param sObjectLists
     */
    public AccountPaymentAccountRelationsHandler(
        List<Account_Payment_Account_Relation__c> sObjectLists
    ) {
        super(sObjectLists);
        setContextBypass(
            Account_Payment_Account_Relation__c.SobjectType,
            AccountPaymentAccountRelationsHandler.class
        );
    }

    /**
     * @description Called to perform before insert processing.
     */
    public override void onBeforeInsert() {
        PaymentAccountFieldsValidations.validateAccountToPaymentAccountRelation(
            (List<Account_Payment_Account_Relation__c>) this.records
        );
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain.IConstructable class.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectLists
         * @return AccountPaymentAccountRelationsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectLists) {
            return new AccountPaymentAccountRelationsHandler(sObjectLists);
        }
    }
}