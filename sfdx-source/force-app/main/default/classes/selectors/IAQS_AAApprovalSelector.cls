/**
 * @author atg
 * @date 05/17/2022
 * @description Interface to add sbaa__Approval__c class methods
 */
public interface IAQS_AAApprovalSelector extends fflib_ISObjectSelector {

    /**
     * @description This method is used for getting all approved SBAA__Approval__c
     * @return List<SBAA__Approval__c>
     */
    List<SBAA__Approval__c> selectApprovedOrderedByLastModifiedDate();

    /**
    * @description This method is used for getting requested SBAA__Approval__c by userId
    * @param userIds
    * @return List<SBAA__Approval__c>
    */
    List<SBAA__Approval__c> selectRequestedForUserIds(Set<Id> userIds);
}