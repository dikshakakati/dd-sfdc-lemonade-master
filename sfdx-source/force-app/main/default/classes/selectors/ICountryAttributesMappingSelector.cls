/**
 * @author Deloitte
 * @date 04/14/2022
 * @description Interface to add Selector class methods
 */
public interface ICountryAttributesMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Country Attributes Mapping records
     * @return List<Country_Attributes_Mapping__mdt> - returns list of metadata records
     */
    List<Country_Attributes_Mapping__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Country_Attributes_Mapping__mdt
     * @return List<Schema.SObjectField>- Country_Attributes_Mapping__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}