/**
 * @author Doordash
 * @date 03/14/2024
 * @description Interface to add Selector class methods for MDS_Sync_Mapping__mdt object
 */
public interface IOrderProtocolMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for retrieveing MDS_Sync_Mapping__mdt object active records
     * @return List of Order_Protocol_Mapping__mdt records
     */
    List<Order_Protocol_Mapping__mdt> getActiveOrderProtocolMappings();
}