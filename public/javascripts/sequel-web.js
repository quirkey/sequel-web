;(function($) {
  
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
        $(this).trigger()
      });
    
  });
  
  SequelWeb = {};
  SequelWeb.Preferences = {
    
    set: function(name, value) {
      this.load();
      this.settings[name] = value;
      this.save();
      return [name, value];
    },
    
    get: function(name) {
      this.load();
      return this.settings[name];
    },
    
    toggle: function(name) {
      this.set(name, !this.get(name));
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
      return JSON.parse($.cookies.get(this.cookieName());
    },
    
    setCookie: function() {
      return $.cookies.set(this.cookieName(), JSON.stringify(this.settings), {hoursToLive: 2000});
    },
    
    cookieName: function() {
      return 'sequel-web';
    }
    
  }
})(jQuery);