/**
 * @author Deloitte
 * @date 30/05/2022
 * @description Service implementation class for Decision Maker population related logic.
 */
public inherited sharing class DecisionMakerCalculationServiceImpl implements IDecisionMakerCalculationService {
    private static final String ACCOUNT_ID = 'AccountId';
    private static final String ACCOUNTCONTACTRELATION_OBJECT_NAME = 'AccountContactRelation';
    private static final String CONTACT_ID = 'ContactId';
    private static final String OPPORTUNITY_ID = 'OpportunityId';
    private static final String OPPORTUNITYCONTACTROLE_OBJECT_NAME = 'OpportunityContactRole';
    Set<Id> accountIds;
    Set<Id> opportunityIds;
    Map<Id, List<Id>> uniqueDecisionMakers;

    /**
     * @description Default constructor for this class.
     */
    public DecisionMakerCalculationServiceImpl() {
        this.accountIds = new Set<Id>();
        this.opportunityIds = new Set<Id>();
        this.uniqueDecisionMakers = new Map<Id, List<Id>>();
    }

    /**
     * @description To fetch unique Decision Makers when WorkOrders are passed.
     * @JIRA# LEM-1652
     * @param workOrders
     * @return Map<Id,List<Id>>
     */
    public Map<Id, List<Id>> getDecisionMakers(List<WorkOrder> workOrders) {
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        fetchOpportunityAndAccountIds(workOrders);
        if (!isSetEmptyOrNull(opportunityIds)) {
            opportunityContactRoles = OpportunityContactRoleSelector.newInstance()
                .selectByOpportunity(opportunityIds);
        }
        if (!isListEmptyOrNull(opportunityContactRoles)) {
            collectContactIds(opportunityContactRoles, OPPORTUNITYCONTACTROLE_OBJECT_NAME);
        }
        if (!isSetEmptyOrNull(accountIds)) {
            accountContactRelations = AccountContactRelationsSelector.newInstance()
                .selectByAccountIds(accountIds);
        }
        if (!isListEmptyOrNull(accountContactRelations)) {
            collectContactIds(accountContactRelations, ACCOUNTCONTACTRELATION_OBJECT_NAME);
        }
        return uniqueDecisionMakers;
    }

    /**
     * @description To collect ContactId from sobject list.
     * @param sObjects
     * @param objectName
     */
    private void collectContactIds(List<sObject> sObjects, String objectName) {
        String parentField;
        if (objectName == OPPORTUNITYCONTACTROLE_OBJECT_NAME) {
            parentField = OPPORTUNITY_ID;
        } else {
            parentField = ACCOUNT_ID;
        }
        for (sObject eachSObject : sObjects) {
            Id parentId = (Id) eachSObject.get(parentField);
            if (!uniqueDecisionMakers.containsKey(parentId)) {
                uniqueDecisionMakers.put(parentId, new List<Id>());
            }
            uniqueDecisionMakers.get(parentId).add((Id) eachSObject.get(CONTACT_ID));
        }
    }

    /**
     * @description It is used to get 'Opportunity Contact Role' and 'Account Contact Relationship' Ids using the passed Work Orders.
     * @JIRA# LEM-5367
     * @param workOrders
     * @return Map<Id, List<Id>>
     */
    public Map<Id, List<Id>> getOCRAndACRIds(List<WorkOrder> workOrders) {
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        fetchOpportunityAndAccountIds(workOrders);
        if (!isSetEmptyOrNull(opportunityIds)) {
            opportunityContactRoles = OpportunityContactRoleSelector.newInstance()
                .selectByOpportunity(opportunityIds);
        }
        if (!isListEmptyOrNull(opportunityContactRoles)) {
            collectOCRAndACRIds(opportunityContactRoles, OPPORTUNITYCONTACTROLE_OBJECT_NAME);
        }
        if (!isSetEmptyOrNull(accountIds)) {
            accountContactRelations = AccountContactRelationsSelector.newInstance()
                .selectByAccountIds(accountIds);
        }
        if (!isListEmptyOrNull(accountContactRelations)) {
            collectOCRAndACRIds(accountContactRelations, ACCOUNTCONTACTRELATION_OBJECT_NAME);
        }
        return uniqueDecisionMakers;
    }

    /**
     * @description It is used to get 'Opportunity Contact Role' and 'Account Contact Relationship' Ids from sobject list.
     * @JIRA# LEM-5367
     * @param sObjects
     * @param objectName
    */
    private void collectOCRAndACRIds(List<sObject> sObjects, String objectName) {
        String parentField;
        if (objectName == OPPORTUNITYCONTACTROLE_OBJECT_NAME) {
            parentField = OPPORTUNITY_ID;
        } else {
            parentField = ACCOUNT_ID;
        }
        for (sObject eachSObject : sObjects) {
            Id parentId = (Id) eachSObject.get(parentField);
            if (!uniqueDecisionMakers.containsKey(parentId)) {
                uniqueDecisionMakers.put(parentId, new List<Id>());
            }
            uniqueDecisionMakers.get(parentId).add((Id) eachSObject.get('Id'));
        }
    }

    /**
     * @description To fetch OpportunityIds and AccountIds from WorkOrders.
     * @param workOrders
     */
    private void fetchOpportunityAndAccountIds(List<WorkOrder> workOrders) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.Opportunity__c != null) {
                opportunityIds.add(eachWorkOrder.Opportunity__c);
            }
            if (eachWorkOrder.AccountId != null) {
                accountIds.add(eachWorkOrder.AccountId);
            }
        }
    }

    /**
     * @description To check whether a list of sobject is null or empty.
     * @param sObjects
     * @return Boolean
     */
    private Boolean isListEmptyOrNull(List<SObject> sObjects) {
        return sObjects == null || sObjects.isEmpty();
    }

    /**
     * @description To check whether a set of id is null or empty.
     * @param uniqueIds
     * @return Boolean
     */
    private Boolean isSetEmptyOrNull(Set<Id> uniqueIds) {
        return uniqueIds == null || uniqueIds.isEmpty();
    }
}