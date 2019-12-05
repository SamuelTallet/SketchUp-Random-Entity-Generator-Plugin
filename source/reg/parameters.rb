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
    # @return [Boolean] true on success...
    def self.set(

        entity_count,
        rotate_entities,
        entity_min_size,
        entity_max_size,
        entity_density,
        glue_ents_to_ground

      )

      parameters = UI.inputbox(

        [
          TRANSLATE['Entity count'],
          TRANSLATE['Rotate entities?'],
          TRANSLATE['Entity minimum size'],
          TRANSLATE['Entity maximum size'],
          TRANSLATE['Entity density'],
          TRANSLATE['Glue entities to ground?']
        ], # Prompts

        [
          entity_count,
          rotate_entities,
          entity_min_size,
          entity_max_size,
          entity_density,
          glue_ents_to_ground
        ], # Defaults

        [
          '', TRANSLATE['Yes'] + '|' + TRANSLATE['No'], '', '',
          '', TRANSLATE['Yes'] + '|' + TRANSLATE['No']
        ], # List

        TRANSLATE[NAME] # Title

      )

      # Escapes if user cancelled operation.
      return false if parameters == false

      PARAMETERS[:entity_count] = parameters[0].to_i
      PARAMETERS[:rotate_entities?] = (parameters[1] == TRANSLATE['Yes'])
      PARAMETERS[:entity_min_size] = parameters[2].to_f
      PARAMETERS[:entity_max_size] = parameters[3].to_f
      PARAMETERS[:entity_density] = parameters[4].to_f
      PARAMETERS[:glue_ents_to_ground?] = (parameters[5] == TRANSLATE['Yes'])

      true

    end

  end

end
