import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import createContractme from '@salesforce/apex/CreateContractLWCController.createContract';
import initData from '@salesforce/apex/CreateContractLWCController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ContractCreate from '@salesforce/label/c.ContractCreate';
import OrderCreateBody from '@salesforce/label/c.OrderCreateBody';
import CreateContractError from '@salesforce/label/c.CreateContractError';
import CreateOrderTypeRequired from '@salesforce/label/c.CreateOrderTypeRequired';
import CreateOrderTypeLabel from '@salesforce/label/c.CreateOrderTypeLabel';

export default class CreateContractOrderLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track orderType;
    @track opList=[];
    @track isPC;
    @track isDisplayOrder;
    @track downPayment;
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
                this.opList = result.optionList;
                console.log('this.opList====>'+JSON.stringify(this.opList));
                this.isDisplayOrder=result.isDisplayOrder;
                console.log('this.isDisplayOrder====>',this.isDisplayOrder);
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
        CreateOrderTypeRequired,
        CreateOrderTypeLabel
    }
    productChange(event) {
        this.orderType = event.target.value;
        console.log('this.orderType',this.orderType);
    }
    downPaymentChange(event)
    {
    	this.downPayment = event.target.value;
        console.log('this.downPayment',this.downPayment);
    }
    confirmData() {
        if(!this.orderType) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Pelase Input  Order Type',
                message: this.customLabel.CreateOrderTypeRequired,
                variant: 'error',
            }));
            return;
        }
        // if(!this.downPayment && this.isDisplayOrder) {
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'error',
        //         message: 'Pelase Input Down Payment Order',
        //         variant: 'error',
        //     }));
        //     return;
        // }
		this.isShowSpinner = true;
		createContractme({
            quoteId : this.recordId,
            contractTypeMe : this.orderType,
            downPayment  : this.downPayment
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
                        "recordId": result.contractId,
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