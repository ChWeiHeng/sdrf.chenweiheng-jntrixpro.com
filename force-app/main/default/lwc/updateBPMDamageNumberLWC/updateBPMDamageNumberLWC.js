/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 03-30-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-30-2026   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import UpdateBPMNumber from '@salesforce/label/c.UpdateBPMNumber';
import BPMNumberRequired from '@salesforce/label/c.BPMNumberRequired';

import confirm from '@salesforce/apex/UpdateBPMDamageNumberController.updateNumber';

export default class UpdateBPMDamageNumberLWC extends NavigationMixin(LightningElement) {
    @track bpmNumber;
    @api recordId;
    @track isShowSpinner = false;
    customLabel = {
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        UpdateBPMNumber,
        BPMNumberRequired
    }
    textChange(event) {
        this.bpmNumber = event.target.value;
    }

    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}

    confirmData() {
        if(!this.bpmNumber) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.customLabel.BPMNumberRequired,
                variant: 'error',
            }));
            return;
        }
		this.isShowSpinner = true;
		confirm({
            orderId : this.recordId,
            damageNumber : this.bpmNumber
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