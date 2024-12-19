/**
 * @author Deloitte
 * @date 15/03/2022
 * @description Controller class for DisplayWorkOrdersRelatedList LWC component
 */
public with sharing class DisplayWorkOrdersController {
    private static final String WORK_ORDER_OBJECT = 'WorkOrder';
    private static final String WORK_ORDER_FIELD_SET = 'Store_Account_Related_List_Fields';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_DATE = 'date';
    private static final String TYPE_URL = 'url';
    private static final String WORK_ORDER_NUMBER = 'WorkOrderNumber';
    private static final String WORK_ORDER_NAME = 'Work_Order_Name__c';
    private static final String WORK_ORDER_CREATED_BY = 'CreatedById';
    private static final String CREATED_BY_LABEL = 'Created By';
    private static final String WORK_ORDER_CREATED_DATE = 'CreatedDate';
    private static final String WORK_ORDER_NUMBER_HYPERLINK = 'workOrderNumberHyperlink';
    private static final String WORK_ORDER_NAME_HYPERLINK = 'workOrderNameHyperlink';
    private static final String WORK_ORDER_CREATED_BY_HYPERLINK = 'workOrderCreatedByHyperlink';

    /**
     * @description This method is used to get work order field set fields.
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getFields() {
        Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe()
            .get(WORK_ORDER_OBJECT)
            .getDescribe()
            .FieldSets.getMap()
            .get(WORK_ORDER_FIELD_SET);
        // Return if no field set found
        if (fieldSetObj == null) {
            return null;
        }

        // Store all field set member fields
        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields();
        List<DynamicColumn> columns = new List<DynamicColumn>();

        // Iterate over field set members
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = fieldSetMember.getFieldPath();
            DynamicColumn columnData = new DynamicColumn();
            if (fieldName == WORK_ORDER_NUMBER) {
                columnData = addLookupFields(
                    WORK_ORDER_NUMBER_HYPERLINK,
                    fieldSetMember.getLabel(),
                    fieldSetMember.getFieldPath()
                );
            } else if (fieldName == WORK_ORDER_NAME) {
                columnData = addLookupFields(
                    WORK_ORDER_NAME_HYPERLINK,
                    fieldSetMember.getLabel(),
                    fieldSetMember.getFieldPath()
                );
            } else if(fieldName == WORK_ORDER_CREATED_BY){
                columnData = addLookupFields(
                    WORK_ORDER_CREATED_BY_HYPERLINK,
                    CREATED_BY_LABEL,
                    fieldSetMember.getFieldPath()
                );
            } else if(fieldName == WORK_ORDER_CREATED_DATE){
                columnData = new DynamicColumn();
                columnData.type = TYPE_DATE;
                columnData.fieldName = fieldName;
                columnData.label = fieldSetMember.getLabel();
                columnData.hideDefaultActions = true;
            }
            else {
                columnData = new DynamicColumn();
                columnData.type = TYPE_STRING;
                columnData.fieldName = fieldName;
                columnData.label = fieldSetMember.getLabel();
                columnData.hideDefaultActions = true;
            }
            columns.add(columnData);
        }
        return JSON.serialize(columns);
    }

    /**
     * @description  This method is used to set all lookupfields for work order field set
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
        columnData.label = fieldLabel;
        columnData.hideDefaultActions = true;
        DynamicColumn.TypeAttributes typeAttribute = new DynamicColumn.TypeAttributes();
        DynamicColumn.Label labelName = new DynamicColumn.Label();
        labelName.fieldName = fieldName;
        typeAttribute.label = labelName;
        columnData.typeAttributes = typeAttribute;
        return columnData;
    }

    /**
     * @description This method is used to get all parent work orders related to child store accounts or opportunities
     * @param recordId
     * @return List<WorkOrder>
     */
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrderDetails(Id recordId) {
        if (recordId.getSObjectType() == Account.SObjectType) {
            return getParentWorkOrderDetailsFromAccount(recordId);
        } else if (recordId.getSObjectType() == Opportunity.SObjectType) {
            return getParentWorkOrderDetailsFromOpportunity(recordId);
        } else {
            throw new AuraHandledException(
                'Unsupported object type for recordId: ' + String.valueOf(recordId.getSObjectType())
            );
        }
    }

    /**
     * @description This method is used to get all parent work orders related to child store accounts
     * @param accountId
     * @return List<WorkOrder>
     */
    public static List<WorkOrder> getParentWorkOrderDetailsFromAccount(Id accountId) {
        return (List<WorkOrder>) Security.stripInaccessible(
                AccessType.READABLE,
                duplicateRemover(
                    WorkOrdersSelector.newInstance().selectWorkOrdersByAccountId(accountId)
                )
            )
            .getRecords();
    }

    /**
     * @description This method is used to get all parent work orders related to opportunity
     * @param opportunityId
     * @return List<WorkOrder>
     */
    public static List<WorkOrder> getParentWorkOrderDetailsFromOpportunity(Id opportunityId) {
        return (List<WorkOrder>) Security.stripInaccessible(
                AccessType.READABLE,
                WorkOrdersSelector.newInstance().selectWorkOrdersByOpportunityId(opportunityId)
            )
            .getRecords();
    }

    /**
     * @description This method is used to retrive unique parent work order record.
     * @param workOrders
     * @return List<WorkOrder>
     */
    private static List<WorkOrder> duplicateRemover(List<WorkOrder> workOrders) {
        Map<Id, WorkOrder> parentWorkOrders = new Map<Id, WorkOrder>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.ParentWorkOrder != null) {
                parentWorkOrders.put(
                    eachWorkOrder.ParentWorkOrder.Id,
                    eachWorkOrder.ParentWorkOrder
                );
            }
        }
        return parentWorkOrders.values();
    }
}