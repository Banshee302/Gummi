require 'net/http'
require 'json'
require 'uri'
require 'fileutils'
require 'open-uri'
require 'zlib'
require 'rubygems/package'

# Configuration
INDEX_URL = 'https://raw.githubusercontent.com/banshee302/gmakepackageindex.org/main/index.json'
PLUGIN_DIR = File.expand_path('.', __dir__)   # root directory
LOCAL_INDEX = File.expand_path('local_index.json', __dir__)
INSTRUCTIONS_FILE = File.expand_path('instructions.json', __dir__)


# Fetch the remote package index
def fetch_index
  uri = URI(INDEX_URL)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
rescue => e
  puts "ERR: Failed to fetch index — #{e}"
  exit 1
end

# Save the latest index locally
def update_local_index
  index = fetch_index
  File.write(LOCAL_INDEX, JSON.pretty_generate(index))
  puts " Local index updated with #{index.keys.size} packages."
end

# Extract .tar.gz archive into a subdirectory
def extract_tar_gz(file_path, destination)
  FileUtils.mkdir_p(destination)
  Zlib::GzipReader.open(file_path) do |gz|
    Gem::Package::TarReader.new(gz) do |tar|
      tar.each do |entry|
        next unless entry.file?
        dest_file = File.join(destination, entry.full_name)
        FileUtils.mkdir_p(File.dirname(dest_file))
        File.write(dest_file, entry.read)
      end
    end
  end
  puts "Extracted contents to #{destination}"
end

# Download and install a package
def get_package(name)
  index = File.exist?(LOCAL_INDEX) ? JSON.parse(File.read(LOCAL_INDEX)) : fetch_index

  unless index.key?(name)
    puts "ERR: Package '#{name}' not found in index!"
    return
  end

  url = index[name]
  filename = File.basename(url)
  dest = File.join(PLUGIN_DIR, filename)

  FileUtils.mkdir_p(PLUGIN_DIR)
  puts " Downloading #{name} from #{url}..."

  begin
    File.write(dest, URI.open(url).read)
    puts " Installed '#{name}' to #{PLUGIN_DIR}"

    # Auto-extract if it's a .tar.gz archive
    if filename.end_with?('.tar.gz')
      extract_tar_gz(dest, File.join(PLUGIN_DIR, name))
    end
  rescue OpenURI::HTTPError => e
    puts "ERR: Failed to download package — #{e.message}"
  rescue => e
    puts "ERR: Unexpected error — #{e}"
  end
end

# Build Instructions etc

def resolve_instructions(file_path)
  unless File.exist?(file_path)
    puts ">> No Instructions Found, resolving Deltas.."
    return
  end

  puts ">> Resolving Packages.."

  begin
    instructions = JSON.parse(File.read(file_path))

    # Package metadata
    package_name = instructions["packageName"]
    package_version = instructions["pkgversion"]
    license = instructions["license"]

    puts ">> Package: #{package_name} (v#{package_version})"
    puts ">> License: #{license}" if license

    # Handle installs
    if instructions["installs"]
      puts ">> Installing dependencies..."
      instructions["installs"].each do |dep|
        puts "   - Installing #{dep} via gummi..."
        # Here you’d call your package manager logic, e.g. get_package(dep)
        get_package(dep)
      end
    else
      puts ">> No dependencies listed."
    end

    # Handle commands
    if instructions["cmds"]
      puts ">> Executing setup commands..."
      instructions["cmds"].each do |cmd|
        puts "   - Would execute: #{cmd}"
        # For safety, you might prompt the host before actually running:
        # system(cmd) if confirm("Run command #{cmd}?")
      end
    else
      puts ">> No setup commands listed."
    end

  rescue JSON::ParserError => e
    puts "ERR: Failed to parse instructions.json — #{e}"
  end
end

# Entry point
def main
  puts "Gummi Multiplatform Package Manager"

  case ARGV[0]
  when 'get'
    pkg = ARGV[1]
    if pkg.nil?
      puts "Usage: ruby gummi.rb get <packagename>"
    else
      get_package(pkg)
      resolve_instructions(INSTRUCTIONS_FILE)
    end

  when 'index'
    update_local_index

  when 'mkpkg'
    dummy = {
      "packageName" => "dummy-package",
      "pkgversion"  => "0.1.0",
      "license"     => "MIT",
      "installs"    => ["dep1", "dep2"],
      "cmds"        => ["echo 'Hello from dummy package!'"]
    }

    File.write(INSTRUCTIONS_FILE, JSON.pretty_generate(dummy))
    puts ">> Dummy instructions.json created at #{INSTRUCTIONS_FILE}, we reccomend editing it to match your Package."

  else
    puts "Usage:"
    puts "  ruby gummi.rb get <packagename>"
    puts "  ruby gummi.rb index"
    puts "  ruby gummi.rb mkpkg"
  end
end

main
