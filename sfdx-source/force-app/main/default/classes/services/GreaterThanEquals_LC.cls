/**
 * @author Deloitte
 * @date 09/12/2022
 * @description Service implementation class for Greater Than Equals operator.
 */
public inherited sharing class GreaterThanEquals_LC implements ILogicalComparator {
    /**
     * @description It returns outcome of the comparison whether
     * field is greater than or equal to the value.
     * @param field
     * @param value
     * @return Boolean
     */
    public Boolean compare(Object field, Object value) {
        String fieldToUpperCase = (field == null) ? '' : String.valueOf(field).toUpperCase().trim();
        String valueToUpperCase = (value == null) ? '' : String.valueOf(value).toUpperCase().trim();
        return fieldToUpperCase >= valueToUpperCase;
    }
}