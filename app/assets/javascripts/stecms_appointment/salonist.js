
$(function() {

    if($('.new-bookings-page').length <= 0) {

        // Visibility API to deal with the different browser-specific syntaxes
        var vis = (function(){
            var stateKey, eventKey, keys = {
                hidden: "visibilitychange",
                webkitHidden: "webkitvisibilitychange",
                mozHidden: "mozvisibilitychange",
                msHidden: "msvisibilitychange"
            };
            for (stateKey in keys) {
                if (stateKey in document) {
                    eventKey = keys[stateKey];
                    break;
                }
            }
            return function(c) {
                if (c) document.addEventListener(eventKey, c);
                return !document[stateKey];
            }
        })();
        // END Visibility API

        function check_new_bookonline() {
            if (get_new_bookonline) {
                $.ajax({
                    method: "POST",
                    dataType: "json",
                    url: "/backend/stecms_appointment/bookings/agenda?action_type=get-new-bookonline",
                    success: function (data) {
                        if (data == true) {
                            $('.new-bookings').addClass('new-bookonline-notice');
                            get_new_bookonline = false;
                        } else {
                            get_new_bookonline = true;
                        }
                    }
                });
            }
        }

        var get_new_bookonline = ($('.new-bookings.new-bookonline-notice').length <= 0),
            checkNewBookonlineInterval = 5 * 60000; // 5 minuti

        // controllo se ci sono nuovi eventi periodicamente
        if (get_new_bookonline) {
            check_new_bookonline();
            setInterval(check_new_bookonline, checkNewBookonlineInterval);
        }

        // controllo se ci sono nuovi eventi ogni volta che la finestra diventa (o torna) visibile
        vis(function(){
            if(vis() && get_new_bookonline) {
                check_new_bookonline();
            }
        });

    }

    // JS per ricerca "live" clienti
    if ( $('#customer_search').length > 0 ) {
        $("#customer_search").autocomplete({
            source: "/backend/stecms_appointment/customers/search",
            minLength: 2,
            search: function() {
                $(this).removeClass("search");
            },
            response: function() {
                $(this).addClass("search");
            },
            select: function(t, e) {
                // carico la pagina di dettaglio del cliente
                window.location.replace('/customers/detail?id='+ e.item.id);
            }
        });
    }

    // JS per ricerca "live" saloni
    if ( $('#salons_search').length > 0 ) {
        $("#salons_search").autocomplete({
            source: "/home/search_salon",
            minLength: 2,
            select: function(t, e) {
                // cambio il salone che sto gestendo
                window.location.replace('/home/salon_switch?id='+ e.item.salon_id);
            }
        });
    }

    // JS per lista appuntamenti di un cliente (aggiunge il pulsantino expand-collapse per il campo note se è troppo lungo)
    if($('#customer_container').length > 0 ) {

        var $customer_container = $('#customer_container');

        $('td.readmore',$customer_container).each(function(){
            if(is_truncated($(this))) {
                $(this).addClass('truncated');
            }
        });

        $('#appointments',$customer_container).removeClass('active').css('visibility','visible');

        $('.truncated',$customer_container).on('click',function(){
            $(this).toggleClass('open');
        });
    }

    // JS per upload file excel clienti
    if($('#upload_excel').length > 0) {

        var $upload_excel = $('#upload_excel');

        $upload_excel.on('submit', function () {
            // disabilito i submit button
            $('input[type=submit]',$upload_excel).prop('disabled',true);
            // mostro il loader
            $('img',$upload_excel).removeClass('hide');
            return true;
        });
    }

    // JS per validazione import clienti (excel)
    if($('#import_excel').length > 0) {

        var $import_excel = $('#import_excel');

        var current_select,
            column_number,
            cell;

        $import_excel.on('submit', function () {
            var name_present = false,
                surname_present = false,
                phone_present = false,
                email_present = false;

            // controllo che siano stati selezionati name, surname e contact_numbers
            $('table select',$import_excel).each(function(){

                current_select = $(this);
                column_number = current_select.parent().index();

                if(current_select.val() == 'name') {
                    name_present = true;
                }
                if(current_select.val() == 'surname') {
                    surname_present = true;
                }
                if(current_select.val() == 'contact_numbers') {
                    phone_present = true;
                }
                if(current_select.val() == 'email') {
                    email_present = true;
                }

            });

            // procedo solo se ho:
            // - almeno uno tra nome e cognome
            // e
            // - almeno uno tra telefono ed email
            if((name_present || surname_present)) {
                // disabilito il submit button
                $('input[type=submit]',$import_excel).prop('disabled',true);
                // mostro il loader
                $('img',$import_excel).removeClass('hide');
                $('span',$import_excel).removeClass('hide');
                return true;
            } else {
                $('.notice',$import_excel).html('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a>Sono obbligatori uno tra <strong>nome</strong>, <strong>cognome</strong> pi&ugrave; uno tra <strong>email</strong> e <strong>numero di telefono</strong>.</div>');
                return false;
            }

        });

    }

    // JS per form di inserimento clienti (manuale)
    if($('#import_manual').length > 0) {
        $(".customer-phone").intlTelInput({defaultCountry: "it", preferredCountries: ["ae", "us", "gb"]});
        $('.customer-datepicker').datepicker({
            dateFormat:'dd-mm-yy',
            changeMonth:true,
            changeYear:true,
            yearRange:'1900:'+new Date().getFullYear()
        });
    }

    // JS per photogallery
    if($('#edit_gallery').length > 0) {

        var $edit_gallery = $('#edit_gallery');

        $edit_gallery.on('submit', function () {
            // disabilito il submit button
            $('input[type=submit]',$edit_gallery).prop('disabled',true);
            // mostro il loader
            $('img.hide',$edit_gallery).removeClass('hide');
            return true;
        });

        // preview image after validation
        $("#salon_image").change(function () {
            $(".notice").empty(); // To remove the previous error message
            var file = this.files[0];
            var imagefile = file.type;
            var match = ["image/jpeg", "image/png", "image/jpg"];
            if (!((imagefile == match[0]) || (imagefile == match[1]) || (imagefile == match[2]))) {
                $('#previewing').attr("src", $('#previewing').data('default'));
                $('#img-format-notice').removeClass('hide');
                $('#edit_gallery .btn').attr('disabled', 'disabled');
                return false;
            } else {
                var reader = new FileReader();
                reader.onload = imageIsLoaded;
                reader.readAsDataURL(this.files[0]);
            }
        });

        function imageIsLoaded(e) {
            $("#salon_image").css("color", "green");
            $('#image_preview').css("display", "block");
            $('#previewing').attr('src', e.target.result);
            $('#previewing').attr('width', '250px');
            $('#previewing').attr('height', '230px');
            $('#img-format-notice').addClass('hide');
            $('#edit_gallery .btn').removeAttr('disabled');
        };

        if($('#photogallery form.delete-photo').length > 0) {

            $('#photogallery form.delete-photo').on('submit', function () {
                //removeLoadingOverlay();
                $('.form-horizontal').closest('.modal').unblock();
                $('body').append("<div class=\'modal hide\' id=\'cancel-modal\'><div class=\'modal-header\'><button aria-hidden=\'true\' class=\'close\' data-dismiss=\'modal\'>&times;<\/button><h3>Elimina Fotografia<\/h3><\/div><div class=\'new-form\'><form accept-charset=\"UTF-8\" action=\"" + $(this).attr('action') + "\" class=\"simple_form form-horizontal edit_service_booking\" data-remote=\"true\" id=\"edit_service_booking\" method=\"post\" novalidate=\"novalidate\"><div style=\"display:none\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /><input name=\"_method\" type=\"hidden\" value=\"patch\" /><\/div><div class=\'modal-body\'><h4>Questa operazione non potr&agrave; essere annullata!<\/h4><\/div><div class=\'modal-footer\'><button class=\"btn\" data-dismiss=\"modal\" aria-hidden=\"true\">Annulla<\/button><a class=\"btn btn-danger\" data-method=\"put\" data-remote=\"true\" href=\"" + $(this).attr('action') + "\" rel=\"nofollow\"><i class=\'icon-trash\'><\/i> Elimina Fotografia<\/a><\/div><\/form><\/div><\/div>");
                $('#cancel-modal').modal({backdrop: 'static', keyboard: false});
                return false;
            });

        }

        // drag & drop per ordinamento foto
        $("#photogallery ul").sortable({
            update: function( event, ui ) {
                $order = '';
                $('#photogallery .list-photo').each(function(){
                    $order = $order+$(this).val()+'|';
                });
                $order = $order.slice(0, -1);
                $('#gallery-order').val($order);
            }
        });
        //$( "#sortable" ).disableSelection();
    }

    if($('#more-bookings-new').length > 0) {
        $('#more-bookings-new').on('click',function(){
            $('#bookings-new tr.hide').slice(0,20).removeClass('hide');
            //console.log($('#bookings-new tr.hide').length);
            if($('#bookings-new tr.hide').length <= 0) {
                $(this).remove();
            }
        });
    }
    if($('#more-bookings-archive').length > 0) {
        $('#more-bookings-archive').on('click',function(){
            $('#bookings-archive tr.hide').slice(0,20).removeClass('hide');
            //console.log($('#bookings-archive tr.hide').length);
            if($('#bookings-archive tr.hide').length <= 0) {
                $(this).remove();
            }
        });
    }

    if($('#remove_old_bookings').length > 0) {
        var date_ = new Date();
        date_.setDate(date_.getDate() - 1);
        $('#data').datepicker({
            //minDate:date_,
            //dateFormat: 'DD, MM d yy',
            dateFormat:"dd/mm/yy",
            maxDate:date_
        });
        $('#remove_old_bookings').on('submit',function(){
            $('img',$(this)).removeClass('hide');
        });
    }

    if($('#send_support_request').length > 0) {
        $('#send_support_request').on('submit',function(){
            $('img',$(this)).removeClass('hide');
        });
    }

    $('body').on('click', '#serviceTab li a', function() {
        if($(this).attr('href') == '#promo') {
            // guardo se ci sono varianti o meno
            if($('#service-pricing-list .well.well-small.item').length > 0) {
                // ho varianti
                $('.promo-variant-selection').show();
            } else {
                // non ho varianti
                $('.promo-variant-selection').hide();
            }
        }
    });

    $('body').on('click','.apply-promo',function(){
        var form = $(this).parents('form');

        var price,
            $this = $(this),
            discount_type = $this.closest('.controls').find('.service_promo_discount_type').val(),
            discount_value = $this.closest('.controls').find('.service_promo_days_price').val(),
            discount_price;

        $this.closest('li').find('.promo-applied input').val('');
        $this.closest('li').find('.promo-applied .control-group').hide();

        console.log('yuhuu')
        // guardo se ci sono varianti o meno
        if($(form).find('#service-pricing-list .well.well-small.item').length > 0) {
            // ho varianti
            $('#service-pricing-list .well.well-small.item').each(function(){

                price = $('.pricing-level-price',$(this)).data('price');
                if(discount_type == 'euro') {
                    discount_price = price - discount_value;
                } else {
                    //discount_price = (100 - discount_value) * (price / 100);
                    discount_price = price - (price * (discount_value / 100));
                }

                if(discount_price < 0) {
                    discount_price = 0;
                }

                if($('.pricing-level-name',$(this)).data('pricing-level') == 'short-hair') {
                    // capelli corti
                    $this.closest('li').find('.promo-applied .promo-applied-short-hair .promo-full-price').val(price);
                    $this.closest('li').find('.promo-applied .promo-applied-short-hair .promo-discount-price').val(discount_price.toFixed(2));
                } else {
                    // capelli lunghi
                    $this.closest('li').find('.promo-applied .promo-applied-long-hair .promo-full-price').val(price);
                    $this.closest('li').find('.promo-applied .promo-applied-long-hair .promo-discount-price').val(discount_price.toFixed(2));
                }
            });

            $(this).closest('li').find('.promo-applied').show();
            $(this).closest('li').find('.promo-applied .promo-applied-short-hair').show();
            $(this).closest('li').find('.promo-applied .promo-applied-long-hair').show();

        } else {
            // nessuna variante
            price = $(form).find('#service_pricing_level_price').val();

            if(discount_type == 'euro') {
                discount_price = price - discount_value;
            } else {
                //discount_price = (100 - discount_value) * (price / 100);
                discount_price = price - (price * (discount_value / 100));
            }

            if(discount_price < 0) {
                discount_price = 0;
            }

            $this.closest('li').find('.promo-applied .promo-applied-both-variant input').val(discount_price.toFixed(2));
            $(this).closest('li').find('.promo-applied').show();
            $(this).closest('li').find('.promo-applied .promo-applied-both-variant').show();
        }

        return false;
    });

    // KEYBOARD SHORTCUTS
    if($('#new-treatment-button').length > 0) {
        shortcut.add("Ctrl+N", function () {
            $('#new-treatment-button').click();
        });
    }

    // JS indirizzi email associati al salone
    if ( $('#email_addresses').length > 0 || $('#email_addresses_invoice').length > 0 ) {
        $('body').on('click', '.add-new-email', function () {
            new_div = $(this).closest('.provider_email_addresses').clone();
            $(this).removeClass('add-new-email').addClass('remove-email').html('Elimina');
            $('.string', new_div).val('');
            $(this).closest('.provider_email_addresses').after(new_div);
            return false;
        });

        $('body').on('click', '.remove-email', function () {
            if ( $(this).closest('form').hasClass('email_invoice') ) {
                if ($('.provider_email_addresses', '#email_addresses_invoice').length > 2) {
                    $(this).closest('.provider_email_addresses').remove();
                } else {
                    bootbox.alert("Deve essere presente almeno un indirizzo di posta elettronica.");
                }
            } else if ( $('.provider_email_addresses','#email_addresses').length > 1 ) {
                $(this).closest('.provider_email_addresses').remove();
            } else {
                $('.string', '.provider_email_addresses').val('');
                $(this).removeClass('remove-email').addClass('add-new-email').html('+ Aggiungi altro');
            }
            return false;
        });
    }

    // useful functions

    function is_valid_email(email) {
        var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
        return re.test(email);
    }

    // funzione per identificare stringhe troncate dal css "ellipsis"
    function is_truncated(element) {
        var $c = element
            .clone()
            .css({display: 'inline', width: 'auto', visibility: 'hidden'})
            .appendTo('body');

        if ($c.width() > element.width()) {
            result = true;
        } else {
            result = false;
        }

        $c.remove();
        return result;
    }

});
