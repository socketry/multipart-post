warn "Top level ::CompositeIO is deprecated, require 'multipart/post' and use `Multipart::Post::CompositeReadIO` instead!"
require_relative 'multipart/post'
CompositeIO = Multipart::Post::CompositeReadIO
UploadIO = Multipart::Post::UploadIO
