# Use the right tar os OS X
`which gtar`
TAR = $?.exitstatus.zero? ? 'gtar' : 'tar'

# Select Debian dist
DIST = 'jessie'

task :run => ["run:puma"]
task :ipxe => ["mk:ipxe","inject:ipxe"]
task :debian_installer => ["di"]
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
    # make working dir
    system 'mkdir os_image_build' unless Dir.exists?('os_image_build')
    system 'mkdir os_image_build/ipxe' unless Dir.exists?('os_image_build/ipxe')

    # write boot script
    system 'bundle exec ruby bin/run_template.rb public/boot.ipxe.erb > os_image_build/ipxe/boot.ipxe'
    
    # fetch and build sources
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

  task :di => ['mk:debian_installer']
  task :debian_installer do
    # make clean working dir
    system 'mkdir os_image_build' unless Dir.exists?('os_image_build')
    system 'mkdir os_image_build/di' unless Dir.exists?('os_image_build/di')
    system 'rm -rf firmware firmware.cpio.gz netboot'

    Dir.chdir('os_image_build/di') do
      # fetch sources
      fetch_tarball "http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/#{DIST}/current/firmware.tar.gz", "--wildcards *bnx* *qlogic*"
      fetch_tarball "http://ftp.us.debian.org/debian/dists/#{DIST}/main/installer-amd64/current/images/netboot/netboot.tar.gz", "--wildcards *linux *initrd.gz *version.info"

      # build firmware bundle
      # do not change this to use cpio instead of pax, it won't work
      system %q(pax -x sv4cpio -s'%firmware%/firmware%' -w firmware | gzip -c >firmware.cpio.gz)
      Dir.chdir('netboot') do
        system 'mv initrd.gz initrd.gz.orig'
        system 'cat initrd.gz.orig ../firmware.cpio.gz > initrd.gz'
      end

    end
  end
end

namespace :inject do
  # install ipxe boot image to tftp home
  task :ipxe do
    system 'mkdir -p tftp'
    system 'cp os_image_build/ipxe/boot.kpxe tftp/'
  end
  
  task :di => ['inject:debian_installer']
  task :debian_installer do
    system 'rm -rf public/di'
    system 'cp -r os_image_build/di/netboot public/di'
  end
end

def fetch_tarball(url,targs='')
  tarball = File.basename url
  tarball_basename = File.basename url, '.tar.gz'
  system "wget #{url}" unless File.exists? tarball
  system "rm -rf tarball_basename" if Dir.exists?(tarball_basename)
  system %Q(set -f; #{TAR} xzf #{tarball} --xform="s|.*/|#{tarball_basename}/|x" #{targs})
end
