/**
 * @description Advanced Approvals Quickstart package
 * @author ATG
 * @date 04/20/2022
 */

public inherited sharing class AQS_ItemsToApproveController{

    /**
 	 * @description getter/setter for requestedApprovals variable
	 * @param
	 * @return List<SBAA__Approval__c> - Returns email template list
 	 */
    public List<SBAA__Approval__c> requestedApprovals {get;set;}
    /**
 	 * @description getter/setter for approvalLists variable
	 * @param
	 * @return List<ApprovalListItemWrapper> - Returns email template list
 	 */
    public List<ApprovalListItemWrapper> approvalLists {get;set;}

    /**
 	 * @description getter/setter for approvalListSize variable
	 * @param
	 * @return Integer - approval List size
 	 */
    public Integer approvalListSize {get;set;}


    /**
 	 * @description constructor
	 * @param
 	 */
    public AQS_ItemsToApproveController(){
        getApprovalListItemWrapperItems();
    }

    /**
 	 * @description gets Approval List Items for display
	 * @return List<ApprovalListItemWrapper>
 	 */
    private List<ApprovalListItemWrapper> getApprovalListItemWrapperItems(){
        Map<Id, String> mapApprovals = new Map<Id, String>();
        String createdDateValue;
        String lastActorInfo;
        approvalLists = new List<ApprovalListItemWrapper>();
        approvalListSize=0;

        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};

        Set<Id> groupIds = getGroupIds(userIds);
        userIds.addAll(groupIds);

        //get Advanced Approvals
        requestedApprovals = getRequestedApprovals(userIds);
        List<SBAA__Approval__c> approvedApprovals = getApprovedApprovals();

        //get approved approvals to populate last actor info - if approval is in a chain
        for(SBAA__Approval__c currentApproval: approvedApprovals){

            if(!mapApprovals.containsKey(currentApproval.AQS_Quote__c)){

               mapApprovals.put(currentApproval.AQS_Quote__c, currentApproval.SBAA__ApprovedBy__r.Name);
            }
        }

       //get requested approvals to display
        for(SBAA__Approval__c currentApproval: requestedApprovals)
        {
            lastActorInfo = mapApprovals.get(currentApproval.AQS_Quote__c) != null ? mapApprovals.get(currentApproval.AQS_Quote__c) : ' ';
            createdDateValue = currentApproval.CreatedDate.format('MM/dd/yyyy hh:mm a');

            approvalLists.add(new ApprovalListItemWrapper(currentApproval.AQS_Quote__c, currentApproval.AQS_Quote__r.Name,
                                                        'Quote', lastActorInfo, currentApproval.Id, false, createdDateValue));
        }

        approvalListSize = approvalLists.size();
        return approvalLists;
    }

    /**
 	 * @description SOQL to get Groups that these Users belong to
	 * @param userIds
	 * @return Set<Id>
 	 */
    private Set<Id> getGroupIds(Set<Id> userIds) {
        Set<Id> returnSet = new Set<Id>();
        List<GroupMember> groupMembersList = GroupMembersSelector.newInstance().selectGroupMembersByUserId(userIds);

        for(GroupMember member : groupMembersList){
            returnSet.add(member.GroupId);
        }

        return returnSet;
    }

    /**
 	 * @description SOQL to get Requested Approvals
	 * @param userIds
	 * @return List<SBAA__Approval__c>
 	 */
    private List<SBAA__Approval__c> getRequestedApprovals(Set<Id> userIds){
        return AQS_AAApprovalSelector.newInstance().selectRequestedForUserIds(userIds);
    }

    /**
 	 * @description SOQL to get Approvals with status Approved
	 * @param
	 * @return List<SBAA__Approval__c>
 	 */
    private List<SBAA__Approval__c> getApprovedApprovals(){
        return AQS_AAApprovalSelector.newInstance().selectApprovedOrderedByLastModifiedDate();
    }
}