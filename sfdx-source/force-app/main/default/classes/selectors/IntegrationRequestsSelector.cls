/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Selector class for Integration_Request__c object.
 */
public inherited sharing class IntegrationRequestsSelector extends fflib_SObjectSelector implements IIntegrationRequestsSelector {
    private static final String SFDC_STATUS_PROCESSED = 'Processed';
    private static final Datetime FOUR_MINUTES_AGO = Datetime.now().addMinutes(-4);
    private static final Datetime FIFTEEN_MINUTES_AGO = Datetime.now().addMinutes(-15);

    /**
     * @description default constructor for the class
     * @return IIntegrationRequestsSelector
     */
    public static IIntegrationRequestsSelector newInstance() {
        return (IIntegrationRequestsSelector) Application.Selector.newInstance(
            Integration_Request__c.SObjectType
        );
    }
    /**
     * @description override default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Integration_Request__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Work Order
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Integration_Request__c.Id,
            Integration_Request__c.Action__c,
            Integration_Request__c.Activation_Date__c,
            Integration_Request__c.Business_Id__c,
            Integration_Request__c.Store_Id__c,
            Integration_Request__c.Provider_Account_Owner_Email__c,
            Integration_Request__c.Onboarding_Type__c,
            Integration_Request__c.Onboarding_Id__c,
            Integration_Request__c.Notes__c,
            Integration_Request__c.Sfdc_Status__c,
            Integration_Request__c.Decision_Maker_Email__c,
            Integration_Request__c.Integration_Id__c,
            Integration_Request__c.Integration_Provider__c,
            Integration_Request__c.Target_Status__c,
            Integration_Request__c.Exclusion_Code__c,
            Integration_Request__c.Batch_Id__c,
            Integration_Request__c.payload__c,
            Integration_Request__c.Account__c,
            Integration_Request__c.Integration_Type__c,
            Integration_Request__c.Product_Status__c,
            Integration_Request__c.Stage__c,
            Integration_Request__c.Stage_Status__c,
            Integration_Request__c.Store_Update_Event_Received_Date_Time__c
        };
    }

    /**
     * @description It is used for getting IntegrationRequests by the passed Ids.
     * @param integrationRequestIds integration Request Ids
     * @return List<Integration_request__c>
     */
    public List<Integration_Request__c> selectById(Set<Id> integrationRequestIds) {
        return (List<Integration_request__c>) selectSObjectsById(IntegrationRequestIds);
    }

    /**
     * @description It is used for getting IntegrationRequests by the passed Ids.
     * @param onboardingIds
     * @param status
     * @return List<Integration_request__c>
     */
    public List<Integration_Request__c> selectByOnboardingId(
        Set<String> onboardingIds,
        Set<String> status
    ) {
        fflib_QueryFactory integrationRequestQuery = newQueryFactory()
            .selectField('Exclusion_Code__c')
            .selectField('Target_Status__c')
            .setCondition('Onboarding_Id__c IN :onboardingIds ' + 'AND Sfdc_Status__c IN: status');
        return (List<Integration_request__c>) Database.query(integrationRequestQuery.toSOQL());
    }
    /**
     * @description It is used for getting parent IntegrationRequests by the passed onbaordingIds.
     * @param onboardingIds
     * @return List<Integration_request__c>
     */
    public List<Integration_Request__c> selectParentByOnboardingId(Set<String> onboardingIds) {
        fflib_QueryFactory integrationRequestQuery = newQueryFactory()
            .setCondition(
                'Onboarding_Id__c IN :onboardingIds ' + 'AND Parent_Integration_Request__c = null'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Integration_request__c>) Database.query(integrationRequestQuery.toSOQL());
    }
    /**
     * @description It is used for getting IntegrationRequests by the passed Batch Ids.
     * @param batchIds
     * @return List<Integration_request__c>
     */
    public List<Integration_Request__c> selectByBatchId(Set<String> batchIds) {
        fflib_QueryFactory integrationRequestQuery = newQueryFactory()
            .selectField('Batch_Id__c')
            .selectField('Opportunity__c')
            .selectField('COO_Parent_Account_Matching_Reason__c')
            .selectField('COO_Reparented_Parent_Account__c')
            .selectField('Account__r.parentId')
            .selectField('Opportunity__r.AccountId')
            .selectField('Opportunity__r.Batch_Id__c')
            .selectField('Account__r.Primary_Vertical__c')
            .selectField('Account__r.Business_Vertical__c')
            .selectField('Product_Status__c')
            .selectField('Parent_Integration_Request__c')
            .selectField('Parent_Integration_Request__r.product_status__c')
            .selectField('Parent_Integration_Request__r.Opportunity__c')
            .selectField('Parent_Integration_Request__r.Opportunity__r.Batch_Id__c')
            .selectField('Parent_Integration_Request__r.SFDC_status__c')
            .selectField('Account__r.Segment__c')
            .selectField('Business_Id__c')
            .selectField('Account__r.Menu_UI_Type__c')
            .selectField('Account__r.CurrencyIsoCode')
            .selectField('Account__r.Order_Protocol__c')
            .selectField('Account__r.Change_of_Ownership_Effective_Date__c')
            .selectField('Account__r.Brand__c')
            .setCondition('Batch_Id__c IN :batchIds');
        return (List<Integration_Request__c>) Database.query(integrationRequestQuery.toSOQL());
    }
    /**
     * @description Method for querying integration records records when you know their status and org to process.
     * @param status status of the integration request record
     * @param sfdcOrg sfdcOrg org to process the integration requests.
     * @param days days last modified should be with last 5 days.
     * @return A list of integration requests
     */
    public List<Integration_Request__c> selectIntegrationRequestsByStatusAndOrg(
        Set<String> status,
        Set<String> sfdcOrg,
        Integer days
    ) {
        fflib_QueryFactory intgrationRequestsQueryFactory = newQueryFactory();
        intgrationRequestsQueryFactory.selectField('Parent_Integration_Request__c');
        intgrationRequestsQueryFactory.selectField('Parent_Integration_Request__r.SFDC_status__c');
        intgrationRequestsQueryFactory.selectFields(getSObjectFieldList());
        String condition = 'Sfdc_status__c IN :status AND ' + 'Sfdc_Org__c IN :sfdcOrg ';
        if (!Test.isRunningTest()) {
            condition +=
                'AND systemmodstamp >= last_N_Days:' +
                days +
                ' AND ' +
                'systemmodstamp <= :FOUR_MINUTES_AGO ';
        }
        intgrationRequestsQueryFactory.setCondition(condition);
        intgrationRequestsQueryFactory.addOrdering(
            new fflib_QueryFactory.Ordering(
                'Integration_Request__c',
                'systemmodstamp',
                fflib_QueryFactory.SortOrder.ASCENDING
            )
        );
        return (List<Integration_Request__c>) Database.query(
            intgrationRequestsQueryFactory.toSOQL()
        );
    }
    /**
     * @description
     * @param integrationRequestDeleteTypes status of the integration request record
     * @param integrationRequestDeleteOlderThanNMonths sfdcOrg org to process the integration requests.
     * @return A list of integration requests
     */
    public List<Integration_Request__c> selectIntegrationRequestsByIntegrationType(
        Set<String> integrationRequestDeleteTypes,
        DateTime integrationRequestDeleteOlderThanNMonths
    ) {
        fflib_QueryFactory intgrationRequestsQueryFactory = newQueryFactory()
            .selectField('Parent_Integration_Request__c')
            .selectField('Parent_Integration_Request__r.SFDC_status__c')
            .selectField('Integration_Type__c')
            .selectField('CreatedDate');
        intgrationRequestsQueryFactory
            .selectFields(getSObjectFieldList())
            .setCondition(
                'Integration_Type__c IN :integrationRequestDeleteTypes AND CreatedDate < :integrationRequestDeleteOlderThanNMonths'
            )
            .setLimit(6000);
        return (List<Integration_Request__c>) Database.query(
            intgrationRequestsQueryFactory.toSOQL()
        );
    }
    /**
     * @description It is used for getting parent IntegrationRequests by the passed onbaordingIds.
     * @param onboardingIds
     * @return List<Integration_request__c>
     */
    public List<Integration_Request__c> selectIntegrationRequestsByOnboardingId(
        Set<Id> onboardingIds
    ) {
        fflib_QueryFactory integrationRequestQuery = newQueryFactory()
            .setCondition(
                'Onboarding_Id__c IN :onboardingIds ' +
                    'AND Parent_Integration_Request__c = null ' +
                    'AND sfdc_Status__c != :SFDC_STATUS_PROCESSED'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Integration_request__c>) Database.query(integrationRequestQuery.toSOQL());
    }

    /**
     * @description This method is used for getting the Integration Requests by Type in the batch mode
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectFailedIntegrationRequestsForMdsStoreSync() {
        //@LEM-15022 - modified where clause as per this ticket
        String queryCondition = '((Integration_Type__c = \'MDS Store Sync\') AND ((sfdc_Status__c = \'Failed\' AND error_message__c <> \'OP received from MDS is not defined\' AND Lastmodifieddate < Last_N_days:7) OR (sfdc_Status__c = \'Pending\' AND Createddate >= Last_N_days:3 AND createddate <= '+FIFTEEN_MINUTES_AGO.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+')))';
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(queryCondition);
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description It is used for getting parent IntegrationRequests by the passed int Ids.
     * @param intIds
     * @return List<Integration_request__c>
     */
    public List<Integration_Request__c> selectByIdForParentIntegration(
        Set<Id> intIds
    ) {
        return (List<Integration_request__c>) Database.query(
            newQueryFactory(true)
                .selectField('Parent_Integration_Request__r.SFDC_status__c')
                .setCondition('Id in :intIds')
                .toSOQL()
        );
    }
}