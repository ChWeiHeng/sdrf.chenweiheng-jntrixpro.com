import { LightningElement,track,api } from 'lwc';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import Resync_Data from '@salesforce/label/c.Resync_Data';
import Resync_Body from '@salesforce/label/c.Resync_Body';
import ErrorMSG from '@salesforce/label/c.Error';
import syncData from '@salesforce/apex/ReSyncDataController.reSyncDataMe';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReSyncData  extends NavigationMixin(LightningElement) {
    customLabel = {
        Resync_Data,
        Resync_Data,
        CancelLable,
        ConfirmLabel,
        Resync_Body,
        ErrorMSG
    }
    @api recordId;
    @track isShowSpinner;
    confirmData() {
		this.isShowSpinner = true;
		syncData({
            recordId : this.recordId
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
                message: this.customLabel.ErrorMSG+':'+JSON.stringify(error),
                variant: 'error',
            }));
        });
	}

    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
}