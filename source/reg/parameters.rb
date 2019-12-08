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

    # Set parameters from user input.
    #
    # @param [Hash] default_params Default parameters.
    #
    # @return [Boolean] true on success...
    def self.set(default_params)

      if !PARAMETERS[:rand_zone_point_grid].empty?

        default_params[:entity_density] = TRANSLATE['Inapplicable']
        default_params[:glue_ents_to_ground] = TRANSLATE['Inapplicable']
        default_params[:glue_ents_to_faces] = TRANSLATE['Yes']

      end

      parameters = UI.inputbox(

        [
          TRANSLATE['Entity count to generate'] + ' ',
          TRANSLATE['Entity minimum rotation'],
          TRANSLATE['Entity maximum rotation'],
          TRANSLATE['Entity minimum size'],
          TRANSLATE['Entity maximum size'],
          TRANSLATE['Entity density'],
          TRANSLATE['Glue entities to ground?'],
          TRANSLATE['Glue entities to faces?'],
          TRANSLATE['Avoid entity collision?'],
          TRANSLATE['Overwrite entity colors?']
        ], # Prompts

        [
          default_params[:entity_count],
          default_params[:entity_min_rotation],
          default_params[:entity_max_rotation],
          default_params[:entity_min_size],
          default_params[:entity_max_size],
          default_params[:entity_density],
          default_params[:glue_ents_to_ground],
          default_params[:glue_ents_to_faces],
          default_params[:avoid_ent_collision],
          default_params[:overwite_ent_colors]
        ], # Defaults

        [
          '', '', '', '', '', '',
          TRANSLATE['Yes'] + '|' + TRANSLATE['No'] + '|' + 
            TRANSLATE['Inapplicable'],
          TRANSLATE['Yes'] + '|' + TRANSLATE['No'] + '|' +
            TRANSLATE['Inapplicable'],
          TRANSLATE['Yes'] + '|' + TRANSLATE['No'],
          TRANSLATE['Yes'] + '|' + TRANSLATE['No']
        ], # List

        TRANSLATE[NAME] # Title

      )

      # Escapes if user cancelled operation.
      return false if parameters == false

      PARAMETERS[:entity_count] = parameters[0].to_i
      
      PARAMETERS[:entity_min_rotation] = parameters[1].to_f
      PARAMETERS[:entity_max_rotation] = parameters[2].to_f

      PARAMETERS[:entity_min_size] = parameters[3].to_f
      PARAMETERS[:entity_max_size] = parameters[4].to_f

      if PARAMETERS[:rand_zone_point_grid].empty?

        PARAMETERS[:entity_density] = parameters[5].to_f
        
        PARAMETERS[:glue_ents_to_ground?] = (parameters[6] == TRANSLATE['Yes'])

      else

        PARAMETERS[:glue_ents_to_faces?] = (parameters[7] == TRANSLATE['Yes'])

      end

      PARAMETERS[:avoid_ent_collision?] = (parameters[8] == TRANSLATE['Yes'])

      PARAMETERS[:overwite_ent_colors?] = (parameters[9] == TRANSLATE['Yes'])

      true

    end

    # Resets parameters.
    #
    # @return [nil]
    def self.reset

      PARAMETERS[:entity_count]         = 100

      PARAMETERS[:entity_min_rotation]  = 0.0
      PARAMETERS[:entity_max_rotation]  = 359.0

      PARAMETERS[:entity_min_size]      = -10.0
      PARAMETERS[:entity_max_size]      = 10.0

      PARAMETERS[:entity_density]       = 10.0

      PARAMETERS[:glue_ents_to_ground?] = false
      PARAMETERS[:glue_ents_to_faces?]  = false

      PARAMETERS[:avoid_ent_collision?] = false

      PARAMETERS[:overwite_ent_colors?] = false

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
