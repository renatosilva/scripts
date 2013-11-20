#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# Base Conversion Cryptography 2013.11.20
# Copyright (c) 2013 Renato Silva
# GNU GPLv2 licensed

require "base64"

class String
    def scan_digits(base=BiggestBase)
        self.scan(/(.{#{base.length}}|.{1,#{base.length}}$)/).map { |item| item[0].to_i }
    end
    def zerofill(base=BiggestBase)
        self.rjust(base.length, "0")
    end
    def decode64
        Base64.decode64(self).unpack("U*")
    end
end

class Array
    def zerofill
        self.map { |item| item.to_s.zerofill }.join
    end
    def encode64
        Base64.encode64(self.pack("U*"))
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
        result.reverse
    end
    def to_10(digits)
        result = 0
        digits.reverse.each_with_index do |digit, index|
            digit_value = @alphabet.index(digit)
            result += digit_value * (@value ** index)
        end
        result
    end
    def length
        Math.log10(self.value).ceil
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
            @decoded = Base.new(lines[0].split[0].to_i, lines[0].split[1].scan_digits)
            @encoded = Base.new(lines[1].split[0].to_i, lines[1].split[1].scan_digits)
        end
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
        @key.decoded.to_this(integer).pack("C*")
    end
    def to_digits(bytes)
        # To be implemented
        bytes
    end
    attr_accessor :key
end

case ARGV[0]
    when "new-key" then
        bc = BaseCrypt.new
        file = File.open(ARGV[1], "w")
        file.puts("#{bc.key.decoded.value.to_s.zerofill} #{bc.key.decoded.alphabet.zerofill}")
        file.puts("#{bc.key.encoded.value.to_s.zerofill} #{bc.key.encoded.alphabet.zerofill}")
        file.close
    when "encode" then
        bc = BaseCrypt.new(ARGV[1])
        puts bc.encode(ARGV[2].bytes)
    when "decode" then
        bc = BaseCrypt.new(ARGV[1])
        decoded = bc.decode(ARGV[2])
        decoded.force_encoding(ARGV[3]) if ARGV[3]
        puts decoded
    when "--help", "-h", nil then
        puts "Base Conversion Cryptography"
        puts "Usage: #{File.basename($0)} encode|decode <key file> <text> [encoding]"
        puts "       #{File.basename($0)} new-key <file path>"
end
