/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Selector class for Inbound_Ingestion_Log__c object.
 */
public inherited sharing class InboundIngestionLogsSelector extends fflib_SObjectSelector implements IInboundIngestionLogsSelector {
    private static final String FAILED_STATUS = 'Failed';
    private static final String FALLOUT_INTEGRATION_TYPE = 'Fallout event';
    private static final String ONBOARDING_INTEGRATION_TYPE = 'Onboarding Event';
    private static final String MX_NSE_INTEGRATION_TYPE = 'Mx Portal New Store Expansion';
    private static final String SUCCESS_STATUS = 'Success';
    private static final String SOURCE_SSMO = 'SSMO';

    /**
     * @description Default constructor for the class.
     * @return IInboundIngestionLogsSelector
     */
    public static IInboundIngestionLogsSelector newInstance() {
        return (IInboundIngestionLogsSelector) Application.Selector.newInstance(
            Inbound_Ingestion_Log__c.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Inbound_Ingestion_Log__c.SObjectType;
    }

    /**
     * @description It is used to get the SObjectFields.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Inbound_Ingestion_Log__c.Id,
            Inbound_Ingestion_Log__c.Failure_Step__c,
            Inbound_Ingestion_Log__c.Parent_Log__c,
            Inbound_Ingestion_Log__c.Payload__c,
            Inbound_Ingestion_Log__c.Status__c,
            Inbound_Ingestion_Log__c.UUID__c,
            Inbound_Ingestion_Log__c.Source__c,
            Inbound_Ingestion_Log__c.Integration_Type__c,
            Inbound_Ingestion_Log__c.Unique_Id__c,
            Inbound_Ingestion_Log__c.Internal_Payload_For_Retry__c
        };
    }

    /**
     * @description It is used to get the Inbound Ingestion Logs by passed recordIds.
     * @param recordIds
     * @return List<Inbound_Ingestion_Log__c>
     */
    public List<Inbound_Ingestion_Log__c> selectById(Set<Id> recordIds) {
        return (List<Inbound_Ingestion_Log__c>) selectSObjectsById(recordIds);
    }

    /**
     * @description  It is used to query parent Inbound Ingestion Log by passed UUIDs.
     * @param uuids
     * @return List<Inbound_Ingestion_Log__c>
     */
    public List<Inbound_Ingestion_Log__c> selectParentInboundIngestionLogsByUUIDs(
        Set<String> uuids
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('UUID__c IN :uuids AND Parent_Log__c = null')
            .setOrdering('Createddate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Inbound_Ingestion_Log__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get the Inbound Ingestion Logs by passed unique identifiers and integration type.
     * @param integrationTypes
     * @param uniqueIdentifiers
     * @return List<Inbound_Ingestion_Log__c>
     */
    public List<Inbound_Ingestion_Log__c> selectInboundIngestionLogsByUniqueIdentifiers(
        Set<String> integrationTypes,
        Set<String> uniqueIdentifiers
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'UUID__c IN :uniqueIdentifiers AND Parent_Log__c = null AND Integration_Type__c IN :integrationTypes'
            );
        return (List<Inbound_Ingestion_Log__c>) Database.query(query.toSOQL());
    }
    /**
     * @description  It is used to query non fallout Inbound Ingestion Log by passed UUIDs .
     * @param uuids
     * @return List<Inbound_Ingestion_Log__c>
     */
    public List<Inbound_Ingestion_Log__c> selectInboundIngestionLogsByUUIDs(Set<String> uuids) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('UUID__c IN :uuids AND Integration_Type__c !=: FALLOUT_INTEGRATION_TYPE');
        return (List<Inbound_Ingestion_Log__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to query the Inbound Ingestion Logs by passed unique identifiers
     * and integration types.
     * @JIRA# LEM-15616
     * @param integrationTypes
     * @param uniqueIdentifiers
     * @return List<Inbound_Ingestion_Log__c>
     */
    public List<Inbound_Ingestion_Log__c> selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
        Set<String> integrationTypes,
        Set<String> uniqueIdentifiers
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Integration_Type__c')
            .selectField('Created_Date_Time__c')
            .setCondition(
                'UUID__c IN :uniqueIdentifiers AND Integration_Type__c IN :integrationTypes'
            );
        return (List<Inbound_Ingestion_Log__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Used to return failed ingestion parent logs
     * @param
     * @return Database.QueryLocator
     */
    @SuppressWarnings('PMD.UnusedLocalVariable') //local variabled used but pmd cannot see it
    public Database.QueryLocator selectFailedIngestionLogs() {
        String failedLogStatus = 'Failed';
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Parent_Log__c')
            .setCondition(
                'Parent_Log__c = null AND Status__c=:failedLogStatus AND Retry_Count__c<3'
            );
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description Query based on BizIds to return failed inbound ingestion logs
     * @author VenkateshDD | 10-03-2024
     * @param bizIds
     * @return List<Inbound_Ingestion_Log__c>
     **/
    public List<Inbound_Ingestion_Log__c> selectFailedIngestionLogsByBizIds(Set<String> bizIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .setCondition('Business_Id__c IN : bizIds AND Status__c = :FAILED_STATUS');
        return (List<Inbound_Ingestion_Log__c>) Database.query(query.toSOQL());
    }

    /**
     * @description selects based on the uuid with the given statuses
     * @author VenkateshDD | 10-09-2024
     * @param uuids
     * @param statuses
     * @param source
     * @return List<Inbound_Ingestion_Log__c>
     **/
    public List<Inbound_Ingestion_Log__c> selectByUUIDStatusSource(
        Set<String> uuids,
        Set<String> statuses,
        String source
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('UUID__c')
            .setCondition('UUID__c IN :uuids AND Status__c IN :statuses AND Source__c = :source');
        return (List<Inbound_Ingestion_Log__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to fetch ingestion log based on the integration type and source.
     * @return List<Inbound_Ingestion_Log__c>
     **/
    public Database.QueryLocator selectSuccessIngestionLogsWithSSMOSourceORMxPortalNSEIntegrationType() {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('UUID__c')
            .selectField('Payload__c')
            .setCondition(
                'UUID__c != null AND ((Integration_Type__c = : ONBOARDING_INTEGRATION_TYPE ' +
                'AND Source__c =: SOURCE_SSMO) OR Integration_Type__c =:MX_NSE_INTEGRATION_TYPE) AND Status__c =:SUCCESS_STATUS'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);

        return Database.getQueryLocator(query.toSOQL());
    }
}