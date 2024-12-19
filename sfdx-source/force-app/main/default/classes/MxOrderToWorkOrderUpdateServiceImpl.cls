/**
 * @author Deloitte
 * @date 11/15/2024
 * @description Service Implementation class to update Work Order fields
 */
public inherited sharing class MxOrderToWorkOrderUpdateServiceImpl implements IMxOrderToWorkOrderUpdateService  {
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';
    /** 
     * @description Updates the Work Order Photo Shoot date and time.
     * @JIRA LEM24164
     * @param mxOrders
    */
    public void updateWorkOrderPhotoShootDateAndTime(List<Mx_Order__c> mxOrders) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for(Mx_Order__c mxOrder : mxOrders){
            if(mxOrder.Type__c == TYPE_PHOTOSHOOT && String.isNotBlank(mxOrder.Work_Order__c)){
                uow.registerDirty(new WorkOrder(
                Id = mxOrder.Work_Order__c,
                PhotoShoot_Date__c = mxOrder.Vendor_PhotoShoot_Date__c,
                PhotoShoot_Time__c = mxOrder.Vendor_PhotoShoot_Time__c
                ));
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }

    }
}