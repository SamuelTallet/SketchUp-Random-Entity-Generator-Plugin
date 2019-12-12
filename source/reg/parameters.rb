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

      nil

    end

    # Shows "REG Parameters" HTML dialog.
    #
    # @param [String] preset
    # @param [String] callback
    #
    # @return [void]
    def self.show_html_dialog(preset, callback)

      raise ArgumentError, 'Preset argument is invalid.'\
        unless preset =~ /^(flowers|trees|grass_blocks|big_bang)$/

      raise ArgumentError, 'Callback argument is invalid.'\
        unless callback =~ /^(generator|randomizer)$/

      html_dialog = UI::HtmlDialog.new(

        dialog_title:    TRANSLATE['REG Parameters'],
        preferences_key: 'REG Parameters',
        scrollable:      false,
        width:           420,
        height:          555,
        min_width:       420,
        min_height:      555

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

      html_dialog.add_action_callback('setParameters') do |_context, parameters|

        html_dialog.close

        puts parameters

        set(parameters)

        if callback == 'generator'

          Generator.new

        else # if callback == 'randomizer'

          Selection.randomize_entities

        end
        
      end

      html_dialog.center

      html_dialog.show

    end

    # Resets parameters.
    #
    # @return [nil]
    def self.reset

      PARAMETERS[:entity_count]           = 100

      PARAMETERS[:entity_min_rotation]    = 0.0.degrees
      PARAMETERS[:entity_max_rotation]    = 359.0.degrees

      PARAMETERS[:entity_min_size]        = -10.0
      PARAMETERS[:entity_max_size]        = 10.0

      PARAMETERS[:push_ents_to_down]      = 0.to_l
      PARAMETERS[:entity_max_altitude]    = 0.to_l

      PARAMETERS[:entity_density]         = 10.0

      PARAMETERS[:glue_ents_to_ground?]   = false
      PARAMETERS[:follow_face_normals?]   = false

      PARAMETERS[:avoid_ent_collision?]   = false

      PARAMETERS[:overwrite_ent_colors?]  = false

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
