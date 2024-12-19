@isTest
private without sharing class FieldContainsValue_LCTest {
    @isTest
    static void testWhenFieldContainsValueThenReturnTrue() {
        Object field = 'Hello World';
        Object value1 = 'ello world';
        Object value2 = ' ello world ';
        System.assertEquals(
            true,
            (new FieldContainsValue_LC()).compare(field, value1),
            String.format(
                'Expected: true, since field: {0}, contains value: {1}',
                new List<Object>{ field, value1 }
            )
        );
        System.assertEquals(
            true,
            (new FieldContainsValue_LC()).compare(field, value2),
            String.format(
                'Expected: true, since field: {0}, contains value: {1}',
                new List<Object>{ field, String.valueOf(value2).trim() }
            )
        );
    }

    @isTest
    static void testWhenFieldNotContainsValueThenReturnFalse() {
        Object field = 'Hello World';
        Object value = 'ello worl d';
        System.assertEquals(
            false,
            (new FieldContainsValue_LC()).compare(field, value),
            String.format(
                'Expected: false, since field: {0}, does not contains value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    @isTest
    static void testWhenFieldEqualsValueThenReturnTrue() {
        Object field = 'anything';
        Object value = 'anything';
        System.assertEquals(
            true,
            (new FieldContainsValue_LC()).compare(field, value),
            String.format(
                'Expected: true, since field: <empty>, equals -- and by conseqent contains -- value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    @isTest
    static void testWhenEitherFieldOrValueBlankThenReturnFalse() {
        Object field1 = '';
        Object value1 = 'anything';
        Object value2 = '';
        Object field2 = 'anything';
        System.assertEquals(
            false,
            (new FieldContainsValue_LC()).compare(field1, value1),
            'Expected: false, since field: <empty>'
        );
        System.assertEquals(
            false,
            (new FieldContainsValue_LC()).compare(field2, value2),
            'Expected: false, since value: <empty>'
        );
    }
}