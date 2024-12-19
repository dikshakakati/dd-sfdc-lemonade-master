/**
 * @author Deloitte
 * @date 10/05/2022
 * @description Service implementation class for WorkStepDependencies related logic.
 */
public inherited sharing class WorkStepDependenciesServiceImpl implements IWorkStepDependenciesService {
    private static final String BANNER_MESSAGE_CONNECTOR = ' and ';
    private static final String BANNER_MESSAGE_EMPTY_STRING = '';
    private static final String BANNER_MESSAGE_LIST_START_STRING = '(';
    private static final String BANNER_MESSAGE_LIST_END_STRING = ')';
    private static final String DEPENDENCY_COUNT_AGGREGATE_QUERY_COUNTFIELD_ALIAS = 'dependenciesCount';
    private static final String DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'groupingId';
    private static final String DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_STATUS_ALIAS = 'dependeeStatus';
    private enum ParentObjectTypes {
        ACCOUNT,
        WORKORDER,
        WORKPLAN,
        WORKSTEP
    }
    private static final Map<Schema.SobjectType, ParentObjectTypes> SOBJECTTYPETOPARENTOBJECTTYPES = new Map<Schema.SobjectType, ParentObjectTypes>{
        Account.SObjectType => ParentObjectTypes.ACCOUNT,
        WorkOrder.SObjectType => ParentObjectTypes.WORKORDER,
        WorkPlan.SObjectType => ParentObjectTypes.WORKPLAN,
        WorkStep.SObjectType => ParentObjectTypes.WORKSTEP
    };
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_RELATIONSHIP_FIELD = 'Dependent_Work_Step__r';
    private static final String WORK_STEP_WORK_PLAN_ID_FIELD = 'WorkPlanId';

    /**
     * @description It checks dependee WorkSteps's Status to enable the banner
     * and get the message by concatenating and formatting the dependee WorkSteps' name.
     * @JIRA# LEM-1217 & LEM-1436
     * @param sObjectId - Id of WorkPlan or WorkStep
     * @return BannerMessageWrapper
     */
    public BannerMessageWrapper getBannerMessageDetails(Id sObjectId) {
        String bannerMessage;
        BannerMessageWrapper bannerMessageWrapper = new BannerMessageWrapper(
            String.isNotBlank(bannerMessage),
            bannerMessage
        );
        Schema.SObjectType sObjectType = sObjectId.getSobjectType();
        Map<Id, Map<Id, List<String>>> workPlanIdToWorkStepIdToDependeeWorkStepNames = getDependeeWorkStepNames(
            new Set<Id>{ sObjectId },
            sObjectType
        );
        if (
            workPlanIdToWorkStepIdToDependeeWorkStepNames == null ||
            workPlanIdToWorkStepIdToDependeeWorkStepNames.isEmpty()
        ) {
            return bannerMessageWrapper;
        }
        List<String> dependeeWorkStepNames = new List<String>();
        for (Id eachWorkPlanId : workPlanIdToWorkStepIdToDependeeWorkStepNames.keySet()) {
            Map<Id, List<String>> workStepIdToDependeeWorkStepNames = workPlanIdToWorkStepIdToDependeeWorkStepNames.get(
                eachWorkPlanId
            );
            switch on SOBJECTTYPETOPARENTOBJECTTYPES.get(sObjectType) {
                when WORKPLAN {
                    for (Id eachWorkStepId : workStepIdToDependeeWorkStepNames.keySet()) {
                        dependeeWorkStepNames.addAll(
                            workStepIdToDependeeWorkStepNames.get(eachWorkStepId)
                        );
                    }
                }
                when WORKSTEP {
                    dependeeWorkStepNames = workStepIdToDependeeWorkStepNames.get(sObjectId);
                }
            }
        }
        bannerMessage = generateMessage(removeDuplicateNames(dependeeWorkStepNames));
        bannerMessageWrapper = new BannerMessageWrapper(
            String.isNotBlank(bannerMessage),
            bannerMessage
        );
        return bannerMessageWrapper;
    }

    /**
     * @description It generates the message using the passed dependee WorkStep names
     * by formating the message custom label.
     * @JIRA# LEM-1436
     * @param workStepNames
     * @return String
     */
    private String generateMessage(List<String> workStepNames) {
        if (workStepNames == null || workStepNames.isEmpty()) {
            return null;
        }
        String workStepNamesInMessage = workStepNames.toString()
            .removeStart(BANNER_MESSAGE_LIST_START_STRING)
            .removeEnd(BANNER_MESSAGE_LIST_END_STRING);
        return String.format(
            System.Label.WorkStepDependenciesMessage,
            new List<Object>{ workStepNamesInMessage }
        );
    }

    /**
     * @description It collects dependee WorkSteps of dependent WorkPlanIds or WorkStepIds where
     * Status is still pending completion.
     * @JIRA# LEM-1436
     * @param sObjectIds - Set of WorkStepIds or Set of WorkPlanIds
     * @param sObjectType - Object type to identify query condition
     * @return Map<Id, Set<String>> - map of WorkPlanId to WorkStepId
     * to dependee WorkStep's names
     */
    public Map<Id, Map<Id, List<String>>> getDependeeWorkStepNames(
        Set<Id> sObjectIds,
        Schema.SObjectType sObjectType
    ) {
        Map<Id, Map<Id, List<String>>> workPlanIdToWorkStepIdToDependeeWorkStepNames = new Map<Id, Map<Id, List<String>>>();
        if (sObjectIds.isEmpty()) {
            return workPlanIdToWorkStepIdToDependeeWorkStepNames;
        }
        Id workPlanId;
        for (
            WorkStepDependency__c eachWorkStepDependency : WorkStepDependenciesSelector.newInstance()
                .selectDependeeWorkStepsByDependentSobjectIds(
                    sObjectIds,
                    getQueryDependeeFieldBySOBjectType(sObjectType)
                )
        ) {
            // Get WorkPlanId from WorkStepDependency record through relationship field: Dependent_Work_Step__r.WorkPlanId
            workPlanId = (Id) eachWorkStepDependency.getSobject(WORK_STEP_RELATIONSHIP_FIELD)
                ?.get(WORK_STEP_WORK_PLAN_ID_FIELD);
            if (!workPlanIdToWorkStepIdToDependeeWorkStepNames.containsKey(workPlanId)) {
                workPlanIdToWorkStepIdToDependeeWorkStepNames.put(
                    workPlanId,
                    new Map<Id, List<String>>()
                );
            }
            if (
                !workPlanIdToWorkStepIdToDependeeWorkStepNames.get(workPlanId)
                    .containsKey(eachWorkStepDependency.Dependent_Work_Step__c)
            ) {
                workPlanIdToWorkStepIdToDependeeWorkStepNames.get(workPlanId)
                    .put(eachWorkStepDependency.Dependent_Work_Step__c, new List<String>());
            }
            workPlanIdToWorkStepIdToDependeeWorkStepNames.get(workPlanId)
                .get(eachWorkStepDependency.Dependent_Work_Step__c)
                .add(eachWorkStepDependency.Dependee_Work_Step__r.Name);
        }
        return workPlanIdToWorkStepIdToDependeeWorkStepNames;
    }

    /**
     * @description It collects dependent WorkStepIds for which all dependee WorkSteps have
     * Status as Complete.
     * @JIRA# LEM-1142
     * @JIRA# LEM-1217 - Moved to service class
     * @param sObjectIds - Set of WorkStepIds or Set of WorkPlanIds
     * @param sObjectType - Object type to identify grouping field
     * @return Map<Id, Set<String>> - Map of WorkStepId or WorkPlanId and associated Statueses
     */
    public Map<Id, Set<String>> getSobjectIdToDependeeWorkStepStatuses(
        Set<Id> sObjectIds,
        Schema.SObjectType sObjectType
    ) {
        Map<Id, Set<String>> sObjectIdToDependeeWorkStepStatuses = new Map<Id, Set<String>>();
        if (sObjectIds.isEmpty()) {
            return sObjectIdToDependeeWorkStepStatuses;
        }
        Id groupingId;
        String dependeeWorkStepStatus;
        for (
            Aggregate eachAggregate : WorkStepDependenciesSelector.newInstance()
                .getWorkStepDependencyCountFilteredAndGroupedBySobjectIds(
                    sObjectIds,
                    getQueryDependeeFieldBySOBjectType(sObjectType)
                )
        ) {
            groupingId = (Id) eachAggregate.get(
                DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS
            );
            dependeeWorkStepStatus = String.valueOf(
                eachAggregate.get(DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_STATUS_ALIAS)
            );
            if (!sObjectIdToDependeeWorkStepStatuses.containsKey(groupingId)) {
                sObjectIdToDependeeWorkStepStatuses.put(groupingId, new Set<String>());
            }
            sObjectIdToDependeeWorkStepStatuses.get(groupingId).add(dependeeWorkStepStatus);
        }
        return sObjectIdToDependeeWorkStepStatuses;
    }

    /**
     * @description It returns field used for filtering and grouping dependent WorkSteps.
     * @JIRA# LEM-1217 & LEM-1436
     * @param sObjectType - Object type to identify grouping field
     * @return SObjectField
     */
    public SObjectField getQueryDependeeFieldBySOBjectType(Schema.SObjectType sObjectType) {
        SObjectField fieldToFilter;
        switch on SOBJECTTYPETOPARENTOBJECTTYPES.get(sObjectType) {
            when WORKPLAN {
                fieldToFilter = WorkStepDependency__c.Dependent_Work_Plan_Id__c;
            }
            when WORKSTEP {
                fieldToFilter = WorkStepDependency__c.Dependent_Work_Step__c;
            }
        }
        return fieldToFilter;
    }

    /**
     * @description It removes duplicate WorkStep name from the passed list.
     * @JIRA# LEM-1436
     * @param workStepNames
     * @return List<String>
     */
    private List<String> removeDuplicateNames(List<String> workStepNames) {
        List<String> correctedWorkStepNames = new List<String>();
        if (workStepNames == null || workStepNames.isEmpty()) {
            return correctedWorkStepNames;
        }
        for (String eachName : workStepNames) {
            if (correctedWorkStepNames.contains(eachName)) {
                continue;
            }
            correctedWorkStepNames.add(eachName);
        }
        return correctedWorkStepNames;
    }
}