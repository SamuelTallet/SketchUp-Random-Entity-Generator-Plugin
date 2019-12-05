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
require 'reg/shapes'
require 'fileutils'
require 'reg/materials'

# REG plugin namespace.
module REG

  # Proxies.
  module Proxies

    # Attributes dictionary name.
    ATTR_DICT_NAME = 'RandomEntityGenerator.Proxy'

    # Creates a proxy for Enscape.
    #
    # @return [nil|Sketchup::ComponentInstance]
    def self.create_enscape_proxy

      model_path = UI.openpanel(
        TRANSLATE['Select a SketchUp Model'],
        nil,
        TRANSLATE['SketchUp Models'] + '|*.skp||'
      )

      # Escapes if user cancelled operation.
      return if model_path.nil?

      Sketchup.active_model.start_operation(
        TRANSLATE['Create an Enscape proxy'],
        true # disable_ui
      )

      proxy = Shapes.generate_random_box('30cm'.to_l, '30cm'.to_l, '30cm'.to_l)

      proxy = proxy.to_component

      proxy.definition.set_attribute('Enscape.Proxy', 'FileName', model_path)

      proxy.definition.name = File.basename(model_path, '.skp')
      proxy.definition.description = 'Enscape proxy created by REG plugin.'
      
      # XXX This “hack” will maintain proxy color.
      proxy.material = Materials.generate_random
      proxy.material.alpha = 0.5
      proxy.definition.set_attribute(
        ATTR_DICT_NAME, :MaterialName, proxy.material.name
      )

      Sketchup.active_model.commit_operation

      proxy

    end

  end

end
