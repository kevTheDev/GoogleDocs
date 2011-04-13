require 'google_docs/base_object'
require 'google_docs/folder'
require 'google_docs/document'
require 'hpricot'

module GoogleDocs

  class Parser

    # TODO - include support for other object types
    def self.build_file(entry_xml_string)
      object_type = entry_object_type(entry_xml_string)
      
      if ['document'].include?(object_type) # TODO - we should use reflection here to keep the code small (when we add support for other object types)
        Document.new(self, entry_xml_string)
      end
    end
    
    def self.entry_object_type(entry_xml_string)
      xml = Hpricot(entry_xml_string)
      
      categories = xml.search("/entry//category[@scheme='http://schemas.google.com/g/2005#kind']")
      categories.any? ? categories.first['label'] : nil
    end

    
  end
end