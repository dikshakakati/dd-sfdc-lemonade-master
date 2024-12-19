/**
 * @author atg
 * @date 07/26/2022
 * @description Service class for WorkStep related logic when Business Reference or Xref objects are integrated.
 */
public inherited sharing class WorkStepIntegrationStatusService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It is used to handle the payload received via Platform Event.
     * @JIRA# LEM-18813
     * @param events
     */
    public static void execute(List<Onboarding_Activation__e> events) {
        service().handleOnboardingActivationsEvents(events);
    }

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates
     * @param businessReferences
     */
    public static void updateWorkStepsStatusOnBusinessReferenceStatusChange(
        Map<Id, Business_Reference__c> businessReferences
    ) {
        service().updateWorkStepsStatusOnBusinessReferenceStatusChange(businessReferences);
    }

    /**
     * @description Updates WorkStep Status when Xref Integration Status updates
     * @param xrefList
     */
    public static void updateWorkStepsStatusOnXrefStatusChange(List<Xref__c> xrefList) {
        service().updateWorkStepsStatusOnXrefStatusChange(xrefList);
    }

    /**
     * @description Updates WorkStep Status when Xref Creation (LEM-3389)
     * @param xrefs
     * @param businessReferenceIds
     */
    public static void updateSetupBusinessWorkStepStatusOnXrefCreation(
        List<Xref__c> xrefs,
        Set<Id> businessReferenceIds
    ) {
        service().updateSetupBusinessWorkStepStatusOnXrefCreation(xrefs, businessReferenceIds);
    }

    /**
     * @description Updates WorkStep Status when Business References Integration Status updates for COO
     * @param businessReferenceList
     */
    public static void updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(
        List<Business_Reference__c> businessReferenceList
    ) {
        service().updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(businessReferenceList);
    }

    /**
     * @description It creates instance of WorkStepIntegrationStatusServiceImpl class.
     * @return IWorkStepIntegrationStatusService - return instance of WorkStepsServiceImpl
     */
    private static IWorkStepIntegrationStatusService service() {
        return (IWorkStepIntegrationStatusService) Application.Service.newInstance(
            IWorkStepIntegrationStatusService.class
        );
    }
}