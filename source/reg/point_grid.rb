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
require 'reg/bitmap'

# REG plugin namespace.
module REG

  # Grid of points.
  module PointGrid

    # Returns a point grid for a face with normal.
    #
    # @param [Sketchup::Face] face
    # @param [Integer] grid_size
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    #
    # @return [Array<Geom::Point3d, Geom::Vector3d>]
    def self.face(face, grid_size = 10)

      raise ArgumentError, 'Face parameter is invalid.'\
        unless face.is_a?(Sketchup::Face)

      raise ArgumentError, 'Grid Size parameter is invalid.'\
        unless grid_size.is_a?(Integer)

      face_vertices = face.vertices

      if face_vertices.count != 3 && face_vertices.count !=4

        raise StandardError.new('Only triangles and quad faces are supported.')

      end

      face_normal = face.normal

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

          face_point = Geom.linear_combination(
            start_lc_count.to_f / grid_size,
            lc_points_x[lc_point_index],
            end_lc_count.to_f / grid_size,
            lc_points_y[lc_point_index]
          )

          next if PARAMETERS[:entity_max_altitude] != 0\
            && face_point.z > PARAMETERS[:entity_max_altitude]

          face_point_grid.push(
            [
              face_point,
              face_normal
            ]
          )

        end

        lc_point_index += 1

      end

      face_point_grid

    end

    # Returns a point grid for a group or component with face normal.
    #
    # @param [Sketchup::Group|Sketchup::ComponentInstance] grouponent
    # @param [Integer] grid_size
    # @raise [ArgumentError]
    #
    # @return [Array<Geom::Point3d, Geom::Vector3d>]
    def self.grouponent(grouponent, grid_size = 10)

      raise ArgumentError, 'Grouponent parameter is invalid.'\
        unless grouponent.is_a?(Sketchup::Group)\
          || grouponent.is_a?(Sketchup::ComponentInstance)

      raise ArgumentError, 'Grid Size parameter is invalid.'\
        unless grid_size.is_a?(Integer)

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

    # Returns a point grid for a bitmap image.
    # XXX White pixels are considered as holes.
    #
    # @param [String] image_path
    # @param [Integer] cm_per_pixel
    # @param [Integer] z_layers
    # @param [Integer] z_interval
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    #
    # @return [Array<Geom::Point3d, Geom::Vector3d>]
    def self.bitmap(image_path, cm_per_pixel, z_layers, z_interval)

      raise ArgumentError, 'Image Path parameter is invalid.'\
        unless image_path.is_a?(String)

      raise ArgumentError, 'Cm Per Pixel parameter is invalid.'\
        unless cm_per_pixel.is_a?(Integer)

      raise ArgumentError, 'Z Layers parameter is invalid.'\
        unless z_layers.is_a?(Integer)

      raise ArgumentError, 'Z Interval parameter is invalid.'\
        unless z_interval.is_a?(Integer)

      inches_per_pixel = cm_per_pixel.to_s.concat('cm').to_l

      inches_z_interval = z_interval.to_s.concat('cm').to_l

      bitmap = Bitmap.new(image_path)

      if bitmap.width > 1024 || bitmap.height > 1024

        raise StandardError.new(
          TRANSLATE['Image must be a maximum of 1024 x 1024 pixels.']
        )

      end

      bitmap_colors_xy = []

      for bitmap_color_index in 1..bitmap.colors.size do

        if bitmap_color_index % bitmap.width == 0

          bitmap_colors_xy.push(
            bitmap.colors[bitmap_color_index-bitmap.width...bitmap_color_index]
          )
          
        end

      end

      bitmap_point_grid_2d = []

      bitmap_point_x = 0
      bitmap_point_y = 0

      bitmap_colors_xy.each do |bitmap_color_x|

        bitmap_color_x.each do |bitmap_color_y|

          bitmap_point_y += inches_per_pixel
          
          next if bitmap_color_y.red == 255 && bitmap_color_y.green == 255\
            && bitmap_color_y.blue == 255

          bitmap_point_grid_2d.push([
            Geom::Point3d.new(bitmap_point_x, bitmap_point_y, 0),
            Z_AXIS
          ])

        end

        bitmap_point_x += inches_per_pixel

        bitmap_point_y = 0

      end

      return bitmap_point_grid_2d if z_layers == 1

      bitmap_point_grid_3d = []

      bitmap_point_z = 0

      z_layers.times do

        bitmap_point_grid_2d.each do |point_and_normal|

          point = point_and_normal[0]

          normal = point_and_normal[1]

          new_point = Geom::Point3d.new(
            point.x,
            point.y,
            bitmap_point_z
          )

          bitmap_point_grid_3d.push([
            new_point,
            normal
          ])

        end

        bitmap_point_z += inches_z_interval

      end

      bitmap_point_grid_3d

    end

  end

end
