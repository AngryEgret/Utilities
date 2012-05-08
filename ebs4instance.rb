#!/usr/bin/env ruby
require 'aws-sdk'
require 'trollop'

opts = Trollop::options do
  version "ebs4instance 0.0.1 (c) 2012 Ryan Greget"
  banner <<-EOS

This script will attach EBS devices to stuff.  Also things.

Requires:
      'gem install aws-sdk trollop'

Usage:
       ebs4instance.rb [options]

where [options] are:
EOS
  opt :instance, "instance to attach EBS to", :type => String
  opt :size, "size of EBS volumes, in GB", :default => 100
  opt :count, "number of EBS volumes, max 10", :default => 4
  opt :aws_key, "AWS Public Key", :type => String, :short => "-p"
  opt :aws_secret, "AWS Secret Key", :type => String, :short => "-s"
end
Trollop::die :instance, "must provide instance id" if opts[:instance] == false
Trollop::die :count, "must be less than 21" if opts[:count] > 21
Trollop::die :aws_key, "must provide AWS Public Key" if opts[:aws_key] == false
Trollop::die :aws_secret, "must provide AWS Secret Key" if opts[:aws_secret] == false

mount = "/dev/sde"

ec2 = AWS::EC2.new(
    :access_key_id => opts[:aws_key],
    :secret_access_key => opts[:aws_secret])

instance = ec2.instances[opts[:instance]]

opts[:count].times do
  volume = ec2.volumes.create(:size => opts[:size],
                              :availability_zone => instance.availability_zone)
  attachment = volume.attach_to(instance, mount.next!)
end

puts "Done."
