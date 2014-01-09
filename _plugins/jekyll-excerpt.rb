module Jekyll
  class Post
    alias_method :original_to_liquid, :to_liquid
    def to_liquid(attrs = nil)
      original_to_liquid(attrs).deep_merge({
        'excerpt' => content.match('<hr class="more docutils" />') ? content.split('<hr class="more docutils" />').first : nil
      })
    end
  end
end
