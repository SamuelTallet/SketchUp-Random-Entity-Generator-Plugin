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
require 'reg/transform'
require 'reg/shapes'
require 'reg/materials'
require 'reg/preview_tool'

# REG plugin namespace.
module REG

  # Entities.
  module Entities
    
    # Randomizes selected entities.
    #
    # @param [String] mode
    # @raise [ArgumentError]
    #
    # @return [nil]
    def self.randomize_selection(mode)

      raise ArgumentError, 'Mode argument is invalid.'\
        unless mode =~ /^(validate|preview)$/

      model = Sketchup.active_model
      selected_grouponents = []

      model.selection.each { |selected_entity|

        if selected_entity.is_a?(Sketchup::Group)\
         || selected_entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(selected_entity)

        end

      }

      if selected_grouponents.empty?

        UI.messagebox(TRANSLATE['No group nor component found in selection.'])
        return

      end

      model.start_operation(
        TRANSLATE['Randomize selected entities'],
        true # disable_ui
      )

      Sketchup.status_text = TRANSLATE['Randomizing entities... Please wait.']

      entities = []

      PARAMETERS[:entity_count].times do

        entities.push(randomize(clone_grouponent(selected_grouponents.sample)))

      end

      post_processing(entities, mode)

      model.commit_operation

      Sketchup.status_text = nil

      nil

    end

    # Clones a group or component.
    #
    # @param [Sketchup::Group|Sketchup::ComponentInstance]
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Group|Sketchup::ComponentInstance]
    def self.clone_grouponent(original_grouponent)

      raise ArgumentError, 'Grouponent parameter is invalid.'\
        unless original_grouponent.is_a?(Sketchup::Group)\
          || original_grouponent.is_a?(Sketchup::ComponentInstance)

      if original_grouponent.is_a?(Sketchup::Group)

        cloned_grouponent = original_grouponent.copy
        cloned_grouponent.material = original_grouponent.material
      
      else # if original_grouponent.is_a?(Sketchup::ComponentInstance)

        cloned_grouponent = Sketchup.active_model.entities.add_instance(
          original_grouponent.definition,
          Geom::Transformation.new
        )

        material_name = cloned_grouponent.definition.get_attribute(
          Proxies::ATTR_DICT_NAME, :MaterialName
        )

        if !material_name.nil?

          cloned_grouponent.material = Sketchup.active_model.materials[
            material_name
          ]

        end

      end

      cloned_grouponent

    end

    # Randomizes an entity's characteristics.
    #
    # @param [Sketchup::Entity] entity
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Entity]
    def self.randomize(entity)

      raise ArgumentError, 'Entity parameter must be a Sketchup::Entity.'\
        unless entity.is_a?(Sketchup::Entity)

      entity.transform!(Transformations.generate_random_rotation)

      entity.transform!(Transformations.generate_random_scaling(entity))

      entity.transform!(Transformations.generate_random_translation)

      if PARAMETERS[:overwrite_ent_colors?]

        randomize_color(entity)

      end

      entity

    end

    # Randomizes an entity's color.
    #
    # @param [Sketchup::Entity] entity
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Entity]
    def self.randomize_color(entity)

      raise ArgumentError, 'Entity parameter must be a Sketchup::Entity.'\
        unless entity.is_a?(Sketchup::Entity)

      faces_to_paint = []

      if entity.is_a?(Sketchup::Face)

        faces_to_paint.push(entity)

      elsif entity.is_a?(Sketchup::Group)

        faces_to_paint = entity.entities.grep(Sketchup::Face)

      elsif entity.is_a?(Sketchup::ComponentInstance)

        faces_to_paint = entity.definition.entities.grep(Sketchup::Face)

      end

      faces_to_paint.each { |face_to_paint|

        face_to_paint.material = Materials.generate_random
        face_to_paint.back_material = face_to_paint.material

      }

      entity

    end

    # Generates a random entity.
    #
    # @return [Sketchup::Group]
    def self.generate_random

      group = Shapes.generate_random

      group.material = Materials.generate_random

      randomize(group)

    end

    # Detects collided entities.
    #
    # @param [Array<Sketchup::Entity>] entities
    # @raise [ArgumentError]
    #
    # @return [Array<Sketchup::Entity>] Collided entities.
    def self.collision_detect(entities)

      raise ArgumentError, 'Entities argument is invalid.'\
        unless entities.is_a?(Array)

      ent_bounding_boxes = []
      collided_entities = []

      entities.each { |entity|

        ent_bounding_boxes.push([entity, entity.bounds])

      }

      ent_bounding_boxes.each { |entity_1, bounding_box_1|

        ent_bounding_boxes.each { |entity_2, bounding_box_2|

          if entity_1.object_id == entity_2.object_id

            next

          end

          if bounding_box_1.intersect(bounding_box_2).valid?

            collided_entities.push(entity_1)
            collided_entities.push(entity_2)

          end

        }

      }

      collided_entities

    end

    # Processes collision detect, preview, etc. after generation...
    #
    # @param [Array<Sketchup::Entity>] entities
    # @param [String] mode
    # @raise [ArgumentError]
    #
    # @return [nil]
    def self.post_processing(entities, mode)

      raise ArgumentError, 'Entities argument is invalid.'\
        unless entities.is_a?(Array)

      raise ArgumentError, 'Mode argument is invalid.'\
        unless mode =~ /^(validate|preview)$/

      model = Sketchup.active_model

      if PARAMETERS[:avoid_ent_collision?]

        # FIXME: Why these param. are incompatible?
        if PARAMETERS[:rand_zone_point_grid].empty?

          5.times do

            collided_entities = collision_detect(entities)

            collided_entities.each { |collided_entity|

              randomize(collided_entity)

            }

          end

        end

        model.active_entities.erase_entities(collision_detect(entities))

      end

      if mode == 'preview'

        SESSION[:bound_boxes_to_preview] = []

        entities.each { |entity|

          SESSION[:bound_boxes_to_preview].push(entity.bounds)

        }

        model.active_entities.erase_entities(entities)

        model.select_tool(PreviewTool.new)

        # XXX This “hack” debugs preview.
        model.active_view.refresh
        Sketchup.send_action('viewTop:')
        model.active_view.zoom_extents

      else # if mode == 'validate'

        if PARAMETERS[:entity_group_name] != ''

          group = model.active_entities.add_group(entities)

          group.name = PARAMETERS[:entity_group_name]

        end

        if PARAMETERS[:entity_layer_name] != 'Layer0'

          layer = model.layers[PARAMETERS[:entity_layer_name]]

          entities.each { |entity|

            entity.layer = layer

          }

        end

      end

    end

  end

end
