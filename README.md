# feh-hsdarcwriter

`Feh::HSDArcWriter` is an interface for generating files in the HSDArc file
format used by Fire Emblem Heroes.

## Installation

```ruby
$ gem install feh-hsdarcwriter
```

## Example

The following script generates an HSDArc file _equivalent_ to
`assets/Common/SRPG/Move.bin` as of FEH version 2.9.1:

```ruby
#!/usr/bin/env ruby

require 'feh/hsdarc_writer'

MVMTS = [
  {id_tag: 'MVID_歩行', range: 2, costs: [
     1,  1,  1,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  1,
     1,  2,  1, -1, -1, -1,  1,  1,  1,  1, -1,  1,  1,  1,  1,  1,
     1, -1, -1]},
  {id_tag: 'MVID_重装', range: 1, costs: [
     1,  1,  1,  1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  1,
     1,  1,  1, -1, -1, -1,  1,  1,  1,  1, -1,  1,  1,  1,  1,  1,
     1, -1, -1]},
  {id_tag: 'MVID_騎馬', range: 3, costs: [
     1,  1,  1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  1,
     1, -1,  1, -1, -1, -1,  3,  3,  3,  3, -1,  1,  1,  1,  1,  1,
     1, -1, -1]},
  {id_tag: 'MVID_飛行', range: 2, costs: [
     1,  1,  1,  1,  1,  1,  1,  1, -1, -1, -1, -1, -1, -1, -1,  1,
     1,  1,  1, -1, -1, -1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1, -1, -1]},
]

writer = Feh::HSDArcWriter.new
writer.ptr do |blk|
  MVMTS.each_with_index do |mvmt, index|
    blk.string(mvmt[:id_tag], Feh::HSDArcWriter::XORKeys::ID_XORKEY)
    blk.ptr {|costs| costs.i8(mvmt[:costs], 0xB8)}
    blk.i32(index, 0xD5025852)
    blk.i8(mvmt[:range], 0x80)
  end
end
writer.i64(MVMTS.size, 0x20A10C408924170E)

IO.binwrite('Move.bin', writer.hsdarc.pack('c*'))

# if Feh::Bin is available:
# require 'feh/bin'
# IO.binwrite('Move.bin.lz', Feh::Bin.compress(writer.hsdarc).pack('c*'))
```

## Changelog

### V0.1.1

- `Feh::HSDArcWriter#string` now accepts a nil string and writes a null pointer

### V0.1.0

- Initial release

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
