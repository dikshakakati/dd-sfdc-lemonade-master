import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getBusinessReferences from '@salesforce/apex/CreateBrandAndBusinessIdController.getBusinessReferencesBySourceId';
import createLog from "@salesforce/apex/LogController.createLog";
import { refreshApex } from "@salesforce/apex";
const columns = [
    { label: 'Brand Name', fieldName: 'brandNameUrl', type: 'url', typeAttributes: { label: { fieldName: 'BrandName' }, target: '_blank' } },
    { label: 'Business ID', fieldName: 'businessIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'External_Id__c' }, target: '_blank' } },
    { label: 'Business Group ID', fieldName: 'businessGroupIdUrl', type: 'url', typeAttributes: { label: { fieldName: 'Business_Group_Id__c' }, target: '_blank' } }
];
const ASCENDING = "asc";
const LWC_NAME = "displayBrandAndBusinessDataTable";


export default class DisplayBrandAndBusinessDataTable extends NavigationMixin(LightningElement) {
    @api recordId;
    businessReferences;
    columns = columns;
    defaultSortDirection = ASCENDING;
    sortDirection = ASCENDING;
    sortedBy;
    noAccess = false;

    @wire(getBusinessReferences, { recordId: '$recordId' })
    wiredBusinessReferences({ error, data }) {
        if (data) {
            this.businessReferences = data.map(row => {
                let businessIdUrl;
                if (row.External_Id__c) {
                    businessIdUrl = '/' + row.Id;
                }
                let businessGroupIdUrl;
                if (row.Business_Group_Id__c) {
                    businessGroupIdUrl = '/' + row.Id;
                }
                if (row.Brand__r) {
                    return { ...row, BrandName: row.Brand__r.Name, id: row.Id, brandNameUrl: '/' + row.Brand__c, businessIdUrl: businessIdUrl, businessGroupIdUrl: businessGroupIdUrl };
                }
                else {
                    return { ...row, id: row.Id, businessIdUrl: businessIdUrl, businessGroupIdUrl: businessGroupIdUrl };
                }
            });
        } else if (error) {
            this.noAccess = true;
            createLog({
                lwcName: LWC_NAME,
                methodName: 'CreateBrandAndBusinessIdController.getBusinessReferencesBySourceId',
                message: JSON.stringify(error.body)
            });
        }
    }

    handleBrandNameClick(event) {
        event.preventDefault();
        const brandId = event.target.dataset.brandId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: brandId,
                objectApiName: 'Brand__c',
                actionName: 'view'
            }
        });
    }

    handleBusinessIdClick(event) {
        event.preventDefault();
        const bizrefId = event.target.dataset.bizrefId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: bizrefId,
                objectApiName: 'Business_Reference__c',
                actionName: 'view'
            }
        });
    }

    handleBusinessGroupIdClick(event) {
        event.preventDefault();
        const businessGroupId = event.target.dataset.businessGroupId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: businessGroupId,
                objectApiName: 'Business_Group_Id__c',
                actionName: 'view'
            }
        });
    }

    /**
     * @description It is used to sort table by selected column.
     * @param event
     */
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.businessReferences];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === ASCENDING ? 1 : -1));
        this.businessReferences = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    /**
   * @description To refresh the datatable records after Status is updated for a record.
   */
    handleRefresh() {
        refreshApex(this.refreshDatatable);
    }


}