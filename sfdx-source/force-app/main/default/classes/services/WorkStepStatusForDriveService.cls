/**
 * @author atg
 * @date 07/26/2022
 * @description Service class for WorkStep related logic when Business Reference or Xref objects are integrated.
 */
public inherited sharing class WorkStepStatusForDriveService {
    /**
     * @description Updates WorkStep and WorkOrder Status when Business References Integration Status updates to Success,
     * external source = drive and Last Completed Step = User created
     * @param busReferIdToBusRefRecMap
     */
    public static void updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
        Map<Id, Business_Reference__c> busReferIdToBusRefRecMap
    ) {
        service()
            .updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(busReferIdToBusRefRecMap);
    }

    /**
     * @description Updates WorkStep Status when Xref Integration Status updates for Account type Store
     * @param busRefIdXrefRecMap
     */
    public static void updateWorkStepsStatusOnXrefStatusChangeForDrive(
        Map<Id, List<Xref__c>> busRefIdXrefRecMap
    ) {
        service().updateWorkStepsStatusOnXrefStatusChangeForDrive(busRefIdXrefRecMap);
    }

    /**
     * @description It creates instance of WorkStepIntegrationStatusServiceImpl class.
     * @return IWorkStepStatusForDriveService - return instance of WorkStepsServiceImpl
     */
    private static IWorkStepStatusForDriveService service() {
        return (IWorkStepStatusForDriveService) Application.Service.newInstance(
            IWorkStepStatusForDriveService.class
        );
    }
}