module LoremHelper
  def lorem
    (0..5).map { lorem_words[(lorem_words.length * rand).to_i] }.join(' ')
  end

  def lorem_words
    @w ||=
      %w(lorem ipsum dolor sit amet consecteteur adicicising elit sed do eiusmod) +
      %w(tempor incidudunt nam posture magna aliqua ut labore et dolore) +
      %w(cum sociis nostrud aequitas verificium)
  end
end
