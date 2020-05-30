#!/usr/bin/env ruby

puts "Future"
puts "---"

Todo = Struct.new(:area, :project, :item)

PLUGIN_DIR = File.join(ENV['HOME'], "BitBar", "things_lib")

todos_raw_csv = `/usr/bin/osascript #{File.join(PLUGIN_DIR, 'things3-exporter.scpt')}`
todos = []
todos_raw_csv.split("\n").each do |line|
  next if line == ""

  parts = line.split(",", 3)
  todos << Todo.new(parts[0], parts[1], parts[2])
end 

todos_by_area = todos.group_by(&:area)

todos_by_area.each do |area, todos|
  puts "#{area} |bash=/usr/bin/osascript param1=#{File.join(PLUGIN_DIR, 'things3-opener.scpt')} param2='#{area}' refresh=false terminal=false"
  todos_by_project = todos.group_by(&:project)
  todos_by_project.each do |project, todos|
    if project.empty?
      todos.each do |todo|
        puts "--#{todo.item} |bash=/usr/bin/osascript param1=#{File.join(PLUGIN_DIR, 'things3-opener.scpt')} param2='#{todo.item}'' refresh=false terminal=false"
      end
    else
      puts "--#{project} |bash=/usr/bin/osascript param1=#{File.join(PLUGIN_DIR, 'things3-opener.scpt')} param2='#{project}'' refresh=false terminal=false"
      todos.filter{|todo| !todo.item.empty?}.each do |todo|
        puts "----#{todo.item} |bash=/usr/bin/osascript param1=#{File.join(PLUGIN_DIR, 'things3-opener.scpt')} param2='#{todo.item}'' refresh=false terminal=false"
      end
    end
  end
end

