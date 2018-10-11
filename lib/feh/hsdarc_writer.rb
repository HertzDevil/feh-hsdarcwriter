#!/usr/bin/env ruby

require 'feh/hsdarc_writer/version'
require 'feh/hsdarc_writer/xor_keys'

module Feh
  # A class that builds well-formed HSDArc files used in Fire Emblem Heroes.
  #
  # Duplicate strings are currently stored like any other sub-block and not
  # optimized; the compiled HSDArc data might not be byte-for-byte identical to
  # the original asset files.
  class HSDArcWriter
    def initialize
      @buf = []
      @subblocks = []
    end

    # @return [Array<Integer>] the relocatable pointer list
    def reloc_ptrs
      @subblocks.map(&:first)
    end

    # Writes 8-bit integers.
    # @param x [Integer, Array<Integer>] the integer value(s)
    # @param xor [Integer] XOR value
    # @return [HSDArcWriter] self
    def i8(x, xor = 0)
      int(x, 1, xor)
    end

    # Writes 16-bit integers.
    # @param x [Integer, Array<Integer>] the integer value(s)
    # @param xor [Integer] XOR value
    # @return [HSDArcWriter] self
    def i16(x, xor = 0)
      int(x, 2, xor)
    end

    # Writes 32-bit integers.
    # @param x [Integer, Array<Integer>] the integer value(s)
    # @param xor [Integer] XOR value
    # @return [HSDArcWriter] self
    def i32(x, xor = 0)
      int(x, 4, xor)
    end

    # Writes 64-bit integers.
    # @param x [Integer, Array<Integer>] the integer value(s)
    # @param xor [Integer] XOR value
    # @return [HSDArcWriter] self
    def i64(x, xor = 0)
      int(x, 8, xor)
    end

    # Writes boolean values.
    # @param b [Object, Array<Object>] the boolean value(s), only truthiness is
    #   considered
    # @param xor [Integer] XOR value
    # @return [HSDArcWriter] self
    def bool(b, xor = 0)
      i8(b ? 1 : 0, xor)
    end

    # Writes an XOR-encrypted string. The resulting string is always zero-padded
    # to align on 64-bit boundaries.
    # @param str [String] UTF-8 string
    # @param xor [Array<Integer>] optional XOR cipher to use, writes unencrypted
    #   strings by default
    # @return [HSDArcWriter] self
    def xor_str(str, xor = [0])
      align(8)
      bytes = str.bytes.zip(xor.cycle).map {|x, y| x != y ? x ^ y : x}
      bytes += [0] * (8 - bytes.size % 8)
      @buf += bytes
      self
    end

    # Creates a pointer to an XOR-encrypted string.
    # @param str [String, nil] UTF-8 string, writes a null pointer instead if
    #   equal to **nil**
    # @param xor [Array<Integer>] optional XOR cipher to use, writes unencrypted
    #   strings by default
    # @return [HSDArcWriter] self
    def string(str, xor = [0])
      str.nil? ? nullptr : ptr {|blk| blk.xor_str(str, xor)}
    end

    # Writes a null pointer.
    # @return [HSDArcWriter] self
    def nullptr
      i64(0)
    end

    # Writes a pointer that points to a new block.
    # @yieldparam blk [HSDArcWriter] the sub-block object
    # @return [HSDArcWriter] self
    def ptr(&block)
      blk = self.class.new
      block.(blk)
      align(8)
      @subblocks << [@buf.size, blk]
      nullptr
    end

    # Compiles the data section of the HSDArc file.
    # @return [Array<Integer>] Content of the data section
    def compile
      hsdarc_impl.first
    end

    # Compiles the whole HSDArc file.
    # @return [Array<Integer>] Content of the HSDArc file
    def hsdarc
      bin, reloc = hsdarc_impl
      total_size = 0x20 + bin.size + reloc.size * 8
      header = [total_size, reloc.empty? ? 0 : bin.size, reloc.size, 0, 0, 1, 0, 0]
        .pack('l<*').bytes
      header + bin + reloc.pack('q<*').bytes
    end

    # Aligns the data pointer.
    # @param x [Integer] alignment byte count
    # @return [HSDArcWriter] self
    def align(x)
      @buf += [0] * ((-@buf.size) % x)
      self
    end

  private
    def int(x, len, xor = 0)
      align(len)
      if x.is_a?(Array)
        x.map! {|y| y ^ xor}
        x.each {|y| @buf += Array.new(len) {|i| (y >> (i * 8)) & 0xFF}}
      else
        x ^= xor
        @buf += Array.new(len) {|i| (x >> (i * 8)) & 0xFF}
      end
      self
    end

    def self.replace_ptr(arr, pos, x)
      x += arr[pos, 8].pack('c*').unpack('q<').first
      arr[pos, 8] = Array.new(8) {|i| (x >> (i * 8)) & 0xFF}
      nil
    end

    def hsdarc_impl
      bin = @buf.dup
      bin += [0] * ((-bin.size) % 8)
      reloc = reloc_ptrs

      @subblocks.each do |pos, blk|
        s = bin.size
        bin2 = blk.compile
        reloc2 = blk.reloc_ptrs
        reloc2.map! {|x| x + s}
        bin += bin2
        reloc2.each {|x| self.class.replace_ptr(bin, x, s)}
        reloc += reloc2
        self.class.replace_ptr(bin, pos, s)
      end

      bin += [0] * ((-bin.size) % 8)
      [bin, reloc]
    end
  end
end
