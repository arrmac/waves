namespace :cluster do

  desc 'Start a cluster of waves applications.'
  task :start do |task|
    waves = defined?(WAVES) || ENV['WAVES'] || File.exist?( File.dirname(__FILE__) / :waves )
    script = waves ? ( waves / :bin / 'waves-server' ) : 'waves-server'
    ( Waves::Console.config.ports || [ Waves::Console.config.port ] ).each do |port|
      cmd = "#{script} -p #{port} -c #{ENV['mode']||'development'} -d"
      puts cmd ; `#{cmd}`
    end
  end

  desc 'Stop a cluster of waves applications.'
  task :stop do |task|
     Dir[ :log / '*.pid' ].each do |pidfile|
       pid = File.read(pidfile).to_i
       puts "Stopping process #{pid} ..."
       Process.kill( 'INT', pid ) rescue nil
    end
  end

  desc 'Restart a cluster of waves applications.'
  task :restart => [ :stop, :start ] do |task|
  end

end
