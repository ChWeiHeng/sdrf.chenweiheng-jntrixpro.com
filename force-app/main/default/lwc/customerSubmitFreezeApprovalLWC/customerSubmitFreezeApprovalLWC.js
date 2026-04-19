import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import submitApproval from '@salesforce/apex/SubmitAccountFreezeController.sumbitApproval';
import initFreezeData from '@salesforce/apex/SubmitAccountFreezeController.initFreeze';
import initUnFreezeData from '@salesforce/apex/SubmitAccountFreezeController.initUnFreeze';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import notifacation from '@salesforce/label/c.notifacationBody';
import AccFreezeSumbitApprovalHeader from '@salesforce/label/c.AccFreezeSumbitApprovalHeader';
import AccUnFreezeSumbitApprovalHeader from '@salesforce/label/c.AccUnFreezeSumbitApprovalHeader';
import Comment from '@salesforce/label/c.Comment';

export default class CustomerSubmitFreezeApprovalLWC extends NavigationMixin(LightningElement){
    @api recordId;
    @api label;
    @track isShowSpinner;
    @track isMSG=false;
    @track commentString;
    @track IsFreeze;
    connectedCallback() {
        this.isShowSpinner = true;
        if(this.label==='Freeze'){
            this.IsFreeze=true;
        }else{
            this.IsFreeze=false;
        }
        console.log('this.IsFreeze',this.IsFreeze);
        if(this.IsFreeze){
            initFreezeData({
                customerSaleInfoId : this.recordId
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
        }else{
            initUnFreezeData({
                customerSaleInfoId : this.recordId
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
        AccUnFreezeSumbitApprovalHeader,
        AccFreezeSumbitApprovalHeader,
        Comment
    }
    commentStringChange(event)
    {
    	this.commentString=event.target.value;
    	console.log('this.commentString',this.commentString);
    }
    confirmData() {
		this.isShowSpinner = true;
		submitApproval({
            customerSaleInfoId : this.recordId,
            commentString : this.commentString,
            isFreeze : this.IsFreeze
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