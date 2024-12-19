/**
  * @author Deloitte
  * @date 06/10/2024
  * @description It facilitates the retrieval and display subscription records
  * and data below contract table.
*/
import { LightningElement, api, track, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import getAllSubscriptionColumns from '@salesforce/apex/ContractsSummaryController.getAllSubscriptionColumns';

const ADS_PROMOS = 'Ads & Promos';
const BLANK = '_blank';
const FORWARD_SLASH = "/";
const GRAPHQL_QUERY_ERROR = 'GraphQL query error:';
const ID = "id";
const LOADING = "Loading";
const NO_SUBSCRIPTION_ERROR = 'No subscription columns found.';
const NO_SUBSCRIPTION_COLUMN_ERROR = 'Error fetching subscription columns:';
const NO_CONTRACT_ERROR = 'Contract Id is not provided.';
const RECORDLINK = 'recordLink';
const SPINNER_SIZE_MEDIUM = "medium";
const SPINS = "spins";
const SUBSCRIPTION_API_NAME = 'Name';
const TYPE_URL = 'url';

export default class LwcSubscriptionSummary extends LightningElement {
  @api contractId;
  @api splitCategory;
  @track loadMore;
  @track data = [];
  @track columns = [];
  @track errors;
  @track results = [];
  subscriptionSummary = [];
  queryString = '';
  dynamicFields = [];
  sectionValues = {
    ID,
    LOADING,
    SPINNER_SIZE_MEDIUM,
    SPINS
  }
  loaded = false;

  connectedCallback() {
    if (this.contractId) {
      this.fetchSubscriptionColumns();
    } else {
      console.error(NO_CONTRACT_ERROR);
    }
  }

  /**
   * @description It returns all the subscription columns present in the Contract_Table_Mapping__mdt.
   */
  fetchSubscriptionColumns() {
    getAllSubscriptionColumns({ contractId: this.contractId, splitCategory: this.splitCategory })
      .then(result => {
        if (result && result.contractDataTableMap) {
          result.contractDataTableMap.forEach(column => {
            if (column.API_Name__c === SUBSCRIPTION_API_NAME) {
              this.columns.push({
                label: column.Label,
                fieldName: RECORDLINK,
                type: TYPE_URL,
                typeAttributes: { label: { fieldName: column.API_Name__c }, target: BLANK },
              });
            }
            else {
              this.columns.push({
                label: column.Label,
                fieldName: column.API_Name__c
              });
            }
          });
        } else {
          this.errors = NO_SUBSCRIPTION_ERROR;
          console.error(NO_SUBSCRIPTION_ERROR);

        }
      })
      .catch(error => {
        this.errors = NO_SUBSCRIPTION_COLUMN_ERROR;
        console.error(NO_SUBSCRIPTION_COLUMN_ERROR, error);
      }).finally(() => {
        this.loaded = true;
      });
  }

  /**
   * @description It is used to query the Subscription records and the field values.
   */
  @wire(graphql, {
    query: gql`
            query getSubscriptions($contractId: ID!, $isActive: Boolean, , $limitValue: Int) {
              uiapi {
                query {
                  SBQQ__Subscription__c( first: $limitValue
                                 where: {
                                  and: [
                                    {
                                      SBQQ__Contract__c: { eq: $contractId }
                                    },
                                    {
                                      Is_Active__c: { eq: $isActive  }
                                    },
                                  ]
                                 }
                                 orderBy: {
                                  Sort_Order__c: { order: ASC },
                                }
                               ) {
                    edges {
                      node {
                        Id
                         Name {
                      value
                    }
                    Start_Date__c {
                      value
                    }
                    End_Date__c {
                      value
                    }
                    SBQQ__ProductName__c {
                      value
                    }
                    Package__c {
                      value
                    }
                    Budget__c {
                      value
                    }
                    Budget_Period__c {
                      value
                    }
                    Split_Category__c{
                      value
                    }
                    Final_Commission__c{
                      value
                    }
                    Final_Fee__c{
                      value
                    }
                    Trial_Commission__c{
                      value
                    }
                    Trial_Fee__c{
                      value
                    }
                    Trial_Period__c{
                      value
                    }
                    Trial_Start_Date__c{
                      value
                    }
                    Contract_Signed_Date__c{
                      value
                    }
                      }
                      cursor
                  }
                  }
                }
              }
            }`,
    variables: "$variables",
  })
  graphqlQueryResult({ data, error }) {
    if (data) {
      this.parseData(data);
      this.errors = undefined;
    } else if (error) {
      this.errors = this.errors = GRAPHQL_QUERY_ERROR + JSON.stringify(error);;
      this.results = undefined;
      console.error(GRAPHQL_QUERY_ERROR, JSON.stringify(error));
    }
  }

  /**
   * @description It stores subscriptions field values to the respective column.
   */
  parseData(data) {
    this.subscriptionSummary = (this.subscriptionSummary || []).concat(data.uiapi.query.SBQQ__Subscription__c.edges);
    this.results = this.subscriptionSummary.map((edge, index) => ({
      Id: edge.node.Id,
      Name: edge.node.Name.value,
      recordLink: FORWARD_SLASH + edge.node.Id,
      Package__c: edge.node.Package__c.value,
      SBQQ__ProductName__c: edge.node.SBQQ__ProductName__c.value,
      Final_Commission__c: (this.splitCategory !== ADS_PROMOS && !edge.node.Package__c.value) ? '' : this.formatNumber(edge.node.Final_Commission__c.value),
      Final_Fee__c: (this.splitCategory !== ADS_PROMOS && !edge.node.Package__c.value) ? '' : this.formatNumber(edge.node.Final_Fee__c.value),
      Start_Date__c: (this.splitCategory !== ADS_PROMOS && !edge.node.Package__c.value) ? '' : edge.node.Start_Date__c.value,
      Contract_Signed_Date__c: edge.node.Contract_Signed_Date__c.value,
      Budget__c: edge.node.Budget__c.value,
      End_Date__c: edge.node.End_Date__c.value,
      Budget_Period__c: edge.node.Budget_Period__c.value,
      Trial_Commission__c: this.formatNumber(edge.node.Trial_Commission__c.value),
      Trial_Fee__c: this.formatNumber(edge.node.Trial_Fee__c.value),
      Trial_Period__c: edge.node.Trial_Period__c.value,
      Trial_Start_Date__c: edge.node.Trial_Start_Date__c.value,
    }));
    this.data = this.results;
  }

  /**
   * @description It returns contract Id.
   */
  get variables() {
    return {
      contractId: this.contractId,
      isActive: true,
      limitValue: 50
    }
  }
  formatNumber(value) {
    if (value == null || isNaN(value)) {
      return '';
    }
    return parseFloat(value).toFixed(2);
  }
}
