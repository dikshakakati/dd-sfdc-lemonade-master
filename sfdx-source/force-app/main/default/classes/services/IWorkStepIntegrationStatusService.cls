/**
 * @author atg
 * @date 07/26/2022
 * @description Service class for WorkStep related logic when Business Reference or Xref objects are integrated.
 */
public interface IWorkStepIntegrationStatusService {
    /**
     * @description It is used to handle the payload received via Platform Event.
     * @param events
     */
    void handleOnboardingActivationsEvents(List<Onboarding_Activation__e> events);

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates
     * @param businessReferences
     */
    void updateWorkStepsStatusOnBusinessReferenceStatusChange(
        Map<Id, Business_Reference__c> businessReferences
    );

    /**
     * @description Updates WorkStep Status when Xref Integration Status updates
     * @param xrefList
     */
    void updateWorkStepsStatusOnXrefStatusChange(List<Xref__c> xrefList);

    /**
     * @description Updates WorkStep Status when Xref Creation (LEM-3389)
     * @param xrefs
     * @param businessReferenceIds
     */
    void updateSetupBusinessWorkStepStatusOnXrefCreation(
        List<Xref__c> xrefs,
        Set<Id> businessReferenceIds
    );

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates for COO
     * @param businessReferenceList
     */
    void updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(
        List<Business_Reference__c> businessReferenceList
    );
}