#--
# Copyright (c) 2007-2013 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'parts'
  module Multipartable
    DEFAULT_BOUNDARY = "-----------RubyMultipartPost"
    def initialize(path, params, headers={}, boundary = DEFAULT_BOUNDARY)
      headers = headers.clone # don't want to modify the original variable
      parts_headers = headers.delete(:parts) || {}
      super(path, headers)
      parts = convert_params_to_parts(params, boundary, parts_headers, '')
      parts << Parts::EpiloguePart.new(boundary)
      ios = parts.map {|p| p.to_io }
      self.set_content_type(headers["Content-Type"] || "multipart/form-data",
                            { "boundary" => boundary })
      self.content_length = parts.inject(0) {|sum,i| sum + i.length }
      self.body_stream = CompositeReadIO.new(*ios)
    end

    private

    def convert_params_to_parts(params, boundary = DEFAULT_BOUNDARY, parts_headers = {}, prefix = '')
        parts = params.map do |k, v|
            process_params_value(k, v, boundary, parts_headers, prefix)
        end.flatten
        parts
    end

    def process_params_value(k, v, boundary = DEFAULT_BOUNDARY, parts_headers = {}, prefix = '')
        if v.is_a?(Array)
            v.map do |item|
                process_params_value('', item, boundary, parts_headers, prefix == '' ? "#{k}" : prefix + "[#{k}]")
            end
        elsif v.is_a?(Hash)
            convert_params_to_parts(v, boundary, parts_headers, prefix == '' ? k : prefix + "[#{k}]")
        else
            Parts::Part.new(boundary, prefix == '' ? k : prefix + "[#{k}]", v, parts_headers[k])
        end
    end
  end
