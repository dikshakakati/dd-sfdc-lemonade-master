/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Interface to add Selector class methods.
 */
public interface IOIAttributesConfigsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is for getting the fields on OIAttributesConfig__mdt.
     * @return List<Schema.SObjectField> - OIAttributesConfig__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}