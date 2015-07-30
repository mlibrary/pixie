require_relative 'lib/pixie'
require_relative 'lib/offline'

# Use the right tar os OS X
`which gtar`
TAR = $?.exitstatus.zero? ? 'gtar' : 'tar'

# Select Debian dist
DIST = 'jessie'
PUBLIC = File.absolute_path(File.join(Pathname.new(__FILE__).dirname,'public'))

task :run => ["run:puma"]
task :ipxe => ["mk:ipxe","inject:ipxe"]
task :debian_installer => ["di"]
task :di => ["mk:di","inject:di"]
task :conf => ["mk:conf","inject:conf"]

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
    system 'rm -rf build/*'
  end

  task :ipxe do
    # Build only supported on Linux hosts
    `uname`.chomp.eql?('Linux') or abort 'mk:ipxe task requires platform Linux'

    # make working dir
    Util.mkdir 'build'
    Util.mkdir 'build/ipxe'

    t = Dir.getwd.to_s
    # fetch and build sources
    Dir.chdir('build/ipxe') do
      if Dir.exists?('ipxe')
        system 'cd ipxe; make clean; git pull'
      else
        system 'git clone git://git.ipxe.org/ipxe.git'
      end

      Dir.chdir('ipxe/src') do
        # write boot script
        Pixie::Subnets.get_each_value_of('pixiemaster').each { |h|
          TemplateEngine.new(File.join(PUBLIC,'boot.ipxe.erb'),h).write('../../boot.ipxe')
          system 'make bin/undionly.kpxe EMBED=../../boot.ipxe'
          system "cp bin/undionly.kpxe ../../#{h.hostname}.kpxe"
        }
        system 'make clean'
      end
    end
  end

  task :di => ['mk:debian_installer']
  task :debian_installer do
    # make clean working dir
    Util.mkdir 'build'
    Util.mkdir 'build/di'
    system 'rm -rf firmware firmware.cpio.gz netboot'

    Dir.chdir('build/di') do
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

  # generate config files
  task :conf do
    Util.mkdir 'build'
    Util.mkdir 'build/conf'

    # dhcp conf
    TemplateEngine.new(File.join(PUBLIC,'dhcpd.conf.erb'),h).write('build/conf/dhcpd.conf')
  end
end

namespace :inject do
  # copy ipxe boot image to tftp home
  task :ipxe do
    tftp_home = nil
    if Dir.exists?('/srv/tftp/')
      tftp_home = '/srv/tftp/'
    elsif Dir.exists('/private/tftpboot')
      tftp_home = '/srv/tftp/'
    end

    if tftp_home
      system("cp build/ipxe/*.kpxe #{tftp_home}")
    else
      abort 'No TFTP home found'
    end
  end

  # copy debian pxe install image to public
  task :di => ['inject:debian_installer']
  task :debian_installer do
    system 'rm -rf public/di'
    system 'cp -r build/di/netboot public/di'
  end

  # copy misc config files to proper locations
  task :conf do
    system 'cp build/conf/dhcpd.conf /etc/dhcp/dhcpd.conf'
  end
end

def fetch_tarball(url,targs='')
  tarball = File.basename url
  tarball_basename = File.basename url, '.tar.gz'
  system "wget #{url}" unless File.exists? tarball
  system "rm -rf tarball_basename" if Dir.exists?(tarball_basename)
  system %Q(set -f; #{TAR} xzf #{tarball} --xform="s|.*/|#{tarball_basename}/|x" #{targs})
end
