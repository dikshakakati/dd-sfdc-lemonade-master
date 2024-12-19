/**
 * @author Deloitte
 * @date 06/11/2024
 * @description Controller class for Cloning Account Plan.
 */
public with sharing class CloneAccountPlanController {
    private static final String ACTIVE = 'Active';
    private static final String ACCOUNT_OWNER = 'Account Owner';
    private static final String COMPLETED = 'Completed';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_RECORD_CREATION_ERROR = 'Exception occured during record creation.';
    private static final String NOT_ON_ACCOUNT_TEAM = 'Not on Account Team';
    private static final String REJECTED = 'Rejected by Merchant';
    private static final String QUARTER_ONE = 'Q1';
    private static final String QUARTER_TWO = 'Q2';
    private static final String QUARTER_THREE = 'Q3';
    private static final String QUARTER_FOUR = 'Q4';
	private static final String INACTIVE = 'Inactive';
    
    /**
     * @description It is used to clone the Account Plan and Reparent the child records.
     * @JIRA# LEM-15227
     * @param flowInputs
     * @return List<Id>
     */
    @InvocableMethod(label='Clone Account Plan' description='LEM-15227: It clones the Account Plan')
    public static List<Id> cloneAccountPlan(List<CloneAccountPlanFlowInputs> flowInputs) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account accountRecord = AccountsSelector.newInstance()
            .selectById(new Set<Id>{ flowInputs[0].accountPlanRecord.Account__c })[0];
        Account_Plan__c newAccountPlan = new Account_Plan__c();
        newAccountPlan.Status__c = INACTIVE;
        newAccountPlan.Account__c = flowInputs[0].accountPlanRecord.Account__c;
        newAccountPlan.Name = getAccountPlanName(accountRecord.Name);
        newAccountPlan.Created_By_Role__c = getCreatedByRole(
            accountRecord,
            flowInputs[0].runningUserId
        );
        uow.registerNew(newAccountPlan);
        commitWork(uow);
        cloneAndReparentChildRecords(flowInputs[0].accountPlanRecord, newAccountPlan.Id);
        return new List<Id>{ newAccountPlan.Id };
    }

    /**
     * @description It is used to clone the Levers and Reparent the child records.
     * @JIRA# LEM-15227
     * @param accountPlanRecord
     * @param accountPlanId
     */
    private static void cloneAndReparentChildRecords(
        Account_Plan__c accountPlanRecord,
        Id accountPlanId
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> openOpportunityIds = new Set<Id>();
        Map<Id, List<Product_Insights__c>> oldLeverIdToProductInsightMap = new Map<Id, List<Product_Insights__c>>();
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectOpenOpportunitiesByAccountPlanIds(new Set<Id>{ accountPlanRecord.Id })
        ) {
            openOpportunityIds.add(eachOpportunity.Id);
            eachOpportunity.Account_Plan__c = accountPlanId;
            uow.registerDirty(eachOpportunity);
        }
        for (
            Lever__c eachLever : LeversSelector.newInstance()
                .selectOpenLeversByAccountPlanId(new Set<Id>{ accountPlanRecord.Id })
        ) {
            createLeverRecord(eachLever, accountPlanId, uow);
        }
        for (
            Product_Insights__c eachProductInsight : ProductInsightsSelector.newInstance()
                .selectProductInsightsByOpportunityIds(openOpportunityIds)
        ) {
            if (!oldLeverIdToProductInsightMap.containsKey(eachProductInsight.Lever__c)) {
                oldLeverIdToProductInsightMap.put(
                    eachProductInsight.Lever__c,
                    new List<Product_Insights__c>()
                );
            }
            oldLeverIdToProductInsightMap.get(eachProductInsight.Lever__c).add(eachProductInsight);
            if (
                eachProductInsight.Lever__r.Status__c == COMPLETED ||
                eachProductInsight.Lever__r.Status__c == REJECTED
            ) {
                createLeverRecord(eachProductInsight.Lever__r, accountPlanId, uow);
            }
        }
        commitWork(uow);
        reparentProductInsights(oldLeverIdToProductInsightMap);
    }

    /**
     * @description It is used to get the Name of the Account Plan.
     * @JIRA# LEM-15227
     * @param accountName
     * @return String
     */
    private static String getAccountPlanName(String accountName) {
        Date today = System.today();
        String quarter;
        String year = String.valueOf(today.year());
        switch on today.month() {
            when 1, 2, 3 {
                quarter = QUARTER_ONE;
            }
            when 4, 5, 6 {
                quarter = QUARTER_TWO;
            }
            when 7, 8, 9 {
                quarter = QUARTER_THREE;
            }
            when else {
                quarter = QUARTER_FOUR;
            }
        }
        return accountName + ': ' + quarter + ' ' + year.substring(2);
    }

    /**
     * @description It is used to get the Created by Role of Account Plan.
     * @JIRA# LEM-15227
     * @param accountRecord
     * @param runningUserId
     * @return String
     */
    private static String getCreatedByRole(Account accountRecord, Id runningUserId) {
        if (runningUserId == accountRecord.OwnerId) {
            return ACCOUNT_OWNER;
        }
        for (
            AccountTeamMember eachMember : AccountTeamMembersSelector.newInstance()
                .selectAccountTeamMembersByAccountId(accountRecord.Id)
        ) {
            if (eachMember.UserId == runningUserId) {
                return eachMember.TeamMemberRole;
            }
        }
        return NOT_ON_ACCOUNT_TEAM;
    }

    /**
     * @description It is used to create the Lever Record.
     * @JIRA# LEM-15227
     * @param oldLever
     * @param accountPlanId
     * @param uow
     * @return Lever__c
     */
    private static Lever__c createLeverRecord(
        Lever__c oldLever,
        Id accountPlanId,
        fflib_ISObjectUnitOfWork uow
    ) {
        Lever__c newLever = new Lever__c();
        newLever.Account__c = oldLever.Account__c;
        newLever.Account_Plan__c = accountPlanId;
        newLever.Confidence_Level__c = oldLever.Confidence_Level__c;
        newLever.Interest_Level__c = oldLever.Interest_Level__c;
        newLever.Predicted_Incremental_Sales__c = oldLever.Predicted_Incremental_Sales__c;
        newLever.Rejection_Reason__c = oldLever.Rejection_Reason__c;
        newLever.Solution__c = oldLever.Solution__c;
        newLever.Status__c = oldLever.Status__c;
        newLever.Cloned_From_Lever_Id__c = oldLever.Id;
        uow.registerNew(newLever);
        return newLever;
    }

    /**
     * @description It is used to reparent the Product Insight records.
     * @JIRA# LEM-15227
     * @param oldLeverIdToProductInsightMap
     */
    private static void reparentProductInsights(
        Map<Id, List<Product_Insights__c>> oldLeverIdToProductInsightMap
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            Lever__c eachLever : LeversSelector.newInstance()
                .selectByClonedLeverId(oldLeverIdToProductInsightMap.keySet())
        ) {
            if (oldLeverIdToProductInsightMap.get(eachLever.Cloned_From_Lever_Id__c).isEmpty()) {
                continue;
            }
            for (
                Product_Insights__c eachProductInsight : oldLeverIdToProductInsightMap.get(
                    eachLever.Cloned_From_Lever_Id__c
                )
            ) {
                eachProductInsight.Lever__c = eachLever.Id;
                uow.registerDirty(eachProductInsight);
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is a common method to commit unit of work.
     * @JIRA# LEM-15227
     * @param uow
     */
    private static void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_RECORD_CREATION_ERROR,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }
}