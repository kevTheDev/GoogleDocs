require 'google_docs/base_object'
require 'google_docs/folder'
require 'google_docs/document'

require 'google_docs/feed'

require 'hpricot'

module GoogleDocs

  class UnknownObjectTypeError < StandardError; end #:nodoc: all

  class Service < GData4Ruby::Service    
    #Accepts an optional attributes hash for initialization values
    def initialize(attributes = {})
      super(attributes)
    end
  
    # The authenticate method passes the username and password to google servers.  
    # If authentication succeeds, returns true, otherwise raises the AuthenticationFailed error.
    def authenticate(username, password, service='writely')
      super(username, password, service)
    end
    
    #Helper function to reauthenticate to a new Google service without having to re-set credentials.
    def reauthenticate(service='writely')
      authenticate(@account, @password, service)
    end
    
    # TODO - this should be moved up into the GData gem
    def valid_auth_token?
      !auth_token.blank?
    end
    
    def check_authentication
      raise GData4Ruby::NotAuthenticated unless valid_auth_token?
    end
    
    #Returns an array of Folder objects for each folder associated with 
    #the authenticated account.
    def folders
      check_authentication

      ret = send_request(GData4Ruby::Request.new(:get, FOLDER_LIST_FEED))
      folders = []
      REXML::Document.new(ret.body).root.elements.each("entry"){}.map do |entry|
        entry = GData4Ruby::Utils::add_namespaces(entry)
        folder = Folder.new(self)
        puts entry.to_s if debug
        folder.load("<?xml version='1.0' encoding='UTF-8'?>#{entry.to_s}")
        folders << folder
      end
      return folders
    end
    

    # returns all files, with no folder hierarchy
    def files
      check_authentication
      xml = send_files_request
      
      files = xml.search('/entry').each.inject([]) do |files, entry|
        files << build_file(entry.inner_html)
      end
      
      files.compact
    end
    
    # TODO - include support for other object types
    def build_file(entry_xml_string)
      object_type = Service.find_entry_object_type(entry_xml_string)
      
      if ['document'].include?(object_type) # TODO - we should use reflection here to keep the code small (when we add support for other object types)
        Document.new(self, entry_xml_string)
      end
    end
    
    def self.find_entry_object_type(entry_xml_string)
      xml = Hpricot(entry_xml_string)
      
      categories = xml.search("/entry//category[@scheme='http://schemas.google.com/g/2005#kind']")
      categories.any? ? categories.first['label'] : nil
    end
    
    def files_request
      GData4Ruby::Request.new(:get, GoogleDocs::Feed.document_list_feed)
    end
    
    def send_files_request
      response = send_request(files_request)
      Hpricot(response.body)
    end
    
  end
end