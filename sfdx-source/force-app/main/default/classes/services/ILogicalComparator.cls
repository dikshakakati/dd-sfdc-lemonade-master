/**
 * @description logical comparison operator interface
 */
public interface ILogicalComparator {
    /**
     * @description Interface contract
     * @param obj1 first operand in comparison
     * @param obj2 second operand in comparison
     * @return Boolean
     */
    Boolean compare(Object obj1, Object obj2);
}