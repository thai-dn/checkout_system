# frozen_string_literal: true

require 'spec_helper.rb'
require_relative '../product'

RSpec.describe Product do
  let(:product) { { code: '001', name: 'Lavender heart', price: 40 } }
  let(:wrong_product) do
    [
      { code: nil, name: 'Lavender heart', price: 40 },
      { code: '001', name: 'Lavender heart', price: -1 }
    ]
  end

  it 'will be created' do
    expect { Product.new(product) }.not_to raise_error(ProductError)
  end

  it 'raises ProductError exception' do
    wrong_product.each do |product|
      expect { Product.new(product) }.to raise_error(ProductError)
    end
  end
end
