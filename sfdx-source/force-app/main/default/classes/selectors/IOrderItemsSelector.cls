/**
 * @author atg
 * @date 05/25/2022
 * @description Interface to add OrderItemsSelector class methods
 */
public interface IOrderItemsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return List<OrderItem> - Orders Items List
     */
    List<OrderItem> selectById(Set<Id> idSet);

    /**
     * @description It is used for getting Account and Contract Ids linked to Order Products
     * associated to Primary Orders based on the passed Order Product Ids.
     * @param orderItemIds
     * @return Aggregate[]
     */
    Aggregate[] selectByIdsGroupedByAccountContractIds(Set<Id> orderItemIds);

    /**
     * @description This method is used for getting OrderItems based on Id, and returning all fields in the fieldset.
     * @param fieldSet - name of the field set to read the fields from
     * @param setIds - Set of Ids
     * @return List of OrderItem
     */
    List<OrderItem> selectOrderItemFieldSetById(Schema.FieldSet fieldSet, Set<Id> setIds);

    /**
     * @description It is used for getting activated OrderItems based on passed Ids.
     * @param orderItemIds
     * @param isManagePricingProcess
     * @return List<OrderItem>
     */
    List<OrderItem> selectActivatedOrderItemsById(
        Set<Id> orderItemIds,
        Boolean isManagePricingProcess
    );

    /**
     * @description It is used for getting OrderItems where Product is either Alcohol
     * Pickup or Delivery by the passed Account Ids.
     * @param accountIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectAlcoholDeliveryOrPickupOrderItemsByAccountIds(Set<Id> accountIds);

    /**
     * @description It is used for getting activated OrderItems with Product BackEnd Systems
     *                  based on passed Ids.
     * @param orderItemIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectProductBackEndByOrderItemIds(Set<Id> orderItemIds);

    /**
     * @description It is used for getting activated Order Products along with Primary Order Product
     * details based on passed Account Ids and productTypes.
     * @param storeAccountIds
     * @param productTypes
     * @return List<OrderItem>
     */
    List<OrderItem> selectActivatedOrderItemsByAccountIdsAndProductTypes(
        Set<Id> storeAccountIds,
        Set<String> productTypes
    );

    /**
     * @description It is used for getting activated Order Products along with Primary Order Product
     * details based on passed Account Ids.
     * @param storeAccountIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectActivatedOrderItemsByAccountIds(Set<Id> storeAccountIds);

    /**
     * @description It is used for getting Order Products by the passed Order Ids
     * where 'Work Order Type' is populated on the associated product.
     * @param orderIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(Set<Id> orderIds);

    /**
     * @description It is used for getting Primary Order Products by the passed Order Ids
     * @param orderItemIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectPrimaryOrderItemsByIds(Set<Id> orderItemIds);

    /**
     * @description It is used for getting Order Products by the passed Order Ids
     * where order type is primary order
     * @param orderItemIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectOrderItemsWithPrimaryOrderFields(Set<Id> orderItemIds);

    /**
     * @description It is used for getting Order Items for Amendments by the passed Order Ids.
     * @param orderItemIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectAmendedOrderItems(Set<Id> orderItemIds);

    /**
     * @description It is used for querying Order Items for the passed Order Ids.
     * @param orderIds
     * @return List<OrderItem>
     */
    List<OrderItem> selectOrderItemsByOrderIds(Set<Id> orderIds);
}
