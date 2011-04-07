# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "google_docs/version"


Gem::Specification.new do |s|
   s.name = %q{google_docs}
   s.version = GoogleDocs::VERSION
   s.date = %q{2010-03-12}
   s.authors = ["Kevin Edwards", "Mike Reich"]
   s.email = %q{kev.j.edwards@gmail.com}
   s.summary = %q{A full featured wrapper for interacting with the Google Docs API}
   s.homepage = %q{http://github.com/kevTheDev/google_docs}
   s.description = %q{GoogleDocs is a full featured wrapper for version 3.0 of the Google Documents API (aka DocList).  GoogleDocs provides the ability to create, update and delete google documents, metadata and content.  The gem also includes support for folders, modifying permissions for documents via ACL feeds, and much more.}


   s.files         = `git ls-files`.split("\n")
   s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
   s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
   s.require_paths = ["lib"]
end 