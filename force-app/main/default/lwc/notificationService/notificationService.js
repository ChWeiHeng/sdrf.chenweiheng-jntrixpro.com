import { LightningElement, track, wire, api } from 'lwc';
import notification from '@salesforce/apex/NotificationServiceController.notification';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CreditNotificationBody from '@salesforce/label/c.CreditNotificationBody';
import CreditNotificationHeader from '@salesforce/label/c.CreditNotificationHeader';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ErrorMSG from '@salesforce/label/c.Error';

export default class NotificationService extends NavigationMixin(LightningElement)  {
    //报价Id
    @api recordId;
    @track isShowSpinner;
    customLabel = {
        CreditNotificationBody,
        CreditNotificationHeader,
        CancelLable,
        ConfirmLabel,
        ErrorMSG
    }
	close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}

	confirmData() {
		this.isShowSpinner = true;
		notification({
            accountRecordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
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
                message: this.customLabel.ErrorMSG+';'+JSON.stringify(error),
                variant: 'error',
            }));
        });
	}
}