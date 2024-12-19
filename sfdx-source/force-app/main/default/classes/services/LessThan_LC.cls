/**
 * @author Deloitte
 * @date 09/12/2022
 * @description Service implementation class for Less Than operator.
 */
public inherited sharing class LessThan_LC implements ILogicalComparator {
    /**
     * @description It returns outcome of the comparison whether
     * field is less than the value.
     * @param field
     * @param value
     * @return Boolean
     */
    public Boolean compare(Object field, Object value) {
        String fieldToUpperCase = (field == null) ? '' : String.valueOf(field).toUpperCase().trim();
        String valueToUpperCase = (value == null) ? '' : String.valueOf(value).toUpperCase().trim();
        return fieldToUpperCase < valueToUpperCase;
    }
}