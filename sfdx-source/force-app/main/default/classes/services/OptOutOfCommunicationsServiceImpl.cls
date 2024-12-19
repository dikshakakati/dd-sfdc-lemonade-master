/**
 * @author Deloitte
 * @date 07/23/2024
 * @description Service Implemtation class for updating fields on opt out of communications setting.
 */
public inherited sharing class OptOutOfCommunicationsServiceImpl implements IOptOutOfCommunicationsService {
    private static final String OPT_OUT_OF_MARKETING = 'Opt_Out_of_Marketing__c';
    private static final String PHONE = 'Phone';
    private static final String DO_NOT_CALL = 'DoNotCall';
    private static final String SMS_OPTED_OUT = 'SMS_Opted_Out__c';
    private static final String DATE_SMS_OPTED_OUT_IN = 'Date_SMS_Opted_Out_In__c';
    /**
     * @description It is used to update DoNotCall and SMSOptedOut fields
     * on phone field update.
     * @param records
     */
    public static void updateDoNotCallAndSMSOptedOut(List<SObject> records) {
        for (SObject eachRecord : records) {
            if (eachRecord.get(OPT_OUT_OF_MARKETING) == false && eachRecord.get('Phone') != null) {
                if (eachRecord.get(DO_NOT_CALL) == true) {
                    eachRecord.put(DO_NOT_CALL, false);
                }
                if (eachRecord.get(SMS_OPTED_OUT) == true) {
                    eachRecord.put(SMS_OPTED_OUT, false);
                }
            }
        }
    }

    /**
     * @description It is used to update Date SMS Opted Out/In when SMS is Opted Out/In
     * @param records
     */
    public static void updateDateSMSOptedOutOrIn(List<SObject> records) {
        for (SObject eachRecord : records) {
            eachRecord.put(DATE_SMS_OPTED_OUT_IN, System.TODAY());
        }
    }
}