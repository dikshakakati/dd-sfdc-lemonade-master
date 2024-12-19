/**
 * @author Deloitte
 * @date 12/04/2023
 * @description JavaScript controller for storeAssociationFailures lightning web component.
 */
import { LightningElement, wire, api, track } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import NUMBER_OF_DAYS from '@salesforce/label/c.StoresAssociationFailures_DAYS_FILTER';
import LIMITVALUE from '@salesforce/label/c.StoresAssociationFailures_LIMIT_VALUE';
import noDataFoundMessage from '@salesforce/label/c.Stores_On_WorkPlan_No_Data_Found_Message';
import createLog from '@salesforce/apex/LogController.createLog';

const BUSINESS_ERROR = 'BUSINESS_ERROR';
const DML_EXCEPTION = 'DML_EXCEPTION';
const columns = [
  {
    label: 'Store Name',
    fieldName: 'StoreAccountLink',
    type: 'url',
    typeAttributes: {
      label: {
        fieldName: 'StoreAccountName'
      },
      target: '_self'
    }
  },
  { label: 'Detailed Message', fieldName: 'DetailedMessage', wrapText: true },
];
const FORWARD_SLASH = '/';
const GRAPHQL_RESULTS_METHOD_NAME = 'graphqlQueryResult';
const LWC_NAME = 'StoreAssociationFailures';

export default class StoreAssociationFailures extends LightningElement {
  @api recordId;
  @track loadMore;
  @track isLoading = false;
  columns = columns;
  endcursor;
  errors;
  hasNextPage;
  hasPreviousPage;
  loaded = false;
  loadingAlternativeText = loading;
  noDataFoundMessage = noDataFoundMessage;
  results;
  pageInfo;
  recordsCount;
  showDataTable = false;
  showMessage = true;
  startCursor;
  storeAssociationFailures = [];

  /**
   * @description To fetch log records details from current business account.
   * @JIRA# LEM-11499
   */
  @wire(graphql, {
    query: gql`
      query getLogs($recordId: String, $businessError: String, $dmlException: String, $loadMore: String, $numberOfDays: Int, $limitValue: Int) {
        uiapi {
          query {
            Log__c( first: $limitValue, after: $loadMore,
                    where: {
                      and: [
                        {or: [
                          {
                            Parent_Account_Id_18__c: { eq: $recordId }
                          },
                          {
                            Franchise_Parent_Account_Id_18__c: { eq: $recordId }
                          }
                        ]},
                        {or: [
                          {
                            Log_Type__c: { eq: $businessError }
                          },
                          {
                            Log_Type__c: { eq: $dmlException }
                          }
                        ]}
                      ],
                      CreatedDate: { gte: { range: { n_days_ago: $numberOfDays } } }
                    }
                    orderBy: {
                      CreatedDate: { order: DESC },
                      Store_Account_Name__c: { order: ASC }
                    }
                  ) {
              totalCount
              edges {
                node {
                  Id
                  Name {
                    value
                  }
                  Store_Account_Id_18__c {
                    value
                  }
                  Store_Account_Name__c{
                    value
                  }
                  Detailed_Message__c{
                    value
                  }
                }
                cursor
              }
              pageInfo {
                endCursor
                hasNextPage
                hasPreviousPage
                startCursor
              }
          }
        }
      }
    }`,
    variables: "$variables",
  })
  graphqlQueryResult({ data, errors }) {
    if (data) {
      this.parseData(data);
      this.errors = undefined;
      this.loaded = true;
      if (this.results && Array.isArray(this.results) && this.results.length > 0) {
        this.showDataTable = true;
        this.showMessage = false;
      }
    }
    else if (errors) {
      this.errors = errors;
      this.loaded = true;
      this.showDataTable = false;
      this.showMessage = true;
      this.results = undefined;
      createLog({
        lwcName: LWC_NAME, methodName: GRAPHQL_RESULTS_METHOD_NAME,
        message: JSON.stringify(errors)
      });
    }
  }

  /**
   * @description To get variables for GraphQL query.
   * @JIRA# LEM-11499
   */
  get variables() {
    return {
      businessError: BUSINESS_ERROR,
      dmlException: DML_EXCEPTION,
      limitValue: parseInt(LIMITVALUE, 10),
      loadMore: this.loadMore,
      numberOfDays: parseInt(NUMBER_OF_DAYS, 10),
      recordId: this.recordId,
    }
  }

  /**
   * @description To parse data recieved from GraphQL query result.
   * @JIRA# LEM-11499
   * @param data
   */
  parseData(data) {
    this.storeAssociationFailures = this.storeAssociationFailures.concat(data.uiapi.query.Log__c.edges);;
    this.results = this.storeAssociationFailures.map((edge) => ({
      Id: edge.node.Id,
      DetailedMessage: edge.node.Detailed_Message__c.value,
      Name: edge.node.Name.value,
      StoreAccountId: edge.node.Store_Account_Id_18__c.value,
      StoreAccountLink: FORWARD_SLASH + edge.node.Store_Account_Id_18__c.value,
      StoreAccountName: edge.node.Store_Account_Name__c.value
    }));
    this.endCursor = data.uiapi.query.Log__c.pageInfo.endCursor;
    this.hasNextPage = data.uiapi.query.Log__c.pageInfo.hasNextPage;
    this.hasPreviousPage = data.uiapi.query.Log__c.pageInfo.hasPreviousPage;
    this.recordsCount = data.uiapi.query.Log__c.totalCount;
    this.startCursor = data.uiapi.query.Log__c.pageInfo.startCursor;
    this.isLoading = false;
  }

  /**
   * @description It is used to load more store association failures
   * on scrolling through the datatable.
   * @JIRA# LEM-11499
   * @param event
   */
  loadMoreData(event) {
    this.loadMore = this.endCursor;
    if (!this.hasNextPage) {
      event.target.enableInfiniteLoading = false;
    }
    this.isLoading = true;
  }
}