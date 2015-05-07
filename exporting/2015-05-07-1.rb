=begin
1、平台从运行开始的第一笔收入到5月6日24:00的流水记录（原价票售出张数及金额，补贴票售出张数及相应的补贴金额和售票金额），如果有合计就更好了。
=end

require 'csv'

t0 = Date.parse('2001-05-02').to_datetime.beginning_of_day
t1 = Date.parse('2015-05-06').to_datetime.end_of_day

qt0 = ActiveRecord::Base.connection.quote(t0)
qt1 = ActiveRecord::Base.connection.quote(t1)


sql = <<SQL
SELECT tickets.id AS ticket_id,
       tickets.name AS ticket_name,
       tickets.performance_id AS perf_id,
       orders.id AS order_id,
       orders.paid_at AS paid_at,
       tickets.refunded_at AS refunded_at,
       tickets.price AS price
FROM tickets
JOIN orders ON (tickets.order_id = orders.id)
WHERE (tickets.status = 'refunding' OR tickets.status = 'refunded')
  AND (tickets.refunding_at BETWEEN #{qt0} AND #{qt1})
ORDER BY tickets.refunded_at
SQL


rst = ActiveRecord::Base.connection.select_all(sql)


def str_time(o)
  return nil if o.nil?
  Time.parse(o).strftime('%F %T')
end

def str_date(o)
  return nil if o.nil?
  Time.parse(o.to_s).strftime('%F')
end

CSV.open("/tmp/export-data.csv", 'w') do |csv|
  csv << ['Ticket id',
          'Ticket name',
          'Show id',
          'Order id',
          'Paid at',
          'Refunded at',
          'Price']

  rst.each do |rec|
    csv << [rec['ticket_id'],
            rec['ticket_name'],
            rec['show_id'],
            rec['order_id'],
            str_time(rec['paid_at']),
            str_time(rec['refunded_at']),
            rec['price']]
  end
end
