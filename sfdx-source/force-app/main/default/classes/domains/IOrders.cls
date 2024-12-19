/**
 * @author ATG
 * @date 2022-04-05
 * @description Interface to add domain class methods
 */
public interface IOrders extends fflib_ISObjects {
    /**
     * @description set Order as ready for activation
     */
    void setReadyForActivation();

    /**
     * @description set Order as Status = 'Activated'
     */
    void setActive();

    /**
     * @description set Order as SBQQ__Contracted__c = true
     */
    void setContracted();

    /**
     * @description if an order is migrated,set the start date to the related quote's start date
     */
    void updateEffectiveDateForMigratedOrders();
    /**
     * @description It is used to set Order Status as 'Activated' for 'Activation Orders' for Order Type as 'A&P'.
     */
    void setStatusForActivationOrder();
}