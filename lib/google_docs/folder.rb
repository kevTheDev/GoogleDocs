module GoogleDocs

  class Folder < BaseObject
      FOLDER_XML = '<?xml version="1.0" encoding="UTF-8"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:category scheme="http://schemas.google.com/g/2005#kind"
      term="http://schemas.google.com/docs/2007#folder" label="folder"/>
  <atom:title></atom:title>
</atom:entry>'
  
    #Creates a new Folder instance.  Requires a valid GData4Ruby#Service object.
    def initialize(service, attributes = {})
      super(service, attributes)
      @xml = FOLDER_XML
    end

    public
    #Loads the Calendar with returned data from Google Calendar feed.  Returns true if successful.
    def load(string)
      super(string)
      xml = REXML::Document.new(string)
      xml.root.elements.each(){}.map do |ele|
#        case ele.name
#          
#        end
      end
      
      @folder_feed = @id
      return true
    end
    
    #Returns a list of sub folders that this folder contains.
    def sub_folders
      ret = service.send_request(GData4Ruby::Request.new(:get, @content_uri+"/-/folder?showfolders=true"))
      folders = []
      REXML::Document.new(ret.body).root.elements.each("entry"){}.map do |entry|
        entry = GData4Ruby::Utils::add_namespaces(entry)
        folder = Folder.new(service)
        puts entry.to_s if service.debug
        folder.load("<?xml version='1.0' encoding='UTF-8'?>#{entry.to_s}")
        folders << folder
      end
      return folders
    end
    
    #Returns a list of files in the folder
    def files
      return nil if @content_uri == nil
      contents = []
      ret = @service.send_request(GData4Ruby::Request.new(:get, @content_uri))
      xml = REXML::Document.new(ret.body)
      xml.root.elements.each('entry'){}.map do |ele|
        ele = GData4Ruby::Utils::add_namespaces(ele)
        obj = BaseObject.new(@service)
        obj.load(ele.to_s)
        case obj.type
          when 'document'
            doc = Document.new(@service)
          when 'folder'
            doc = Folder.new(@service)
        end
        doc.load(ele.to_s)
        contents << doc
      end
      return contents
    end
    
    #Helper function limit queries to Folders.  See BaseObject#find for syntax.  Type is not required and assumed to be 'document'.
    def self.find(service, query, args = {})      
      raise ArgumentError if not query.is_a? Hash and not query.is_a? String
      ret = query.is_a?(String) ? [] : nil
      service.folders.each do |f|
        if (query.is_a? Hash and ((query[:id] and f.id == query[:id]) or (query[:query] and f.title.include? query[:query])))
          return f
        end
        if (query.is_a? String and f.title.include? query)
          ret << f
        end
      end
      return ret
    end
    
    def find_sub_folder(sub_folder_name)
      sub_folders.each do |f|
        return f if f.title == sub_folder_name
      end
      
      return nil
    end

    # TODO - not DRY
    def create_sub_folder(sub_folder_name)
      content = "<?xml version='1.0' encoding='UTF-8'?>
    <atom:entry xmlns:atom='http://www.w3.org/2005/Atom'>
      <atom:category scheme='http://schemas.google.com/g/2005#kind'
          term='http://schemas.google.com/docs/2007#folder' label='folder'/>
      <atom:title>#{sub_folder_name}</atom:title>
        </atom:entry>"
      ret = service.send_request(GData4Ruby::Request.new(:post, "https://docs.google.com/feeds/default/private/full/folder%3A#{id_for_request}/contents", content))
    end

    def find_or_create_sub_folder(sub_folder_name)
      sub_folder = find_sub_folder(sub_folder_name)
      return sub_folder unless sub_folder.nil?

      create_sub_folder(sub_folder_name)
      find_sub_folder(sub_folder_name)
    end
    
  end
end