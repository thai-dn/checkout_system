require 'spec_helper.rb'
require_relative '../product'
require_relative '../check_out'

RSpec.describe CheckOut do
  let(:product) { { code: '001', name: 'Lavender heart', price: 50 } }
  let(:product2) { { code: '002', name: 'Personalised cufflinks', price: 50 } }
  let(:p) { Product.new(product) }

  context 'apply promotion' do
    let(:discount_by_value) { [{ name: 'discount_by_value', code: nil, discount: [20, ''], type: nil, quantity: 1, min_pay: 0 }] }
    it 'shoud be applied by value' do
      co = CheckOut.new(discount_by_value)
      co.scan(p)
      total_price, applied_promo = co.total
      expect_price = co.original_price - discount_by_value[0][:discount][0]
      expect total_price.should eq(expect_price)
    end

    let(:promo_with_percent) { [{ name: 'promo_with_percent', code: nil, discount: [10, '%'], type: nil, quantity: 0, min_pay: 0 }] }
    it 'shoud be applied based percent' do
      co = CheckOut.new(promo_with_percent)
      co.scan(p)
      total_price, applied_promo = co.total
      expect_price = co.original_price - co.original_price * promo_with_percent[0][:discount][0] * 0.01
      expect total_price.should eq(expect_price)
    end

    let(:promo_via_code) { [{ name: 'promo_via_code', code: '001', discount: [8.5, ''], type: 'original_price', quantity: 1, min_pay: 0 }] }
    it 'shoud be applied for only a product based on code' do
      p2 = Product.new(product)
      co = CheckOut.new(promo_via_code)
      co.scan(p)
      co.scan(p2)

      total_price, applied_promo = co.total
      expect_price = promo_via_code[0][:discount][0] * 2
      expect total_price.should eq(expect_price)
    end

    let(:promo_based_min_payment) { [{ name: 'promo_based_min_payment', code: nil, discount: [20, ''], type: nil, quantity: 1, min_pay: 50 }] }
    it 'shoud be applied based minimum payment' do
      co = CheckOut.new(promo_based_min_payment)
      co.scan(p)

      total_price, applied_promo = co.total
      expect_price = co.original_price - promo_based_min_payment[0][:discount][0]
      expect total_price.should eq(expect_price)
    end

    let(:promo_via_quantity) { [{ name: 'promo_via_quantity', code: nil, discount: [20, ''], type: nil, quantity: 2, min_pay: 0 }] }
    it 'shoud be applied via quantity' do
      p2 = Product.new(product)
      co = CheckOut.new(promo_via_quantity)
      co.scan(p)
      co.scan(p2)

      total_price, applied_promo = co.total
      expect_price = co.original_price - promo_via_quantity[0][:discount][0]
      expect total_price.should eq(expect_price)
    end

    let(:promo_via_code_quantity) { [{ name: 'promo_via_code_quantity', code: '001', discount: [20, ''], type: nil, quantity: 2, min_pay: 0 }] }
    it 'shoud be applied with code and quantity' do
      co = CheckOut.new(promo_via_code_quantity)
      co.scan(p)
      co.scan(p)

      total_price, applied_promo = co.total
      expect_price = co.original_price - promo_via_code_quantity[0][:discount][0]
      expect total_price.should eq(expect_price)
    end

    let(:promo_via_code_quantity_based_percent) { [{ name: 'promo_via_code_quantity_based_percent', code: '001', discount: [10, '%'], type: nil, quantity: 2, min_pay: 0 }] }
    it 'shoud be applied with code and quantity based percent' do
      co = CheckOut.new(promo_via_code_quantity_based_percent)
      co.scan(p)
      co.scan(p)

      total_price, applied_promo = co.total
      expect_price = co.original_price - (co.original_price * promo_via_code_quantity_based_percent[0][:discount][0] * 0.01)
      expect total_price.should eq(expect_price)
    end

    let(:promo_all_conditions_based_percent) { [{ name: 'promo_all_conditions_based_percent', code: '001', discount: [10, '%'], type: nil, quantity: 2, min_pay: 100 }] }
    it 'shoud be applied with all conditions based percent' do
      p2 = Product.new(product2)
      co = CheckOut.new(promo_all_conditions_based_percent)
      co.scan(p)
      co.scan(p)
      co.scan(p2)

      total_price, applied_promo = co.total
      expect_price = co.original_price - co.original_price * promo_all_conditions_based_percent[0][:discount][0] * 0.01
      expect total_price.should eq(expect_price)
    end

    let(:promo_without_condition) { [{ name: 'promo_without_condition', code: nil, discount: [20, ''], type: nil, quantity: 1, min_pay: 0 }] }
    it 'shoud be applied without condition' do
      co = CheckOut.new(promo_without_condition)
      co.scan(p)

      total_price, applied_promo = co.total
      expect_price = co.original_price - promo_without_condition[0][:discount][0]
      expect total_price.should eq(expect_price)
    end

    let(:promo_without_condition_based_percent) { [{ name: 'promo_without_condition_based_percent', code: nil, discount: [10, '%'], type: nil, quantity: 1, min_pay: 0 }] }
    it 'shoud be applied without condition' do
      co = CheckOut.new(promo_without_condition_based_percent)
      co.scan(p)

      total_price, applied_promo = co.total
      expect_price = co.original_price - (co.original_price * promo_without_condition_based_percent[0][:discount][0] * 0.01)
      expect total_price.should eq(expect_price)
    end
  end

  context 'no promotion apply' do
    let(:no_discount) do
      [
        { name: 'based_code', code: '003', discount: [20, ''], type: nil, quantity: 1, min_pay: 0 },
        { name: 'based_quantity', code: nil, discount: [20, ''], type: nil, quantity: 10, min_pay: 0 },
        { name: 'based_min_pay', code: nil, discount: [20, ''], type: nil, quantity: 1, min_pay: 200 },

        { name: 'based_code_percent', code: '003', discount: [10, '%'], type: nil, quantity: 1, min_pay: 0 },
        { name: 'based_quantity_percent', code: nil, discount: [10, '%'], type: nil, quantity: 10, min_pay: 0 },
        { name: 'based_min_pay_percent', code: nil, discount: [10, '%'], type: nil, quantity: 1, min_pay: 200 },

        { name: 'no_discount', code: nil, discount: [0, ''], type: nil, quantity: 1, min_pay: 0 },
        { name: 'no_discount_percent', code: nil, discount: [0, '%'], type: nil, quantity: 1, min_pay: 0 }
      ]
    end

    it 'shoud not be applied any conditions' do
      p2 = Product.new(product2)
      co = CheckOut.new(no_discount)
      co.scan(p)
      co.scan(p)
      co.scan(p2)
      total_price, applied_promo = co.total
      expect applied_promo.should eq(false)
    end
  end
end
