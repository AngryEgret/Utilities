#!/usr/bin/env ruby
require 'aws-sdk'
require 'trollop'

opts = Trollop::options do
  version "aws-SecGroup-scan 0.0.1 (c) 2012 Ryan Greget"
  banner <<-EOS

This script will look for security groups on your account that are open to the world ('/0').

Requires:
      'gem install aws-sdk trollop'

Usage:
       aws-SecGroup-scan.rb [options]

where [options] are:
EOS
  opt :pattern, "Pattern to search (default '/0')", :default => "/0", :short => "-p"
  opt :aws_key, "AWS Public Key", :type => String, :short => "-k"
  opt :aws_secret, "AWS Secret Key", :type => String, :short => "-s"
end
Trollop::die :aws_key, "must provide AWS Public Key" if opts[:aws_key] == false
Trollop::die :aws_secret, "must provide AWS Secret Key" if opts[:aws_secret] == false

ec2 = AWS::EC2.new(
    :access_key_id => opts[:aws_key],
    :secret_access_key => opts[:aws_secret])

ec2.security_groups.each do |sec_group|
  sec_group.ip_permissions.each do |permissions|
    permissions.ip_ranges.each do |range|
      if range.include? opts[:pattern]
        puts sec_group.security_group_id + " - " + sec_group.name
        puts "  " + range + " " + permissions.port_range.begin.to_s + " to " + permissions.port_range.end.to_s
      end
    end
  end
end
