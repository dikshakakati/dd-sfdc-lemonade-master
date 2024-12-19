/**
 * @author Deloitte
 * @date 10/05/2022
 * @description Service implementation class for Tablet Case payload generation related logic.
 */
public inherited sharing class TabletCasePayloadGenerationServiceImpl implements ITabletCasePayloadGenerationService {
    private static final String SEPARATOR = System.Label.Separator;
    private static final String TABLET_CASE_ELIGIBLE_WORK_ORDER_TYPES_STATIC_CONFIG = 'Tablet_Case_Eligible_Work_Order_Types';
    private static final Set<String> ACCOUNT_ORDER_PROTOCOL_MERCHANT_OWNS = new Set<String>{
        'Android Tablet (Merchant Owns)',
        'POS and Tablet (Merchant Owns)'
    };
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private Set<String> tabletCaseEligibleWorkOrderTypes;
    private List<TabletCaseEntry> tabletCaseEntries;

    /**
     * @description Default constructor to instantiate variables.
     */
    public TabletCasePayloadGenerationServiceImpl() {
        tabletCaseEligibleWorkOrderTypes = new Set<String>();
        tabletCaseEntries = new List<TabletCaseEntry>();
        collectStaticConfigurations();
    }

    /**
     * @description It is used for generating payload for Tablet Case integration
     * using the passed Store Account Ids.
     * It also passes the generated payload and topic for futher processing.
     * @JIRA# LEM-1087
     * @param storeAccountIds
     * @param topicName
     */
    public void generatePayloadUsingStoreAccountIds(Set<Id> storeAccountIds, String topicName) {
        if (storeAccountIds.isEmpty() || String.isBlank(topicName)) {
            return;
        }
        /* Collecting Work Order Ids to enable Tablet Creation Generation indicator on Work Order
         * to notify Tablet Case Creation on Deliver Tablet Work Step */
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByAccountIds(storeAccountIds)
        ) {
            if (
                !areTabletCredentialsPopulated(eachWorkOrder.Account) ||
                ACCOUNT_ORDER_PROTOCOL_MERCHANT_OWNS.contains(
                    eachWorkOrder.Account.Order_Protocol__c
                ) &&
                eachWorkOrder.Provisioning_Status__c != PROVISIONING_STATUS_PROVISIONING_COMPLETE
            ) {
                storeAccountIds.remove(eachWorkOrder.AccountId);
            }
        }
        if (storeAccountIds.isEmpty()) {
            return;
        }
        generateTabletCaseEntries(
            WorkStepsSelector.newInstance()
                .getDeliverTabletWorkStepsDetailsByStoreAccount(storeAccountIds)
        );
        if (tabletCaseEntries.isEmpty()) {
            return;
        }
        publishNotifications(topicName, JSON.serialize(tabletCaseEntries));
    }

    /**
     * @description It is used for generating payload for Tablet Case integration
     * using the passed Work Step.
     * It also passes the generated payload and topic for futher processing.
     * @param workSteps
     * @param topicName
     */
    public void generatePayloadUsingWorkSteps(List<WorkStep> workSteps, String topicName) {
        if (String.isBlank(topicName)) {
            return;
        }
        generateTabletCaseEntries(workSteps);
        if (tabletCaseEntries.isEmpty()) {
            return;
        }
        publishNotifications(topicName, JSON.serialize(tabletCaseEntries));
    }

    /**
     * @description It is used to verify whether the tablet credentials are populated
     * on the passed Store Account.
     * @param account
     * @return Boolean
     */
    private Boolean areTabletCredentialsPopulated(Account account) {
        return String.isNotBlank(account.Tablet_User_Name__c) &&
            String.isNotBlank(account.Tablet_Password__c);
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.tabletCaseEligibleWorkOrderTypes = new Set<String>(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(TABLET_CASE_ELIGIBLE_WORK_ORDER_TYPES_STATIC_CONFIG)
                .Configuration_Value__c.split(SEPARATOR)
        );
    }

    /**
     * @description It generates TabletCaseEntries using the passed "Deliver Tablet" WorkSteps.
     * @JIRA# LEM-1087
     * @param deliverTabletWorkSteps
     */
    private void generateTabletCaseEntries(List<WorkStep> deliverTabletWorkSteps) {
        if (deliverTabletWorkSteps == null || deliverTabletWorkSteps.isEmpty()) {
            return;
        }
        TabletCaseEntry tabletCaseEntry;
        for (WorkStep eachWorkStep : deliverTabletWorkSteps) {
            if (!tabletCaseEligibleWorkOrderTypes.contains(eachWorkStep.Work_Order_Type__c)) {
                continue;
            }
            tabletCaseEntry = new TabletCaseEntry(eachWorkStep.Id, eachWorkStep.WorkOrderId);
            // Adding Figment Id in the payload for Status update scenario.
            tabletCaseEntry.figmentId = eachWorkStep.Figment_Id__c;
            tabletCaseEntries.add(tabletCaseEntry);
        }
    }

    /**
     * @description It passes topic and corresponding payload to service
     * for publishing a platform event.
     * @JIRA# LEM-1087, LEM-10273
     * @param topicName
     * @param payload
     */
    private void publishNotifications(String topicName, String payload) {
        if (String.isBlank(topicName) || String.isBlank(payload)) {
            return;
        }
        ExternalNotifierEventsService.publishEvents(
            new Map<String, String>{ topicName => payload }
        );
    }
}