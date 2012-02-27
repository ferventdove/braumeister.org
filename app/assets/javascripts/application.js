//= require flattr
//= require jquery
//= require jquery_ujs
//= require jquery.timeago

$(function() {
  $('abbr.timeago').timeago();
});

var formHandler = function() {
  if($('#search').val() == $('#search')[0].defaultValue) {
    $('#search').addClass('inactive');
  }

  $('#search').live('focus', function() {
    $(this).removeClass('inactive');
    this.value = '';
  });

  $('#search').blur(function() {
    if($(this).val().match(/^\s*$/)) {
      $(this).addClass('inactive');
      this.value = this.defaultValue;
    }
  });

  $('#search-form').submit(function() {
      if(!$('#search').hasClass('inactive')) {
          var searchUrl = '/search/' + $('#search').val();
          if(typeof(repositoryName) !== 'undefined') {
            searchUrl = '/repos/' + repositoryName + searchUrl;
          }
          window.location = searchUrl;
      }

      return false;
  });
}
