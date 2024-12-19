/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Controller class for Opportunity Creation.
 */
public with sharing class OpportunityCreationController {
    private static final String ACTIVE = 'Active';
    private static final String ADS_AND_PROMOS = 'Ads & Promos';
    private static final Set<String> ADS_PROMOS_CATEGORIES = new Set<String>{
        'Ads',
        'Promos',
        'ads',
        'promos'
    };
    private static final String FULL_SERVE = 'Full-Serve';
    private static final String HYPHEN = '-';
    private static final String IN_PROGRESS = 'In Progress';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_RECORD_CREATION_ERROR = 'Exception occured during record creation.';
    private static final String TO_BE_EVALUATED = 'To Be Evaluated';
    private static final String VSP = '-VSP:';
    private static final String VSP_RECOMMENDATION = 'VSP Recommendation';
    private static final Integer OPPORTUNITY_NAME_LENGTH = 120;

    /**
     * @description It is invoked from a flow to assign the Name to an Opportunity.
     * @param  flowInputs
     */
    @InvocableMethod(
        label='Assign Opportunity Name'
        description='LEM-15224: Assign the Opportunity Name for VSP'
    )
    public static void assignOpportunityNameForVSP(List<OpportunityCreationFlowInputs> flowInputs) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Opportunity opportunityRecord = flowInputs[0].opportunityRecord;
        Account accountRecord = new Account();
        Set<Id> leverIds = (new Map<Id, SObject>(flowInputs[0].levers)).keySet();
        Set<Id> accPlanIds = new Set<Id>{ flowInputs[0].accountPlanId };
        Boolean updateSubType = false;
        String leverSuffix = '';
        for (Lever__c eachLever : LeversSelector.newInstance().selectById(leverIds)) {
            if (ADS_PROMOS_CATEGORIES.contains(eachLever.Solution__r.Product_Family__c)) {
                updateSubType = true;
            }
            leverSuffix += eachLever.Solution_Name__c + HYPHEN;
            accountRecord = eachLever.Account__r;
        }
        if (updateSubType) {
            opportunityRecord.Opportunity_Sub_Type__c = ADS_AND_PROMOS;
            opportunityRecord.Deal_Type__c = FULL_SERVE;
        }
        if (opportunityRecord.AccountId != null) {
            Opportunities.newInstance(new List<Opportunity>{ opportunityRecord })
                .formulateName(opportunityRecord, accountRecord, 40);
        }
        opportunityRecord.Name += VSP;
        opportunityRecord.Name += leverSuffix.removeEnd(HYPHEN);
        if ((opportunityRecord.Name).length() > OPPORTUNITY_NAME_LENGTH) {
            opportunityRecord.Name = (opportunityRecord.Name)
                .substring(
                    0,
                    ((opportunityRecord.Name).substring(0, OPPORTUNITY_NAME_LENGTH))
                        .lastIndexof('-')
                );
        }

        uow.registerDirty(opportunityRecord);
        commitWork(uow);
        Map<Id, List<Id>> leverIdToProductInsightIds = new Map<Id, List<Id>>();
        for (
            Product_Insights__c eachProductInsight : ProductInsightsSelector.newInstance()
                .selectProductInsightsByLeverIdAndAccPlanId(leverIds, accPlanIds)
        ) {
            if (!leverIdToProductInsightIds.containsKey(eachProductInsight.Lever__c)) {
                leverIdToProductInsightIds.put(
                    eachProductInsight.Lever__c,
                    new List<Id>{ eachProductInsight.Id }
                );
            } else {
                leverIdToProductInsightIds.get(eachProductInsight.Lever__c)
                    .add(eachProductInsight.Id);
            }
        }
        createProductInsightRecords(flowInputs[0], leverIdToProductInsightIds);
    }

    /**
     * @description It is used to create the Product Insight record for each Lever.
     * @param  flowInput
     * @param leverIdToProductInsightIds
     */
    private static void createProductInsightRecords(
        OpportunityCreationFlowInputs flowInput,
        Map<Id, List<Id>> leverIdToProductInsightIds
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Product_Insights__c newProductInsight;

        for (Lever__c eachLever : flowInput.levers) {
            if (
                !leverIdToProductInsightIds.isEmpty() &&
                leverIdToProductInsightIds.containsKey(eachLever.Id)
            ) {
                for (Id productInsightId : leverIdToProductInsightIds.get(eachLever.Id)) {
                    newProductInsight = new Product_Insights__c(
                        Id = productInsightId,
                        Opportunity__c = flowInput.opportunityRecord.Id
                    );
                    uow.registerDirty(newProductInsight);
                }
            } else {
                newProductInsight = new Product_Insights__c();
                newProductInsight.Account_Name__c = flowInput.opportunityRecord.AccountId;
                newProductInsight.Opportunity__c = flowInput.opportunityRecord.Id;
                if (eachLever.Solution__c != null) {
                    newProductInsight.Product__c = eachLever.Solution__c;
                } else {
                    uow.registerNew(
                        newProductInsight,
                        Product_Insights__c.Product__c,
                        getSolution(eachLever)
                    );
                }
                newProductInsight.Lever__c = eachLever.Id;
                newProductInsight.Origin__c = VSP_RECOMMENDATION;
                newProductInsight.Interest_Level__c = TO_BE_EVALUATED;
                newProductInsight.Account_Plan__c = flowInput.accountPlanId;
                newProductInsight.Predicted_Sales_Uplift__c = eachLever.Predicted_Incremental_Sales__c;
                eachLever.Status__c = IN_PROGRESS;
                uow.registerDirty(new Lever__c(Id = eachLever.Id, Status__c = IN_PROGRESS));
                uow.registerNew(newProductInsight);
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is used to get the Solution Id related to the Lever.
     * @param lever
     * @return Campaign_Product__c
     */
    private static Campaign_Product__c getSolution(Lever__c lever) {
        return new Campaign_Product__c(Name = lever.Name, Status__c = ACTIVE);
    }

    /**
     * @description A common method to commit unit of work.
     * @JIRA# LEM-15224
     * @param uow
     */
    private static void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
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