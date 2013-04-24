require 'retina_rails/exception'

module RetinaRails

  module Paperclip

    extend ActiveSupport::Concern

    included do
      ## Override paperclip default options
      RetinaRails::Extensions.override_default_options

      ## Iterate over each has_attached_file
      attachment_definitions.each_pair do |key, value|

        ## Check for style definitions
        styles = attachment_definitions[key][:styles]

        ## Get retina quality
        retina_quality = attachment_definitions[key][:retina_quality] || 40

        if styles

          retina_styles = {}
          retina_convert_options = {}
          convert_options = attachment_definitions[key][:convert_options]

          ## Iterate over styles and set optimzed dimensions
          styles.each_pair do |key, value|
            # make sure the file format is configureed; otherwise we'll get strange errors
            raise MisconfiguredError unless value.is_a?(Array) && value.size == 2

            dimensions = value[0]

            width  = dimensions.scan(/\d+/)[0].to_i * 2
            height = dimensions.scan(/\d+/)[1].to_i * 2

            processor = dimensions.scan(/#|</).first

            retina_styles["#{key}_retina".to_sym] = ["#{width}x#{height}#{processor}", value[1]]

            ## Set quality convert option
            convert_option = convert_options[key].to_s.dup if convert_options
            # make sure we double all the dimensions in convert options as well (such as extents)
            if (dimension_matches = convert_option.to_s.scan(/(\d+)x(\d+)/)).present?
              dimension_matches.each do |match|
                convert_option.sub!(/#{match[0]}x#{match[1]}/, "#{match[0].to_i*2}x#{match[1].to_i*2}")
              end
            end
            retina_convert_options["#{key}_retina".to_sym] = "#{convert_option} -quality #{retina_quality}"

          end

          ## Append new retina optimzed styles
          value[:styles].merge!(retina_styles)

          ## Set quality convert options
          value[:convert_options] = {} if value[:convert_options].nil?
          value[:convert_options].merge!(retina_convert_options)

          ## Make path work with retina optimization
          original_path = attachment_definitions[key][:path]
          value[:path] = RetinaRails::Extensions.optimize_path(original_path) if original_path

          ## Make url work with retina optimization
          original_url = attachment_definitions[key][:url]
          value[:url] = RetinaRails::Extensions.optimize_path(original_url) if original_url

        end

      end

    end

  end

end
