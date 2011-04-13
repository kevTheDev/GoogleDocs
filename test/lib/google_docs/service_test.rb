require 'test_helper'



module GoogleDocs

  class ServiceTest < ActiveSupport::TestCase
    
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
        assert_nothing_raised( GData4Ruby::NotAuthenticated) { @service.check_authentication }
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
    
    
    context 'self.entry_object_type' do
      
      setup do
       @body =  "<entry gd:etag='&quot;BBEVVARCDit7ImBr&quot;'>
              <id>http://docs.google.com/feeds/id/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q</id>
              <published>2011-04-07T16:09:24.257Z</published>
              <updated>2011-04-07T16:09:24.807Z</updated>
              <app:edited xmlns:app='http://www.w3.org/2007/app'>2011-04-07T16:09:26.566Z</app:edited>
              <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/docs/2007#document' label='document'/>
              <category scheme='http://schemas.google.com/g/2005/labels' term='http://schemas.google.com/g/2005/labels#viewed' label='viewed'/>
              <title>Monica Muguti_CV_unpublished_associate_272</title>
              <content type='text/html' src='http://docs.google.com/feeds/download/documents/export/Export?id=1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q'/>

              <link rel='http://schemas.google.com/docs/2007#parent' type='application/atom+xml' href='http://docs.google.com/feeds/default/private/full/folder%3A0B3jiE2DZb0utM2E2YzQ3ZDAtODYzOS00NWQ4LTlkZWYtMWEzNjdkY2I3ZTk2' title='unpublished'/>
              <link rel='alternate' type='text/html' href='http://docs.google.com/a/mysilvercloud.co.uk/document/d/1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q/edit?hl=en'/>
              <link rel='http://schemas.google.com/g/2005#resumable-edit-media' type='application/atom+xml' href='http://docs.google.com/feeds/upload/create-session/default/private/full/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q'/>
              <link rel='http://schemas.google.com/docs/2007/thumbnail' type='image/jpeg' href='http://lh4.googleusercontent.com/Y6T89U6BF0SZahH9K6Q_0S8QsGG90zNfToAEmbDEVr6TGya821BNcLg5KdEHIUkVUtg5IX0oIhULwx_g=s220'/>
              <link rel='self' type='application/atom+xml' href='http://docs.google.com/feeds/default/private/full/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q'/>
              <link rel='edit' type='application/atom+xml' href='http://docs.google.com/feeds/default/private/full/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q'/>
              <link rel='edit-media' type='text/html' href='http://docs.google.com/feeds/default/media/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q'/>

              <author>
                <name>system_job</name>
                <email>system_job@mysilvercloud.co.uk</email>
              </author>

              <gd:resourceId>document:1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q</gd:resourceId>
              <gd:lastModifiedBy>
                <name>system_job</name>
                <email>system_job@mysilvercloud.co.uk</email>
              </gd:lastModifiedBy>
              <gd:lastViewed>2011-04-07T16:09:24.807Z</gd:lastViewed>
              <gd:quotaBytesUsed>0</gd:quotaBytesUsed>

              <docs:writersCanInvite value='true'/>
              <gd:feedLink rel='http://schemas.google.com/acl/2007#accessControlList' href='http://docs.google.com/feeds/default/private/full/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q/acl'/>
              <gd:feedLink rel='http://schemas.google.com/docs/2007/revisions' href='http://docs.google.com/feeds/default/private/full/document%3A1rVSpkMWoFIs0wBzfIcvCGXvK6onHC959WxqqSNIa35Q/revisions'/>
            </entry>
          </feed>
        "
      end
      
      should 'return an object_type of document' do
        object_type = Service.entry_object_type(@body)
        assert_equal 'document', object_type
      end
    end
    
  end

end

# this is what we are looking for when we create a document object
# @type = cat[:label] if cat[:scheme] and cat[:scheme] == 'http://schemas.google.com/g/2005#kind'