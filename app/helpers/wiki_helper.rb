module WikiHelper
  def highlight_body(page, terms)
    matcher = Regexp.compile "(#{terms.join('|')})", Regexp::IGNORECASE
    text = page.body(:plain)
    i = 0
    windows = []
    while i < text.length
      break unless start = text.index(matcher, i)
      i = start + $0.length
      start, finish = [ start - 16, 0 ].max, [ i + 16, text.length - 1 ].min
      start = windows.pop.first if !windows.empty? && start < windows.last.last
      windows << [ start, finish ]
    end
    windows << [ 0, -1 ] if windows.empty?
    highlight truncate(windows.collect { |s, f| (s > 0 ? " &hellip; " : "") + text[s..f] }.join, :length => 128, :omission => " &hellip;"), terms
  end
end
