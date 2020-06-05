exports = function(changeEvent) {

    const order = changeEvent.fullDocument;

    let purchaseOrder = {
      'ORDER_ID': order.ORDER_NUMBER,
      'CUSTOMER': {
        'ID': order.CUSTOMERNUMBER,
        'NAME': order.CUSTOMERNAME,
        'CITY': order.CITY},
      'PRODUCT':{
        'CODE': order.PRODUCTCODE,
        'QUANTITY': order.QUANTITYORDERED},
      'DATE':{
        'SHIPPED': order.SHIPPEDDATE,
        'REQUIRED': order.REQUIREDDATE,
        'ORDERED': order.ORDERDATE}
    };
   
    var collection = context.services.get("mongodb-atlas").db("demo").collection("po");
    collection.insertOne(purchaseOrder);

};