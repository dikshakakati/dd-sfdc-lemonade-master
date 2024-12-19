/**
 * @author atg
 * @date   06/29/2022
 * @description This is the service interface for Integrating Xref__c objects
 */
public interface IXrefIntegrationService {
    /**
     * @description create platform Events to integrate Xref__c objects
     * @param xrefList
     * @param topic
     */
    void createIntegrationPlatformEvents(List<Xref__c> xrefList, String topic);

    /**
     * @description when Business_Reference__c records are updated to Success, update any xref records that
     * had a status of 'Waiting for Business'
     * @param businessReferenceList
     * @param changeOfOwnership
     */
    void updateStatusToReadyForIntegration(
        List<Business_Reference__c> businessReferenceList,
        Boolean changeOfOwnership
    );

    /**
     * @description when an Xref record has been deactivated, we will receive a COO Success Integration Status.
     * @param xrefList
     */
    void processCOOSuccess(List<Xref__c> xrefList);
    /**
     * @description Update the Existing Xrefs which are already Provisioned.
     * @param accountsIdSet
     */
    void updateExistingXrefsForAmendaments(Set<Id> accountsIdSet);
    /**
     * @description Update the Existing Business Accounts based on the Active MDS/Drive Xrefs
     * @param xrefList
     */
    void updateBusinessAccountsForXrefs(List<Xref__c> xrefList);
}