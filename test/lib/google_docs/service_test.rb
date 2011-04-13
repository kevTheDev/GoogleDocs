require 'test_helper'



module GoogleDocs

  class ServiceTest < ActiveSupport::TestCase
    
    context 'files' do
      
      setup do
        @service = GoogleDocs::Service.new
        stub(@service).valid_auth_token? { true }
      end
      
      should 'raise HTTPRequestFailed if !valid_response?'
      
      should 'raise no error if valid_response?' do
        stub(Parser).valid_response? { true }
        assert_nothing_raised { @service.files }
      end
      
      
    end
    
    context 'valid_auth_token?' do
      setup { @service = GoogleDocs::Service.new }
      
      should 'return false if auth_token returns nil' do
        stub(@service).auth_token { nil }
        assert_equal false, @service.valid_auth_token?
      end
      
      should 'return false if auth_token returns empty string' do
        stub(@service).auth_token { '' }
        assert_equal false, @service.valid_auth_token?
      end
      
      should 'return true  if auth_token returns a non-empty string' do
        stub(@service).auth_token { 'ksdfhk' }
        assert @service.valid_auth_token?
      end
    end
    
    context 'check_authentication' do
      setup do
        @service = GoogleDocs::Service.new
      end
      
      should 'raise NotAuthenticated if valid_auth_token? returns false' do
        stub(@service).valid_auth_token? { false }
        assert_raise( GData4Ruby::NotAuthenticated) { @service.check_authentication }
      end
      
      should 'not raise NotAuthenticated if valid_auth_token? returns true' do
        stub(@service).valid_auth_token? { true }
        assert_nothing_raised
      end
      
    end
    
    context 'files_request' do
      
      setup do
        @service = GoogleDocs::Service.new
        @service.files_request
      end
      
      before_should 'create a request object with DOCUMENT_LIST_FEED' do
        mock(GoogleDocs::Feed).document_list_feed { 'DOCUMENT_LIST_FEED' }.once
        mock(GData4Ruby::Request).new(:get, 'DOCUMENT_LIST_FEED') { '' }.once
      end
      
      should 'return a GData4Ruby::Request object' do
        assert_equal GData4Ruby::Request, @service.files_request.class
      end
    end
    
  end

end