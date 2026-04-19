import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import confirmSave from '@salesforce/apex/closeEscComplaintController.confirmSave';
import initData from '@salesforce/apex/closeEscComplaintController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ContractCreate from '@salesforce/label/c.ContractCreate';
import OrderCreateBody from '@salesforce/label/c.OrderCreateBody';
import CreateContractError from '@salesforce/label/c.CreateContractError';
import CloseEscCaseHeader from '@salesforce/label/c.CloseEscCaseHeader';
import CloseEscCaseStatus from '@salesforce/label/c.CloseEscCaseStatus';
import CloseEscCaseResolve from '@salesforce/label/c.CloseEscCaseResolve';
import CloseEscCaseReason from '@salesforce/label/c.CloseEscCaseReason';
import CloseEscCaseStatusRequired from '@salesforce/label/c.CloseEscCaseStatusRequired';
import CloseEscCaseResolveRequired from '@salesforce/label/c.CloseEscCaseResolveRequired';
import CloseEscCaseReasonRequired from '@salesforce/label/c.CloseEscCaseReasonRequired';

export default class CloseEscComplaintLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track caseStatus;
    @track opList=[];
    @track opList1=[];
    @track isPC;
    @track callReason;
    @track isResolve;
    @track isEsc=false;
    @track isClose=false;
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
            comId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.opList = result.optionList;
                console.log('this.opList====>'+JSON.stringify(this.opList));
                this.opList1 = result.optionList1;
                console.log('this.opList1====>'+JSON.stringify(this.opList1));
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
        CloseEscCaseReason,
        CloseEscCaseResolve,
        CloseEscCaseStatus,
        CloseEscCaseHeader,
        CloseEscCaseStatusRequired,
        CloseEscCaseResolveRequired,
        CloseEscCaseReasonRequired


    }
    productChange(event) {
        this.caseStatus = event.target.value;
        console.log('this.caseStatus',this.caseStatus);
        if(this.caseStatus=='Closed'){
        	this.isEsc=false;
        	this.isClose=true;
        }else if(this.caseStatus=='Cancel'){
        	this.isEsc=true;
        	this.isClose=false;
        }else{
        	this.isEsc=false;
        	this.isClose=false;
        	this.callReason = null;
        	this.isResolve = null;
        }
    }
    callReasonChange(event)
    {
    	this.callReason = event.target.value;
        console.log('this.callReason',this.callReason);
    }
    isResolveChange(event)
    {
    	this.isResolve = event.target.value;
        console.log('this.isResolve',this.isResolve);
    }
    confirmData() {
        if(!this.caseStatus) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Pelase Input  Status',
                message: this.customLabel.CloseEscCaseStatusRequired,
                variant: 'error',
            }));
            return;
        }
        if(!this.isResolve && this.isClose) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Pelase Input Resolve',
                message: this.customLabel.CloseEscCaseResolveRequired,
                variant: 'error',
            }));
            return;
        }
        if(!this.callReason && this.isEsc) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Pelase Input callReason',
                message: this.customLabel.CloseEscCaseReasonRequired,
                variant: 'error',
            }));
            return;
        }
		this.isShowSpinner = true;
		confirmSave({
            comId : this.recordId,
            status : this.caseStatus,
            cancellReason  : this.callReason,
            isResolve : this.isResolve
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