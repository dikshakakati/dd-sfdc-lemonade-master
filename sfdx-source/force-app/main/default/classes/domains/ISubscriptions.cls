/**
 * @author Deloitte
 * @date 17/05/2022
 * @description Interface to add domain class methods
 */
public interface ISubscriptions extends fflib_ISObjects {
    /**
     * @description To call contract service when subscription
     * is inserted
     * @JIRA# LEM-6861
     */
    void callContractServiceToUpdateContractName();

    /**
     * @description Updates Quote line Group Fields on Subscriptions
     */
    void populateQuoteLineGroup();

    /**
     * @description It validates Subscription fields and for SSMO/SSOB Work Order Creation.
     * @JIRA# LEM-15362
     */
    void evaluateAndInitalizeForWorkOrderCreation();
    /**
     * @description It is used to update Subscription's Product Family on Contract.
     * @JIRA# LEM-24915
     */
    void updateContractWithSubscritionProductFamily();
}