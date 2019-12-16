# Random Entity Generator extension for SketchUp 2017 or newer.
# Copyright: © 2019 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

raise 'The REG plugin requires at least Ruby 2.2.0 or SketchUp 2017.'\
  unless RUBY_VERSION.to_f >= 2.2 # SketchUp 2017 includes Ruby 2.2.4.

require 'sketchup'

# REG plugin namespace.
module REG

  # Bitmap parser. XXX Algorithm comes from Spirix BMP Tracer plugin for SU.
  #
  # @see https://sites.google.com/site/spirixcode/code/spirix_bmp_tracer.rbz
  class Bitmap

    attr_reader :colors, :width, :height

    def initialize(filename)

      @colors = []

      data = File.open(filename, 'rb')

      t = data.read(54).unpack('C54')

      @width = t[19].to_i * 256 + t[18].to_i
      @height = t[23].to_i * 256 + t[22].to_i

      fo = t[11].to_i * 256 + t[10].to_i

      if fo != 54
        v = fo - 54
        t = data.read(v).unpack('C' + v.to_s)
      end

      padding = (@width * 3) & 3

      if padding != 0
        padding = 4 - padding
      end

      for y in 0...@height do

        t = data.read(@width * 3 + padding).unpack('C' + (@width * 3).to_s)

        for x in 0...@width do

          @colors.push(

            Sketchup::Color.new([

              t[3 * x + 2].to_i, # Red
              t[3 * x + 1].to_i, # Green
              t[3 * x].to_i # Blue

            ])

          )

        end

      end

      data.close

    end

  end

end