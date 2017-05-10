//= require spree/backend

var SearchableList = (function() {
  var SearchableCheckboxList = function(container) {
    this.$searchBox = $("<div class='input-group input-group-lg col-xs-12'>\
                           <input type='text' placeholder='Search..' class='narrow-down-list form-control'></input>\
                         </div>");
    this.$container = container;
    container.before(this.$searchBox);
    this.bindEvents();
  };

  SearchableCheckboxList.prototype.bindEvents = function() {
    this.bindSearch();
    this.bindCheck();
    this.formChange();
  };

  SearchableCheckboxList.prototype.bindCheck = function() {
    this.$container.find('input:checkbox').on('change', function() {
      var checkbox = $(this);
      checkbox.parents('.list-group-item').toggleClass('list-group-item-success');
      var total = checkbox.parents('.list-group').find('.list-group-item').length;
      var totalChecked = checkbox.parents('.list-group').find('input:checked').length;
      checkbox.parents('.panel').find('.count').text(totalChecked + '/' + total);
    });
  };

  SearchableCheckboxList.prototype.bindSearch = function() {
    var that = this;
    this.$searchBox.on('keyup', function() {
      var value = $(this).find('input').val();
      var pattern = new RegExp(value, "i");

      that.$container.find('.list-group-item').each(function() {
        if (!($(this).text().search(pattern) >= 0)) {
          $(this).hide();
        } else {
          $(this).show();
        }
      });
    });
  };

  SearchableCheckboxList.prototype.formChange = function() {
    var that = this;
    var form = this.$container.closest('form');
    var buttons = form.find('button');
    buttons.attr('disabled', true);
    form.find('input').one('change', function() {
      buttons.attr('disabled', false);
    });
  };

  return SearchableCheckboxList;
})();

$(document).ready(function() {
  $('.searchable-scrollable-list').each(function() { new SearchableList($(this)); });
});
