/**
 * @author Deloitte
 * @date 02/12/2022
 * @description Domain Class for AccountContactRelation Object.
 */
public inherited sharing class AccountContactRelations extends fflib_SObjects implements IAccountContactRelations {
    private static final String ACCOUNTING_CONTACT = 'Accounting Contact';
    private static final String CONTACT_EVENT_TYPE_FALLOUT = 'Fallout Event';
    private static final String CONTACT_EVENT_TYPE_ONBOARDING = 'Onboarding Event';
    private static final String CONTACT_EVENT_TYPE_SSOB_ONBOARDING = 'SSOB Onboarding Event';
    private static final String DECISION_MAKER_ROLE = 'Decision Maker';
    private static final String INFLUENCER_ROLE = 'Influencer';
    private static final String SEMICOLON = ';';

    /**
     * @description This method is used to return the IAccountContactRelations interface
     * @param records - List of AccountContactRelation records
     * @return IAccountContactRelations - Returns IAccountContactRelations Interface
     */
    public static IAccountContactRelations newInstance(List<AccountContactRelation> records) {
        return (IAccountContactRelations) Application.Domain.newInstance(records);
    }

    /**
     * @description Default constructor for the class
     * @param sObjects
     */
    public AccountContactRelations(List<AccountContactRelation> sObjects) {
        super(sObjects, Schema.AccountContactRelation.SObjectType);
    }

    /**
     * @description This method is for implementing constructor in fflib_IDomainConstructor class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method for implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return AccountContactRelations - List of AccountContactRelations
         */
        public fflib_SObjects construct(List<Object> objectList) {
            return new AccountContactRelations((List<SObject>) objectList);
        }
    }

    /**
     * @description It is used to update Roles on ACR based on SSMO events.
     * @JIRA# LEM-14817
     */
    public void updateRolesByEventType() {
        Set<Id> contactIds = new Set<Id>();
        for (AccountContactRelation eachACR : (List<AccountContactRelation>) getRecords()) {
            contactIds.add(eachACR.ContactId);
        }
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(
            ContactsSelector.newInstance().selectById(contactIds)
        );
        for (AccountContactRelation eachACR : (List<AccountContactRelation>) getRecords()) {
            if (
                checkACRRoleUpdateEligibilityByEventType(
                    eachACR,
                    CONTACT_EVENT_TYPE_FALLOUT,
                    contactsMap
                )
            ) {
                eachACR.Roles = INFLUENCER_ROLE;
            } else if (
                checkACRRoleUpdateEligibilityByEventType(
                    eachACR,
                    CONTACT_EVENT_TYPE_ONBOARDING,
                    contactsMap
                )
            ) {
                eachACR.Roles = DECISION_MAKER_ROLE;
            }
            else if (
                checkACRRoleUpdateEligibilityByEventType(
                    eachACR,
                    CONTACT_EVENT_TYPE_SSOB_ONBOARDING,
                    contactsMap
                )
            ) {
                eachACR.Roles = contactsMap.get(eachACR.contactId).Integration_Contact_Type__c;
            }
        }
    }

    /**
     * @description It is used to validate the contact records with AccountContactRelation's role
     * as 'Accounting Contact' for empty SSN and Date of Birth.
     */
    public void validateSSNAndBirthdate() {
        if (UserInfo.getUserName().startsWithIgnoreCase(System.Label.NintexUserName)) {
            return;
        }
        Set<Id> contactIds = new Set<Id>();
        Map<Id, List<Contact>> accountIdToContacts = new Map<Id, List<Contact>>();
        List<AccountContactRelation> acrWithAccountingContactRoles = new List<AccountContactRelation>();
        for (
            AccountContactRelation eachACR : (List<AccountContactRelation>) getRecordsWithNotBlankFieldValues(
                AccountContactRelation.Roles
            )
        ) {
            if (eachACR.Roles.contains(ACCOUNTING_CONTACT)) {
                contactIds.add(eachACR.ContactId);
                acrWithAccountingContactRoles.add(eachACR);
            }
        }
        Map<Id, Contact> contactIdToContact = new Map<Id, contact>(
            ContactsSelector.newInstance().selectById(contactIds)
        );
        for (
            AccountContactRelation eachACRWithAccountingContactRole : acrWithAccountingContactRoles
        ) {
            if (!accountIdToContacts.containsKey(eachACRWithAccountingContactRole.Accountid)) {
                accountIdToContacts.put(
                    eachACRWithAccountingContactRole.Accountid,
                    new List<Contact>{}
                );
            }
            accountIdToContacts.get(eachACRWithAccountingContactRole.Accountid)
                .add(contactIdToContact.get(eachACRWithAccountingContactRole.ContactId));
        }

        Map<Id, String> contactIdToErrorMessage = ContactsService.validateSSNAndBirthdate(
            accountIdToContacts
        );
        for (AccountContactRelation eachACR : acrWithAccountingContactRoles) {
            if (contactIdToErrorMessage.containsKey(eachACR.ContactId)) {
                eachACR.addError(contactIdToErrorMessage.get(eachACR.ContactId));
            }
        }
    }

    /**
     * @description It is used to validate whether the OCR creation is needed or not when a
     * Decision Maker ACR is inserted.
     * @JIRA# LEM-13473
     */
    public void validateOCRCreation() {
        Map<Id, Id> accountIdToContactId = new Map<Id, Id>();
        for (AccountContactRelation eachACR : (List<AccountContactRelation>) getRecords()) {
            if (eachACR.Roles != null && eachACR.Roles.contains(DECISION_MAKER_ROLE)) {
                accountIdToContactId.put(eachACR.AccountId, eachACR.ContactId);
            }
        }
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectOpportunitiesAndQuotesByAccountIds(accountIdToContactId.keySet())
        ) {
            checkIfEligibleQuoteAndOCRExists(eachOpportunity, accountIdToContactId);
        }
    }

    /**
     * @description It is used to check whether eligible quote and OCR exists or not.
     * @JIRA# LEM-13473
     * @param opportunity
     * @param accountIdToContactId
     */
    private void checkIfEligibleQuoteAndOCRExists(
        Opportunity opportunity,
        Map<Id, Id> accountIdToContactId
    ) {
        Map<Id, Id> opportunityIdToContactIdMapForPrimaryOCR = new Map<Id, Id>();
        Map<Id, Id> opportunityIdToContactIdMapForNonPrimaryOCR = new Map<Id, Id>();
        if (!opportunity.SBQQ__Quotes2__r.isEmpty()) {
            if (opportunity.OpportunityContactRoles.isEmpty()) {
                opportunityIdToContactIdMapForPrimaryOCR.put(
                    opportunity.Id,
                    accountIdToContactId.get(opportunity.AccountId)
                );
            } else {
                opportunityIdToContactIdMapForNonPrimaryOCR.put(
                    opportunity.Id,
                    accountIdToContactId.get(opportunity.AccountId)
                );
            }
        }
        if (!opportunityIdToContactIdMapForPrimaryOCR.isEmpty()) {
            OpportunityContactRoleService.createOCR(opportunityIdToContactIdMapForPrimaryOCR, true);
        }
        if (!opportunityIdToContactIdMapForNonPrimaryOCR.isEmpty()) {
            OpportunityContactRoleService.createOCR(
                opportunityIdToContactIdMapForNonPrimaryOCR,
                false
            );
        }
    }

    /**
     * @description It is used to check the eligibility of role update on account contact relation
     * based on the passed event type.
     * @JIRA# LEM-14817
     * @param accountContactRelation
     * @param eventType
     * @param contactsMap
     * @return Boolean
     */
    private Boolean checkACRRoleUpdateEligibilityByEventType(
        AccountContactRelation accountContactRelation,
        String eventType,
        Map<Id, Contact> contactsMap
    ) {
        return (accountContactRelation.AccountId ==
        contactsMap.get(accountContactRelation.contactId).AccountId &&
        contactsMap.get(accountContactRelation.contactId).Unique_Identifier__c != null &&
        contactsMap.get(accountContactRelation.contactId).Event_Type__c == eventType &&
        String.isBlank(accountContactRelation.Roles));
    }
}