# Pushes the rhouse.gem to your linux mce box
# NOTE: You should mod this task per your env.
namespace :gem do
  desc "Deploy rhouse gem to linux mce box"
  task :deploy => [:clobber, :package] do
    gem_files = Dir.glob("pkg/*.gem").join(' ')
    results  = %x[scp #{gem_files} fernand@rhouse:~/downloads/]
    if $?.exitstatus == 0 then
      puts "gems `#{gem_files} copied to RHOUSE"
    else
      puts "failed to copy"
      puts results
    end
  end
end
