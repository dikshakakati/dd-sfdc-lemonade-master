/**
 * @author Deloitte
 * @date 07/23/2024
 * @description Interface class for updating fields on opt out of communications setting.
 */
public interface IOptOutOfCommunicationsService {
    /**
     * @description It is used to update DoNotCall and SMSOptedOut fields
     * on phone field update.
     * @param records
     */
    void updateDoNotCallAndSMSOptedOut(List<SObject> records);

    /**
     * @description It is used to update Date SMS Opted Out/In when SMS is Opted Out/In
     * @param records
     */
    void updateDateSMSOptedOutOrIn(List<SObject> records);
}