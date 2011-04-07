module GoogleDocs

  
  class Document < BaseObject
    DOCUMENT_XML = '<?xml version="1.0" encoding="UTF-8"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:category scheme="http://schemas.google.com/g/2005#kind"
      term="http://schemas.google.com/docs/2007#document" label="document"/>
  <atom:title>example document</atom:title>
</atom:entry>'
    DOWNLOAD_TYPES = ['doc', 'html', 'odt', 'pdf', 'png', 'rtf', 'txt', 'zip']
    EXPORT_URI = 'https://docs.google.com/feeds/download/documents/Export'
    
    #Creates a new Document instance.  Requires a valid Service object.
    def initialize(service, data, attributes = {})
      super(service, attributes, data)
      @xml = DOCUMENT_XML
    end
    
    #Retrieves an export of the Document.  The parameter +type+ must be one of the DOWNLOAD_TYPES.
    def get_content(type)
      if !@exists
        raise DocumentDoesntExist
      end
      if not DOWNLOAD_TYPES.include? type
        raise ArgumentError
      end
      ret = service.send_request(GData4Ruby::Request.new(:get, EXPORT_URI, nil, nil, {"docId" => @id,"exportFormat" => type}))
      ret.body
    end
    
    #Finds a BaseObject based on a text query or by an id.  Parameters are:
    #*service*::  A valid Service object to search.
    #*query*:: either a string containing a text query to search by, or a hash containing an +id+ key with an associated id to find, or a +query+ key containint a text query to search for.
    #*type*:: used to limit results to a specific document type, as list in TYPES.
    #*args*:: a hash containing optional additional query paramters to use.  See http://code.google.com/apis/gdata/docs/2.0/reference.html#Queries for a full list of possible values.  Example: 
    # {'max-results' => '100'}
    #If an ID is specified, a single instance of the document is returned if found, otherwise false.
    #If a query term is specified, and array of matching results is returned, or an empty array if nothing
    #was found.
    def self.find(service, query, args = {})      
      raise ArgumentError, 'query must be a hash or string' if not query.is_a? Hash and not query.is_a? String

      if query.is_a? Hash and query[:id]
        id = query[:id]
        puts "id passed, finding event by id" if service.debug
        puts "id = "+id if service.debug
        d = service.send_request(GData4Ruby::Request.new(:get, "https://docs.google.com/feeds/documents/private/full/#{id}", {"If-Not-Match" => "*"}))
        puts d.inspect if service.debug
        if d
          return get_instance(service, d)
        end
      else
        results = []
        term = query.is_a?(Hash) ? CGI::escape(query[:query]) : CGI::escape(query)
        args["q"] = term if term and term != ''
        ret = service.send_request(GData4Ruby::Request.new(:get, "https://docs.google.com/feeds/default/private/full/-/document", nil, nil, args))
        xml = REXML::Document.new(ret.body).root
        xml.elements.each("entry") do |e|
          results << get_instance(service, e)
        end
        return results
      end
      return false
    end
    
    #Downloads the export retrieved through get_content to a specified local file.  Parameters are:
    #*type*:: must be a valid type enumerated in DOWNLOAD_TYPES
    #*location*:: a valid file location for the local system
    def download_to_file(type, location)
      File.open(location, 'wb+') {|f| f.write(get_content(type)) }
    end
    
    def duplicate(new_title='duplicate')
      uri = "https://docs.google.com/feeds/default/private/full/"
      
      content = "<?xml version='1.0' encoding='UTF-8'?>
      <entry xmlns='http://www.w3.org/2005/Atom'>
        <id>https://docs.google.com/feeds/default/private/full/document%3A#{id_for_request}</id>
        <title>#{new_title}</title>
      </entry>"
      
      request = GData4Ruby::Request.new(:post, uri, content)
      ret = service.send_request(request)
      
      new_document = Document.new(@service)
      new_document.load(ret.body)
      new_document
    end
    
    def move_to_folder(folder)
      uri = "https://docs.google.com/feeds/default/private/full/folder%3A#{folder.id_for_request}/contents"
      
      content =  "<?xml version='1.0' encoding='UTF-8'?>
      <entry xmlns='http://www.w3.org/2005/Atom'>
        <id>https://docs.google.com/feeds/default/private/full/document%3A#{id_for_request}</id>
      </entry>"
      
      service.send_request(GData4Ruby::Request.new(:post, uri, content))
    end
    
    def self.find_by_id(service, document_id)
      uri = "https://docs.google.com/feeds/default/private/full/document%3A#{document_id}"
      ret = service.send_request(GData4Ruby::Request.new(:get, uri))
      document = Document.new(service)
      document.load(ret.body)
      document
    end
    
  end
end