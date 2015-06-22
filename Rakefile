task :run => ["run:puma"]
task :ipxe => ["mk:ipxe","inject:ipxe"]
task :di => ["mk:di","inject:di"]

namespace :run do
  task :shotgun do
    system 'bundle exec shotgun -s puma -o 0.0.0.0'
  end

  task :puma do
    system 'bundle exec puma'
  end
end

namespace :mk do
  task :clean do
    system 'rm -rf os_image_build/*'
  end

  task :ipxe do
    # clean working dir
    system 'mkdir os_image_build' unless Dir.exists?('os_image_build')
    system 'mkdir os_image_build/ipxe' unless Dir.exists?('os_image_build/ipxe')

    system 'bundle exec ruby bin/run_template.rb public/boot.ipxe.erb > os_image_build/ipxe/boot.ipxe'
    Dir.chdir('os_image_build/ipxe') do
      if Dir.exists?('ipxe')
        system 'cd ipxe; make clean; git pull'
      else
        system 'git clone git://git.ipxe.org/ipxe.git'
      end

      Dir.chdir('ipxe/src') do
        system 'make bin/undionly.kpxe EMBED=../../boot.ipxe'
        system 'cp bin/undionly.kpxe ../../boot.kpxe'
        system 'make clean'
      end
    end
  end

  task :di => ["mk:debian_installer"]
  task :debian_installer do
    puts "build di"
  end
end


namespace :inject do
  task :ipxe do
    system 'cp os_image_build/ipxe/boot.kpxe public/'
  end

  task :di do
    puts "inject di"
  end
end