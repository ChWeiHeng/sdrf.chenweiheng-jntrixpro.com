/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-01-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-01-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import changeData from '@salesforce/apex/ChangeCustomerSalesInfoLWCController.changeData';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ChangeCustomerSalesInfoHeard from '@salesforce/label/c.ChangeCustomerSalesInfoHeard';
import ChangeCustomerSalesInfo from '@salesforce/label/c.ChangeCustomerSalesInfo';

export default class ChangeCustomerSalesInfoLWC extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;
    @track reason;
    @track opList=[];
    @track isShow;
    @track option;
    @track type;

 
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        ChangeCustomerSalesInfo,
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        ChangeCustomerSalesInfoHeard
    }
    changeData() {
		this.isShowSpinner = true;
		changeData({
            customerSalesInfoId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
                    variant: 'Success',
                }));
                this.dispatchEvent(new CustomEvent('refreshview'));
                this.dispatchEvent(new CustomEvent('closemodal'));
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        "recordId": result.newRecordId,
                        "objectApiName": "Order__c",
                        "actionName": "view"
                    },
                });	
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: JSON.stringify(error),
                variant: 'error',
            }));
        });
	}
}