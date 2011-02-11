module Ion::Helpers
  # Replacement for instance_eval for DSL stuff
  # @example
  #
  #   yieldie(search) { |q| q.text :title, "hi" }
  #   yieldie(search) { text :title, "hi" }
  #
  def yieldie(to=self, &blk)
    (blk.arity > 0) ? yield(to) : to.instance_eval(&blk)
  end
end
