/**
 * @author Deloitte
 * @date 22/11/2022
 * @description Selector Class for Encrypted Value object.
 */
public inherited sharing class EncryptedValuesSelector extends fflib_SObjectSelector implements IEncryptedValuesSelector {
    /**
     * @description Default constructor for EncryptedValuesSelector class.
     * @return IEncryptedValuesSelector - interface of IEncryptedValuesSelector
     */
    public static IEncryptedValuesSelector newInstance() {
        return (IEncryptedValuesSelector) Application.Selector.newInstance(
            Encrypted_Value__c.SObjectType
        );
    }

    /**
     * @description It is used to get the fields on Encrypted_Value__c object.
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Encrypted_Value__c.Id,
            Encrypted_Value__c.Description__c,
            Encrypted_Value__c.Value__c
        };
    }

    /**
     * @description It is used for getting sObject type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Encrypted_Value__c.SObjectType;
    }

    /**
     * @description It is used for getting encrypted value associated with the passed key name.
     * @param encryptedValueName
     * @return List<Encrypted_Value__c>
     */
    public List<Encrypted_Value__c> selectByName(String encryptedValueName) {
        /* It allows field encryption using the returned value as a key by any user which may not
         * have access to the objects used in the query.
         * It runs in the background and does not expose any
         * encrypted/confidential data on UI.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        String.escapeSingleQuotes(encryptedValueName);
        fflib_QueryFactory query = newQueryFactory().setCondition('Name = :encryptedValueName');
        return (List<Encrypted_Value__c>) Database.query(query.toSOQL());
    }
}