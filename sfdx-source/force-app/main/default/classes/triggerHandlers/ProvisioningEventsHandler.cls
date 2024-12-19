/**
 * @description Provisioning Event Object Trigger Handler
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class ProvisioningEventsHandler extends ApplicationDomainHandler {
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_TYPE_COO = 'COO';

    private enum WoType {
        DRIVE,
        MARKETPLACE,
        STOREFRONT,
        POST_SALES,
        COO
    }

    private static final Map<String, WoType> WOTYPETOENUM = new Map<String, WoType>{
        WORK_ORDER_TYPE_DRIVE => WoType.DRIVE,
        WORK_ORDER_TYPE_MARKETPLACE => WoType.MARKETPLACE,
        WORK_ORDER_TYPE_STOREFRONT => WoType.STOREFRONT,
        WORK_ORDER_TYPE_POST_SALES => WoType.POST_SALES,
        WORK_ORDER_TYPE_COO => WoType.COO
    };
    private static final String GENERIC_LOG_SERVICE_WORKORDER_PROVISIONING_EVENT = 'PROVISIONING_EVENTS_HANDLER';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning events';
    /**
     * @description Constructor Method
     * @param sObjectList - Provisioning Events Record List
     */
    public ProvisioningEventsHandler(List<Provisioning_Event__e> sObjectList) {
        super(sObjectList);
        setContextBypass(Provisioning_Event__e.SObjectType, ProvisioningEventsHandler.class);
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        //only process 1 at a time.  Provisioning events have been broken into 50 accounts per event.
        Integer scopeSize = 1;
        List<Provisioning_Event__e> provisioningEventsToProcess = new List<Provisioning_Event__e>();
        String messageDetails = '';

        for (Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++) {
            Provisioning_Event__e provisioningEvent = (Provisioning_Event__e) this.records[counter];

            provisioningEventsToProcess.add(provisioningEvent);
            EventBus.TriggerContext.currentContext()
                .setResumeCheckpoint(provisioningEvent.replayId);
        }

        Map<String, Set<Id>> marketplaceAccountIdsByCreationMethod = new Map<String, Set<Id>>();
        // To collect Account Ids associated with Storefront/Post-Sales work order types
        Map<String, Set<Id>> amendmentAccountIdsByCreationMethod = new Map<String, Set<Id>>();
        Map<String, Set<Id>> driveAccountIdsByCreationMethod = new Map<String, Set<Id>>();
        List<Provisioning_Event__e> cooProvisioningEventsList = new List<Provisioning_Event__e>();
        for (Provisioning_Event__e event : provisioningEventsToProcess) {
            switch on WOTYPETOENUM.get(event.WO_Type__c) {
                when MARKETPLACE {
                    if (
                        !marketplaceAccountIdsByCreationMethod.containsKey(event.Creation_Method__c)
                    ) {
                        marketplaceAccountIdsByCreationMethod.put(
                            event.Creation_Method__c,
                            new Set<Id>()
                        );
                    }

                    marketplaceAccountIdsByCreationMethod.get(event.Creation_Method__c)
                        .addAll((List<Id>) JSON.deserialize(event.Accounts__c, List<Id>.class));
                }
                when STOREFRONT, POST_SALES {
                    if (
                        !amendmentAccountIdsByCreationMethod.containsKey(event.Creation_Method__c)
                    ) {
                        amendmentAccountIdsByCreationMethod.put(
                            event.Creation_Method__c,
                            new Set<Id>()
                        );
                    }

                    amendmentAccountIdsByCreationMethod.get(event.Creation_Method__c)
                        .addAll((List<Id>) JSON.deserialize(event.Accounts__c, List<Id>.class));
                }
                when DRIVE {
                    if (!driveAccountIdsByCreationMethod.containsKey(event.Creation_Method__c)) {
                        driveAccountIdsByCreationMethod.put(
                            event.Creation_Method__c,
                            new Set<Id>()
                        );
                    }

                    driveAccountIdsByCreationMethod.get(event.Creation_Method__c)
                        .addAll((List<Id>) JSON.deserialize(event.Accounts__c, List<Id>.class));
                }
                when COO {
                    cooProvisioningEventsList.add(event);
                }
                when else {
                    continue;
                }
            }
            // Append the message for logging
            messageDetails =
                messageDetails +
                ' Provisioning Event AFTER Creation: WO_Type=' +
                event.WO_Type__c +
                ', Creation_Method=' +
                event.Creation_Method__c +
                ', Accounts=' +
                (List<Id>) JSON.deserialize(event.Accounts__c, List<Id>.class);
        }

        // Log the event details
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    GENERIC_LOG_SERVICE_WORKORDER_PROVISIONING_EVENT,
                    LOG_DOMAIN_PROVISIONING,
                    GenericLogEntry.SeverityLevel.HIGH
                )
                .logMessage(MessageDetails)
        );
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            marketplaceAccountIdsByCreationMethod
        );
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            amendmentAccountIdsByCreationMethod,
            true
        );
        if (!driveAccountIdsByCreationMethod.isEmpty()) {
            AccountsProvisioningDriveService.provisionDriveAccountsByCreationMethod(
                driveAccountIdsByCreationMethod
            );
        }
        if (!cooProvisioningEventsList.isEmpty()) {
            ChangeOfOwnershipService.provisionCOO(cooProvisioningEventsList);
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
            return new ProvisioningEventsHandler(sObjectList);
        }
    }
}