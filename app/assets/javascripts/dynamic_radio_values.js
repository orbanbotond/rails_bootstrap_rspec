jQuery.fn.filterOn = function(radio, values) {
    return this.each(function() {
        var select = this;
        var options = [];
        $(select).find('option').each(function() {
            options.push({value: $(this).val(), text: $(this).text()});
        });
        $(select).data('options', options);
        $(radio).click(function() {
            var options = $(select).empty().data('options');
            var haystack = values[$(this).attr('id')];
            $.each(options, function(i) {
                var option = options[i];
                if($.inArray(option.value, haystack) !== -1) {
                    $(select).append(
                    $('<option>').text(option.text).val(option.value)
                    );
                }
            });
        });            
    });
};