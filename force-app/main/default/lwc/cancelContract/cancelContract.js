import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

// import cancelContractMe from '@salesforce/apex/EditContractDetailController.cancelContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import Cancel_Contract_Header from '@salesforce/label/c.Cancel_Contract_Header';

// import initdata from '@salesforce/apex/EditContractDetailController.initCancelData';
export default class CancelContract extends NavigationMixin(LightningElement) {

    @api recordId;
    @track isShowSpinner;
    @track isCancel=false;
    connectedCallback() {
        // this.isShowSpinner = true;
		// initdata({
        //     contractId:this.recordId
        // }).then(result => {
        //     if (result.isSucess) {
        //         this.isCancel=true;
        //     }else{
        //         this.dispatchEvent(new ShowToastEvent({
        //             title: 'error',
        //             message: result.errorMsg,
        //             variant: 'error',
        //         }));
        //         this.isCancel=false; 
        //         //this.dispatchEvent(new CustomEvent('closemodal'));  
        //     }
        //     this.isShowSpinner = false;
        // }).catch(error => {
        //     this.isShowSpinner = false;
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'error',
        //         message: this.customLabel.ErrorMSG+';'+JSON.stringify(error),
        //         variant: 'error',
        //     }));
        // });
    }
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        Cancel_Contract_Header
    }
    confirmData() {
		// this.isShowSpinner = true;
		// cancelContractMe({
        //     contractId : this.recordId
        // }).then(result => {
        //     if (result.isSucess) {
        //     	this.dispatchEvent(new ShowToastEvent({
        //             title: 'Success',
        //             message: 'Success',
        //             variant: 'Success',
        //         }));
        //         this.dispatchEvent(new CustomEvent('refreshview'));
        //         this.dispatchEvent(new CustomEvent('closemodal'));
        //     }else{
        //         this.dispatchEvent(new ShowToastEvent({
        //             title: 'error',
        //             message: result.errorMsg,
        //             variant: 'error',
        //         }));    
        //     }
        //     this.isShowSpinner = false;
        // }).catch(error => {
        //     this.isShowSpinner = false;
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'error',
        //         message: JSON.stringify(error),
        //         variant: 'error',
        //     }));
        // });
	}
}