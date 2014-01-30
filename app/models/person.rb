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
    r = Redis.new # new connection to redis listening on 6379
    results = [] # the array to be returned
    rangelen = 50 # This is not random, try to get replies < MTU size
    start = r.zrank(:compl,prefix) # ZRANK (key, member)
    #Returns the rank of member in the sorted set stored at key, with the scores ordered from low to high. The rank (or index) is 0-based, which means that the member with the lowest score has rank 0. 
    return [] if !start
    while results.length != count
        range = r.zrange(:compl,start,start+rangelen-1) #ZRANGE key start stop [WITHSCORES] 
        #Returns the specified range of elements in the sorted set stored at key. The elements are considered to be ordered from the lowest to the highest score. 
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



