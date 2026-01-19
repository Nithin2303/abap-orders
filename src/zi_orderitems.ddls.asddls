@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS VIEW FOR ORDER(ITEMS)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ORDERITEMS
  as select from zdemo_orderitems
{
  key orderitemid   as Orderitemid,
      orderid       as Orderid,
      productname   as Productname,
      unitfield     as Unitfield,
      @Semantics.quantity.unitOfMeasure: 'Unitfield'
      quantity      as Quantity,
      currfield     as Currfield,
      @Semantics.amount.currencyCode: 'Currfield'
      unitprice     as Unitprice,
      createdby     as Createdby,
      createdat     as Createdat,
      lastchangedby as Lastchangedby,
      changedat     as Changedat
}
