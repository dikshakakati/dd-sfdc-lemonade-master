/**
 * @author Deloitte
 * @date 28/02/2022
 * @description Interface to add reusable methods.
 */
public interface IBypassLogicModel {
    /**
     * @description This method checks if trigger context is bypassed
     * @param sObjectName
     * @param triggerContext
     * @return true or false value whether trigger is bypassed
     */
    Boolean isTriggerBypassed(String sObjectName, System.TriggerOperation triggerContext);

    /**
     * @description This sets the parent calling class name
     * @param className
     * @return String - parent calling class name
     */
    String setParentCallingClassName(String className);
}