/**
 * @description RollUpEvent Object Trigger Handler
 * @author Deloitte
 * @date 14/03/2022
 */
public class RollUpEventsHandler extends ApplicationDomainHandler {
    private static final String STORE_COUNT = 'Store Count';
    private static final String VERTICAL = 'Vertical';
    private static final String FRANCHISE = 'Franchise';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Address Verification Status';

    /**
     * @description Constructor Method
     * @param sObjectList - RollUpEvents Record List
     */
    public RollUpEventsHandler(List<RollUpEvent__e> sObjectList) {
        super(sObjectList);
        setContextBypass(RollUpEvent__e.SObjectType, RollUpEventsHandler.class);
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        Set<Id> franchiseAccountIds = new Set<Id>();
        Set<Id> storeDetailIds = new Set<Id>();
        Integer counter = 0;
        for (RollUpEvent__e events : (List<RollUpEvent__e>) this.records) {
            counter++;
            if (counter > 200) {
                break;
            }
            if (!accountIdsByType.containsKey(events.Type__c)) {
                accountIdsByType.put(events.Type__c, new Set<Id>());
            }
            if (events.Type__c == FRANCHISE) {
                franchiseAccountIds.add(events.RecordId__c);
            }
            if (events.Type__c == ADDRESS_VERIFICATION_STATUS) {
                storeDetailIds.add(events.RecordId__c);
            }
            accountIdsByType.get(events.Type__c).add(events.RecordId__c);
            EventBusTriggerContext.setResumeCheckpoint(events.replayId);
        }
        AccountRollupService.calculateRollupsByType(accountIdsByType);
        StoreDetailRollUpService.rollUpAddressVerificationStatus(storeDetailIds);
        if (!franchiseAccountIds.isEmpty()) {
            AccountRollupService.aggregateVerticalOnFranchiseParents(franchiseAccountIds);
        }
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return RollUpEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new RollUpEventsHandler(sObjectList);
        }
    }
}