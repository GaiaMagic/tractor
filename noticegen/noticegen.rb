#  -*- coding: utf-8 -*-

require 'csv'

TICKET_TYPE_COL = 3
TICKET_NO_COL = 8
PHONE_NO_COL = 9



data = CSV.open(ARGV[0], 'rb:UTF-8').to_a

columns = data.map {|d| d[TICKET_TYPE_COL] }.uniq.sort.map do |type|
  [type, data.select {|x| x[TICKET_TYPE_COL] == type }]
end

ticket_sets = Hash[columns]

def num_tickets(tickets)
  num_tickets = 0
  tickets.each do |t|
    num_tickets += t[TICKET_NO_COL].split(', ').count
  end
  num_tickets
end

def print_tickets(handle, tickets)
  tickets.each do |t|
    ticket_no = t[TICKET_NO_COL]
    phone_no = t[PHONE_NO_COL]

    handle.puts("票号 #{ticket_no}, 手机 #{phone_no}")
  end
end

File.open('output.txt', 'w') do |f|
  f.puts File.basename(ARGV[0].encode('utf-8'))
  f.puts ''

  ticket_sets.each do |type, tickets|
    f.puts "#{type}：#{num_tickets(tickets)}张"
    print_tickets(f, tickets)
    f.puts '----'
  end
end
