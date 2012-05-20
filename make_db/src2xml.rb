#/usr/bin/env ruby

require 'cgi'

def to_xml(id, file_path, file_name, package_name, version, ext_name, body)
  return <<-"EOS"
  <doc>
    <field name="id">#{id}</field>
    <field name="package">#{package_name}</field>
    <field name="version">#{version}</field>
    <field name="file_path">#{file_path}</field>
    <field name="file">#{file_name}</field>
    <field name="langage">#{ext_name}</field>
    <field name="body">
#{body}
    </field>
  </doc>
  EOS
end

base_dir = '/data/itoshi/bioconductor.jp/packages/2.11/bioc/src/contrib'
xml_dir = './xml'

id = 0
Dir.glob("#{base_dir}/*.tar.gz")  do |tar_ball|

  # extract tar ball
  cmd = "tar zxfC #{tar_ball} ./xml"
  system(cmd)

  # extract and setup input dir and output file
  package_full_name = File.basename(tar_ball).sub(/\.tar\.gz$/, "")
  version = package_full_name.match(/_(\d+\.\d+\.\d+$)/).to_a[1]
  package_name = package_full_name.sub(/_(\d+\.\d+\.\d+$)/, "")

  package_dir = File.join(xml_dir, package_name)
  xml_path    = File.join(xml_dir, package_name) + ".xml"
  
  puts package_full_name
#  p [package_full_name, package_name, version, package_dir, xml_path]

  # transform src to xml  
  xml = ""
  Dir.glob("#{package_dir}/**/*.[r|R|c|cpp|f|h]") do |file|

    # extract information
    file_path    = file.sub(/#{xml_dir}/, "")
    file_name    = File.basename(file)
    ext_name     = File.extname(file_name).sub(/^\./, "").downcase
#    p [id, file, file_path, file_name, package_name, version, ext_name, xml_path]

    # make a xml
    body = File.open(file).read
    body = body.encode("UTF-16BE",
      :invalid => :replace,
      :undef   =>:replace,
      :replace => '?').encode("UTF-8")
    body.gsub!(/(?!\n)[[:cntrl:]]/,"")
    body = CGI.escapeHTML(body)
    xml << to_xml(id, file_path, file_name, package_name, version, ext_name, body)

    id = id + 1
  end

  # output
  xml_io = File.open(xml_path, "w")
  xml_io.puts "<add>"
  xml_io.puts xml
  xml_io.puts "</add>"
  xml_io.close

  # remove extracted directory
  system("rm -rf #{package_dir}")
#  break
end
