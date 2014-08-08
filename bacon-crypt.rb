#!/usr/bin/env ruby
# Encoding: ISO-8859-1

##
##     Base Conversion Cryptography 2014.8.8
##     Copyright (c) 2013 Renato Silva
##     GNU GPLv2 licensed
##
## Usage: @script.name [options], where options are:
##
##         --key=FILE                Use this FILE for the actions below.
##     -c, --create                  Create a new cryptography key and save it
##                                   to the file specified by the --key option.
##
##         --encode=STRING           Encode STRING and print the result.
##         --decode=STRING           Decode STRING and print the result.
##         --decode-text=STRING      Decode STRING and print the result as text.
##
##         --encode-file=FILE        Encode FILE and save to FILE.bacon.
##         --decode-file=FILE.bacon  Decode FILE.bacon and save to FILE.
##
##     -v, --verbose                 Print progress information when encoding or
##                                   decoding files.
##         --encoding=ENCODING       Use ENCODING for FILE or STRING.
##     -l, --lines                   Add line breaks to encoded text.
##     -h, --help                    This help text.
##

require "base64"
require_relative "easyoptions"

class String
    def scan_digits(length=BiggestBase.length, digit_base=10, leading_zero=false, fixed_length=true)
        offset = leading_zero ? 0 : 1
        length = rand(2..length) if length > 2 and not fixed_length
        digits = self.scan(/(.{#{length - offset}}|.{1,#{length - offset}}$)/)
        non_zero = leading_zero ? "" : "1"
        digits.map { |item| "#{non_zero}#{item[0]}".to_i(digit_base) }
    end
    def zerofill(length=nil)
        length=BiggestBase.length if not length
        self.rjust(length, "0")
    end
    def decode64
        array = Base64.decode64(self).unpack("U*")
        Progress.done("Decoded from Base64")
        array
    end
end

class Array
    def zerofill(length=nil)
        self.map { |item| item.to_s.zerofill(length) }.join
    end
    def encode64
        base64 = $options[:lines].nil? ? Base64.strict_encode64(self.pack("U*")) : Base64.encode64(self.pack("U*"))
        Progress.done("Encoded to Base64")
        base64
    end
end

class Progress
    def initialize(message, maximum)
        @message = message
        @maximum = maximum
        @step = 0
    end
    def Progress.done(message)
        $stderr.puts("#{message}.") if $options[:verbose]
    end
    def next
        return unless $options[:verbose]
        @step += 1
        percentage = (100 * @step) / @maximum
        previous_percentage = (100 * (@step - 1)) / @maximum
        $stderr.print("\r#{@message}... #{percentage} % ") if percentage != previous_percentage
        $stderr.print("\r#{" " * (@message.length + 10)}\r") if @step == @maximum
    end
end

class Base
    def initialize(base, alphabet=(0..(base - 1)).to_a.shuffle)
        @value, @alphabet = base, alphabet
    end
    def to_this(integer)
        result = []
        begin
            result << @alphabet[integer % @value]
            integer = integer / @value
        end until integer == 0
        Progress.done("Converted from base 10")
        result.reverse
    end
    def to_10(digits)
        result = 0
        progress = Progress.new("Converting to base 10", digits.length)
        digits.reverse.each_with_index do |digit, index|
            digit_value = @alphabet.index(digit)
            result += digit_value * (@value ** index)
            progress.next
        end
        Progress.done("Converted to base 10")
        result
    end
    def length(base=10)
        Math.log(self.value, base).ceil
    end
    def bitlength
        Math.log2(self.value)
    end
    def to_s
        hexa_alphabet = @alphabet.map { |digit| digit.to_s(16).upcase }
        "#{@value.to_s.zerofill}=#{hexa_alphabet.zerofill(self.length(16))}"
    end
    attr_accessor :value
    attr_accessor :alphabet
end

DecodedBases = (2**14)..(2**16) # 16384..65536
EncodedBases = (2**10)..(2**12) # 1024..4096
BiggestBase  = Base.new([DecodedBases.max, EncodedBases.max].max)

class EncryptionKey
    def initialize(file_path=nil)
        if file_path == nil
            @decoded = Base.new(rand(DecodedBases))
            @encoded = Base.new(rand(EncodedBases))
        else
            lines = File.readlines(file_path)
            @decoded = parse_line(lines[0])
            @encoded = parse_line(lines[1])
        end
    end
    def parse_line(line)
        columns=line.split("=")
        base = Base.new(columns[0].to_i)
        base.alphabet = columns[1].scan_digits(base.length(16), 16, true)
        base
    end
    def to_s
        "#{@decoded}\n#{@encoded}"
    end
    attr_accessor :decoded
    attr_accessor :encoded
end

class BaseCrypt
    def initialize(file_path=nil)
        @key = EncryptionKey.new(file_path)
    end
    def encode(bytes)
        digits = to_digits(bytes)
        integer = @key.decoded.to_10(digits)
        digits = @key.encoded.to_this(integer)
        digits.encode64
    end
    def decode(string)
        digits = string.decode64
        integer = @key.encoded.to_10(digits)
        digits = @key.decoded.to_this(integer)
        to_bytes(digits).pack("C*")
    end
    def to_digits(bytes)
        bits = bytes.map { |byte| byte.to_s(2).zerofill(8) }.join
        digits = bits.scan_digits(@key.decoded.bitlength.floor, 2, false, false)
        Progress.done("Converted from bytes to digits")
        digits
    end
    def to_bytes(digits)
        bin_digits = digits.map { |digit| digit.to_s(2)[1..-1] }
        bytes = bin_digits.join.scan_digits(8, 2, true)
        Progress.done("Converted from digits to bytes")
        bytes
    end
    attr_accessor :key
end

if $options.empty? then
    puts $documentation
    exit
end

finish("--key is required") if not $options[:key]
finish("cannot decode while creating key") if $options[:create] and ($options[:decode] or $options[:decode_file])
finish("cannot specify multiple encoding actions") if [:encode, :encode_file].find_all { |option| not $options[option].nil? }.length > 1
finish("cannot specify multiple decoding actions") if [:decode, :decode_file, :decode_text].find_all { |option| not $options[option].nil? }.length > 1
finish("encoded file must have the bacon extension") if $options[:decode_file] and not $options[:decode_file].end_with?(".bacon")

$options[:decode] = $options[:decode_text] if $options[:decode_text]
$options[:encode] = File.open($options[:encode_file], "rb") { |io| io.read } if $options[:encode_file]
$options[:decode] = File.open($options[:decode_file], "rb") { |io| io.read } if $options[:decode_file]

if $options[:create] then
    bc = BaseCrypt.new
    file = File.open($options[:key], "w")
    file.puts(bc.key)
    file.close
end

if $options[:encode] then
    bc = BaseCrypt.new($options[:key])
    $options[:encode].force_encoding($options[:encoding]) if $options[:encoding]
    ciphertext = bc.encode($options[:encode].bytes)
    $stdout = File.open("#{$options[:encode_file]}.bacon", "w") if $options[:encode_file]
    $stdout.puts ciphertext
end

if $options[:decode] then
    bc = BaseCrypt.new($options[:key])
    decoded = bc.decode($options[:decode])
    decoded.force_encoding($options[:encoding]) if $options[:encoding]
    $stdout = File.open($options[:decode_file].sub(/\.bacon$/, ""), "wb") if $options[:decode_file]
    if $options[:decode_text] then
        $stdout.puts(decoded)
    else
        $stdout.binmode.write(decoded)
    end
end
