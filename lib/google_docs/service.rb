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
require 'gdocs4ruby/base_object'
require 'gdocs4ruby/folder'
require 'gdocs4ruby/document'
require 'gdocs4ruby/spreadsheet'
require 'gdocs4ruby/presentation'

module GDocs4Ruby

# this feeds are for version 2.0 only
#DOCUMENT_LIST_FEED = "https://docs.google.com/feeds/documents/private/full"
#FOLDER_LIST_FEED = "http://docs.google.com/feeds/documents/private/full/-/folder?showfolders=true"


DOCUMENT_UPLOAD_URI = "https://docs.google.com/feeds/default/private/full"

DOCUMENT_LIST_FEED = "http://docs.google.com/feeds/default/private/full/-/document"
FOLDER_LIST_FEED   = "http://docs.google.com/feeds/default/private/full/-/folder"

  #The service class is the main handler for all direct interactions with the 
  #Google Documents API.  A service represents a single user account.  Each user
  #account can have multiple documents and folders.
  #=Usage
  #
  #1. Authenticate
  #    service = Service.new
  #    service.authenticate("user@gmail.com", "password")
  #
  #2. Get Document List
  #    documents = service.files
  #
  #3. Get Folder List
  #    folders = serivce.folders
  #
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
      if not @auth_token
         raise NotAuthenticated
      end
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
    
    #Returns an array of objects for each document in the account.  Note that this 
    #method will return all documents for the account, including documents contained in
    #subfolders.
    def files
      contents = []
      ret = send_request(GData4Ruby::Request.new(:get, DOCUMENT_LIST_FEED))
      xml = REXML::Document.new(ret.body)
      xml.root.elements.each('entry'){}.map do |ele|
        ele = GData4Ruby::Utils::add_namespaces(ele)
        obj = BaseObject.new(self)
        obj.load(ele.to_s)
        case obj.type
          when 'document'
            doc = Document.new(self)
          when 'spreadsheet'
            doc = Spreadsheet.new(self)
          when 'presentation'
            doc = Presentation.new(self)
          else
            doc = BaseObject.new(self)
        end
        if doc
          doc.load(ele.to_s)
          contents << doc
        end
      end
      return contents
    end
  end
end