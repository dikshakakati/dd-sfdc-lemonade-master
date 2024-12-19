/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Trigger Handler for Leads.
 */
public class LeadsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - Leads Record List
     */
    public LeadsHandler(List<Lead> sObjectList) {
        super(sObjectList);
        setContextBypass(Lead.SObjectType, LeadsHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return LeadsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new LeadsHandler(sObjectList);
        }
    }

    /**
     * @description It is used to perform processing after Lead insertion.
     */
    public override void onAfterInsert() {
        AddressVerificationService.publishAddressVerificationEvent(this.records);
        Leads.newInstance(this.records)
            .updateInboundIngestionLogsToCompletedStatusOnSSMOLeadCreation();
    }

    /**
     * @description It is used to perform processing after Leads are updated.
     * @param existing
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        AddressVerificationService.publishAddressVerificationEvent(
            leadsWithUpdatedAddressOrStatus()
        );
        Leads.newInstance(checkForConvertedLeads()).processLeadsOnConversion();
        List<Lead> leadsToBeUpdatedOnFallout = getChangedRecords(
            new Set<SObjectField>{ Lead.Inbound_Ingestion_Log__c, Lead.SSMO_UUID__c }
        );
        SSMOLeadCreationService.createTaskOnLeadAfterFallout(
            leadsToBeUpdatedOnFallout,
            (Map<Id, Lead>) existing
        );
        List<Lead> leadsWithStatusUpdateOnFallout = getChangedRecords(
            new Set<SObjectField>{ Lead.Inbound_Ingestion_Log__c, Lead.Status }
        );
        SSMOLeadCreationService.updateInboundIngestionLogsToCompletedStatusOnSSMOLeadUpdationWhenInClosedStatus(
            leadsWithStatusUpdateOnFallout,
            (Map<Id, Lead>) existing
        );
    }

    /**
     * @description Called to perform after Undelete processing
     */
    public override void onAfterUndelete() {
        AddressVerificationService.publishAddressVerificationEvent(this.records);
    }

    /**
     * @description It is used to perform processing before Leads are inserted.
     */
    public override void onBeforeInsert() {
        TimeZoneCalculationService.calculateTimeZone(this.records);
        Leads.newInstance(this.records).setDefaultValuesBeforeConversion();
        CassieIdEncryptionService.encryptCassieId(this.records, 'Email', 'Email_Cassie_ID__c');
    }

    /**
     * @description It is used to perform processing before Leads are updated.
     * @param existing
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        Leads.newInstance(leadsWithUpdatedAddresses()).resetAddressAttributes();
        Leads.newInstance(this.records).setDefaultValuesBeforeConversion();
        TimeZoneCalculationService.calculateTimeZone(leadsWithUpdatedTimeZone());
        Leads.newInstance(leadsWithUpdatedPrimaryCampaignSource()).updateLastInboundDateTime();
        List<Lead> leadsToBeUpdatedOnFallout = getChangedRecords(
            new Set<SObjectField>{ Lead.Inbound_Ingestion_Log__c }
        );
        SSMOLeadCreationService.updateFieldsOnLeadAfterFallout(leadsToBeUpdatedOnFallout);
        CassieIdEncryptionService.encryptCassieId(
            leadsWithUpdatedEmail(),
            'Email',
            'Email_Cassie_ID__c'
        );
        OptOutOfCommunicationsService.updateDoNotCallAndSMSOptedOut(leadsWithUpdatedPhone());
        OptOutOfCommunicationsService.updateDateSMSOptedOutOrIn(leadsWithUpdatedSMSOptedOut());
        //@JIRA# LEM-21484
        List<Lead> statusUpdatedLeads = new List<Lead>(
            (List<Lead>) getChangedRecords(new Set<SObjectField>{ Lead.Status })
        );
        Leads.newInstance(statusUpdatedLeads).updateLastStatusChangeDate();
    }

    /**
     * @description this method used to get changed records .
     * @return List<Contact>
     */
    private List<Lead> leadsWithUpdatedPhone() {
        return new List<Lead>((List<Lead>) getChangedRecords(new Set<SObjectField>{ Lead.Phone }));
    }

    /**
     * @description To update address verification status and date
     * @return List<Lead>
     */
    private List<Lead> leadsWithUpdatedEmail() {
        return new List<Lead>((List<Lead>) getChangedRecords(new Set<SObjectField>{ Lead.Email }));
    }

    /**
     * @description this method used to get changed records.
     * @return List<Contact>
     */
    private List<Lead> leadsWithUpdatedSMSOptedOut() {
        return new List<Lead>(
            (List<Lead>) getChangedRecords(new Set<SObjectField>{ Lead.SMS_Opted_Out__c })
        );
    }
    /**
     * @description Check if Lead has been converted
     * @return List<Lead>
     */
    private list<lead> checkForConvertedLeads() {
        return new List<Lead>(
            (List<Lead>) getChangedRecords(new Set<Schema.SObjectField>{ Lead.isConverted })
        );
    }

    /**
     * @description It gets the account ids from the list of converted leads.
     * @param newConvertedLeads
     * @return List<Lead>
     */
    private Set<Id> collectAccountIdsFromConvertedLeads(List<Lead> newConvertedLeads) {
        Set<Id> accountIdsFromConvertedLeads = new Set<Id>();
        for (Lead eachConvertedLead : newConvertedLeads) {
            accountIdsFromConvertedLeads.add(eachConvertedLead.convertedAccountId);
        }
        return accountIdsFromConvertedLeads;
    }

    /**
     * @description It is used to get Leads with updated Address or Status.
     * @return List<Lead>
     */
    private List<Lead> leadsWithUpdatedAddressOrStatus() {
        return new List<Lead>(
            (List<Lead>) getChangedRecords(
                new Set<SObjectField>{
                    Lead.Country,
                    Lead.CountryCode,
                    Lead.State,
                    Lead.StateCode,
                    Lead.City,
                    Lead.PostalCode,
                    Lead.Street,
                    Lead.Address_Verification_Status__c
                }
            )
        );
    }

    /**
     * @description To update address verification status and date
     * @return List<Lead>
     */
    private List<Lead> leadsWithUpdatedAddresses() {
        return new List<Lead>(
            (List<Lead>) getChangedRecords(
                new Set<SObjectField>{
                    Lead.Country,
                    Lead.CountryCode,
                    Lead.State,
                    Lead.StateCode,
                    Lead.City,
                    Lead.PostalCode,
                    Lead.Street
                }
            )
        );
    }
    /**
     * @description It is used to collect Leads with updated Time Zone backend field
     * @return List<Lead>
     */
    private List<Lead> leadsWithUpdatedTimeZone() {
        return new List<Lead>(
            (List<Lead>) getChangedRecords(new Set<SObjectField>{ Lead.Time_Zone_Backend__c })
        );
    }

    /**
     * @description It is used to collect Leads with updated Primary Campaign Source field
     * @return List<Lead>
     */
    private List<Lead> leadsWithUpdatedPrimaryCampaignSource() {
        return new List<Lead>(
            (List<Lead>) getChangedRecords(new Set<SObjectField>{ Lead.Primary_Campaign_Source__c })
        );
    }
}