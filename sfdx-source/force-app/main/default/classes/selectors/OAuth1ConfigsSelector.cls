/**
 * @description OAuth_Config__c Selector class
 */
public inherited sharing class OAuth1ConfigsSelector extends fflib_SObjectSelector implements IOAuth1ConfigsSelector {
    /**
     * @description Default constructor for the AccountContactRelationSelector class.
     * @return IOAuth1ConfigsSelector
     */
    public static IOAuth1ConfigsSelector newInstance() {
        return (IOAuth1ConfigsSelector) Application.SELECTOR.newInstance(
            OAuth_Config__c.SObjectType
        );
    }
    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return OAuth_Config__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Work Order
     * @return List<Schema.SObjectField> - OAuth Config fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OAuth_Config__c.Id,
            OAuth_Config__c.Name,
            OAuth_Config__c.Encrypted_Value__c,
            OAuth_Config__c.Include_In_Authorization__c,
            OAuth_Config__c.Include_In_Header__c,
            OAuth_Config__c.Include_In_Signature__c,
            OAuth_Config__c.Key__c,
            OAuth_Config__c.Value__c,
            OAuth_Config__c.Value_Encrypted__c,
            OAuth_Config__c.Value_Generated__c
        };
    }

    /**
     * @description returns list  of OAuth configs that serve as data map for the setsuite integration.
     * @return List<OAuth_Config__c>
     */
    public List<OAuth_Config__c> getNetsuiteIntegrationDatamap() {
        fflib_QueryFactory dataMapConfigs = newQueryFactory(false)
            .selectField('ID')
            .selectField('Key__c')
            .selectField('Value__c')
            .setCondition(' Name = \'Payment Account\' AND Data_Map_Type__c = \'Outbound\'');
        return (List<OAuth_Config__c>) Database.query(dataMapConfigs.toSOQL());
    }

    /**
     * @description returns list of OAuth configs that serve as the headers for the setsuite Restlet api request.
     * @return List<OAuth_Config__c>
     */
    public List<OAuth_Config__c> getNetsuiteIntegrationHeaders() {
        fflib_QueryFactory headerConfigs = newQueryFactory()
            .setCondition(' Name = \'Payment Account\' AND Data_Map_Type__c = null');
        return (List<OAuth_Config__c>) Database.query(headerConfigs.toSOQL());
    }

    /**
     * @description returns list of OAuth configs for a given OAuthConfigName
     * @param oAuthConfigName
     * @return List<OAuth_Config__c>
     */
    public List<OAuth_Config__c> getOAuthConfigsByName(String oAuthConfigName) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(' Name =:oAuthConfigName');
        return (List<OAuth_Config__c>) Database.query(query.toSOQL());
    }
}
