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
require 'reg/entities'

# REG plugin namespace.
module REG

  # Secondary instance.
  class Selection

    # Randomizes selected entities.
    def initialize

      selected_groups = []

      Sketchup.active_model.selection.each { |selected_entity|

        if selected_entity.is_a?(Sketchup::Group)

          selected_groups.push(selected_entity)

        end

      }

      if selected_groups.empty?

        UI.messagebox(TRANSLATE['No group found in selection.'])
        return

      end

      Sketchup.active_model.start_operation(
        TRANSLATE['Randomize position/size of selected entities'],
        true # disable_ui
      )

      Sketchup.status_text = TRANSLATE['Randomizing entities... Please wait.']

      PARAMETERS[:entity_count].times do

        original_group = selected_groups.sample

        cloned_group = original_group.copy
        cloned_group.material = original_group.material
        cloned_group.transformation = original_group.transformation
        
        Entities.randomize_position_and_size(cloned_group)

      end

      Sketchup.active_model.commit_operation

      Sketchup.status_text = nil

    end

  end

end
