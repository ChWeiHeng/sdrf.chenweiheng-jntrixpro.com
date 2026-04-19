/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-08-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-08-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import closeOrderMe from '@salesforce/apex/CloseOrderController.closeOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import OrderCloseBody from '@salesforce/label/c.OrderCloseBody';
import OrderCloseHeader from '@salesforce/label/c.OrderCloseHeader';
import initdata from '@salesforce/apex/CloseOrderController.init';
export default class CloseOrderLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @track isShowSpinner;
    @track reason;
    @track opList=[];
    @track showConfirmLabel;
    connectedCallback() {
        this.isShowSpinner = true;
		initdata({
            orderRecordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.opList = result.optionList;
                console.log('this.opList====>'+JSON.stringify(this.opList));
                this.showConfirmLabel = true;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));   
                this.showConfirmLabel = false; 
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.customLabel.ErrorMSG+';'+JSON.stringify(error),
                variant: 'error',
            }));
        });
    }
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        OrderCloseBody,
        OrderCloseHeader,
        CancelLable,
        ConfirmLabel,
        ErrorMSG
    }
    confirmData() {
        if(!this.reason) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.customLabel.OrderCloseBody,
                variant: 'error',
            }));
            return;
        }
		this.isShowSpinner = true;
		closeOrderMe({
            orderRecordId : this.recordId,
            reasonText : this.reason
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
                    variant: 'Success',
                }));
                this.dispatchEvent(new CustomEvent('refreshview'));
                this.dispatchEvent(new CustomEvent('closemodal'));
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
        this.reason = event.target.value;
    }
}