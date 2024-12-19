/**
 * @author atg
 * @date 05/24/2022
 * @description ApprovalListItemWrapper for AQS_ItemsToApproveController.
 */
public class ApprovalListItemWrapper
{
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public string relatedTo {get;set;}
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public string objectType {get;set;}
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public string mostRecentApprover {get;set;}
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public string targetObjectId {get;set;}
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public boolean isStandard {get;set;}
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public string processId {get;set;}
    /**
     * @description getter/setter for ApprovalListItemWrapper variable
     */
    public string dateSubmitted {get;set;}

    /**
     * @description Constructor
    * @param objId
    * @param objRelatedTo
    * @param objType
    * @param recentApprover
    * @param processId
    * @param objIsStandard
    * @param dateSubmitted
    */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public ApprovalListItemWrapper(String objId, String objRelatedTo, String objType, String recentApprover, String processId, Boolean objIsStandard, String dateSubmitted)
    {
        this.isStandard = objIsStandard;
        this.targetObjectId = objId;
        this.relatedTo = objRelatedTo;
        this.objectType = objType;
        this.mostRecentApprover= recentApprover;
        this.processId = processId;
        this.dateSubmitted = dateSubmitted;
    }
}