/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Selector Class for Opportunity Object
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class OpportunitiesSelector extends fflib_SObjectSelector implements IOpportunitiesSelector {
    static final String STALLED = 'Stalled';
    private static final String BUSINESS_RECORD_TYPE = System.Label.BusinessAccountRecordTypeName;
    static final string CLOSED = 'Closed';
    static final string CLOSED_WON = 'Closed Won';
    static final string CLOSED_LOST = 'Closed Lost';
    static final string NONE = 'None';
    static final List<String> QUOTE_STATUS = new List<String>{
        'Draft',
        'In Review',
        'Approved',
        'Denied'
    };
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';
    private static final Set<String> NINTEX_USE_CASE_WITH_CONTRACT_FOR_WORK_ORDER_CREATION = new Set<String>{
        'Middleware Provider',
        'SSMO'
    };
    private static final String MX_PORTAL = 'Mx Portal';
    private static final String ONBOARDING_SCENARIO_NSE = 'New Store Expansion';
    private static final String OPPORTUNITY_SUB_TYPE_NEW_STORE_EXPANSION = 'New Store Expansion';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final Set<String> NON_ELIGIBLE_OPPORTUNITY_STAGES = new Set<String>{
        STALLED,
        CLOSED_WON,
        CLOSED_LOST
    };
    private static final Set<String> NON_ELIGIBLE_OPPORTUNITY_STAGES_FOR_WORK_ORDER_CREATION = new Set<String>{
        STALLED,
        CLOSED_LOST
    };
    private static final string SALES_DEVELOPMENT_REP = 'Sales Development Rep';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_PROMOS = 'Ads & Promos';

    /**
     * @description Default constructor for the Opportunity Selector class
     * @return IOpportunitiesSelector - interface of IOpportunitiesSelector
     */
    public static IOpportunitiesSelector newInstance() {
        return (IOpportunitiesSelector) Application.Selector.newInstance(Opportunity.SObjectType);
    }

    /**
     * @description This method is used for getting the fields on Opportunity object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity.Id,
            Opportunity.Business_ID__c,
            Opportunity.Name,
            Opportunity.Description,
            Opportunity.AccountId,
            Opportunity.ContactId,
            Opportunity.CloseDate,
            Opportunity.ContractId,
            Opportunity.CreatedDate,
            Opportunity.CurrencyISOCode,
            Opportunity.Deal_Type__c,
            Opportunity.Deselected_Marketplace_Offerings__c,
            Opportunity.Drive_Nintex_Id__c,
            Opportunity.First_Activity__c,
            Opportunity.FranchiseAmendmentProcess__c,
            Opportunity.IsClosed,
            Opportunity.IsWon,
            Opportunity.Last_Activity__c,
            Opportunity.Marketplace_Nintex_Id__c,
            Opportunity.Nintex_Signed_Date__c,
            Opportunity.Nintex_Use_Case__c,
            Opportunity.Opportunity_Sub_Type__c,
            Opportunity.Opt_In_Opt_Out_Response_Time__c,
            Opportunity.Opt_Out_Save_Period__c,
            Opportunity.OwnerId,
            Opportunity.Responsible_Party__c,
            Opportunity.SBQQ__PrimaryQuote__c,
            Opportunity.Source__c,
            Opportunity.StageName,
            Opportunity.Type,
            Opportunity.Estimated_Total_Investment__c,
            Opportunity.Campaign_TLDR__c,
            Opportunity.Campaign_Program__c,
            Opportunity.Purchase_Order__c,
            Opportunity.Packages_with_Products__c,
            Opportunity.Count_of_Emails_Sent__c,
            Opportunity.Count_of_Calls_Outbound_Inbound__c,
            Opportunity.Days_OFS_to_Next_Step_Date__c,
            Opportunity.Contract_Sent_Date__c,
            Opportunity.Contract_Signed_Date__c,
            Opportunity.First_Qualified_Activity__c,
            Opportunity.Last_Qualified_Activity__c,
            Opportunity.Days_Since_Last_Activity__c,
            Opportunity.Last_Stage_Change__c,
            Opportunity.Days_Since_Last_Stage_Change__c,
            Opportunity.Account_Segment__c,
            Opportunity.First_Activity__c,
            Opportunity.Last_Activity__c,
            Opportunity.Next_Step_Date__c,
            Opportunity.Unique_Identifier__c,
            Opportunity.Pricebook2Id,
            Opportunity.Meeting_Set__c,
            Opportunity.RESSMO_Link__c
        };
    }

    /**
     * @description This method is used for getting object type
     * @return Opportunity- Opportunity fields
     */
    public Schema.SObjectType getSObjectType() {
        return Opportunity.SObjectType;
    }

    /**
     * @description This method is used for getting Opportunities based on ID
     * @param setIds Set of Ids
     * @return list of Opportunity records
     */
    public List<Opportunity> selectById(Set<Id> setIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :setIds');
        query.selectField('Account.RecordType.DeveloperName');
        query.selectField('Account.Data_Verification_Status__c');
        query.selectField('Account.Address_Verification_Status__c');
        query.selectField('Account.Segment__c');
        query.selectField('Account.DoorDash_Legal_Entity__c');
        query.selectField('Account.Primary_Vertical__c');
        query.selectField('Account.Preferred_Language__c');
        query.selectField('Account.Legal_Business_Name__c');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This method querying Opportunities by AccountId.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesByAccountId(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('AccountId IN :accountIds');
        query.selectField('IsClosed');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to get List of Opportunities based
     * @description This method is to get the list of opportunities in Stalled Stage and not updated
     * in the last passed number of days.
     * @param numberOfDays
     * @return list of Opportunity records
     */
    public Database.QueryLocator selectInactiveOpportunityInStalledStage(Integer numberOfDays) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Stagename =: STALLED AND (CloseDate < TODAY OR' +
            ' (LastModifiedDate < ' +
            'LAST_N_DAYS :' +
            numberOfDays +
            ' AND LastActivityDate < ' +
            'LAST_N_DAYS :' +
            numberOfDays +
            '))'
        );
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description This method is used to get List of Opportunities based
     *  on child Product_Insights__c Id
     * @param childInsights
     * @return List<Opportunity>
     */
    public List<Opportunity> selectByInsights(List<Product_Insights__c> childInsights) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Product_Insights__c eachChildInsight : childInsights) {
            if (eachChildInsight.Opportunity__c != null) {
                opportunityIds.add(eachChildInsight.Opportunity__c);
            }
        }
        return selectById(opportunityIds);
    }

    /**
     * @description This method is used for querying all open Opportunities without related quotes or opportunity products
     * associated with provided set of account Ids.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpenOpportunitiesByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Account.CurrencyIsoCode');
        query.setCondition(
            'AccountId IN :accountIds AND ForecastCategory != :CLOSED AND Id NOT IN (SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.AccountId IN :accountIds) AND Id NOT IN (SELECT OpportunityId FROM OpportunityLineItem WHERE Opportunity.AccountId IN :accountIds)'
        );
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get all Opportunities having Nintex Id populated
     * using the passed Opportunity Ids.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesWithNintexIdById(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Contract.' + System.Label.DriveAutoProvisioningIndicator)
            .selectField('Contract.Payment_Method__c')
            .selectField('Drive_Nintex_Id__c')
            .selectField('Marketplace_Nintex_Id__c')
            .selectField('Nintex_Use_Case__c')
            .selectField('Account.Segment__c')
            .selectField('OwnerId')
            .setCondition(
                'Nintex_Use_Case__c != null AND ' +
                '(Drive_Nintex_Id__c != null OR Marketplace_Nintex_Id__c != null) AND ' +
                'Id IN :opportunityIds AND' +
                '((Nintex_Use_Case__c IN :NINTEX_USE_CASE_WITH_CONTRACT_FOR_WORK_ORDER_CREATION AND ContractId != null) OR ' +
                '(Nintex_Use_Case__c NOT IN :NINTEX_USE_CASE_WITH_CONTRACT_FOR_WORK_ORDER_CREATION))'
            );

        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for querying all the opportunities with Primary Quote populated
     * associated with provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesWithQuotes(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('SBQQ__PrimaryQuote__c');
        query.selectField('SBQQ__PrimaryQuote__r.ApprovalStatus__c');
        query.selectField('SBQQ__PrimaryQuote__r.HasPipelineProduct__c');
        query.setCondition('Id IN :opportunityIds AND SBQQ__PrimaryQuote__c!=null');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is being used to get the query the Opportunities record which associated contract and quotes which are created from Nintex.
     * @JIRA# LEM-2131
     * @param opportunityIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesWithNintexUseCase(Set<Id> opportunityIds) {
        fflib_QueryFactory query = getNintexCreatedOpportunities();
        String conditionExpression = query.getCondition() + ' AND Id IN :opportunityIds';
        query.setCondition(conditionExpression);
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is being used to get the query the Opportunities record which associated contract and quotes which are created from Nintex.
     * @JIRA# LEM-2131
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectOpportunitiesWithNintexUseCaseQueryLocator() {
        return Database.getQueryLocator(getNintexCreatedOpportunities().toSOQL());
    }

    /**
     * @description This method is being used to get the query the Opportunities record which associated contract and quotes which are created from Nintex.
     * @JIRA# LEM-2131
     * @return fflib_QueryFactory
     */
    private fflib_QueryFactory getNintexCreatedOpportunities() {
        return newQueryFactory()
            .selectField('Account.OwnerId')
            .selectField('Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_In_Out_Responsible_Party__c')
            .selectField(
                'Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_In_Opt_Out_Response_Time_in_Days__c'
            )
            .selectField('Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_In_Opt_Out_Decision__c')
            .selectField('Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_Out_Save_Period_days__c')
            .setCondition(
                'Nintex_Use_Case__c != null AND Nintex_Use_Case__c != :NONE AND ContractId != null AND ' +
                'Contract.SBQQ__Order__r.SBQQ__Quote__c != null AND IsClosed = false'
            );
    }
    /**
     * @description select opps to write back to from the brief
     * @JIRA LEM-9264
     * @param oppIds
     * @return List<Opportunity>
     */

    public List<Opportunity> getOpportunitiesToSyncFromBriefs(Set<Id> oppIds) {
        Set<Schema.SObjectField> additionalFields = OpportunityToBriefMappingSelector.newInstance()
            .getOpportunityFieldSet();
        fflib_QueryFactory query = newQueryFactory();
        for (Schema.SObjectField field : additionalFields) {
            query.selectField(field);
        }
        query.setCondition('Id IN :oppIds');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for selecting the opportunities and related quotes when
     * accountIds are passed.
     * @JIRA LEM-13473
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesAndQuotesByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('AccountId IN :accountIds AND IsClosed = false');
        query.selectField('AccountId');
        QuotesSelector quoteSelector = new QuotesSelector();
        // Added to ignore CRUD check while querying Quote object.
        quoteSelector.ignoreCRUD();
        quoteSelector.addQueryFactorySubselect(query, 'SBQQ__Quotes2__r')
            .selectField('SBQQ__Status__c')
            .setCondition('SBQQ__Status__c IN :QUOTE_STATUS AND SBQQ__Primary__c = TRUE');
        new OpportunityContactRoleSelector()
            .addQueryFactorySubselect(query, 'OpportunityContactRoles')
            .setCondition('Role =: CONTRACT_SIGNATORY_CONTACT_ROLE AND IsPrimary = TRUE');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for selecting the opportunities and related OpportunityContactRoles by
     * passing opportunity ids and contact ids.
     * @param opportunityIds
     * @param contactIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesAndOpportunityContactRolesByIds(
        Set<Id> opportunityIds,
        List<Id> contactIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('AccountId')
            .setCondition('Id IN :opportunityIds');
        new OpportunityContactRoleSelector()
            .addQueryFactorySubselect(query, 'OpportunityContactRoles')
            .setCondition('ContactId IN :contactIds');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to select opportunities by the passed unique identifiers.
     * @JIRA LEM-14588
     * @param uniqueIdentifiers
     * @return List<Opportunity>
     */
    public List<Opportunity> getOpportunitiesbyUniqueIdentifiers(Set<String> uniqueIdentifiers) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('AccountId')
            .selectField('Account.Name')
            .selectField('Id')
            .selectField('Unique_Identifier__c')
            .selectField('ContactId')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiers');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to select opportunities by the passed Account Plan Ids.
     * @JIRA LEM-15227
     * @param accountPlanIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpenOpportunitiesByAccountPlanIds(Set<Id> accountPlanIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .setCondition('Account_Plan__c IN :accountPlanIds AND IsClosed = false');
        new ProductInsightsSelector()
            .addQueryFactorySubselect(query, 'Product_Insights__r')
            .selectField('Lever__c');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for selecting the opportunities and related quotes by
     * passed Account Ids.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(
        Set<Id> accountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('SBQQ__PrimaryQuote__c')
            .selectField('Unique_Identifier__c')
            .selectField('ContactId')
            .selectField('Account.Name')
            .selectField('AccountId')
            .setCondition(
                'AccountId IN :accountIds AND ' +
                'StageName NOT IN :NON_ELIGIBLE_OPPORTUNITY_STAGES AND ' +
                '((Type = :OPPORTUNITY_TYPE_NEW AND ' +
                'Opportunity_Sub_Type__c = :OPPORTUNITY_SUB_TYPE_NET_NEW) OR (Source__c = :MX_PORTAL AND Type = :OPPORTUNITY_TYPE_EXISTING))'
            );
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for selecting the Open or Closed Won opportunities by
     * passed Account Ids.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectNewStoreExpansionOpportunitiesByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('AccountId')
            .selectField('Is_Updated_By_Onboarding_Inputs__c')
            .setCondition(
                'AccountId IN :accountIds AND ' +
                'StageName NOT IN :NON_ELIGIBLE_OPPORTUNITY_STAGES_FOR_WORK_ORDER_CREATION AND ' +
                'Type = :OPPORTUNITY_TYPE_EXISTING AND ' +
                'Opportunity_Sub_Type__c = :OPPORTUNITY_SUB_TYPE_NEW_STORE_EXPANSION'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to Query opportunities with associated Opportunity Team Member
     * by passing opportunity ids.
     * @param opportunityIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(
        Set<Id> opportunityIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('SDR_Opportunity_Owner__c')
            .setCondition('Id IN :opportunityIds');
        new OpportunityTeamMembersSelector()
            .addQueryFactorySubselect(query, 'OpportunityTeamMembers')
            .selectField('UserId')
            .setCondition('TeamMemberRole = :SALES_DEVELOPMENT_REP')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This method used for querying Opportunities by ContractId.
     * @param contractId
     * @return List<Opportunity>
     */
    public List<Opportunity> selectOpportunitiesByContractId(Id contractId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ContractId =:contractId');
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for selecting the opportunities by Id and related OpportunityContactRoles with condition
     * @author SamikshaDD | 08-01-2024
     * @param opportunityId
     * @param objectToSobjectsFields
     * @return Opportunity
     **/
    public Opportunity selectOpportunityContactRoleByOpportunityId(
        Id opportunityId,
        Map<String, Set<String>> objectToSobjectsFields
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .setCondition('Id = :opportunityId');
        new OpportunityContactRoleSelector()
            .addQueryFactorySubselect(query, 'OpportunityContactRoles')
            .selectFields(objectToSobjectsFields.get('Contact'))
            .selectField('Contact.Unique_Identifier__c')
            .setCondition('Role =: CONTRACT_SIGNATORY_CONTACT_ROLE')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);

        return (Opportunity) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for selecting the opportunities and related quotes by
     * passed Account Ids for non Ads and Promos sub type.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectExistingNonAdsAndPromosOpportunities(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('SBQQ__PrimaryQuote__c')
            .selectField('Unique_Identifier__c')
            .selectField('ContactId')
            .selectField('Account.Name')
            .selectField('AccountId')
            .setCondition(
                'AccountId IN :accountIds AND ' +
                'StageName NOT IN :NON_ELIGIBLE_OPPORTUNITY_STAGES AND ' +
                'Type = :OPPORTUNITY_TYPE_EXISTING AND ' +
                'Opportunity_Sub_Type__c != :OPPORTUNITY_SUB_TYPE_ADS_PROMOS'
            );
        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to select Opportunities by Sub Type and AccountIds where Sub Type
     * is NSE and Stage is not closed.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectBySubTypeAndAccount(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'AccountId IN :accountIds AND Opportunity_Sub_Type__c = :ONBOARDING_SCENARIO_NSE ' +
                'AND IsClosed = false'
            )
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);

        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    /**
     * @description This is used to select Open Opportunities by AccountId.
     * @param accountIds
     * @return List<Opportunity>
     */
    public List<Opportunity> selectAllOpenOpportunitiesByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory opportunityQuery = newQueryFactory()
            .selectField('IsClosed')
            .selectField('Mx_Tag_Associations_Concatenated__c')
            .setCondition(
                'AccountId IN :accountIds AND ' +
                'Account.RecordType.Name = :BUSINESS_RECORD_TYPE ' +
                'AND IsClosed = false'
            );
        return (List<Opportunity>) Database.query(opportunityQuery.toSOQL());
    }
}