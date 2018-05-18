# frozen_string_literal: true

#--
# Copyright (c) 2007-2013 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'multipart/post/parts'
require 'multipart/post/composite_read_io'
require 'securerandom'

module Multipart
  module Post
    module Multipartable
      def self.secure_boundary
        # https://tools.ietf.org/html/rfc7230
        #      tchar          = "!" / "#" / "$" / "%" / "&" / "'" / "*"
        #                     / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
        #                     / DIGIT / ALPHA

        # https://tools.ietf.org/html/rfc2046
        #      bcharsnospace := DIGIT / ALPHA / "'" / "(" / ")" /
        #                       "+" / "_" / "," / "-" / "." /
        #                       "/" / ":" / "=" / "?"

        "--#{SecureRandom.uuid}"
      end

      def initialize(path, params, headers={}, boundary = Multipartable.secure_boundary)
        headers = headers.clone # don't want to modify the original variable
        parts_headers = headers.delete(:parts) || {}
        parts_headers.transform_keys!(&:to_sym)

        super(path, headers)

        parts = Array.new
        generate_parts(parts, params, boundary, parts_headers, '')
        parts << Parts::EpiloguePart.new(boundary)

        ios = parts.map {|p| p.to_io }
        self.set_content_type(headers["Content-Type"] || "multipart/form-data",
                              { "boundary" => boundary })
        self.content_length = parts.inject(0) {|sum,i| sum + i.length }
        self.body_stream = CompositeReadIO.new(*ios)

        @boundary = boundary
      end

      attr :boundary

      private

      def generate_parts(parts, params, boundary, parts_headers, prefix)
        params.each do |key, value|
          key = key.to_sym
          generate_nested_parts(parts, key, value, boundary, parts_headers, prefix)
        end
      end

      def generate_nested_parts(parts, key, value, boundary, parts_headers, prefix)
        nested_prefix = prefix.empty? ? key.to_s : "#{prefix}[#{key}]"

        case value
        when Array
          value.each do |item|
            generate_nested_parts(parts, '', item, boundary, parts_headers, nested_prefix)
          end
        when Hash
          generate_parts(parts, value, boundary, parts_headers, nested_prefix)
        else
          parts << Parts::Part.new(boundary, nested_prefix, value, parts_headers[key])
        end
      end
    end
  end
end
