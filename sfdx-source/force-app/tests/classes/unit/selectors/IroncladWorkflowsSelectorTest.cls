/**
 * @author Deloitte
 * @date 05/28/2024
 * @description Test class for IroncladWorkflowsSelector class.
 */
@isTest(SeeAllData=false)
public class IroncladWorkflowsSelectorTest {
    private static final String OUT_FOR_SIGNATURE = 'Out for Signature';
    private static final String QUOTE_APPROVED = 'Approved';
    private static final String QUOTE_PENDING = 'Pending';
    private static final String OPPORTUNITY_DRAFT = 'Draft';
    private static final String OPPORTUNITY_PITCHING = 'Pitching';
    private static final String OPPORTUNITY_CLOSED_LOST = 'Closed Lost';
    private static final String OPPORTUNITY_SUB_STAGE_DISCOVERY = 'Discovery';
    private static final String PROCESS_AUTOMATION_USER = 'Process Automation User';
    private static final String OPPORTUNITY_LOST_REASON = 'Pricing';
    private static final String ASSERT_MESSAGE_FOR_SIZE = 'Expected one ironclad workflow record';
    private static final String ASSERT_MESSAGE = 'Unexpected ironclad workflow record';
    private static final String OPPORTUNITY_NAME = 'MOCK Test Opportunity';

    /**
     * @description It is used to test when Opportunity Id is passed then Ironclad Workflow record
     * based on the passed Opportunity ids where Quote is primary and Quote's Status is Out for
     * Signature is returned.
     */
    @isTest
    private static void testWhenOpportunityIdPassedThenIroncladWorkflowsWithPrimaryAndOutOfSignatureQuoteReturned() {
        Opportunity mockOppty = new Opportunity(
            Name = OPPORTUNITY_NAME,
            CloseDate = system.today(),
            StageName = OPPORTUNITY_PITCHING,
            Substage__c = OPPORTUNITY_SUB_STAGE_DISCOVERY
        );
        insert mockOppty;

        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = mockOppty.Id,
            SBQQ__Primary__c = true,
            ApprovalStatus__c = QUOTE_APPROVED,
            SBQQ__Status__c = OPPORTUNITY_DRAFT
        );
        insert mockQuote;
        mockQuote.SBQQ__Status__c = OUT_FOR_SIGNATURE;
        update mockQuote;

        ironclad__Ironclad_Workflow__c ironcladWorkflow = new ironclad__Ironclad_Workflow__c(
            ironclad__Workflow_ID__c = '123',
            Quote__c = mockQuote.Id
        );
        insert ironcladWorkflow;

        Test.startTest();
        mockOppty.StageName = OPPORTUNITY_CLOSED_LOST;
        mockOppty.Lost_Reason__c = OPPORTUNITY_LOST_REASON;
        update mockOppty;
        List<ironclad__Ironclad_Workflow__c> result = IroncladWorkflowsSelector.newInstance()
            .selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
                new Set<Id>{ mockOppty.Id }
            );
        Test.stopTest();
        System.assertEquals(1, result.size(), ASSERT_MESSAGE_FOR_SIZE);
        System.assertEquals(mockQuote.Id, result[0].Quote__c, ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test when Opportunity Id is passed then Ironclad Workflow record
     * based on the passed Opportunity ids where Quote is primary and Quote's Status is not Out for
     * Signature is not returned.
     */
    @isTest
    private static void testWhenOpportunityIdPassedThenIroncladWorkflowsWithPrimaryAndDraftQuoteNotReturned() {
        Opportunity mockOppty = new Opportunity(
            Name = OPPORTUNITY_NAME,
            CloseDate = system.today(),
            StageName = OPPORTUNITY_PITCHING,
            Substage__c = OPPORTUNITY_SUB_STAGE_DISCOVERY
        );
        insert mockOppty;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = mockOppty.Id,
            SBQQ__Primary__c = true,
            ApprovalStatus__c = QUOTE_APPROVED,
            SBQQ__Status__c = OPPORTUNITY_DRAFT
        );
        insert mockQuote;
        ironclad__Ironclad_Workflow__c ironcladWorkflow = new ironclad__Ironclad_Workflow__c(
            ironclad__Workflow_ID__c = '123',
            Quote__c = mockQuote.Id
        );
        insert ironcladWorkflow;
        Test.startTest();
        mockOppty.StageName = OPPORTUNITY_CLOSED_LOST;
        mockOppty.Lost_Reason__c = OPPORTUNITY_LOST_REASON;
        update mockOppty;
        List<ironclad__Ironclad_Workflow__c> result = IroncladWorkflowsSelector.newInstance()
            .selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
                new Set<Id>{ mockOppty.Id }
            );
        Test.stopTest();
        System.assertEquals(0, result.size(), ASSERT_MESSAGE_FOR_SIZE);
    }
}