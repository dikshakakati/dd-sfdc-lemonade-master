/**
 * @author Deloitte
 * @date   04/12/2024
 * @description This is the service implementation class for time zone population on related records.
 */
public inherited sharing class TimeZoneCalculationServiceImpl implements ITimeZoneCalculationService {
    private static final Integer MILLISECOND_CONVERT_INTO_HOURS = 3600000;
    /**
     * @description It calculates tiomezone difference between user profile and system timezone
     * @return Integer
     */
    public Integer getTimeZoneOffSet() {
        return (UserInfo.getTimeZone()).getOffset(DateTime.now()) / MILLISECOND_CONVERT_INTO_HOURS;
    }
    /**
     * @description It calculates and stamp time zone on the passed records.
     * @param sObjectsToCalculateTimeZone
     */
    public void calculateTimeZone(List<SObject> sObjectsToCalculateTimeZone) {
        if (sObjectsToCalculateTimeZone.isEmpty()) {
            return;
        }
        for (SObject eachSObject : sObjectsToCalculateTimeZone) {
            String timeZoneBackend = (String) eachSObject.get('Time_Zone_Backend__c');
            if (!String.isBlank(timeZoneBackend)) {
                String abbreviatedTimeZone = getTimeZoneAbbrievation(
                    TimeZone.getTimeZone(timeZoneBackend)
                );
                eachSObject.put('Time_Zone__c', abbreviatedTimeZone);
            }
        }
    }

    /**
     * @description It calculates time zone on the passed records.
     * @param timeZone
     * @return String
     */
    private static String getTimeZoneAbbrievation(TimeZone timeZone) {
        String displayName = timeZone.getDisplayName().substringAfter(')');
        displayName = displayName.substringBefore('(');
        displayName = displayName.trim();
        List<String> displayNames = displayName.split(' ');
        String abbreviatedDisplayName = '';
        if (!(displayNames.isEmpty()) && (displayNames.size() >= 3)) {
            for (Integer iterator = 0; iterator < displayNames.size(); iterator++) {
                abbreviatedDisplayName += displayNames[iterator].left(1);
            }
        }
        return abbreviatedDisplayName;
    }
}