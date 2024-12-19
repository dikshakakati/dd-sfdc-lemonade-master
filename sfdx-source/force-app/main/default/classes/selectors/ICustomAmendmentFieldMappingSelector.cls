/**
 * @author Aethereus
 * @date 29/05/2024
 * @description Interface for Custom_Amendment_Field_Mapping__mdt  custom metadata selector.
 */
public interface ICustomAmendmentFieldMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description override default object type method
     * @return object type metadata
     */
    Schema.SObjectType getSObjectType();

    /**
     * @description Method that retrieves the field value mappings from the mdt
     * @return List<Schema.SObjectField> getSObjectFieldList()
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description It is used for getting all active Custom_Amendment_Field_Mapping__mdt  records
     * @return List<Custom_Amendment_Field_Mapping__mdt >
     */
    List<Custom_Amendment_Field_Mapping__mdt> selectAllCustomAmendmentFieldsMapping();

    /**
     * @description It is used for getting all active Custom_Amendment_Field_Mapping__mdt records whose Source is 'Contract'.
     * @param source
     * @param target
     * @return List<Custom_Amendment_Field_Mapping__mdt>
     */
    List<Custom_Amendment_Field_Mapping__mdt> selectMappingsBySourceObjectAndTargetObject(String source, String target);

}