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
    
    #Returns an array of Folder objects for each folder associated with 
    #the authenticated account.
    def folders
      raise NotAuthenticated unless @auth_token

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
    
    # TODO - We want a folder / files hierarchy here
    #Returns an array of objects for each document in the account.  Note that this 
    #method will return all documents for the account, including documents contained in
    #subfolders.
    def files
      raise NotAuthenticated unless @auth_token

      files = []
      
      response = send_request(files_request)
      xml = REXML::Document.new(response.body)
      
      xml.root.elements.each('entry'){}.map do |element|
        element = GData4Ruby::Utils::add_namespaces(element)
        
        object_type = Service.find_entry_object_type(element.to_s)
        case object_type
        when 'document'
          files << Document.new(self, element.to_s)
        end
      end
      
      return files
    end
    
    def self.find_entry_object_type(entry_xml_string)
      xml = Hpricot(entry_xml_string)
      
      categories = xml.search("/entry//category[@scheme='http://schemas.google.com/g/2005#kind']")
      return categories.first['label'] if categories.any?
      nil
    end
    
    def files_request
      GData4Ruby::Request.new(:get, GoogleDocs::Feed.document_list_feed)
    end
  end
end