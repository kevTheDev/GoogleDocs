# Author:: Mike Reich (mike@seabourneconsulting.com)
# Copyright:: Copyright (C) 2010 Mike Reich
# License:: GPL v2
#--
# Licensed under the General Public License (GPL), Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# Feel free to use and update, but be sure to contribute your
# code back to the project and attribute as required by the license.
#++
module GDocs4Ruby
  #The Document class represents a Google Documents Folder.
  #=Usage
  #Assumes a valid and authenticated @service object.
  #1. Retrieving a list of folders
  #    @service.folders
  #
  #2. Getting a list of files in a folder
  #    @folder = @service.folders.first
  #    @folder.files
  #
  #3. Getting a list of sub folders in a folder
  #    @folder = @service.folders.first
  #    @folder.sub_folders
  #
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
          when 'spreadsheet'
            doc = Spreadsheet.new(@service)
          when 'presentation'
            doc = Presentation.new(@service)
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