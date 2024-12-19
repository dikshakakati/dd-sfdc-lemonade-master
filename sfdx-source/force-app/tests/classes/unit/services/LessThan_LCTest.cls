/**
 * @author Deloitte
 * @date 09/13/2022
 * @description Test class for LessThan_LC class.
 */
@isTest(SeeAllData=false)
private class LessThan_LCTest {
    private static final String VALUE_NOT_LESS_ASSERT_MESSAGE = 'Unexpected result: the field is not less than the value';
    private static final String VALUE_LESS_THAN_ASSERT_MESSAGE = 'Unexpected result: the field is less than the value';

    /**
     * @description To test that compare method returns true when the field
     * is less than the value.
     */
    @isTest
    private static void testWhenFieldIsLessThanValueThenReturnTrue() {
        Object field = '2022-01-02';
        Object value = '2022-02-17';
        System.assertEquals(
            true,
            (new LessThan_LC()).compare(field, value),
            VALUE_NOT_LESS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test that compare method returns false when the field
     * is not less than the value.
     */
    @isTest
    private static void testWhenFieldIsNotLessThanValueThenReturnFalse() {
        Object field = '2022-09-10';
        Object value = '2022-07-04';
        System.assertEquals(
            false,
            (new LessThan_LC()).compare(field, value),
            VALUE_LESS_THAN_ASSERT_MESSAGE
        );
    }
}