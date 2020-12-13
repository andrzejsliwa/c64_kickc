require 'fileutils'

DEBUGGER_PATH = '/Applications/C64\ Debugger.app/Contents/MacOS/C64Debugger'
EMULATOR_PATH = '/usr/local/bin/x64sc'

PROGRAM = 'animation' # IF YOU NEED TO CHANGE DEFAULT PROGRAM NAME - CHANGE IT HERE!!!
BUILD_DIR = 'build'
SOURCE_DIR = 'src'

is_windows = Gem.win_platform?

KICKC_SCRIPT = if is_windows
                 File.join("kickc","bin","kickc.bat")
               else
                 File.join("kickc","bin","kickc.sh")
               end

OPTIONS = if is_windows
            ''
          else
            ' 2>&1 > /dev/null &'
          end

desc 'initialize project (from level of kickc folder stored in kickc release)'
task :init_project do
  initial_source_file = File.join(SOURCE_DIR, "main.c")
  unless File.exist?(initial_source_file)
    FileUtils.mkdir_p SOURCE_DIR
    source = %{
int main() {
  return 0;
}
    }
    File.write(initial_source_file, source)
    puts "#{initial_source_file} created!"
    puts "Project initialized!"
  else
    puts "Project already initialized!"
  end

  puts "\nlisting available project tasks..."
  cmd = 'rake -T'
  output = `#{cmd}`
  puts "\n calling: #{cmd}\n\n#{output}\n\n"
  cmd = 'rake debug'
  output = `#{cmd}`
  puts "\n calling: #{cmd}\n\n#{output}\n\n"
end

task :setup_build do
  FileUtils.mkdir_p BUILD_DIR
end

desc 'clean project'
task :clean do
  FileUtils.rm_rf BUILD_DIR
end

desc 'compile program'
task :compile_c, :program do |_, args|
  Rake::Task['setup_build'].invoke

  file = args[:program] || ENV["PROGRAM"] || PROGRAM
  sh "#{KICKC_SCRIPT} #{File.join("src", "#{file}.c")} -odir=#{BUILD_DIR}"
end

desc 'assemble all build/*.asm programs'
task :compile_asm, :program do |_, args|
  Rake::Task['compile_c'].invoke

  file = args[:program] || ENV["PROGRAM"] || PROGRAM
  cmd = %{
      java -jar kickass/KickAss.jar build/#{file}.asm
          -bytedumpfile #{File.join(BUILD_DIR, "#{file}.bytedump")}
          -o build/#{file}.prg
          -afo
          -aom
          -showmem
          -debugdump
          -vicesymbols
          -symbolfile
          -symbolfiledir #{BUILD_DIR}
  }.split.join(" ")
  sh cmd
end

desc 'compile all src/*.c programs'
task :compile_all do
  Dir['src/*.c'].each do |fullpath|
    file = File.basename(fullpath, '.c')
    Rake::Task['compile_asm'].execute(program: file)
  end
end

desc 'compile & run program'
task :start, :program do |_, args|
  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  Rake::Task['compile_asm'].execute(program: file)
  cmd = %{#{EMULATOR_PATH}
    #{File.join(BUILD_DIR, "#{file}.prg")}
    #{OPTIONS}
  }.split.join(" ")
  sh cmd
end

desc 'compile & debug program'
task :debug, :program do |_, args|
  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  Rake::Task['compile_asm'].execute(program: file)
  sh %{#{DEBUGGER_PATH}
    -prg #{File.join(BUILD_DIR, "#{file}.prg")}
    -pass -unpause -autojmp -wait 250
    #{OPTIONS}
  }.split.join(" ")
end

desc 'list available programs'
task :list_programs do
  puts "Available programs:"
  Dir[File.join('src', '*.c')].each do |fullpath|
    file = File.basename(fullpath, '.c')
    puts "  #{file}"
  end
end
task default: :start