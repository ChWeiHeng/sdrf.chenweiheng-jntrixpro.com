import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import submit from '@salesforce/apex/SubmitContractController.submitContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import SubmitContractBody from '@salesforce/label/c.SubmitContractBody';
import SubmitContractHeader from '@salesforce/label/c.SubmitContractHeader';

export default class SubmitContractLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        SubmitContractBody,
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        SubmitContractHeader
    }
    confirmData() {
		this.isShowSpinner = true;
		submit({
            conRecordId : this.recordId
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