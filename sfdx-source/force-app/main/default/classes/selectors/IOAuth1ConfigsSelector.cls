/**
 * @description OAuth Config selector interface.
 */
public interface IOAuth1ConfigsSelector extends fflib_ISObjectSelector {
    /**
     * @description returns list of OAuth configs that serve as data map for the setsuite integration.
     * @return List<OAuth_Config__c>
     */
    List<OAuth_Config__c> getNetsuiteIntegrationDatamap();
    /**
     * @description returns list of OAuth configs that serve as the headers for the setsuite Restlet api request.
     * @return List<OAuth_Config__c>
     */
    List<OAuth_Config__c> getNetsuiteIntegrationHeaders();
    /**
     * @description returns list of OAuth configs for a given OAuthConfigName
     * @param oAuthConfigName
     * @return List<OAuth_Config__c>
     */
    List<OAuth_Config__c> getOAuthConfigsByName(String oAuthConfigName);
}
