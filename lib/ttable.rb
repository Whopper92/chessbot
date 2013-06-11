#! /usr/bin/ruby

require File.expand_path('../ttableEntry.rb', __FILE__)
require File.expand_path('../zobristTable.rb', __FILE__)


class Ttable

# array of TtableEntry
# Constructor initializes

  def initialize
    tTableEntryArray = Array.new(65536){ TtableEntry.new }
  end
end
