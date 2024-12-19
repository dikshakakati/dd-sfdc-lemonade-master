/**
 * @author Deloitte
 * @date 10/12/2022
 * @description Interface to add Payment Account domain class methods
 */
public interface IPaymentAccounts extends fflib_ISObjects {
    /**
     * @description This method is used for populating the currency from the Business Account tied to Payment Account
     * @JIRA# LEM-3121
     */
    void populateCurrencyByBusinessAccount();

    /**
     * @description This method is used to auto-sync Invoice Payment Account with NetSuite.
     */
    void syncWithNetSuite();
    /**
     * @description It is used to update default Entity type as 'Company' for Payment Record type, if not present.
     */
    void setEntityTypeForPaymentsRecordType();

}