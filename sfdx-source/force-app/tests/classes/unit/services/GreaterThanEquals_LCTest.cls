/**
 * @author Deloitte
 * @date 09/13/2022
 * @description Test class for GreaterThanEquals_LC class.
 */
@isTest(SeeAllData=false)
private class GreaterThanEquals_LCTest {
    private static final String VALUE_NOT_EQUAL_ASSERT_MESSAGE = 'Unexpected result: the field is not equal to value';
    private static final String VALUE_NOT_GREATER_ASSERT_MESSAGE = 'Unexpected result: the field is not greater than value';
    private static final String VALUE_GREATER_THAN_OR_EQUALS_ASSERT_MESSAGE = 'Unexpected result: the field is greater than or equal to the value';

    /**
     * @description To test that compare method returns true when the field
     * is greater than or equal to the value.
     */
    @isTest
    private static void testWhenFieldGreaterThanOrEqualsThenReturnTrue() {
        Object field = '2022-05-18';
        Object equalValue = '2022-05-18';
        Object greaterValue = '2022-05-07';
        System.assertEquals(
            true,
            (new GreaterThanEquals_LC()).compare(field, equalValue),
            VALUE_NOT_EQUAL_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            (new GreaterThanEquals_LC()).compare(field, greaterValue),
            VALUE_NOT_GREATER_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test that compare method returns false when the field
     * is not greater than or equal to the value.
     */
    @isTest
    private static void testWhenFieldIsNotGreaterThanOrEqualsThenReturnFalse() {
        Object field = '2022-03-11';
        Object value = '2022-04-30';
        System.assertEquals(
            false,
            (new GreaterThanEquals_LC()).compare(field, value),
            VALUE_GREATER_THAN_OR_EQUALS_ASSERT_MESSAGE
        );
    }
}