/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Interface for NintexUrlMappingSelector
 */
public interface INintexUrlMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Nintex URL Mapping records
     * @return List<Nintex_URL_Mapping__mdt> - returns list of metadata records
     */
    List<Nintex_URL_Mapping__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Nintex_URL_Mapping__mdt
     * @return List<Schema.SObjectField>- Nintex_URL_Mapping__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}