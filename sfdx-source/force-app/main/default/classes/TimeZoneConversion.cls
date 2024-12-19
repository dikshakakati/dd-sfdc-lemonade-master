/**
 * @author Deloitte
 * @date 07/17/2024
 * @description  Controller class for Guided flow.
 */
public with sharing class TimeZoneConversion {
    /**
     * @description To generate Mx Order and Mx Order Items
     * @return List<Integer>
     */
    @InvocableMethod(
        label='Get Timezone difference/offset '
        description='It returns user timezone difference with system time'
    )
    public static List<Integer> getTimeZoneOffSets() {
        return new List<Integer>{ getTimeZoneOffSet() };
    }
    /**
     * @description To generate Mx Order and Mx Order Items
     * @return List<Integer>
     */
    public static Integer getTimeZoneOffSet() {
        return TimeZoneCalculationService.getTimeZoneOffSet();
    }
}
