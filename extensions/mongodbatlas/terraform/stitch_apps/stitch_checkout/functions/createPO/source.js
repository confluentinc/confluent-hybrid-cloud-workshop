exports = function(changeEvent) {

    const order = changeEvent.fullDocument;

    let purchaseOrder = {
      'ORDER_ID': order.ORDER_ID,
      'CUSTOMER': {
        'ID': order.CUSTOMER_ID,
        'FNAME': order.CUSTOMER_FNAME,
        'LNAME': order.CUSTOMER_LNAME,
        'EMAIL': order.CUSTOMER_EMAIL,
        'COUNTRY': order.CUSTOMER_COUNTRY,
        'CITY': order.CITY},
      'PRODUCT':{
        'CODE': order.PRODUCT_ID,
        'QUANTITY': order.PRODUCT_QTY},
      'DATE':{
        'ORDERED': order.ORDER_DATE}
    };
   
    var collection = context.services.get("mongodb-atlas").db("demo").collection("po");
    collection.insertOne(purchaseOrder);

};