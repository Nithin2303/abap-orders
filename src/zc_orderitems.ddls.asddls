@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for order items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ORDERITEMS
  as projection on ZI_R_ORDERITEMS
{
  key Orderitemid,
      Orderid,
      Productname,
      Unitfield,
      @Semantics.quantity.unitOfMeasure: 'Unitfield'
      Quantity,
      Currfield,
      @Semantics.amount.currencyCode: 'Currfield'
      Unitprice,
      Createdby,
      Createdat,
      Lastchangedby,
      Changedat,
      /* Associations */
      _header : redirected to parent ZC_ORDER
}
