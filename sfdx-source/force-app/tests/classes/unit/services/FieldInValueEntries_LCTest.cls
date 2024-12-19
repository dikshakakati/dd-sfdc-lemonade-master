@isTest
private without sharing class FieldInValueEntries_LCTest {
    @isTest
    static void testWhenFieldInValueEntriesThenReturnTrue() {
        Object field = 'Hello World';
        Object value = '     hELLO WORLd , hello, world, anything  ';
        System.assertEquals(
            true,
            (new FieldInValueEntries_LC()).compare(field, value),
            String.format(
                'Expected: true, since field: {0}, is a trimmed entry in value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    @isTest
    static void testWhenFieldNotInValueThenReturnFalse() {
        Object field = 'Hello World';
        Object value = 'hello, world';
        System.assertEquals(
            false,
            (new FieldInValueEntries_LC()).compare(field, value),
            String.format(
                'Expected: false, since field: {0}, does not contains value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    @isTest
    static void testWhenFieldEqualsValueThenReturnFalse() {
        Object field = 'Hello World';
        Object value = 'Hello world';
        System.assertEquals(
            false,
            (new FieldInValueEntries_LC()).compare(field, value),
            String.format(
                'Expected: false, since field: {0}, equals value: {1}',
                new List<Object>{ field, value }
            )
        );
    }
}