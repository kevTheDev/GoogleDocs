require 'google_docs/base_object'
require 'google_docs/folder'
require 'google_docs/document'
require 'hpricot'

module GoogleDocs

  

  class Parser
    
    def self.entry_object_type(entry_xml_string)
      xml = Hpricot(entry_xml_string)
      
      categories = xml.search("/entry//category[@scheme='http://schemas.google.com/g/2005#kind']")
      categories.any? ? categories.first['label'] : nil
    end
    
    # TODO - include support for other object types
    def self.build_file(entry_xml_string)
      object_type = entry_object_type(entry_xml_string)
      
      if ['document'].include?(object_type) # TODO - we should use reflection here to keep the code small (when we add support for other object types)
        Document.new(self, entry_xml_string)
      end
    end
    
    def self.build_files(files_request_response)
      xml = Hpricot(files_request_response)
      
      files = xml.search('/entry').each.inject([]) do |files, entry|
        files << Parser.build_file(entry.inner_html)
      end
      
      files.compact
    end
    
    # TODO - This might need to be moved to the GData gem
    # Checks that a response conforms to the structure that we expect for a give request
    def self.response_valid?(response, request_type)
      return false if response.blank?
      
      case request_type
      when RequestType.get_all_files
        get_all_files_response_valid?
      else
        raise UnknownRequestType
      end
    end
    
    def self.get_all_files_response_valid?(response)
      
    end
    
  end
end