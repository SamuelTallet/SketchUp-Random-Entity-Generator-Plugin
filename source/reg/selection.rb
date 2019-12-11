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
require 'reg/point_grid'
require 'reg/entities'

# REG plugin namespace.
module REG

  # Secondary instance.
  class Selection

    # Sets selection as one more random zone.
    #
    # @return [nil]
    def self.set_as_random_zone

      model = Sketchup.active_model

      selected_faces = model.selection.grep(Sketchup::Face)

      if selected_faces.empty?

        UI.messagebox(TRANSLATE['Please select one or many faces.'])

        return

      end

      begin

        model.start_operation(
          TRANSLATE['Set Random Zone'],
          true # disable_ui
        )

        Sketchup.status_text = TRANSLATE['Defining Random Zone... Please wait.']

        altitude_parameter = UI.inputbox(

           [TRANSLATE['Entity max. altitude (m)']], # Prompt
           [0], # Default
           TRANSLATE[NAME] # Title

        )

        # Escapes if user cancelled operation.
        return if altitude_parameter == false

        PARAMETERS[:entity_max_altitude] =
          altitude_parameter[0].to_s.concat('m').to_l

        # XXX High density point grid:
        if selected_faces.size <= 100

          selected_faces.each { |selected_face|

            PARAMETERS[:rand_zone_point_grid].concat(
              PointGrid.face(selected_face, 100)
            )

          }

        # XXX Low density point grid:
        else

          selected_faces.each { |selected_face|

            selected_face_point = selected_face.bounds.center

            next if PARAMETERS[:entity_max_altitude] != 0\
              && selected_face_point.z > PARAMETERS[:entity_max_altitude]

            PARAMETERS[:rand_zone_point_grid].concat([

              [
                selected_face_point,
                selected_face.normal
              ]

            ])

          }

        end

        model.commit_operation

        Sketchup.status_text = nil

        UI.messagebox(TRANSLATE['Surface well added to Random Zone list.'])

        nil

      rescue StandardError => _exception

        model.abort_operation

        Sketchup.status_text = nil

        UI.messagebox(
          TRANSLATE[
            'Can\'t be a random zone: REG plugin supports only quad faces.'
          ] + ' ' +
          TRANSLATE[
            'Use Quadrilateralizer plugin to convert this face to quad faces.'
          ]
        )

        UI.openURL('http://sketchucation.com/pluginstore?pln=Quadrilateralizer')

      end

    end

    # Randomizes selected entities.
    #
    # @return [nil]
    def self.randomize_entities

      selected_grouponents = []

      Sketchup.active_model.selection.each { |selected_entity|

        if selected_entity.is_a?(Sketchup::Group)\
         || selected_entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(selected_entity)

        end

      }

      if selected_grouponents.empty?

        UI.messagebox(TRANSLATE['No group nor component found in selection.'])
        return

      end

      Sketchup.active_model.start_operation(
        TRANSLATE['Randomize selected entities'],
        true # disable_ui
      )

      Sketchup.status_text = TRANSLATE['Randomizing entities... Please wait.']

      generated_entities = []

      PARAMETERS[:entity_count].times do

        generated_entities.push(Entities.randomize(
          Entities.clone_grouponent(selected_grouponents.sample)
        ))

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

        Sketchup.active_model.active_entities.erase_entities(
          Entities.collision_detect(generated_entities)
        )

      end

      Sketchup.active_model.commit_operation

      Sketchup.status_text = nil

      nil

    end

  end

end
