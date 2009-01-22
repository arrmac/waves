module Waves

  # A temporary measure until the applications "array" becomes a hash.
  # Currently used to keep track of all loaded Waves applications.
  class Applications < Array
    def []( name ) ; self.find { |app| app == name.to_s.camel_case } ; end
  end
  
  def self.config; instance.config ; end
  
  # The list of all loaded applications
  def self.applications ; @applications ||= Applications.new ; end

  # Access the principal Waves application.
  def self.main ; applications.first ; end

  # Register a module as a Waves application.
  def self.<< ( app )
    applications << app if Module === app
  end

  # Returns the most recently created instance of Waves::Runtime.
  def self.instance ; Waves::Runtime.instance ; end
  
  def self.version ; File.read( File.expand_path( "#{File.dirname(__FILE__)}/../../../doc/VERSION" ) ) ; end
  def self.license ; File.read( File.expand_path( "#{File.dirname(__FILE__)}/../../../doc/LICENSE" ) ) ; end
  
  def self.method_missing(name,*args,&block)
    cache_method_missing name, "instance.#{name}( *args, &block)", *args, &block
  end

  # A Waves::Runtime takes an inert application module and gives it concrete, pokeable form.
  # Waves::Server and Waves::Console are types of runtime.
  class Runtime

    class << self; attr_accessor :instance; end

    # Accessor for options passed to the runtime.
    attr_reader :options

    # Create a new Waves application instance.
    def initialize( options={} )
      @options = options
      Dir.chdir options[:directory] if options[:directory]
      Runtime.instance = self
    end

    # The 'mode' of the runtime determines which configuration it will run under.
    def mode ; options[:mode]||:development ; end
    
    # Returns true if debug was set to true in the current configuration.
    def debug? ; options[:debugger] or config.debug ; end

    # Returns the current configuration.
    def config ; Waves.main::Configurations[ mode ] ; end

    # Reload the modules specified in the current configuration.
    def reload ; config.reloadable.each { |mod| mod.reload } ; end

    # Start and / or access the Waves::Logger instance.
    def log ; @log ||= Waves::Logger.start ; end

    # Provides access to the server mutex for thread-safe operation.
    def synchronize( &block ) ; ( @mutex ||= Mutex.new ).synchronize( &block ) ; end
    def synchronize? ; !options[ :turbo ] ; end

  end

end
