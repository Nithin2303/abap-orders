CLASS lhc_orderitems DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS valitemslimit FOR VALIDATE ON SAVE
      IMPORTING keys FOR OrderItems~valitemslimit.
    METHODS detOrderAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR OrderItems~detOrderAmount.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR OrderItems RESULT result.
    METHODS detuppercase FOR DETERMINE ON SAVE
      IMPORTING keys FOR orderitems~detuppercase.

ENDCLASS.

CLASS lhc_orderitems IMPLEMENTATION.

  METHOD valitemslimit.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY OrderItems
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(order_items_list).

    DATA(order_id) = VALUE #( order_items_list[ 1 ]-Orderid OPTIONAL ).

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders BY \_items
    ALL FIELDS WITH VALUE #( ( %tky-Orderid = order_id ) )
    RESULT DATA(total_order_items).

    IF lines( total_order_items ) > 5.
      reported-orders = VALUE #(
      ( %tky-Orderid = order_id
      %msg = new_message_with_text(
      severity = if_abap_behv_message=>severity-error
      text = 'Order items should be less than 5' ) )
       ).
    ENDIF.

  ENDMETHOD.

  METHOD detOrderAmount.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
      ENTITY OrderItems
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(order_items_list).

    DATA(order_id) = VALUE #( order_items_list[ 1 ]-Orderid OPTIONAL ).

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders BY \_items
    ALL FIELDS WITH VALUE #( ( %tky-Orderid = order_id ) )
    RESULT DATA(total_order_items).

    DATA(total_amount) = 0.
    LOOP AT total_order_items INTO DATA(items).
      total_amount += ( items-Quantity * items-Unitprice ).
    ENDLOOP.

    MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    UPDATE FIELDS ( Amount ) WITH VALUE #( ( %tky-Orderid = order_id Amount = total_amount ) )
*    MAPPED DATA(mapped_orders)
    FAILED DATA(failed_U)
    REPORTED DATA(reported_U).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY OrderItems
    FIELDS ( Orderid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).
    LOOP AT lt_items INTO DATA(item).
      READ ENTITIES OF zi_r_order
      IN LOCAL MODE
      ENTITY Orders
      FIELDS ( Status )
      WITH VALUE #( ( Orderid = item-Orderid ) )
      RESULT DATA(lt_orders).
      LOOP AT lt_orders INTO DATA(order).
        IF order-Status = 'CMP' OR order-Status = 'CAN'.
          result = VALUE #( BASE result ( %tky-%key-Orderitemid = item-Orderitemid
                                      %is_draft = item-%is_draft
                                      %update = if_abap_behv=>fc-o-disabled
                                      %delete = if_abap_behv=>fc-o-disabled ) ).
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD detuppercase.
    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY orderitems
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(itemsdata).

    LOOP AT itemsdata INTO DATA(items).
      DATA(new_name) = to_upper( items-Productname ).
      IF new_name <> items-Productname.
        MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
        ENTITY OrderItems
        UPDATE FIELDS ( Productname )
        WITH VALUE #( (  %tky-Orderitemid = items-%tky-Orderitemid
                      Productname = new_name ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


CLASS lhc_Orders DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Orders RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Orders RESULT result.
    METHODS cancel FOR MODIFY
      IMPORTING keys FOR ACTION Orders~cancel RESULT result.

    METHODS complete FOR MODIFY
      IMPORTING keys FOR ACTION Orders~complete RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Orders RESULT result.
    METHODS reasoncancel FOR MODIFY
      IMPORTING keys FOR ACTION orders~reasoncancel RESULT result.
    METHODS detuppercse FOR DETERMINE ON SAVE
      IMPORTING keys FOR Orders~detuppercse.
    METHODS fillcomments FOR DETERMINE ON SAVE
      IMPORTING keys FOR Orders~fillcomments.


ENDCLASS.

CLASS lhc_Orders IMPLEMENTATION.

  METHOD get_instance_authorizations.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

    LOOP AT lt_orders INTO DATA(order).
      DATA(update_auth) = if_abap_behv=>auth-allowed.
      IF order-Status = 'CMP'.
        update_auth = if_abap_behv=>auth-unauthorized.
      ENDIF.
      APPEND VALUE #( %tky = order-%tky
                      %update = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                      THEN update_auth
                      ELSE if_abap_behv=>auth-allowed )
                   ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD cancel.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(orderdata).



    DATA(has_error) = abap_false.

    LOOP AT orderdata INTO DATA(order).
      IF order-Comments IS INITIAL.
        reported-orders = VALUE #(
        ( %tky = order-%tky
        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                      text = 'Cannot Cancel Order without Comments' )
         )
         ).
        has_error = abap_true.
      ENDIF.
    ENDLOOP.

    IF has_error = abap_false.
      MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
      ENTITY Orders
      UPDATE FIELDS ( Status )
      WITH VALUE #(
      FOR rec IN orderdata (
      %tky = rec-%tky
       Status = 'CAN'
       )
       )
       FAILED failed
       REPORTED reported.
    ENDIF.

    result = VALUE #(
    FOR rec IN orderdata (
      %tky = rec-%tky
      %param = rec
    )
    ).



  ENDMETHOD.

  METHOD complete.
    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(orderdata).

    MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    UPDATE FIELDS ( Status Comments )
    WITH VALUE #(
    FOR rec IN orderdata (
    %tky = rec-%tky
     Status = 'CMP'
     Comments = 'Order Completed'
     )
*        ( %tky = orderdata[ 1 ]-%tky
*        Status = 'CMP'
*        Comments = 'Order delivered successfully' )
     )
     FAILED failed
     REPORTED reported.

    result = VALUE #(
    FOR rec IN orderdata (
      %tky = rec-%tky
      %param = rec
    )
    ).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_r_order
    IN LOCAL MODE
    ENTITY Orders
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

    LOOP AT lt_orders INTO DATA(order).
*  DATA(create_) = SWITCH abp_behv_op_ctrl( order-Status
*  WHEN 'CMP' OR 'CAN' THEN if_abap_behv=>fc-o-disabled
*  ELSE if_abap_behv=>fc-o-enabled ).

      "another approach

*    IF order-Status = 'CMP' OR order-Status = 'CAN' .
*        result = VALUE #( BASE result ( %tky-%key-Orderid = order-Orderid
*                                        %is_draft = order-%is_draft
*                                        %assoc-_items = if_abap_behv=>fc-o-disabled
*                                        %action-complete = if_abap_behv=>fc-o-disabled
*                                        %action-cancel = if_abap_behv=>fc-o-disabled
*                                        %action-reasoncancel = if_abap_behv=>fc-o-disabled
*                                         ) ).
*     ENDIF.

      "by using switch case

      DATA(update_auth) = if_abap_behv=>auth-allowed.

      CASE order-Status.
        WHEN 'CMP'.
          APPEND VALUE #(
                  %tky = order-%tky
                  %is_draft = order-%is_draft
                  %assoc-_items = if_abap_behv=>fc-o-disabled
                  %action-complete = if_abap_behv=>fc-o-disabled
                  %action-cancel = if_abap_behv=>fc-o-disabled
                  %action-reasoncancel = if_abap_behv=>fc-o-disabled
           ) TO result.
        WHEN 'CAN'.
          IF requested_features-%update = if_abap_behv=>mk-on.
            update_auth = if_abap_behv=>auth-unauthorized.
            APPEND VALUE #( %tky = order-%tky
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text = 'Cannot update Cancelled Order' )
                    ) TO reported-orders.
          ENDIF.
          APPEND VALUE #(
                  %tky = order-%tky
                  %is_draft = order-%is_draft
                  %update = update_auth
                  %assoc-_items = if_abap_behv=>fc-o-disabled
                  %action-complete = if_abap_behv=>fc-o-disabled
                  %action-cancel = if_abap_behv=>fc-o-disabled
                  %action-reasoncancel = if_abap_behv=>fc-o-disabled
           ) TO result.


        WHEN OTHERS.
          APPEND VALUE #(
                  %tky = order-%tky
                  %is_draft = order-%is_draft
                  %assoc-_items = if_abap_behv=>fc-o-enabled
                  %action-complete = if_abap_behv=>fc-o-enabled
                  %action-cancel = if_abap_behv=>fc-o-enabled
                  %action-reasoncancel = if_abap_behv=>fc-o-enabled
           ) TO result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD reasoncancel.

    MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
      ENTITY Orders
      UPDATE FIELDS ( Comments Status )
      WITH VALUE #( FOR key IN keys (
              %key-Orderid = key-Orderid
              Comments = key-%param-reason_for_cancel
              Status = 'CAN'
       ) ).

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(updateddata).

    result = VALUE #( FOR u IN updateddata (
                        %key = u-%key
                        %param = u
     ) ).


  ENDMETHOD.

  METHOD detuppercse.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
      ENTITY Orders
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(orderdata).

    LOOP AT orderdata INTO DATA(order).
      DATA(new_comments) = to_upper( order-Comments ).
      DATA(new_status) = to_upper( order-Status ).
      IF new_comments <> order-Comments OR new_status <> order-Status.
        MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
          ENTITY Orders
          UPDATE FIELDS ( Comments )
          WITH VALUE #(
            ( %tky = order-%tky
              Comments = new_comments
              Status = new_status )
          ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD fillcomments.

    READ ENTITIES OF zi_r_order IN LOCAL MODE
    ENTITY Orders
    FIELDS ( Status Comments )
    WITH CORRESPONDING #( keys )
    RESULT DATA(orderdata).

    LOOP AT orderdata INTO DATA(order).
      IF order-Status IS NOT INITIAL.
        SELECT description FROM zi_status WHERE value = @order-Status INTO @DATA(desc).
        ENDSELECT.
        IF desc IS NOT INITIAL AND order-Comments <> desc.
          order-Comments = desc.
          MODIFY orderdata FROM order.
*          MODIFY ENTITIES OF zi_r_order IN LOCAL MODE
*          ENTITY Orders
*          UPDATE FIELDS ( Comments )
*          WITH VALUE #( ( %tky-%key-Orderid = order-%key-Orderid Comments = desc ) ).

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
