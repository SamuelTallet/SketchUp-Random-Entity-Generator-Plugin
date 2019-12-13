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

  # Preview draw tool.
  class PreviewTool

    # Draws a bounding box in view.
    #
    # @return [nil]
    def draw_bounding_box(bounding_box)

      bb_points = (0..7).map { |bb_corner_index|

        bounding_box.corner(bb_corner_index)

      }

      @view.draw_polyline(
        [bb_points[0], bb_points[2], bb_points[3], bb_points[1]]
      )

      @view.draw_polyline(
        [bb_points[0], bb_points[4], bb_points[5], bb_points[1]]
      )

      @view.draw_polyline(
        [bb_points[0], bb_points[4], bb_points[6], bb_points[2]]
      )

      @view.draw_polyline(
        [bb_points[2], bb_points[6], bb_points[7], bb_points[3]]
      )

      @view.draw_polyline(
        [bb_points[3], bb_points[7], bb_points[5], bb_points[1]]
      )

      @view.draw_polyline(
        [bb_points[4], bb_points[6], bb_points[7], bb_points[5]]
      )

      nil

    end

    # Draws bounding boxes to preview in view.
    #
    # @return [Sketchup::View]
    def draw(view)

      return if SESSION[:bound_boxes_to_preview] == nil

      @view = view

      @view.drawing_color = Sketchup::Color.new(170, 0, 0)
      @view.line_width = 2

      SESSION[:bound_boxes_to_preview].each do |bound_box_to_preview|

        draw_bounding_box(bound_box_to_preview)

      end

      @view

    end

  end

end
