#!/usr/bin/env ruby
# Encoding: UTF-8

##
##     Sticky Notes PDF Exporter 2016.6.20
##     Copyright (c) 2016 Renato Silva
##     GNU GPLv2 licensed
##
## Usage: @script.name [options] TARGET
##
##     -r, --remove    Remove TARGET before exporting
##

require 'fileutils'
require 'tmpdir'
require 'easyoptions'

unless EasyOptions.arguments[0]
    puts EasyOptions.documentation
    exit 1
end

def merge_rtf(result, files)
    line = /(\r\n|\r|\n)/
    tail = /#{line}\}#{line}.+$/m
    joint = /#{line}\}#{line}\{\\rtf1\\[^\r\n]*#{line}/m
    generator = /\{\\\*\\Generator [^\}]+\}/
    raw = files.map do |file|
        raw = File.open(file).read
        raw.gsub!(tail, "\\1}\\1")
        raw.gsub(generator, "")
    end.join
    result = File.open(result, 'w')
    result.write(raw.gsub(joint, "\\1\\page\\1"))
    result.close
end

target = File.expand_path(EasyOptions.arguments[0].sub(/(\.pdf)?$/i, '.pdf'))
FileUtils.safe_unlink(target) if EasyOptions.options[:remove]
Notes = "#{ENV['APPDATA']}/Microsoft/Sticky Notes/StickyNotes.snt"

Dir.mktmpdir('notestopdf') do |temporary|
    notes = "#{temporary}/notes"
    FileUtils.copy(Notes, "#{notes}.snt")
    system("7z x -y -ir!0 -o'#{notes}' '#{notes}.snt'", :out => File::NULL) or exit 1
    if File.directory?(notes)
        merge_rtf("#{notes}.rtf", Dir["#{notes}/*/0"])
        rtf = `cygpath --windows '#{notes}.rtf'`.strip
        target = `cygpath --windows '#{target}'`.strip
        script = <<-DONE
            $word = New-Object -ComObject "word.application"
            $rtf  = $word.documents.open("#{rtf}")
            $rtf.SaveAs("#{target}", 17)
            ps winword | kill
        DONE
        system("powershell -command '#{script}'") or exit 1
    end
end
