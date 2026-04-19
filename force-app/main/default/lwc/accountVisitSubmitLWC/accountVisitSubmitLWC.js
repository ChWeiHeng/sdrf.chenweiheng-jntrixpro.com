import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import noticeManage from '@salesforce/apex/AccountVisitSubmitController.NoticeManage';
import initData from '@salesforce/apex/AccountVisitSubmitController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ContractCreate from '@salesforce/label/c.ContractCreate';
import OrderCreateBody from '@salesforce/label/c.OrderCreateBody';
import CreateContractError from '@salesforce/label/c.CreateContractError';
import CustomerVisitSubmitHeader from '@salesforce/label/c.CustomerVisitSubmitHeader';
import CustomerVisitSubmitConfirm from '@salesforce/label/c.CustomerVisitSubmitConfirm';

export default class AccountVisitSubmitLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track isPC;
    @track isMSG=false;
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
            accVisitId : this.recordId
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
        CustomerVisitSubmitConfirm,
        CustomerVisitSubmitHeader

    }
    confirmData() {
		this.isShowSpinner = true;
		noticeManage({
            accVisitId : this.recordId
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