/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Controller class for Guided flow.
 */
public with sharing class GuidedFlowController {
    /**
     * @description To get WorkSteps for creating Mx Orders and Mx Order Items flow.
     * @param flowInputs
     * @JIRA# LEM-13511
     */
    private static final String RETURN_COMPONENT_YES = 'Yes';
    private static final String SUB_TYPE_NET_NEW = 'Net-New';
    private static final String SUB_TYPE_REPLACEMENT = 'Replacement';
    private static final String SUB_TYPE_RETURN = 'Return';
    private enum SubTypes {
        SUB_TYPE_NET_NEW,
        SUB_TYPE_REPLACEMENT,
        SUB_TYPE_RETURN
    }
    private static final Map<String, SubTypes> WORK_STEP_SUB_TYPE_MAPPINGS = new Map<String, SubTypes>{
        SUB_TYPE_NET_NEW => SubTypes.SUB_TYPE_NET_NEW,
        SUB_TYPE_REPLACEMENT => SubTypes.SUB_TYPE_REPLACEMENT,
        SUB_TYPE_RETURN => SubTypes.SUB_TYPE_RETURN
    };

    /**
     * @description To generate Mx Order and Mx Order Items
     * @JIRA# LEM-13511
     * @param flowInputs
     */
    @InvocableMethod(
        label='Generate Mx Orders and Order Items'
        description='It generates Mx Orders and Mx Order Items for the passed WorkSteps'
    )
    public static void generateMxOrderAndMxOrderItem(List<GuidedFlowInputs> flowInputs) {
        switch on WORK_STEP_SUB_TYPE_MAPPINGS.get(flowInputs[0].typeOfRequest) {
            when SUB_TYPE_NET_NEW {
                MxOrderCreationService.generateMerchantOrder(flowInputs[0], true);
            }
            when SUB_TYPE_REPLACEMENT {
                MxOrderCreationService.generateMerchantOrder(flowInputs[0], true);
                if(flowInputs[0].returnComponent == RETURN_COMPONENT_YES){
                MxOrderCreationService.generateMerchantOrder(flowInputs[0], false);
                }
            }
            when SUB_TYPE_RETURN {
                MxOrderCreationService.generateMerchantOrder(flowInputs[0], false);
            }
        }
    }
}
