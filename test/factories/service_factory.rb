# module GoogleDocs
# 
Factory.define(:service), :class => GoogleDocs::Service do |s|
  # a.email { Factory.next(:email) }
  #   a.password  'wibble'
  #   a.password_confirmation 'wibble'
end
# 
# 
# end
# Factory.define(:account_with_admin, :parent => :account) do |account|
#   account.after_build { |a| a.user = Factory.create(:admin) }
# end
