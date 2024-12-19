/**
 * @author Deloitte
 * @date 04/18/2024
 * @description Interface of service class for TimeZoneCalculationService class.
 */
public interface ITimeZoneCalculationService {
    /**
     * @description It calculates and stamp time zone on the passed records.
     * @param recordsToCalculateTimeZone
     */
    void calculateTimeZone(List<SObject> recordsToCalculateTimeZone);
    /**
     * @description It calculates tiomezone difference between user profile and system timezone
     * @return Integer
     */
    Integer getTimeZoneOffSet();
}