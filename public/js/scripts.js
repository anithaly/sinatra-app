$(document).ready(function() {

  $('article .remove').on('submit', function(e) {
    e.preventDefault();
    url = $(this).attr('action');

    $.post(url, function( data ) {
      $('#article' + data.id).remove();
    });
  });

  $(document).on('click', '.publish', function(e) {
    e.preventDefault();
    url = $(this).attr('action');
    ispublic = $(this).attr('ispublic');
    form = this

    $.ajax({
      type: 'POST',
      url: url,
      data: {
        ispublic: ispublic
      },
      success: function(data) {
        $(form).attr('ispublic', (data.ispublic) ? 0 : 1 );
        $(form).find('input').val((data.ispublic) ? 'Hide from public view' : 'Publish')
      },
      dataType: 'json'
    });
  });

});