class TestPlan < ActiveRecord::Base
  attr_accessible :name, :description, :product_id, :status, :custom_items_attributes
  
	belongs_to :product
	belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
	belongs_to :modified_by, :class_name => "User", :foreign_key => "modified_by_id"
	has_many :plan_cases, :dependent => :destroy
	has_many :test_cases, :through => :plan_cases
	has_many :assignments
	has_many :comments, :dependent => :destroy
	has_many :custom_items, :dependent => :destroy
	has_many :custom_fields, :through => :custom_items
  has_many :schedules
  has_many :stencil_test_plans, :dependent => :destroy
  has_many :stencils, :through => :stencil_test_plans
  
	validates :name, :presence => true
	validates :product_id, :presence => true
	
	accepts_nested_attributes_for :custom_items
	
  attr_accessor :test_case_ids
  after_save :update_test_cases

  #after_save callback to handle test_case_ids
  def update_test_cases
    unless test_case_ids.nil?
      self.plan_cases.each do |p|
        p.destroy unless test_case_ids.include?(p.test_case_id.to_s)
        test_case_ids.delete(p.test_case_id.to_s)
      end 
      test_case_ids.each do |c|
        self.plan_cases.create(:test_case_id => c) unless c.blank?
      end
      reload
      self.test_case_ids = nil
    end
  end
end