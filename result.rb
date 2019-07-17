require './check_out'

promo_list = [
  { name: 'by_min_pay_percent', code: nil, discount: [10, '%'], type: '', quantity: 1, min_pay: 60 },
  { name: 'via_code', code: '001', discount: [8.50, ''], type: 'original_price', quantity: 2, min_pay: 0 }
]

item = Product.new(code: '001', name: 'Lavender heart', price: 9.25)
item2 = Product.new(code: '002', name: 'Personalised cufflinks', price: 45.00)
item3 = Product.new(code: '003', name: 'Kids T-shirt', price: 19.95)

co = CheckOut.new(promo_list)
co.scan(item)
co.scan(item2)
co.scan(item3)
co.show_products
puts 'Total price expected: £%0.2f' % co.total
# ------------------
co.reset
co.scan(item)
co.scan(item3)
co.scan(item)
co.show_products
puts 'Total price expected: £%0.2f' % co.total
# ------------------
co.reset
co.scan(item)
co.scan(item2)
co.scan(item)
co.scan(item3)
co.show_products
puts 'Total price expected: £%0.2f' % co.total