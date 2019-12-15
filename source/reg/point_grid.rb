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

    # Returns a point grid for an image.
    # XXX White pixels are considered as holes.
    #
    # @param [String] image_path
    # @param [Integer] cm_per_pixel
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    #
    # @return [Array<Geom::Point3d, Geom::Vector3d>]
    def self.image(image_path, cm_per_pixel = 100)

      if Sketchup.version.to_i < 18

        raise StandardError.new(
          TRANSLATE['This function requires SketchUp 2018 or newer.']
        )

      end

      raise ArgumentError, 'Image Path parameter is invalid.'\
        unless image_path.is_a?(String)

      raise ArgumentError, 'Cm Per Pixel parameter is invalid.'\
        unless cm_per_pixel.is_a?(Integer)

      inches_per_pixel = cm_per_pixel.to_s.concat('cm').to_l

      image = Sketchup::ImageRep.new

      image.load_file(image_path)

      if image.width > 316 || image.height > 316

        raise StandardError.new(
          TRANSLATE['Image must be a maximum of 316 x 316 pixels.']
        )

      end

      image_colors_xy = []

      for image_color_index in 1..image.colors.size do

        if image_color_index % image.width == 0

          image_colors_xy.push(
            image.colors[image_color_index-image.width...image_color_index]
          )
          
        end

      end

      image_point_grid = []

      image_point_x = 0
      image_point_y = 0

      image_colors_xy.each do |image_color_x|

        image_color_x.each do |image_color_y|

          image_point_y += inches_per_pixel
          
          next if image_color_y.red == 255 && image_color_y.green == 255\
            && image_color_y.blue == 255

          image_point_grid.push([
            Geom::Point3d.new(image_point_x, image_point_y, 0),
            Z_AXIS
          ])

        end

        image_point_x += inches_per_pixel

        image_point_y = 0

      end

      image_point_grid

    end

  end

end
