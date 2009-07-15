module Sequel
  module Web
    module ViewHelpers

      def tag_options(options, escape = true)
        option_string = options.collect {|k,v| %{#{k}="#{v}"}}.join(' ')
        option_string = " " + option_string unless option_string.blank?
      end

      def content_tag(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        "<#{name}#{tag_options}>#{content}</#{name}>"
      end

      def link_to(text, link = nil, options = {})         
        link ||= text
        link = url_for(link)
        content_tag(:a, text, {:href => link}.merge(options))
      end

      def text_field(name, options = {})
        title = options[:title] || name.humanize
        value = options[:value] || ''
        html = "<p>"
        html << "<label for='#{name}'>#{title}</label>"
        html << "<input type='text' name='#{name}' value='#{value}' /></p>"
        html 
      end

      def url_for(link_options)
        logger.info '== url_for: ' + link_options.inspect
        return link_options unless link_options.is_a?(Hash)
        link_options = HashWithIndifferentAccess.new(link_options)
        path = link_options.delete(:path) || request.path_info
        params.delete('captures')
        full_path = path + '?' + build_query(params.merge(link_options))
        logger.info full_path
        full_path
      end
      
      def cycle(on, off, name = :cycle)
        @_cycle ||= {}
        @_cycle[name] = !@_cycle[name]
        @_cycle[name] ? on : off
      end

      def ts(time)
        time.strftime('%b %d, %Y') if time
      end

    end
  end
end