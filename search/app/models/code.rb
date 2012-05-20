class Code < ActiveRecord::Base
  attr_accessible :code, :file, :file_path, :language, :package, :version

  searchable do
    text :code, :stored => true
    text :file
  end
end
