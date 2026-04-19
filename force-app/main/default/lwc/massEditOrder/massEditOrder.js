/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 12-18-2025
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-18-2025   Gerry   Initial Version
**/
import { LightningElement,track } from 'lwc';
import { RefreshEvent } from "lightning/refresh";
import ErrorMSG from '@salesforce/label/c.Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import init from '@salesforce/apex/MassEditOrderController.initData';
import saveData from '@salesforce/apex/MassEditOrderController.saveData';
import OrderImport36 from '@salesforce/label/c.OrderLabe21';//error
import OrderImport37 from '@salesforce/label/c.OrderLabe22';//success
import mass1 from '@salesforce/label/c.mass1';//Payment Term is required!
import mass2 from '@salesforce/label/c.mass2';//please select at least one record
import mass3 from '@salesforce/label/c.mass3';//select up to 100 records
import mass4 from '@salesforce/label/c.mass4';//Save Success
import mass5 from '@salesforce/label/c.mass5';//ZARA
import mass6 from '@salesforce/label/c.mass6';//Order Number
import mass7 from '@salesforce/label/c.mass7';//Payment Term
import mass8 from '@salesforce/label/c.mass8';//Auto Create ZAR1


export default class MassEditOrder extends NavigationMixin(LightningElement) {
    customLabel = {
        mass5,
        mass6,
        mass7,
        mass8
    }

    @track dataList = [];
    @track isShowSpinner = false;
    @track Error = ErrorMSG;

    connectedCallback(){
        this.getOrderData();
    }

    getOrderData(){
        this.isShowSpinner = true;
        init().then(result => {
            if (!result['error']) {
                console.log('result=====>',JSON.stringify(result));
            	this.dataList = result.dataList;
            }else{  
                this.showToast(result['error'],`${OrderImport36}`);
                this.back();
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.showToast(this.Error+';'+JSON.stringify(error),`${OrderImport36}`);
        });
    }

    changeAll(event){
        this.dataList.forEach(data => {
            data.isSelect = event.target.checked;
        });
    }

    changeData(event){
        let index = event.currentTarget.dataset.name;
        this.dataList[index].isSelect = event.target.checked;
    }

    changeCreate(event){
        let index = event.currentTarget.dataset.name;
        this.dataList[index].isAutoCreate = event.target.checked;
    }

    changeTerm(event){
        let index = event.currentTarget.dataset.name;
        this.dataList[index].order.Terms_Of_Payment__c = event.target.value;
    }

    changeMethod(event){
        let index = event.currentTarget.dataset.name;
        this.dataList[index].order.Payment_Method__c = event.target.value;
    }

    save(){
        let selectList = [];
        for(let i=0;i<this.dataList.length;i++){
            if(this.dataList[i].isSelect){
                //if(!this.dataList[i].order.Terms_Of_Payment__c || !this.dataList[i].order.Payment_Method__c){
                if(!this.dataList[i].order.Terms_Of_Payment__c){
                    this.showToast(`${mass1}`,`${OrderImport36}`);
                    return;
                }
                selectList.push(this.dataList[i]);
            }
        }
        if(!selectList.length){
            this.showToast(`${mass2}`,`${OrderImport36}`);
            return;
        }
        if(selectList.length > 100){
            this.showToast(`${mass3}`,`${OrderImport36}`);
            return;
        }
        this.isShowSpinner = true;
        console.log('selectList => '+JSON.stringify(selectList));
        saveData({
            selectListStr : JSON.stringify(selectList)
        }).then(result => {
            console.log('result===>'+JSON.stringify(result));
            if (!result['error']) {
                this.showToast(`${mass4}`,`${OrderImport37}`);
                this.dataList = result.dataList;
            }else{
                this.showToast(result['error'],`${OrderImport36}`);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.showToast(this.Error+';'+JSON.stringify(error),`${OrderImport36}`);
        });
    }

    back(){
        console.log('return order');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order__c',
                actionName: 'home'
            }
        });
    }

    showToast(message,type){
        this.dispatchEvent(new ShowToastEvent({
                title: '',
                message: message,
                variant: type,
            }));
    }
}