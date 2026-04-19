/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-08-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-26-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import recallCon from '@salesforce/apex/RecallContractFROMBPM.recallContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import RecallContractBody from '@salesforce/label/c.RecallContractBody';
import RecallContractHeader from '@salesforce/label/c.RecallContractHeader';

export default class RecallContractLWC extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;

    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        RecallContractBody,
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        RecallContractHeader
    }
    confirmData() {
		this.isShowSpinner = true;
        var conId = [];
        conId.push(this.recordId);
		recallCon({
            contractIdList : conId
        }).then(result => {
            console.log('result====>',JSON.stringify(result));
            if (result.isSuccess) {
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
                    message: result.message,
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