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
require 'reg/parameters'
require 'reg/generator'
require 'reg/proxies'

# REG plugin namespace.
module REG

  # Connects REG plugin menu to SketchUp user interface.
  class Menu

    # Adds REG plugin menu (items included) in a SketchUp menu.
    #
    # @param [Sketchup::Menu] parent_menu Target parent menu.
    # @raise [ArgumentError]
    def initialize(parent_menu)

      raise ArgumentError, 'Parent menu must be a SketchUp::Menu.'\
        unless parent_menu.is_a?(Sketchup::Menu)

      @menu = parent_menu.add_submenu('🎲 ' + TRANSLATE[NAME])

      menu_item = @menu.add_item('▣ ' + TRANSLATE['Explore Proxy Library...']) {

        Proxies.show_library_html_dialog

      }

      @menu.set_validation_proc(menu_item) {

        if Sketchup.platform == :platform_osx

          MF_GRAYED

        else

          MF_ENABLED
          
        end

      }

      @menu.add_item(TRANSLATE['Generate Random Entities...']) {

        if Parameters.set({

          :entity_count         => 100,
          :entity_min_rotation  => 0.0,
          :entity_max_rotation  => 359.0,
          :entity_min_size      => -10.0,
          :entity_max_size      => 10.0,
          :entity_density       => 10.0,
          :glue_ents_to_ground  => TRANSLATE['No'],
          :glue_ents_to_faces   => TRANSLATE['Inapplicable'],
          :avoid_ent_collision  => TRANSLATE['No'],
          :overwite_ent_colors  => TRANSLATE['No']

        })

          Generator.new

        end
        
      }

      @menu.add_item(TRANSLATE['Create a Proxy for Enscape...']) {

        Proxies.create_for_enscape_part1

      }

      @menu.add_item(TRANSLATE['Erase Real Model of Proxy']) {

        Proxies.erase_real_model

      }

      @menu.add_item(TRANSLATE['Forget the Random Zones']) {

        Parameters.reset_random_zone

      }

      @menu.add_item('💌 ' + TRANSLATE['Donate to Plugin Author']) do

        UI.openURL('https://www.paypal.me/SamuelTS/')
        
      end

    end

  end

end
