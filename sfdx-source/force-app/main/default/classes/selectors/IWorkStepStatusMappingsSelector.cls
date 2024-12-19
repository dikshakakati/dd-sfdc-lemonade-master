/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Interface to add selector class methods.
 */
public interface IWorkStepStatusMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It fetches all records of Work Step Status Mapping metadata.
     * @return List<Work_Step_Status_Mapping__mdt> - Returns list of metadata records
     */
    List<Work_Step_Status_Mapping__mdt> getAllValues();

    /**
     * @description It is for getting the fields of Work_Step_Status_Mapping__mdt.
     * @return List<Schema.SObjectField> - Returns Work_Step_Status_Mapping__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}