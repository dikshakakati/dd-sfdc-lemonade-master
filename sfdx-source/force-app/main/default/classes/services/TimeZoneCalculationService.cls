/**
 * @author Deloitte
 * @date   04/12/2024
 * @description This is the service interface for time zone calculation logic.
 */
public inherited sharing class TimeZoneCalculationService {
    /**
     * @description It calculates tiomezone difference between user profile and system timezone
     * @return Integer
     */
    public static Integer getTimeZoneOffSet() {
        return service().getTimeZoneOffSet();
    }

    /**
     * @description It calculates and stamp time zone on the passed records.
     * @param recordsToCalculateTimeZone
     */
    public static void calculateTimeZone(List<SObject> recordsToCalculateTimeZone) {
        service().calculateTimeZone(recordsToCalculateTimeZone);
    }

    private static ITimeZoneCalculationService service() {
        return (ITimeZoneCalculationService) Application.Service.newInstance(
            ITimeZoneCalculationService.class
        );
    }
}