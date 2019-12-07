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

  # Grid of points.
  module PointGrid

    # Returns a point grid for a face.
    #
    # @param [Sketchup::Face] face
    # @param [Integer] grid_size
    #
    # @raise [StandardError]
    #
    # @return [Array<Geom::Point3d>]
    def self.face(face, grid_size = 10)

      face_vertices = face.vertices

      if face_vertices.size != 4

        raise StandardError.new('Only quad faces are supported.')

      end

      lc_points_x = []
      lc_points_y = []

      face_point_grid = []

      start_lc_count = 0
      end_lc_count = grid_size

      grid_size.times do

        start_lc_count += 1
        end_lc_count -= 1

        lc_points_x.push(Geom.linear_combination(
          start_lc_count.to_f / grid_size,
          face_vertices.first.position,
          end_lc_count.to_f / grid_size,
          face_vertices.last.position
        ))

        lc_points_y.push(Geom.linear_combination(
          start_lc_count.to_f / grid_size,
          face_vertices[1].position,
          end_lc_count.to_f / grid_size,
          face_vertices[2].position
        ))

      end

      lc_point_index = 0

      lc_points_y.size.times do

        start_lc_count = 0
        end_lc_count = grid_size

        grid_size.times do

          start_lc_count += 1
          end_lc_count -= 1

          face_point_grid.push(Geom.linear_combination(
            start_lc_count.to_f / grid_size,
            lc_points_x[lc_point_index],
            end_lc_count.to_f / grid_size,
            lc_points_y[lc_point_index]
          ))

        end

        lc_point_index += 1

      end

      face_point_grid

    end

    # Returns a point grid for a group or component.
    #
    # @param [Sketchup::Group|Sketchup::ComponentInstance] grouponent
    # @raise [ArgumentError]
    #
    # @param [Integer] grid_size
    #
    # @return [Array<Geom::Point3d>]
    def self.grouponent(grouponent, grid_size = 10)

      raise ArgumentError, 'Grouponent parameter is invalid.'\
        unless grouponent.is_a?(Sketchup::Group)\
          || grouponent.is_a?(Sketchup::ComponentInstance)

      grouponent_transformation = grouponent.transformation

      grouponent_point_grid = []

      if grouponent.is_a?(Sketchup::Group)

        grouponent_faces = grouponent.entities.grep(Sketchup::Face)

      else # if grouponent.is_a?(Sketchup::ComponentInstance)

        grouponent_faces = grouponent.definition.entities.grep(Sketchup::Face)

      end

      grouponent_faces.each { |grouponent_face|

        not_trans_point_grid = face(grouponent_face, grid_size)

        transformed_point_grid = []

        not_trans_point_grid.each { |not_trans_point|

          transformed_point_grid.push(
            not_trans_point.transform!(grouponent_transformation)
          )

        }

        grouponent_point_grid.concat(transformed_point_grid)

      }

      grouponent_point_grid

    end

  end

end
