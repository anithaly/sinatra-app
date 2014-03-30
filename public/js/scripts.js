$(document).ready(function() {

  $("article .remove").on('submit', function(e) {
    e.preventDefault();
    url = $(this).attr('action');
    $.post(url, function( data ) {
      $('#article' + data.id).remove();
    });
  });

  $(".publish").click(function(e) {
    e.preventDefault();
    url = $(this).attr('action');
    ispublic = $(this).attr('ispublic');
    $.ajax({
      type: "POST",
      url: url,
      data: {
        ispublic: ispublic
      },
      success: function() {

      },
      dataType: 'json'
    });
  });

});