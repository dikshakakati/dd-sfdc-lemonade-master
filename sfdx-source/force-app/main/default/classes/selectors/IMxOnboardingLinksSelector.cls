/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Interface to add Selector class methods.
 */
public interface IMxOnboardingLinksSelector extends fflib_ISObjectSelector {
    /**
     * @description It is for getting the fields on Mx_Onboarding_Link__c.
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description It is used to query Mx Onboarding links associated with the passed contractIds.
     * @param contractIds
     * @return List<Mx_Onboarding_Link__c>
     */
    List<Mx_Onboarding_Link__c> selectByContractIds(Set<Id> contractIds);

    /**
     * @description It is used to query Business Onboarding Details, Store Details and Contracts
     * associated with the passed MxOnboarding Links Id.
     * @param mxOnboardingLinksIds
     * @return List<Mx_Onboarding_Link__c>
     */
    List<Mx_Onboarding_Link__c> selectByMxOnboardingLinkIds(Set<Id> mxOnboardingLinksIds);

    /**
    * @description Get all the Mx onboardings by UUIDs
    * @author VenkateshDD | 08-05-2024
    * @param uuids
    * @return List<Mx_Onboarding_Link__c>
    **/
    List<Mx_Onboarding_Link__c> selectByUUID(Set<String> uuids);

     /**
     * @description It is used for getting Mx Onboarding Link based on passed Ids.
     * @param recordIds
     * @return Mx_Onboarding_Link__c
     */
    Mx_Onboarding_Link__c currentOnBoardingLink(Set<Id> recordIds);

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Mx_Onboarding_Link__c>
     */
    List<Mx_Onboarding_Link__c> selectById(Set<Id> idSet);

    /**
     * @description It is used for getting Mx Onboarding Links based on passed UUID.
     * @param uuid
     * @return List<Mx_Onboarding_Link__c>
     */
    List<Mx_Onboarding_Link__c> currentOnBoardingLinkByUUID(String uuid);

    /**
    * @description - select mx onboarding link record by id along with its store and busines related records
    * @author Soumya Dash | 08-16-2024
    * @param mxLinkId
    * @return List<Mx_Onboarding_Link__c>
    **/
    List<Mx_Onboarding_Link__c> selectByIdWithPayloadAndRelated(Id mxLinkId);

}