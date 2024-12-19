/**
 * @author Scott McLung
 * @date 09/03/2022
 * @description This is interface class.
 */

public interface IAsyncBatchRunner {
    /**
 	* @description This method mocks the batch execute method
     @param batchClass - Pass the batchinstance
     @return Id 
    */
    Id executeBatch(Object batchClass);
    //Id executeBatch(Object batchClass, Integer scope);
}