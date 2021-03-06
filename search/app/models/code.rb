class Code < ActiveRecord::Base
  attr_accessible :code, :file, :file_path, :language, :package, :version

  searchable do
    text :code, :stored => true, :more_like_this => true
#    text :code, :stored => false
    text :file
    string :package
  end
end
