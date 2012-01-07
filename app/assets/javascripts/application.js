//= require jquery
//= require jquery_ujs

var formHandler = function() {
  if($('input#search').val() == $('input#search')[0].defaultValue) {
    $('input#search').addClass('inactive');
  }

  $('input#search').live('focus', function() {
    $(this).removeClass('inactive');
    this.value = '';
  });

  $('input#search').blur(function() {
    if($(this).val().match(/^\s*$/)) {
      $(this).addClass('inactive');
      this.value = this.defaultValue;
    }
  });
}
