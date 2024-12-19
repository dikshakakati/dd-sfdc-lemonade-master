/**
 * @description This is the controller for localTime component.
 * @author Deloitte
 * @date 04/09/2024
 */
public with sharing class LocalTimeController {
    /**
     * @description To retrieve related metadata record
     * @param recordId The Id of the Account or Lead record
     * @return TimeZoneWrapper A wrapper containing the time zone information
     */
    @AuraEnabled(Cacheable=true)
    public static TimeZoneWrapper getTimeZoneFromBackend(Id recordId) {
        try {
            String timeZoneBackend;
            String abbreviatedDisplayName;
            Set<Id> idSet = new Set<Id>{ recordId };
            List<SObject> records = new List<SObject>();
            // Check if the record is an Account or a Lead
            SObjectType recordType = recordId.getSobjectType();

            if (recordType == Account.SObjectType) {
                records = AccountsSelector.newInstance().selectById(idSet);
            } else if (recordId.getSobjectType() == Lead.SObjectType) {
                records = LeadsSelector.newInstance().selectById(idSet);
            }

            if (records.isEmpty()) {
                throw new LocalTimeControllerException(
                    'Given record id does not exist in Lead or Account tables. Record Id:' +
                    recordId
                );
            }

            timeZoneBackend = (String) records[0].get('Time_Zone_Backend__c');
            if (String.isBlank(timeZoneBackend)) {
                throw new LocalTimeControllerException(
                    'Given record does not have a valid value in Time_Zone_Backend__c field. Record Id:' +
                    recordId
                );
            }

            abbreviatedDisplayName = getTimeZoneAbbreviation(TimeZone.getTimeZone(timeZoneBackend));
            return new TimeZoneWrapper(timeZoneBackend, abbreviatedDisplayName);
        } catch (Exception e) {
            throw new AuraHandledException('Unable to retrieve the merchant\'s local timezone.');
        }
    }

    /**
     * @description Generates an abbreviated display name for a given TimeZone
     * @param timeZone The TimeZone object to generate the abbreviation for
     * @return String The abbreviated display name of the TimeZone
     */
    private static String getTimeZoneAbbreviation(TimeZone timeZone) {
        String displayName = timeZone.getDisplayName()
            .substringAfter(')')
            .substringBefore('(')
            .trim();

        List<String> displayNames = displayName.split(' ');
        String abbreviatedDisplayName = '';
        Integer displayNameListSize = displayNames.size();
        if (!(displayNames.isEmpty()) && (displayNameListSize >= 3)) {
            for (Integer iterator = 0; iterator < displayNames.size(); iterator++) {
                abbreviatedDisplayName += displayNames[iterator].left(1);
            }
        }
        return abbreviatedDisplayName;
    }

    /**
     * @description Custom exception class for LocalTimeController
     */
    public class LocalTimeControllerException extends Exception {
    }
}