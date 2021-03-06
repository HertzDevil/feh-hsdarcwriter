#!/usr/bin/env ruby

module Feh
  class HSDArcWriter
    module XORKeys
      # Produces a XOR cipher from an internal key.
      # @param key [Array<Integer>] byte values of the internal key
      # @return [Array<Integer>] content of the XOR cipher
      def self.make_cipher(key)
        k = (key[0] + key[1]) & 0xFF
        cipher = []
        key.each do |x|
          k ^= x
          cipher << k
        end
        key.each do |x|
          k ^= x
          cipher << k
        end
        cipher
      end

      # XOR cipher used for almost all asset files.
      ID_XORKEY = make_cipher([
        0x40, 0x81, 0x80, 0x24, 0xFE, 0x4C, 0x79, 0x17, 0x2F,
        0xD6, 0xAC, 0xDA, 0x0B, 0x9A, 0x69, 0x28, 0x52,
      ]).freeze

      # XOR cipher used for message files.
      MSG_XORKEY = make_cipher([
        0x58, 0xDF, 0x3F, 0x59, 0x39, 0x85, 0x30, 0xB1, 0x2D,
        0xB0, 0x80, 0x13, 0xB3, 0xCB, 0x25, 0xB0, 0xE8, 0x5D,
        0x2E, 0x29, 0xBF, 0xC9, 0xEA, 0x70, 0x33, 0x7B, 0xE6,
        0xD3, 0xD2,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Tutorial/`.
      TUT_XORKEY = make_cipher([
        0x0B, 0x76, 0x02, 0xC7, 0x63, 0x1F, 0xDD, 0x15, 0xE3,
        0x90, 0x7E, 0x4E, 0xC6, 0x7C, 0x60, 0x81, 0x7A, 0x94,
      ]).freeze

      # XOR cipher used for files under `assets/Common/SRPG/StageBgm/`.
      BGM_XORKEY = make_cipher([
        0xE0, 0xAF, 0xF7, 0x8B, 0x7B, 0xA8, 0x6B, 0x3F, 0x55,
        0x15, 0x0D, 0xCE, 0x7F, 0xE9, 0x20, 0x0F, 0xE7, 0x82,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Occupation/World/`.
      GC_XORKEY = make_cipher([
        0x56, 0xEB, 0x35, 0x23, 0x93, 0x10, 0x4D, 0x99, 0x19,
        0xF0, 0x5A, 0x56, 0xE5, 0x36, 0xBD, 0xFB, 0x62, 0x1B,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Tournament/`.
      VG_XORKEY = make_cipher([
        0xD7, 0x76, 0x02, 0xC7, 0xA8, 0x1F, 0x5C, 0x80, 0xE3,
        0x2C, 0x7E, 0x4E, 0xC6, 0x0C, 0x94, 0x15, 0x7A, 0x60,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Portrait/`.
      FB_XORKEY = make_cipher([
        0x04, 0x27, 0x6E, 0x8B, 0x91, 0xE4, 0xAC, 0x1E, 0xCE,
        0x48, 0xED, 0x90, 0x34, 0xFA, 0xCD, 0x8C, 0x76, 0x1A,
        0x44, 0xA8, 0x59, 0x8D, 0xAD, 0x5E, 0xBD, 0x6C, 0x0E,
        0xE1, 0xE2,
      ]).freeze

      # XOR cipher used for files under `assets/Common/LoginBonus/`.
      LOGIN_XORKEY = make_cipher([
        0xA9, 0xBB, 0xE3, 0xE8, 0x07, 0x8F, 0x46, 0xB8, 0xED,
        0x2F, 0xF0, 0x4B, 0x8E, 0x62, 0x7C, 0x91, 0x4E, 0x0C,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Summon/`.
      SUMMON_XORKEY = make_cipher([
        0x87, 0x1C, 0xC0, 0xF8, 0x4C, 0xAC, 0xCE, 0x0D, 0x50,
        0xF0, 0x6C, 0x2B, 0x40, 0x0B, 0x7B, 0x1D, 0x3B, 0x77,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Home/`.
      HOME_XORKEY = make_cipher([
        0xE3, 0x17, 0xC8, 0xEF, 0x87, 0x81, 0x71, 0x52, 0xBC,
        0x66, 0x38, 0xBD, 0xFB, 0x5B, 0x79, 0xF1, 0xE3, 0xE1,
      ]).freeze

      # XOR cipher used for `assets/Common/Loading/Data.bin`.
      LOADING_XORKEY = make_cipher([
        0x73, 0x76, 0xEF, 0xC7, 0xC5, 0x1F, 0x5C, 0x80, 0xE3,
        0x70, 0x7E, 0x53, 0xC6, 0xD7, 0x94, 0x15, 0x7A, 0x60,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Battle/Asset/`.
      BATTLE_XORKEY = make_cipher([
        0x01, 0x6F, 0x1A, 0xF1, 0xB2, 0x3D, 0x66, 0xBE, 0x9C,
        0x76, 0x73, 0xE3, 0x4D, 0x1C, 0xA1, 0x7A, 0x1D, 0x41,
        0x19, 0x20, 0x33, 0xC6, 0x85, 0xA6,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Effect/arc/`.
      EFFECT_ARC_XORKEY = make_cipher([
        0x0B, 0x44, 0x35, 0xF4, 0x3E, 0xEB, 0xDC, 0x59, 0x62,
        0xED, 0x01, 0x74, 0xA7, 0xA8, 0x3D, 0x81, 0x64, 0x7C,
      ]).freeze

      # XOR cipher used for files under `assets/Common/Sound/arc/`.
      SOUND_ARC_XORKEY = make_cipher([
        0x30, 0x3A, 0x10, 0xF0, 0x21, 0x33, 0x9E, 0xF9, 0xD2,
        0xA5, 0x10, 0xCA, 0x42, 0x90, 0xDC, 0x2C, 0x3C, 0x81,
      ]).freeze
    end
  end
end
