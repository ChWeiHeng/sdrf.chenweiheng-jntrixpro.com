import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import cloneOrderme from '@salesforce/apex/CloneOrderController.cloneOrder';
import initData from '@salesforce/apex/CloneOrderController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import OrderCloneBody from '@salesforce/label/c.OrderCloneBody';
import OrderCloneHeader from '@salesforce/label/c.OrderCloneHeader';
export default class CloneOrderLWC extends  NavigationMixin(LightningElement) {

    @api recordId;
    @track isShowSpinner;
    @track reason;
    @track opList=[];
    @track isShow;
    @track option;
    @track type;
    connectedCallback() {
        this.isShowSpinner = true;
		initData({
            orderRecordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.isShow = result.showOption;
                this.option = result.optionList;
                if(this.isShow) {
                    this.type = 'ZARB';
                }
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

    productChange(event) {
        this.type = event.target.value;
    }
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        OrderCloneBody,
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        OrderCloneHeader
    }
    confirmData() {
		this.isShowSpinner = true;
		cloneOrderme({
            orderRecordId : this.recordId,
            orderType : this.type
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