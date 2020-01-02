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
require 'reg/generator'
require 'reg/entities'

# REG plugin namespace.
module REG

  # Parameters.
  module Parameters

    # Sets parameters from HTML dialog user input.
    #
    # @see HTML Dialogs/parameters.rhtml
    # @see HTML Dialogs/parameters.js
    # 
    # @return [nil]
    def self.set(parameters)

      PARAMETERS[:entity_count] = parameters['entity_count'].to_i
      
      PARAMETERS[:entity_min_rotation]\
        = parameters['entity_min_rotation'].to_f.degrees

      PARAMETERS[:entity_max_rotation]\
        = parameters['entity_max_rotation'].to_f.degrees

      PARAMETERS[:entity_min_size] = parameters['entity_min_size'].to_f
      PARAMETERS[:entity_max_size] = parameters['entity_max_size'].to_f

      if PARAMETERS[:rand_zone_point_grid].empty?

        PARAMETERS[:entity_max_altitude]\
          = parameters['entity_max_altitude'].concat('m').to_l

        PARAMETERS[:entity_density] = parameters['entity_density'].to_f
        
        PARAMETERS[:glue_ents_to_ground?]\
          = (parameters['glue_ents_to_ground'] == 'yes')

      else

        PARAMETERS[:push_ents_to_down]\
          = parameters['push_ents_to_down'].concat('cm').to_l

        PARAMETERS[:follow_face_normals?]\
          = (parameters['follow_face_normals'] == 'yes')

      end

      PARAMETERS[:avoid_ent_collision?]\
        = (parameters['avoid_ent_collision'] == 'yes')

      PARAMETERS[:overwrite_ent_colors?]\
        = (parameters['overwrite_ent_colors'] == 'yes')

      PARAMETERS[:entity_group_name] = parameters['entity_group_name']

      PARAMETERS[:entity_layer_name] = parameters['entity_layer_name']

      nil

    end

    # Sets selection as one more Random Zone.
    #
    # @return [nil]
    def self.set_selection_as_rand_zone

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

        parameters = UI.inputbox(

          [
            TRANSLATE['Entity maximum altitude (m)'],
            TRANSLATE['Entity distribution algorithm'] + ' '
          ], # Prompts

          [
            0,
            TRANSLATE['Random / Face center']
          ], # Defaults

          [
            '',
            TRANSLATE['Random / Face center'] + '|' +
            TRANSLATE['Random (Slow)'] + '|' +
            TRANSLATE['Face center (Fast)']
          ],

          TRANSLATE[NAME] # Title

        )

        # Escapes if user cancelled operation.
        return if parameters == false

        entity_max_altitude = parameters[0].to_s.concat('m').to_l
        entity_distrib_algo = parameters[1]

        if entity_distrib_algo == TRANSLATE['Random / Face center']

          if selected_faces.size <= 100

            selected_faces.each { |selected_face|

              PARAMETERS[:rand_zone_point_grid].concat(
                PointGrid.face(selected_face, 100)
              )

            }

          else

            selected_faces.each { |selected_face|

              selected_face_point = selected_face.bounds.center

              next if entity_max_altitude != 0\
                && selected_face_point.z > entity_max_altitude

              PARAMETERS[:rand_zone_point_grid].concat([

                [
                  selected_face_point,
                  selected_face.normal
                ]

              ])

            }

          end

        elsif entity_distrib_algo == TRANSLATE['Random (Slow)']

          selected_faces.each { |selected_face|

            PARAMETERS[:rand_zone_point_grid].concat(
              PointGrid.face(selected_face, 100)
            )

          }

        else # if entity_distrib_algo == TRANSLATE['Face center (Fast)']

          selected_faces.each { |selected_face|

            selected_face_point = selected_face.bounds.center

            next if entity_max_altitude != 0\
              && selected_face_point.z > entity_max_altitude

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
            'Error: Random zone must be constituted of triangles or quad faces.'
          ]
        )

      end

    end

    # Sets Random Zone param. from an image.
    #
    # @return [nil]
    def self.set_rand_zone_from_image

      image_path = UI.openpanel(
        TRANSLATE['Select an Image'], nil,
        TRANSLATE['Image'] + '|*.bmp||'
      )

      # Escapes if user cancelled operation.
      return if image_path == nil

      parameters = UI.inputbox(

        [
          TRANSLATE['How many centimeters per pixel?'],
          TRANSLATE['How many vertical (Z axis) layers?'],
          TRANSLATE['Space between each Z layer (cm)?'] + ' '
        ], # Prompts

        [
          10,
          1,
          100
        ], # Defaults

        TRANSLATE[NAME] # Title

      )

      # Escapes if user cancelled operation.
      return if parameters == false

      begin

        model = Sketchup.active_model

        model.start_operation(
          TRANSLATE['Set Random Zone'],
          true # disable_ui
        )

        Sketchup.status_text = TRANSLATE['Defining Random Zone... Please wait.']

        PARAMETERS[:rand_zone_point_grid]\
          = PointGrid.bitmap(
              image_path,
              parameters[0],
              parameters[1],
             parameters[2]
            )

        model.commit_operation

        Sketchup.status_text = nil

        UI.messagebox(TRANSLATE['Random Zone recorded.'])

        nil

      rescue StandardError => exception

        model.abort_operation

        Sketchup.status_text = nil

        UI.messagebox(TRANSLATE['Error:'] + ' ' + exception.message)

      end

    end

    # Shows "REG Parameters" HTML dialog.
    #
    # @param [String] preset
    # @param [String] callback
    #
    # @raise [ArgumentError]
    #
    # @return [void]
    def self.show_html_dialog(preset, callback)

      raise ArgumentError, 'Preset argument is invalid.'\
        unless preset =~ /^(custom|flowers|trees|grass_blocks|big_bang)$/

      raise ArgumentError, 'Callback argument is invalid.'\
        unless callback =~ /^(generator|randomizer)$/

      html_dialog = UI::HtmlDialog.new(

        dialog_title:    TRANSLATE['REG Parameters'],
        preferences_key: 'REG Parameters',
        scrollable:      false,
        width:           420,
        height:          625,
        min_width:       420,
        min_height:      625

      )

      html_dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'parameters.rhtml',
        scripts: ['parameters.js'],
        styles: ['parameters.css']

      ))

      html_dialog.add_action_callback('getPresetAndRandomZoneStatus') do

        html_dialog.execute_script('REG.preset = "' + preset + '";')

        if !PARAMETERS[:rand_zone_point_grid].empty?

          html_dialog.execute_script('REG.randomZoneIsDefined = true;')

        else

          html_dialog.execute_script('REG.randomZoneIsDefined = false;')

        end

      end

      html_dialog.add_action_callback('setParameters') do |_c, parameters, mode|

        if mode == 'validate'

          html_dialog.close

        end

        set(parameters)

        if callback == 'generator'

          Generator.new(mode)

        else # if callback == 'randomizer'

          Entities.randomize_selection(mode)

        end
        
      end

      html_dialog.set_on_closed {

        # XXX This “hack” clears preview.
        Sketchup.send_action('selectSelectionTool:')
        Sketchup.active_model.active_view.refresh

      }

      html_dialog.center

      html_dialog.show

    end

    # Resets parameters.
    #
    # @return [nil]
    def self.reset

      PARAMETERS[:entity_count]           = 500

      PARAMETERS[:entity_min_rotation]    = 0.0.degrees
      PARAMETERS[:entity_max_rotation]    = 359.0.degrees

      PARAMETERS[:entity_min_size]        = 0.7
      PARAMETERS[:entity_max_size]        = 1.0

      PARAMETERS[:push_ents_to_down]      = 0.to_l
      PARAMETERS[:entity_max_altitude]    = 0.to_l

      PARAMETERS[:entity_density]         = 10.0

      PARAMETERS[:glue_ents_to_ground?]   = true
      PARAMETERS[:follow_face_normals?]   = false

      PARAMETERS[:avoid_ent_collision?]   = false

      PARAMETERS[:overwrite_ent_colors?]  = false

      PARAMETERS[:entity_group_name] = ''

      PARAMETERS[:entity_layer_name] = 'Layer0'

      reset_random_zone

      nil

    end

    # Resets Random Zone parameter.
    #
    # @return [nil]
    def self.reset_random_zone

      PARAMETERS[:rand_zone_point_grid] = []

      nil

    end

  end

end
