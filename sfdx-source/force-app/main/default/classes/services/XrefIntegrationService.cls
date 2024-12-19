/**
 * @author atg
 * @date   06/29/2022
 * @description This is the service interface for Integrating Xref__c objects
 */
public inherited sharing class XrefIntegrationService {
    /**
     * @description create platform Events to integrate Xref__c objects
     * @param xrefList
     * @param topic
     */
    public static void createIntegrationPlatformEvents(List<Xref__c> xrefList, String topic) {
        service().createIntegrationPlatformEvents(xrefList, topic);
    }

    /**

	* @description when Business_Reference__c records are updated to Success, update any xref records that
    * had a status of 'Waiting for Business'
    * @param businessReferenceList
    * @param changeOfOwnership
	*/
    public static void updateStatusToReadyForIntegration(
        List<Business_Reference__c> businessReferenceList,
        Boolean changeOfOwnership
    ) {
        service().updateStatusToReadyForIntegration(businessReferenceList, changeOfOwnership);
    }

    /**
     * @description Update the Existing Business Accounts based on the Active MDS/Drive Xrefs
     * @param xrefList
     */
    public static void updateBusinessAccountsForXrefs(List<Xref__c> xrefList) {
        service().updateBusinessAccountsForXrefs(xrefList);
    }

    /**
     * @description when an Xref record has been deactivated, we will receive a COO Success Integration Status.
     * @param xrefList
     */
    public static void processCOOSuccess(List<Xref__c> xrefList) {
        service().processCOOSuccess(xrefList);
    }
    /**
     * @description [LEM-3170] Update the Existing Xrefs which are already Provisioned.
     * @param accountsIdSet
     */
    public static void updateExistingXrefsForAmendaments(Set<Id> accountsIdSet) {
        service().updateExistingXrefsForAmendaments(accountsIdSet);
    }

    private static IXrefIntegrationService service() {
        return (IXrefIntegrationService) Application.Service.newInstance(
            IXrefIntegrationService.class
        );
    }
}