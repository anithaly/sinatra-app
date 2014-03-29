$(document).ready(function() {

  $("article .remove").on('submit', function(e) {
    e.preventDefault();
    url = $(this).attr('action');
    $.post(url, function( data ) {
      $('#article' + data.id).remove();
    });
  });

  $(".public").click(function(e) {
    e.preventDefault();

    url = this.attr('action');

    $.ajax({
      type: "POST",
      url: url,
      data: {},
      success: function() {},
      dataType: 'json'
    });
  });

});