/**
 * @author Deloitte
 * @date 05/24/2022
 * @description Interface to add selector class methods
 */
public interface ILegalEntityMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all metadata records
     * @return List<Legal_Entity_Mapping__mdt> - returns list of metadata records
     */
    List<Legal_Entity_Mapping__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Legal_Entity_Mapping__mdt
     * @return List<Schema.SObjectField>- Legal_Entity_Mapping__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}