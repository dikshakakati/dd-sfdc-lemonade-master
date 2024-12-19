/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Service implementation class for Integration Templates related logic.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts')
public inherited sharing class IntegrationTemplatesServiceImpl implements IIntegrationTemplatesService {
    private static final String ACCOUNT_ID_FIELD = 'AccountId';
    private static final String ACCOUNT_ID_WORKSTEP_REFERENCE = 'WorkOrder.AccountId';
    private static final String CUSTOM_OBJECT_SUFFIX = '__c';
    private static final String COLLECT_DECISION_MAKER_METHOD = 'collectDecisionMakerContactDetails';
    private static final String COLLECT_DEPENDEE_WORKSTEPS_METHOD = 'collectDependeeWorkSteps';
    private static final String COLLECT_MERCHANT_ORDERS_METHOD = 'collectMxOrders';
    private static final String COLLECT_XREF_METHOD = 'collectXrefDetails';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_CRITERION = 'Criterion';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_LOGIC = 'Logic';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_MERGE_FIELD = 'Merge Field Mapping';
    private static final String DATE_KEY = 'DATE.';
    private static final String DATE_TODAY = 'DATE.TODAY';
    private static final String DOT_NOTATION = '.';
    private static final String EMAIL_OUTBOUND_CONFIG_NAME = 'Email_Outbound_Integration';
    private static final String INITIATE_EMAIL_INTEGRATION = 'EMAIL_INTEGRATION_OUTBOUND';
    private static final String INTERFACE_TRANSACTION_STATUS_NEW = 'New';
    private static final String LOG_DOMAIN_EMAIL_INTEGRATION = 'Email Outbound Integration';
    private static final String LOG_SERVICE_INTEGRATION_TEMPLATES = 'Integration Template Evaluation';
    private static final String MX_ORDER_OBJECT = 'MX_Order__c';
    private static final String MX_ORDER_ACCOUNT_FIELD_API_NAME = 'Account__c';
    private static final String REFERENCE_TYPE_FIELD_API_NAME = 'Field API Name';
    private static final String REFERENCE_TYPE_SERVICE_METHOD_NAME = 'Service Method Name';
    private static final String SOBJECT_TYPE_OPPORTUNITY = 'Opportunity';
    private static final String SPLIT_BY_DOT_NOTATION = '\\.';
    private static final String WORKORDER_OBJECT = 'WorkOrder';
    private static final String WORKSTEP_OBJECT = 'WorkStep';
    private static final Map<String, String> SOBJECT_OBJECT_NAME_TO_ACCOUNT_FIELD_API_NAME = new Map<String, String>{
        MX_ORDER_OBJECT => MX_ORDER_ACCOUNT_FIELD_API_NAME,
        SOBJECT_TYPE_OPPORTUNITY => ACCOUNT_ID_FIELD,
        WORKORDER_OBJECT => ACCOUNT_ID_FIELD,
        WORKSTEP_OBJECT => ACCOUNT_ID_WORKSTEP_REFERENCE
    };
    private static final Map<String, Object> CUSTOM_DATE_VALUES = new Map<String, Object>{
        DATE_TODAY => System.today()
    };

    private enum EventTopics {
        EVENTTOPIC_INITIATE_EMAIL_INTEGRATION
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        INITIATE_EMAIL_INTEGRATION => EventTopics.EVENTTOPIC_INITIATE_EMAIL_INTEGRATION
    };

    private Map<Id, List<String>> integrationTemplateIdToPayloads;
    private Map<String, Set<String>> passedIntegrationTemplateToRecordIds;
    private Integer maximumRetryLimit;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public IntegrationTemplatesServiceImpl() {
        integrationTemplateIdToPayloads = new Map<Id, List<String>>();
        passedIntegrationTemplateToRecordIds = new Map<String, Set<String>>();
        collectStaticConfigurations();
    }

    /**
     * @description This method is used to handle the published emailOutboundIntegrationEvents.
     * @param emailOutboundIntegrationEvents List of platform events with payload.
     */
    public void handleEmailOutboundIntegrationEvents(
        List<Email_Outbound_Integration__e> emailOutboundIntegrationEvents
    ) {
        Set<Id> recordIdsByPayload;
        Set<Id> sObjectIds = new Set<Id>();
        for (Email_Outbound_Integration__e eachEvent : emailOutboundIntegrationEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_INITIATE_EMAIL_INTEGRATION {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    sObjectIds.addAll(recordIdsByPayload);
                }
            }
        }
        if (!sObjectIds.isEmpty()) {
            try {
                initiateIntegrationTemplateCriteriaEvaluation(sObjectIds);
            } catch (Exception criteriaEvaluationException) {
                Logger.publish(
                    LogEntry.newExceptionLog(
                        criteriaEvaluationException,
                        LogEntry.SeverityLevel.HIGH
                    )
                );
                GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(
                            LOG_SERVICE_INTEGRATION_TEMPLATES,
                            LOG_DOMAIN_EMAIL_INTEGRATION,
                            GenericLogEntry.SeverityLevel.HIGH
                        )
                        .logException(criteriaEvaluationException)
                );
            }
        }
    }

    /**
     * @description It initiates criteria evaluation process based on SObject type
     * of received SObject Ids.
     * @JIRA# LEM-13778
     * @param sObjectIds
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public void initiateIntegrationTemplateCriteriaEvaluation(Set<Id> sObjectIds) {
        Map<String, Set<Id>> sObjectTypeToSObjectIds = new Map<String, Set<Id>>();
        String sObjectType;
        Map<String, Integration_Template__c> integrationTemplateNameToRecord = new Map<String, Integration_Template__c>();
        Map<String, List<Integration_Template__c>> sObjectTypeToIntegrationTemplate = new Map<String, List<Integration_Template__c>>();
        Map<String, Set<String>> sObjectTypeToFieldNames = new Map<String, Set<String>>();
        Map<String, Set<String>> methodNameToFieldNames = new Map<String, Set<String>>();
        Map<String, Set<String>> sObjectTypeToMethodNames = new Map<String, Set<String>>();
        Map<Id, SObject> recordIdToDetails = new Map<Id, SObject>();
        Map<String, Map<Id, List<SObject>>> recordIdToRelatedDetails = new Map<String, Map<Id, List<SObject>>>();
        Map<Id, List<Integration_Template__c>> sObjectIdToIntegrationTemplates = new Map<Id, List<Integration_Template__c>>();
        for (Id eachSObjectId : sObjectIds) {
            sObjectType = eachSObjectId.getSObjectType().getDescribe().getName();
            if (!sobjectTypeToSObjectIds.containsKey(sObjectType)) {
                sobjectTypeToSObjectIds.put(sObjectType, new Set<Id>());
            }
            sobjectTypeToSObjectIds.get(sObjectType).add(eachSObjectId);
        }
        for (
            Integration_Template__c eachIntegrationTemplate : IntegrationTemplatesSelector.newInstance()
                .selectIntegrationTemplatesAndChildCriteriaBasedOnSObjectType(
                    sObjectTypeToSObjectIds.keySet()
                )
        ) {
            integrationTemplateNameToRecord.put(
                eachIntegrationTemplate.Name,
                eachIntegrationTemplate
            );
            if (
                !sObjectTypeToIntegrationTemplate.containsKey(
                    eachIntegrationTemplate.SObject_Type__c
                )
            ) {
                sObjectTypeToIntegrationTemplate.put(
                    eachIntegrationTemplate.SObject_Type__c,
                    new List<Integration_Template__c>()
                );
            }
            sObjectTypeToIntegrationTemplate.get(eachIntegrationTemplate.SObject_Type__c)
                .add(eachIntegrationTemplate);
            if (!sObjectTypeToFieldNames.containsKey(eachIntegrationTemplate.SObject_Type__c)) {
                sObjectTypeToFieldNames.put(
                    eachIntegrationTemplate.SObject_Type__c,
                    new Set<String>()
                );
            }
            fetchMethodToFieldNamesForIntegrationtemplate(
                sObjectTypeToFieldNames,
                methodNameToFieldNames,
                sObjectTypeToMethodNames,
                eachIntegrationTemplate
            );
        }
        sObjectType = new List<String>(sObjectTypeToSObjectIds.keySet())[0];
        if (
            sObjectTypeToFieldNames.containsKey(sObjectType) &&
            sObjectTypeToFieldNames.get(sObjectType).contains(null)
        ) {
            sObjectTypeToFieldNames.get(sObjectType).remove(null);
        }
        Set<String> fieldsToQuery = sObjectTypeToFieldNames.get(sObjectType);
        if (fieldsToQuery == null || fieldsToQuery.isEmpty()) {
            return;
        }
        recordIdToDetails = new Map<Id, SObject>(
            IntegrationTemplatesSelector.newInstance()
                .selectSObjectDetailsWithPassedFieldsByIds(
                    fieldsToQuery,
                    sObjectTypeToSObjectIds.get(sObjectType),
                    sObjectType
                )
        );
        recordIdToRelatedDetails = collectRelatedDetailsBasedOnSObjectType(
            sObjectTypeToMethodNames,
            recordIdToDetails.values(),
            methodNameToFieldNames
        );
        fetchObjectIdToIntegrationTemplate(
            sObjectTypeToSObjectIds,
            sObjectTypeToIntegrationTemplate,
            sObjectIdToIntegrationTemplates
        );
        for (Id eachSObjectId : sObjectIdToIntegrationTemplates.keySet()) {
            List<Integration_Template__c> integrationTemplates = sObjectIdToIntegrationTemplates.get(
                eachSObjectId
            );
            for (Integration_Template__c eachIntegrationTemplate : integrationTemplates) {
                fetchPassedIntegrationTemplateRecordIds(
                    eachIntegrationTemplate,
                    eachSObjectId,
                    recordIdToDetails,
                    recordIdToRelatedDetails
                );
            }
        }
        for (String eachTemplate : passedIntegrationTemplateToRecordIds.keySet()) {
            for (String eachRecordId : passedIntegrationTemplateToRecordIds.get(eachTemplate)) {
                generateEmailPayload(
                    eachRecordId,
                    integrationTemplateNameToRecord.get(eachTemplate),
                    recordIdToDetails,
                    recordIdToRelatedDetails
                );
            }
        }
        if (!integrationTemplateIdToPayloads.isEmpty()) {
            createInterfaceTransactionsWithEmailPayloads();
        }
    }

    /**
     * @description It is used to collect details from related records
     * based on SObject type and record Ids.
     * @param sObjectTypeToMethodNames
     * @param recordDetails
     * @param methodNameToFieldNames
     * @return Map<String, Map<Id, SObject>>
     */
    private Map<String, Map<Id, List<SObject>>> collectRelatedDetailsBasedOnSObjectType(
        Map<String, Set<String>> sObjectTypeToMethodNames,
        List<SObject> recordDetails,
        Map<String, Set<String>> methodNameToFieldNames
    ) {
        Map<String, Map<Id, List<SObject>>> relatedRecordDetails = new Map<String, Map<Id, List<SObject>>>();
        if (sObjectTypeToMethodNames.isEmpty()) {
            return relatedRecordDetails;
        }
        if (
            sObjectTypeToMethodNames.get(new List<String>(sObjectTypeToMethodNames.keySet())[0])
                .contains(COLLECT_DECISION_MAKER_METHOD)
        ) {
            relatedRecordDetails.put(
                COLLECT_DECISION_MAKER_METHOD,
                CriteriaService.collectDecisionMakerContactDetails(
                    recordDetails,
                    methodNameToFieldNames.get(COLLECT_DECISION_MAKER_METHOD)
                )
            );
        }
        if (
            sObjectTypeToMethodNames.get(new List<String>(sObjectTypeToMethodNames.keySet())[0])
                .contains(COLLECT_XREF_METHOD)
        ) {
            relatedRecordDetails.put(
                COLLECT_XREF_METHOD,
                CriteriaService.collectXrefDetails(
                    recordDetails,
                    methodNameToFieldNames.get(COLLECT_XREF_METHOD)
                )
            );
        }
        if (
            sObjectTypeToMethodNames.get(new List<String>(sObjectTypeToMethodNames.keySet())[0])
                .contains(COLLECT_DEPENDEE_WORKSTEPS_METHOD)
        ) {
            relatedRecordDetails.put(
                COLLECT_DEPENDEE_WORKSTEPS_METHOD,
                CriteriaService.collectDependeeWorkSteps(
                    recordDetails,
                    methodNameToFieldNames.get(COLLECT_DEPENDEE_WORKSTEPS_METHOD)
                )
            );
        }
        if (
            sObjectTypeToMethodNames.get(new List<String>(sObjectTypeToMethodNames.keySet())[0])
                .contains(COLLECT_MERCHANT_ORDERS_METHOD)
        ) {
            relatedRecordDetails.put(
                COLLECT_MERCHANT_ORDERS_METHOD,
                CriteriaService.collectMxOrders(
                    recordDetails,
                    methodNameToFieldNames.get(COLLECT_MERCHANT_ORDERS_METHOD)
                )
            );
        }
        return relatedRecordDetails;
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.maximumRetryLimit = Integer.valueOf(
            InterfaceTransactionConfigSelector.newInstance()
                .getInstanceValue(EMAIL_OUTBOUND_CONFIG_NAME)
                .Retry_Limit__c
        );
    }

    /**
     * @description It checks whether the passed field reference and sobjects are null.
     * added to reduce method complexity.
     * @JIRA# LEM-13778
     * @param fieldReference
     * @param sObjectRecord
     * @return Boolean
     */
    private Boolean checkSObjectAndFieldNotNull(String fieldReference, SObject sObjectRecord) {
        return String.isBlank(fieldReference) || fieldReference == null || sObjectRecord == null;
    }

    /**
     * @description It creates Interface Transaction records based on generated payloads
     * @JIRA# LEM-13778
     */
    private void createInterfaceTransactionsWithEmailPayloads() {
        List<Interface_Transaction__c> interfaceTransactionsToInsert = new List<Interface_Transaction__c>();
        for (Id eachRecordId : integrationTemplateIdToPayloads.keySet()) {
            for (String eachPayload : integrationTemplateIdToPayloads.get(eachRecordId)) {
                interfaceTransactionsToInsert.add(
                    new Interface_Transaction__c(
                        Integration_Template__c = eachRecordId,
                        Interface_Transaction_Configuration_Name__c = EMAIL_OUTBOUND_CONFIG_NAME,
                        Payload__c = eachPayload,
                        Record_Id__c = (String) eachRecordId,
                        Remaining_Retry_Attempts__c = maximumRetryLimit,
                        Status__c = INTERFACE_TRANSACTION_STATUS_NEW
                    )
                );
            }
        }
        if (interfaceTransactionsToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsCreation = Application.UnitOfWork.newInstance();
        uowRecordsCreation.registerNew(interfaceTransactionsToInsert);
        uowRecordsCreation.commitWork();
    }

    /**
     * @description It collects mapping of sObject Ids to Integration Templates.
     * @JIRA# LEM-13778
     * @param sObjectTypeToSObjectIds
     * @param sObjectTypeToIntegrationTemplate
     * @param sObjectIdToIntegrationTemplates
     */
    private void fetchObjectIdToIntegrationTemplate(
        Map<String, Set<Id>> sObjectTypeToSObjectIds,
        Map<String, List<Integration_Template__c>> sObjectTypeToIntegrationTemplate,
        Map<Id, List<Integration_Template__c>> sObjectIdToIntegrationTemplates
    ) {
        for (String eachSObjectType : sObjectTypeToSObjectIds.keySet()) {
            for (Id eachSObjectId : sObjectTypeToSObjectIds.get(eachSObjectType)) {
                sObjectIdToIntegrationTemplates.put(
                    eachSObjectId,
                    sObjectTypeToIntegrationTemplate.get(eachSObjectType)
                );
            }
        }
    }

    /**
     * @description It collects mapping of sObject fields for processing.
     * @JIRA# LEM-13778
     * @param sObjectTypeToFieldNames
     * @param methodNameToFieldNames
     * @param sObjectTypeToMethodNames
     * @param eachIntegrationTemplate
     */
    private void fetchMethodToFieldNamesForIntegrationtemplate(
        Map<String, Set<String>> sObjectTypeToFieldNames,
        Map<String, Set<String>> methodNameToFieldNames,
        Map<String, Set<String>> sObjectTypeToMethodNames,
        Integration_Template__c eachIntegrationTemplate
    ) {
        for (Criterion__c eachCriterion : eachIntegrationTemplate.Criteria__r) {
            String fieldReferenceType = eachCriterion.Field_Reference_Type__c;
            String criteriaField = eachCriterion.Field__c;
            if (
                eachCriterion.RecordType.Name != CRITERION_RECORD_TYPE_DEVELOPERNAME_LOGIC &&
                String.isNotBlank(eachCriterion.Field__c)
            ) {
                if (fieldReferenceType == REFERENCE_TYPE_FIELD_API_NAME) {
                    sObjectTypeToFieldNames.get(eachIntegrationTemplate.SObject_Type__c)
                        .add(criteriaField);
                } else {
                    String accountFieldApiName;
                    if (
                        !sObjectTypeToMethodNames.containsKey(
                            eachIntegrationTemplate.SObject_Type__c
                        )
                    ) {
                        sObjectTypeToMethodNames.put(
                            eachIntegrationTemplate.SObject_Type__c,
                            new Set<String>()
                        );
                    }
                    sObjectTypeToMethodNames.get(eachIntegrationTemplate.SObject_Type__c)
                        .add(eachCriterion.Service_Method_Name__c);
                    accountFieldApiName = SOBJECT_OBJECT_NAME_TO_ACCOUNT_FIELD_API_NAME.get(
                        eachIntegrationTemplate.SObject_Type__c
                    );
                    sObjectTypeToFieldNames.get(eachIntegrationTemplate.SObject_Type__c)
                        .add(accountFieldApiName);
                    if (!methodNameToFieldNames.containsKey(eachCriterion.Service_Method_Name__c)) {
                        methodNameToFieldNames.put(
                            eachCriterion.Service_Method_Name__c,
                            new Set<String>()
                        );
                    }
                    methodNameToFieldNames.get(eachCriterion.Service_Method_Name__c)
                        .add(criteriaField);
                }
            }
        }
    }

    /**
     * @description It generates Email payload based on collected merge fields.
     * @JIRA# LEM-13778
     * @param recordId
     * @param integrationTemplate
     * @param recordIdToDetails
     * @param recordIdToRelatedDetails
     */
    private void generateEmailPayload(
        String recordId,
        Integration_Template__c integrationTemplate,
        Map<Id, SObject> recordIdToDetails,
        Map<String, Map<Id, List<SObject>>> recordIdToRelatedDetails
    ) {
        Map<String, String> mergeFieldValues = new Map<String, String>();
        for (Criterion__c eachCriteria : integrationTemplate.Criteria__r) {
            if (eachCriteria.RecordType.Name == CRITERION_RECORD_TYPE_DEVELOPERNAME_MERGE_FIELD) {
                if (eachCriteria.Field_Reference_Type__c == REFERENCE_TYPE_FIELD_API_NAME) {
                    mergeFieldValues.put(
                        eachCriteria.Name,
                        String.valueOf(
                            getFieldValueFromRecord(
                                eachCriteria.Field__c,
                                recordIdToDetails.get(recordId)
                            )
                        )
                    );
                } else {
                    if (
                        recordIdToRelatedDetails.containsKey(eachCriteria.Service_Method_Name__c) &&
                        recordIdToRelatedDetails
                            .get(eachCriteria.Service_Method_Name__c)
                            .containsKey(recordId)
                    ) {
                        for (
                            SObject eachSObject : recordIdToRelatedDetails
                                ?.get(eachCriteria.Service_Method_Name__c)
                                ?.get(recordId)
                        ) {
                            mergeFieldValues.put(
                                eachCriteria.Name,
                                String.valueOf(
                                    getFieldValueFromRecord(eachCriteria.Field__c, eachSObject)
                                )
                            );
                        }
                    }
                }
            }
        }
        EmailOutboundPayloads newEmailOutboundPayloads = new EmailOutboundPayloads();
        EmailOutboundPayloads.EmailOutboundDetails newEmailOutboundDetails = new EmailOutboundPayloads.EmailOutboundDetails(
            integrationTemplate.Name,
            ''
        );
        newEmailOutboundPayloads.setProperties(newEmailOutboundDetails, mergeFieldValues);
        if (!integrationTemplateIdToPayloads.containsKey(integrationTemplate.Id)) {
            integrationTemplateIdToPayloads.put(integrationTemplate.Id, new List<String>());
        }
        integrationTemplateIdToPayloads.get(integrationTemplate.Id)
            .add(JSON.serialize(newEmailOutboundDetails));
    }

    /**
     * @description It evaluates the SObject record based on criteria
     * and collects passed Integration Templates.
     * @JIRA# LEM-13778
     * @param eachIntegrationTemplate
     * @param eachSObjectId
     * @param recordIdToDetails
     * @param recordIdToRelatedDetails
     */
    private void fetchPassedIntegrationTemplateRecordIds(
        Integration_Template__c eachIntegrationTemplate,
        Id eachSObjectId,
        Map<Id, SObject> recordIdToDetails,
        Map<String, Map<Id, List<SObject>>> recordIdToRelatedDetails
    ) {
        Map<Integer, Boolean> criteriaOrderNumberToOutcome = new Map<Integer, Boolean>();
        String logicalExpression = '';
        for (Criterion__c eachCriteria : eachIntegrationTemplate.Criteria__r) {
            if (eachCriteria.RecordType.Name == CRITERION_RECORD_TYPE_DEVELOPERNAME_CRITERION) {
                Integer orderNumber = Integer.valueOf(eachCriteria.Order_Number__c);
                Boolean outcome = true;
                Object value = getCriteriaValueForCompare(eachCriteria);
                if (eachCriteria.Field_Reference_Type__c == REFERENCE_TYPE_FIELD_API_NAME) {
                    outcome = LogicalComparatorFactory.getComparator(eachCriteria.Comparator__c)
                        .compare(
                            getFieldValueFromRecord(
                                eachCriteria.Field__c,
                                recordIdToDetails.get(eachSObjectId)
                            ),
                            value
                        );
                } else {
                    if (
                        recordIdToRelatedDetails.containsKey(eachCriteria.Service_Method_Name__c) &&
                        recordIdToRelatedDetails
                            .get(eachCriteria.Service_Method_Name__c)
                            .containsKey(eachSObjectId)
                    ) {
                        for (
                            SObject eachSObject : recordIdToRelatedDetails
                                ?.get(eachCriteria.Service_Method_Name__c)
                                ?.get(eachSObjectId)
                        ) {
                            outcome =
                                outcome &&
                                LogicalComparatorFactory.getComparator(eachCriteria.Comparator__c)
                                    .compare(
                                        getFieldValueFromRecord(eachCriteria.Field__c, eachSObject),
                                        value
                                    );
                        }
                    }
                }
                criteriaOrderNumberToOutcome.put(orderNumber, outcome);
            } else if (eachCriteria.RecordType.Name == CRITERION_RECORD_TYPE_DEVELOPERNAME_LOGIC) {
                logicalExpression = eachCriteria.Criterion_Name__c;
            }
        }
        boolean isCriteriaPassed = LogicalExpressionEvaluator.getOutcome(
            criteriaOrderNumberToOutcome,
            logicalExpression
        );
        collectPassedSObjectIdsBasedOnTemplateName(
            isCriteriaPassed,
            eachIntegrationTemplate,
            eachSObjectId
        );
    }

    /**
     * @description It collects the SObject Ids based on passed integration templates
     * @JIRA# LEM-13778
     * @param isCriteriaPassed
     * @param integrationTemplate
     * @param sObjectId
     */
    private void collectPassedSObjectIdsBasedOnTemplateName(
        Boolean isCriteriaPassed,
        Integration_Template__c integrationTemplate,
        Id sObjectId
    ) {
        if (isCriteriaPassed) {
            String templateName = integrationTemplate.Name;
            if (!passedIntegrationTemplateToRecordIds.containsKey(templateName)) {
                passedIntegrationTemplateToRecordIds.put(templateName, new Set<String>());
            }
            passedIntegrationTemplateToRecordIds.get(templateName).add(sObjectId);
        }
    }

    /**
     * @description It returns field value for comparison based on the passed Criteria record.
     * @JIRA# LEM-13778
     * @param criteriaDetails
     * @return Object
     */
    private Object getCriteriaValueForCompare(Criterion__c criteriaDetails) {
        return !(criteriaDetails.Value__c == null || String.isBlank(criteriaDetails.Value__c)) &&
            criteriaDetails.Value__c.contains(DATE_KEY)
            ? CUSTOM_DATE_VALUES.get(criteriaDetails.Value__c)
            : criteriaDetails.Value__c;
    }

    /**
     * @description It returns the field value from passed record based on passed field reference name.
     * @JIRA# LEM-13778
     * @param fieldReference
     * @param sObjectRecord
     * @return Object
     */
    private Object getFieldValueFromRecord(String fieldReference, SObject sObjectRecord) {
        List<String> fieldReferences;
        Object fieldValue;
        if (checkSObjectAndFieldNotNull(fieldReference, sObjectRecord)) {
            return '';
        }
        if (fieldReference.contains(DOT_NOTATION)) {
            fieldReferences = fieldReference.split(SPLIT_BY_DOT_NOTATION);
            for (Integer i = 0; i < fieldReferences.size(); i++) {
                if (sObjectRecord == null) {
                    return '';
                }
                if (i == fieldReferences.size() - 1) {
                    fieldValue = sObjectRecord.get(fieldReferences[i]);
                    return fieldValue == null ? '' : fieldValue;
                }
                sObjectRecord = sObjectRecord.getSObject(fieldReferences[i]);
            }
        } else {
            fieldValue = sObjectRecord.get(fieldReference);
        }
        return fieldValue == null ? '' : fieldValue;
    }
}