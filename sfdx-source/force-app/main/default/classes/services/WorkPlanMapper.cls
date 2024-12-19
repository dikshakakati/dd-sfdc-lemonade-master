/**
 * @description used to get applicable work plan templates to provided work order
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.ApexCRUDViolation')
public without sharing class WorkPlanMapper {
    /**
     * @description WorkPlanGenerator's exception class
     * @param workOrderIds list of work order Ids to get mapped work plan for
     * @return Map<Id, Set<String>>
     */
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    public static Map<Id, Set<String>> getMappedWorkPlanTypes(List<String> workOrderIds) {
        Map<Id, Set<String>> woIdToMappedWpTypes = new Map<Id, Set<String>>();
        // work order template Id 2 work plan template type 2 criterion RT Name 2 Criterion

        Map<String, Map<String, Map<String, List<Criterion__c>>>> entries = getWorkOrderEntries(
            workOrderIds
        );
        Set<String> woFieldsToQuery = new Set<String>{
            'Id',
            'Type__c',
            'ParentWorkOrderId',
            'ParentWorkOrder.Type__c'
        };
        woFieldsToQuery.addAll(getWorkOrderFieldsToQuery(entries));

        Map<Id, Set<String>> woIdToExistingWPTypes = new Map<Id, Set<String>>();
        Map<Id, Map<String, Object>> woIdToPopulatedFieldsAsMap = new Map<Id, Map<String, Object>>();
        // JIRA#: LEM-2684 - It is used to maintain mapping of Type field to refer for the Work Plans generation.
        Map<Id, String> woIdToTypeField = new Map<Id, String>();

        for (WorkOrder wo : queryWorkOrderAndWorkplans(workOrderIds, woFieldsToQuery)) {
            woIdToPopulatedFieldsAsMap.put(wo.Id, reformatSObjectRecord(wo, woFieldsToQuery));
            if (wo.ParentWorkOrderId == null) {
                woIdToTypeField.put(wo.Id, 'Type__c');
            } else {
                woIdToTypeField.put(wo.Id, 'ParentWorkOrder.Type__c');
            }
            woIdToExistingWPTypes.put(wo.Id, new Set<String>());
            for (WorkPlan wp : wo.WorkPlans) {
                woIdToExistingWPTypes.get(wo.Id).add(wp.Type__c);
            }
        }

        Map<String, Map<String, List<Criterion__c>>> entry;
        List<Criterion__c> entryCriteria;
        String logicalExpression;
        for (Id woId : woIdToPopulatedFieldsAsMap.keySet()) {
            woIdToMappedWpTypes.put(woId, new Set<String>());
            entry = entries.get(
                (String) woIdToPopulatedFieldsAsMap.get(woId).get(woIdToTypeField.get(woId))
            );
            for (String planType : entry.keySet()) {
                if (woIdToExistingWPTypes.get(woId).contains(planType)) {
                    continue;
                }
                entryCriteria = entry.get(planType).get('Criterion');
                logicalExpression = (entry.get(planType).get('Logic').isEmpty())
                    ? null
                    : entry.get(planType).get('Logic')[0].Criterion_Name__c;
                if (
                    entryCriteria.isEmpty() ||
                    getOutcome(
                        woIdToPopulatedFieldsAsMap.get(woId),
                        entryCriteria,
                        logicalExpression
                    )
                ) {
                    woIdToMappedWpTypes.get(woId).add(planType);
                }
            }
        }
        return woIdToMappedWpTypes;
    }

    @testVisible
    @SuppressWarnings('PMD.ApexCRUDViolation')
    static Set<String> getWorkOrderTypes(List<String> workOrderIds) {
        Set<String> types = new Set<String>();
        for (WorkOrder wo : [
            SELECT ParentWorkOrderId, ParentWorkOrder.Type__c, Type__c
            FROM WorkOrder
            WHERE Id IN :workOrderIds
        ]) {
            // JIRA#: LEM-2684 - Collect Type value from ParentWorkOrder for child Work Order.
            if (wo.ParentWorkOrderId == null) {
                types.add(wo.Type__c);
            } else {
                types.add(wo.ParentWorkOrder.Type__c);
            }
        }
        return types;
    }

    @testVisible
    static Map<String, Map<String, Map<String, List<Criterion__c>>>> getWorkOrderEntries(
        List<String> workOrderIds
    ) {
        Set<String> woTypes = getWorkOrderTypes(workOrderIds);
        Map<String, Map<String, Map<String, List<Criterion__c>>>> entries = new Map<String, Map<String, Map<String, List<Criterion__c>>>>(); // work order template Id 2 work plan template Id 2 criterion RT Name 2 Criterion
        for (Work_Order_Template_Entry__c wote : [
            SELECT
                Id,
                Name,
                Work_Order_Template__r.Type__c,
                Work_Order_Template__c,
                Work_Plan_Template__r.Type__c,
                Work_Plan_Template__c,
                (
                    SELECT
                        Id,
                        Name,
                        Criterion_Name__c,
                        Field__c,
                        Comparator__c,
                        Value__c,
                        Order_Number__c,
                        RecordTypeId,
                        RecordType.Name
                    FROM Criteria__r
                    ORDER BY Order_Number__c ASC NULLS LAST
                )
            FROM Work_Order_Template_Entry__c
            WHERE Work_Order_Template__r.Type__c IN :woTypes
        ]) {
            if (!entries.containsKey(wote.Work_Order_Template__r.Type__c)) {
                entries.put(
                    wote.Work_Order_Template__r.Type__c,
                    new Map<String, Map<String, List<Criterion__c>>>{
                        wote.Work_Plan_Template__r.Type__c => new Map<String, List<Criterion__c>>{
                            'Criterion' => new List<Criterion__c>(),
                            'Logic' => new List<Criterion__c>()
                        }
                    }
                );
            } else if (
                !entries.get(wote.Work_Order_Template__r.Type__c)
                    .containsKey(wote.Work_Plan_Template__r.Type__c)
            ) {
                entries.get(wote.Work_Order_Template__r.Type__c)
                    .put(
                        wote.Work_Plan_Template__r.Type__c,
                        new Map<String, List<Criterion__c>>{
                            'Criterion' => new List<Criterion__c>(),
                            'Logic' => new List<Criterion__c>()
                        }
                    );
            }
            for (Criterion__c cr : wote.Criteria__r) {
                entries.get(wote.Work_Order_Template__r.Type__c)
                    .get(wote.Work_Plan_Template__r.Type__c)
                    .get(cr.RecordType.Name)
                    .add(cr);
            }
        }
        return entries;
    }

    @testVisible
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    static Set<String> getWorkOrderFieldsToQuery(
        Map<String, Map<String, Map<String, List<Criterion__c>>>> entries
    ) {
        Set<String> fields = new Set<String>();
        for (Map<String, Map<String, List<Criterion__c>>> entryValue : entries.values()) {
            for (Map<String, List<Criterion__c>> value : entryValue.values()) {
                for (Criterion__c cr : value.get('Criterion')) {
                    fields.add(cr.Field__c);
                }
            }
        }
        return fields;
    }

    @testVisible
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    static List<WorkOrder> queryWorkOrderAndWorkplans(
        List<String> workOrderIds,
        Set<String> woFieldsToQuery
    ) {
        String queryStringParam = '';

        for (String field : woFieldsToQuery) {
            queryStringParam += ' ,' + field;
        }
        String woQueryString =
            ' SELECT (SELECT Type__c FROM WorkPlans Where Deprecated__c = false) {0} ' +
            ' FROM WorkOrder ' +
            ' WHERE Id IN :workOrderIds';
        return Database.query(String.format(woQueryString, new List<String>{ queryStringParam }));
    }

    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    @testVisible
    static Boolean getOutcome(
        Map<String, Object> fieldNameTofieldValue,
        List<Criterion__c> criteria,
        String logicalExpression
    ) {
        Map<Integer, Boolean> criteriaOrderNumberToOutcome = new Map<Integer, Boolean>();
        for (Criterion__c cr : criteria) {
            if (cr.Order_Number__c < 1) {
                throw new WorkPlanGeneratorException(
                    'Missing field value on Criterion__c: Order_Number__c'
                );
            }
            criteriaOrderNumberToOutcome.put(
                Integer.valueOf(cr.Order_Number__c),
                LogicalComparatorFactory.getComparator(cr.Comparator__c)
                    .compare(fieldNameTofieldValue.get(cr.Field__c), cr.Value__c)
            );
        }
        return LogicalExpressionEvaluator.getOutcome(
            criteriaOrderNumberToOutcome,
            logicalExpression
        );
    }

    @testVisible
    static Map<String, Object> reformatSObjectRecord(SObject record, Set<String> fields) {
        Map<String, Object> fieldToValue = new Map<String, Object>();
        SObject nextSObject;
        String nextField;

        if (fields.contains('Id')) {
            fieldToValue.put('Id', record.get('Id'));
        }

        for (String field : fields) {
            nextSObject = record;
            nextField = field;
            if (nextField.contains('.')) {
                List<String> hierarchicalFields = nextField.split('\\.');
                for (Integer count = 0; count < hierarchicalFields.size() - 1; count++) {
                    nextField = hierarchicalFields[count];
                    nextSObject = nextSObject?.getSObject(nextField);
                }
                nextField = hierarchicalFields[hierarchicalFields.size() - 1];
            }
            fieldToValue.put(field, nextSObject?.get(nextField));
        }
        return fieldToValue;
    }

    /**
     * @description WorkPlanGenerator's exception class
     */
    public class WorkPlanGeneratorException extends Exception {
    }
}