/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 09-04-2025
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   09-04-2025   Gerry   Initial Version
**/
import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import SHEETJS_ZIP from '@salesforce/resourceUrl/sheetjs';
import downloadTemplateId from '@salesforce/label/c.OrderImportTemplateId';
import saveOrderData from '@salesforce/apex/OrderImportController.saveOrderData';
import InitData from '@salesforce/apex/OrderImportController.InitData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import OrderImport1 from '@salesforce/label/c.OrderImport1';//Customer's PO
import OrderImport2 from '@salesforce/label/c.OrderImport2';//Delivery Plant
import OrderImport3 from '@salesforce/label/c.OrderImport3';//Distribution Channel
import OrderImport4 from '@salesforce/label/c.OrderImport4';//Order Type
import OrderImport5 from '@salesforce/label/c.OrderImport5';//Customer
import OrderImport6 from '@salesforce/label/c.OrderImport6';//Ship To
import OrderImport7 from '@salesforce/label/c.OrderImport7';//Pricing Date
import OrderImport8 from '@salesforce/label/c.OrderImport8';//Currency
import OrderImport9 from '@salesforce/label/c.OrderImport9';//Payment Term
import OrderImport10 from '@salesforce/label/c.OrderImport10';//Customer Shipping Address
import OrderImport11 from '@salesforce/label/c.OrderImport11';//Product Code
import OrderImport12 from '@salesforce/label/c.OrderImport12';//Product Name
import OrderImport13 from '@salesforce/label/c.OrderImport13';//Order Item Quantity
import OrderImport14 from '@salesforce/label/c.OrderImport14';//Unit Price
import OrderImport15 from '@salesforce/label/c.OrderImport15';//Inventory Location
import OrderImport16 from '@salesforce/label/c.OrderImport16';//Crop
import OrderImport17 from '@salesforce/label/c.OrderImport17';//Error Message
import OrderImport18 from '@salesforce/label/c.OrderImport18';//Delivery Date
import OrderImport19 from '@salesforce/label/c.OrderImport19';//Stock Aging Limit
import OrderImport20 from '@salesforce/label/c.OrderLabe5';//SheetJS library failed to load.
import OrderImport21 from '@salesforce/label/c.OrderLabe6';//Please select a file.
import OrderImport22 from '@salesforce/label/c.OrderLabe7';//Invalid template.
import OrderImport23 from '@salesforce/label/c.OrderLabe8';//Insufficient template data!!!!!!
import OrderImport24 from '@salesforce/label/c.OrderLabe9';//The line
import OrderImport25 from '@salesforce/label/c.OrderLabe10';//is missing required fields:
import OrderImport26 from '@salesforce/label/c.OrderLabe11';//Order type must be the same
import OrderImport27 from '@salesforce/label/c.OrderLabe12';//The number of data entries imported cannot exceed 100, please check the uploaded file.
import OrderImport28 from '@salesforce/label/c.OrderLabe13';//The unit price in line
import OrderImport29 from '@salesforce/label/c.OrderLabe14';//is not valid
import OrderImport30 from '@salesforce/label/c.OrderLabe15';//File parse failed.
import OrderImport31 from '@salesforce/label/c.OrderLabe16';//Are you sure to refresh the page?
import OrderImport32 from '@salesforce/label/c.OrderLabe17';//No data to save.
import OrderImport33 from '@salesforce/label/c.OrderLabe18';//Save successful!
import OrderImport34 from '@salesforce/label/c.OrderLabe19';//Save failed, check error file.
import OrderImport35 from '@salesforce/label/c.OrderLabe20';//Save failed.
import OrderImport36 from '@salesforce/label/c.OrderLabe21';//error
import OrderImport37 from '@salesforce/label/c.OrderLabe22';//success
import OrderImport38 from '@salesforce/label/c.OrderLabe23';//Unknown Error
import OrderImport39 from '@salesforce/label/c.OrderLabe24';//Order_Import_Errors.xlsx
import OrderImport40 from '@salesforce/label/c.OrderLabe25';//Error
import DistrubutorExchangeRate from '@salesforce/label/c.DistrubutorExchangeRate';//Distrubutor Exchange Rate


export default class OrderImport extends NavigationMixin(LightningElement) {
    @track orderAndOrderItems = [];
    @track flagOne = true;
    @track isProcessing = false;

    label = {
        OrderImport1,
        OrderImport2,
        OrderImport3,
        OrderImport4,
        OrderImport5,
        OrderImport6,
        OrderImport7,
        OrderImport8,
        OrderImport9,
        OrderImport10,
		OrderImport11,
		OrderImport12,
		OrderImport13,
		OrderImport14,
		OrderImport15,
		OrderImport16,
        OrderImport17,
        OrderImport18,
        OrderImport19,
        DistrubutorExchangeRate
    };

    @track columns = [
        {
            label: OrderImport1,
            fieldName: 'customerPO',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport4,
            fieldName: 'orderType',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport6,
            fieldName: 'shipTo',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport5,
            fieldName: 'customer',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport7,
            fieldName: 'pricingDate',
            type: 'date',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport18,
            fieldName: 'deliveryDate',
            type: 'date',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport8,
            fieldName: 'currencys',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport9,
            fieldName: 'paymentTerm',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: DistrubutorExchangeRate,
            fieldName: 'distrubutorExchangeRate',
            type: 'text',
            sortable: true,
            initialWidth: 300
        },
        /*{
            label: OrderImport10,
            fieldName: 'shipaddress',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },*/
        {
            label: OrderImport11,
            fieldName: 'productCode',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },    
        {
            label: OrderImport12,
            fieldName: 'productName',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport13,
            fieldName: 'orderItemQty',
            type: 'number',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport14,
            fieldName: 'unitPrice',
            type: 'number',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport15,
            fieldName: 'invLocation',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport16,
            fieldName: 'crop',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: OrderImport19,
            fieldName: 'stockLimit',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
    ];
    

    // 计算属性：检查是否有订单数据
    get hasOrderData() {
        return this.orderAndOrderItems && this.orderAndOrderItems.length > 0;
       
    }
    get notHasOrderData() {
        return !this.hasOrderData;
    }
    connectedCallback() {
        loadScript(this, SHEETJS_ZIP + '/xlsx.full.min.js')
            .then(() => console.log('SheetJS loaded'))
            .catch(error => {
                console.error(error);
                this.showToast(`${OrderImport20}`, `${OrderImport36}`);
            });
    }

    downloadTemplate() {
        const url = `/servlet/servlet.FileDownload?file=${downloadTemplateId}`;
        window.open(url);
    }

    handleFilesChange(event) {
        const files = event.target.files;
        if (!files || files.length === 0) {
            this.showToast(`${OrderImport21}`, `${OrderImport36}`);
            return;
        }

        const file = files[0];
        this.isProcessing = true;

        const reader = new FileReader();
        reader.onload = async (e) => {
            try {
                const data = new Uint8Array(e.target.result);
                const workbook = XLSX.read(data, { type: 'array' });

                if (workbook.SheetNames.length === 0) {
                    this.showToast(`${OrderImport22}`, `${OrderImport36}`);
                    return;
                }

                // const sheetJson = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]]);
                // const sheetJson = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]], {
                //     range: 2    // 跳过前3行，从第四行开始读取数据
                // });
                // console.log('这是sheetJson:' + JSON.stringify(sheetJson, null, 2));
                // if (sheetJson.length === 0) {
                //     this.showToast('Empty data.', 'error');
                //     return;
                // }
                const sheetData = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]], {
                    header: 1, // 读取为二维数组
                });
                console.log(JSON.stringify(sheetData));

                if (sheetData.length < 4) {
                    this.showToast(`${OrderImport23}`, `${OrderImport36}`);
                    return;
                }

                // 第1行：字段名（真实的表头）
                const headerRow = sheetData[0];
                // 第4行及以后：有效数据（跳过2、3行说明）
                const dataRows = sheetData.slice(3);

                console.log(JSON.stringify(sheetData[0]));
                console.log(JSON.stringify(dataRows));

                const fieldMap = {
                    "*Customer's PO": 'customerPO',
                    '*Order Type': 'orderType',
                    '*Customer': 'customer',
                    '*Ship To': 'shipTo',
                    '*Pricing Date': 'pricingDate',
                    '*Currency': 'currencys',
                    '*Payment Term': 'paymentTerm',
                    'Distrubutor Exchange Rate': 'distrubutorExchangeRate',//ZARE新增税率
                    //'*Customer Shipping Address': 'shipaddress',
                    '*Product Code': 'productCode',
                    '*Product Name': 'ypfproductName',
                    '*Order Item Quantity': 'orderItemQty',
                    '*Delivery Date': 'deliveryDate',
                    '*Unit Price': 'unitPrice',
                    'Inventory Location': 'invLocation',
                    'Crop': 'crop',
                    'Stock Aging Limit': 'stockLimit',
                };
                    // 标记必填字段
                const requiredFields = [
                    'customerPO',
                    'orderType',
                    'customer',
                    'shipTo',
                    'pricingDate',
                    'currencys',
                    'paymentTerm',
                    //'shipaddress',
                    'productCode',
                    'ypfproductName',
                    'orderItemQty',
                    'deliveryDate',
                    'unitPrice'
                ];
                // const mappedData = sheetJson.map((row, index) => {
                //     const mapped = {};
                //     for (const key in row) {
                //         mapped[fieldMap[key] || key] = row[key];
                //     }
                //     mapped._rowIndex = index + 4; // 如果你需要提示第几行错误
                //     return mapped;
                // });

                // const rawData = mappedData.filter(mapped => {
                //     const missingFields = requiredFields.filter(field => !mapped[field]);
                //     if (missingFields.length > 0) {
                //         this.showToast(`Row ${mapped._rowIndex} missing required fields: ${missingFields.join(', ')}`, 'error');
                //         return false;
                //     }
                //     return true;
                // });

                let orderType;
                let errorMessage;
                // 将每行数组转为对象
                const rawData = dataRows.map((row, index) => {
                    const actualRowNumber = index + 3;

                    // 跳过完全空行（所有字段都为 null/undefined/空字符串）
                    const isEmpty = row.every(cell => cell === null || cell === undefined || cell === '');
                    if (isEmpty) {
                        console.warn(`第 ${actualRowNumber} 行是空行，已跳过`);
                        return null;
                    }

                    // 跳过“待客户提供文本”这一类未填写的占位行
                    const isPlaceholder = row.every(cell => typeof cell === 'string' && cell.includes('待客户提供文本'));
                    if (isPlaceholder) {
                        console.warn(`第 ${actualRowNumber} 行是说明/占位行，已跳过`);
                        return null;
                    }
                    const mapped = {};
                    for (let i = 0; i < headerRow.length; i++) {
                        const key = headerRow[i];
                        const fieldName = fieldMap[key];
                        if (fieldName) {
                            mapped[fieldName] = row[i];
                        }
                    }

                    console.log(`第 ${actualRowNumber} 行映射结果:`, JSON.stringify(mapped, null, 2));

                    const missingFields = [];
                    for (const key in fieldMap) {
                        if (requiredFields.indexOf(fieldMap[key]) !== -1 && !mapped[fieldMap[key]]) {
                            missingFields.push(key.replace('*',''));
                        }
                     }
                    if (missingFields.length > 0) {
                        this.showToast(`${OrderImport24} ${index + 4} ${OrderImport25} ${missingFields.join(', ')}`, `${OrderImport36}`);
                        return null;    
                    }

                    if(mapped.orderType && orderType && orderType !== mapped.orderType){
                        errorMessage = `${OrderImport26}`;
                    }else{
                        orderType = mapped.orderType;
                    }
                    return mapped;  
                }).filter(item => item !== null);
                console.log('这是rawData'+rawData);

                if(errorMessage){
                    this.showToast(errorMessage, `${OrderImport36}`);
                    return;
                }

                if (rawData.length > 100) {
                    this.showToast(`${OrderImport27}`, `${OrderImport36}`);
                    this.isProcessing = false;
                    return;
                }

                const result = await InitData({ Data: JSON.stringify(rawData) });

                //illion 20250828 取消校验
                /*for(let index = 0; index < result.length; index++){
                    if(!result[index].unitPriceCheck){
                        this.showToast(`${OrderImport28} ${index + 4} ${OrderImport29}`, `${OrderImport36}`);
                        return;    
                    }
                }*/

                this.orderAndOrderItems = result.map((item, index) => ({
                    index: index + 1,
                    rowKey: `row-${index}`,
                    customerPO: item.customerPO,
                    orderType: item.orderType,
                    customer: item.customer,
                    shipTo: item.shipTo,
                    pricingDate: item.pricingDate,
                    currencys: item.currencys,
                    paymentTerm: item.paymentTerm,
                    distrubutorExchangeRate: item.distrubutorExchangeRate,
                    //shipaddress: item.shipaddress,
                    productCode: item.productCode,
                    orderItemQty: item.orderItemQty,
                    deliveryDate: item.deliveryDate,
                    unitPrice: item.unitPrice,
                    invLocation: item.invLocation,
                    productNameId: item.productNameId,
                    salesUnit: item.salesUnit,
                    crop: item.crop,
                    customerId: item.customerId,
                    shipToId: item.shipToId,
                    productName: item.productName,
                    deliveryPlant: item.deliveryPlant,
                    distributionChannel: item.distributionChannel, 
                    productUnit:item.productUnit,
                    stockLimit:item.stockLimit, 
                    salesUnitCoefficient:item.salesUnitCoefficient,      
                }));

                this.flagOne = false;

            } catch (err) {
                console.error(err);
                this.showToast(`${OrderImport30}`, `${OrderImport36}`);
            } finally {
                this.isProcessing = false;
            }
        };

        reader.readAsArrayBuffer(file);
    }

    handleCancel() {
        if (confirm(`${OrderImport31}`)) {
            location.reload();
        }
    }

    handleSave() {
        this.isProcessing = true;

        // 保存所有数据
        const allOrders = [...this.orderAndOrderItems];
        
        if (allOrders.length === 0) {
            this.showToast(`${OrderImport32}`, `${OrderImport36}`);
            this.isProcessing = false;
            return;
        }

        saveOrderData({ OrderData: JSON.stringify(allOrders) })
            .then(result => {
                if (result.success === '1') {
                    this.showToast(`${OrderImport33}`, `${OrderImport37}`);
                    this.clearData();
                    location.reload();
                } else if (result.success === '2') {
                    this.showToast(`${OrderImport34}`, `${OrderImport36}`);
                    this.generateErrorExcel(result.errors);
                } else if(result.success === '3'){
                    this.showToast(result.errorMsg, `${OrderImport36}`);
                }
                this.isProcessing = false;
                
            })
            .catch(err => {
                console.error(err);
                this.showToast(`${OrderImport35}`, `${OrderImport36}`);
                this.isProcessing = false;
            });
    }

    generateErrorExcel(errors) {
        const header = [
            OrderImport1,  // "*Customer's PO"
            OrderImport4,  // "*Order Type"
            OrderImport6,  // "*Ship To"
            OrderImport5,  // "*Customer"
            OrderImport7,  // "*Pricing Date"
            OrderImport18, // "*Delivery Date" 
            OrderImport8,  // "*Currency"
            OrderImport9,  // "*Payment Term"
            DistrubutorExchangeRate,  // "Distrubutor Exchange Rate"
            //OrderImport10, // "*Customer Shipping Address"
            OrderImport11, // "*Product Code"
            OrderImport12, // "*Product Name"
            OrderImport13, // "*Order Item Quantity"
            OrderImport14, // "Unit Price"
            OrderImport15, // "Inventory Location"
            OrderImport16,// "Crop"
            OrderImport19,  // "Stock Aging Limit"
            OrderImport17,  // "Error Message"
                
        ];
        const rows = errors.map(e => [
            e.customerPO || '',
            e.orderType || '',
            e.customer || '',
            e.shipTo || '',
            e.pricingDate || '',
            e.deliveryDate || '', 
            e.currencys || '',
            e.paymentTerm || '',
            e.distrubutorExchangeRate || '',
            //e.shipaddress || '',
            e.productCode || '',
            e.productName || '',
            e.orderItemQty || '',
            e.unitPrice || '',
            e.invLocation || '',
            e.crop || '',
            e.stockLimit || '',
            e.message || `${OrderImport38}`
        ]);
        const worksheet = XLSX.utils.aoa_to_sheet([header, ...rows]);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, `${OrderImport40}`);
        XLSX.writeFile(workbook, `${OrderImport39}`);
    }

    showToast(message, variant = 'info') {
        this.dispatchEvent(new ShowToastEvent({
            title: variant === 'error' ? 'Error' : '提示',
            message,
            variant,
            mode: 'dismissable',
            duration: 10000
        }));
    }
    clearData() {
    this.orderAndOrderItems = [];
    this.flagOne = true;  
}

convertRowToObject(rowArray, headerArray) {
    let obj = {};
    for (let i = 0; i < headerArray.length; i++) {
        obj[headerArray[i]] = rowArray[i];
    }
    return obj;
}
}