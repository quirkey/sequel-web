module Sequel
  module Web
    module ViewHelpers
      extend Rack::Utils
      
      def build_query(params)
        params.map { |k, v|
          if v.is_a? Array
            build_query(v.map { |x| [k, x] })
          elsif v.is_a? Hash
            build_query(v.map { |x, y| [[k].push(x).flatten, y]})
          else
            k = k.is_a?(Array) ? [escape(k.shift), k.map {|x| "[#{escape(x)}]"}].join('') : escape(k)
            k + "=" + escape(v)
          end
        }.join("&")
      end
      module_function :build_query

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
      
      def input_for_column(row, table_name, column, options = {})
        prefix = options[:prefix] || "record"
        column_type = @db.schema(table_name).detect {|c| c[0] == column.to_sym }[1][:type]
        case column_type
        when :datetime
          value = row[column].is_a?(Time) ? row[column].to_s(:db) : row[column]
          text_field("#{prefix}[#{column}]", :title => column, :value => value)
        else
          text_field("#{prefix}[#{column}]", :title => column, :value => row[column])
        end
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
      
      
      def sortable_column_header(attribute_name, text = nil, options = {})
        link_text = text || attribute_name.to_s.humanize
        query_param = options[:query_param] || 'query'
        query_parser = RestfulQuery::Parser.new(params[query_param])
        logger.info 'params:' +  self.params[query_param].inspect
        logger.info 'parser:' + query_parser.inspect
        sorting_this = query_parser.sort(attribute_name)
        logger.info "sorting #{attribute_name}:" + sorting_this.inspect
        link_text << %{<span class="ui-icon ui-icon-triangle-1-#{sorting_this.direction == 'asc' ? 'n' : 's'}"></span>} if sorting_this
        query_parser.clear_default_sort!
        query_parser.set_sort(attribute_name, sorting_this ? sorting_this.next_direction : 'desc')
        link_to(link_text, self.params.dup.merge(query_param => query_parser.to_query_hash), :class => 'sortable-column-header')
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