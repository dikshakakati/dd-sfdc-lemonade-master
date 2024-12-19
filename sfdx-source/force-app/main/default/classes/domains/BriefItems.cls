/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Domain Class for Brief Item Object
 */
public inherited sharing class BriefItems extends fflib_SObjects implements IBriefItems {

    private static final Integer CAMPAIGN_ID_LIST_SIZE = 30;
    private static final Integer CAMPAIGN_ID_LENGTH = 36;
    private static final String DELIMETER_COMMA = ',';
    /**
     * @description This method is to return the IOpportunities interface
     * @param List<Brief_Item__c> - list of Brief Items
     * @param recordList - Brief Items record list
     * @return IBriefItems - Returns IBriefItems Interface
     */
    public static IBriefItems newInstance(List<Brief_Item__c> recordList) {
        return (IBriefItems) Application.Domain.newInstance(recordList);
    }

    /**
     * @description default constructor for the class
     * @param sObjectList
     * @param Schema.Brief_Item__c.SObjectType
     */
    public BriefItems(List<Brief_Item__c> sObjectList) {
        super(sObjectList, Schema.Brief_Item__c.SObjectType);
    }

    /**
     * @description It is used to fetch Brief Item Records
     * @return List<Brief_Item>
     */
    private List<Brief_Item__c> getBriefItems() {
        return (List<Brief_Item__c>) getRecords();
    }

    /**
     * @description It is used to fetch all Brief Items related to the Brief.
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    private List<Brief_Item__c> getAllBriefItems(Set<Id> briefIds) {
        return BriefItemsSelector.newInstance().selectByBrief(briefIds);
    }

    /**
     * @description It is used to fetch Dates of all Brief Items and update the dates on the
     * related Brief.
     */
    public void updateDateOnRelatedBrief() {
        Set<Id> briefIds = new Set<Id>();
        Map<Id, Date> briefsToStartDate = new Map<Id, Date>();
        Map<Id, Date> briefsToEndDate = new Map<Id, Date>();
        for (Brief_Item__c eachBriefItem : getBriefItems()) {
            briefIds.add(eachBriefItem.Brief__c);
        }
        List<Brief_Item__c> allBriefItems = getAllBriefItems(briefIds);

        for (Brief_Item__c eachBriefItem : allBriefItems) {
            //Start Date
            if (
                briefsToStartDate.containsKey(eachBriefItem.Brief__c) &&
                briefsToStartDate.get(eachBriefItem.Brief__c) <= eachBriefItem.Start_Date__c
            ) {
                continue;
            }
            briefsToStartDate.put(eachBriefItem.Brief__c, eachBriefItem.Start_Date__c);
        }
        for (Brief_Item__c eachBriefItem : allBriefItems) {
            //End Date
            if (
                briefsToEndDate.containsKey(eachBriefItem.Brief__c) &&
                briefsToEndDate.get(eachBriefItem.Brief__c) >= eachBriefItem.End_Date__c
            ) {
                continue;
            }
            briefsToEndDate.put(eachBriefItem.Brief__c, eachBriefItem.End_Date__c);
        }
        BriefsService.updateBriefDateBasedOnBriefItemsDate(
            briefIds,
            briefsToStartDate,
            briefsToEndDate
        );
    }

    /**
     * @description It is used to verify status of all the related Brief Items and update queue
     * assignment eligibility of the related Brief
     */
    public void updateStatusOnRelatedBrief() {
        Set<Id> briefIds = new Set<Id>();
        Map<Id, List<Brief_Item__c>> briefsToBriefItems = new Map<Id, List<Brief_Item__c>>();
        for (Brief_Item__c eachBriefItem : getBriefItems()) {
            briefIds.add(eachBriefItem.Brief__c);
        }
        List<Brief_Item__c> allBriefItems = BriefItemsSelector.newInstance()
            .selectByBriefAndStatus(briefIds);

        //Mapping Brief Items to parent Briefs
        for (Brief_Item__c eachBriefItem : allBriefItems) {
            if (!briefsToBriefItems.containsKey(eachBriefItem.Brief__c)) {
                briefsToBriefItems.put(eachBriefItem.Brief__c, new List<Brief_Item__c>());
            }
            briefsToBriefItems.get(eachBriefItem.Brief__c).add(eachBriefItem);
        }

        briefIds.removeAll(briefsToBriefItems.keySet());
        BriefsService.updateBriefBasedOnBriefItemsStatus(briefsToBriefItems.keySet(), briefIds);
    }

    /**
     * @description It is used to update sync changes in the brief item to the subscription related
     * to the quote line the brief item was created
     */
    public void syncSubscriptionFields() {
        fflib_ISObjectUnitOfWork unitOfWorkBriefCreation = Application.UNITOFWORK.newInstance();
        List<String> quoteLinesWithBriefItems = new List<String>();
        Set<String> parentSubscriptionIds = new Set<String>();
        List<SBQQ__Subscription__c> listOfChildSubscriptions = new List<SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> quoteLineIdToSubscription = new Map<Id, SBQQ__Subscription__c>();
        for (Brief_Item__c eachBriefItem : getBriefItems()) {
            quoteLinesWithBriefItems.add(eachBriefItem?.Quote_Line__c);
        }

        List<SBQQ__Subscription__c> listOfSubscriptions = SubscriptionSelector.newInstance()
            .selectSubscriptionsWithFieldsToSyncWithBriefItems(quoteLinesWithBriefItems);
        if (!listOfSubscriptions.isEmpty()) {
            for (SBQQ__Subscription__c subscription : listOfSubscriptions) {
                quoteLineIdToSubscription.put(subscription?.SBQQ__QuoteLine__c, subscription);
                parentSubscriptionIds.add(subscription?.Id);
            }
            listOfChildSubscriptions = SubscriptionSelector.newInstance()
                .selectChildSubscriptions(parentSubscriptionIds);
        } else{
            return;
        }
        List<Brief_Item_To_Subscription_Sync_Mapping__mdt> briefItemSubscriptionSyncs = BriefItemSubscriptionMappingSelector.newInstance()
            .getAllValues();
        for (Brief_Item__c eachBriefItem : getBriefItems()) {
            SBQQ__Subscription__c subscriptionToUpdate = new SBQQ__Subscription__c();
            List<SBQQ__Subscription__c> listOfSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();

            if (quoteLineIdToSubscription.containsKey(eachBriefItem.Quote_Line__c)) {
                subscriptionToUpdate = quoteLineIdToSubscription.get(eachBriefItem.Quote_Line__c);

                listOfSubscriptionsToUpdate.addAll(
                    buildSubscriptionList(
                        briefItemSubscriptionSyncs,
                        eachBriefItem,
                        subscriptionToUpdate,
                        listOfChildSubscriptions
                    )
                );
                unitOfWorkBriefCreation.registerDirty(listOfSubscriptionsToUpdate);
            }
        }
        unitOfWorkBriefCreation.commitWork();
    }

    /** @description It is used to update the configuration field in the brief item to the
     * related brief
     */
    public void updateConfigurationOnRelatedBrief() {
        Set<Id> briefIds = new Set<Id>();
        Map<Id, List<Brief_Item__c>> briefsToBriefItems = new Map<Id, List<Brief_Item__c>>();
        for (Brief_Item__c eachBriefItem : getBriefItems()) {
            briefIds.add(eachBriefItem.Brief__c);
        }
        List<Brief_Item__c> allBriefitems = BriefItemsSelector.newInstance()
            .selectBriefItemsWithRoutingAndCustomCreative(briefIds);
        List<Brief__c> briefsWithVert = BriefsSelector.newInstance()
            .selectBriefWithPrimaryVertical(briefIds);
        for (Brief_Item__c eachBriefItem : allBriefItems) {
            if (!briefsToBriefItems.containsKey(eachBriefItem.Brief__c)) {
                briefsToBriefItems.put(eachBriefItem.Brief__c, new List<Brief_Item__c>());
            }
            briefsToBriefItems.get(eachBriefItem.Brief__c).add(eachBriefItem);
        }
        BriefsService.updateBriefConfiguration(briefsToBriefItems, briefsWithVert);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of Brief Item domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of BriefItems
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (BriefItems.constructorMock != null) {
                return (fflib_ISObjects) BriefItems.constructorMock.construct(objects);
            }
            return new BriefItems((List<Brief_Item__c>) objects);
        }
    }
    /**
     * @description this method finds the child subscription we want to update.
     * @param listOfChildSubscriptions
     * @param childProductName
     * @param parentSubscription
     * @return SBQQ__Subscription__c
     */
    public SBQQ__Subscription__c findChildSubscription(List<SBQQ__Subscription__c> listOfChildSubscriptions, String childProductName, SBQQ__Subscription__c parentSubscription){
        SBQQ__Subscription__c childSubscriptionToUpdate = new SBQQ__Subscription__c();
        for(SBQQ__Subscription__c childSubscription : listOfChildSubscriptions){
            if(
                childSubscription.SBQQ__RequiredById__c == parentSubscription.Id &&
                childSubscription.SBQQ__ProductName__c.equalsIgnoreCase(childProductName)
            ){
                childSubscriptionToUpdate = childSubscription;
            }
        }
        return childSubscriptionToUpdate;
    }
    /**
     * @description this method creates the list of subscriptions we want to update
     * @param briefItemSubscriptionSyncs
     * @param eachBriefItem
     * @param subscriptionToUpdate
     * @param listOfChildSubscriptions
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> buildSubscriptionList(
        List<Brief_Item_To_Subscription_Sync_Mapping__mdt> briefItemSubscriptionSyncs,
        Brief_Item__c eachBriefItem,
        SBQQ__Subscription__c subscriptionToUpdate,
        List<SBQQ__Subscription__c> listOfChildSubscriptions
    ){
        SBQQ__Subscription__c childSubscription = new SBQQ__Subscription__c();
        List<SBQQ__Subscription__c> listOfSubscriptionsToUpdate = new List<SBQQ__Subscription__c>();
        for (
            Brief_Item_To_Subscription_Sync_Mapping__mdt mapping : briefItemSubscriptionSyncs
        ) {
            //have boolean to check if needs to go to child subscription or not in custom metadata
            // have field for product name (childProductName)
            // call method to find child sub (pass in subscription and product name)
            //in new method loop through listOfSubscriptions use product name and
            //if SBQQ__ProductName__c is childprodname and requiredbyid is subscription to update
            // use SBQQ__RequiredById__c
            if(eachBriefItem.get(mapping.BriefItemFieldAPIName__c) != null){
                if(mapping.UpdateChild__c == true){
                    childSubscription = findChildSubscription(listOfChildSubscriptions, mapping.ChildProductName__c, subscriptionToUpdate);
                    childSubscription.put(
                        mapping.SubscriptionFieldAPIName__c,
                        eachBriefItem.get(mapping.BriefItemFieldAPIName__c)
                    );
                    listOfSubscriptionsToUpdate.add(childSubscription);
                }
                else{
                    subscriptionToUpdate.put(
                        mapping.SubscriptionFieldAPIName__c,
                        eachBriefItem.get(mapping.BriefItemFieldAPIName__c)
                    );
                    listOfSubscriptionsToUpdate.add(subscriptionToUpdate);
                }
            }
        }
        return listOfSubscriptionsToUpdate;
    }

    /**
     * @description validates the campaign Id field on brief items
     */
    public void validateCampaignIdField() {
        List<String> campaignIdList = new List<String>();
        for (Brief_Item__c briefItem : getBriefItems()) {
            if(String.isNotBlank(briefItem.Campaign_ID_s_36_digit_ID_only__c)){
                campaignIdList = briefItem.Campaign_ID_s_36_digit_ID_only__c.split(DELIMETER_COMMA);
                if (campaignIdList.size() > CAMPAIGN_ID_LIST_SIZE || briefItem.Campaign_ID_s_36_digit_ID_only__c.countMatches(DELIMETER_COMMA) > campaignIdList.size() ){
                    briefItem.addError(System.Label.Campaign_Id_Validation_Error);
                }
                for(String campaginId : campaignIdList){
                    campaginId = campaginId.trim();
                    if(campaginId.length() != CAMPAIGN_ID_LENGTH){
                        briefItem.addError(System.Label.Campaign_Id_Validation_Error);
                    }
                }
            }
        }
    }
}