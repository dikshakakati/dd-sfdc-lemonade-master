/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Service implementation class for Criteria related logic.
 */
public class CriteriaServiceImpl implements ICriteriaService {
    private static final String ACCOUNT_ID_FIELD = 'AccountId';
    private static final String ACCOUNT_ID_WORKSTEP_REFERENCE = 'WorkOrder.AccountId';
    private static final String CONTACT_OBJECT_RELATIONSHIP_PREFIX = 'Contact.';
    private static final String DOT_NOTATION = '.';
    private static final String MX_ORDER_OBJECT = 'MX_Order__c';
    private static final String MX_ORDER_ACCOUNT_FIELD_API_NAME = 'Account__c';
    private static final String OPPORTUNITY_OBJECT = 'Opportunity';
    private static final String SPLIT_BY_DOT_NOTATION = '\\.';
    private static final String WORKORDER_OBJECT = 'WorkOrder';
    private static final String WORKSTEP_OBJECT = 'WorkStep';
    private static final Map<String, String> SOBJECT_OBJECT_NAME_TO_ACCOUNT_FIELD_API_NAME = new Map<String, String>{
        MX_ORDER_OBJECT => MX_ORDER_ACCOUNT_FIELD_API_NAME,
        OPPORTUNITY_OBJECT => ACCOUNT_ID_FIELD,
        WORKORDER_OBJECT => ACCOUNT_ID_FIELD,
        WORKSTEP_OBJECT => ACCOUNT_ID_WORKSTEP_REFERENCE
    };
    private String accountFieldApiName;
    private Map<Id, Set<Id>> accountIdToSObjectId;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public CriteriaServiceImpl() {
        accountIdToSObjectId = new Map<Id, Set<Id>>();
    }

    /**
     * @description It collects decision maker contact details based on passed SObject Ids.
     * @JIRA# LEM-13778
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public Map<Id, List<SObject>> collectDecisionMakerContactDetails(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        Map<Id, List<SObject>> sObjectIdToDMContact = new Map<Id, List<SObject>>();
        Set<String> sObjectFieldApiNames = new Set<String>();
        for (String eachSObjectField : sObjectFields) {
            sObjectFieldApiNames.add(CONTACT_OBJECT_RELATIONSHIP_PREFIX + eachSObjectField);
        }
        fetchAccountIdToSObjectId(sObjects);
        for (
            AccountContactRelation eachACR : AccountContactRelationsSelector.newInstance()
                .selectDecisionMakerContactsByAccountIds(
                    accountIdToSObjectId.keySet(),
                    sObjectFieldApiNames
                )
        ) {
            for (Id eachSObjectId : accountIdToSObjectId.get(eachACR.AccountId)) {
                if (!sObjectIdToDMContact.containsKey(eachSObjectId)) {
                    sObjectIdToDMContact.put(eachSObjectId, new List<SObject>());
                }
                sObjectIdToDMContact.get(eachSObjectId).add(eachACR.Contact);
            }
        }
        return sObjectIdToDMContact;
    }

    /**
     * @description It collects Xref details based on passed SObject Ids.
     * @JIRA# LEM-15574
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public Map<Id, List<SObject>> collectXrefDetails(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        Map<Id, List<SObject>> sObjectIdToXRef = new Map<Id, List<SObject>>();
        fetchAccountIdToSObjectId(sObjects);
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectActiveXrefsBySalesforceAccountName(accountIdToSObjectId.keySet())
        ) {
            for (Id eachSObjectId : accountIdToSObjectId.get(eachXref.Salesforce_Account_Name__c)) {
                if (!sObjectIdToXRef.containsKey(eachSObjectId)) {
                    sObjectIdToXRef.put(eachSObjectId, new List<SObject>());
                }
                sObjectIdToXRef.get(eachSObjectId).add(eachXref);
            }
        }
        return sObjectIdToXRef;
    }

    /**
     * @description It collects dependee Work Step details based on passed SObject Ids.
     * @JIRA# LEM-15573
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public Map<Id, List<SObject>> collectDependeeWorkSteps(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        Map<Id, List<SObject>> sObjectIdToDependeeWorkSteps = new Map<Id, List<SObject>>();
        for (
            WorkStepDependency__c eachWorkStepDependency : WorkStepDependenciesSelector.newInstance()
                .selectDependenciesByDependentWorkStepsIds(new Map<Id, SObject>(sObjects).keySet())
        ) {
            if (
                !sObjectIdToDependeeWorkSteps.containsKey(
                    eachWorkStepDependency.Dependent_Work_Step__c
                )
            ) {
                sObjectIdToDependeeWorkSteps.put(
                    eachWorkStepDependency.Dependent_Work_Step__c,
                    new List<SObject>()
                );
            }
            sObjectIdToDependeeWorkSteps.get(eachWorkStepDependency.Dependent_Work_Step__c)
                .add(eachWorkStepDependency.Dependee_Work_Step__r);
        }
        return sObjectIdToDependeeWorkSteps;
    }

    /**
     * @description It collects child Merchant Order details based on passed Work Steps and Fields.
     * @JIRA# LEM-15573
     * @param sObjects
     * @param sObjectFields
     * @return Map<Id, List<SObject>>
     */
    public Map<Id, List<SObject>> collectMxOrders(
        List<SObject> sObjects,
        Set<String> sObjectFields
    ) {
        Map<Id, List<SObject>> sObjectIdToMxOrders = new Map<Id, List<SObject>>();
        for (
            MX_Order__c eachMxOrder : MerchantOrdersSelector.newInstance()
                .selectByWorkStepIds(new Map<Id, SObject>(sObjects).keySet(), sObjectFields)
        ) {
            if (!sObjectIdToMxOrders.containsKey(eachMxOrder.Work_Step__c)) {
                sObjectIdToMxOrders.put(eachMxOrder.Work_Step__c, new List<SObject>());
            }
            sObjectIdToMxOrders.get(eachMxOrder.Work_Step__c).add(eachMxOrder);
        }
        return sObjectIdToMxOrders;
    }

    /**
     * @description It collects mapping of account Id to sObject Id.
     * @JIRA# LEM-13778
     * @param sObjects
     */
    private void fetchAccountIdToSObjectId(List<SObject> sObjects) {
        String sObjectType;
        Id accountIdValue;
        for (SObject eachSObject : sObjects) {
            sObjectType = eachSObject.Id.getSObjectType().getDescribe().getName();
            accountFieldApiName = SOBJECT_OBJECT_NAME_TO_ACCOUNT_FIELD_API_NAME.get(sObjectType);
            accountIdValue = (Id) getFieldValueFromRecord(accountFieldApiName, eachSObject);
            if (!accountIdToSObjectId.containsKey(accountIdValue)) {
                accountIdToSObjectId.put(accountIdValue, new Set<Id>());
            }
            accountIdToSObjectId.get(accountIdValue).add(eachSObject.Id);
        }
    }

    /**
     * @description It returns the field value from passed record based on passed field reference name.
     * @JIRA# LEM-13778
     * @param fieldReference
     * @param sObjectRecord
     * @return Object
     */
    private Object getFieldValueFromRecord(String fieldReference, SObject sObjectRecord) {
        List<String> fieldReferences;
        Object fieldValue;
        if (String.isBlank(fieldReference) || fieldReference == null || sObjectRecord == null) {
            fieldValue = '';
        }
        if (fieldReference.contains(DOT_NOTATION)) {
            fieldReferences = fieldReference.split(SPLIT_BY_DOT_NOTATION);
            for (Integer iterator = 0; iterator < fieldReferences.size(); iterator++) {
                if (sObjectRecord == null) {
                    fieldValue = '';
                }
                if (iterator == fieldReferences.size() - 1) {
                    fieldValue = sObjectRecord.get(fieldReferences[iterator]);
                    return fieldValue;
                }
                sObjectRecord = sObjectRecord.getSObject(fieldReferences[iterator]);
            }
        } else {
            fieldValue = sObjectRecord.get(fieldReference);
        }
        return fieldValue;
    }
}