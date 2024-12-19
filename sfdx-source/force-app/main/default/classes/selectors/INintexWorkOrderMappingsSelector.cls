/**
 * @author Deloitte
 * @date 08/18/2022
 * @description Interface for Nintex_Work_Order_Mapping__mdt custom metadata selector.
 */
public interface INintexWorkOrderMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch all "Nintex Use Case To Work Order Mapping"
     * custom metadata records.
     * @return List<Nintex_Work_Order_Mapping__mdt>
     */
    List<Nintex_Work_Order_Mapping__mdt> getAllMappings();
}