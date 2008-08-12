require 'net/http'
require 'stringio'
require 'cgi'
require 'composite_io'

module Net
  class HTTP
    class Post
      class ParamPart
        def initialize(boundary, name, value)
          @part = build_part(boundary, name, value)
          @io = StringIO.new(@part)
        end

        def length
          @part.length
        end

        def build_part(boundary, name, value)
          part = ''
          part << "--#{boundary}\r\n"
          part << "Content-Disposition: form-data; name=\"#{name.to_s}\"\r\n"
          part << "\r\n"
          part << "#{value}\r\n"
        end

        def to_io
          @io
        end
      end

      class FilePart
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

        def length
          @length
        end

        def build_head(boundary, name, filename, type)
          part = ''
          part << "--#{boundary}\r\n"
          part << "Content-Disposition: form-data; name=\"#{name.to_s}\"; filename=\"#{filename}\"\r\n"
          part << "Content-Type: #{type}\r\n"
          part << "Content-Transfer-Encoding: binary\r\n"
          part << "\r\n"
        end

        def to_io
          @io
        end
      end

      class ClosingBoundary
        def initialize(boundary)
          @part = "--#{boundary}--\r\n"
          @io = StringIO.new(@part)
        end
        def length
          @part.length
        end
        def to_io
          @io
        end
      end

      class Part
        def self.new(boundary, name, value)
          if value.respond_to? :content_type
            FilePart.new(boundary, name, value)
          else
            ParamPart.new(boundary, name, value)
          end
        end
      end

      DEFAULT_BOUNDARY = "-----------RubyMultipartPost"

      class Multipart < Post
        def initialize(path, params, boundary = DEFAULT_BOUNDARY)
          super(path)
          parts = params.map {|k,v| Part.new(boundary, k, v)}
          parts << ClosingBoundary.new(boundary)
          ios = parts.map{|p| p.to_io }
          self.set_content_type("multipart/form-data", { "boundary" => boundary })
          self.content_length = parts.inject(0) {|sum,i| sum + i.length }
          self.body_stream = CompositeReadIO.new(*ios)
        end
      end
    end
  end
end