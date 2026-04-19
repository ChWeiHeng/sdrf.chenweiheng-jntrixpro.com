/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-03-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-02-2026   Gerry   Initial Version
**/
import { LightningElement,track,api  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import CreateFreeOrder from '@salesforce/label/c.CreateFreeOrder';
import CreateFreeOrderConfirm from '@salesforce/label/c.CreateFreeOrderConfirm';
import confirmCreate from '@salesforce/apex/CreateFreeOrderController.createFreeOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateFreeOrderLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;
    connectedCallback() {
        
    }
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        CancelLable,
        ConfirmLabel,
        CreateFreeOrder,
        CreateFreeOrderConfirm
    }
    confirmData() {
		this.isShowSpinner = true;
		confirmCreate({
            recordId : this.recordId
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