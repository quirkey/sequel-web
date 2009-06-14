;(function($) {

  $(function() {
    $('table.qtable').each(function() {
      new QTable(this);
    });
  });
  
  function QTable(table) {
    console.log('qtable init', table);
    this.$table = $(table);
    this.column_names = this.$table
      .find('thead th')
      .map(function() { return $(this).text(); });
    console.log('qtable', this);
    this.options = this.getCookie();
    this.hideColumns();
  }
  
  $.extend(QTable.prototype, {
    
    hideColumns: function() {
      var qtable = this;
      $.each(this.options.hidden, function(column_name, hidden) {
        if (hidden) { qtable.hideColumn(column_name); }
      });
    },
    
    showColumn: function(column_name) {
      var index = this.columnIndex(column_name);
      if (index == -1) return;
    },
    
    hideColumn: function(column_name) {
      var index = this.columnIndex(column_name);
      if (index == -1) return;
      this.$table
            .find('th:eq('+ index + ')').hide();
      this.$table
            .find('tr')
            .each(function() {
              $(this).find('td:eq('+ index + ')').hide();
            });
      this.options.hidden[column_name] = true;
      this.setCookie();
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
      return 'qtable';
    },
    
  });

  window.QTable = QTable;

})(jQuery);