#--
# (c) Copyright 2007-2008 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'net/http'
require 'stringio'
require 'cgi'
require 'composite_io'

module Net #:nodoc:
  class HTTP #:nodoc:
    class Post #:nodoc:
      module Part #:nodoc:
        def self.new(boundary, name, value)
          if value.respond_to? :content_type
            FilePart.new(boundary, name, value)
          else
            ParamPart.new(boundary, name, value)
          end
        end

        def length
          @part.length
        end

        def to_io
          @io
        end
      end

      # Represents a part to be filled with a string name/value pair.
      class ParamPart
        include Part
        def initialize(boundary, name, value)
          @part = build_part(boundary, name, value)
          @io = StringIO.new(@part)
        end

        def build_part(boundary, name, value)
          part = ''
          part << "--#{boundary}\r\n"
          part << "Content-Disposition: form-data; name=\"#{name.to_s}\"\r\n"
          part << "\r\n"
          part << "#{value}\r\n"
        end
      end

      # Represents a part to be filled from file IO.
      class FilePart
        include Part
        attr_reader :length
        def initialize(boundary, name, io)
          @head = build_head(boundary, name, io.original_filename, io.content_type)
          file_length = if io.respond_to? :length
            io.length
          else
            File.size(io.local_path)
          end
          @length = @head.length + file_length
          @io = CompositeReadIO.new(StringIO.new(@head), io, StringIO.new("\r\n"))
        end

        def build_head(boundary, name, filename, type)
          part = ''
          part << "--#{boundary}\r\n"
          part << "Content-Disposition: form-data; name=\"#{name.to_s}\"; filename=\"#{filename}\"\r\n"
          part << "Content-Type: #{type}\r\n"
          part << "Content-Transfer-Encoding: binary\r\n"
          part << "\r\n"
        end
      end

      # Represents the epilogue or closing boundary.
      class EpiloguePart
        include Part
        def initialize(boundary)
          @part = "--#{boundary}--\r\n"
          @io = StringIO.new(@part)
        end
      end

      DEFAULT_BOUNDARY = "-----------RubyMultipartPost"

      # Extension to the Net::HTTP::Post class that builds a post body
      # consisting of a multipart mime stream based on the parameters given.
      # See README.txt for synopsis and details.
      class Multipart < Post
        def initialize(path, params, boundary = DEFAULT_BOUNDARY)
          super(path)
          parts = params.map {|k,v| Part.new(boundary, k, v)}
          parts << EpiloguePart.new(boundary)
          ios = parts.map{|p| p.to_io }
          self.set_content_type("multipart/form-data", { "boundary" => boundary })
          self.content_length = parts.inject(0) {|sum,i| sum + i.length }
          self.body_stream = CompositeReadIO.new(*ios)
        end
      end
    end
  end
end