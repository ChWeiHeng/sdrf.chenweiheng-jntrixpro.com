import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import changeStatus from '@salesforce/apex/ChangeQuoteStatusController.changeStatus';
import initData from '@salesforce/apex/ChangeQuoteStatusController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ContractCreate from '@salesforce/label/c.ContractCreate';
import OrderCreateBody from '@salesforce/label/c.OrderCreateBody';
import CreateContractError from '@salesforce/label/c.CreateContractError';
import ChangeIsCustomerConfirmHead from '@salesforce/label/c.ChangeIsCustomerConfirmHead';
import IsCustomerConfirmed from '@salesforce/label/c.IsCustomerConfirmed';

export default class ChangeQuoteStatusLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track changeStatus;
    @track opList=[];
    @track isPC;
    connectedCallback() {
        console.log('this.formFactorPropertyName',formFactorPropertyName);
        if(formFactorPropertyName==='Small') {
            this.isPC = false;
        }else{
            this.isPC = true;
        }
        console.log('this.isPC',this.isPC);
        this.isShowSpinner = true;
		initData({
            quoteId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.changeStatus = result.currentStatus;
                console.log('this.changeStatus====>',this.changeStatus);
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
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
        ChangeIsCustomerConfirmHead,
        IsCustomerConfirmed
    }
    productChange(event) {
        this.changeStatus = event.target.checked;
        console.log('this.changeStatus',this.changeStatus);
    }
   
    confirmData() {
		this.isShowSpinner = true;
		changeStatus({
            quoteId : this.recordId,
            currentStatus : this.changeStatus
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
}