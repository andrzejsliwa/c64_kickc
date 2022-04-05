require 'fileutils'

DEBUGGER_PATH = '/Applications/C64\ Debugger.app/Contents/MacOS/C64\ Debugger'
EMULATOR_PATH = '/Applications/Vice/x64.app/Contents/MacOS/x64'

PROGRAM = 'print' # IF YOU NEED TO CHANGE DEFAULT PROGRAM NAME - CHANGE IT HERE!!!
BUILD_DIR = 'build'
RELATIVE_BUILD_DIR = File.join("..", BUILD_DIR)
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
  file_path = File.join("src", "#{file}.c")

  if File.exist?(File.join(file_path))
    sh "#{KICKC_SCRIPT} #{file_path} -odir=#{BUILD_DIR}"
  end
end

desc 'convert all (src)/*.bas'
task :compile_bas, :program do |_, args|
  Rake::Task['setup_build'].invoke

  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  build_file = File.join("src", "#{file}.bas")
  cmd = %{
    petcat -w2
        -o #{BUILD_DIR}/#{file}.prg
        -- #{build_file}
  }.split.join(" ")
  sh cmd
end

desc 'assemble all (build|src)/*.s programs'
task :compile_asm, :program, :options do |_, args|
  Rake::Task['compile_c'].invoke

  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  build_file =
    if File.exist?(File.join("src", "#{file}.s"))
      File.join("src", "#{file}.s")
    else
      File.join("build", "#{file}.asm")
    end

  cmd = %{
      java -jar kickass/KickAss.jar #{build_file}
          -bytedumpfile ../#{BUILD_DIR}/#{file}.bytedump
          -o #{BUILD_DIR}/#{file}.prg
          -afo
          -aom
          -showmem
          -debugdump
          -vicesymbols
          -libdir ./lib
          -symbolfile
          -symbolfiledir ../#{BUILD_DIR}
          #{args[:options]}
  }.split.join(" ")
  sh cmd
end

desc 'compile all src/*.(c|s|bas) programs'
task :compile_all do
  Dir['src/*.c'].each do |fullpath|
    file = File.basename(fullpath, '.c')
    Rake::Task['compile_asm'].execute(program: file)
  end
  Dir['src/*.s'].each do |fullpath|
    file = File.basename(fullpath, '.s')
    Rake::Task['compile_asm'].execute(program: file)
  end
  Dir['src/*.bas'].each do |fullpath|
    file = File.basename(fullpath, '.bas')
    Rake::Task['compile_bas'].execute(program: file)
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

desc 'convert & run basic program'
task :start_basic, :program do |_, args|
  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  Rake::Task['compile_bas'].execute(program: file)
  cmd = %{#{EMULATOR_PATH}
    -basicload #{File.join(BUILD_DIR, "#{file}.prg")}
  }.split.join(" ")
  sh cmd
end

desc 'compile & debug program'
task :debug, :program do |_, args|
  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  sh "killall C64\ Debugger || true"
  Rake::Task['compile_asm'].execute(program: file)
  sh %{#{DEBUGGER_PATH}
    -prg #{File.join(BUILD_DIR, "#{file}.prg")}
    -pass -unpause -autojmp -wait 3000
    #{OPTIONS}
  }.split.join(" ")
end

desc 'compile & test program'
task :test, :program do |_, args|
  file = args[:program] || ENV["PROGRAM"] || PROGRAM

  options = %{:on_exit=jam
    :write_final_results_to_file=true
    :result_file_name=#{file}.specOut
  }
  Rake::Task['compile_asm'].execute(program: file, options: options)
  cmd = %{#{EMULATOR_PATH}
    -autostart build/#{file}.prg
    -warp
    -jamaction 5
    -console
    -autostartprgmode 0
    #{OPTIONS}
  }.split.join(" ")
  sh cmd

  sh "petcat build/#{file}.specOut"
end

desc 'list available programs'
task :list_programs do
  puts "Available programs !(name and its full path):"

  all = []
  Dir[File.join('src', '*.{c,s,bas}')].each do |fullpath|
    file = File.basename(fullpath, '.*')
    all << {file: file, fullpath: fullpath}
  end

  padding = all.map { |f| f[:file].size }.max
  all.each do |f|
    puts "  #{f[:file].ljust(padding + 1)} #{f[:fullpath]}"
  end
end
task default: :start