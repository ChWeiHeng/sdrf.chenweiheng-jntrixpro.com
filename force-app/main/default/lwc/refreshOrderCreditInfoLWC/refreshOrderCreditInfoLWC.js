/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 08-05-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-05-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import refreshOrderme from '@salesforce/apex/SubmitOrderController.submitDataMe';
import initData from '@salesforce/apex/SubmitOrderController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import RefreshOrderBody from '@salesforce/label/c.RefreshOrderBody';
import RefreshOrderHeader from '@salesforce/label/c.RefreshOrderHeader';

export default class RefreshOrderCreditInfoLWC extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;
    @track dataInfo;
    customLabel = {
        RefreshOrderBody,
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        RefreshOrderHeader
    }
    connectedCallback() {
        this.isShowSpinner = true;
		initData({
            orderId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.dataInfo = result;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));  
                this.close();
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

    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}

    confirmData() {
		this.isShowSpinner = true;
		refreshOrderme({
            orderId : this.recordId,
            infodata : this.dataInfo
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