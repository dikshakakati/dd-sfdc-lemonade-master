/**
 * @author Deloitte
 * @date 21/11/2022
 * @description Service class for Initatives related logic.
 */
public inherited sharing class InitiativesService {
    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed initiatives which triggers the further processing on AccountId change on initiatives.
     * @param initiatives
     */
    public static void processMergedAccountsRelatedRecords(List<Initiative__c> initiatives) {
        service().processMergedAccountsRelatedRecords(initiatives);
    }

    /**
     * @description This method is used to create an instance of InitiativesService class.
     * @return IInitiativesService - return instance of InitiativesServiceImpl
     */
    private static IInitiativesService service() {
        return (IInitiativesService) Application.Service.newInstance(IInitiativesService.class);
    }
}