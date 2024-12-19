/**
 * @author Deloitte
 * @date 04/15/2024
 * @description TimeZoneWrapper for localTime lightning web component.
 */

public class TimeZoneWrapper {
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    @AuraEnabled
    public String timeZoneBackend { get; set; }
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    @AuraEnabled
    public String abbreviatedWrapperTimeZone { get; set; }

    /**
     * @description Parameterized constructor to assign value to the variables.
     * @param timeZoneBackend
     * @param abbreviatedWrapperTimeZone
     */
    public TimeZoneWrapper(String timeZoneBackend, String abbreviatedWrapperTimeZone) {
        this.timeZoneBackend = timeZoneBackend;
        this.abbreviatedWrapperTimeZone = abbreviatedWrapperTimeZone;
    }
}