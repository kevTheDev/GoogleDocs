require 'test_helper'



module GoogleDocs

  class ParserTest < ActiveSupport::TestCase
    
    context 'response_valid?' do
      
      should 'return false if response.nil?' do
        assert_equal false, Parser.response_valid?(nil, RequestType.get_all_files)
      end
      
      should 'return false if response.empty?' do
        assert_equal false, Parser.response_valid?('', RequestType.get_all_files)
      end
      
      should 'raise error if the request_type is not recognized' do
        assert_raise(UnknownRequestType) { Parser.response_valid?('response_string', 'UNKNOWN_REQUEST_TYPE') }
      end
      
      should 'call appropriate response validation method' do
        mock(Parser).get_all_files_response_valid? { true }.once
        Parser.response_valid?('response_string', RequestType.get_all_files)
      end
        
        
        
      
    end
    
    context 'build_files' do
      should 'return [] if response is empty'
    end
    
    context 'build_file' do
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
        object_type = Parser.entry_object_type(@body)
        assert_equal 'document', object_type
      end
    end
    
  end

end