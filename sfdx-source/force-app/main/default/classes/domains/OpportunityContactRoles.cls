/**
 * @author DoorDash
 * @date 07/21/2022
 * @description Domain Class for OpportunityContactRole Object
 */
public inherited sharing class OpportunityContactRoles extends fflib_SObjects implements IOpportunityContactRoles {
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';
    /**
     * @description This method is to return the IOpportunityContactRoles interface
     * @param List<OpportunityContactRole> - list of OpportunityContactRoles
     * @param recordList - OpportunityContactRoles record list
     * @return IOpportunityContactRoles - Returns IOpportunityContactRoles Interface
     */
    public static IOpportunityContactRoles newInstance(List<OpportunityContactRole> recordList) {
        return (IOpportunityContactRoles) Application.Domain.newInstance(recordList);
    }
    /**
     * @description default constructor for the class
     * @param sObjectList
     * @param Schema.Opportunity.SObjectType
     */
    public OpportunityContactRoles(List<OpportunityContactRole> sObjectList) {
        super(sObjectList, Schema.OpportunityContactRole.SObjectType);
    }
    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }
    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return OpportunityContactRoles - List of OpportunityContactRoles
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (OpportunityContactRoles.constructorMock != null) {
                return (fflib_SObjects) OpportunityContactRoles.constructorMock.construct(
                    objectList
                );
            }
            return new OpportunityContactRoles((List<SObject>) objectList);
        }
    }

    /**
     * @description It is used to populate 'Contact Role Added Date' to current date
     * when Opportunity Contact Role is created.
     * @JIRA# LEM-13540
     */
    public void populateFieldsWhenOpportunityContactRoleCreated() {
        for (
            OpportunityContactRole eachOpportunityContactRole : (List<OpportunityContactRole>) getRecords()
        ) {
            if (eachOpportunityContactRole.Contact_Role_Added_Date__c == null) {
                if (eachOpportunityContactRole.IsPrimary) {
                    eachOpportunityContactRole.Primary_Contact_Confirmed_Date__c = System.today();
                }
                eachOpportunityContactRole.Contact_Role_Added_Date__c = System.today();
            }
        }
    }

    /**
     * @description It is used to populate 'Primary Contact Confirmed Date' to current date
     * when Opportunity Contact Role is marked as primary.
     * @JIRA# LEM-13540
     * @param oldOpportunityContactRoles
     */
    public void populateDateWhenOpportunityContactRoleMarkedPrimary(
        Map<Id, OpportunityContactRole> oldOpportunityContactRoles
    ) {
        OpportunityContactRole oldOpportunityContactRole;
        for (
            OpportunityContactRole eachOpportunityContactRole : (List<OpportunityContactRole>) getRecords()
        ) {
            oldOpportunityContactRole = oldOpportunityContactRoles.get(
                eachOpportunityContactRole.Id
            );
            if (
                hasOpportunityContactRoleIsPrimaryChanged(
                    eachOpportunityContactRole,
                    oldOpportunityContactRole
                )
            ) {
                if (eachOpportunityContactRole.IsPrimary) {
                    eachOpportunityContactRole.Primary_Contact_Confirmed_Date__c = System.today();
                }
            }
        }
    }

    /**
     * @description Method to populate the Store Name
     */
    public void populateQuoteOnOpportunityContactRole() {
        Set<Id> oppIds = new Set<Id>();
        List<OpportunityContactRole> contractSignatoryOppContactRoles = new List<OpportunityContactRole>();
        for (
            OpportunityContactRole eachOppContactRole : (List<OpportunityContactRole>) getRecordsByFieldValue(
                OpportunityContactRole.Role,
                CONTRACT_SIGNATORY_CONTACT_ROLE
            )
        ) {
            if (eachOppContactRole.OpportunityId != null) {
                oppIds.add(eachOppContactRole.OpportunityId);
                contractSignatoryOppContactRoles.add(eachOppContactRole);
            }
        }
        Map<Id, Opportunity> oppQuoteMap = new Map<Id, Opportunity>(
            OpportunitiesSelector.newInstance().selectOpportunitiesWithQuotes(oppIds)
        );
        if (oppQuoteMap.isEmpty()) {
            return;
        }
        for (OpportunityContactRole eachOppRole : contractSignatoryOppContactRoles) {
            if (
                oppQuoteMap.containsKey(eachOppRole.OpportunityId) &&
                oppQuoteMap.get(eachOppRole.OpportunityId) != null
            ) {
                eachOppRole.Quote__c = oppQuoteMap.get(eachOppRole.OpportunityId)
                    .SBQQ__PrimaryQuote__c;
            }
        }
    }

    /**
     * @description It checks whether OpportunityContactRole IsPrimary has changed and marked true.
     * @JIRA# LEM-13540
     * @param newOpportunityContactRole
     * @param oldOpportunityContactRole
     * @return Boolean
     */
    private Boolean hasOpportunityContactRoleIsPrimaryChanged(
        OpportunityContactRole newOpportunityContactRole,
        OpportunityContactRole oldOpportunityContactRole
    ) {
        return (newOpportunityContactRole.IsPrimary != oldOpportunityContactRole.IsPrimary);
    }
    /**
     * @description It updates the Primary Contact on Opportunity.
     * @JIRA# LEM-14152
     */
    public void updatePrimaryContactOnOpportunities() {
        Map<Id,Id> opportunityIdToPrimaryOCRContactId = new Map<Id,Id>();
        for (OpportunityContactRole eachOpportunityContactRole : (List<OpportunityContactRole>) getRecords()) {
            if(eachOpportunityContactRole.isPrimary){
                opportunityIdToPrimaryOCRContactId.put(eachOpportunityContactRole.OpportunityId,eachOpportunityContactRole.ContactId);
            }
        }
        if(!opportunityIdToPrimaryOCRContactId.isEmpty()){
            OpportunitiesService.updatePrimaryOCRContactOnOpportunity(opportunityIdToPrimaryOCRContactId);
        }
    }
}