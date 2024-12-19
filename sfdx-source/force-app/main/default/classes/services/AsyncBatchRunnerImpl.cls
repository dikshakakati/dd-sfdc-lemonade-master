/**
 * @author Scott McLung
 * @date 09/03/2022
 * @description This mock class for batch implementation
 */

public inherited sharing class AsyncBatchRunnerImpl implements IAsyncBatchRunner {
    /**
 	* @description This method mocks the batch execute method
     @param batchClass - Pass the batchinstance
     @return Id 
    */
    public Id executeBatch(Object batchClass) {
        return Database.executeBatch((Database.Batchable<SObject>) batchClass);
    }

    /*public Id executeBatch( Object batchClass, Integer scope ) {
        return Database.executeBatch( (Database.Batchable<SObject>) batchClass, scope );
    }*/
}