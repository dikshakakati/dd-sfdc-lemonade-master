/**
 * @author Doordash
 * @date 09/27/2023
 * @description Interface to add Selector class methods for Business_Friendly_Mapping__mdt object
 */
public interface IBusinessFriendlyMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for retrieveing IBusinessFriendlyMappingSelector object records by Integration Type
     * @param integrationType
     * @return List of BusinessFriendlyMappingSelector records
     */
    List<Business_Friendly_Mapping__mdt> selectByIntegrationType(string integrationType);
}