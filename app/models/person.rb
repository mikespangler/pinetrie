class Person < ActiveRecord::Base
  attr_accessor :name

  def self.load_redis
    r = Redis.new
    if !r.exists(:compl)
      Person.all.each do |person|
        p = person[:name].strip
        (1..(p.length)).each do |name_length|
            prefix = p[0...name_length]
            r.zadd(:compl,0,prefix)
        end
        r.zadd(:compl,0,p+"*")
      end
    end
  end

  def self.complete(prefix,count)
    r = Redis.new
    results = []
    rangelen = 50 # This is not random, try to get replies < MTU size
    start = r.zrank(:compl,prefix)
    return [] if !start
    while results.length != count
        range = r.zrange(:compl,start,start+rangelen-1)
        start += rangelen
        break if !range or range.length == 0
        range.each do |entry|
            minlen = [entry.length,prefix.length].min
            if entry[0...minlen] != prefix[0...minlen]
                count = results.count
                break
            end
            if entry[-1..-1] == "*" and results.length != count
                results << entry[0...-1]
            end
        end
    end
    return results
  end
end



