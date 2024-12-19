/**
 * @author Deloitte
 * @date 24/11/2022
 * @description Interface of service class for Initiatives related logic.
 */
public interface IInitiativesService {
    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed initiatives which triggers the further processing on AccountId change on initiatives.
     * @param initiatives
     */
    void processMergedAccountsRelatedRecords(List<Initiative__c> initiatives);
}