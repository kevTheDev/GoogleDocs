Gem::Specification.new do |s|
   s.name = %q{google_docs}
   s.version = "0.1.2"
   s.date = %q{2010-03-12}
   s.authors = ["Kevin Edwards", "Mike Reich"]
   s.email = %q{mike@seabourneconsulting.com}
   s.summary = %q{A full featured wrapper for interacting with the Google Docs API}
   s.homepage = %q{http://google_docs.rubyforge.org/}
   s.description = %q{GoogleDocs is a full featured wrapper for version 2.0 of the Google Documents API (aka DocList).  GoogleDocs provides the ability to create, update and delete google documents, metadata and content.  The gem also includes support for folders, modifying permissions for documents via ACL feeds, and much more.}
   s.files = ["README", "CHANGELOG", "lib/google_docs.rb", "lib/google_docs/service.rb", "lib/google_docs/folder.rb", "lib/google_docs/document.rb", "lib/google_docs/base_object.rb"]
   s.has_rdoc = true
   s.test_files = ['test/unit.rb']
   s.add_dependency('bundler')
end 
