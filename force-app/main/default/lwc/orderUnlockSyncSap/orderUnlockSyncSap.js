import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';

import syncSap from '@salesforce/apex/orderUnlockSyncSapController.syncSap';
import updateDataMe from '@salesforce/apex/orderUnlockSyncSapController.updateData';
import initData from '@salesforce/apex/orderUnlockSyncSapController.init';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import ContractCreate from '@salesforce/label/c.ContractCreate';
import OrderCreateBody from '@salesforce/label/c.OrderCreateBody';
import CreateContractError from '@salesforce/label/c.CreateContractError';
import OrderUnlockSyncSapHeader from '@salesforce/label/c.OrderUnlockSyncSapHeader';

export default class OrderUnlockSyncSap extends NavigationMixin(LightningElement){
    @api recordId;
    @track isShowSpinner;
    @track contractType;
    @track opList=[];
    @track isMSG=false;
    @track downPayment;
    @track isClose;
    connectedCallback() {
        this.isShowSpinner = true;
		initData({
            orderId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.isMSG=true;
                this.isClose = result.isLock;
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
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        CancelLable,
        ConfirmLabel,
        ErrorMSG,
        ContractCreate,
        OrderCreateBody,
        CreateContractError,
        OrderUnlockSyncSapHeader
    }
    confirmData() {
		this.isShowSpinner = true;
        if (!this.isClose) {//解锁
            syncSap({
                orderId : this.recordId,
                flag : false,
                change : false
            }).then(result => {
                console.log('1');
                if (result.isSucess) {
                    syncSap({
                        orderId : this.recordId,
                        flag : false,
                        change : true
                    }).then(result => {
                        console.log('2');
                        if (result.isSucess) {
                            updateDataMe({
                                orderId : this.recordId,
                                locked:this.isClose
                            }).then(result => {
                                console.log('3');
                                if (result.isSucess) {
                                    this.dispatchEvent(new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Success',
                                        variant: 'Success',
                                    }));
                                    this.isShowSpinner = false;
                                    this.dispatchEvent(new CustomEvent('refreshview'));
                                    this.dispatchEvent(new CustomEvent('closemodal'));
                                }else{
                                
                                    this.isShowSpinner = false;
                                    this.dispatchEvent(new ShowToastEvent({
                                        title: 'error',
                                        message: result.errorMsg,
                                        variant: 'error',
                                    }));    
                                }
                                
                            }).catch(error => {
                                this.isShowSpinner = false;
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'error',
                                    message: JSON.stringify(error),
                                    variant: 'error',
                                }));
                            });
                        }else{
                            this.isShowSpinner = false;
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'error',
                                message: result.errorMsg,
                                variant: 'error',
                            }));    
                        }
                    }).catch(error => {
                        this.isShowSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: JSON.stringify(error),
                            variant: 'error',
                        }));
                    });
                }else{
                    this.isShowSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));    
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: JSON.stringify(error),
                    variant: 'error',
                }));
            });
        }else{
            syncSap({
                orderId : this.recordId,
                flag : true,
                change : false
            }).then(result => {
                console.log('1');
                if (result.isSucess) {
                    
                    updateDataMe({
                        orderId : this.recordId,
                        locked:this.isClose
                    }).then(result => {
                        console.log('3');
                        if (result.isSucess) {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Success',
                                message: 'Success',
                                variant: 'Success',
                            }));
                            this.isShowSpinner = false;
                            this.dispatchEvent(new CustomEvent('refreshview'));
                            this.dispatchEvent(new CustomEvent('closemodal'));
                        }else{
                        
                            this.isShowSpinner = false;
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'error',
                                message: result.errorMsg,
                                variant: 'error',
                            }));    
                        }
                        
                    }).catch(error => {
                        this.isShowSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: JSON.stringify(error),
                            variant: 'error',
                        }));
                    });
                                
                }else{
                    this.isShowSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));    
                }
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
}