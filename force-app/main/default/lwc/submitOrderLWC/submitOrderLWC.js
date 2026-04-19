/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-15-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-15-2026   Gerry   Initial Version
**/
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initdata from '@salesforce/apex/SubmitOrderController.init';
import submitData from '@salesforce/apex/SubmitOrderController.submitDataMe';
import ErrorMSG from '@salesforce/label/c.Error';

import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import Order_Amount from '@salesforce/label/c.Order_Amount';
import Overdue from '@salesforce/label/c.Overdue';
import RemainingCredit from '@salesforce/label/c.RemainingCredit';
import SubmitOrderHeader from '@salesforce/label/c.SubmitOrderHeader';
import CancelLable from '@salesforce/label/c.CancelLable';
import OrderApproingAmount from '@salesforce/label/c.OrderApproingAmount';
import SapCredit from '@salesforce/label/c.SapCredit';
import comments from '@salesforce/label/c.comments';

export default class SubmitOrderLWC extends NavigationMixin(LightningElement)   {
    customLabel = {
        Order_Amount,
        Overdue,
        CancelLable,
        ConfirmLabel,
        RemainingCredit,
        SubmitOrderHeader,
        OrderApproingAmount,
        SapCredit,
        comments
    }
    @track Error = ErrorMSG;
    @api recordId;
    @track info = {};
    @track isShowSpinner;
    @track showText="";
    @track isCDOrder;
    @track orderListData;
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}

    commentsChange(event) {
        this.info.comments = event.target.value;
    }

    connectedCallback() {
        this.isShowSpinner = true;
		initdata({
            orderId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.info = result;
                this.customLabel.Order_Amount = this.customLabel.Order_Amount+' ('+this.info.currencyCode+')';
                this.customLabel.RemainingCredit = this.customLabel.RemainingCredit+' ('+this.info.currencyCode+')';
                this.customLabel.OrderApproingAmount = this.customLabel.OrderApproingAmount+' ('+this.info.currencyCode+')';
                this.customLabel.SapCredit = this.customLabel.SapCredit+' ('+this.info.currencyCode+')';
                this.isCDOrder = result.isCDNoteOrder;
                this.orderListData = result;
                console.log('this.orderListData====>'+JSON.stringify(this.orderListData));
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
                message: this.Error+';'+JSON.stringify(error),
                variant: 'error',
            }));
        });
    }

    confirmData() {
        this.isShowSpinner = true;
		submitData({
            orderId : this.recordId,
            infodata : this.info
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Submit Success',
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
                message: this.Error+';'+JSON.stringify(error),
                variant: 'error',
            }));
        });
    }
}