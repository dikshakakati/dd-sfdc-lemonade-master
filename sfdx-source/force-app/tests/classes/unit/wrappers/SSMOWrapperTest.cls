/**
 * @description       :
 * @author            : Soumya Dash
 * @group             :
 * @last modified on  : 07-15-2024
 * @last modified by  : Soumya Dash
**/
@isTest
private  class SSMOWrapperTest {

    /**
    * @description - test Wrapper deserialize
    * @author Soumya Dash | 06-28-2024
    **/
    @isTest
    private static void testWhenWrapperThenDeserialize(){
        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        Assert.areNotEqual(null,result,'');
    }
}