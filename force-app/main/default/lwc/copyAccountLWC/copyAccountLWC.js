import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import confirmClone from '@salesforce/apex/CloneShipToAccountCustomer.confirmClone';
import initData from '@salesforce/apex/CloneShipToAccountCustomer.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import notifacation from '@salesforce/label/c.notifacationBody';
import CopyCustomerConfirmInfo from '@salesforce/label/c.CopyCustomerConfirmInfo';
import Comment from '@salesforce/label/c.Comment';
import CopyCustomerConfirmInfoHeader from '@salesforce/label/c.CopyCustomerConfirmInfoHeader';


export default class CopyAccountlLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @api label;
    @track isShowSpinner;
    @track isMSG=false;
    @track commentString;
    connectedCallback() {
        this.isShowSpinner = true;
       
            initData({
                recordId : this.recordId
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
        notifacation,
        CopyCustomerConfirmInfo,
        Comment,
        CopyCustomerConfirmInfoHeader
    }
    confirmData() {
		this.isShowSpinner = true;
		confirmClone({
            recordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
                    variant: 'Success',
                }));
                window.location.href = result.returnUrl;
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