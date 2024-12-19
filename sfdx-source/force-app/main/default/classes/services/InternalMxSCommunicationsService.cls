/**
 * @author Deloitte
 * @date 04/24/2023
 * @description Service class for internal communitcations related logic.
 * "Without Sharing" is required to allow sending email to private Contacts
 * since they cannot be shared due to organization-wide default's value as "controlled by Parent".
 */
public without sharing class InternalMxSCommunicationsService {
    /**
     * @description It is used to send email to Account Team Members based on the flow inputs.
     * @JIRA# LEM-5727
     * @param flowInputs
     */
    @InvocableMethod(label='Notify Drive Specialists')
    public static void sendSingleEmailMessagesToAccountTeamMembers(
        List<InternalMxSCommunicationsFlowInputs> flowInputs
    ) {
        service().sendSingleEmailMessagesToAccountTeamMembers(flowInputs);
    }

    /**
     * @description It creates instance of InternalMxSCommunicationsServiceImpl class.
     * @JIRA# LEM-5727
     * @return IInternalMxSCommunicationsService
     */
    private static IInternalMxSCommunicationsService service() {
        return (IInternalMxSCommunicationsService) Application.SERVICE.newInstance(
            IInternalMxSCommunicationsService.class
        );
    }
}