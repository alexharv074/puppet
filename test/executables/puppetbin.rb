if __FILE__ == $0
    $:.unshift '../../lib'
    $:.unshift '..'
    $puppetbase = "../.."
end

require 'puppet'
require 'puppet/server'
require 'puppet/sslcertificates'
require 'test/unit'
require 'puppettest.rb'

class TestPuppetBin < Test::Unit::TestCase
	include ExeTest
    def test_version
        output = nil
        assert_nothing_raised {
          output = %x{puppet --version}.chomp
        }
        assert_equal(Puppet.version, output)
    end

    def test_execution
        file = mktestmanifest()

        output = nil
        cmd = "puppet"
        if Puppet[:debug]
            cmd += " --debug"
        end
        #cmd += " --fqdn %s" % fqdn
        cmd += " --confdir %s" % Puppet[:confdir]
        cmd += " --vardir %s" % Puppet[:vardir]
        unless Puppet[:debug]
            cmd += " --logdest %s" % "/dev/null"
        end

        assert_nothing_raised {
            system(cmd + " " + file)
        }
        assert($? == 0, "Puppet exited with code %s" % $?.to_i)

        assert(FileTest.exists?(@createdfile), "Failed to create config'ed file")
    end

    def test_inlineexecution
        path = tempfile()
        code = "file { '#{path}': ensure => file }"

        output = nil
        cmd = "puppet"
        if Puppet[:debug]
            cmd += " --debug"
        end
        #cmd += " --fqdn %s" % fqdn
        cmd += " --confdir %s" % Puppet[:confdir]
        cmd += " --vardir %s" % Puppet[:vardir]
        unless Puppet[:debug]
            cmd += " --logdest %s" % "/dev/null"
        end

        cmd += " -e \"#{code}\""

        assert_nothing_raised {
            system(cmd)
        }
        assert($? == 0, "Puppet exited with code %s" % $?.to_i)

        assert(FileTest.exists?(path), "Failed to create config'ed file")
    end
end

# $Id$
