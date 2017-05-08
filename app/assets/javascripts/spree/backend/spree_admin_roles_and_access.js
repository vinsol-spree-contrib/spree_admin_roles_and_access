//= require spree/backend

var SearchableList = (function() {
  var SearchableCheckboxList = function(container) {
    this.$searchBox = $("<input type='text' placeholder='Search..' class='narrow-down-list'></input>");
    this.$container = container;
    container.before(this.$searchBox);
    this.bindEvents();
  };

  SearchableCheckboxList.prototype.bindEvents = function() {
    var that = this;
    this.$searchBox.on('keyup', function() {
      var value = $(this).val();
      var pattern = new RegExp(value, "i");

      that.$container.find('label').each(function() {
        if (!($(this).text().search(pattern) >= 0)) {
          $(this).hide();
        } else {
          $(this).show();
        }
      });
    });
  };

  return SearchableCheckboxList;
})();

$(document).ready(function() {
  $('.searchable-scrollable-list').each(function() { new SearchableList($(this)); });
});
