# Random Entity Generator extension for SketchUp 2017 or newer.
# Copyright: © 2025 Samuel Tallet <samuel.tallet arobase gmail.com>
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
require 'fileutils'
require 'reg/html_dialogs'
require 'reg/shapes'
require 'reg/materials'

# REG plugin namespace.
module REG

  # Proxies.
  module Proxies

    # Absolute path to proxy library (plugin folder).
    PLUGIN_LIB_DIR = File.join(__dir__, 'Proxy Library').freeze

    # Absolute path to proxy library (program folder).
    PROGRAM_LIB_DIR = 'C:\\ProgramData\\Random Entity Generator\\Library'.freeze

    # Attributes dictionary name.
    ATTR_DICT_NAME = 'RandomEntityGenerator.Proxy'.freeze

    # Installs proxy library.
    #
    # XXX Only on Windows.
    #
    # @return [Boolean] true on success...
    def self.install_library

      if Sketchup.platform == :platform_osx || File.exist?(PROGRAM_LIB_DIR)

        return false

      end

      FileUtils.mkdir_p(PROGRAM_LIB_DIR)

      Dir.foreach(PLUGIN_LIB_DIR) do |filename|

        next if filename == '.' || filename == '..'

        FileUtils.cp(
          File.join(PLUGIN_LIB_DIR, filename), # source
          File.join(PROGRAM_LIB_DIR, filename) # destination
        )

      end

      true

    end

    # Uninstalls proxy library.
    #
    # XXX Only on Windows.
    #
    # @return [Boolean] true on success...
    def self.uninstall_library

      if Sketchup.platform == :platform_osx

        return false

      end

      FileUtils.remove_dir(PROGRAM_LIB_DIR, true)

      true

    end

    # Returns all proxy names stored in proxy library.
    # 
    # @return [Array<String>]
    def self.names_stored_in_library

      [
        'Alaska Cedar', 'Azalea', 'Bolete',
        'Conifer', 'European Birch', 'Grass Block',
        'Pink Daisy Flower', 'Plane', 'White Daisy Flower'
      ]

    end

    # Shows "REG Proxy Library Explorer" HTML dialog.
    #
    # @return [void]
    def self.show_library_html_dialog

      html_dialog = UI::HtmlDialog.new(

        dialog_title:    TRANSLATE['REG Proxy Library Explorer'],
        preferences_key: 'REG Proxy Library Explorer',
        scrollable:      true,
        width:           950,
        height:          500,
        min_width:       950,
        min_height:      500

      )

      html_dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'proxy-library-explorer.rhtml',
        scripts: ['proxy-library-explorer.js'],
        styles: ['proxy-library-explorer.css']

      ))

      html_dialog.add_action_callback('importProxy') do |_context, proxy_ref|

        html_dialog.close

        Sketchup.active_model.import(
          File.join(PROGRAM_LIB_DIR, proxy_ref + '.skp')
        )
        
      end

      html_dialog.center

      html_dialog.show

    end

    # Creates a proxy for Enscape (Part #1).
    #
    # @return [nil]
    def self.create_for_enscape_part1

      proxy_model_path = UI.openpanel(
        TRANSLATE['Select a SketchUp Model'],
        nil,
        TRANSLATE['SketchUp Models'] + '|*.skp||'
      )

      # Escapes if user cancelled operation.
      return if proxy_model_path.nil?

      SESSION[:proxy_model_path] = proxy_model_path

      Sketchup.active_model.import(SESSION[:proxy_model_path])

      nil

    end

    # Creates a proxy for Enscape (Part #2).
    #
    # @see REG::ModelObserver
    #
    # @param [Sketchup::ComponentInstance] real_component
    #
    # @return [nil]
    def self.create_for_enscape_part2(real_component)

      Sketchup.active_model.start_operation(
        TRANSLATE['Create an Enscape proxy'],
        true # disable_ui
      )

      real_compo_bounds = real_component.bounds

      real_component.hidden = true

      proxy_group = Shapes.generate_random_box(
        real_compo_bounds.height,
        real_compo_bounds.width,
        real_compo_bounds.depth
      )

      proxy_component = proxy_group.to_component

      proxy_component.definition.set_attribute(
        'Enscape.Proxy', 'FileName', SESSION[:proxy_model_path]
      )

      proxy_component.definition.name = File.basename(
        SESSION[:proxy_model_path], '.skp'
      )

      proxy_component.definition.description\
        = 'Enscape proxy created by REG plugin.'
      
      # XXX This “hack” will maintain proxy color:

      proxy_component.material = Materials.generate_random

      proxy_component.material.alpha = 0.5

      proxy_component.definition.set_attribute(
        ATTR_DICT_NAME, :MaterialName, proxy_component.material.name
      )

      SESSION[:proxy_model_path] = nil

      SESSION[:real_compo_object_id] = real_component.object_id

      Sketchup.active_model.commit_operation

      UI.messagebox(
        TRANSLATE[
          'To optimize SketchUp model weight, run: Erase Real Model of Proxy.'
        ]
      )

      nil

    end

    # Erases real proxy model.
    #
    # @return [nil]
    def self.erase_real_model

      begin

        if !SESSION[:real_compo_object_id].nil?

          ObjectSpace._id2ref(SESSION[:real_compo_object_id]).erase!

          SESSION[:real_compo_object_id] = nil

          Sketchup.active_model.definitions.purge_unused
          
          Sketchup.active_model.materials.purge_unused

        end

        nil
        
      # If real component was already erased:
      rescue TypeError => _exception

        SESSION[:real_compo_object_id] = nil
        
      end
      
    end

  end

end
