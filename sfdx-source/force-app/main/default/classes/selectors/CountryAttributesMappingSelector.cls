/**
 * @author Deloitte
 * @date 04/14/2022
 * @description Selector Class for CountryAttributesMapping custom metadata
 */
public inherited sharing class CountryAttributesMappingSelector extends fflib_SObjectSelector implements ICountryAttributesMappingSelector {
    /**
     * @description default constructor for the class
     * @return ICountryAttributesMappingSelector - interface of ICountryAttributesMapping
     */
    public static ICountryAttributesMappingSelector newInstance() {
        return (ICountryAttributesMappingSelector) Application.Selector.newInstance(
            Country_Attributes_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Country_Attributes_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting all field values for Country_Attributes_Mapping__mdt
     * @return List<Country_Attributes_Mapping__mdt> - List of metadata records with values
     */
    public List<Country_Attributes_Mapping__mdt> getAllValues() {
        return Country_Attributes_Mapping__mdt.getall().values();
    }

    /**
     * @description This method is for getting the fields on Country_Attributes_Mapping__mdt
     * @return List<Schema.SObjectField>- Country_Attributes_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Country_Attributes_Mapping__mdt.Country__c,
            Country_Attributes_Mapping__mdt.Country_Code__c,
            Country_Attributes_Mapping__mdt.Currency__c,
            Country_Attributes_Mapping__mdt.Currency_Code__c,
            Country_Attributes_Mapping__mdt.Phone_Maximum_Digits__c,
            Country_Attributes_Mapping__mdt.Phone_Minimum_Digits__c,
            Country_Attributes_Mapping__mdt.Phone_Country_Code__c
        };
    }
}