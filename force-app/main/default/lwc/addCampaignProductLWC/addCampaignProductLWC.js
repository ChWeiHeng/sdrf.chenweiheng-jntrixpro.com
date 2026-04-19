/**
 * @description       : Add Campaign Product LWC - Following addOrderItemLWC pattern exactly
 * @author            : Agentforce
 * @group             : 
 * @last modified on  : 04-16-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-15-2026   Agentforce    Initial Version - Complete rewrite
**/
import { LightningElement, track, api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import init from '@salesforce/apex/AddCampaignProductController.initData';
import save from '@salesforce/apex/AddCampaignProductController.saveData';
import search from '@salesforce/apex/AddCampaignProductController.searchDataMe';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ErrorMSG from '@salesforce/label/c.Error';
import Action from '@salesforce/label/c.Action';
import Delivery_Date from '@salesforce/label/c.Delivery_Date';
import Material_Code from '@salesforce/label/c.Material_Code';
import ProductNameOrderItem from '@salesforce/label/c.ProductNameOrderItem';
import Search from '@salesforce/label/c.Search';
import Search_Result from '@salesforce/label/c.Search_Result';
import searchText from '@salesforce/label/c.searchText';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import Quantity from '@salesforce/label/c.Quantity';
import Sales_Unit from '@salesforce/label/c.Sales_Unit';
import Material_Descriptio from '@salesforce/label/c.Material_Descriptio';
import productDescription from '@salesforce/label/c.productDescription';
import Observation from '@salesforce/label/c.Observation';

export default class AddCampaignProductLWC extends LightningElement {
    customLabel = {
        Observation,
        Action,
        Delivery_Date,
        Material_Code,
        ProductNameOrderItem,
        Search,
        Search_Result,
        searchText,
        CancelLable,
        ConfirmLabel,
        Quantity,
        Sales_Unit,
        Material_Descriptio,
        productDescription
    }
    
    @api recordId;
    @track lengthData = {};
    @track isPC;
    @track isShowSpinner;
    @track deleteIdList = [];
    @track searchText = '';
    @track productItemList = [];
    @track Error = ErrorMSG;
    @track showSearchPage = false;
    @track campaignProductList = [];
    @track isFreeOrder;
    connectedCallback() {
        this.lengthData.big = 'width: 300px;';
        this.lengthData.small = 'width: 50px;';
        this.lengthData.medium = 'width: 200px;';
        this.lengthData.mediumSmall = 'width: 100px;';
        this.lengthData.mediumBig = 'width: 150px;';
        
        if(formFactorPropertyName === 'Small') {
            this.isPC = false;
        } else {
            this.isPC = true;
        }
        
        this.isShowSpinner = true;
            init({
                campaignRecordId: this.recordId
            }).then(result => {
                if (result.isSucess) {
                    this.campaignProductList = result.campaignProductList;
                    this.productItemList = result.productNameList;
                    console.log('campaignProductList', JSON.stringify(this.campaignProductList));
                    console.log('productItemList', JSON.stringify(this.productItemList));
                    this.isFreeOrder = result.isFreeOrder;
                    // Normalize existing campaignProductList rows so editing prefills correctly
                    if (this.campaignProductList && this.campaignProductList.length > 0) {
                        this.campaignProductList = this.campaignProductList.map((row, idx) => {
                            // Ensure indexNum exists and is consistent
                            row.indexNum = row.indexNum ? row.indexNum : (idx + 1) * 10 + '';

                            // Ensure campaignProductData object exists
                            row.campaignProductData = row.campaignProductData ? row.campaignProductData : {};

                            // Prefill display fields:
                            // If productName not present, try to read from related Product_Name__r
                            if (!row.campaignProductData.productName) {
                                if (row.campaignProductData.Product_Name__r && row.campaignProductData.Product_Name__r.Name) {
                                    row.campaignProductData.productName = row.campaignProductData.Product_Name__r.Name;
                                } else if (row.campaignProductData.Product_Name__c && this.productItemList) {
                                    // Try to find in productItemList by id
                                    const found = this.productItemList.find(p => p.productNameId === row.campaignProductData.Product_Name__c);
                                    if (found) {
                                        row.campaignProductData.productName = found.productName;
                                        row.opList = found.opList || row.opList;
                                        row.campaignProductData.materialCode = found.materialCode || row.campaignProductData.materialCode;
                                    }
                                }
                            }

                            // Ensure opList exists: try to find by Product_Name__c in productItemList
                            if (!row.opList) {
                                if (row.campaignProductData.Product_Name__c && this.productItemList) {
                                    const found = this.productItemList.find(p => p.productNameId === row.campaignProductData.Product_Name__c);
                                    if (found) {
                                        row.opList = found.opList || [];
                                    } else {
                                        row.opList = [];
                                    }
                                } else {
                                    row.opList = [];
                                }
                            }

                            // Prefill Unit__c combobox value:
                            // If Product_Unit_Lookup__c exists (lookup Id), use that so combobox selects correctly.
                            // Otherwise, if Unit__c already contains an Id-like value that matches opList, keep it.
                            if (row.campaignProductData.Product_Unit_Lookup__c) {
                                row.campaignProductData.Unit__c = row.campaignProductData.Product_Unit_Lookup__c;
                            } else if (row.campaignProductData.Unit__c && row.opList && row.opList.length > 0) {
                                // If Unit__c is text but opList contains that label, try to set by matching label to value
                                const match = row.opList.find(o => o.label === row.campaignProductData.Unit__c || o.value === row.campaignProductData.Unit__c);
                                if (match) {
                                    row.campaignProductData.Unit__c = match.value;
                                }
                            }

                            // Ensure Quantity is numeric (so inputs show correctly)
                            if (row.campaignProductData.Quantity__c !== undefined && row.campaignProductData.Quantity__c !== null) {
                                row.campaignProductData.Quantity__c = Number(row.campaignProductData.Quantity__c);
                            } else {
                                row.campaignProductData.Quantity__c = null;
                            }

                            return row;
                        });
                    }
                } else {
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
    
    showSearch() {
        this.showSearchPage = true;
    }
    
    cancelAddPage() {
        this.showSearchPage = false;
    }
    
    textChange(event) {
        this.searchText = event.target.value;
    }
    
    queryData() {
        this.isShowSpinner = true;
        search({
            campaignRecordId: this.recordId,
            searchData: this.searchText
        }).then(result => {
            if (result.isSucess) {
                this.productItemList = [];
                this.productItemList = result.productNameList;
                console.log('productItemList', JSON.stringify(this.productItemList));
            } else {
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
    
    close() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
    
    selectChange(event) {
        let product = this.productItemList[event.currentTarget.dataset.record];
        console.log('product:'+JSON.stringify(product));
        
        let item = {
            Product_Name__c: product.productNameId,
            Quantity__c: null,
            Unit__c: product.salesUnitValue, // Store unit ID initially for combobox
            Delivery_Date__c: null,
            Campaign__c: this.recordId
        };
        
        let campaignProduct = {};
        campaignProduct.indexNum = (this.campaignProductList.length + 1) * 10 + '';
        campaignProduct.campaignProductData = item;
        campaignProduct.campaignProductData.productName = product.productName; // Store for display
        campaignProduct.campaignProductData.materialCode = product.materialCode; // Store for display
        campaignProduct.opList = this.productItemList[event.currentTarget.dataset.record].opList;
        
        this.campaignProductList.push(campaignProduct);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Add Success',
            variant: 'Success',
        }));
    }
    
    deleteDetailData(event) {
        let index = event.currentTarget.dataset.record;
        console.log('Delete index:', index);
        
        if (this.campaignProductList[index].campaignProductData.Id) {
            this.deleteIdList.push(this.campaignProductList[index].campaignProductData.Id);
        }
        this.campaignProductList.splice(index, 1);
        
        for (let i = 0; i < this.campaignProductList.length; i++) {
            this.campaignProductList[i].indexNum = (i + 1) * 10 + '';
        }
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Delete Success',
            variant: 'Success',
        }));
    }
    
    confirmData() {
        let allValid2 = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(!element.reportValidity()) {
                allValid2 = false;
            }
        });
        
        let allValid1 = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()) {
                allValid1 = false;
            }
        });
        
        if(!allValid1 || !allValid2) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: 'Input Required',
                variant: 'error',
            }));
            return;
        }
        
        for (let index = 0; index < this.campaignProductList.length; index++) {
            if(this.isFreeOrder) {
                if (!this.campaignProductList[index].campaignProductData.Delivery_Date__c) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: 'Delivery Date Required',
                        variant: 'error',
                    }));
                    return;
                }
                
                if (!this.campaignProductList[index].campaignProductData.Unit__c) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: 'Unit Required',
                        variant: 'error',
                    }));
                    return;
                }
                if (this.campaignProductList[index].campaignProductData.Quantity__c <= 0) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: 'Quantity can not be negative',
                        variant: 'error',
                    }));
                    return;
                }
            }
            
            
            
        }
        
        this.isShowSpinner = true;
        console.log('campaignProductList', JSON.stringify(this.campaignProductList));
        
        save({
            campaignProductListData: this.campaignProductList,
            deleteList: this.deleteIdList
        }).then(result => {
            if (result.isSucess) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
                    variant: 'Success',
                }));
                this.dispatchEvent(new CustomEvent('refreshview'));
                this.dispatchEvent(new CustomEvent('closemodal'));
            } else {
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
    
    productChange(event) {
        let index = event.currentTarget.dataset.record;
        let filedName = event.target.name;
        console.log("index:", index);
        console.log("filedName:", filedName);
        
        if(filedName === 'Quantity__c') {
            this.campaignProductList[index].campaignProductData[filedName] = event.target.value * 1;
        } else if(filedName === 'Unit__c') {
            // For Unit__c combobox, store the value (which is the unit ID)
            // The combobox value is the Product_Unit__c ID
            this.campaignProductList[index].campaignProductData[filedName] = event.target.value;
        } else {
            this.campaignProductList[index].campaignProductData[filedName] = event.target.value;
        }
        
        console.log('campaignProductList[index]', JSON.stringify(this.campaignProductList[index]));
    }
}