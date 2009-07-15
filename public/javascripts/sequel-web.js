;(function($) {
  
  SequelWeb = {};
  SequelWeb.Preferences = {
    bindings: {},
    
    applySettings: function() {
      var preferences = this;
      preferences.load();
      $.each(this.settings, function(name, value) {
        preferences.trigger(name);
      });
    },
    
    bind: function(name, callback) {
      if (typeof this.bindings[name] == 'undefined') {
        this.bindings[name] = [];
      }
      this.bindings[name].push(function(value) {
        setTimeout(function() {
          callback(value);
        }, 1);
      });
      return this;
    },
    
    trigger: function(name) {
      var preferences = this;
      if (typeof this.bindings[name] != 'undefined') {
        $.each(this.bindings[name], function(i, callback) {
          callback(preferences.get(name));
        });
      }
      return this;
    },
    
    set: function(name, value) {
      this.load();
      this.settings[name] = value;
      this.save();
      return this;
    },
    
    get: function(name) {
      this.load();
      return this.settings[name];
    },
    
    toggle: function(name) {
      this.set(name, !this.get(name));
      return this;
    },
    
    load: function() {
      if (typeof this.settings == "undefined") {
        this.settings = this.getCookie() || {};
      }
    },
    
    save: function() {
      return this.setCookie();
    },
    
    getCookie: function() {
      return JSON.parse($.cookies.get(this.cookieName()));
    },
    
    setCookie: function() {
      return $.cookies.set(this.cookieName(), JSON.stringify(this.settings), {hoursToLive: 2000});
    },
    
    cookieName: function() {
      return 'sequel-web';
    } 
  };
  
    
  SequelWeb.Preferences
    .bind('show-sql-log', function(value) {
      console.log('triggerering show-sql-log', value);
      var $sql_log = $('#sql_log');
      if (value) {
        $sql_log.show('fast');
      } else {
        $sql_log.hide('fast');
      }
    });
  
  $(function() {
    
    $('.preferences')
      .bind('show', function() {
        $(this)
          .find('ul')
          .slideDown('fast');
        $(this).addClass('active');
      })
      .bind('hide', function() {
        $(this)
          .find('ul')
          .slideUp('fast');
        $(this).removeClass('active');
      })
      .bind('toggle', function() {
        if ($(this).is('.active')) {
          $(this).trigger('hide');
        } else {
          $(this).trigger('show');
        }
      })
      .find('ul').hide().end()
      .find('span a')
        .bind('click', function(e) {
          e.preventDefault();
          $(this).parents('.preferences').trigger('toggle');
        });
   
    // bind smart triggers
    $('a[href^="#:"]')
      .bind('click', function(e) {
        e.preventDefault();
        var setting = $(this).attr('href').replace(/^\#\:/, '').split('/');
        var event_name = setting[0];
        var action     = setting[1];
        console.log('triggering', event_name, this);
        SequelWeb.Preferences.toggle(event_name).trigger(event_name);
        $(this).parents('.preferences').trigger('hide');
      });
    
    SequelWeb.Preferences.applySettings();
  });
  
})(jQuery);