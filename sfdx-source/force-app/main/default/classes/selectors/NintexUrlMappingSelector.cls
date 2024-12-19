/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Selector class for Nintex_URL_Mapping__mdt custom metadata
 */
public inherited sharing class NintexUrlMappingSelector extends fflib_SObjectSelector implements INintexUrlMappingSelector {
    /**
     * @description default constructor for the class
     * @return INintexUrlMappingSelector - interface of INintexUrlMappingSelector
     */
    public static INintexUrlMappingSelector newInstance() {
        return (INintexUrlMappingSelector) Application.Selector.newInstance(
            Nintex_URL_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Nintex_URL_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Nintex_URL_Mapping__mdt
     * @return List<Schema.SObjectField>- Nintex_URL_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Nintex_URL_Mapping__mdt.MasterLabel,
            Nintex_URL_Mapping__mdt.URL__c,
            Nintex_URL_Mapping__mdt.DeveloperName
        };
    }

    /**
     * @description This method is for getting all field values for Nintex_URL_Mapping__mdt
     * @return List<Nintex_URL_Mapping__mdt> - List of metadata records with values
     */
    public List<Nintex_URL_Mapping__mdt> getAllValues() {
        return Nintex_URL_Mapping__mdt.getall().values();
    }
}