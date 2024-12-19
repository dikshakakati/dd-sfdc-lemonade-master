/**
 * @description Interface for SObjects
 *
 * @author Scott McClung
 * @date 2023/02/16
 */
public interface ISObjects extends fflib_ISObjects {
    /**
     * @description Convenience method to return the number of records in the domain collection
     * @return Number of records
     */
    Integer size();
}