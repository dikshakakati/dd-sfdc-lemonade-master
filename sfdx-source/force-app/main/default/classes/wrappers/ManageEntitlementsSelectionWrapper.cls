/**
 * @author Deloitte
 * @date 12/18/2023
 * @description LEM-11329 - The LWC application facilitates the retrieval of existing CAA records, the uploading of account IDs, and subsequently verifies the integrity of the uploaded IDs.
 */
public with sharing class ManageEntitlementsSelectionWrapper {
    /**
     * @description getter/setter for ManageEntitlementsSelectionWrapper variable
     */
    @AuraEnabled
    public String groupId { get; set; }
    /**
     * @description getter/setter for ManageEntitlementsSelectionWrapper variable
     */
    @AuraEnabled
    public List<Id> accountIds { get; set; }
    /**
     * @description getter/setter for ManageEntitlementsSelectionWrapper variable
     */
    @AuraEnabled
    public List<ManageEntitlementsPackageSelectionWrapper> packageList = new List<ManageEntitlementsPackageSelectionWrapper>();

    /**
     * @description Constructor
     * @param subsGroupId
     * @param accountIds
     * @param packagesList
     */
    public ManageEntitlementsSelectionWrapper(
        String subsGroupId,
        List<Id> accountIds,
        List<ManageEntitlementsPackageSelectionWrapper> packagesList
    ) {
        this.groupId = subsGroupId;
        this.accountIds = accountIds;
        this.packageList = packagesList;
    }

    /**
     * @description Wrapper class to show data in correct format
     */
    public class ManageEntitlementsPackageSelectionWrapper {
        /**
         * @description getter/setter for ManageEntitlementsPackageSelectionWrapper variable
         */
        @AuraEnabled
        public Id packageId { get; set; }
        /**
         * @description getter/setter for ManageEntitlementsPackageSelectionWrapper variable
         */
        @AuraEnabled
        public String packageName { get; set; }
        /**
         * @description getter/setter for ManageEntitlementsPackageSelectionWrapper variable
         */
        @AuraEnabled
        public Boolean isSelectionEnabled { get; set; }
        /**
         * @description getter/setter for ManageEntitlementsPackageSelectionWrapper variable
         */
        @AuraEnabled
        public List<SBQQ__Subscription__c> subsList { get; set; }
        /**
         * @description getter/setter for ManageEntitlementsPackageSelectionWrapper variable
         */
        @AuraEnabled
        public Boolean isDrivePackage { get; set; }

        /**
         * @description Constructor
         * @param subsPackageId
         * @param subsPackageName
         * @param subsIsSelectionEnabled
         * @param subscrpList
         * @param isDrivePackage
         */
        public ManageEntitlementsPackageSelectionWrapper(
            Id subsPackageId,
            String subsPackageName,
            Boolean subsIsSelectionEnabled,
            List<SBQQ__Subscription__c> subscrpList,
            Boolean isDrivePackage
        ) {
            this.packageId = subsPackageId;
            this.packageName = subsPackageName;
            this.isSelectionEnabled = subsIsSelectionEnabled;
            this.subsList = subscrpList;
            this.isDrivePackage = isDrivePackage;
        }
    }
}