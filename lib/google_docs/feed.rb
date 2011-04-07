module GoogleDocs
  
  class Feed
    
    DOCUMENT_UPLOAD_URI = "https://docs.google.com/feeds/default/private/full"

    DOCUMENT_LIST_FEED = "http://docs.google.com/feeds/default/private/full/-/document"
    FOLDER_LIST_FEED   = "http://docs.google.com/feeds/default/private/full/-/folder"
    
    def self.document_list_feed
      DOCUMENT_LIST_FEED
    end
    
    def self.folder_list_feed
      FOLDER_LIST_FEED
    end
    
    def self.document_upload_uri
      DOCUMENT_UPLOAD_URI
    end
    
  end
  
end