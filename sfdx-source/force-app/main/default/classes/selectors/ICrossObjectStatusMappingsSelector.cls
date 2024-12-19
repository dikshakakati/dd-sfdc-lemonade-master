/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Interface to add Selector class methods
 */
public interface ICrossObjectStatusMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch the Cross Object Status Mapping records with the
     * passed Process Name.
     * @param processName
     * @return List<Cross_Object_Status_Mapping__mdt>
     */
    List<Cross_Object_Status_Mapping__mdt> selectActiveStatusMappingsByProcessName(
        String processName
    );
}