/**
 * @author Deloitte
 * @date 31/01/2024
 * @description Interface for CCP_Workorder_Validation__mdt custom metadata selector.
 */
public interface ICcpWorkOrderValidationsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting all active CCP_Workorder_Validation__mdt records
     * having service class and method name fields populated.
     * @return List<CCP_Workorder_Validation__mdt>
     */
    List<CCP_Workorder_Validation__mdt> selectAllWorkOrderValidationRules();
}