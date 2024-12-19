/**
 * @author DoorDash
 * @date 08-Aug-2023
 * @description Selector interface for the Data_Transfer_Mapping__mdt custom metadata
**/
public interface IDataTransferMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It fetches all records of Data Transfer Mapping metadata.
     * @return List<Data_Transfer_Mapping__mdt> - Returns list of metadata records
     */
    List<Data_Transfer_Mapping__mdt> getAllValues();
    /**
     * @description It fetches all Active records of Data Transfer Mapping metadata.
     * @return List<Data_Transfer_Mapping__mdt> - Returns list of metadata records
     */
    List<Data_Transfer_Mapping__mdt> getAllActiveValues();
}