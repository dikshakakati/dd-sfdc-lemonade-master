/**
 * @author Deloitte
 * @date 29/07/2022
 * @description Selector class for Encrypted_Fields_Configuration__mdt custom metadata.
 */
public inherited sharing class EncryptedFieldsConfigurationsSelector extends fflib_SObjectSelector implements IEncryptedFieldsConfigurationsSelector {
    /**
     * @description Default constructor for the class.
     * @return IEncryptedFieldsConfigurationsSelector - interface of IEncryptedFieldsConfigurationsSelector
     */
    public static IEncryptedFieldsConfigurationsSelector newInstance() {
        return (IEncryptedFieldsConfigurationsSelector) Application.Selector.newInstance(
            Encrypted_Fields_Configuration__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Encrypted_Fields_Configuration__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields of Encrypted_Fields_Configuration__mdt.
     * @return List<Schema.SObjectField> - Encrypted_Fields_Configuration__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Encrypted_Fields_Configuration__mdt.Component_Location__c,
            Encrypted_Fields_Configuration__mdt.FieldSet_Name__c,
            Encrypted_Fields_Configuration__mdt.Object_Api_Name__c
        };
    }

    /**
     * @description It is used for getting the configuration related to the object on which viewEncryptedData
     * lightning web component is added.
     * @JIRA# LEM-2255
     * @param componentLocation
     * @return List<Encrypted_Fields_Configuration__mdt>
     */
    public List<Encrypted_Fields_Configuration__mdt> selectByComponetLocationAndObjectApiName(
        String componentLocation
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Component_Location__c LIKE :componentLocation');
        return (List<Encrypted_Fields_Configuration__mdt>) Database.query(query.toSOQL());
    }
}