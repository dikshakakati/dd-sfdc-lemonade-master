@isTest
private without sharing class FieldDoesNotContainValue_LCTest {
    private static final String FIELD_VALUE = 'Hello World';
    private static final String ASSERT_MESSAGE = 'Expected: true, since field: {0}, does not contains value: {1}';

    @isTest
    static void testWhenFieldContainsValueThenReturnFalse() {
        Object field = 'Hello World';
        Object value1 = 'ello world';
        Object value2 = '   ello world    ';
        System.assertEquals(
            false,
            (new FieldDoesNotContainValue_LC()).compare(field, value1),
            String.format(
                'Expected: false, since field: {0}, contains value: {1}',
                new List<Object>{ field, value1 }
            )
        );
        System.assertEquals(
            false,
            (new FieldDoesNotContainValue_LC()).compare(field, value2),
            String.format(
                'Expected: false, since field: {0}, contains value: {1}',
                new List<Object>{ field, String.valueOf(value2).trim() }
            )
        );
    }

    @isTest
    static void testWhenFieldNotContainsValueThenReturnTrue() {
        Object field = 'Hello World';
        Object value = 'ello worl d';
        System.assertEquals(
            true,
            (new FieldDoesNotContainValue_LC()).compare(field, value),
            String.format(
                'Expected: true, since field: {0}, does not contains value: {1}',
                new List<Object>{ field, value }
            )
        );
    }

    /**
     * @description To test compare returns true when field value is null.
     */
    @isTest
    static void testWhenFieldNullThenReturnTrue() {
        Object field = null;
        Object value = FIELD_VALUE;
        System.assertEquals(
            true,
            (new FieldDoesNotContainValue_LC()).compare(field, value),
            String.format(ASSERT_MESSAGE, new List<Object>{ field, value })
        );
    }
}