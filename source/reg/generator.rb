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

require 'reg/entities'
require 'reg/preview_tool'

# REG plugin namespace.
module REG

  # Main instance.
  class Generator

    # Generates random entities.
    #
    # @param [String] mode
    # @raise [ArgumentError]
    def initialize(mode)

      raise ArgumentError, 'Mode argument is invalid.'\
        unless mode =~ /^(validate|preview)$/

      model = Sketchup.active_model

      model.start_operation(
        TRANSLATE['Generate random entities'],
        true # disable_ui
      )

      Sketchup.status_text = TRANSLATE['Generating entities... Please wait.']

      generated_entities = []

      PARAMETERS[:entity_count].times do

        generated_entities.push(Entities.generate_random)

      end

      if PARAMETERS[:avoid_ent_collision?]

        # FIXME: Why these param. are incompatible?
        if PARAMETERS[:rand_zone_point_grid].empty?

          5.times do

            collided_entities = Entities.collision_detect(generated_entities)

            collided_entities.each { |collided_entity|

              Entities.randomize(collided_entity)

            }

          end

        end

        model.active_entities.erase_entities(
          Entities.collision_detect(generated_entities)
        )

      end

      if mode == 'preview'

        SESSION[:bound_boxes_to_preview] = []

        generated_entities.each { |generated_entity|

          SESSION[:bound_boxes_to_preview].push(generated_entity.bounds)

        }

        model.active_entities.erase_entities(generated_entities)

        model.select_tool(PreviewTool.new)

        # XXX This “hack” debugs preview.
        model.active_view.refresh
        Sketchup.send_action('viewTop:')
        model.active_view.zoom_extents

      end

      model.commit_operation

      Sketchup.status_text = nil

    end

  end

end
