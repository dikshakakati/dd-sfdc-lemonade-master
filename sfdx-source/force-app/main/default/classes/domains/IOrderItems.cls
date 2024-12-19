/**
 * @author Deloitte
 * @date 2023-08-21
 * @description Interface to add domain class methods
 */
public interface IOrderItems extends fflib_ISObjects {
    /**
     * @description Updates Quote line Group Fields on order item.
     */
    void populateQuoteLineGroup();

    /**
     * @description It is used to update orders based on the OrderType by OrderIds.
     */
    void updateOrderByOrderItemSplitCategory();

    /**
     * @description It is used to default the order item fields.
     */
    void defaultOrderItemFields();
}