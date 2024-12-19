/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Brief Item Object Trigger Handler.
 */
public class BriefItemsHandler extends ApplicationDomainHandler {
    /**
     * @description constructor method
     * @param sObjectList - Brief Item record list
     */
    public BriefItemsHandler(List<Brief_Item__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Brief_Item__c.SObjectType, BriefItemsHandler.class);
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onAfterInsert() {
        BriefItems.newInstance(this.records).updateStatusOnRelatedBrief();
        BriefItems.newInstance(this.records).updateDateOnRelatedBrief();
        BriefItemsService.updateQuoteLinesFromBriefItems(this.records);
        BriefItems.newInstance(this.records).updateConfigurationOnRelatedBrief();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        BriefItems.newInstance(briefItemWithUpdatedStatus()).updateStatusOnRelatedBrief();
        BriefItems.newInstance(briefItemWithUpdatedDate()).updateDateOnRelatedBrief();
        BriefItems.newInstance(briefItemWithUpdatedFields()).syncSubscriptionFields();
        BriefItemsService.sendCampaignCompletedEmails(existing,briefItemsWithInCampaignChangeToComplete());
        BriefItems.newInstance(this.records).updateConfigurationOnRelatedBrief();
    }
    /**
     * @description called to perform before update
     * @param existing
     */
    public override void onBeforeUpdate(Map<Id,SObject> existing){
        BriefItemsService.createBriefItemTrackingRecords(existing, briefItemsWithUpdatedTrackingFields());
        BriefItemsService.updateInCampaignChangeOnBriefItem(existing, briefItemsWithUpdatedTrackingFields());
        BriefItems.newInstance(briefItemsWithUpdatedCampaignIdFields()).validateCampaignIdField();
    }

    public override void onAfterDelete() {
        BriefItems.newInstance(existingRecords.values()).updateConfigurationOnRelatedBrief();
    }



    /**
     * @description To get changed records
     * @return List<Brand__c>
     */
    private List<Brief_Item__c> briefItemWithUpdatedStatus() {
        return new List<Brief_Item__c>(
            (List<Brief_Item__c>) getChangedRecords(
                new Set<SObjectField>{ Brief_Item__c.Status__c }
            )
        );
    }

    /**
     * @description To get changed records
     * @return List<Brief_Item__c>
     */
    private List<Brief_Item__c> briefItemsWithUpdatedCampaignIdFields() {
        return new List<Brief_Item__c>(
            (List<Brief_Item__c>) getChangedRecords(
                new Set<SObjectField>{ Brief_Item__c.Campaign_ID_s_36_digit_ID_only__c }
            )
        );
    }

    /**
     * @description To get changed records
     * @return List<Brand__c>
     */
    private List<Brief_Item__c> briefItemWithUpdatedDate() {
        return new List<Brief_Item__c>(
            (List<Brief_Item__c>) getChangedRecords(
                new Set<SObjectField>{ Brief_Item__c.Start_Date__c, Brief_Item__c.End_Date__c }
            )
        );
    }

    /**
     * @description To get changed records
     * @return List<Brief_Item__c>
     */
    private List<Brief_Item__c> briefItemWithUpdatedFields(){
        return new List<Brief_Item__c>(
            (List<Brief_Item__c>) getChangedrecords(
                BriefItemSubscriptionMappingSelector.newInstance().getAllBriefItemFields().keySet()
            )
        );
    }
    /**
     * @description get changed records for specific fields for field tracking
     * @return List<Brief_Item__c>
     */
    private List<Brief_Item__c> briefItemsWithUpdatedTrackingFields(){
        return new List<Brief_Item__c>(
            (List<Brief_Item__c>) getChangedrecords(
                BriefItemTrackingSelector.newInstance().getAllTrackingFields().keySet()
            )
        );
    }
    /**
     * @description return changed records that have campaign change
     * @return List<Brief_Item__c>
     */
    private List<Brief_Item__c> briefItemsWithInCampaignChangeToComplete(){
        List<Brief_Item__c> campaignChangedBriefItems = (List<Brief_Item__c>) getChangedRecords(
            new Set<SObjectField> {
                Brief_Item__c.In_Campaign_Change__c
            }
        );
        return campaignChangedBriefItems;
    }

    /**
     * @description return changed record that have updated config parameters
     * @return List<Brief_Item__c>
     */
    private List<Brief_Item__c> briefItemsWithConfigurationChanges() {
        return new List<Brief_Item__c>(
            (List<Brief_Item__c>) getChangedRecords(
                new Set<SObjectField>{ Brief_Item__c.Brief_Routing__c, Brief_Item__c.Custom_Creative_Required__c }
            )
        );
    }


    /**
     * @description Constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return BriefItemsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BriefItemsHandler(sObjectList);
        }
    }
}