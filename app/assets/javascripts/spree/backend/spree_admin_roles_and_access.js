//= require spree/backend

var SearchableList = (function() {
  var SearchableCheckboxList = function(container) {
    this.$searchBox = $("<div class='input-group input-group-lg col-xs-12'>\
                           <input type='text' placeholder='Search..' class='narrow-down-list form-control'></input>\
                            <div class='input-group-btn search-icon-btn'>\
                              <button class='btn btn-default' type='submit'><i class='glyphicon glyphicon-search'></i></button>\
                            </div>\
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
    this.$container.find('.list-group-item').on('click', function(e) {
      if (this == e.target) {
        $(this).find('input:checkbox').click();
      }
    });

    this.$container.find('input:checkbox').on('change', function() {
      var checkbox     = $(this);
      var lgItem       = checkbox.parents('.list-group-item');
      var lg           = checkbox.parents('.list-group');
      var total        = lg.find('.list-group-item').length;
      var totalChecked = lg.find('input:checked').length;
      lgItem.toggleClass('list-group-item-success');
      checkbox.parents('.panel').find('.count').text(totalChecked + '/' + total);
    });
  };

  SearchableCheckboxList.prototype.bindSearch = function() {
    var that = this;
    this.$searchBox.on('keyup', function(e) {
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
    form.find('input:not(.narrow-down-list)').one('keyup', function() {
      buttons.attr('disabled', false);
    });
    form.find('input').on('change', function() {
      buttons.attr('disabled', false);
    });

    form.on('keypress', function(e) {
      if (e.which === 13){
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    });
  };



  return SearchableCheckboxList;
})();

$(document).ready(function() {
  $('.searchable-scrollable-list').each(function() { new SearchableList($(this)); });
});
