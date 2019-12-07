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

  # Transformations.
  module Transformations

    # Generates a random rotation transformation.
    #
    # @return [Geom::Transformation]
    def self.generate_random_rotation

      return Geom::Transformation.new unless PARAMETERS[:rotate_entities?]

      if PARAMETERS[:glue_ents_to_ground?] || !PARAMETERS[:rand_zone_min_x].nil?

        return Geom::Transformation.rotation(

          Geom::Point3d.new,

          Z_AXIS,

          rand(0...360).degrees

        )

      else

        density = PARAMETERS[:entity_density] * '1m'.to_l

        return Geom::Transformation.rotation(

          Geom::Point3d.new(
            rand(-density...density),
            rand(-density...density),
            rand(-density...density)
          ),

          Geom::Vector3d.new(rand(0.1...1), rand(0.1...1), rand(0.1...1)),

          rand(0...360).degrees

        )

      end

    end

    # Generates a random scaling transformation.
    #
    # @return [Geom::Transformation]
    def self.generate_random_scaling

      scale = rand(PARAMETERS[:entity_min_size]...PARAMETERS[:entity_max_size])

      if PARAMETERS[:entity_min_size] == PARAMETERS[:entity_max_size]

        scale = PARAMETERS[:entity_min_size]

      end

      Geom::Transformation.scaling(ORIGIN, scale)

    end

    # Generates a random translation transformation.
    #
    # @return [Geom::Transformation]
    def self.generate_random_translation

      if !PARAMETERS[:rand_zone_min_x].nil?

        if PARAMETERS[:rand_zone_min_x] != PARAMETERS[:rand_zone_max_x]

          x_translation = rand(
            PARAMETERS[:rand_zone_min_x]...
            PARAMETERS[:rand_zone_max_x]
          )

        else

          x_translation = PARAMETERS[:rand_zone_min_x]

        end

        if PARAMETERS[:rand_zone_min_y] != PARAMETERS[:rand_zone_max_y]

          y_translation = rand(
            PARAMETERS[:rand_zone_min_y]...
            PARAMETERS[:rand_zone_max_y]
          )

        else

          y_translation = PARAMETERS[:rand_zone_min_y]

        end

        if PARAMETERS[:rand_zone_min_z] != PARAMETERS[:rand_zone_max_z]

          z_translation = rand(
            PARAMETERS[:rand_zone_min_z]...
            PARAMETERS[:rand_zone_max_z]
          )

        else

          z_translation = PARAMETERS[:rand_zone_min_z]

        end

      else

        density = PARAMETERS[:entity_density] * '1m'.to_l

        x_translation = rand(-density...density)
        y_translation = rand(-density...density)
        z_translation = rand(-density...density)

      end
      
      if PARAMETERS[:glue_ents_to_ground?]

        z_translation = 0

      end

      Geom::Transformation.translation(

        Geom::Point3d.new(
          x_translation,
          y_translation,
          z_translation
        )

      )

    end

  end

end
