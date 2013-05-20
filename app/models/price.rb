# == Schema Information
#
# Table name: prices
#
#  id                       :integer          not null, primary key
#  price                    :float
#  agreement_id             :integer
#  product_id               :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  supplier_part_number     :text
#  unit_of_measurement_code :string(5)
#  unit_of_measurement      :string(25)
#  available                :string(255)
#

class Price < ActiveRecord::Base

  belongs_to :agreement, :counter_cache => true
  belongs_to :product

  attr_accessible :price, :product_id, :agreement_id, :supplier_part_number, :unit_of_measurement, :unit_of_measurement_code 

  include Tire::Model::Search
  include Tire::Model::Callbacks

  delegate :deleted_at, :thumbnail_url, :image_url, :commodity_code, :commodity_name, :long_description, :short_description, :manufacturer_name, :manufacturer_part_number, :to => :product, :allow_nil => true
  delegate :erp_supplier_number, :erp_supplier_name, :supplier_active, :client_name, :client_authentication_key, :agreement_type, :active, :to => :agreement, :allow_nil => true

  settings :analysis => {
            :analyzer => {
              :price_analyzer => {
                "tokenizer"    => "lowercase",
                "filter"       => ["porterStem", "phonetic"]}
                # "filter"       => ["porterStem"]}
            }
          } do
    mapping do
      indexes :supplier_active , type: 'boolean'
      indexes :active , type: 'boolean'
      indexes :commodity_code
      indexes :commodity_name
      indexes :long_description, analyzer: 'price_analyzer'
      indexes :short_description, boost: 10, analyzer: 'price_analyzer'
      indexes :supplier_part_number
      indexes :manufacturer_name
      indexes :manufacturer_part_number
    end
  end


  @@attributes_returned = 10

  @@attributes_returned.times do |idx|
    delegate :"attribute_#{idx+1}_name", :"attribute_#{idx+1}_value", :to => :product, :allow_nil => true
  end

  def delete_index
    DeleteIndexWorker.perform_async id
  end

  def update_index
    UpdateIndexWorker.perform_async id
  end

  def set_destroyed_4_tire 
    @destroyed = true
  end

  def to_indexed_json
    methods = [:deleted_at, :manufacturer_name, :supplier_part_number, :short_description, :long_description, :commodity_name, :supplier_active, :client_name, :client_authentication_key, :thumbnail_url, :image_url, :commodity_code, :manufacturer_part_number, :erp_supplier_number, :erp_supplier_name, :agreement_type, :active]
    @@attributes_returned.times do |idx|
      methods << [:"attribute_#{idx+1}_name", :"attribute_#{idx+1}_value"]
    end
    methods.flatten!

    to_json(methods: methods)
  end

  class << self

    def prices_of_filtered_products_belonging_to_client(term, name, pwd)
      term = "%#{term}%"
      where{agreement_id.in( Agreement.belonging_to_client(name, pwd).select{id}) &
        product_id.in( Product.with_description(term).select{id})}
    end

    def prices_of_filtered_products_belonging_to_client_(search_term, name, pwd, options)
      options.reverse_merge!({page:1, per_page: 15, sort: {price: :desc}})
      page = options[:page]
      per_page = options[:per_page]
      sort = options[:sort]
      sort_key = [:price, :manufacturer_name, :supplier_part_number, :short_description, :long_description, :commodity_name, :supplier_active, :client_name, :client_authentication_key].include?(sort.keys.first) ? sort.keys.first : :price
      sort_direction = [:asc, :desc].include?(sort.values.first) ? sort.values.first : :desc

      tire.search(page: page, per_page: per_page) do
        query do
          boolean(:minimum_number_should_match => 1) do
            should { match :short_description, search_term, :type => :phrase }
            should { match :long_description, search_term, :type => :phrase }
            should { match :commodity_name, search_term, :type => :phrase }
            should { match :manufacturer_name, search_term, :type => :phrase }
            should { match :manufacturer_part_number, search_term, :type => :phrase }
            should { match :supplier_part_number, search_term, :type => :phrase }
            must   { match :client_name, name, :type => :phrase }
            must   { string "client_authentication_key:#{pwd}" }
            must   { term :active, true }
            must   { term :supplier_active, true }
          end
        end

        filter :not, :exists => { :field => :deleted_at }
        sort { by sort_key, sort_direction.to_s }
      end
    end

    def search(params)
      tire.search(load: true, per_page: 200) do
        query do
          boolean(:minimum_number_should_match => 1) do
            should { match :short_description, params[:term], :type => :phrase } if params[:term].present?
            should { match :long_description, params[:term], :type => :phrase } if params[:term].present?
            should { match :commodity_name, params[:term], :type => :phrase } if params[:term].present?
            should { match :manufacturer_name, params[:term], :type => :phrase } if params[:term].present?
            should { match :manufacturer_part_number, params[:term], :type => :phrase }
            should { match :supplier_part_number, params[:term], :type => :phrase }
          end
        end

        filter :not, :exists => {:field => :deleted_at}
      end
    end

  end
end
