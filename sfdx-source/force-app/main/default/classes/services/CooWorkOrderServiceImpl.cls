/**
 * @author DoorDash
 * @date 8/28/23
 * @description Service class for processing coo same store work order related updates
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public inherited sharing class CooWorkOrderServiceImpl implements ICooWorkOrderService {
    private static final Set<String> WO_OPEN_STATUS = new Set<String>{'Planning', 'Confirmed', 'In Progress', 'At Risk', 'Past Due', 'Not Started'};
    private static final Set<String> TYPE_COO = new Set<String>{'COO'};
    private static final String WO_TYPE_COO = 'COO';
    private static final Set<String> SUB_TYPE_COO_SAME_STORE = new Set<String>{'COO Same Store'};
    private static final String WO_SUBTYPE_COO = 'COO Same Store';
    private static final String WS_STATUS_DEAD = 'Dead';
    private static final String WS_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WS_STATUS_NOT_STARTED = 'Not Started';
    private static final String WS_STATUS_COMPLETE = 'Complete';
    private static final String WS_STATUS_REASON_CANCELLED = 'COO Same Store Cancelled';
    private static final Set<String> WORK_STEP_TYPE_POS = new Set<String>{'Complete pre-work', 'Configure POS', 'Ingest Menu', 'QA Menu', 'Enable Integration' };
    private static final Set<String> WS_TYPE_COO_SAME_STORE =  new Set<String>{'COO Same Store'};
    private static final String MENU_COMPLETED_BY_DOORDASH_ONBOARDING_TEAM = 'DoorDash Onboarding Team';
    private static final Set<String> WORK_PLAN_TYPE_POS = new Set<String>{'POS'};
    private static final String WORK_ORDER_PROVISIONING_COMPLETE = 'Provisioning Complete';

    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final Map<String, String> ORDER_PROTOCOL_MAPPINGS = new Map<String, String>{
             'Android Tablet (Merchant Owns)' => 'POS',
             'Email' => 'POS',
             'Fax' => 'POS',
             'Other' => 'POS',
             'Tablet (DoorDash Owns)' => 'POS and Tablet (DoorDash Owns)',
             'Tablet and Printer (DoorDash Owns)' => 'POS and Tablet (DoorDash Owns)',
             'Tablet (Caviar Owns)'=>'POS and Tablet (Caviar Owns)'
    };

    /**
     * @description Processes the COO (Change of Ownership) requests based on the provided batch IDs.
     * @param intReqByBatch  A Set of batch IDs.
     * @param batchIdToOppId  A Set of batch IDs.
     */
    public void createUpdateParentWorkOrder(List<Integration_Request__c> intReqByBatch, Map<String, Id> batchIdToOppId){
        Map<String,Date> batchIDByActivationDate = new  Map<String,Date>();
        Map<String,Workorder> batchIDByParentWO = new Map<String,Workorder>();
        Map<Id,Id> opportunityIDByBusinessAccountId = new Map<Id,Id>();
        Map<String,Set<Id>> batchIdBystoreAccIds = new  Map<String,Set<Id>>();
        Set<String> batchIds = new Set<String>();
        batchIds = batchIdToOppId.keySet();
        List<Id> opportunityIds  = new List<Id>();
        opportunityIds = batchIdToOppId.values();
        Set<Id> oppIDSet = new Set<Id>(opportunityIds);
        List<Opportunity> oppList = OpportunitiesSelector.newInstance().selectById(oppIDSet);
        for (Opportunity opp : oppList){
            opportunityIDByBusinessAccountId.put(opp.ID, opp.AccountID);
        }
        for (WorkOrder wo :  WorkOrdersSelector.newInstance().selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID( WO_OPEN_STATUS, TYPE_COO, SUB_TYPE_COO_SAME_STORE, oppIDSet, batchIds)){
                batchIDByParentWO.put(wo.Opportunity__r.Batch_Id__c, wo);
        }

        for(Integration_Request__c eachIR: intReqByBatch){
            if (eachIR.Account__c == null){
               continue;
            }
            if (batchIdBystoreAccIds.containsKey(eachIR.Batch_Id__c )){
                batchIdBystoreAccIds.get(eachIR.Batch_Id__c).add(eachIR.Account__c);
            }else{
                batchIdBystoreAccIds.put(eachIR.Batch_Id__c, new Set<Id>{eachIR.Account__c});
            }
            if (!batchIDByActivationDate.containsKey(eachIR.Batch_Id__c)){
                batchIDByActivationDate.put(eachIR.Batch_Id__c, eachIR.Activation_Date__c);
            }
        }
        if (!batchIdBystoreAccIds.isEmpty()){
              createUpdateCOOWorkOrder( batchIdToOppId, batchIDByActivationDate, batchIDByParentWO, opportunityIDByBusinessAccountId, batchIdBystoreAccIds );
        }
    }

    // Create Event: Create a Parent workorder if it doesn't exist
    // Update the existing work order(append the associated account ids to create child workorders)
    private void createUpdateCOOWorkOrder ( Map<String, Id> batchIdToOppId,  Map<String,Date> batchIDByActivationDate,  Map<String,Workorder> batchIDByParentWO,  Map<Id,Id> opportunityIDByBusinessAccountId, Map<String,Set<Id>> batchIdBystoreAccIds ){
        for(String batchID: batchIdBystoreAccIds.keySet()){
            Set<Id> ids = new Set<Id>();
            ids = batchIdBystoreAccIds.get(batchID);
            if (!ids.isEmpty() && ids != null) {
                List<String> idStrs = (List<String>)JSON.deserialize(JSON.serialize(ids), List<String>.class);
                String idsString = String.join(idStrs, ',');
                // if no Parent WO is found create Parent WO
                if (!batchIDByParentWO.containsKey(batchID)){
                    WorkOrder cooWO = new WorkOrder(
                            AccountId = opportunityIDByBusinessAccountId.get(batchIdToOppId.get(batchID)),
                            Type__c = WO_TYPE_COO,
                            Sub_Type__c = WO_SUBTYPE_COO,
                            Associated_Account_Ids__c = idsString,
                            Opportunity__c  = batchIdToOppId.get(batchID),
                            Proposed_Date_of_Activation__c = batchIDByActivationDate.get(batchID),
                            Menu_to_be_Completed_By__c  = MENU_COMPLETED_BY_DOORDASH_ONBOARDING_TEAM,
                            Provisioning_Status__c = WORK_ORDER_PROVISIONING_COMPLETE
                    );
                    uow.registerNew(cooWO);
                }else {
                // Update the Parent WO , append the Associated Account ID field.
                    Workorder cooparentWO = batchIDByParentWO.get(batchID);
                    String existingAccounts = cooparentWO.Associated_Account_Ids__c;
                    cooparentWO.Associated_Account_Ids__c = String.isNotEmpty(existingAccounts)? existingAccounts +',' + idsString : idsString;
                    uow.registerDirty(cooparentWO);
                }
            }
        }
        uow.commitWork();
    }

    /**
     * @description Complete event: Update the COO workorders to complete,
     * Update the POS WorkSteps: form Not Workable to Not Started
     * @param intReqByBatchCompleted  A Set of batch IDs.
    */
     public void updateWorkOrderToComplete(List<Integration_Request__c> intReqByBatchCompleted){
         Set<String> batchIds = new Set<String>();
         Set<Id> storeAccountIds = new Set<Id>();
         for (Integration_Request__c ir : intReqByBatchCompleted ){
                storeAccountIds.add(ir.Account__c);
                batchIds.add(ir.Batch_Id__c);
            }
    	if(!storeAccountIds.isEmpty() && !batchIds.isEmpty()){
            updateCOOWorkStepsToComplete(storeAccountIds, batchIds);
            updatePOWorkStepsToNotStarted(storeAccountIds, batchIds);
        }
        uow.commitWork();
    }

    // Complete event: update COO Same Store workstep to Complete
    //@testVisible
    private void updateCOOWorkStepsToComplete (Set<Id> storeAccountIds, Set<String> batchIds){
        List<WorkStep> childWorkSteps = new List <WorkStep>();
        childWorkSteps = WorkStepsSelector.newInstance().selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(storeAccountIds, WS_TYPE_COO_SAME_STORE , batchIds);
	    	if (!childWorkSteps.isEmpty() && childWorkSteps != null ){
            	for(workstep wsp : childWorkSteps){
    				wsp.Status__c = WS_STATUS_COMPLETE;
        			uow.registerDirty(wsp);
				}
       		}
    }

    //On complete event update POS WorkSteps from 'Not Workable' to  'Not Started'
    private void updatePOWorkStepsToNotStarted (Set<Id> storeAccIds, Set<String> batchIds){
        List<WorkStep> childPOSWorkSteps = new List <WorkStep>();
        childPOSWorkSteps = WorkStepsSelector.newInstance().selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(storeAccIds, WORK_STEP_TYPE_POS, batchIds);
        if (childPOSWorkSteps != null && !childPOSWorkSteps.isEmpty()){
            for(workstep wsp : childPOSWorkSteps){
                if (WS_STATUS_NOT_WORKABLE.equals(wsp.Status__c)){
                    	wsp.Status__c = WS_STATUS_NOT_STARTED;
        		    uow.registerDirty(wsp);
                }
			}
        }
    }

    /**
     * @description Cancelled event: update the Workorder to dead
     * @param pendingCancelledCooRequests
     * @param batchIdToOppId
     *
    */
    public void updateWorkOrderToDead( List<Integration_Request__c> pendingCancelledCooRequests, Map<String, Id> batchIdToOppId) {
        if (!batchIdToOppId.isEmpty()){
            updateParentWorkOrderToDead(batchIdToOppId);
        }
        if (!pendingCancelledCooRequests.isEmpty()){
            updateStoreWorkOrderToDead(pendingCancelledCooRequests);
        }
        uow.commitWork();
    }
    private void updateParentWorkOrderToDead(Map<String, Id> batchIdToOppId){
         Set<String> batchIds = new Set<String>();
        batchIds = batchIdToOppId.keySet();
        List<Id> opportunityIds  = new List<Id>();
        opportunityIds = batchIdToOppId.values();
        Set<Id> oppIDSet = new Set<Id>(opportunityIds);
        Set<id> parentWorkOrderIDs = new Set<Id>();
        List<WorkOrder> parentworkOrderList = new List<WorkOrder>();
        parentworkOrderList = WorkOrdersSelector.newInstance().selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID( WO_OPEN_STATUS, TYPE_COO, SUB_TYPE_COO_SAME_STORE,oppIDSet,batchIds);
        if (!parentworkOrderList.isEmpty()){
          	for (WorkOrder wo :  parentworkOrderList){
            	parentWorkOrderIDs.add(wo.id);
          	}
        }

       // If all the Integration reuest for a Batch Id is Cancelled
       // Update all the ChildWorkSteps for the Parent WO to Dead
        List<workstep> allChildworkSteps = new List<workstep>();
        if (!parentWorkOrderIDs.isEmpty()){
             allChildworkSteps =  WorkStepsSelector.newInstance().selectAllChildWorkStepsByParentWorkOrderID(parentWorkOrderIDs);
        }
        if (!allChildworkSteps.isEmpty() && allChildworkSteps != null ){
            for(workstep wsp : allChildworkSteps ){
            	wsp.Status__c = WS_STATUS_DEAD;
            	wsp.Is_Updated_By_System__c = true;
            	wsp.Status_Reason__c  = WS_STATUS_REASON_CANCELLED;
            uow.registerDirty(wsp);
        	}
        }
     }

    private void updateStoreWorkOrderToDead(List<Integration_Request__c> pendingCancelledCooRequests){
        Set<Id> storeAccountIds = new Set<Id>();
        Set<String> batchStringIds = new Set<String>();
        if (!pendingCancelledCooRequests.isEmpty()){
            for (Integration_Request__c ir : pendingCancelledCooRequests ){
                storeAccountIds.add( ir.Account__c);
                batchStringIds.add(ir.Batch_Id__c);
            }

		List<WorkStep> childWorkSteps = WorkStepsSelector.newInstance().selectChildWorkStepsByStoreAccountIdsAndBatchId(storeAccountIds, batchStringIds );
            if (!childWorkSteps.isEmpty() && childWorkSteps != null ){
                for(workstep wsp : childWorkSteps ){
            	    wsp.Status__c = WS_STATUS_DEAD;
            	    wsp.Is_Updated_By_System__c = true;
            	    wsp.Status_Reason__c  = WS_STATUS_REASON_CANCELLED;
                uow.registerDirty(wsp);
        	    }
            }
        }
    }

    /**
     * @description process POS requests on Ready event,
     * Update the existing POS workPlans to dead, Reevaluate the WorkOrders to create POS workplans
     * @param posIntegrationRequestsOnReadyEvent
     *
    */
    public void processPosIntRequestOnReadyEvent(List<Integration_Request__c> posIntegrationRequestsOnReadyEvent) {
        Map<String, String> batchIdByOrderProtocol = new Map<String, String>();
        Map<String,Id> batchIdByOpportunityId = new Map<String,Id>();
        Map<Id, String> storeAccIdToBatchId = new Map<Id, String>();

        for(Integration_Request__c eachIr : posIntegrationRequestsOnReadyEvent){
            if (eachIr.Parent_Integration_Request__r.Opportunity__c != null
                 && eachIr.Batch_Id__c != null
                ){
                    storeAccIdToBatchId.put(eachIr.Account__c, eachIr.Batch_Id__c);
                    String accountOrderProtocol = eachIr.Account__r.Order_Protocol__c;
                    batchIdByOrderProtocol.put(eachIr.Batch_Id__c, String.isBlank(accountOrderProtocol) ? 'POS': accountOrderProtocol);
                    batchIdByOpportunityId.put(eachIr.Batch_Id__c, eachIr.Parent_Integration_Request__r.Opportunity__c);
            }
        }
        if (!storeAccIdToBatchId.isEmpty()) {
            updatePOSWorkPlansToDead(storeAccIdToBatchId);
        }
        updateWorkOrderForReevaluation(batchIdByOrderProtocol, batchIdByOpportunityId );
    }

      // check for existing POS workplan on the Store Integration Request, update to dead.
    private void updatePOSWorkPlansToDead(Map<Id, String> storeAccIdToBatchId){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
         // check for existing POS WorkSteps, make it to dead.
            List<WorkStep> childPOSWorkSteps = WorkStepsSelector.newInstance().selectChildWorkStepsByStoreAccountIdsAndType(storeAccIdToBatchId.keySet(), WORK_STEP_TYPE_POS);
            if(!childPOSWorkSteps.isEmpty() && childPOSWorkSteps != null ){
                for (workstep wsp : childPOSWorkSteps){
                    if(storeAccIdToBatchId.containsKey(wsp.Store_Account__c) && storeAccIdToBatchId.get(wsp.Store_Account__c) != wsp.Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c){
                        wsp.Status__c = WS_STATUS_DEAD;
                        wsp.Is_Updated_By_System__c = true;
                        wsp.Status_Reason__c = 'Other';
                        wsp.Notes__c = 'COO Same Store request received and making existing pos work plan dead';
                        uow.registerDirty(wsp);
                    }
                }
            }
            uow.commitWork();
    }

    private void updateWorkOrderForReevaluation(Map<String, String> batchIdByOrderProtocol, Map<String, Id> batchIdToOppId){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<String> batchIds = new Set<String>();
        batchIds = batchIdToOppId.keySet();
        List<Id> opportunityIds  = new List<Id>();
        opportunityIds = batchIdToOppId.values();
        Set<Id> oppIDSet = new Set<Id>(opportunityIds);
        Set<Id> workorderIDs = new Set<Id>();
        if (batchIdToOppId.size()>0){
            for (WorkOrder wo :  WorkOrdersSelector.newInstance().selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID( WO_OPEN_STATUS, TYPE_COO, SUB_TYPE_COO_SAME_STORE,oppIDSet,batchIds)){
                wo.HasPosWorkPlan__c = true;
                String accountOrderProtocol = batchIdByOrderProtocol.get(wo.Opportunity__r.Batch_Id__c);
                String orderProtocol = accountOrderProtocol.contains('POS') ? accountOrderProtocol : ORDER_PROTOCOL_MAPPINGS.get(accountOrderProtocol) ;
                wo.Order_Protocol__c =  orderProtocol;
                workorderIDs.add(wo.id);
            uow.registerDirty(wo);
            }
        }
            uow.commitWork();
           // reevaluate the child workorder and parent wo for reevaluating the workplan.
        if (!workorderIDs.isEmpty()){
            reEvaluateWorkOrder(workorderIDs);
        }
    }

    private void reEvaluateWorkOrder(Set<Id> workOrderIDs){
        List<WorkOrder> eligibleWorkOrders = new List<WorkOrder>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                    .selectParentAndChildrenByIds(workOrderIds)
        ) {
            eligibleWorkOrders.add(eachWorkOrder);
        }
        if(!eligibleWorkOrders.isEmpty()){
                WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(eligibleWorkOrders);
        }
    }
}