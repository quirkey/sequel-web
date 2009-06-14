/**
 * Copyright (c) 2005 - 2009, James Auldridge
 * All rights reserved.
 *
 * Licensed under the BSD, MIT, and GPL (your choice!) Licenses:
 *  http://code.google.com/p/cookies/wiki/License
 *
 * Version 2.0.1
 */
var jaaulde = window.jaaulde || {};
jaaulde.utils = jaaulde.utils || {};
jaaulde.utils.cookies = (function()
{
	var cookies = [];

	var defaultOptions = {
		hoursToLive: null,
		path: '/',
		domain:  null,
		secure: false
	};
	/**
	 * resolveOptions - receive an options object and ensure all options are present and valid, replacing with defaults where necessary
	 *
	 * @access private
	 * @static
	 * @parameter Object options - optional options to start with
	 * @return Object complete and valid options object
	 */
	var resolveOptions = function(options)
	{
		var returnValue;

		if(typeof options !== 'object' || options === null)
		{
			returnValue = defaultOptions;
		}
		else
		{
			returnValue = {
				hoursToLive: (typeof options.hoursToLive === 'number' && options.hoursToLive > 0 ? options.hoursToLive : defaultOptions.hoursToLive),
				path: (typeof options.path === 'string' && options.path != '' ? options.path : defaultOptions.path),
				domain: (typeof options.domain === 'string' && options.domain != '' ? options.domain : defaultOptions.domain),
				secure: (typeof options.secure === 'boolean' && options.secure ? options.secure : defaultOptions.secure)
			};
		}

		return returnValue;
	};
	/**
	 * assembleOptionsString - analyze options and assemble appropriate string for setting a cookie with those options
	 *
	 * @access private
	 * @static
	 * @parameter Object options - optional options to start with
	 * @return String - complete and valid cookie setting options
	 */
	var assembleOptionsString = function(options)
	{
		options = resolveOptions(options);

		return (
			(typeof options.hoursToLive == 'number' ? '; expires='+expiresGMTString(options.hoursToLive) : '') +
			'; path=' + options.path +
			(typeof options.domain === 'string' ? '; domain=' + options.domain : '') +
			(options.secure === true ? '; secure' : '')
		);
	};
	/**
	 * expiresGMTString - add given number of hours to current date/time and convert to GMT string
	 *
	 * @access private
	 * @static
	 * @parameter Integer hoursToLive - number of hours for which cookie should be valid
	 * @return String - GMT time representing current date/time plus number of hours given
	 */
	var expiresGMTString = function(hoursToLive)
	{
		var dateObject = new Date();
		dateObject.setTime(dateObject.getTime() + (hoursToLive*60*60*1000));

		return dateObject.toGMTString();
	};
	/**
	 * splitCookies - retrieve document.cookie string and break it into a hash
	 *
	 * @access private
	 * @static
	 * @return Object - hash of cookies from document.cookie
	 */
	var splitCookies = function()
	{
		cookies = [];
		var pair, name, separated = document.cookie.split(';');
		for(var i = 0; i < separated.length; i++)
		{
			pair = separated[i].split('=');
			name = pair[0].replace(/^\s*/, '').replace(/\s*$/, '');
			value = decodeURIComponent(pair[1]);
			cookies[name] = value;
		}
		return cookies;
	};

	var constructor = function(){};
	
	/**
	 * get - get one, several, or all cookies
	 *
	 * @access public
	 * @paramater Mixed cookieName - String:name of single cookie; Array:list of multiple cookie names; Void (no param):if you want all cookies
	 * @return Mixed - String:if single cookie requested and found; Null:if single cookie requested and not found; Object:hash of multiple or all cookies
	 */
	constructor.prototype.get = function(cookieName)
	{
		var returnValue;
		
		splitCookies();
		
		if(typeof cookieName === 'string')
		{
			returnValue = (typeof cookies[cookieName] !== 'undefined') ? cookies[cookieName] : null;
		}
		else if(typeof cookieName === 'object' && cookieName !== null)
		{
			returnValue = [];
			for(var item in cookieName)
			{
				returnValue[cookieName[item]] = (typeof cookies[cookieName[item]] !== 'undefined') ? cookies[cookieName[item]] : null;
			}
		}
		else
		{
			returnValue = cookies;
		}

		return returnValue;
	};
	/**
	 * set - set or delete a cookie with desired options
	 *
	 * @access public
	 * @paramater String cookieName - name of cookie to set
	 * @paramater Mixed value - Null:if deleting, String:value to assign cookie if setting
     * @paramater Object options - optional list of cookie options to specify
	 * @return void
	 */
	constructor.prototype.set = function(cookieName, value, options) //hoursToLive, path, domain, secure
	{
		if(typeof value === 'undefined' || value === null)
		{
			if(typeof options !== 'object' || options === null)
			{
				options = {};
			}
			value = '';
			options.hoursToLive = -8760;
		}
		
		var optionsString = assembleOptionsString(options);

		document.cookie = cookieName + '=' + encodeURIComponent(value) + optionsString;
	};
	/**
	 * del - delete a cookie (domain and path options must match those with which the cookie was set; this is really an alias for set() with parameters simplified for this use)
	 *
	 * @access public
	 * @paramater String cookieName - name of cookie to delete
     * @paramater Object options - optional list of cookie options to specify
	 * @return void
	 */
	constructor.prototype.del = function(cookieName, options) //path, domain
	{
		if(typeof options !== 'object' || options === null)
		{
			options = {};
		}
		this.set(cookieName, null, options);
	};
	/**
	 * test - test whether the browser is accepting cookies
	 *
	 * @access public
	 * @return Boolean
	 */
	constructor.prototype.test = function()
	{
		var returnValue = false, testName = 'cT', testValue = 'data';

		this.set(testName, testValue);

		if(this.get(testName) == testValue)
		{
			this.del(testName);
			returnValue = true;
		}

		return returnValue;
	};
	/**
	 * setOptions - set default options for calls to cookie methods
	 *
	 * @access public
	 * @param Object options - list of cookie options to specify
	 * @return void
	 */
	constructor.prototype.setOptions = function(options)
	{
		if(typeof options !== 'object')
		{
			options = null;
		}

		defaultOptions = resolveOptions(options);
	}

	return new constructor();
})();


(function()
{
	if(typeof jQuery !== 'undefined' )
	{
		jQuery.cookies = jaaulde.utils.cookies;

		var extensions = {
			/**
			 * $('selector').cookify - set the value of an input field to a cookie by the name or id of the field (radio and checkbox not supported)
			 *
			 * @access public
			 * @param Object options - list of cookie options to specify
			 * @return Object jQuery
			 */
			cookify: function(options)
			{
				return this.each(function()
				{
					var name = '', value = '', nameAttrs = ['name', 'id'], iteration = 0, inputType;

					while(iteration < nameAttrs.length && (typeof name !== 'string' || name === ''))
					{
						name = jQuery(this).attr(nameAttrs[iteration]);
						iteration++;
					}

					if(typeof name === 'string' || name !== '')
					{
						inputType = jQuery(this).attr('type').toLowerCase();
						if(inputType !== 'radio' && inputType !== 'checkbox')
						{
							value = jQuery(this).attr('value');
							if(typeof value !== 'string' || value === '')
							{
								value = null;
							}
							jQuery.cookies.set(name, value, options);
						}
					}

					iteration = 0;
				});
			},
			/**
			 * $('selector').cookieFill - set the value of an input field or the innerHTML of an element from a cookie by the name or id of the field or element
			 *
			 * @access public
			 * @return Object jQuery
			 */
			cookieFill: function()
			{
				return this.each(function()
				{
					var name = '', value, nameAttrs = ['name', 'id'], iteration = 0, nodeType;

					while(iteration < nameAttrs.length && (typeof name !== 'string' || name === ''))
					{
						name = jQuery(this).attr(nameAttrs[iteration]);
						iteration++;
					}

					if(typeof name === 'string' && name !== '')
					{
						value = jQuery.cookies.get(name);
						if(value !== null)
						{
							nodeType = this.nodeName.toLowerCase();
							if(nodeType === 'input' || nodeType === 'textarea')
							{
									jQuery(this).attr('value', value);
							}
							else
							{
								jQuery(this).html(value);
							}
						}
					}

					iteration = 0;
				});
			},
			/**
			 * $('selector').cookieBind - call cookie fill on matching elements, and bind their change events to cookify()
			 *
			 * @access public
			 * @param Object options - list of cookie options to specify
			 * @return Object jQuery
			 */
			cookieBind: function(options)
			{
				return this.each(function(){
					$(this).cookieFill().change(function()
					{
						$(this).cookify(options);
					});
				});
			}
		};

		jQuery.each(extensions, function(i)
		{
			jQuery.fn[i] = this;
		});
	}
})();