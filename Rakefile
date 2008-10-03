begin
  $: << 'lib'; %w( rubygems rake/testtask rake/rdoctask rake/gempackagetask
    ext/string ext/symbol ext/kernel extensions/all date ).each { |dep| require dep }
rescue LoadError => e
  if e.message == 'no such file to load -- extensions/all'
    puts "Better do `rake setup` to get all the fancies you're missing"
    puts
  else
    raise e
  end
end

gem = Gem::Specification.new do |gem|
  gem.name = "waves"
  gem.rubyforge_project = "waves"
  gem.summary = "Open-source framework for building Ruby-based Web applications."
  gem.version = File.read('doc/VERSION')
  gem.homepage = 'http://rubywaves.com'
  gem.author = 'Dan Yoder'
  gem.email = 'dan@zeraweb.com'
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.8.6'
  %w( mongrel rack markaby erubis haml metaid
      extensions live_console choice daemons functor ).each do |dep|
    gem.add_dependency dep
  end
  gem.add_dependency('rakegen', '>= 0.6.6')
  gem.add_dependency('sequel', '>= 2.0.0')
  gem.add_dependency('autocode', '>= 1.0.0')
  gem.add_dependency('dyoder-filebase', '>= 0.3.4')
  gem.add_dependency('dyoder-functor', '>= 0.5.0')


  # Unfortunately there are some gems that don't work in JRuby, so...
  case engine
    when 'ruby'
    # Matz' Ruby dependencies here...
    puts "You are running MRI/Ruby #{RUBY_VERSION}"
    gem.add_dependency('RedCloth', '>= 4.0.0')
    when 'jruby'
    # JRuby compatible dependencies here...
    puts "You are running JRuby #{JRUBY_VERSION}"
    gem.add_dependency('RedCloth', '= 3.0.4')
    else
    # Not sure what you're running, we're not sure. We'll just try the MRI specifics...
    puts "You are running #{RUBY_ENGINE} #{RUBY_VERSION}"
    gem.add_dependency('RedCloth', '>= 4.0.0')
  end
  
  gem.files = FileList[ 'app/**/*', 'app/**/.gitignore', 'lib/**/*.rb','lib/**/*.erb', "{doc,samples,verify}/**/*" ]
  gem.has_rdoc = true
  gem.bindir = 'bin'
  gem.executables = [ 'waves', 'waves-server', 'waves-console' ]
end

desc "Create the waves gem"
task( :package => :clean ) { Gem::Builder.new( gem ).build }

desc "Clean build artifacts"
task( :clean ) { FileUtils.rm_rf Dir['*.gem'] }

desc "Rebuild and Install Waves as a gem"
task( :install => [ :package, :rdoc, :install_gem ] )

desc "Install Waves a local gem"
task( :install_gem ) do
    require 'rubygems/installer'
    Dir['*.gem'].each do |gem|
      Gem::Installer.new(gem).install
    end
end

desc "create .gemspec file (useful for github)"
task :gemspec do
  filename = "#{gem.name}.gemspec"
  File.open(filename, "w") do |f|
    f.puts gem.to_ruby
  end
end

desc "Publish to RubyForge"
task( :publish => [ :package, :rdoc_publish ] ) do
  `rubyforge login`
  `rubyforge add_release #{gem.name} #{gem.name} #{gem.version} #{gem.name}-#{gem.version}.gem`
end

task( :rdoc_publish => :rdoc ) do
  path = "/var/www/gforge-projects/#{gem.name}/"
  `rsync -a --delete ./doc/rdoc/ dyoder67@rubyforge.org:#{path}`
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
  rdoc.rdoc_files.add [ 'lib/**/*.rb', 'README.rdoc', 'doc/HISTORY' ]
end

# based on a blog post by Assaf Arkin
desc "Set up dependencies so you can work from source"
task( :setup ) do
  gems = Gem::SourceIndex.from_installed_gems
  # Runtime dependencies from the Gem's spec.
  dependencies = gem.dependencies
  # Add build-time dependencies, like this:
  dependencies.each do |dep|
    if gems.search(dep.name, dep.version_requirements).empty?
      puts "Installing dependency: #{dep}"
      begin
        require 'rubygems/dependency_installer'
        if Gem::RubyGemsVersion =~ /^1\.0\./
          Gem::DependencyInstaller.new(dep.name, dep.version_requirements).install
        else
          # as of 1.1.0
          Gem::DependencyInstaller.new.install(dep.name, dep.version_requirements)
        end
      rescue LoadError # < rubygems 1.0.1
        require 'rubygems/remote_installer'
        Gem::RemoteInstaller.new.install(dep.name, dep.version_requirements)
      end
    end
  end
  system(cmd = "chmod +x bin/waves*")
  puts "rake setup task completed... happy hacking!"
end

def verify_excludes
  [
    "**/obsolete_*/*",
    "**/track_*.rb",
    "**/helpers.rb"
  ]
end

desc "Run the unit tests and specs"
task :verify => [ :spec, :test ]

Rake::TestTask.new(:spec) do |t|
  t.test_files = FileList["verify/specs/**/*.rb"].exclude( 
    *( verify_excludes + [ "**/app_generation/*.rb" ] )
  )
  t.verbose = true
end

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["verify/tests/**/*.rb"].exclude( *verify_excludes )
  t.verbose = true
end

# subset tasks, e.g. verify:mapping
namespace :test do
  
  FileList["verify/tests/*/"].each do |area|
    task = area.sub("verify/tests/", '').chomp("/")
    Rake::TestTask.new(task) do |t|
      t.test_files = FileList["#{area}**/*.rb"].exclude( *verify_excludes )
      t.verbose = true
    end
  end

end

namespace :spec do
  
  FileList["verify/specs/*/"].each do |area|
    task = area.sub("verify/specs/", '').chomp("/")
    Rake::TestTask.new(task) do |t|
      t.test_files = FileList["#{area}**/*.rb"].exclude( *verify_excludes )
      t.verbose = true
    end
  end
  
end



