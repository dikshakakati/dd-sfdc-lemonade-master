/**
 * @author Deloitte
 * @date 04/10/2024
 * @description Test class for TimeZoneValueSelector class
 */

 @isTest(seeAllData=false)
 public class TimeZoneValueSelectorTest {
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Time Zone Value';
    private static final String TIME_ZONE_LABEL = 'GMT-08:00';
    private static final String TIME_ZONE_ABBREVIATION = 'PST';
    private static final String TIME_ZONE_LABEL_MISMATCH_MESSAGE = 'Unexpected Result: Time zone label does not match';
    private static final String TIME_ZONE_ABBREVIATION_MISMATCH_MESSAGE = 'Unexpected Result: Time zone abbreviation does not match';
     /**
      * @description To test when selector method called then return SObjectType and SObjectFieldList.
      */
     @isTest
     private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
         List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
             Time_Zone_Value__mdt.Label,
             Time_Zone_Value__mdt.Time_Zone_Abbreviation__c
         };

         fflib_ApexMocks mocks = new fflib_ApexMocks();
         TimeZoneValueSelector mockTimeZoneValue = (TimeZoneValueSelector) mocks.mock(
             TimeZoneValueSelector.class
         );

         mocks.startStubbing();
         mocks.when(mockTimeZoneValue.getSObjectType()).thenReturn(Time_Zone_Value__mdt.SObjectType);
         mocks.when(mockTimeZoneValue.getSObjectFieldList()).thenReturn(sObjectFieldsMock);
         mocks.stopStubbing();
         Application.SELECTOR.setMock(mockTimeZoneValue);

         Schema.SObjectType typeOfObject = TimeZoneValueSelector.newInstance().SObjectType();
         List<Schema.SObjectField> sObjectFields = TimeZoneValueSelector.newInstance()
             .getSObjectFieldList();

         System.assertEquals(
             Time_Zone_Value__mdt.SObjectType,
             typeOfObject,
             OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
         );

         System.assertEquals(
             sObjectFieldsMock,
             sObjectFields,
             FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
         );
     }

     /**
      * @description To test when select time zone abbreviation called the return valid list.
      */
     @isTest
     private static void testWhenSelectTimeZoneAbbreviationThenReturnValidTimeZoneList() {
         Time_Zone_Value__mdt[] timeZones = new List<Time_Zone_Value__mdt>{
             new Time_Zone_Value__mdt(Label = TIME_ZONE_LABEL, Time_Zone_Abbreviation__c = TIME_ZONE_ABBREVIATION)
         };

         fflib_ApexMocks mocks = new fflib_ApexMocks();
         TimeZoneValueSelector mockTimeZoneValue = (TimeZoneValueSelector) mocks.mock(
             TimeZoneValueSelector.class
         );

         mocks.startStubbing();
         mocks.when(mockTimeZoneValue.getSObjectType()).thenReturn(Time_Zone_Value__mdt.SObjectType);
         mocks.when(mockTimeZoneValue.selectTimeZoneAbbreviation(timeZones[0].Label))
             .thenReturn(timeZones);
         mocks.stopStubbing();
         Application.SELECTOR.setMock(mockTimeZoneValue);

         List<Time_Zone_Value__mdt> timeZoneAbbreviation = TimeZoneValueSelector.newInstance()
             .selectTimeZoneAbbreviation(timeZones[0].Label);
         System.assertEquals(
             timeZones[0].Label,
             timeZoneAbbreviation[0].Label,
             TIME_ZONE_LABEL_MISMATCH_MESSAGE
         );
         System.assertEquals(
             timeZones[0].Time_Zone_Abbreviation__c,
             timeZoneAbbreviation[0].Time_Zone_Abbreviation__c,
             TIME_ZONE_ABBREVIATION_MISMATCH_MESSAGE
         );
     }
 }