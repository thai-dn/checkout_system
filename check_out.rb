require './product.rb'

class CheckOut
  attr_reader :original_price, :discount, :product_list

  def initialize(promo_rules = [])
    @promo_rules = promo_rules
    reset
  end

  def reset
    @original_price = 0
    @product_list = []
    @discount_list = { original_price: 0, discount: [] }
  end

  def show_products
    puts '----------------------------------------------'
    puts format('%13s| %23s | %s', 'Product code', 'Name', 'price')
    puts '----------------------------------------------'
    @product_list.each do |product|
      puts format('%13s| %23s | £%0.2f', product.code, product.name, product.price)
    end
    puts '----------------------------------------------'
  end

  def scan(product)
    @product_list << product
    @original_price += product.price
  end

  def total
    # show_products
    apply_promotion
    new_price = @original_price - @discount_list[:original_price]
    discount = @discount_list[:discount].inject(0) { |sum, d| sum += (d[1] == '%' ? new_price * d[0] * 0.01 : d[0]) }
    total_price = new_price - discount
    total_price = 0 if total_price < 0
    applied_promo = total_price != @original_price

    # puts format('original: £%0.2f | discount: £%0.2f | total price: £%.02f| applied_promo %s', @original_price, discount, total_price, applied_promo)
    [total_price, applied_promo]
  end

  def handle_discount(product_price, discount, quantity)
    return product_price * discount[0] * 0.01 * quantity if discount[1] == '%'

    (product_price - discount[0]) * quantity
  end

  def apply_promotion
    @promo_rules.each do |promo|
      next if promo[:min_pay].to_i > @original_price

      count_quantity = @product_list.inject(0) { |sum, _p| sum + 1 }
      next if count_quantity < promo[:quantity]

      if promo[:code]
        product_item = @product_list.select { |p| p.code == promo[:code] }
        product_code_quantity = product_item.inject(0) { |sum, _p| sum + 1 }
        next if product_code_quantity < promo[:quantity]

        if promo[:type] == 'original_price' # applied for a product by code
          @discount_list[:original_price] += handle_discount(product_item[0].price, promo[:discount], product_code_quantity)
        else # applied for all products
          @discount_list[:discount] << promo[:discount]
        end
        next
      end

      @discount_list[:discount] << promo[:discount]
    end
  end
end
