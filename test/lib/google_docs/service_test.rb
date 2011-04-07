require 'test_helper'



module GoogleDocs

  class ServiceTest < ActiveSupport::TestCase
    
    context 'files_request' do
      
      setup do
        @service = GoogleDocs::Service.new
        @service.files_request
      end
      
      before_should 'create a request object with DOCUMENT_LIST_FEED' do
        mock(GoogleDocs::Feed).document_list_feed { 'DOCUMENT_LIST_FEED' }.once
        mock(GData4Ruby::Request).new(:get, 'DOCUMENT_LIST_FEED') { '' }.once
      end
      
      
    end
    
    
    context 'files' do
      
      setup do
      end
      
      
      
    end
    
  end

end