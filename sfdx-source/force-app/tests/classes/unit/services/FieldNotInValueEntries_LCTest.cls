@isTest
private without sharing class FieldNotInValueEntries_LCTest {
    @isTest
    static void testWhenFieldInValueEntriesThenReturnFalse() {
        Object field = 'Hello World';
        Object value = '     hELLO WORLd , hello, world, anything  ';
        System.assertEquals(
            false,
            (new FieldNotInValueEntries_LC()).compare(field, value),
            String.format(
                'Expected: false, since field: {0}, is a trimmed entry in value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    @isTest
    static void testWhenFieldNotInValueThenReturnTrue() {
        Object field = 'Hello World';
        Object value = 'hello, world';
        System.assertEquals(
            true,
            (new FieldNotInValueEntries_LC()).compare(field, value),
            String.format(
                'Expected: true, since field: {0}, does not contains value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    @isTest
    static void testWhenFieldEqualsValueThenReturnTrue() {
        Object field = 'Hello World';
        Object value = 'Hello world';
        System.assertEquals(
            true,
            (new FieldNotInValueEntries_LC()).compare(field, value),
            String.format(
                'Expected: true, since field: {0}, equals value: {1}',
                new List<Object>{ field, value }
            )
        );
    }
}