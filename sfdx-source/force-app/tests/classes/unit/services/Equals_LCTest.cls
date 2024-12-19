@isTest
private without sharing class Equals_LCTest {
    @isTest
    static void testWhenFieldEqualsValueThenReturnTrue() {
        Object field = '1';
        Object value1 = '1';
        Object value2 = ' 1 ';
        System.assertEquals(
            true,
            (new Equals_LC()).compare(field, value1),
            String.format(
                'Expected: true, since field: {0}, equals value: {1}',
                new List<Object>{ field, value1 }
            )
        );
        System.assertEquals(
            true,
            (new Equals_LC()).compare(field, value2),
            String.format(
                'Expected: true, since field: {0}, equals value: {1}',
                new List<Object>{ field, String.valueOf(value2).trim() }
            )
        );
    }

    @isTest
    static void testWhenFieldNotEqualValueThenReturnFalse() {
        Object field = '1';
        Object value = '12';
        System.assertEquals(
            false,
            (new Equals_LC()).compare(field, value),
            String.format(
                'Expected: false, since field: {0}, not equal value: {1}',
                new List<Object>{ field, value }
            )
        );
    }
}