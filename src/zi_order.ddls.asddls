@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS VIEW FOR ORDERS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ORDER
  as select from zdemo_order
{
  key orderid       as Orderid,
      customerid    as Customerid,
      orderdate     as Orderdate,
      curr          as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      amount        as Amount,
      status        as Status,
      comments      as Comments,
      createdby     as Createdby,
      createdat     as Createdat,
      lastchangedby as Lastchangedby,
      changedat     as Changedat
}
