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
import CreateContractType from '@salesforce/label/c.CreateContractType';
import CreateContractHeader from '@salesforce/label/c.CreateContractHeader';
import CreateContractTypeRequired from '@salesforce/label/c.CreateContractTypeRequired';

export default class CreateContractLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track contractType;
    @track opList=[];
    @track isPC;
    @track isMSG=false;
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
                this.isMSG=true;
                let opMap = [];
                opMap.push({label: null,value: null});
                opMap.push({label: 'Final Customer' ,value: 'Final Customer'});
                opMap.push({label: 'Subsidiary',value: 'Subsidiary'});
                this.opList = opMap;
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
        CreateContractHeader,
        CreateContractType,
        CreateContractTypeRequired
    }
    productChange(event) {
        this.conType = event.target.value;
        console.log('this.conType',this.conType);
    }
    confirmData() {
		this.isShowSpinner = true;
        if(!this.conType) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Pelase Input  Contract Type',
                message: this.customLabel.CreateContractTypeRequired,
                variant: 'error',
            }));
            this.isShowSpinner = false;
            return;

        }
		createContractme({
            quoteId : this.recordId,
            contractTypeMe : this.conType,
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
                        "objectApiName": "Contracts__c",
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