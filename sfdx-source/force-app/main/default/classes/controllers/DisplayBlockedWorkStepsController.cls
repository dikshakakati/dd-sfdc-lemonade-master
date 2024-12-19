/**
 * @author Deloitte
 * @date 10/11/2023
 * @description Controller class for displayBlockedWorkSteps LWC component.
 */
public inherited sharing class DisplayBlockedWorkStepsController {
    private static final Map<String, String> FIELD_HYPERLINK_TO_MATCH = new Map<String, String>{
        'Store_Account__c' => 'storeAccountHyperlink',
        'WorkPlanId' => 'workPlanHyperlink',
        'Name' => 'workStepHyperLink',
        'WorkPlan.Xref__c' => 'xrefHyperlink'
    };
    private static final Map<String, String> FIELD_API_NAME_TO_FIELD_LABEL = new Map<String, String>{
        'Status_Reason__c' => 'Status Reason',
        'Status_Reason_Details__c' => 'Status Reason Details'
    };
    private static final Set<String> FIELD_TO_WRAP_TEXT = new Set<String>{ 'Store Account' };
    private static final String ACCOUNT_LABEL = 'Account';
    private static final String LABEL = 'label';
    private static final String NAME = 'Name';
    private static final String STATUS_REASON_API = 'Status_Reason__c';
    private static final String STORE_ACCOUNT_LABEL = 'Store Account';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    private static final String VALUE = 'value';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_PLAN = 'Work Plan Name';
    private static final String WORK_PLAN_ID = 'Work Plan ID';
    private static final String XREF = 'Xref';
    private static final String XREF_LABEL = 'Xref';
    private static final String WORK_STEP_FIELD_SET = 'Blocked_Work_Steps_Related_List';
    private static final String WORK_STEP_NAME = 'Work Step Name';
    private static final String WORK_STEP_OBJECT = 'WorkStep';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String ULTIMATE_WORK_STEP_AGGREGATE_QUERY_COUNT_ALIAS = 'workStepsCount';
    private static final String ULTIMATE_WORK_STEP_AGGREGATE_QUERY_STATUS_ALIAS = 'workStepStatus';

    /**
     * @description It is used to set up the Columns for the Lightining Datatable using
     * the fields from field set.
     * @JIRA# LEM-9934
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getFields() {
        Schema.FieldSet workStepFieldSet = Schema.getGlobalDescribe()
            .get(WORK_STEP_OBJECT)
            .getDescribe()
            .FieldSets.getMap()
            .get(WORK_STEP_FIELD_SET);
        // Return if no field set found
        if (workStepFieldSet == null) {
            return null;
        }

        List<DynamicColumn> columns = new List<DynamicColumn>();

        for (Schema.FieldSetMember fieldSetMember : workStepFieldSet.getFields()) {
            DynamicColumn columnData = new DynamicColumn();
            if (FIELD_HYPERLINK_TO_MATCH.get(fieldSetMember.getFieldPath()) != null) {
                columnData = addLookupFields(
                    FIELD_HYPERLINK_TO_MATCH.get(fieldSetMember.getFieldPath()),
                    fieldSetMember.getLabel(),
                    fieldSetMember.getFieldPath()
                );
                columns.add(columnData);
                continue;
            } else {
                columnData.type = TYPE_STRING;
                columnData.fieldName = fieldSetMember.getFieldPath();
                columnData.label = FIELD_API_NAME_TO_FIELD_LABEL.get(fieldSetMember.getFieldPath());
                if (fieldSetMember.getFieldPath() == STATUS_REASON_API) {
                    columnData.wrapText = true;
                }
                columnData.hideDefaultActions = true;
                columns.add(columnData);
            }
        }
        return JSON.serialize(columns);
    }

    /**
     * @description It is used to get the Work Step records which have 'Blocked' status.
     * @JIRA# LEM-9934
     * @param recordId
     * @param workStepStatus
     * @return List<WorkStep>
     */
    @AuraEnabled(cacheable=true)
    public static List<WorkStep> getWorkStepDetails(Id recordId,String workStepStatus) {
        Set<Id> workOrderIds = new Set<Id>();
        Set<Id> parentWorkOrderIds = new Set<Id>();
        for (
            WorkOrder eachWorkOrder : new List<WorkOrder>(
                WorkOrdersSelector.newInstance().selectParentAndChildWOsByWorkOrderIds(recordId)
            )
        ) {
            if (eachWorkOrder.ParentWorkOrderId != null) {
                workOrderIds.add(eachWorkOrder.Id);
                parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
            } else if (eachWorkOrder.Type__c == WORK_ORDER_TYPE_DRIVE) {
                workOrderIds.add(eachWorkOrder.Id);
            }
        }
        // LEM-12026: Remove the parent work order Ids from the work order Ids set
        // for Drive with stores scenario.
        workOrderIds.removeAll(parentWorkOrderIds);
        return (List<WorkStep>) Security.stripInaccessible(
                AccessType.READABLE,
                WorkStepsSelector.newInstance()
                    .selectWorkStepsByWorkOrderIdsAndStatuses(
                        workOrderIds,
                        new Set<String>{ workStepStatus }
                    )
            )
            .getRecords();
    }

    /**
     * @description It is used to get the count of all the worksteps filtered by passed workOrderId.
     * @JIRA# LEM-11935
     * @param recordId
     * @return List<WorkStep>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getWorkStepCountFilteredByConditionGroupedByWorkOrderIds(Id recordId) {
        Map<String, Integer> collectStausAndWorkStepCount = new Map<String, Integer>();
        for (
            Aggregate eachAggregate : WorkStepsSelector.newInstance()
                .getWorkStepsCountFilteredByConditionGroupedByWorkOrderIdAndStatus(
                    recordId
                )
        ) {
            collectStausAndWorkStepCount.put(
                (String) eachAggregate.get(ULTIMATE_WORK_STEP_AGGREGATE_QUERY_STATUS_ALIAS),
                (Integer) eachAggregate.get(ULTIMATE_WORK_STEP_AGGREGATE_QUERY_COUNT_ALIAS)
            );
        }
        return collectStausAndWorkStepCount;

    }


    /**
     * @description  This method is used set up the 'url' type columns in Lightining Datatable.
     * @JIRA# LEM-9934
     * @param hyperlink
     * @param fieldLabel
     * @param fieldName
     * @return DynamicColumn
     */
    private static DynamicColumn addLookupFields(
        String hyperlink,
        String fieldLabel,
        String fieldName
    ) {
        DynamicColumn columnData = new DynamicColumn();
        columnData.type = TYPE_URL;
        columnData.fieldName = hyperlink;
        if (fieldLabel == WORK_PLAN_ID) {
            columnData.label = WORK_PLAN;
        } else if (fieldLabel == XREF_LABEL) {
            columnData.label = XREF;
        } else if (fieldLabel == NAME) {
            columnData.label = WORK_STEP_NAME;
        } else if (fieldLabel == STORE_ACCOUNT_LABEL) {
            columnData.label = ACCOUNT_LABEL;
        } else {
            columnData.label = fieldLabel;
        }
        columnData.hideDefaultActions = true;
        DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
        DynamicColumn.Label labelName = new DynamicColumn.Label();
        labelName.fieldName = fieldName;
        typeAttribute.label = labelName;
        if (FIELD_TO_WRAP_TEXT.contains(fieldLabel)) {
            columnData.wrapText = true;
        }
        columnData.typeAttributes = typeAttribute;
        return columnData;
    }

    /**
     * @description  This method is used to retrieve the custom meta data mapping for the work step resolution to quick action details
     * @JIRA# LEM-11093
     * @return Map<String, String>
     */
    @AuraEnabled
    public static Map<String, String> getResolutionMap() {
        Map<String, String> resolutionActionsMap = new Map<String, String>();
        List<Status_Reason_And_Details_Mapping__mdt> statusReasonAndDetailsMappings = StatusReasonAndDetailsMappingsSelector.newInstance()
            .getAllMappings();
        for (Status_Reason_And_Details_Mapping__mdt metaDataRec : statusReasonAndDetailsMappings) {
            if (String.isBlank(metaDataRec.Quick_Action_Name__c)) {
                continue;
            }
            string baseKey = metaDataRec.Type__c + '-' + metaDataRec.Status_Reason__c;
            string primaryKey = string.isNotBlank(metaDataRec.Business_Friendly_Mapping__c) &&
                String.isNotBlank(
                    metaDataRec.Business_Friendly_Mapping__r.Business_Friendly_Message__c
                )
                ? baseKey +
                  '-' +
                  metaDataRec.Business_Friendly_Mapping__r.Business_Friendly_Message__c
                : baseKey;
            resolutionActionsMap.put(baseKey, metaDataRec.Quick_Action_Name__c);
            resolutionActionsMap.put(primaryKey, metaDataRec.Quick_Action_Name__c);
        }
        return resolutionActionsMap;
    }
}