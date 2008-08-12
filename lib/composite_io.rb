# Concatenate together multiple IO objects into a single, composite IO object
# for purposes of reading as a single stream.
#
# Usage:
#
#     crio = CompositeReadIO.new(StringIO.new('one'), StringIO.new('two'), StringIO.new('three'))
#     puts crio.read # => "onetwothree"
#  
class CompositeReadIO
  # Create a new composite-read IO from the arguments, all of which should
  # respond to #read in a manner consistent with IO.
  def initialize(*ios)
    @ios = ios.flatten
  end

  # Read from the IO object, overlapping across underlying streams as necessary.
  def read(amount = nil, buf = nil)
    buffer = buf || ''
    done = if amount; nil; else ''; end
    partial_amount = amount

    loop do
      result = done

      while !@ios.empty? && (result = @ios.first.read(partial_amount)) == done
        @ios.shift
      end

      buffer << result if result
      partial_amount -= result.length if partial_amount && result != done

      break if partial_amount && partial_amount <= 0
      break if result == done
    end

    if buffer.length > 0
      buffer
    else
      done
    end
  end
end

module UploadIO # :nodoc:
  def self.convert!(io, content_type, original_filename, local_path) # :nodoc:
    io.instance_eval(<<-EOS, __FILE__, __LINE__)
      def content_type
        "#{content_type}"
      end
      def original_filename
        "#{original_filename}"
      end
      def local_path
        "#{local_path}"
      end
    EOS
    io
  end
end
