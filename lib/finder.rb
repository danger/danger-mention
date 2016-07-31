class FileInfo
  attr_accessor :name
  attr_accessor :changed_lines

  def initialize(name, changed_lines)
    self.name = name
    self.changed_lines = changed_lines
  end
end

class Finder
  def self.parse(diff)
    files = []

    diff.each do |f|
      name = f.path

      if f.type != 'modified'
        files << FileInfo.new(name, 0)
        next
      end

      lines = f.patch.split(/\n/).reject(&:empty?)

      count = 0
      lines[4..-1].each do |line|
        count += 1 if line.start_with?('-', '+')
      end

      files << FileInfo.new(name, count)
    end

    files = files.sort_by(&:changed_lines).reverse
    files.map(&:name)
  end

end
