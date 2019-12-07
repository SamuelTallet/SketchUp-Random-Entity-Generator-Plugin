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

      if !PARAMETERS[:rand_zone_min_x].nil?

        default_params[:entity_density] = TRANSLATE['Inapplicable']
        
      end

      parameters = UI.inputbox(

        [
          TRANSLATE['Entity count to generate'] + ' ',
          TRANSLATE['Rotate entities?'],
          TRANSLATE['Entity minimum size'],
          TRANSLATE['Entity maximum size'],
          TRANSLATE['Entity density'],
          TRANSLATE['Glue entities to ground?'],
          TRANSLATE['Avoid entity collision?']
        ], # Prompts

        [
          default_params[:entity_count],
          default_params[:rotate_entities],
          default_params[:entity_min_size],
          default_params[:entity_max_size],
          default_params[:entity_density],
          default_params[:glue_ents_to_ground],
          default_params[:avoid_ent_collision]
        ], # Defaults

        [
          '', TRANSLATE['Yes'] + '|' + TRANSLATE['No'], '', '', '',
          TRANSLATE['Yes'] + '|' + TRANSLATE['No'],
          TRANSLATE['Yes'] + '|' + TRANSLATE['No']
        ], # List

        TRANSLATE[NAME] # Title

      )

      # Escapes if user cancelled operation.
      return false if parameters == false

      PARAMETERS[:entity_count] = parameters[0].to_i
      PARAMETERS[:rotate_entities?] = (parameters[1] == TRANSLATE['Yes'])
      PARAMETERS[:entity_min_size] = parameters[2].to_f
      PARAMETERS[:entity_max_size] = parameters[3].to_f

      if PARAMETERS[:rand_zone_min_x].nil?

        PARAMETERS[:entity_density] = parameters[4].to_f

      end

      PARAMETERS[:glue_ents_to_ground?] = (parameters[5] == TRANSLATE['Yes'])
      PARAMETERS[:avoid_ent_collision?] = (parameters[6] == TRANSLATE['Yes'])

      true

    end

    # Resets parameters.
    #
    # @return [nil]
    def self.reset

      PARAMETERS[:entity_count]         = 100
      PARAMETERS[:rotate_entities?]     = TRANSLATE['Yes']
      PARAMETERS[:entity_min_size]      = -10.0
      PARAMETERS[:entity_max_size]      = 10.0
      PARAMETERS[:entity_density]       = 10.0
      PARAMETERS[:glue_ents_to_ground?] = TRANSLATE['No']
      PARAMETERS[:avoid_ent_collision?] = TRANSLATE['No']

      reset_random_zone

      nil

    end

    # Resets Random Zone parameters.
    #
    # @return [nil]
    def self.reset_random_zone

      PARAMETERS[:rand_zone_min_x] = nil
      PARAMETERS[:rand_zone_max_x] = nil

      PARAMETERS[:rand_zone_min_y] = nil
      PARAMETERS[:rand_zone_max_y] = nil

      PARAMETERS[:rand_zone_min_z] = nil
      PARAMETERS[:rand_zone_max_z] = nil

      nil

    end

  end

end
