import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import confirmSync from '@salesforce/apex/CustomerSalesInfoSyncToSAPController.confirmSync';
import initData from '@salesforce/apex/CustomerSalesInfoSyncToSAPController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import notifacation from '@salesforce/label/c.notifacationBody';
import ShipToAccountSyncSapConfirmInfo from '@salesforce/label/c.ShipToAccountSyncSapConfirmInfo';
import Comment from '@salesforce/label/c.Comment';

export default class ShipToSapLWC extends NavigationMixin(LightningElement){
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
        ShipToAccountSyncSapConfirmInfo,
        Comment
    }
    confirmData() {
		this.isShowSpinner = true;
		confirmSync({
            recordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: result.errorMsg,
                    variant: 'Success',
                }));
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