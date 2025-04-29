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

# REG plugin namespace.
module REG

  # Donation helper.
  module Donation

    # Permanent URL to donate.
    # @type [String]
    PERMALINK = 'https://www.paypal.me/SamuelTallet'.freeze

    # Dynamic URL to donate.
    # @type [String]
    DYNALINK = 'https://raw.githubusercontent.com/SamuelTallet/SketchUp-Random-Entity-Generator-Plugin/master/config/donate.url'.freeze

    # URL to donate.
    # @type [String]
    @@url = PERMALINK

    # Fetches URL to donate from GitHub or defaults to PayPal.Me
    def self.fetch_url
      request = Sketchup::Http::Request.new(DYNALINK)

      request.start do |_request, response|
        error_suffix = "while fetching donation URL #{DYNALINK}"

        if response.status_code < 400

          if response.body.strip.start_with?('https://')
            @@url = response.body.strip
          else
            puts "Got no URL in #{response.body} #{error_suffix}"
          end

        else
          puts "Got error #{response.status_code} #{error_suffix}"
        end

      end
    end

    # Gets URL to donate.
    #
    # @return [String]
    def self.url
      @@url
    end

  end

end
