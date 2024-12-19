/**
 * @author Deloitte
 * @date 04/24/2023
 * @description Interface of service class for internal communitcations related logic.
 */
public interface IInternalMxSCommunicationsService {
    /**
     * @description It is used to send email to Account Team Members based on the flow inputs.
     * @param flowInputs
     */
    void sendSingleEmailMessagesToAccountTeamMembers(
        List<InternalMxSCommunicationsFlowInputs> flowInputs
    );
}