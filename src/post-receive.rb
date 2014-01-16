#!/usr/bin/ruby

# Extracts the name of the branch.
branch = STDIN.gets.chomp.split.last.split('/').last

# Assigns a pseudorandom port number for the deploy.
port = rand(1000) + 33000

path = "/tmp/deploy-%s-to-port-%d" % [branch, port]

# Check out the latest branch to be pushed.
begin
  output = %x{ git clone . #{path} --branch #{branch} }
rescue
  puts "The git clone failed for some reason :("
  exit!
end

# Build the Docker image, grab the ID.
begin
  image_id = %x{ docker build -q=true #{path} 2> /dev/null }.split.last.chomp
  puts "Image ID: %s." % image_id
rescue
  puts "Uh oh, deploy failed."
  exit!
end

# Run the Docker image as a container
begin
#  system "docker run -n=true -p %d:80 %s" % [port, img_id]
  container_id = %x{ docker run -d=true -n=true -p #{port}:80 #{image_id} 2>/dev/null }.split.last.chomp
  puts "Container ID: %s." % container_id
rescue
  puts "Uh oh, deploy failed."
  exit!
end

# That's it, send back the all-good!
puts "All good! Check out port number: %d." % port
