require 'date'
require 'pp'
require 'csv'
require 'text-table'

def init_table()
  result = Array.new(7)
  (0..6).each{|wday|
    result[wday] = Array.new(24)
    (0..23).each{|hour|
      result[wday][hour] = Array.new
    }
  }
  return result
end

def get_averaged_table(table)
  result = init_table()
  all = []
  (0..6).each{|wday|
    (0..23).each{|hour|
      all = all.concat(table[wday][hour])
    }
  }
  ave = average(all)
  (0..6).each{|wday|
    (0..23).each{|hour|
      tmp = if table[wday][hour].empty?
              nil # ave
            else
              average(table[wday][hour])
            end
      result[wday][hour] = tmp
    }
  }
  return result
end

def average(array)
  array = array.dup.delete_if{|x|x.nil?}
  if array.empty?
    nil
  else
    array.reduce(0.0){|result, n| result + n} / array.count
  end
end

table = Text::Table.new
table.head = [''].concat((0..23).to_a).concat(['ave'])

result = init_table()

all = []
STDIN.each{|line|
  date_tmp, num_tmp = CSV.parse(line).first
  date = DateTime.strptime(date_tmp, "%Y-%m-%d %H:%M:%S %z")
  num = num_tmp.to_f
  all.push num
  result[date.wday][date.send(:hour)].push num
}

ave = average(all)

result = get_averaged_table(result)
orig_result = Marshal.load(Marshal.dump(result))

def format_num(num)
  if num.nil? or num.nan?
    ''
  else
    '%.1f' % num
  end
end

(0..6).each{|wday|
  tmp = (0..23).map{|hour| format_num(orig_result[wday][hour])}
  line = [wday].concat(tmp).concat([format_num(average(orig_result[wday]))])
  table.rows << line
}

last_line = (0..23).map{|hour|
  array = (0..6).map{|wday| orig_result[wday][hour]}
  format_num(average(array))
}.concat([format_num(ave)])

table.rows << ['ave'].concat(last_line)
puts table
