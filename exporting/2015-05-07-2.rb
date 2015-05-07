=begin
1、平台从运行开始的第一笔收入到5月6日24:00的流水记录（原价票售出张数及金额，补贴票售出张数及相应的补贴金额和售票金额），如果有合计就更好了。
=end

require 'csv'

t0 = Date.parse('2001-05-02').to_datetime.beginning_of_day
t1 = Date.parse('2015-05-06').to_datetime.end_of_day

qt0 = ActiveRecord::Base.connection.quote(t0)
qt1 = ActiveRecord::Base.connection.quote(t1)

sql = <<SQL
SELECT DISTINCT ON (ticket_settings.id)
       performances.title AS show_name,
       ticket_settings.name AS name,
       performances.created_at AS publish_time,
       orders.created_at AS last_order,
       performances.begin_at AS show_time,
       ticket_settings.price AS ticket_price,
       (ticket_settings.original_price - ticket_settings.price) AS ticket_subsidy,
       ticket_settings.tickets_count AS ticket_count
FROM ticket_settings
JOIN performances ON ticket_settings.performance_id = performances.id
JOIN orders ON orders.ticket_setting_id = ticket_settings.id
WHERE (orders.paid_at BETWEEN #{qt0} AND #{qt1})
  AND ticket_settings.available_via = 'electronic'
ORDER BY ticket_settings.id ASC, orders.created_at DESC
SQL


rst = ActiveRecord::Base.connection.select_all(sql)


CSV.open("/tmp/export-data.csv", 'w') do |csv|
  csv << ['Show name',
          'Ticket name',
          'Publish time',
          'Last order',
          'Show time',
          'Ticket price',
          'Ticket subsidy',
          'Sold ticket count',
          'Total',
          'Subsidy total']

  rst.each do |rec|
    csv << [rec['show_name'],
            rec['name'],
            Time.parse(rec['publish_time']).strftime('%F %T'),
            Time.parse(rec['last_order']).strftime('%F %T'),
            Time.parse(rec['show_time']).strftime('%F'),
            rec['ticket_price'],
            rec['ticket_subsidy'],
            rec['ticket_count'],
            (rec['ticket_price'].to_i * rec['ticket_count'].to_i),
            (rec['ticket_subsidy'].to_i * rec['ticket_count'].to_i)
           ]
  end
end
