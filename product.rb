require './custom_exceptions'
class Product
  attr_reader :code, :name, :price

  def initialize(product)
    raise ProductError, 'Can not create new product' unless check_product(product)

    @code = product[:code]
    @name = product[:name]
    @price = product[:price]
  end

  def check_product(product)
    return false unless /^\d*\.?\d*$/.match(product[:price].to_s)
    return false if product[:code].nil?

    true
  end

  def show_product
    puts format('%s | %s | %0.2f', @name, @code, @price)
  end
end