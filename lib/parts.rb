warn "Top level ::Parts is deprecated, require 'multipart/post' and use `Multipart::Post::Parts` instead!"
require_relative 'multipart/post'

Parts = Multipart::Post::Parts
Object.deprecate_constant :Parts
