$(document).ready(function() {

  // open external links in a new window
  hostname = window.location.hostname
  $("a[href^=http]")
    .not("a[href*='" + hostname + "']")
    .addClass('link external')
    .attr('target', '_blank');


  /* this could be useful later (maybe)
  $.ajaxSetup({
    cache: false,
    beforeSend: function() {
      $('#content').hide();
      $('#ajaxy-refresh').show();
    },
    complete: function() {
      $('#loading').hide();
      $('#ajaxy-refresh').show();
    },
    success: function() {
      $('#loading').hide();
      $('#ajaxy-refresh').show();
    }
  });
  */

  // this is just a silly proof-of-concept
  var container = $('#ajaxy-refresh');
  var randomnumber = Math.floor(Math.random() * 100);
  container.text('Random Number = ' + randomnumber);
  var refreshId = setInterval(function() {
    var randomnumber = Math.floor(Math.random() * 100);
    container.text('Random Number = ' + randomnumber);
  }, 3000);

});
