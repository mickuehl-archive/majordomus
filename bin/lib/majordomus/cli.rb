
require 'json'
require 'yaml'
require 'excon'
require 'thor'

# The top-level module for the Majordomus API
module Majordomus
  
  class CLI < Thor
    
    def initialize(p1,p2,p3)
      super
    end
    
    desc "create TYPE NAME", "Create the metadata for a new app"
    def create(type,name)
      # TYPE = static | container
      # NAME = organization/name
      
      # returns a random name e.g. angry_stallmann, that is used as a primary hostname
      # 1) create random_name and add it to consul random_name => NAME, NAME => random_name
      # 2) add random_name.BASE_DOMAIN to the host table
      # 3 create random_name.yml basic configuration
      # 4) static:
      #   create www/random_name folder
      #   create random_name.conf nginx config and add it to sites-available
      # 5) container:
      # => NAME becomes the image name in the beginning
      
      if !(type == 'static') && !(type == 'container')
        raise Thor::Error.new("Invalid application type '#{type}'. Expected 'static', 'container'. ")
      end
      
      if Majordomus::kv_key? "apps/name/#{name}"
        raise Thor::Error.new("Application '#{name}' already exists. Use a different name.")
      end
      
      begin
        rname = Majordomus::random_name
      end while Majordomus::kv_key? "uname/#{rname}"
      
      # basic data in the consul index
      Majordomus::put_kv "apps/name/#{name}", rname
      Majordomus::put_kv "uname/#{rname}", name
      
      # basic metadata
      meta = {
        "name" => name,
        "internal" => rname,
        "type" => type
      }
      Majordomus::put_kv "apps/meta/#{rname}", meta.to_s
      
      return rname
      
    end

    desc "build NAME", "Build or pull an new image"
    def build(name)
      puts "*** BUILD #{name}"
      
      # NAME = organization/name
      # 1) look-up random_name based on the NAME. Error if it does not exists
      # 2) load random_name.yml
      # 3) static:
      #   move contents from git/NAME to www/random_name
      # 4) container:
      #   if there IS NO Dockerfile => pull NAME from repository
      #   if there IS a Dockerfile  => build NAME from git/NAME
      #   introspect image metadata and update the random_name,yml
      #     - remove missing ENV, add new ENV, keep ENV if content different from metadata
    end
    
    desc "open NAME", "Open the app for traffic"
    def open(name)
      puts "*** OPEN #{name}"
      
      # NAME = organization/name
      
      # move the nginx config to sites-enabled and restart nginx
      # random_name.conf, mapped_hostname.conf
    end
    
    desc "close NAME", "Close the app for traffic"
    def close(name)
      puts "*** CLOSE #{name}"
      
      # NAME = organization/name
      
      # remove the config from sites-enabled and restart nginx
      # random_name.conf, mapped_hostname.conf
    end
    
    desc "remove NAME", "Remove the app and all its metadata"
    def remove(name)
      
      if !Majordomus::kv_key? "apps/name/#{name}"
        raise Thor::Error.new("Application '#{name}' does not exist.")
      end
      
      rname = Majordomus::get_kv "apps/name/#{name}"
      
      # stop the app
      
      # cleanup consul
      Majordomus::delete_kv "apps/name/#{name}"
      Majordomus::delete_kv "uname/#{rname}"
      Majordomus::delete_kv "apps/meta/#{rname}"
      
      return rname
    end        
    
  end # class CLI
  
end


