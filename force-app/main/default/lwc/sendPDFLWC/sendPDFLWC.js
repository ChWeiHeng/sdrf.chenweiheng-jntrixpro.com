import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import sendPDF from '@salesforce/apex/SendPDFController.SendPDF';
import initData from '@salesforce/apex/SendPDFController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ContractCreate from '@salesforce/label/c.ContractCreate';
import OrderCreateBody from '@salesforce/label/c.OrderCreateBody';
import CreateContractError from '@salesforce/label/c.CreateContractError';
import OrderSendPDFHeader from '@salesforce/label/c.OrderSendPDFHeader';
import OrderSendPDFConfirm from '@salesforce/label/c.OrderSendPDFConfirm';

export default class SendPDFlLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track isMSG=false;

    connectedCallback() {
        this.isShowSpinner = true;
		initData({
            orderId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.isMSG=true;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                this.isMSG=false;  
                this.dispatchEvent(new CustomEvent('closemodal'));
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
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        ContractCreate,
        OrderCreateBody,
        CreateContractError,
        OrderSendPDFConfirm,
        OrderSendPDFHeader
    }
    commentStringChange(event)
    {
    	this.commentString=event.target.value;
    	console.log('this.commentString',this.commentString);
    }
    confirmData() {
		this.isShowSpinner = true;
		sendPDF({
            orderId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'PDF Sended,Please Notice Send Result!',
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
}