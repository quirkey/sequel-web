module Sequel
  class Dataset
    
    module Pagination
      
      alias_method :total_pages, :page_count
      alias_method :previous_page, :prev_page
      alias_method :total_entries, :pagination_record_count
      alias_method :per_page, :page_size      
    end
  end
end