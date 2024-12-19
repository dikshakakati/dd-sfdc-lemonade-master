/**
 * @author Scott McLung
 * @date 09/03/2022
 * @description This mock class for batch
 */

public inherited sharing class AsyncBatchRunner {
    /**
 	* @description This method mocks the batch execute method
     @param batchClass - Pass the batchinstance
     @return service instance 
    */
    public static Id executeBatch(Object batchClass) {
        return service().executeBatch(batchClass);
    }

    /*  public static Id executeBatch(Object batchClass, Integer scope) {
        return service().executeBatch(batchClass, scope);
    }*/

    /**
 	* @description This method instantiates the service method.
     @return service instance 
	*/
    private static IAsyncBatchRunner service() {
        return (IAsyncBatchRunner) Application.SERVICE.newInstance(IAsyncBatchRunner.class);
    }
}