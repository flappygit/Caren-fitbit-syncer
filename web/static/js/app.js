import "phoenix_html";
import "jquery";

var CarenFitbitClient = {
  
  init: function() {
    CarenFitbitClient.showPage();
  },

  showPage: function() {
    $('.wrapper').addClass('show');
  }
}

$(window).ready(CarenFitbitClient.init);