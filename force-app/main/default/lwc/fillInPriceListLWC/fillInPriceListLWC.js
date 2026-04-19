import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import inputData from '@salesforce/apex/FillInPriceListController.setValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import FillInHeader from '@salesforce/label/c.FillInHeader';
export default class FillInPriceListLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @track isShowSpinner;
    @track pricelist;
    // connectedCallback() {
    //     this.isShowSpinner = true;
	// 	initdata({
            
    //     }).then(result => {
    //         if (result.isSucess) {
    //             this.opList = result.optionList;
    //             console.log('this.opList====>'+JSON.stringify(this.opList));
    //         }else{
    //             this.dispatchEvent(new ShowToastEvent({
    //                 title: 'error',
    //                 message: result.errorMsg,
    //                 variant: 'error',
    //             }));    
    //         }
    //         this.isShowSpinner = false;
    //     }).catch(error => {
    //         this.isShowSpinner = false;
    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'error',
    //             message: this.customLabel.ErrorMSG+';'+JSON.stringify(error),
    //             variant: 'error',
    //         }));
    //     });
    // }
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        FillInHeader,
        CancelLable,
        ConfirmLabel,
        ErrorMSG
    }
    confirmData() {
        if(!this.pricelist) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: 'required',
                variant: 'error',
            }));
            return;
        }
		this.isShowSpinner = true;
		inputData({
            quoteDetailId : this.recordId,
            priceListValue : this.pricelist
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

    productChange(event) {
        this.pricelist = event.target.value;
    }
}