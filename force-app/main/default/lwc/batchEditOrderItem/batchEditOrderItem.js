/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-13-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-13-2026   Gerry   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getOrderItems from '@salesforce/apex/BatchEditOrderItemController.getOrderItems';
import searchProducts from '@salesforce/apex/BatchEditOrderItemController.searchProducts';
import searchProductUnits from '@salesforce/apex/BatchEditOrderItemController.searchProductUnits';
import saveOrderItems from '@salesforce/apex/BatchEditOrderItemController.saveOrderItems';

const columns = [
    { label: '订单项编号', fieldName: 'Name', type: 'text', editable: false },
    { label: '产品', fieldName: 'productName', type: 'text', editable: false },
    { label: '单位', fieldName: 'unitName', type: 'text', editable: false },
    { label: '数量', fieldName: 'Quantity__c', type: 'number', editable: true },
    { label: '价格', fieldName: 'Price__c', type: 'number', editable: true, 
      typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: '总金额', fieldName: 'Total_Price__c', type: 'number', editable: false,
      typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } }
];

export default class BatchEditOrderItem extends LightningElement {
    @api recordId; // Order__c record Id
    @track orderItems = [];
    @track draftValues = [];
    @track isLoading = false;
    
    columns = columns;
    wiredOrderItemsResult;

    @wire(getOrderItems, { orderId: '$recordId' })
    wiredOrderItems(result) {
        this.wiredOrderItemsResult = result;
        if (result.data) {
            this.orderItems = result.data.map(item => ({
                ...item,
                productName: item.Product__r ? item.Product__r.Name : '',
                unitName: item.Sales_Unit__r ? item.Sales_Unit__r.Name : ''
            }));
            this.isLoading = false;
        } else if (result.error) {
            this.showToast('错误', '加载订单项失败: ' + this.getErrorMessage(result.error), 'error');
            this.isLoading = false;
        }
    }

    handleSave(event) {
        this.isLoading = true;
        const draftValues = event.detail.draftValues;
        
        // Create a map of draft values by Id
        const draftMap = new Map();
        draftValues.forEach(draft => {
            draftMap.set(draft.Id, draft);
        });

        // Merge draft values with original records
        const updatedItems = this.orderItems
            .filter(item => draftMap.has(item.Id))
            .map(item => {
                const draft = draftMap.get(item.Id);
                return {
                    Id: item.Id,
                    Quantity__c: draft.Quantity__c !== undefined ? draft.Quantity__c : item.Quantity__c,
                    Price__c: draft.Price__c !== undefined ? draft.Price__c : item.Price__c,
                    Product__c: item.Product__c,
                    Sales_Unit__c: item.Sales_Unit__c
                };
            });

        // Call Apex to save
        saveOrderItems({ orderItems: updatedItems })
            .then(result => {
                this.showToast('成功', result, 'success');
                this.draftValues = [];
                return refreshApex(this.wiredOrderItemsResult);
            })
            .catch(error => {
                this.showToast('错误', '保存失败: ' + this.getErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        this.draftValues = [];
    }

    closeModal() {
        // Dispatch event to close the modal
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        }
        return '未知错误';
    }

    get hasOrderItems() {
        return this.orderItems && this.orderItems.length > 0;
    }
}