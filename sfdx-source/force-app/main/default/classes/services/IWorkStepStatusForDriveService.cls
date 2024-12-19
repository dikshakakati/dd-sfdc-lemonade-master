/**
 * @author atg
 * @date 11/14/2022
 * @description Service class for WorkStep related logic when Business Reference or Xref objects are integrated.
 */
 
public interface IWorkStepStatusForDriveService {
    /**
     * @description Updates WorkStep and WorkOrder Status when Business References Integration Status updates to Success,
     * external source = drive and Last Completed Step = User created
     * @param busReferIdToStatusMap
     */
    void updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
        Map<Id, Business_Reference__c> busReferIdToStatusMap
    );

    /**
     * @description Updates WorkStep Status when Xref Integration Status updates for Account type store
     * @param busRefIdXrefRecMap
     */
    void updateWorkStepsStatusOnXrefStatusChangeForDrive(Map<Id, List<Xref__c>> busRefIdXrefRecMap);
}