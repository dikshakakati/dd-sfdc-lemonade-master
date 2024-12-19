/**
 * @author Deloitte
 * @date 04/05/2024
 * @description Service Implementation for Activation Checklist related functionality.
 */
public inherited sharing class ActivationChecklistServiceImpl implements IActivationChecklistService {
    private static final String ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Activations_Checklist_Payload_Chunk_Size';
    private static final String DASH_SPLIT = '-';
    private static final String CREATE_ACTIVATION_CHECKLIST = 'CREATE_ACTIVATION_CHECKLIST';
    private static final String EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION = 'ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION';
    private static final String PAYLOAD_BUSINESS_DETAILS = 'GET_BUSINESS';
    private static final String PAYLOAD_DATA = 'responsePayload';
    private static final String PAYLOAD_ERROR = 'error';
    private static final String PAYLOAD_MENU_DETAILS = 'GET_MENU';
    private static final String PAYLOAD_PAYMENT = 'GET_PAYMENT_ACCOUNT';
    private static final String PAYLOAD_POINT_OF_SALES = 'GET_POINT_OF_SALE';
    private static final String PAYLOAD_PRICING_PROGRAMS = 'GET_PRICING_PROGRAMS';
    private static final String PAYLOAD_PROGRAMS = 'programs';
    private static final String PAYLOAD_STORE = 'GET_STORE';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_SALESFORCE_ID = 'workStepSalesforceId';
    private enum EventTopics {
        EVENTTOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
        EVENTTOPIC_CREATE_ACTIVATION_CHECKLIST
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION => EventTopics.EVENTTOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
        CREATE_ACTIVATION_CHECKLIST => EventTopics.EVENTTOPIC_CREATE_ACTIVATION_CHECKLIST
    };
    private Integer payloadChunkSize;

    /**
     * @description Default constructor for this class.
     */
    public ActivationChecklistServiceImpl() {
        collectStaticConfigurations();
    }

    /**
     * @description This method is used to handle the published onboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> recordIdsByPayload;
        Set<Id> integrationRequestIds = new Set<Id>();
        List<String> activationChecklistOutboundPayloads = new List<String>();
        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION {
                    activationChecklistOutboundPayloads.add(eachEvent.Payload__c);
                }
                when EVENTTOPIC_CREATE_ACTIVATION_CHECKLIST {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    integrationRequestIds.addAll(recordIdsByPayload);
                }
            }
        }
        parseActivationChecklistPayloads(integrationRequestIds);
        if (!activationChecklistOutboundPayloads.isEmpty()) {
            IntegrationOutboundService.sendAPICalloutWithRequestPayload(
                EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
                activationChecklistOutboundPayloads
            );
        }
    }

    /**
     * @description It is used to generate chunked payload for Activation Checklist outbound integration.
     * @JIRA# LEM-13305
     * @param activationChecklistDetails
     */
    public void generatePayloadAndInitiateOutboundIntegration(
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails
    ) {
        List<String> activationChecklistPayloads = new List<String>();
        Integer storeCountInCurrentChunk = 0;
        Integer processedStoreCount = 0;
        ActivationChecklistOutboundWrapper newActivationChecklistWrapper = new ActivationChecklistOutboundWrapper(
            getUUID(),
            new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>()
        );
        for (
            ActivationChecklistOutboundWrapper.ActivationChecklistDetails eachActivationChecklistDetails : activationChecklistDetails
        ) {
            processedStoreCount = processedStoreCount + 1;
            storeCountInCurrentChunk = storeCountInCurrentChunk + 1;
            if (storeCountInCurrentChunk < payloadChunkSize) {
                newActivationChecklistWrapper.requestPayload.add(eachActivationChecklistDetails);
                if (processedStoreCount == activationChecklistDetails.size()) {
                    activationChecklistPayloads.add(JSON.Serialize(newActivationChecklistWrapper));
                }
            } else {
                newActivationChecklistWrapper.requestPayload.add(eachActivationChecklistDetails);
                activationChecklistPayloads.add(JSON.Serialize(newActivationChecklistWrapper));
                newActivationChecklistWrapper = new ActivationChecklistOutboundWrapper(
                    getUUID(),
                    new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>()
                );
                storeCountInCurrentChunk = 0;
            }
        }
        if (!activationChecklistPayloads.isEmpty()) {
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION => activationChecklistPayloads
                }
            );
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.payloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It generates a sequence of alpha-numeric ID used as unique identifier
     * for outbound integration payload.
     * @return String
     */
    private String getUUID() {
        Blob blbKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blbKey);
        String uuid =
            hexKey.SubString(0, 8) +
            DASH_SPLIT +
            hexKey.SubString(8, 12) +
            DASH_SPLIT +
            hexKey.SubString(12, 16) +
            DASH_SPLIT +
            hexKey.SubString(16, 20) +
            DASH_SPLIT +
            hexKey.substring(20);
        return uuid;
    }

    /**
     * @description Route Activation Checklist for parsing
     * @param integrationRequestIds
     */
    private void parseActivationChecklistPayloads(Set<Id> integrationRequestIds) {
        Map<Id, ActivationChecklistWrapper> mintStoreData = new Map<Id, ActivationChecklistWrapper>();
        if (integrationRequestIds.isEmpty()) {
            return;
        }
        ActivationChecklistWrapper storeDataList;
        Map<String, Object> jsonString;
        Map<String, Object> dataString;
        Set<String> storeAccountIds = new Set<String>();
        Set<Id> failedWorkStepIds = new Set<Id>();

        for (
            Integration_Request__c eachIntegrationRequest : IntegrationRequestsSelector.newInstance()
                .selectById(integrationRequestIds)
        ) {
            dataString = (Map<String, Object>) JSON.deserializeUntyped(
                eachIntegrationRequest.Payload__c
            );
            jsonString = (Map<String, Object>) dataString.get(PAYLOAD_DATA);
            storeDataList = new ActivationChecklistWrapper(
                Integer.valueOf(jsonString.get('storeId')),
                (String) jsonString.get('accountSalesforceId'),
                (String) jsonString.get('xrefSalesforceId'),
                (String) jsonString.get('businessRefSalesforceId'),
                (String) jsonString.get('workStepSalesforceId')
            );
            List<Object> errors = (List<Object>) jsonString.get(PAYLOAD_ERROR);
            if (!errors.isEmpty()) {
                failedWorkStepIds.add((Id) jsonString.get(WORK_STEP_SALESFORCE_ID));
            }
            storeDataList.storeInformation = parseStoreInformation(jsonString.get(PAYLOAD_STORE));
            storeDataList.paymentAccountInformation = parsePaymentInformation(
                jsonString.get(PAYLOAD_PAYMENT)
            );
            storeDataList.businessInformation = parseBusinessInformation(
                jsonString.get(PAYLOAD_BUSINESS_DETAILS)
            );
            storeDataList.menuInformation = parseMenuInformation(
                jsonString.get(PAYLOAD_MENU_DETAILS)
            );
            storeDataList.posInformation = parsePOSInformation(
                jsonString.get(PAYLOAD_POINT_OF_SALES)
            );

            if (((Map<String, Object>) jsonString.get(PAYLOAD_PRICING_PROGRAMS)) != null) {
                storeDataList.pricingPrograms = parsePricingPrograms(
                    (List<Object>) ((Map<String, Object>) jsonString.get(PAYLOAD_PRICING_PROGRAMS))
                        .get(PAYLOAD_PROGRAMS)
                );
            }
            storeAccountIds.add((Id) jsonString.get('accountSalesforceId'));
            mintStoreData.put((Id) jsonString.get('accountSalesforceId'), storeDataList);
        }
        ActivationCheckValidationsService.failedWorkStepIdsFromPayload.addAll(failedWorkStepIds);
        ActivationCheckValidationsService.validateStoreAccount(
            AccountsSelector.newInstance().selectById(storeAccountIds),
            mintStoreData,
            ActivationChecklistValidationSelector.newInstance().getAllActiveValidations()
        );
        WorkPlansService.escalateActivationChecklistValidationOnWorkPlan(
            WorkStepsSelector.newInstance().selectByIds(failedWorkStepIds)
        );
        WorkStepsService.updateActivationChecklistWorkStepsStatus(
            failedWorkStepIds,
            true,
            WORK_STEP_STATUS_ESCALATED
        );
        //Last Ran Date
    }

    private List<ActivationChecklistWrapper.Error> parseErrors(List<Object> allErrors) {
        List<ActivationChecklistWrapper.Error> checklistErrors = new List<ActivationChecklistWrapper.Error>();
        ActivationChecklistWrapper.Error errorWrapper;
        for (Object eachErrorObject : allErrors) {
            errorWrapper = (ActivationChecklistWrapper.Error) JSON.deserialize(
                JSON.serialize(eachErrorObject),
                ActivationChecklistWrapper.Error.class
            );
            checklistErrors.add(errorWrapper);
        }
        return checklistErrors;
    }

    private ActivationChecklistWrapper.GetStore parseStoreInformation(Object storeInformation) {
        return (ActivationChecklistWrapper.GetStore) JSON.deserialize(
            JSON.serialize(storeInformation),
            ActivationChecklistWrapper.GetStore.class
        );
    }

    private ActivationChecklistWrapper.GetPayment parsePaymentInformation(
        Object paymentInformation
    ) {
        return (ActivationChecklistWrapper.GetPayment) JSON.deserialize(
            JSON.serialize(paymentInformation),
            ActivationChecklistWrapper.GetPayment.class
        );
    }

    private ActivationChecklistWrapper.GetBusinessDetails parseBusinessInformation(
        Object businessInformation
    ) {
        return (ActivationChecklistWrapper.GetBusinessDetails) JSON.deserialize(
            JSON.serialize(businessInformation),
            ActivationChecklistWrapper.GetBusinessDetails.class
        );
    }

    private ActivationChecklistWrapper.GetMenu parseMenuInformation(Object menuInformation) {
        return (ActivationChecklistWrapper.GetMenu) JSON.deserialize(
            JSON.serialize(menuInformation),
            ActivationChecklistWrapper.GetMenu.class
        );
    }

    private List<ActivationChecklistWrapper.GetPricingPrograms> parsePricingPrograms(
        List<Object> pricingPrograms
    ) {
        ActivationChecklistWrapper.GetProducts programDetailProduct;
        ActivationChecklistWrapper.GetPricing programDetailPricing;
        ActivationChecklistWrapper.GetPricingPrograms programDetailInformation;
        ActivationChecklistWrapper.FeeAttributes feeAttributeDetails;
        List<ActivationChecklistWrapper.FeeAttributes> allFeeAttributes;
        List<ActivationChecklistWrapper.GetPricingPrograms> allProgramInformation = new List<ActivationChecklistWrapper.GetPricingPrograms>();
        Map<String, Object> pricingDetail = new Map<String, Object>();
        Map<String, Object> programDetail = new Map<String, Object>();
        for (Object eachPricingProgram : pricingPrograms) {
            programDetail = (Map<String, Object>) ((Map<String, Object>) eachPricingProgram)
                .get('program');
            programDetailProduct = new ActivationChecklistWrapper.GetProducts();
            programDetailPricing = new ActivationChecklistWrapper.GetPricing();
            programDetailInformation = new ActivationChecklistWrapper.GetPricingPrograms();
            feeAttributeDetails = new ActivationChecklistWrapper.FeeAttributes();
            allFeeAttributes = new List<ActivationChecklistWrapper.FeeAttributes>();
            pricingDetail = (Map<String, Object>) ((Map<String, Object>) ((Map<String, Object>) eachPricingProgram)
                    .get('program'))
                .get('pricing');
            programDetailInformation.productInformation = (ActivationChecklistWrapper.GetProducts) JSON.deserialize(
                JSON.serialize(programDetail.get('product')),
                ActivationChecklistWrapper.GetProducts.class
            );
            programDetailInformation.isActive = (Boolean) ((Map<String, Object>) eachPricingProgram)
                .get('isActive');
            programDetailInformation.isTrial = (Boolean) ((Map<String, Object>) eachPricingProgram)
                .get('isTrial');
            programDetailInformation.isPostTrial = (Boolean) ((Map<String, Object>) eachPricingProgram)
                .get('isPostTrial');
            programDetailInformation.isPartner = (Boolean) (programDetail.get('isPartner'));
            programDetailInformation.partnershipId = String.valueOf(
                ((Map<String, Object>) eachPricingProgram).get('partnershipId')
            );
            for (Object eachFee : (List<Object>) pricingDetail.get('feeAttributes')) {
                feeAttributeDetails.flatFee = ((Map<String, Object>) eachFee)
                        .get('flatFeeInCents') == null
                    ? 0
                    : Decimal.valueOf(
                          String.valueOf(((Map<String, Object>) eachFee).get('flatFeeInCents'))
                      );
                feeAttributeDetails.feeType = String.valueOf(
                    ((Map<String, Object>) eachFee).get('feeType')
                );
                feeAttributeDetails.feeRate = ((Map<String, Object>) eachFee).get('feeRate') == null
                    ? 0.0
                    : Decimal.valueOf(
                          String.valueOf(((Map<String, Object>) eachFee).get('feeRate'))
                      );
                feeAttributeDetails.startTime = String.valueOf(
                    ((Map<String, Object>) eachFee).get('startTime')
                );
                if (programDetail.get('isTrial') == true) {
                    feeAttributeDetails.endTime = String.valueOf(
                        ((Map<String, Object>) eachFee).get('endTime')
                    );
                }
                allFeeAttributes.add(feeAttributeDetails);
                feeAttributeDetails = new ActivationChecklistWrapper.FeeAttributes();
            }
            programDetailPricing.feeAttributesInformation = allFeeAttributes;
            if (programDetailInformation.isPartner != null && programDetailInformation.isPartner) {
                programDetailPricing.tabletSubscriptionFee = getTabletORPrinterSubscriptionFee('weeklyTabletSubscriptionFee',pricingDetail);
                programDetailPricing.printerSubscriptionFee = getTabletORPrinterSubscriptionFee('weeklyPrinterSubscriptionFee',pricingDetail);
            }
            programDetailInformation.pricingInformation = programDetailPricing;
            programDetailInformation.sourceId = (String) (programDetail.get('sourceId'));
            allProgramInformation.add(programDetailInformation);
        }
        return allProgramInformation;
    }

    private ActivationChecklistWrapper.GetPointOfSales parsePOSInformation(Object posInformation) {
        return (ActivationChecklistWrapper.GetPointOfSales) JSON.deserialize(
            JSON.serialize(posInformation),
            ActivationChecklistWrapper.GetPointOfSales.class
        );
    }

    /**
     * @description This method is used to to get Subscription Fee for tablet or printer.
     * @param key
     * @param pricingDetail
     * @return Decimal
     */
    private Decimal getTabletORPrinterSubscriptionFee(String key, Map<String, Object> pricingDetail) {
        return ((Map<String, Object>) pricingDetail).
        containsKey(key) ?
        Decimal.valueOf( (String)((Map<String, Object>) pricingDetail).get(key)) : null;
    }
}
