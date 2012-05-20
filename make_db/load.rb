#/usr/bin/env ruby

require 'cgi'
require 'sqlite3'

db_file  = "../search/db/development.sqlite3"
base_dir = '/data/itoshi/bioconductor.jp/packages/2.11/bioc/src/contrib'
tmp_dir = './tmp'

db = SQLite3::Database.new(db_file)

id = 0
Dir.glob("#{base_dir}/*.tar.gz")  do |tar_ball|

  # extract tar ball
  cmd = "tar zxfC #{tar_ball} ./tmp"
  system(cmd)

  # extract and setup input dir and output file
  package_full_name = File.basename(tar_ball).sub(/\.tar\.gz$/, "")
  version = package_full_name.match(/_(\d+\.\d+\.\d+$)/).to_a[1]
  package_name = package_full_name.sub(/_(\d+\.\d+\.\d+$)/, "")

  package_dir = File.join(tmp_dir, package_name)
  
  puts package_full_name
#  p [package_full_name, package_name, version, package_dir]

  # transform src to code
  code = ""
  Dir.glob("#{package_dir}/**/*.[r|R|c|cpp|f|h]") do |file|

    # extract information
    file_path    = file.sub(/#{tmp_dir}/, "")
    file_name    = File.basename(file)
    ext_name     = File.extname(file_name).sub(/^\./, "").downcase
#    p [file, file_path, file_name, package_name, version, ext_name]

    # Escape code text
    code = File.open(file).read
    code = code.encode("UTF-16BE",
      :invalid => :replace,
      :undef   =>:replace,
      :replace => '?').encode("UTF-8")
    code.gsub(/\t/, "  ")
    code.gsub!(/(?!\n)[[:cntrl:]]/,"")
    code = CGI.escapeHTML(code)
    
    # Load data to database
    db.execute("delete from codes where id = #{id}")
    sql = "insert into codes values (?, ?, ?, ?, ?, ?, ?)"
    db.execute(sql,
      id,
      package_name, version, file_path,
      file_name, ext_name, code
    )
    id = id + 1
  end

  # remove extracted directory
  system("rm -rf #{package_dir}")

end
