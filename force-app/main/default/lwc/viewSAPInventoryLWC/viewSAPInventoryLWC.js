/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 11-11-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   10-28-2025   Gerry   Initial Version
**/
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initdata from '@salesforce/apex/ViewSAPInventoryLWCController.init';
import Product_Name from '@salesforce/label/c.Product_Name';
import Quantity from '@salesforce/label/c.Quantity';
import Sales_Unit from '@salesforce/label/c.Sales_Unit';
import SAPInventoryHeader from '@salesforce/label/c.SAPInventoryHeader';
import Storage_Location from '@salesforce/label/c.Storage_Location';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import defaultUnit from '@salesforce/label/c.defaultUnit';
import ProductCode from '@salesforce/label/c.Product_Code';
import salesQuantity from '@salesforce/label/c.salesQuantity';
import Open_Order_Qty from '@salesforce/label/c.Open_Order_Qty';
import Approving_Qty from '@salesforce/label/c.Approving_Qty';
import deliveryOrderQty from '@salesforce/label/c.DeliveryOrderQty';
import ActualQuantity from '@salesforce/label/c.ActualQuantity';
import QuantityHelpText from '@salesforce/label/c.QuantityHelpText';
import ActualQuantityHelpText from '@salesforce/label/c.ActualQuantityHelpText';
import formFactorPropertyName from '@salesforce/client/formFactor';

export default class ViewSAPInventoryLWC extends NavigationMixin(LightningElement)   {
    @api recordId;
    @track isShowSpinner;
    @track orderItemList=[];
    @track isPC = true;
    close() {
		console.log("cancel:");
        this.dispatchEvent(new CustomEvent('closemodal'));
	}
    customLabel = {
        QuantityHelpText,
        ActualQuantityHelpText,
        ActualQuantity,
        deliveryOrderQty,
        Open_Order_Qty,
        Approving_Qty,
        ProductCode,
        Product_Name,
        Quantity,
        CancelLable,
        ConfirmLabel,
        Sales_Unit,
        SAPInventoryHeader,
        Storage_Location,
        defaultUnit,
        salesQuantity
    }

    connectedCallback() {
        this.isShowSpinner = true;
		initdata({
            orderId : this.recordId
        }).then(result => {
            if (result.isSucess) {
            	this.orderItemList = result.orderItemList;
                if(formFactorPropertyName==='Small') {
                    this.isPC = false;
                }else{
                    this.isPC = true;
                }
                console.log('orderItemList===========>',JSON.stringify(this.orderItemList));
            }else{
                console.log('进入逻辑');
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