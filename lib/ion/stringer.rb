module Ion::Stringer
  def self.sanitize(str)
    return ''  unless str.is_a?(String)

    # Also remove special characters ("I.B.M. can't" => "ibm cant")
    str.downcase.gsub(/[\.'"]/,'').force_encoding('UTF-8')
  end

  # "Hey,  yes you." => %w(hey yes you)
  def self.keywords(str)
    return Array.new  unless str.is_a?(String)
    split = split_words(sanitize(str))
    split.reject { |s| Ion.config.stopwords.include?(s) }
  end

  def self.split_words(str)
    if RUBY_VERSION >= "1.9"
      str.scan(/[[:word:]]+/)
    else
      # \w doesn't work in Unicode, but it's all you've got for Ruby <=1.8
      str.scan(/\w+/)
    end
  end

  # "one_sign" => "OneSign"
  def self.classify(name)
    str = name.to_s
    str.scan(/\b(\w)(\w*)/).map { |(w, ord)| w.upcase + ord.downcase }.join('')
  end
end
