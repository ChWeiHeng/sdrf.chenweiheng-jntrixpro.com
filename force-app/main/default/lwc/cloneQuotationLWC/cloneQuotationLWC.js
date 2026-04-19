/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 07-14-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-14-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import cloneQuotationme from '@salesforce/apex/CloneQuotationController.cloneQoute';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import QuoteCloneBody from '@salesforce/label/c.QuoteCloneBody';
import QuoteCloneHeader from '@salesforce/label/c.QuoteCloneHeader';

export default class CloneQuotationLWC extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;

    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        QuoteCloneBody,
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        QuoteCloneHeader
    }
    confirmData() {
		this.isShowSpinner = true;
		cloneQuotationme({
            quoteRecordId : this.recordId
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
                        "objectApiName": "Quote__c",
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