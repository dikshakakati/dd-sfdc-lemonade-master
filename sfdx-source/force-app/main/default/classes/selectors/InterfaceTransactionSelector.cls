/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Selector Class for Interface_Transaction__c Object
 */
public inherited sharing class InterfaceTransactionSelector extends fflib_SObjectSelector implements IInterfaceTransactionSelector {
    private static final String FAILURE_STATUS = 'Failure';
    private static final String NEW_STATUS = 'New';
    private static final String EMAIL_OUTBOUND_CONFIG_NAME = 'Email_Outbound_Integration';
    private static final String INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD = 'Mx_Fraud_Document_Integration';
    private static final Set<String> INTERFACE_TRANSACTION_CONFIG_NAMES_TO_SKIP_RETRY = new Set<String>{
        INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD
    };

    /**
     * @description newinstance method to call application selector
     * @param Interface_Transaction__c.SObjectType - Interface_Transaction__c object type
     * @return IInterfaceTransactionSelector - interface of IInterfaceTransactionSelector
     */
    public static IInterfaceTransactionSelector newInstance() {
        return (IInterfaceTransactionSelector) Application.Selector.newInstance(
            Interface_Transaction__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on Interface_Transaction__c object
     * @return List<Schema.SObjectField> - Interface Transaction Object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Interface_Transaction__c.Id,
            Interface_Transaction__c.CreatedDate,
            Interface_Transaction__c.Integration_Template__c,
            Interface_Transaction__c.Interface_Transaction_Configuration_Name__c,
            Interface_Transaction__c.Interface__c,
            Interface_Transaction__c.Payload__c,
            Interface_Transaction__c.Record_Id__c,
            Interface_Transaction__c.Remaining_Retry_Attempts__c,
            Interface_Transaction__c.Status__c
        };
    }

    /**
     * @description This method is for getting the Interface_Transaction__c Records based on id
     * @param ids - Interface_Transaction__c record Ids
     * @return List<Interface_Transaction__c - DML operation result
     */
    public List<Interface_Transaction__c> selectById(Set<Id> ids) {
        return (List<Interface_Transaction__c>) selectSObjectsById(ids);
    }

    /**
     * @description This method is for getting the Interface Transaction Records based on Interface record id
     * @param interfaceId - Interface
     * @return List<Interface_Transaction__c - DML operation result
     */
    public List<Interface_Transaction__c> selectByInterface(String interfaceId) {
        List<Interface_Transaction__c> result = Database.query(
            newQueryFactory().setCondition('Interface__c =: interfaceId').toSOQL()
        );
        return result;
    }

    /**
     * @description This method is for getting the Interface Transaction Records
     * based on Record_Id__c field value.
     * @JIRA# LEM-13506
     * @param recordIds
     * @return List<Interface_Transaction__c>
     */
    public List<Interface_Transaction__c> selectByOriginRecordIds(Set<String> recordIds) {
        List<Interface_Transaction__c> result = Database.query(
            newQueryFactory().setCondition('Record_Id__c IN :recordIds').toSOQL()
        );
        return result;
    }

    /**
     * @description This method is for getting the Interface class name
     * based on interface transaction configuration name.
     * @return Database.QueryLocator - DML operation result
     */
    public Database.QueryLocator queryLocatorReadyToRetry() {
        return Database.getQueryLocator(
            newQueryFactory()
                .setCondition(
                    '(Status__c = \'' +
                        FAILURE_STATUS +
                        '\' OR (Status__c = \'' +
                        NEW_STATUS +
                        '\' AND Interface_Transaction_Configuration_Name__c = \'' +
                        EMAIL_OUTBOUND_CONFIG_NAME +
                        '\' AND Integration_Template__r.Immediate_Communication__c = false))' +
                        ' AND Remaining_Retry_Attempts__c > 0' +
                        ' AND Interface_Transaction_Configuration_Name__c NOT IN :INTERFACE_TRANSACTION_CONFIG_NAMES_TO_SKIP_RETRY'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method id for getting object type
     * @return Interface_Transaction_c Object type
     */
    public Schema.SObjectType getSObjectType() {
        return Interface_Transaction__c.SObjectType;
    }
}