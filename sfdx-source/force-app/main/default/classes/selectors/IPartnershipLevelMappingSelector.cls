/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Interface to add selector class methods
 */
public interface IPartnershipLevelMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all metadata records
     * @return List<Partnership_Level_Mapping__mdt > - returns list of metadata records
     */
    List<Partnership_Level_Mapping__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Partnership_Level_Mapping__mdt
     * @return List<Schema.SObjectField>- Partnership_Level_Mapping__mdt  fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}