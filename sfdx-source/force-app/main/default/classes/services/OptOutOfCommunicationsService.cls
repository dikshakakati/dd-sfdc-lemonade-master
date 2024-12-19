/**
 * @author Deloitte
 * @date 07/23/2024
 * @description Service class for updating fields on opt out of communications setting.
 */
public inherited sharing class OptOutOfCommunicationsService {
    /**
     * @description It is used to update DoNotCall and SMSOptedOut fields
     * on phone field update.
     * @param records
     */
    public static void updateDoNotCallAndSMSOptedOut(List<SObject> records) {
        service().updateDoNotCallAndSMSOptedOut(records);
    }

    /**
     * @description It is used to update Date SMS Opted Out/In when SMS is Opted Out/In
     * @param records
     */
    public static void updateDateSMSOptedOutOrIn(List<SObject> records) {
        service().updateDateSMSOptedOutOrIn(records);
    }

    /**
     * @description It creates instance of InboundIngestionEventsServiceImpl class.
     * @return IOptOutOfCommunicationsService
     */
    private static IOptOutOfCommunicationsService service() {
        return (IOptOutOfCommunicationsService) Application.Service.newInstance(
            IOptOutOfCommunicationsService.class
        );
    }
}