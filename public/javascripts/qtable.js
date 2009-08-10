;(function($) {

  $(function() {
    $('table.qtable').each(function() {
      new QTable(this);
    });
  });
  
  function QTable(table) {
    // console.log('qtable init', table);
    this.$table = $(table);
    this.column_names = this.$table
      .find('thead th')
      .map(function() { return $(this).text(); });
    // console.log('qtable', this);
    this.options = this.getCookie();
    this.buildMenu();
    this.hideColumns();
  }
  
  $.extend(QTable.prototype, {
    
    buildMenu: function() {
      var qtable = this;
      qtable.menu = $('<div class="qtable-menu"></div>').hide();
      qtable.menu.append('<h4>Show Columns</h4>');
      var columns = $('<ul></ul>');
      $.each(this.column_names, function(i, name) {
        if ($.trim(name) == '') return;
        var checked = (qtable.options.hidden[name] ? '' : 'checked');
        var li = $('<li><input type="checkbox" checked="' + checked + '" name="' + name +'"/>' + name + '</li>');
        columns.append(li);
      });
      qtable.menu.append(columns);
      this.$table.find('th:first')
        .addClass('ui-state-default')
        .prepend('<span class="qtable-menu-toggle ui-icon ui-icon-gear"></span>')
        .prepend(qtable.menu);
      qtable.menu.find('li').click(function(e) {
        if (!$(e.originalTarget).is(':checkbox')) {
          $(this).find(':checkbox').attr('checked', function() {
            return ($(this).is(':checked')) ? '' : 'checked';
          });
        }
        qtable.toggleColumn($(this).find(':checkbox').attr('name'));
      });
      this.$table.find('.qtable-menu-toggle').click(function(e) {
        $(this).parent().toggleClass('ui-state-default').toggleClass('ui-state-hover');
        var offset = qtable.menu.parent().offset();
        var top = qtable.menu.parent().outerHeight() + offset.top;
        var left = offset.left;
        qtable.menu
                .css({'top': top + 'px', 'left': left + 'px'})
                .toggle();
      });
    },
    
    hideColumns: function() {
      var qtable = this;
      $.each(this.options.hidden, function(column_name, hidden) {
        if (hidden) { qtable.hideColumn(column_name); }
      });
    },
    
    toggleColumn: function(column_name) {
      var index = this.columnIndex(column_name);
      if (index == -1) return;
      if (this.options.hidden[column_name]) {
        this.showColumn(column_name);
      } else {
        this.hideColumn(column_name);
      }
    },
    
    showColumn: function(column_name) {
      var index = this.columnIndex(column_name);
      if (index == -1) return;
      this.selectColumn(index).show();
      delete this.options.hidden[column_name];
      this.setCookie();
    },
    
    hideColumn: function(column_name) {
      var index = this.columnIndex(column_name);
      if (index == -1) return;
      this.selectColumn(index).hide();
      this.options.hidden[column_name] = true;
      this.setCookie();
    },
    
    selectColumn: function(index) {
      index++;
      return this.$table
                .find('tr td:nth-child('+ index + '), tr th:nth-child(' + index + ')');
    },
    
    columnIndex: function(column_name) {
      return $.inArray(column_name, this.column_names);
    },
    
    getCookie: function() {
      return JSON.parse($.cookies.get(this.cookieName()) || '{"hidden": {}}');
    },
    
    setCookie: function() {
      return $.cookies.set(this.cookieName(), JSON.stringify(this.options), {hoursToLive: 1000});
    },
    
    cookieName: function() {
      return 'qtable-' + window.location.pathname;
    }
    
  });

  window.QTable = QTable;

})(jQuery);